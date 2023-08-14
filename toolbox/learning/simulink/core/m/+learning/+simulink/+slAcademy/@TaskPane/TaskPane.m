classdef TaskPane<handle



    properties(Access=public,Constant)
        TASK_PANE_DOCKED_TAG='taskEmbedded';
    end

    methods(Access=public)
        function this=TaskPane()
        end

        function show(this,studio)

            signalCheckComponent=studio.getComponent('GLUE2:DDG Component',learning.simulink.StudioMgr.TASK_PANE_ID);
            if~isempty(signalCheckComponent)
                studio.destroyComponent(signalCheckComponent);
            end
            comp=GLUE2.DDGComponent(studio,learning.simulink.StudioMgr.TASK_PANE_ID,this);
            studio.registerComponent(comp);
            comp.UserClosable=false;
            taskPaneWidth=learning.simulink.Application.getInstance().getTaskPaneWidth();
            if isempty(taskPaneWidth)
                width=380;
            else
                width=taskPaneWidth;
            end
            studioPosition=studio.getStudioPosition();
            height=studioPosition(4)/2;
            comp.setPreferredSize(width,height);
            studio.moveComponentToDock(comp,...
            message('learning:simulink:resources:TaskPaneTitle').getString(),'left','tabbed');
        end

    end

end
