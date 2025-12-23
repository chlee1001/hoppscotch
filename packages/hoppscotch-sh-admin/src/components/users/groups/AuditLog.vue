<template>
  <div class="flex flex-col space-y-4">
    <h3 class="text-lg font-semibold">{{ t('user_groups.audit_log') }}</h3>

    <HoppSmartTable
      v-model:list="auditLogsList"
      :headings="headings"
      :loading="fetching"
    >
      <template #head>
        <th class="px-6 py-2">{{ t('user_groups.action') }}</th>
        <th class="px-6 py-2">{{ t('user_groups.target_type') }}</th>
        <th class="px-6 py-2">{{ t('user_groups.performed_by') }}</th>
        <th class="px-6 py-2">{{ t('user_groups.performed_at') }}</th>
        <th class="px-6 py-2">{{ t('user_groups.ip_address') }}</th>
      </template>

      <template #empty-state>
        <td colspan="5">
          <span class="flex justify-center p-3">
            {{
              error
                ? t('user_groups.load_audit_logs_error')
                : t('user_groups.no_audit_logs')
            }}
          </span>
        </td>
      </template>

      <template #body="{ row: log }">
        <td class="py-2 px-7">
          <span
            class="text-xs font-medium px-2 py-1 rounded bg-primaryDark text-secondaryLight"
          >
            {{ log.action }}
          </span>
        </td>

        <td class="py-2 px-7">{{ log.targetType }}</td>

        <td class="py-2 px-7">{{ log.performedBy }}</td>

        <td class="py-2 px-7">
          {{ formatDate(log.performedAt) }}
        </td>

        <td class="py-2 px-7">{{ log.ipAddress || t('state.not_available') }}</td>
      </template>
    </HoppSmartTable>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useQuery } from '@urql/vue';
import { format } from 'date-fns';
import { useI18n } from '~/composables/i18n';
import { GetUserGroupAuditLogsDocument } from '~/helpers/backend/graphql';

const t = useI18n();

const props = defineProps<{
  groupId: string;
}>();

// Format helper
const formatDate = (date: string) => {
  return format(new Date(date), 'dd MMM yyyy, hh:mm a');
};

// Table headings
const headings = [
  { key: 'action', label: t('user_groups.action') },
  { key: 'targetType', label: t('user_groups.target_type') },
  { key: 'performedBy', label: t('user_groups.performed_by') },
  { key: 'performedAt', label: t('user_groups.performed_at') },
  { key: 'ipAddress', label: t('user_groups.ip_address') },
];

// Fetch audit logs
const { data, fetching, error } = useQuery({
  query: GetUserGroupAuditLogsDocument,
  variables: { groupId: props.groupId, limit: 100, offset: 0 },
});

const auditLogsList = computed(() => data.value?.userGroupAuditLogs || []);
</script>
