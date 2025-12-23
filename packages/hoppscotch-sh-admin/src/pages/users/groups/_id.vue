<template>
  <div class="flex flex-col">
    <div v-if="fetching" class="flex justify-center">
      <HoppSmartSpinner />
    </div>

    <div v-else-if="error" class="text-lg">
      {{ t('user_groups.load_info_error') }}
    </div>

    <div v-else-if="group" class="flex flex-col">
      <div class="flex items-center space-x-4">
        <button
          class="p-2 rounded-3xl bg-divider hover:bg-dividerDark transition flex justify-center items-center"
          @click="router.push('/users/groups')"
        >
          <icon-lucide-arrow-left class="text-xl" />
        </button>
        <div class="flex justify-center items-center space-x-3">
          <h1 class="text-lg text-accentContrast">
            {{ group.name }}
          </h1>
          <span>/</span>
          <h2 class="text-lg text-accentContrast">
            {{ currentTabName }}
          </h2>
        </div>
      </div>

      <div class="py-8">
        <HoppSmartTabs v-model="selectedOptionTab" render-inactive-tabs>
          <HoppSmartTab :id="'details'" :label="t('user_groups.details')">
            <UserGroupsDetails
              v-model:group="group"
              @delete-group="deleteGroup"
              class="py-8 px-4"
            />
          </HoppSmartTab>
          <HoppSmartTab :id="'members'" :label="t('user_groups.members')">
            <UserGroupsMembers v-model:group-id="groupId" class="py-8 px-4" />
          </HoppSmartTab>
          <HoppSmartTab :id="'teams'" :label="t('user_groups.teams')">
            <UserGroupsTeams v-model:group-id="groupId" class="py-8 px-4" />
          </HoppSmartTab>
          <HoppSmartTab :id="'audit'" :label="t('user_groups.audit_log')">
            <UserGroupsAuditLog v-model:group-id="groupId" class="py-8 px-4" />
          </HoppSmartTab>
        </HoppSmartTabs>

        <HoppSmartConfirmModal
          :show="confirmDeletion"
          :title="t('user_groups.confirm_delete_group')"
          @hide-modal="confirmDeletion = false"
          @resolve="deleteGroupMutation(deleteGroupId)"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useQuery, useMutation } from '@urql/vue';
import { computed, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useI18n } from '~/composables/i18n';
import { useToast } from '~/composables/toast';
import {
  DeleteUserGroupDocument,
  GetUserGroupDocument,
} from '~/helpers/backend/graphql';
import UserGroupsDetails from '~/components/users/groups/Details.vue';
import UserGroupsMembers from '~/components/users/groups/Members.vue';
import UserGroupsTeams from '~/components/users/groups/Teams.vue';
import UserGroupsAuditLog from '~/components/users/groups/AuditLog.vue';

const t = useI18n();
const toast = useToast();
const route = useRoute();
const router = useRouter();

// Tabs
type OptionTabs = 'details' | 'members' | 'teams' | 'audit';

const selectedOptionTab = ref<OptionTabs>('details');

const currentTabName = computed(() => {
  switch (selectedOptionTab.value) {
    case 'details':
      return t('user_groups.group_details');
    case 'members':
      return t('user_groups.group_members');
    case 'teams':
      return t('user_groups.assigned_teams');
    case 'audit':
      return t('user_groups.audit_log');
    default:
      return '';
  }
});

// Get Group Info
const groupId = ref(route.params.id.toString());

const { data, fetching, error, executeQuery } = useQuery({
  query: GetUserGroupDocument,
  variables: { id: groupId.value },
});

const group = computed(() => data.value?.userGroup);

// Refetch when route changes
watch(
  () => route.params.id,
  (newId) => {
    groupId.value = newId.toString();
    executeQuery();
  }
);

// Delete group
const confirmDeletion = ref(false);
const groupDeletion = useMutation(DeleteUserGroupDocument);
const deleteGroupId = ref<string | null>(null);

const deleteGroup = (id: string) => {
  confirmDeletion.value = true;
  deleteGroupId.value = id;
};

const deleteGroupMutation = async (id: string | null) => {
  if (!id) {
    confirmDeletion.value = false;
    toast.error(t('user_groups.delete_group_failure'));
    return;
  }

  const result = await groupDeletion.executeMutation({ groupId: id });

  if (result.error) {
    toast.error(t('user_groups.delete_group_failure'));
  } else {
    toast.success(t('user_groups.delete_group_success'));
    router.push('/users/groups');
  }

  confirmDeletion.value = false;
  deleteGroupId.value = null;
};
</script>
