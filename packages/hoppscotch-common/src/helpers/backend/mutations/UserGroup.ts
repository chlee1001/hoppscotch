import { runMutation } from "../GQLClient"
import {
  AddUserToGroupDocument,
  AddUserToGroupMutation,
  AddUserToGroupMutationVariables,
  AddUserToGroupByEmailDocument,
  AddUserToGroupByEmailMutation,
  AddUserToGroupByEmailMutationVariables,
  RemoveUserFromGroupDocument,
  RemoveUserFromGroupMutation,
  RemoveUserFromGroupMutationVariables,
  UpdateUserGroupDocument,
  UpdateUserGroupMutation,
  UpdateUserGroupMutationVariables,
  UserGroupTeamAccessRole,
} from "../graphql"

type AddUserToGroupErrors =
  | "user_group/not_found"
  | "user_group/user_already_member"

type AddUserToGroupByEmailErrors =
  | "user_group/not_found"
  | "user_group/user_already_member"
  | "user/not_found"

type RemoveUserFromGroupErrors =
  | "user_group/not_found"
  | "user_group/user_not_member"

type UpdateUserGroupErrors = "user_group/not_found" | "user_group/invalid_name"

export const addUserToGroup = (
  groupId: string,
  userUid: string,
  isAdmin: boolean
) =>
  runMutation<
    AddUserToGroupMutation,
    AddUserToGroupMutationVariables,
    AddUserToGroupErrors
  >(AddUserToGroupDocument, {
    groupId,
    userUid,
    isAdmin,
  })

export const addUserToGroupByEmail = (
  groupId: string,
  email: string,
  isAdmin: boolean
) =>
  runMutation<
    AddUserToGroupByEmailMutation,
    AddUserToGroupByEmailMutationVariables,
    AddUserToGroupByEmailErrors
  >(AddUserToGroupByEmailDocument, {
    groupId,
    email,
    isAdmin,
  })

export const removeUserFromGroup = (groupId: string, userUid: string) =>
  runMutation<
    RemoveUserFromGroupMutation,
    RemoveUserFromGroupMutationVariables,
    RemoveUserFromGroupErrors
  >(RemoveUserFromGroupDocument, {
    groupId,
    userUid,
  })

export const updateUserGroup = (
  groupId: string,
  name?: string,
  description?: string,
  role?: UserGroupTeamAccessRole
) =>
  runMutation<
    UpdateUserGroupMutation,
    UpdateUserGroupMutationVariables,
    UpdateUserGroupErrors
  >(UpdateUserGroupDocument, {
    groupId,
    name,
    description,
    role,
  })
