classdef ParsedCovariateModel<handle




    properties
        ParameterCovariateRelationships=SimBiology.internal.Covariate.ParametersCovariateRelationship.empty
    end
    properties(SetAccess=immutable,Dependent)
NumberOfParameters
NumberOfSlopes
ParameterNames
CovariateNames
ParamTransform
REParamsSelect
FixedEffectNames
FixedEffectDescription
RandomEffectNames
    end

    methods(Static=true)
        function obj=loadobj(objAsStruct)


            if iscell(objAsStruct.ParameterCovariateRelationships)
                parameterCovariateRelationships=vertcat(objAsStruct.ParameterCovariateRelationships{:});
            else
                parameterCovariateRelationships=objAsStruct.ParameterCovariateRelationships;
            end
            obj=SimBiology.internal.Covariate.ParsedCovariateModel;
            obj.ParameterCovariateRelationships=parameterCovariateRelationships;
        end
    end

    methods
        function out=get.NumberOfParameters(obj)
            out=numel(obj.ParameterCovariateRelationships);
        end

        function out=get.NumberOfSlopes(obj)
            covariateTerms=vertcat(obj.ParameterCovariateRelationships.CovariateTerms);
            out=numel(covariateTerms);
        end

        function out=get.ParameterNames(obj)
            out=makeColumnCell(obj.ParameterCovariateRelationships.Name);
        end

        function out=get.CovariateNames(obj)
            out=vertcat({},obj.ParameterCovariateRelationships.CovariateNames);
            out=makeColumnCell(unique(out));
            if isempty(out)


                out={};
            end
        end

        function out=get.ParamTransform(obj)

            t.exp=1;
            t.probitinv=2;
            t.logitinv=3;


            out=zeros(obj.NumberOfParameters,1);
            for i=1:obj.NumberOfParameters
                if~isempty(obj.ParameterCovariateRelationships(i).Transform)
                    out(i)=t.(obj.ParameterCovariateRelationships(i).Transform);
                else
                    out(i)=0;
                end
            end
        end

        function out=get.REParamsSelect(obj)
            out=false(numel(obj.ParameterCovariateRelationships),1);
            for i=1:numel(out)
                out(i)=obj.ParameterCovariateRelationships(i).HasRandomEffect;
            end




        end


        function out=get.FixedEffectNames(obj)
            interceptNames={obj.ParameterCovariateRelationships.InterceptName}';
            covariateTerms=vertcat(obj.ParameterCovariateRelationships.CovariateTerms);
            if isempty(covariateTerms)
                slopeNames={};
            else
                slopeNames={covariateTerms.SlopeName}';
            end
            out=makeColumnCell(interceptNames,slopeNames);
        end

        function out=get.FixedEffectDescription(obj)
            interceptNames={obj.ParameterCovariateRelationships.Name}';
            covariateTerms=vertcat(obj.ParameterCovariateRelationships.CovariateTerms);
            if isempty(covariateTerms)
                slopeNames={};
            else
                slopeNames={covariateTerms.SlopeDescription}';
            end
            out=makeColumnCell(interceptNames,slopeNames);
        end

        function out=get.RandomEffectNames(obj)
            out=makeColumnCell(obj.ParameterCovariateRelationships.RandomEffectName);

            out=out(~strcmp(out,''));
            out=makeColumnCell(out);
        end
    end
end

function out=makeColumnCell(varargin)
    if isempty(varargin)
        out=cell(0,1);
    elseif iscell(varargin{1})
        out=reshape(vertcat(varargin{:}),[],1);
    else
        out=reshape(vertcat(varargin(:)),[],1);
    end
end
