<template>
  <HoppSmartModal
    v-if="show"
    dialog
    :title="t('profile.manage_group_members')"
    @close="hideModal"
  >
    <template #body>
      <!-- Result view after adding members -->
      <div v-if="addMembersResult.length" class="flex flex-col px-4">
        <div class="mb-8 flex max-w-md flex-col items-center justify-center">
          <icon-lucide-users class="h-6 w-6 text-accent" />
          <h3 class="my-2 text-center text-lg">
            {{ t("profile.members_added_title") }}
          </h3>
          <p class="text-center">
            {{ t("profile.members_added_description") }}
          </p>
        </div>

        <!-- Success list -->
        <div v-if="successMembers.length">
          <label class="mb-4 block">
            {{ t("profile.success_members") }}
          </label>
          <div
            class="flex flex-col space-y-6 rounded border border-dividerLight p-4"
          >
            <div
              v-for="(member, index) in successMembers"
              :key="`member-${index}`"
              class="flex items-center"
            >
              <p class="flex flex-1 items-center">
                <icon-lucide-check-circle
                  class="svg-icons mr-4 text-green-500"
                />
                <span class="truncate">{{ member.email }}</span>
              </p>
            </div>
          </div>
        </div>

        <!-- Failed list -->
        <div v-if="failedMembers.length" class="mt-6">
          <label class="mb-4 block">
            {{ t("profile.failed_members") }}
          </label>
          <div
            class="flex flex-col space-y-6 rounded border border-dividerLight p-4"
          >
            <div
              v-for="(member, index) in failedMembers"
              :key="`member-${index}`"
              class="flex flex-col"
            >
              <p class="flex items-center">
                <icon-lucide-alert-triangle
                  class="svg-icons mr-4 text-red-500"
                />
                <span class="truncate">{{ member.email }}</span>
              </p>
              <p class="ml-8 mt-1 text-tiny text-secondaryLight">
                {{ getErrorMessage(member.error) }}
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- Loading state -->
      <div
        v-else-if="addingMembers"
        class="flex items-center justify-center p-4"
      >
        <HoppSmartSpinner />
      </div>

      <!-- Main view -->
      <div v-else class="flex flex-col">
        <!-- Group Info (Read-only) -->
        <div
          class="mb-4 rounded border border-dividerLight bg-primaryLight p-4"
        >
          <div class="flex items-center gap-2">
            <icon-lucide-users class="svg-icons text-secondaryLight" />
            <span class="font-semibold">{{ groupName }}</span>
          </div>
        </div>

        <!-- Current Members Section -->
        <div class="flex flex-1 items-center justify-between">
          <label for="memberList" class="px-4 pb-4">
            {{ t("profile.current_members") }}
          </label>
        </div>

        <div class="divide-y divide-dividerLight rounded border border-divider">
          <!-- Loading members -->
          <div
            v-if="groupDetails.loading"
            class="flex items-center justify-center p-4"
          >
            <HoppSmartSpinner />
          </div>

          <!-- Members list -->
          <div v-else>
            <div
              v-if="!groupDetails.loading && E.isRight(groupDetails.data)"
              class="divide-y divide-dividerLight"
            >
              <div
                v-for="(member, index) in currentMembers"
                :key="`member-${index}`"
                class="flex divide-x divide-dividerLight"
              >
                <input
                  class="flex flex-1 bg-transparent px-4 py-2 text-secondaryLight"
                  :placeholder="t('team.email')"
                  :value="member.user?.email || member.userUid"
                  readonly
                />
                <input
                  class="flex w-24 bg-transparent px-4 py-2 text-center text-secondaryLight"
                  :value="
                    member.isAdmin
                      ? t('profile.group_admin')
                      : t('profile.regular_member')
                  "
                  readonly
                />
                <div class="flex">
                  <HoppButtonSecondary
                    v-if="!member.isAdmin"
                    v-tippy="{ theme: 'tooltip' }"
                    :title="t('action.remove')"
                    :icon="IconTrash"
                    color="red"
                    :loading="removingMemberIndex === index"
                    @click="removeMember(member.userUid, index)"
                  />
                  <div
                    v-else
                    v-tippy="{ theme: 'tooltip' }"
                    :title="t('profile.admin_cannot_be_removed')"
                    class="flex items-center justify-center px-3 text-secondaryLight"
                  >
                    <icon-lucide-shield class="svg-icons" />
                  </div>
                </div>
              </div>
            </div>

            <!-- Empty state -->
            <HoppSmartPlaceholder
              v-if="E.isRight(groupDetails.data) && currentMembers.length === 0"
              :src="`/images/states/${colorMode.value}/add_group.svg`"
              :alt="t('empty.members')"
              :text="t('empty.members')"
            />

            <!-- Error state -->
            <div
              v-if="!groupDetails.loading && E.isLeft(groupDetails.data)"
              class="flex flex-col items-center p-4"
            >
              <icon-lucide-help-circle class="svg-icons mb-4" />
              {{ t("error.something_went_wrong") }}
            </div>
          </div>
        </div>

        <!-- Add New Members Section -->
        <div class="flex flex-1 items-center justify-between pt-4">
          <label for="newMemberList" class="p-4">
            {{ t("profile.add_new_members") }}
          </label>
          <div class="flex">
            <HoppButtonSecondary
              :icon="IconPlus"
              :label="t('add.new')"
              filled
              @click="addNewMemberRow"
            />
          </div>
        </div>

        <div class="divide-y divide-dividerLight rounded border border-divider">
          <div
            v-for="(invitee, index) in newMembers"
            :key="`new-member-${index}`"
            class="flex divide-x divide-dividerLight"
          >
            <input
              v-model="invitee.email"
              class="flex flex-1 bg-transparent px-4 py-2"
              :placeholder="t('team.email')"
              autofocus
              @keyup.enter="addMembers"
            />
            <div class="flex">
              <HoppButtonSecondary
                v-tippy="{ theme: 'tooltip' }"
                :title="t('action.remove')"
                :icon="IconTrash"
                color="red"
                @click="removeNewMemberRow(index)"
              />
            </div>
          </div>

          <!-- Empty state for new members -->
          <HoppSmartPlaceholder
            v-if="newMembers.length === 0"
            :src="`/images/states/${colorMode.value}/add_group.svg`"
            :alt="t('empty.invites')"
            :text="t('empty.invites')"
          >
            <template #body>
              <HoppButtonSecondary
                :label="t('add.new')"
                filled
                @click="addNewMemberRow"
              />
            </template>
          </HoppSmartPlaceholder>
        </div>
      </div>
    </template>

    <template #footer>
      <!-- Footer after adding -->
      <p
        v-if="addMembersResult.length"
        class="flex flex-1 justify-between text-secondaryLight"
      >
        <HoppButtonSecondary
          class="link !p-0"
          :label="t('profile.add_more_members')"
          :icon="IconArrowLeft"
          @click="resetAddMembersForm"
        />
        <HoppButtonSecondary
          class="link !p-0"
          :label="t('action.dismiss')"
          @click="hideModal"
        />
      </p>

      <!-- Default footer -->
      <span v-else class="flex space-x-2">
        <HoppButtonPrimary
          :label="t('action.add')"
          :disabled="!hasValidNewMembers"
          outline
          @click="addMembers"
        />
        <HoppButtonSecondary
          :label="t('action.cancel')"
          outline
          filled
          @click="hideModal"
        />
      </span>
    </template>
  </HoppSmartModal>
</template>

<script setup lang="ts">
import { computed, ref, watch } from "vue"
import * as E from "fp-ts/Either"
import { pipe } from "fp-ts/function"
import * as TE from "fp-ts/TaskEither"
import {
  UserGroupDocument,
  UserGroupQuery,
  UserGroupQueryVariables,
} from "~/helpers/backend/graphql"
import {
  addUserToGroupByEmail,
  removeUserFromGroup,
} from "~/helpers/backend/mutations/UserGroup"
import { useGQLQuery } from "~/composables/graphql"
import { useI18n } from "@composables/i18n"
import { useToast } from "@composables/toast"
import { useColorMode } from "@composables/theming"
import { GQLError } from "~/helpers/backend/GQLClient"

import IconPlus from "~icons/lucide/plus"
import IconTrash from "~icons/lucide/trash"
import IconArrowLeft from "~icons/lucide/arrow-left"

const t = useI18n()
const colorMode = useColorMode()
const toast = useToast()

const emit = defineEmits<{
  (e: "hide-modal"): void
}>()

const props = defineProps<{
  show: boolean
  groupId: string
  groupName: string
}>()

// New members to add
const newMembers = ref<Array<{ email: string }>>([{ email: "" }])

// Adding state
const addingMembers = ref(false)
const removingMemberIndex = ref<number | null>(null)

// Result state
type AddMemberResult =
  | { email: string; status: "success" }
  | { email: string; status: "error"; error: GQLError<string> }

const addMembersResult = ref<AddMemberResult[]>([])

const successMembers = computed(() =>
  addMembersResult.value.filter((m) => m.status === "success")
)
const failedMembers = computed(() =>
  addMembersResult.value.filter((m) => m.status === "error")
)

// Fetch group details with members
const groupDetails = useGQLQuery<UserGroupQuery, UserGroupQueryVariables, "">({
  query: UserGroupDocument,
  variables: {
    id: props.groupId,
  },
  defer: true,
})

// Current members from fetched data
const currentMembers = computed(() => {
  if (E.isRight(groupDetails.data) && groupDetails.data.right.userGroup) {
    return groupDetails.data.right.userGroup.members || []
  }
  return []
})

// Watch for groupId changes and load data
watch(
  () => props.groupId,
  (groupId: string) => {
    if (groupId) {
      groupDetails.execute({ id: groupId })
    }
  },
  { immediate: true }
)

// Check if there are valid new members to add
const hasValidNewMembers = computed(() =>
  newMembers.value.some((m) => m.email.trim() !== "")
)

// Add new member row
const addNewMemberRow = () => {
  newMembers.value.push({ email: "" })
}

// Remove new member row
const removeNewMemberRow = (index: number) => {
  newMembers.value.splice(index, 1)
}

// Add all new members
const addMembers = async () => {
  const validMembers = newMembers.value.filter((m) => m.email.trim() !== "")

  if (validMembers.length === 0) {
    toast.error(t("error.incorrect_email"))
    return
  }

  addingMembers.value = true
  addMembersResult.value = []

  const results: AddMemberResult[] = []

  for (const member of validMembers) {
    const result = await pipe(
      addUserToGroupByEmail(props.groupId, member.email.trim(), false),
      TE.match(
        (err) => ({
          email: member.email,
          status: "error" as const,
          error: err,
        }),
        () => ({
          email: member.email,
          status: "success" as const,
        })
      )
    )()

    results.push(result)
  }

  addMembersResult.value = results
  addingMembers.value = false

  // Refresh member list if any success
  if (successMembers.value.length > 0) {
    groupDetails.execute({ id: props.groupId })
  }
}

// Remove a member
const removeMember = async (userUid: string, index: number) => {
  removingMemberIndex.value = index

  const result = await pipe(
    removeUserFromGroup(props.groupId, userUid),
    TE.match(
      (err) => {
        console.error("Error removing member:", err)
        toast.error(t("error.something_went_wrong"))
        return false
      },
      () => {
        toast.success(t("team.member_removed"))
        return true
      }
    )
  )()

  removingMemberIndex.value = null

  if (result) {
    groupDetails.execute({ id: props.groupId })
  }
}

// Get error message for display
const getErrorMessage = (error: GQLError<string>) => {
  if (error.type === "network_error") {
    return t("error.network_error")
  }

  const errorCode = error.error
  switch (errorCode) {
    case "USER_NOT_FOUND":
      return t("profile.user_not_found_by_email")
    case "USER_GROUP_NOT_FOUND":
      return t("profile.group_not_found")
    case "USER_GROUP_MEMBER_EXISTS":
      return t("profile.member_already_exists")
    default:
      return t("error.something_went_wrong")
  }
}

// Reset form to add more members
const resetAddMembersForm = () => {
  addMembersResult.value = []
  newMembers.value = [{ email: "" }]
}

// Hide modal and emit event
const hideModal = () => {
  addMembersResult.value = []
  newMembers.value = [{ email: "" }]
  emit("hide-modal")
}
</script>
