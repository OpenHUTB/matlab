
function doUpdate(obj,~)









    anc=ancestor(obj,'matlab.ui.internal.mixin.CanvasHostMixin');
    if~isempty(anc)
        canvas=anc.getCanvas();
        if isa(canvas,'matlab.graphics.primitive.canvas.HTMLCanvas')


            if obj.isMobileToolbar()
                return
            end


            if obj.canRegisterInteraction(obj.Axes)


                tempVis=obj.Visible;
                tempVisMode=obj.VisibleMode;

                obj.Visible='off';



                if canvas.ServerSideRendering==1

                    if obj.Opacity~=0
                        obj.Opacity=0;
                    end
                else

                    if obj.Opacity~=1
                        obj.Opacity=1;
                    end
                end

                obj.Visible=tempVis;
                obj.VisibleMode=tempVisMode;

                obj.registerToolbarInteraction(obj.Axes,canvas);
            else
                if~isempty(obj.Interaction)&&isvalid(obj.Interaction)
                    obj.Opacity=0;
                    if~isempty(canvas)
                        canvas.InteractionsManager.unregisterInteraction(obj.Interaction);
                    end
                    delete(obj.Interaction);
                end
            end
        end
    end
    obj.setInternalPosition();
end
