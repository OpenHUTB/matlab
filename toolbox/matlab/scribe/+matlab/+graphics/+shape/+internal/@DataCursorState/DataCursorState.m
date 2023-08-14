classdef DataCursorState<matlab.graphics.mixin.internal.GraphicsDataTypeContainer







    properties(Access=public)


        SnapToDataVertex matlab.internal.datatype.matlab.graphics.datatype.on_off='on';



        DisplayStyle{matlab.internal.validation.mustBeASCIICharRowVector(DisplayStyle,'DisplayStyle')}='datatip';


        UpdateFcn=[];


        DefaultExportVarName{matlab.internal.validation.mustBeASCIICharRowVector(DefaultExportVarName,'DefaultExportVarName')}='cursor_info';

        Interpreter matlab.internal.datatype.matlab.graphics.datatype.TextInterpreter='tex';
    end

    methods
        function hObj=set.DisplayStyle(hObj,newValue)
            newValue=matlab.internal.validation.makeCharRowVector(newValue);
            if~any(strcmpi(newValue,{'datatip','window'}))
                error(message('MATLAB:graphics:datacursormanager:InvalidDisplayStyle',newValue));
            end
            hObj.DisplayStyle=lower(newValue);
        end
    end
    methods
        function obj=set.DefaultExportVarName(obj,value)
            obj.DefaultExportVarName=matlab.internal.validation.makeCharRowVector(value);
        end
    end
end
