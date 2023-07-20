classdef Source<Simulink.typeeditor.app.Source





    methods(Hidden)
        function editor=getEditor(this)

            editor=sl.interface.dictionaryApp.StudioApp.findStudioAppForDict(...
            this.NodeConnection.filespec);
        end
    end

    methods(Access=public)
        function useSourceSLDDListener=useSourceSLDDListener(~)


            useSourceSLDDListener=false;
        end
    end

    methods(Access=protected)

        function shouldSkip=skipGUIUpdateOnRefresh(~)


            shouldSkip=true;
        end

        function shouldPublish=shouldPublishStatusMsgOnStudioAppWindow(~)



            shouldPublish=false;
        end
    end
end


