import { Resolver, ResolveField, Parent } from '@nestjs/graphql';
import { UserGroupTeamAccess } from './user-group.model';
import { Team } from '../team/team.model';
import { TeamService } from '../team/team.service';
import { throwErr } from '../utils';
import { TEAMS_NOT_FOUND } from '../errors';

@Resolver(() => UserGroupTeamAccess)
export class UserGroupTeamAccessResolver {
  constructor(private readonly teamService: TeamService) {}

  @ResolveField(() => Team, {
    description: 'The team details',
  })
  async team(@Parent() access: UserGroupTeamAccess): Promise<Team> {
    const { teamId } = access as any; // Prisma includes this
    const team = await this.teamService.getTeamWithID(teamId);
    if (!team) throwErr(TEAMS_NOT_FOUND);
    return team;
  }
}
