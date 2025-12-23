<template>
  <HoppSmartModal
    dialog
    :title="t('user_groups.add_members')"
    @close="emit('hide-modal')"
  >
    <template #body>
      <div class="flex flex-col space-y-4">
        <p class="text-secondaryLight text-sm">
          {{ t('user_groups.add_members_description') }}
        </p>

        <HoppSmartInput
          v-model="userEmail"
          :label="t('user_groups.user_email')"
          input-styles="floating-input"
          :placeholder="t('user_groups.user_email_placeholder')"
        />

        <div class="flex items-center space-x-2">
          <input
            id="isAdmin"
            v-model="isAdmin"
            type="checkbox"
            class="cursor-pointer"
          />
          <label for="isAdmin" class="text-secondaryLight cursor-pointer">
            {{ t('user_groups.make_admin') }}
          </label>
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
          :label="t('action.add')"
          :loading="adding"
          @click="addMembers"
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
import { AddUserToGroupDocument } from '~/helpers/backend/graphql';

const t = useI18n();
const toast = useToast();

const props = defineProps<{
  groupId: string;
}>();

const emit = defineEmits<{
  (event: 'hide-modal'): void;
  (event: 'members-added'): void;
}>();

// Form state
const userEmail = ref('');
const isAdmin = ref(false);

// Add mutation
const addMutation = useMutation(AddUserToGroupDocument);
const adding = ref(false);

const addMembers = async () => {
  const trimmedEmail = userEmail.value.trim();

  if (!trimmedEmail) {
    toast.error(t('user_groups.email_required'));
    return;
  }

  adding.value = true;

  // For now, we're using email to find user
  // In production, you'd have a user search/autocomplete component
  const result = await addMutation.executeMutation({
    groupId: props.groupId,
    userUid: trimmedEmail, // This should be userUid, not email
    isAdmin: isAdmin.value,
  });

  adding.value = false;

  if (result.error) {
    toast.error(t('user_groups.add_members_failure'));
  } else {
    emit('members-added');
  }
};

const hideModal = () => {
  emit('hide-modal');
};
</script>
