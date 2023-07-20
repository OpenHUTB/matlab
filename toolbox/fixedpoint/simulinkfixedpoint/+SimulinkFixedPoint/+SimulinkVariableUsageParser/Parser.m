classdef Parser<handle




    properties(SetAccess=private)

        UsersFilter SimulinkFixedPoint.SimulinkVariableUsageParser.Filters.UsersFilter=...
        SimulinkFixedPoint.SimulinkVariableUsageParser.Filters.NoUsersFilter;


        SourceTypeFilter SimulinkFixedPoint.SimulinkVariableUsageParser.Filters.SourceTypeFilter=...
        SimulinkFixedPoint.SimulinkVariableUsageParser.Filters.NoSourceTypeFilter;
    end

    methods
        function setUsersFilter(this,usersFilter)

            this.UsersFilter=usersFilter;
        end

        function setSourceTypeFilter(this,sourceTypeFilter)

            this.SourceTypeFilter=sourceTypeFilter;
        end

        function validUsers=getValidUsers(this,context,dataObjectName,varargin)






            usageProxies=SimulinkFixedPoint.SimulinkVariableUsageParser.getUsageProxy(...
            context,...
            dataObjectName,...
            varargin{:});

            usageProxies=getValidUsages(this.SourceTypeFilter,usageProxies);
            validUsers={};
            for iUsage=1:numel(usageProxies)
                users=getUserObjects(usageProxies(iUsage));
                validUsers=[validUsers,getValidUsers(this.UsersFilter,users)];%#ok<AGROW>
            end
        end

        function isValid=isAtLeastOneUserValid(this,context,dataObjectName,varargin)





            usageProxies=SimulinkFixedPoint.SimulinkVariableUsageParser.getUsageProxy(...
            context,...
            dataObjectName,...
            varargin{:});
            isValid=false;
            for iUsage=1:numel(usageProxies)
                usageProxy=getValidUsages(this.SourceTypeFilter,usageProxies(iUsage));
                users=getUserObjects(usageProxy);
                nUsers=numel(users);
                for iUser=1:nUsers
                    if isUserValid(this.UsersFilter,users{iUser})
                        isValid=true;
                        break;
                    end
                end

                if isValid
                    break;
                end
            end
        end
    end
end
