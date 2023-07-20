classdef VariableNameGenerator<handle














    properties(Access=private)
Time
Group
Dose
Rate
Response
        MinimumCompartmentIndex=0
    end

    methods
        function obj=VariableNameGenerator(nonmemDefinition,varNames)
            obj.Time=getName(nonmemDefinition.TimeLabel,varNames);
            obj.Group=getName(nonmemDefinition.GroupLabel,varNames);
            obj.Dose=getName(nonmemDefinition.DoseLabel,varNames);

            rateLabel=getName(nonmemDefinition.RateLabel,varNames);
            if isempty(rateLabel)
                obj.Rate='Rate';
            else
                obj.Rate=rateLabel;
            end
            obj.Response=getName(nonmemDefinition.DependentVariableLabel,varNames);
        end

        function name=getName(obj,type,reservedNames,compartment)
            if~exist('compartment','var')
                compartment=[];
            end
            basename=obj.(type);

            count=0;
            name=generateName(obj,basename,compartment,count);
            while any(strcmp(name,reservedNames))
                count=count+1;
                name=generateName(obj,basename,compartment,count);
            end
        end
    end

    methods(Access=private)
        function name=generateName(obj,basename,compartment,count)
            if isempty(compartment)

                if count==0
                    name=basename;
                else
                    name=sprintf('%s%d',basename,count);
                end
            else

                compartmentIndex=max(obj.MinimumCompartmentIndex,compartment);
                name=sprintf('%s%d',basename,compartmentIndex);
            end
        end
    end
end

function name=getName(nameOrIndex,varNames)



    if ischar(nameOrIndex)
        name=nameOrIndex;
    else
        index=nameOrIndex;
        try
            name=varNames{index};
        catch


            name='';
        end
    end
end