classdef Response<matlab.mixin.SetGet&handle

    properties(Access=public)
        independentVar;
        dependentVar;
        independentVarUnits='';
        dependentVarUnits='';
    end

    methods(Access=public)
        function obj=Response(values)
            if nargin>0
                if isempty(values)
                    obj=SimBiology.internal.plotting.sbioplot.Response.empty;
                else
                    numObj=numel(values);
                    obj=arrayfun(@(~)SimBiology.internal.plotting.sbioplot.Response(),transpose(1:numObj));
                    arrayfun(@(bin,value)configureSingleObjectFromStruct(bin,value),...
                    obj,values);
                end
            end
        end

        function flag=isEqual(obj,comparisonObj)
            flag=strcmp(obj.independentVar,comparisonObj.independentVar)&&...
            strcmp(obj.dependentVar,comparisonObj.dependentVar);
        end

        function response=getStruct(obj)
            response=arrayfun(@(response)struct('independentVar',response.independentVar,...
            'dependentVar',response.dependentVar,...
            'independentVarUnits',response.independentVarUnits,...
            'dependentVarUnits',response.dependentVarUnits),...
            obj);
        end
    end

    methods(Access=private)
        function configureSingleObjectFromStruct(obj,value)
            set(obj,'independentVar',value.independentVar,...
            'dependentVar',value.dependentVar,...
            'independentVarUnits',value.independentVarUnits,...
            'dependentVarUnits',value.dependentVarUnits);
        end
    end
end