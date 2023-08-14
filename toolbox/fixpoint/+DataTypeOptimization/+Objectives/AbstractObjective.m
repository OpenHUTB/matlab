classdef(Abstract)AbstractObjective<handle







    properties(SetAccess=private)
environmentContext
decisionVariablesCount
definitionDomains
    end

    methods
        function this=AbstractObjective(environmentContext,decisionVariables)
            this.environmentContext=environmentContext;
            this.validate();



            this.decisionVariablesCount=zeros(1,numel(decisionVariables));

            this.definitionDomains=DataTypeOptimization.DefinitionDomain.empty(0,numel(decisionVariables));
            for dIndex=1:numel(this.decisionVariablesCount)

                this.decisionVariablesCount(dIndex)=double(decisionVariables(dIndex).group.members.Count);
                this.definitionDomains(dIndex)=decisionVariables(dIndex).definitionDomain;
            end

        end
    end

    methods(Abstract)
        cost=measure(this,solution);
        validate(this);
    end

end

