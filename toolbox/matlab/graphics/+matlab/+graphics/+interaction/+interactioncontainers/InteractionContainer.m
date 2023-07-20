classdef(ConstructOnLoad=true)InteractionContainer<handle&...
    matlab.graphics.mixin.internal.GraphicsDataTypeContainer




    properties(Hidden,SetObservable,Dependent,Transient,NonCopyable)
Enabled
InteractionsArray
    end

    properties(Hidden,SetObservable,AbortSet)
        Enabled_I matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
InteractionsArray_I
    end

    properties(Hidden)
        EnabledMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';



        InteractionsArrayMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual;
    end

    properties(Hidden,Transient,SetObservable,NonCopyable)
        List=[];

Canvas
Figure
    end

    properties(Hidden,Transient,SetObservable,NonCopyable)
        GObj{matlab.internal.validation.mustBeValidGraphicsObject(GObj,'matlab.graphics.Graphics')}
    end

    methods(Hidden)
        function clearList(hObj)
            hObj.List=[];
        end
    end

    methods(Abstract)
        validateInteractions(hObj,array);

        findConflicts(hObj,arr);

        updateInteractionsAfterDisablingThem(hObj);
        updateInteractions(hObj);

        arr=getDefaultInteractionsArray(hObj);
    end

    methods
        function hObj=InteractionContainer(gobj)
            hObj.GObj=gobj;
            hObj.InteractionsArrayMode="auto";
        end

        function setInteractionsArray(hObj,array)
            hObj.InteractionsArray=array;
        end

        function arr=getInteractionsArray(hObj)
            arr=hObj.InteractionsArray;
        end



        function set.Enabled(hObj,e)
            if strcmp(e,'on')&&~isempty(hObj.Figure)&&isvalid(hObj.Figure)&&...
                matlab.graphics.interaction.internal.UnifiedAxesInteractions.checkIfHWCallbacksExist(hObj.GObj,hObj.Figure)

            else
                hObj.Enabled_I=e;
                hObj.EnabledMode='manual';
                if strcmp(e,'off')
                    hObj.updateInteractionsAfterDisablingThem();
                else
                    hObj.updateCanvasAndFigure();
                    hObj.updateInteractions();
                end
            end
        end

        function e=get.Enabled(hObj)
            e=hObj.Enabled_I;
        end

        function set.InteractionsArray(hObj,arr)
            areAllInteractions=all(isa(arr,'matlab.graphics.interaction.interface.BaseInteraction'));
            isInteractionSet=isscalar(arr)&&isa(arr,'matlab.graphics.interaction.interface.BaseInteractionSet');

            if~areAllInteractions&&~isInteractionSet&&~(isempty(arr)&&isnumeric(arr))
                ME=MException(message('MATLAB:graphics:interaction:InteractionsProperty'));
                throwAsCaller(ME);
            end

            hObj.validateInteractions(arr);
            hObj.findConflicts(arr);

            hObj.InteractionsArray_I=arr;
            hObj.InteractionsArrayMode='manual';

            hObj.clearList();
            hObj.updateInteractions();
        end

        function set.InteractionsArrayMode(hObj,val)
            if strcmp(val,'auto')




                hObj.InteractionsArray_I=hObj.getDefaultInteractionsArray();%#ok<MCSUP> 
            end
            hObj.InteractionsArrayMode=val;
        end

        function arr=get.InteractionsArray(hObj)
            if strcmp(hObj.InteractionsArrayMode,'auto')
                if isempty(hObj.InteractionsArray_I)
                    hObj.InteractionsArray_I=hObj.getDefaultInteractionsArray();
                end
            end
            arr=hObj.InteractionsArray_I;
        end

        function updateCanvasAndFigure(hObj)



            canvas=matlab.graphics.interaction.internal.UnifiedAxesInteractions.getCanvas(hObj.GObj);
            if isempty(canvas)||~isvalid(canvas)


                return
            end
            hObj.Canvas=canvas;

            fig=ancestor(hObj.GObj,'figure');
            if isempty(fig)||~isvalid(fig)
                return;
            end

            if isempty(hObj.Figure)||~isvalid(hObj.Figure)||(hObj.Figure~=fig)
                hObj.clearList();
            end
            hObj.Figure=fig;
        end
    end
end
