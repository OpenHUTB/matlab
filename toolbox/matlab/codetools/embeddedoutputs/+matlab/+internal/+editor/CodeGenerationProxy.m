classdef CodeGenerationProxy<handle






    properties
        ActionRegistrator matlab.internal.editor.figure.Registrator
    end

    events
InteractionOccured
    end

    methods
        function this=CodeGenerationProxy(actionRegistrator)
            this.ActionRegistrator=actionRegistrator;
        end

        function interactionOccured(this,hObject,action,isUndoable)
            [hObject,action]=this.textEditInteraction(hObject,action);
            this.registerAction(hObject,action);
            eventData=matlab.internal.editor.figure.UndoRedoRegistrationData(hObject,action,isUndoable,true);
            this.notify('InteractionOccured',eventData);
        end

        function[hObject,action]=textEditInteraction(this,hObject,action)%#ok<INUSL> 


            if strcmpi(action,matlab.internal.editor.figure.ActionID.TEXT_EDITED)
                hAx=ancestor(hObject,'matlab.graphics.axis.AbstractAxes');
                if matlab.internal.editor.figure.ChartAccessor.getTitleHandle(hAx)==hObject
                    action=matlab.internal.editor.figure.ActionID.TITLE_EDITED;
                elseif matlab.internal.editor.figure.ChartAccessor.getXlabelHandle(hAx)==hObject
                    action=matlab.internal.editor.figure.ActionID.XLABEL_EDITED;
                elseif matlab.internal.editor.figure.ChartAccessor.getYlabelHandle(hAx)==hObject
                    action=matlab.internal.editor.figure.ActionID.YLABEL_EDITED;
                elseif matlab.internal.editor.figure.ChartAccessor.getZlabelHandle(hAx)==hObject
                    action=matlab.internal.editor.figure.ActionID.ZLABEL_EDITED;
                elseif matlab.internal.editor.figure.ChartAccessor.getLongitudeLabel(hAx)==hObject
                    action=matlab.internal.editor.figure.ActionID.LONGITUDELABEL_EDITED;
                elseif matlab.internal.editor.figure.ChartAccessor.getLatitudeLabel(hAx)==hObject
                    action=matlab.internal.editor.figure.ActionID.LATITUDELABEL_EDITED;
                elseif matlab.internal.editor.figure.ChartAccessor.getSubtitleHandle(hAx)==hObject
                    action=matlab.internal.editor.figure.ActionID.SUBTITLE_EDITED;
                else


                    return
                end
                hObject=hAx;
            end
        end

        function toolstripInteractionOccured(this,hObject,action,isUndoable)



            this.registerAction(hObject,action);
            eventData=matlab.internal.editor.figure.UndoRedoRegistrationData(hObject,action,isUndoable,false);
            this.notify('InteractionOccured',eventData);
        end

        function registerAction(this,hObject,action)

            this.ActionRegistrator.put(hObject,action);
        end
    end
end