




classdef BrowserDialogFactory

    methods(Static=true,Hidden=true,Access='public')
        function[aDebugAddress]=getDebugAddress(aBrowserType,aComponentId)
            switch(aBrowserType)
            case 'CEF'
                aDebugAddress=Simulink.messageviewer.internal.CEFBrowserDialog.getDebugAddress();
            case 'DOCK'
                aDebugAddress=Simulink.messageviewer.internal.DockedDialog.getDebugAddress(aComponentId);
            case 'SUPPRESSION_MANAGER_CEF'
                aDebugAddress=Simulink.messageviewer.internal.CEFBrowserDialogSuppressions.getDebugAddress();
            end
        end

        function[aBrowserDialog]=create(aBrowserType,aComponentId)
            aBrowserDialog=[];

            switch(aBrowserType)
            case 'CEF'
                aBrowserDialog=Simulink.messageviewer.internal.CEFBrowserDialog();
            case 'DOCK'
                aBrowserDialog=Simulink.messageviewer.internal.DockedDialog(aComponentId);
            case 'SUPPRESSION_MANAGER_CEF'
                aBrowserDialog=Simulink.messageviewer.internal.CEFBrowserDialogSuppressions();
            end
        end
    end

end


