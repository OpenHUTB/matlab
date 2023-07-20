classdef FigureBasedModeStrategy<matlab.graphics.controls.internal.AbstractModeStrategy





    properties(Access=private)
ModeListener
ModeStateDataListener
ModeManagerListener
    end

    methods

        function handleModeChange(obj,~,eventData)
            obj.setToolbarModeState();
            if~isempty(eventData)&&~isempty(eventData.AffectedObject.CurrentMode)&&...
                strcmp(eventData.AffectedObject.CurrentMode.Name,'Exploration.Zoom')

                if isempty(obj.ModeStateDataListener)




                    obj.ModeStateDataListener=matlab.graphics.controls.internal.ZoomDirectionListener(...
                    eventData.AffectedObject,@()obj.setToolbarModeState);
                end
            else
                obj.ModeStateDataListener=[];
            end
        end

        function createListeners(obj,canvas,~)
            fig=obj.getCanvasFigure(canvas);
            if~isempty(fig)&&isprop(fig,'ModeManager')&&~isempty(fig.ModeManager)...
                &&~isstruct(fig.ModeManager)

                if isempty(obj.ModeListener)
                    obj.ModeListener=matlab.graphics.controls.internal.ModeListener(fig.ModeManager,...
                    fig.ModeManager.findprop('CurrentMode'),'PostSet',@(e,d)obj.handleModeChange(e,d),...
                    fig);
                end

                if~isempty(fig.ModeManager.CurrentMode)&&...
                    strcmp(fig.ModeManager.CurrentMode.Name,'Exploration.Zoom')




                    obj.ModeStateDataListener=matlab.graphics.controls.internal.ZoomDirectionListener(...
                    fig.ModeManager,@()obj.setToolbarModeState);
                else
                    obj.ModeStateDataListener=[];
                end
            else



                obj.ModeManagerListener=matlab.graphics.controls.internal.ModeManagerListener(...
                ?matlab.uitools.internal.uimodemanager,'InstanceCreated',@(e,d)obj.handleModeManagerCreation(d.Instance,fig),fig);
            end
        end

        function result=hasFigureChanged(obj,fig)
            result=false;





            if~isempty(obj.ModeListener)
                result=~isequal(fig,obj.ModeListener.Figure);
            end
            if~result&&~isempty(obj.ModeManagerListener)&&isvalid(obj.ModeManagerListener)
                result=~isequal(obj.ModeManagerListener.Figure,fig);
            end
        end

        function resetListeners(obj)
            obj.ModeListener=[];
            obj.ModeManagerListener=[];
            obj.ModeStateDataListener=[];
        end
    end

    methods


        function setToolbarModeState(obj,~,~)

            fig=ancestor(obj.CurrentToolbar,'figure');

            if isempty(fig)
                return;
            end

            if isprop(fig,'ModeManager')
                modeManager=fig.ModeManager;
            else
                modeManager=[];
            end

            state=struct;
            state.Mode='';
            state.Direction='';

            if~isempty(modeManager)&&~isempty(modeManager.CurrentMode)

                state.Mode=modeManager.CurrentMode.Name;

                if isprop(modeManager.CurrentMode,'ModeStateData')&&...
                    isfield(modeManager.CurrentMode.ModeStateData,'Direction')
                    state.Direction=modeManager.CurrentMode.ModeStateData.Direction;
                end
            end



            if strcmp(state.Mode,'Exploration.Datacursor')&&...
                matlab.ui.internal.isUIFigure(fig)
                return;
            end

            if~isempty(obj.CurrentToolbar)

                allToggleButtons=findobj(obj.CurrentToolbar.getToolbarButtons(),...
                'flat','-isa','matlab.ui.controls.ToolbarStateButton');

                [~,defaultButtonTypes]=enumeration('matlab.graphics.controls.internal.ToolbarValidator');
                ImodeButtons=ismember(get(allToggleButtons,{'Tag'}),defaultButtonTypes);
                modeButtons=allToggleButtons(ImodeButtons);


                defaultToolbarButtonState=matlab.graphics.controls.ToolbarController.getButtonStateFromMode(state.Mode,state.Direction);

                for i=1:length(modeButtons)








                    if~isempty(defaultToolbarButtonState)
                        modeButtons(i).Value=strcmp(modeButtons(i).Tag,defaultToolbarButtonState);
                    else
                        modeButtons(i).Value=false;
                    end
                end


                if strcmp(state.Mode,'Standard.EditPlot')
                    obj.CurrentToolbar.Opacity=0;
                    btns=obj.CurrentToolbar.getToolbarButtons();

                    for i=1:numel(btns)
                        btns(i).togglePickable('visible');
                    end

                end
            end
        end

        function handleModeManagerCreation(obj,modeManagerInstance,fig)
            if isequal(modeManagerInstance.Figure,fig)
                delete(obj.ModeManagerListener);
                obj.ModeListener=matlab.graphics.controls.internal.ModeListener(fig.ModeManager,...
                fig.ModeManager.findprop('CurrentMode'),'PostSet',@(e,d)obj.handleModeChange(e,d),fig);
            end
        end
    end
end

