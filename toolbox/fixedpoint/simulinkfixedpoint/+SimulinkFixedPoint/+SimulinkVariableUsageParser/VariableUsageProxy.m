classdef VariableUsageProxy<handle








    properties(SetAccess=private)
        VariableUsage;
    end
    methods
        function this=VariableUsageProxy(usage)
            this.VariableUsage=usage;
        end

        function name=getName(this)

            name=[];
            if~isempty(this.VariableUsage)
                name=this.VariableUsage.Name;
            end
        end

        function source=getSource(this)

            source=[];
            if~isempty(this.VariableUsage)
                source=this.VariableUsage.Source;
            end
        end

        function sourceType=getSourceType(this)

            sourceType='';
            if~isempty(this.VariableUsage)
                sourceType=this.VariableUsage.SourceType;
            end
        end

        function users=getUserList(this)

            users={};
            if~isempty(this.VariableUsage)
                users=this.VariableUsage.Users;
            end
        end

        function users=getUserObjects(this)

            usersList=getUserList(this);
            nUsers=numel(usersList);
            users={};
            for iUser=1:nUsers


                try
                    users=[users,{get_param(usersList{iUser},'Object')}];%#ok<AGROW>
                catch
                end
            end
        end

        function directDetails=getDirectUsageDetails(this)

            directDetails=[];
            if~isempty(this.VariableUsage)
                directDetails=this.VariableUsage.DirectUsageDetails;
            end
        end
    end
end
