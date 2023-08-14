function figureModeInteractionOnEnter(hFig)




    if~isprop(hFig,'FigureModeData')&&matlab.graphics.interaction.internal.containsAxesInMode(hFig)
        setupAppData(hFig);
        localStartMode(hFig);
    end

    function setupAppData(hFig)
        figureDataProp=addprop(hFig,'FigureModeData');
        figureDataProp.Hidden=true;
        figureDataProp.Transient=true;
        hFig.FigureModeData=matlab.graphics.interaction.internal.WebFigureModeInteractionData(hFig);

        function localStartMode(hFig)
            set(hFig,'UIModeEnabled','on');
            set(hFig,'WindowButtonUpFcn','');
            set(hFig,'WindowButtonDownFcn','');
            hFig.FigureModeData.WindowMousePressListener=addlistener(hFig,'WindowMousePress',@webModeWindowButtonDownFcn);

            set(hFig,'WindowKeyPressFcn','');
            set(hFig,'WindowKeyReleaseFcn','');
            set(hFig,'WindowScrollWheelFcn','');
            set(hFig,'KeyPressFcn','');
            set(hFig,'KeyReleaseFcn','');
            hFig.FigureModeData.setWindowCallbackSetListeners('on');

            function webModeWindowButtonDownFcn(hFig,evd)







                h=evd.HitObject;
                fig_sel_type=get(hFig,'SelectionType');
                legendWithAutoButtonDownFcn=matlab.graphics.interaction.internal.hitLegendWithDefaultButtonDownFcn(evd);
                if~legendWithAutoButtonDownFcn
                    cacheProperty(h,hFig.FigureModeData,'ButtonDownFcn',true)
                end
                if(strcmpi(fig_sel_type,'alt'))
                    cacheProperty(h,hFig.FigureModeData,'ContextMenu',false);
                    openModeContextMenu(h,evd);
                    setupWindowCallbacks(h,evd,hFig.FigureModeData)
                elseif((isa(h,'matlab.ui.container.Container')&&matlab.graphics.interaction.internal.containsAxesInMode(h))||...
                    matlab.graphics.interaction.internal.objectInAxesInMode(h))
                    setupWindowCallbacks(h,evd,hFig.FigureModeData)
                end

                function cacheProperty(h,interactionData,propertyName,checkIfChildrenAreInMode)

                    hasProperty=~isempty(h)&&isprop(h,propertyName)&&~isequal(get(h,propertyName),'');
                    if~hasProperty
                        return
                    elseif((isa(h,'matlab.ui.container.Container')&&...
                        (checkIfChildrenAreInMode&&matlab.graphics.interaction.internal.containsAxesInMode(h)))||...
                        matlab.graphics.interaction.internal.objectInAxesInMode(h))
                        interactionData.setPropertyToRestore(propertyName,h.(propertyName));
                        set(h,propertyName,'');
                    end

                    function setupWindowCallbacks(hObj,evd,interactionData)


                        hFig=ancestor(hObj,'figure');
                        if(~isempty(hFig.WindowButtonUpFcn))
                            hFig.WindowButtonUpFcn();
                        end
                        interactionData.setWindowCallbackSetListeners('off');
                        hFig.WindowButtonUpFcn=@(o,e)restoreAllButtonCallback(hObj,interactionData.PropertyRestoreMap,hFig);


                        function openModeContextMenu(hObj,evd)
                            hAxes=ancestor(hObj,'axes');
                            if(~isempty(hAxes)&&isprop(hAxes,'ModeContextMenu')&&~isequal(hAxes.ModeContextMenu,'')...
                                &&isprop(hObj,'ContextMenu'))
                                set(hObj,'ContextMenu',hAxes.ModeContextMenu);
                            end

                            function restoreAllButtonCallback(h,propMap,hFig)

                                keySet=keys(propMap);
                                for i=1:numel(keySet)
                                    propertyName=keySet{i};
                                    valueName=propMap(propertyName);
                                    restoreButtonCallback(h,propertyName,valueName,hFig);
                                end
                                set(hFig,'WindowButtonUpFcn','');
                                hFig.FigureModeData.setWindowCallbackSetListeners('on');
                                hFig.FigureModeData.clearProperties();


                                function restoreButtonCallback(h,prop,value,hFig)

                                    if isvalid(h)
                                        try
                                            h.(prop)=value;
                                        catch ME
                                            if~strcmp(ME.identifier,'MATLAB:ui:uifigure:UnsupportedAppDesignerFunctionality')
                                                rethrow(ME);
                                            end
                                        end
                                    end
