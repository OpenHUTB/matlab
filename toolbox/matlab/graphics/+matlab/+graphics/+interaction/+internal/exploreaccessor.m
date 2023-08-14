classdef(CaseInsensitiveProperties=true)exploreaccessor<matlab.mixin.SetGet




    properties(AbortSet,SetObservable,GetObservable)

        ButtonDownFilter=[];
        ActionPreCallback=[];
        ActionPostCallback=[];
Enable
    end

    properties(AbortSet,SetObservable,GetObservable,Hidden)
        ModeHandle=[];
    end

    properties(SetAccess=protected,AbortSet,SetObservable,GetObservable)
        FigureHandle=[];
    end

    properties(Dependent)
        UseLegacyExplorationModes matlab.internal.datatype.matlab.graphics.datatype.on_off;
    end

    methods
        function[hThis]=exploreaccessor(hMode)

            if~isvalid(hMode)||~isa(hMode,'matlab.uitools.internal.uimode')
                error(message('MATLAB:graphics:exploreaccessor:InvalidConstructor'));
            end
            set(hThis,'ModeHandle',hMode);
            hMode.ModeStateData.accessor=hThis;
        end

    end

    methods
        function value=get.ButtonDownFilter(obj)
            value=localGetFromMode(obj,obj.ButtonDownFilter,'ButtonDownFilter');
        end
        function set.ButtonDownFilter(obj,value)
            if matlab.ui.internal.isUIFigure(obj.FigureHandle)%#ok<*MCSUP>
                enableLegacyExplorationModes(obj.FigureHandle);
            end


            obj.ButtonDownFilter=localSetToMode(obj,value,'ButtonDownFilter');
        end

        function value=get.ActionPreCallback(obj)
            value=localGetFromMode(obj,obj.ActionPreCallback,'ActionPreCallback');
        end
        function set.ActionPreCallback(obj,value)
            if matlab.ui.internal.isUIFigure(obj.FigureHandle)
                enableLegacyExplorationModes(obj.FigureHandle);
            end


            obj.ActionPreCallback=localSetToMode(obj,value,'ActionPreCallback');
        end

        function value=get.ActionPostCallback(obj)
            value=localGetFromMode(obj,obj.ActionPostCallback,'ActionPostCallback');
        end
        function set.ActionPostCallback(obj,value)
            if matlab.ui.internal.isUIFigure(obj.FigureHandle)
                enableLegacyExplorationModes(obj.FigureHandle);
            end


            obj.ActionPostCallback=localSetToMode(obj,value,'ActionPostCallback');
        end

        function value=get.Enable(obj)
            value=localGetEnable(obj,obj.Enable);
        end
        function set.Enable(obj,value)
            if matlab.ui.internal.isUIFigure(obj.FigureHandle)
                enableLegacyExplorationModes(obj.FigureHandle);
            end


            validatestring(value,{'on','off'},'','Enable');
            obj.Enable=localSetEnable(obj,value);
        end

        function value=get.FigureHandle(obj)
            value=localGetFromMode(obj,obj.FigureHandle,'FigureHandle');
        end

        function value=get.UseLegacyExplorationModes(obj)
            if isprop(obj.FigureHandle,'UseLegacyExplorationModes')
                value=matlab.lang.OnOffSwitchState(obj.FigureHandle.UseLegacyExplorationModes);
            else
                value=matlab.lang.OnOffSwitchState(false);
            end
        end

        function set.UseLegacyExplorationModes(obj,val)
            if isprop(obj.FigureHandle,'UseLegacyExplorationModes')&&...
                obj.FigureHandle.UseLegacyExplorationModes&&~val
                error(message('MATLAB:graphics:interaction:CannotDisableLegacyExplorationModes'));
            elseif val
                enableLegacyExplorationModes(obj.FigureHandle);
            end
        end
    end
end

function newValue=localSetToMode(hThis,valueProposed,propName)

    try
        set(hThis.ModeHandle,propName,valueProposed);
    catch ex
        rethrow(ex);
    end
    newValue=valueProposed;
end



function valueToCaller=localGetFromMode(hThis,~,propName)

    try
        valueToCaller=get(hThis.ModeHandle,propName);
    catch ex
        rethrow(ex);
    end
end



function newValue=localSetEnable(hThis,valueProposed)

    hMode=hThis.ModeHandle;
    try
        if strcmpi(valueProposed,'on')
            activateuimode(hThis.FigureHandle,hMode.Name);
        else
            activateuimode(hThis.FigureHandle,'');
        end
    catch ex
        rethrow(ex);
    end
    newValue=valueProposed;
end



function valueToCaller=localGetEnable(hThis,~)

    hMode=hThis.ModeHandle;
    res=isactiveuimode(hThis.FigureHandle,hMode.Name);
    if res
        valueToCaller='on';
    else
        valueToCaller='off';
    end
end
