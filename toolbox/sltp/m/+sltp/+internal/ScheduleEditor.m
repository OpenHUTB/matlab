



classdef(Hidden=true)ScheduleEditor<sltp.internal.ScheduleEditorInterface
    methods

        function obj=ScheduleEditor(modelHandle)
            obj=obj@sltp.internal.ScheduleEditorInterface(modelHandle);

            dlg=matlab.internal.webwindow(connector.getUrl(obj.URL));
            gr=groot;
            dlg.Position=obj.getDefaultPosition(gr.ScreenSize);
            dlg.setMinSize([400,400]);
            dlg.CustomWindowClosingCallback=@(d,~)hideWindowAndClearModelHighlighting(d,modelHandle);

            if ispc

                dlg.Icon=fullfile(matlabroot,'toolbox','sltp','m','resources','SchedulingEditor_16.ico');
            else




                iconFile=fullfile(matlabroot,'toolbox','shared','dastudio','resources','glue','Toolbars','16px','SchedulingEditor_16.png');
                dlg.Icon=iconFile;
            end
            obj.Dialog=dlg;
        end


        function visible=isVisible(obj)
            visible=obj.Dialog.isWindowValid&&obj.Dialog.isVisible;
        end


        function hide(obj)
            obj.Dialog.hide;
        end

        function show(obj)
            if strcmpi(get_param(obj.modelHandle,'ExplicitPartitioning'),'on')&&...
                strcmpi(get_param(obj.modelHandle,'ConcurrentTasks'),'on')
                throw(MSLException([],message(...
                'SimulinkPartitioning:General:InvalidPartitionExplicitPartitioningModel',...
                get_param(obj.modelHandle,'Name'))));
            end

            obj.Dialog.show;
            obj.Dialog.bringToFront;
        end


        function delete(obj)
            if obj.isVisible
                obj.Dialog.close;
            end

            delete(obj.Dialog);
        end
    end
end

function hideWindowAndClearModelHighlighting(dialog,modelHandle)
    dialog.hide();


    if ishandle(modelHandle)
        ge=sltp.GraphEditor(modelHandle);
        ge.hide();
    end
end


