<template>
  <div class="flex flex-col space-y-6">
    <div class="space-y-4">
      <div class="flex flex-col">
        <label class="font-semibold text-secondaryLight text-tiny mb-2">
          {{ t('user_groups.group_name') }}
        </label>
        <span class="text-secondaryDark">{{ group.name }}</span>
      </div>

      <div class="flex flex-col">
        <label class="font-semibold text-secondaryLight text-tiny mb-2">
          {{ t('user_groups.description') }}
        </label>
        <span class="text-secondaryDark">
          {{ group.description || t('state.none') }}
        </span>
      </div>

      <div class="flex flex-col">
        <label class="font-semibold text-secondaryLight text-tiny mb-2">
          {{ t('user_groups.default_role') }}
        </label>
        <span
          class="text-xs font-medium px-3 py-1 rounded-full w-min"
          :class="getRoleBadgeClass(group.role)"
        >
          {{ getRoleLabel(group.role) }}
        </span>
      </div>

      <div class="flex flex-col">
        <label class="font-semibold text-secondaryLight text-tiny mb-2">
          {{ t('user_groups.created_at') }}
        </label>
        <span class="text-secondaryDark">
          {{ formatDate(group.createdAt) }}
        </span>
      </div>

      <div v-if="group.updatedAt" class="flex flex-col">
        <label class="font-semibold text-secondaryLight text-tiny mb-2">
          {{ t('user_groups.updated_at') }}
        </label>
        <span class="text-secondaryDark">
          {{ formatDate(group.updatedAt) }}
        </span>
      </div>
    </div>

    <div class="flex space-x-2">
      <HoppButtonPrimary
        :label="t('user_groups.edit_group')"
        :icon="IconEdit"
        @click="showEditModal = true"
      />
      <HoppButtonSecondary
        :label="t('user_groups.delete_group')"
        :icon="IconTrash"
        class="!hover:bg-red-600"
        @click="emit('delete-group', group.id)"
      />
    </div>

    <!-- Edit Modal -->
    <UserGroupsEditModal
      v-if="showEditModal"
      :group="group"
      @hide-modal="showEditModal = false"
      @group-updated="onGroupUpdated"
    />
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { format } from 'date-fns';
import { useI18n } from '~/composables/i18n';
import { useToast } from '~/composables/toast';
import { UserGroupTeamAccessRole } from '~/helpers/backend/graphql';
import UserGroupsEditModal from './EditModal.vue';
import IconEdit from '~icons/lucide/pencil';
import IconTrash from '~icons/lucide/trash';

const t = useI18n();
const toast = useToast();

const props = defineProps<{
  group: {
    id: string;
    name: string;
    description?: string | null;
    role: UserGroupTeamAccessRole;
    createdAt: string;
    updatedAt?: string;
  };
}>();

const emit = defineEmits<{
  (event: 'update:group', group: any): void;
  (event: 'delete-group', id: string): void;
}>();

// Format helpers
const formatDate = (date: string) => {
  return format(new Date(date), 'dd MMM yyyy, hh:mm a');
};

// Role helpers
const getRoleLabel = (role: UserGroupTeamAccessRole) => {
  const labels = {
    [UserGroupTeamAccessRole.Owner]: t('user_groups.role_owner'),
    [UserGroupTeamAccessRole.Editor]: t('user_groups.role_editor'),
    [UserGroupTeamAccessRole.Viewer]: t('user_groups.role_viewer'),
  };
  return labels[role] || role;
};

const getRoleBadgeClass = (role: UserGroupTeamAccessRole) => {
  const classes = {
    [UserGroupTeamAccessRole.Owner]: 'bg-purple-900 text-purple-300',
    [UserGroupTeamAccessRole.Editor]: 'bg-blue-900 text-blue-300',
    [UserGroupTeamAccessRole.Viewer]: 'bg-gray-700 text-gray-300',
  };
  return classes[role] || 'bg-gray-700 text-gray-300';
};

// Edit modal
const showEditModal = ref(false);

const onGroupUpdated = () => {
  showEditModal.value = false;
  toast.success(t('user_groups.group_updated_success'));
  // Trigger parent refetch
  window.location.reload();
};
</script>
