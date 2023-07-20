classdef DiagnosticViewer




    methods(Static,Access=public)

        function report(mException,reportType,stageName,mdlName)



            mdlName=get_param(mdlName,'Name');
            sldiagviewer.createStage(stageName,'ModelName',mdlName);

            switch reportType
            case 'error'
                sldiagviewer.reportError(mException);
            case 'warning'
                sldiagviewer.reportWarning(mException);
            case 'info'
                sldiagviewer.reportInfo(mException);
            otherwise
                assert(false,'Did not expect to get here');
            end

            aSLMsgViewer=slmsgviewer.Instance(mdlName);
            if~isempty(aSLMsgViewer)
                aSLMsgViewer.show();
                slmsgviewer.selectTab(mdlName);
            end
        end

    end
end
