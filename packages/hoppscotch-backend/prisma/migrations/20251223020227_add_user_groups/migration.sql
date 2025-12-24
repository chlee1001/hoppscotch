-- CreateEnum
CREATE TYPE "UserGroupAuditAction" AS ENUM ('GROUP_CREATED', 'GROUP_UPDATED', 'GROUP_DELETED', 'MEMBER_ADDED', 'MEMBER_REMOVED', 'MEMBER_ADMIN_GRANTED', 'MEMBER_ADMIN_REVOKED', 'TEAM_ACCESS_GRANTED', 'TEAM_ACCESS_REVOKED', 'INVITATION_SENT', 'INVITATION_ACCEPTED', 'INVITATION_EXPIRED');

-- DropIndex
DROP INDEX "TeamCollection_title_trgm_idx";

-- DropIndex
DROP INDEX "TeamRequest_title_trgm_idx";

-- DropIndex
DROP INDEX "idx_mock_examples_team_requests_gin";

-- DropIndex
DROP INDEX "idx_mock_examples_user_requests_gin";

-- CreateTable
CREATE TABLE "UserGroup" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "role" "TeamAccessRole" NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "UserGroup_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UserGroupMember" (
    "id" TEXT NOT NULL,
    "userUid" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "isAdmin" BOOLEAN NOT NULL DEFAULT false,
    "addedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "addedBy" TEXT NOT NULL,

    CONSTRAINT "UserGroupMember_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UserGroupTeamAccess" (
    "id" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "teamId" TEXT NOT NULL,
    "assignedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "assignedBy" TEXT NOT NULL,

    CONSTRAINT "UserGroupTeamAccess_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UserGroupInvitation" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "invitedBy" TEXT NOT NULL,
    "invitedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "acceptedAt" TIMESTAMP(3),

    CONSTRAINT "UserGroupInvitation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UserGroupAuditLog" (
    "id" TEXT NOT NULL,
    "groupId" TEXT,
    "action" "UserGroupAuditAction" NOT NULL,
    "targetType" TEXT NOT NULL,
    "targetId" TEXT,
    "details" JSONB,
    "performedBy" TEXT NOT NULL,
    "performedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ipAddress" TEXT,
    "userAgent" TEXT,

    CONSTRAINT "UserGroupAuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "UserGroup_name_key" ON "UserGroup"("name");

-- CreateIndex
CREATE INDEX "UserGroup_name_idx" ON "UserGroup"("name");

-- CreateIndex
CREATE INDEX "UserGroupMember_groupId_idx" ON "UserGroupMember"("groupId");

-- CreateIndex
CREATE INDEX "UserGroupMember_userUid_idx" ON "UserGroupMember"("userUid");

-- CreateIndex
CREATE UNIQUE INDEX "UserGroupMember_userUid_groupId_key" ON "UserGroupMember"("userUid", "groupId");

-- CreateIndex
CREATE INDEX "UserGroupTeamAccess_groupId_idx" ON "UserGroupTeamAccess"("groupId");

-- CreateIndex
CREATE INDEX "UserGroupTeamAccess_teamId_idx" ON "UserGroupTeamAccess"("teamId");

-- CreateIndex
CREATE UNIQUE INDEX "UserGroupTeamAccess_groupId_teamId_key" ON "UserGroupTeamAccess"("groupId", "teamId");

-- CreateIndex
CREATE INDEX "UserGroupInvitation_email_idx" ON "UserGroupInvitation"("email");

-- CreateIndex
CREATE INDEX "UserGroupInvitation_groupId_idx" ON "UserGroupInvitation"("groupId");

-- CreateIndex
CREATE UNIQUE INDEX "UserGroupInvitation_email_groupId_key" ON "UserGroupInvitation"("email", "groupId");

-- CreateIndex
CREATE INDEX "UserGroupAuditLog_groupId_idx" ON "UserGroupAuditLog"("groupId");

-- CreateIndex
CREATE INDEX "UserGroupAuditLog_performedAt_idx" ON "UserGroupAuditLog"("performedAt");

-- CreateIndex
CREATE INDEX "UserGroupAuditLog_action_idx" ON "UserGroupAuditLog"("action");

-- AddForeignKey
ALTER TABLE "UserGroupMember" ADD CONSTRAINT "UserGroupMember_userUid_fkey" FOREIGN KEY ("userUid") REFERENCES "User"("uid") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserGroupMember" ADD CONSTRAINT "UserGroupMember_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "UserGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserGroupTeamAccess" ADD CONSTRAINT "UserGroupTeamAccess_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "UserGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserGroupTeamAccess" ADD CONSTRAINT "UserGroupTeamAccess_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES "Team"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserGroupInvitation" ADD CONSTRAINT "UserGroupInvitation_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "UserGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserGroupAuditLog" ADD CONSTRAINT "UserGroupAuditLog_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "UserGroup"("id") ON DELETE SET NULL ON UPDATE CASCADE;
