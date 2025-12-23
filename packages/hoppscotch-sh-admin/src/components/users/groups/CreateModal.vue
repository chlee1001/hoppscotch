<template>
  <HoppSmartModal
    dialog
    :title="t('user_groups.create_group')"
    @close="emit('hide-modal')"
  >
    <template #body>
      <div class="flex flex-col space-y-4">
        <HoppSmartInput
          v-model="name"
          :label="t('user_groups.group_name')"
          input-styles="floating-input"
          :placeholder="t('user_groups.group_name_placeholder')"
        />

        <HoppSmartInput
          v-model="description"
          :label="t('user_groups.description')"
          input-styles="floating-input"
          :placeholder="t('user_groups.description_placeholder')"
        />

        <div class="flex flex-col">
          <label class="text-secondaryLight text-tiny mb-2">
            {{ t('user_groups.default_role') }}
          </label>
          <HoppSmartSelect
            v-model="role"
            :options="roleOptions"
          />
        </div>
      </div>
    </template>
    <template #footer>
      <div class="flex justify-end space-x-2">
        <HoppButtonSecondary
          :label="t('action.cancel')"
          outline
          filled
          @click="hideModal"
        />
        <HoppButtonPrimary
          :label="t('action.create')"
          :loading="creating"
          @click="createGroup"
        />
      </div>
    </template>
  </HoppSmartModal>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useMutation } from '@urql/vue';
import { useI18n } from '~/composables/i18n';
import { useToast } from '~/composables/toast';
import {
  CreateUserGroupDocument,
  UserGroupTeamAccessRole,
} from '~/helpers/backend/graphql';

const t = useI18n();
const toast = useToast();

const emit = defineEmits<{
  (event: 'hide-modal'): void;
  (event: 'group-created'): void;
}>();

// Form State
const name = ref('');
const description = ref('');
const role = ref<UserGroupTeamAccessRole>(UserGroupTeamAccessRole.Viewer);

// Role Options
const roleOptions = [
  {
    label: t('user_groups.role_viewer'),
    value: UserGroupTeamAccessRole.Viewer,
  },
  {
    label: t('user_groups.role_editor'),
    value: UserGroupTeamAccessRole.Editor,
  },
  {
    label: t('user_groups.role_owner'),
    value: UserGroupTeamAccessRole.Owner,
  },
];

// Create Mutation
const createMutation = useMutation(CreateUserGroupDocument);
const creating = ref(false);

const createGroup = async () => {
  const trimmedName = name.value.trim();

  if (!trimmedName) {
    toast.error(t('user_groups.name_required'));
    return;
  }

  creating.value = true;

  const result = await createMutation.executeMutation({
    name: trimmedName,
    description: description.value.trim() || null,
    role: role.value,
  });

  creating.value = false;

  if (result.error) {
    toast.error(t('user_groups.create_group_failure'));
  } else {
    emit('group-created');
  }
};

const hideModal = () => {
  emit('hide-modal');
};
</script>
