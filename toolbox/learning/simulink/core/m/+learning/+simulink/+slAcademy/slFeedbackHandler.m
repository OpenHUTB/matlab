classdef slFeedbackHandler<handle



    methods(Static)

        function createDocked(editor,block,type,varargin)

            if~isempty(block)
                hdl=get_param(block,'Handle');
                pos=get_param(block,'Position');
            else
                hdl='';
                pos=[0,0];
            end
            if isempty(varargin)
                p=learning.simulink.slAcademy.EditorTab(bdroot(editor.getName),hdl,pos,type);
            else
                p=learning.simulink.slAcademy.EditorTab(bdroot(editor.getName),hdl,pos,type,varargin{:});
            end
            dlg=DAStudio.Dialog(p);
            p.show(dlg,editor.getStudio);
        end

        function closeDocked(studio)

            signalCheck=studio.getComponent('GLUE2:DDG Component',learning.simulink.StudioMgr.ASSESS_PANE_ID);
            if~isempty(signalCheck)
                studio.destroyComponent(signalCheck);
            end
        end

    end

end
