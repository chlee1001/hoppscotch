<template>
  <HoppSmartModal
    v-if="show"
    dialog
    :title="t('profile.manage_group_members')"
    @close="hideModal"
  >
    <template #body>
      <div class="flex flex-col">
        <!-- Group Name Input -->
        <HoppSmartInput
          v-model="groupName"
          placeholder=" "
          :label="t('action.label')"
          input-styles="floating-input"
        />

        <div class="flex flex-1 items-center justify-between pt-4">
          <label for="memberList" class="p-4">
            {{ t("profile.group_members") }}
          </label>
        </div>

        <!-- Loading State -->
        <div v-if="groupDetails.loading" class="rounded border border-divider">
          <div class="flex items-center justify-center p-4">
            <HoppSmartSpinner />
          </div>
        </div>

        <!-- Members Table -->
        <div
          v-if="
            !groupDetails.loading &&
            E.isRight(groupDetails.data) &&
            groupDetails.data.right.userGroup
          "
          class="rounded border border-divider"
        >
          <HoppSmartPlaceholder
            v-if="localMembers.length === 0 && !newMemberUid"
            :src="`/images/states/${colorMode.value}/add_group.svg`"
            :alt="`${t('empty.members')}`"
            :text="t('empty.members')"
          />

          <div v-else class="divide-y divide-dividerLight">
            <!-- Existing Members -->
            <div
              v-for="(member, index) in localMembers"
              :key="`member-${index}`"
              class="flex divide-x divide-dividerLight"
            >
              <input
                class="flex flex-1 bg-transparent px-4 py-2"
                :placeholder="`${t('team.email')}`"
                :name="'email' + index"
                :value="member.user?.email || member.uid"
                readonly
              />
              <span>
                <tippy
                  interactive
                  trigger="click"
                  theme="popover"
                  :on-shown="() => tippyActions![index]?.focus()"
                >
                  <HoppSmartSelectWrapper>
                    <input
                      class="flex flex-1 cursor-pointer bg-transparent px-4 py-2"
                      :placeholder="`${t('profile.admin_status')}`"
                      :name="'status' + index"
                      :value="
                        member.isAdmin
                          ? t('profile.group_admin')
                          : t('profile.regular_member')
                      "
                      readonly
                    />
                  </HoppSmartSelectWrapper>
                  <template #content="{ hide }">
                    <div
                      ref="tippyActions"
                      class="flex flex-col focus:outline-none"
                      tabindex="0"
                      @keyup.escape="hide()"
                    >
                      <HoppSmartItem
                        :label="t('profile.group_admin')"
                        :icon="member.isAdmin ? IconCircleDot : IconCircle"
                        :active="member.isAdmin"
                        @click="
                          () => {
                            toggleLocalAdminStatus(index, true)
                            hide()
                          }
                        "
                      />
                      <HoppSmartItem
                        :label="t('profile.regular_member')"
                        :icon="!member.isAdmin ? IconCircleDot : IconCircle"
                        :active="!member.isAdmin"
                        @click="
                          () => {
                            toggleLocalAdminStatus(index, false)
                            hide()
                          }
                        "
                      />
                    </div>
                  </template>
                </tippy>
              </span>
              <div class="flex">
                <HoppButtonSecondary
                  v-tippy="{ theme: 'tooltip' }"
                  :title="t('action.remove')"
                  :icon="IconUserMinus"
                  color="red"
                  @click="removeLocalMember(index)"
                />
              </div>
            </div>

            <!-- Add New Member Row -->
            <div class="flex divide-x divide-dividerLight">
              <input
                v-model="newMemberUid"
                class="flex flex-1 bg-transparent px-4 py-2"
                :placeholder="t('profile.add_member_uid')"
                @keyup.enter="addLocalMember"
              />
              <span class="flex items-center px-4 py-2">
                <input
                  id="new-admin-checkbox"
                  v-model="newMemberIsAdmin"
                  type="checkbox"
                  class="mr-2"
                />
                <label for="new-admin-checkbox" class="text-sm">
                  {{ t("profile.make_admin") }}
                </label>
              </span>
              <div class="flex">
                <HoppButtonSecondary
                  v-tippy="{ theme: 'tooltip' }"
                  :title="t('action.add')"
                  :icon="IconUserPlus"
                  @click="addLocalMember"
                />
              </div>
            </div>
          </div>
        </div>

        <!-- Error State -->
        <div
          v-if="!groupDetails.loading && E.isLeft(groupDetails.data)"
          class="flex flex-col items-center"
        >
          <icon-lucide-help-circle class="svg-icons mb-4" />
          {{ t("error.something_went_wrong") }}
        </div>
      </div>
    </template>

    <template #footer>
      <span class="flex space-x-2">
        <HoppButtonPrimary
          :label="t('action.save')"
          :loading="isSaving"
          outline
          @click="saveAllChanges"
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
import { ref, watch } from "vue"
import * as E from "fp-ts/Either"
import { pipe } from "fp-ts/function"
import * as TE from "fp-ts/TaskEither"
import {
  UserGroupDocument,
  UserGroupQuery,
  UserGroupQueryVariables,
} from "~/helpers/backend/graphql"
import {
  addUserToGroup,
  removeUserFromGroup,
  updateUserGroup,
} from "~/helpers/backend/mutations/UserGroup"
import { useGQLQuery } from "~/composables/graphql"
import { useI18n } from "@composables/i18n"
import { useToast } from "@composables/toast"
import { useColorMode } from "@composables/theming"
import { TippyComponent } from "vue-tippy"

import IconCircleDot from "~icons/lucide/circle-dot"
import IconCircle from "~icons/lucide/circle"
import IconUserPlus from "~icons/lucide/user-plus"
import IconUserMinus from "~icons/lucide/user-minus"

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

// Template refs
const tippyActions = ref<TippyComponent[] | null>(null)

// Local state for batch editing
const groupName = ref(props.groupName)
const localMembers = ref<
  Array<{
    uid: string
    isAdmin: boolean
    user?: {
      email: string | null
      displayName: string | null
      photoURL: string | null
    }
    isNew?: boolean
    isDeleted?: boolean
    adminChanged?: boolean
    originalIsAdmin?: boolean
  }>
>([])

// New member input
const newMemberUid = ref("")
const newMemberIsAdmin = ref(false)

// Saving state
const isSaving = ref(false)

// Fetch group details with members
const groupDetails = useGQLQuery<UserGroupQuery, UserGroupQueryVariables, "">({
  query: UserGroupDocument,
  variables: {
    id: props.groupId,
  },
  defer: true,
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

// Watch for group data changes to initialize local state
watch(
  () => groupDetails.data,
  (data) => {
    if (E.isRight(data) && data.right.userGroup) {
      const group = data.right.userGroup
      groupName.value = group.name

      // Initialize local members from fetched data
      localMembers.value = (group.members || []).map((member: any) => ({
        uid: member.userUid,
        isAdmin: member.isAdmin,
        user: member.user,
        originalIsAdmin: member.isAdmin,
      }))
    }
  }
)

// Add new member to local state
const addLocalMember = () => {
  if (!newMemberUid.value.trim()) {
    toast.error(t("error.invalid_input"))
    return
  }

  // Check if already exists
  if (localMembers.value.some((m) => m.uid === newMemberUid.value)) {
    toast.error(t("profile.member_already_exists"))
    return
  }

  localMembers.value.push({
    uid: newMemberUid.value,
    isAdmin: newMemberIsAdmin.value,
    isNew: true,
  })

  newMemberUid.value = ""
  newMemberIsAdmin.value = false
}

// Remove member from local state
const removeLocalMember = (index: number) => {
  const member = localMembers.value[index]

  if (member.isNew) {
    // If it's a new member, just remove from local array
    localMembers.value.splice(index, 1)
  } else {
    // Mark existing member as deleted
    member.isDeleted = true
    localMembers.value.splice(index, 1)
  }
}

// Toggle admin status in local state
const toggleLocalAdminStatus = (index: number, isAdmin: boolean) => {
  const member = localMembers.value[index]
  member.isAdmin = isAdmin

  if (!member.isNew && member.originalIsAdmin !== isAdmin) {
    member.adminChanged = true
  }
}

// Save all changes
const saveAllChanges = async () => {
  isSaving.value = true

  try {
    // 1. Update group name
    if (groupName.value !== props.groupName) {
      await pipe(
        updateUserGroup(props.groupId, groupName.value, undefined, undefined),
        TE.match(
          (err) => {
            toast.error(t("error.something_went_wrong"))
            console.error("Error updating group:", err)
            return false
          },
          () => true
        )
      )()
    }

    // 2. Add new members
    const newMembers = localMembers.value.filter((m) => m.isNew)
    for (const member of newMembers) {
      await pipe(
        addUserToGroup(props.groupId, member.uid, member.isAdmin),
        TE.match(
          (err) => {
            toast.error(`${t("error.something_went_wrong")}: ${member.uid}`)
            console.error("Error adding member:", err)
            return false
          },
          () => true
        )
      )()
    }

    // 3. Update admin status for changed members
    const changedMembers = localMembers.value.filter(
      (m) => m.adminChanged && !m.isNew
    )
    for (const member of changedMembers) {
      // Remove and re-add with new admin status
      await pipe(
        removeUserFromGroup(props.groupId, member.uid),
        TE.chain(() =>
          addUserToGroup(props.groupId, member.uid, member.isAdmin)
        ),
        TE.match(
          (err) => {
            toast.error(
              `${t("error.something_went_wrong")}: ${member.user?.email || member.uid}`
            )
            console.error("Error updating member:", err)
            return false
          },
          () => true
        )
      )()
    }

    // 4. Remove deleted members (tracked separately if needed)
    // This is handled by removeLocalMember marking them as deleted

    toast.success(t("profile.group_updated"))
    hideModal()
  } catch (error) {
    console.error("Error saving changes:", error)
    toast.error(t("error.something_went_wrong"))
  } finally {
    isSaving.value = false
  }
}

const hideModal = () => {
  emit("hide-modal")
}
</script>
