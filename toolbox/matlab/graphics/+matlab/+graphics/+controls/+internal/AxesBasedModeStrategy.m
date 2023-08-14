classdef AxesBasedModeStrategy<matlab.graphics.controls.internal.AbstractModeStrategy




    properties(Access=private)
noopInteraction
    end

    methods

        function setToolbarModeState(obj,ax,evd)
            obj.handleModeChange(ax,evd);
        end

        function handleModeChange(~,ax,~)
            fig=ancestor(ax,'figure');
            if~isempty(fig)&&isvalid(fig)&&(~isprop(fig,'UseLegacyExplorationModes')||~fig.UseLegacyExplorationModes)

                newMode=ax.InteractionContainer.CurrentMode;

                if~isempty(ax.Toolbar)&&isvalid(ax.Toolbar)
                    allBtns=ax.Toolbar.getToolbarButtons();

                    if strcmp(newMode,'zoom')
                        newMode='zoomin';
                    end




                    for i=1:numel(allBtns)

                        element=allBtns(i);

                        [~,buttonTypesEnum]=enumeration('matlab.graphics.controls.internal.ToolbarValidator');


                        if isa(element,'matlab.ui.controls.ToolbarStateButton')&&...
                            ismember(element.Tag,buttonTypesEnum)
                            if strcmp(newMode,element.Tag)
                                element.Value='on';
                            else
                                element.Value='off';
                            end
                        end
                    end
                end
            end


        end

        function createListeners(obj,canvas,ax)
            if isprop(ax,'InteractionContainer')

                if~isprop(ax,'ModeListener')
                    p=addprop(ax,'ModeListener');
                    p.Hidden=true;
                    p.Transient=true;
                    addlistener(ax.InteractionContainer,'CurrentMode','PostSet',...
                    @(e,d)obj.handleModeChange(ax));
                    ax.ModeListener='on';


                    obj.handleModeChange(ax);
                end
            end
        end

        function result=hasFigureChanged(~,~)


            result=false;
        end

        function resetListeners(~)


        end
    end
end

