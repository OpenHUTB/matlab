classdef DebugUtilities<handle



    properties
        isEnabled=true;
        pruningEnabled=false;
    end

    properties(Constant)
        PathToPrune=string(fileparts(which('matlab.internal.editor.evaluateRegions')));
    end

    methods
        function enableStackPruning(debugUtilities)
            debugOverride=usejava('jvm')&&com.mathworks.mlservices.MatlabDebugServices.isMWDebugOverride();
            if~debugUtilities.pruningEnabled&&~debugOverride
                matlab.internal.lang.maskFoldersFromStack([debugUtilities.PathToPrune]);
                debugUtilities.pruningEnabled=true;
            elseif debugUtilities.pruningEnabled&&debugOverride
                matlab.internal.lang.unmaskFoldersFromStack([debugUtilities.PathToPrune]);
                debugUtilities.pruningEnabled=false;
            end
        end
    end

    methods(Static)

        function obj=getInstance()
            import matlab.internal.editor.debug.DebugUtilities;
            mlock;
            persistent instance;
            if isempty(instance)
                instance=DebugUtilities();
            end
            obj=instance;
        end

        function cleanupObj=disableBreakpoints()
            import matlab.internal.editor.debug.DebugUtilities;
            debugUtilities=DebugUtilities.getInstance();
            debugUtilities.isEnabled=false;
            cleanupObj=onCleanup(@()resetBreakpointState(debugUtilities));

            function resetBreakpointState(debugUtilities)
                debugUtilities.isEnabled=true;
            end
        end

        function cleanupObj=enableDebuggingSupport(fileThatWillRun,fileToForwardTo)
            import matlab.internal.editor.debug.DebugUtilities

            cleanupObj=[];


            debugUtilities=DebugUtilities.getInstance();
            if~debugUtilities.isEnabled
                cleanupObj=[];
                return;
            end

            if usejava('jvm')




                cleanupObj.javaTranslator=debugUtilities.enableJavaTranslation(fileThatWillRun,fileToForwardTo);
            end

            debugFileTranslator=matlab.internal.debugger.DebugFileTranslator.getInstance();
            debugFileTranslator.beginForwarding(fileThatWillRun,fileToForwardTo);

            debugUtilities.enableStackPruning();

            originalValue=feature('DisableDebugPrinting',true);

            cleanupObj.mTranslatorDispose=onCleanup(@()debugFileTranslator.endForwarding(fileThatWillRun,fileToForwardTo));
            cleanupObj.debugEval=onCleanup(@()feature('DisableDebugPrinting',originalValue));
        end
    end

    methods(Access='private')

        function cleanupObj=enableJavaTranslation(~,fileThatWillRun,fileToForwardTo)
            fileThatWillRun=java.io.File(fileThatWillRun);
            fileToForwardTo=java.io.File(fileToForwardTo);

            debugEventTranslator=com.mathworks.mde.liveeditor.debug.LiveEditorDebugEventTranslator;
            debugEventTranslator.beginForwarding(fileThatWillRun,fileToForwardTo);
            com.mathworks.mlservices.MatlabDebugServices.setEventTranslator(debugEventTranslator);

            cleanupObj=[];
            cleanupObj.translator=onCleanup(@()com.mathworks.mlservices.MatlabDebugServices.clearEventTranslator());
            cleanupObj.translatorEndForwarding=onCleanup(@()debugEventTranslator.endForwarding(fileThatWillRun,fileToForwardTo));
        end
    end
end