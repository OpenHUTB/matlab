classdef PropertySchema<Simulink.BlockPropertySchema




    properties(Access=private)
        hBlockHandle;
    end

    methods(Static)
        function propertySchema=create(hBlock)
            maskObject=Simulink.Mask.get(get(hBlock,'Handle'));
            if isempty(maskObject)||isempty(maskObject.BaseMask)
                propertySchema=matlab.system.ui.PropertySchema(hBlock);
            else


                propertySchema=Simulink.BlockPropertySchema(hBlock);
            end
        end
    end

    methods(Access=private)
        function obj=PropertySchema(h)
            obj@Simulink.BlockPropertySchema(h);
            obj.hBlockHandle=get(h,'Handle');
        end
    end

    methods
        function v=getObjectType(obj)
            systemName=get_param(obj.hBlockHandle,'System');
            if isInitialState(systemName)
                v=get_param(obj.hBlockHandle,'BlockType');
            else
                try
                    header=matlab.system.display.internal.Memoizer.getHeader(systemName);
                    v=header.Title;
                catch e %#ok<NASGU>
                    v=getObjectType@Simulink.BlockPropertySchema(obj);
                end
            end
        end

        function out=setPropertyValues(obj,pvPairs,isImplicit)
            out=setPropertyValues@Simulink.BlockPropertySchema(obj,pvPairs,isImplicit);


            try
                matlab.system.ui.DynDialogManager.onDialogApplied(obj.hBlockHandle);
            catch E

                dp=DAStudio.DialogProvider;
                matlab.system.ui.DynDialogManager.errorDialog(...
                dp.errordlg(E.message,'Error',true));
            end
        end
    end
end

function isInitState=isInitialState(systemName)
    isInitState=matlab.system.ui.DialogManager.isUnspecifiedSystemObject(systemName)||...
    ~matlab.system.display.isSystem(systemName);
end

