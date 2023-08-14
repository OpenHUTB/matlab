classdef(Hidden)OptionalParamModel<handle





    properties
        OptionsRow matlab.visualize.task.internal.model.OptionalParameters
        VizParameters matlab.visualize.task.internal.model.OptionalParameters
    end

    methods
        function obj=OptionalParamModel()
        end

        function addOptionsRowAtIndex(obj,vizProperties,rowIndex)
            obj.OptionsRow=[obj.OptionsRow(1:rowIndex-1),vizProperties,obj.OptionsRow(rowIndex:end)];
        end

        function removeOptionsRowAtIndex(obj,rowIndex)
            obj.OptionsRow(rowIndex)=[];
        end

        function updateParameters(obj,vizParams,selectedParams)
            obj.VizParameters=vizParams;
            obj.OptionsRow=selectedParams;
        end

        function[optionsProp,optionsDesc]=getAllOptionalParameters(obj)
            optionsDesc={getString(message('MATLAB:graphics:visualizedatatask:SelectVariableLabel'))};
            optionsProp={'select variable'};

            for i=1:numel(obj.VizParameters)
                optionalParam=obj.VizParameters(i);
                optionsProp{end+1}=optionalParam.Name;%#ok<*AGROW>
                optionsDesc{end+1}=optionalParam.Description;
            end
        end

        function[optionsProp,optionsDesc]=getAllParameters(obj,selectedVal)
            optionsDesc={getString(message('MATLAB:graphics:visualizedatatask:SelectVariableLabel'))};
            optionsProp={'select variable'};

            for i=1:numel(obj.VizParameters)
                optionalParam=obj.VizParameters(i);
                if~optionalParam.IsSelected||strcmpi(optionalParam.Name,selectedVal)
                    optionsProp{end+1}=optionalParam.Name;
                    optionsDesc{end+1}=optionalParam.Description;
                end
            end
        end

        function vizParamRow=getVizParamData(obj,paramName)
            vizParamRow=matlab.visualize.task.internal.model.OptionalParameters.empty();
            for i=1:numel(obj.VizParameters)
                optionalParam=obj.VizParameters(i);
                if strcmpi(paramName,optionalParam.Name)
                    vizParamRow=optionalParam;
                    break;
                end
            end
        end

        function updateOptionsRows(obj,vizProperties,rowIndex)
            obj.OptionsRow(rowIndex)=vizProperties;
        end

        function updateRowValue(obj,valueToUpdate,rowIndex)
            vizProperties=obj.OptionsRow(rowIndex);
            vizProperties.SelectedValue=valueToUpdate;
            obj.OptionsRow(rowIndex)=vizProperties;
        end

        function OptionsRows=getAllOptionsRows(obj)
            OptionsRows=obj.OptionsRow;
        end
    end
end