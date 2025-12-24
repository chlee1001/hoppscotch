import { Module, forwardRef } from '@nestjs/common';
import { UserGroupService } from './user-group.service';
import { UserGroupResolver } from './user-group.resolver';
import { UserGroupMemberResolver } from './user-group-member.resolver';
import { UserGroupTeamAccessResolver } from './user-group-team-access.resolver';
import { UserGroupAuditLogResolver } from './user-group-audit-log.resolver';
import { UserGroupPermissionService } from './user-group-permission.service';
import { UserGroupAuditService } from './user-group-audit.service';
import { GqlUserGroupAdminGuard } from './guards/gql-user-group-admin.guard';
import { GqlSystemAdminGuard } from './guards/gql-system-admin.guard';
import { PrismaModule } from '../prisma/prisma.module';
import { UserModule } from '../user/user.module';
import { PubSubModule } from '../pubsub/pubsub.module';
import { TeamModule } from '../team/team.module';

@Module({
  imports: [
    PrismaModule,
    UserModule,
    PubSubModule,
    forwardRef(() => TeamModule),
  ],
  providers: [
    UserGroupService,
    UserGroupResolver,
    UserGroupMemberResolver,
    UserGroupTeamAccessResolver,
    UserGroupAuditLogResolver,
    UserGroupPermissionService,
    UserGroupAuditService,
    GqlUserGroupAdminGuard,
    GqlSystemAdminGuard,
  ],
  exports: [UserGroupService, UserGroupPermissionService],
})
export class UserGroupModule {}
