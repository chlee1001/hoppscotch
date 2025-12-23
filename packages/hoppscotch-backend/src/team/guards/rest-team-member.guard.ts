import {
  CanActivate,
  ExecutionContext,
  Injectable,
  Inject,
  forwardRef,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { TeamService } from '../../team/team.service';
import { TeamAccessRole } from '../../team/team.model';
import { UserGroupPermissionService } from '../../user-group/user-group-permission.service';
import {
  BUG_TEAM_NO_REQUIRE_TEAM_ROLE,
  BUG_AUTH_NO_USER_CTX,
  BUG_TEAM_NO_TEAM_ID,
  TEAM_MEMBER_NOT_FOUND,
  TEAM_NOT_REQUIRED_ROLE,
} from 'src/errors';
import { throwHTTPErr } from 'src/utils';

@Injectable()
export class RESTTeamMemberGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly teamService: TeamService,
    @Inject(forwardRef(() => UserGroupPermissionService))
    private readonly userGroupPermissionService: UserGroupPermissionService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const requireRoles = this.reflector.get<TeamAccessRole[]>(
      'requiresTeamRole',
      context.getHandler(),
    );
    if (!requireRoles)
      throwHTTPErr({ message: BUG_TEAM_NO_REQUIRE_TEAM_ROLE, statusCode: 400 });

    const request = context.switchToHttp().getRequest();

    const { user } = request;
    if (user == undefined)
      throwHTTPErr({ message: BUG_AUTH_NO_USER_CTX, statusCode: 400 });

    const teamID = request.params.teamID;
    if (!teamID)
      throwHTTPErr({ message: BUG_TEAM_NO_TEAM_ID, statusCode: 400 });

    // Use UserGroupPermissionService to resolve role (includes direct + group membership)
    const userRole = await this.userGroupPermissionService.resolveUserTeamRole(
      user.uid,
      teamID,
    );

    if (!userRole)
      throwHTTPErr({ message: TEAM_MEMBER_NOT_FOUND, statusCode: 404 });

    // Type assertion needed: Prisma enum and GraphQL enum have same values but are different types
    if (requireRoles.includes(userRole as TeamAccessRole)) return true;

    throwHTTPErr({ message: TEAM_NOT_REQUIRED_ROLE, statusCode: 403 });
  }
}
