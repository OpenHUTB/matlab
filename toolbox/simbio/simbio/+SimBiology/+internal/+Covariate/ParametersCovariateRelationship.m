classdef ParametersCovariateRelationship<handle




    properties
Name
Transform
HasRandomEffect
RandomEffectName
InterceptName
CovariateTerms
RowNumber
Expression
    end

    properties(SetAccess=immutable,Dependent)
CovariateNames
FixedEffectNames
FixedEffectDescription
    end

    methods(Static)
        function obj=loadobj(objAsStruct)
            if iscell(objAsStruct.CovariateTerms)
                objAsStruct.CovariateTerms=vertcat(SimBiology.internal.Covariate.CovariateTerm.empty,objAsStruct.CovariateTerms{:});
            end
            obj=SimBiology.internal.Covariate.ParametersCovariateRelationship;
            fieldsToCopy={'Name','Transform','HasRandomEffect','RandomEffectName','InterceptName','CovariateTerms','RowNumber','Expression'};
            for i=1:numel(fieldsToCopy)
                obj.(fieldsToCopy{i})=objAsStruct.(fieldsToCopy{i});
            end
        end
    end

    methods
        function out=get.FixedEffectDescription(obj)
            out={obj.Name,obj.CovariateTerms.SlopeDescription}';
        end

        function out=get.FixedEffectNames(obj)
            out={obj.InterceptName,obj.CovariateTerms.SlopeName}';
        end

        function out=get.CovariateNames(obj)
            out={obj.CovariateTerms.CovariateName}';
        end
    end

end

