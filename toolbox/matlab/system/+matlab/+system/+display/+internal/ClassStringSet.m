classdef(Sealed,Hidden)ClassStringSet




    properties(SetAccess=private)
        Values={};
        PropertiesTitle;
        Labels={};
        ConstructorExpressions={};
        NestDisplay;
        AllowCustomExpression;
        CustomExpressionLabel;
    end

    properties(Dependent,Hidden)
        Set;
    end

    methods
        function obj=ClassStringSet(values,varargin)

            obj.Values=values;


            p=inputParser;
            cellStrValidator=@(x)iscellstr(x)&&isequal(numel(x),numel(values));
            p.addParameter('PropertiesTitle','',@ischar);
            p.addParameter('ConstructorExpressions',values,cellStrValidator);
            p.addParameter('Labels',values,cellStrValidator);
            p.addParameter('NestDisplay',true,@islogical);
            p.addParameter('AllowCustomExpression',false,@islogical);
            p.addParameter('CustomExpressionLabel',message('MATLAB:system:classExpressionLabel').getString,@ischar);
            p.parse(varargin{:});
            results=p.Results;


            obj.PropertiesTitle=results.PropertiesTitle;
            obj.Labels=results.Labels;
            obj.ConstructorExpressions=results.ConstructorExpressions;
            obj.NestDisplay=results.NestDisplay;
            obj.AllowCustomExpression=results.AllowCustomExpression;
            obj.CustomExpressionLabel=results.CustomExpressionLabel;
        end

        function v=get.Set(obj)
            if(obj.AllowCustomExpression)
                v=[obj.Labels,obj.CustomExpressionLabel];
            else
                v=obj.Labels;
            end
        end
    end
end
