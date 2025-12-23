<template>
  <HoppSmartModal
    dialog
    :title="t('user_groups.assign_teams')"
    @close="emit('hide-modal')"
  >
    <template #body>
      <div class="flex flex-col space-y-4">
        <p class="text-secondaryLight text-sm">
          {{ t('user_groups.assign_teams_description') }}
        </p>

        <HoppSmartInput
          v-model="teamId"
          :label="t('user_groups.team_id')"
          input-styles="floating-input"
          :placeholder="t('user_groups.team_id_placeholder')"
        />
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
          :label="t('action.assign')"
          :loading="assigning"
          @click="assignTeams"
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
import { AssignGroupToTeamDocument } from '~/helpers/backend/graphql';

const t = useI18n();
const toast = useToast();

const props = defineProps<{
  groupId: string;
}>();

const emit = defineEmits<{
  (event: 'hide-modal'): void;
  (event: 'teams-assigned'): void;
}>();

// Form state
const teamId = ref('');

// Assign mutation
const assignMutation = useMutation(AssignGroupToTeamDocument);
const assigning = ref(false);

const assignTeams = async () => {
  const trimmedTeamId = teamId.value.trim();

  if (!trimmedTeamId) {
    toast.error(t('user_groups.team_id_required'));
    return;
  }

  assigning.value = true;

  const result = await assignMutation.executeMutation({
    groupId: props.groupId,
    teamId: trimmedTeamId,
  });

  assigning.value = false;

  if (result.error) {
    toast.error(t('user_groups.assign_teams_failure'));
  } else {
    emit('teams-assigned');
  }
};

const hideModal = () => {
  emit('hide-modal');
};
</script>
