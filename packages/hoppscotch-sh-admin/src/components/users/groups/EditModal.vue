<template>
  <HoppSmartModal
    dialog
    :title="t('user_groups.edit_group')"
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
          :label="t('action.save')"
          :loading="updating"
          @click="updateGroup"
        />
      </div>
    </template>
  </HoppSmartModal>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue';
import { useMutation } from '@urql/vue';
import { useI18n } from '~/composables/i18n';
import { useToast } from '~/composables/toast';
import {
  UpdateUserGroupDocument,
  UserGroupTeamAccessRole,
} from '~/helpers/backend/graphql';

const t = useI18n();
const toast = useToast();

const props = defineProps<{
  group: {
    id: string;
    name: string;
    description?: string | null;
    role: UserGroupTeamAccessRole;
  };
}>();

const emit = defineEmits<{
  (event: 'hide-modal'): void;
  (event: 'group-updated'): void;
}>();

// Form State
const name = ref(props.group.name);
const description = ref(props.group.description || '');
const role = ref<UserGroupTeamAccessRole>(props.group.role);

// Watch for group changes
watch(
  () => props.group,
  (newGroup) => {
    name.value = newGroup.name;
    description.value = newGroup.description || '';
    role.value = newGroup.role;
  }
);

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

// Update Mutation
const updateMutation = useMutation(UpdateUserGroupDocument);
const updating = ref(false);

const updateGroup = async () => {
  const trimmedName = name.value.trim();

  if (!trimmedName) {
    toast.error(t('user_groups.name_required'));
    return;
  }

  updating.value = true;

  const result = await updateMutation.executeMutation({
    groupId: props.group.id,
    name: trimmedName !== props.group.name ? trimmedName : undefined,
    description:
      description.value.trim() !== (props.group.description || '')
        ? description.value.trim() || null
        : undefined,
    role: role.value !== props.group.role ? role.value : undefined,
  });

  updating.value = false;

  if (result.error) {
    toast.error(t('user_groups.update_group_failure'));
  } else {
    emit('group-updated');
  }
};

const hideModal = () => {
  emit('hide-modal');
};
</script>
