

classdef BindModeSelectionData<handle



    properties(SetAccess=private,GetAccess=public)
        selectionStyle(1,1)BindMode.SelectionStyleEnum;
        selectionTypes(1,:);
        selectionHandles(1,:)double;
        selectionPosition(1,2)double;
        selectionBackendIds(1,:)double;
    end

    methods
        function newObj=BindModeSelectionData(selectionStyle,selectionTypes,...
            selectionHandles,selectionPosition,varargin)
            newObj.selectionStyle=selectionStyle;
            newObj.selectionTypes=selectionTypes;
            newObj.selectionHandles=selectionHandles;
            newObj.selectionPosition=selectionPosition;

            numvarargs=length(varargin);
            if(numvarargs>1)
                error(message('simulink_ui:bind_mode:resources:SelectionDataConstructorTooManyInputs'));
            end
            optargs={[]};
            optargs(1:numvarargs)=varargin;
            [newObj.selectionBackendIds]=optargs{:};
        end
    end
end