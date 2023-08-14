classdef DebugFileTranslator<handle

    properties(Constant)
        UPDATE_CHANNEL="/debugger/file_translation/update";
        REQUEST_CHANNEL="/debugger/file_translation/request";
    end

    properties
        translatedFiles=containers.Map
breakpointStore
    end

    methods(Static)
        function obj=getInstance()
            mlock;
            persistent instance;
            if isempty(instance)
                instance=matlab.internal.debugger.DebugFileTranslator();
                instance.registerListener();
                instance.setupBreakpointStoreProperties();
            end
            obj=instance;
        end
    end

    methods
        function registerListener(obj)
            message.subscribe(obj.REQUEST_CHANNEL,@(evt)obj.publish);
        end

        function publish(obj)
            payload=obj.buildPublishData();
            message.publish(obj.UPDATE_CHANNEL,payload);
        end

        function data=buildPublishData(obj)





            fromFiles=obj.translatedFiles.keys;
            toFiles=obj.translatedFiles.values;

            if(isempty(fromFiles))
                fromFiles=[];
                toFiles=[];
            end
            data=struct('fromFile',fromFiles,'toFile',toFiles);
        end

        function beginForwarding(obj,fromFile,toFile)





            if~contains(toFile,'.')
                toFile=[toFile,'.m'];
            end



            obj.transferBreakpoints(fromFile,toFile);
            obj.translatedFiles(fromFile)=toFile;
            obj.publish();
        end

        function endForwarding(obj,fromFile,~)

            if isfile(fromFile)

                dbclear('-completenames',fromFile);
            end
            obj.translatedFiles.remove(fromFile);
            obj.publish();
        end
    end

    methods(Access=private)
        function setupBreakpointStoreProperties(obj)
            obj.breakpointStore=matlab.internal.debugger.breakpoints.EditorViewBreakpointStore.getInstance();
        end

        function transferBreakpoints(obj,fromFile,toFile)
            breakpointInfos=obj.getBreakpointsForFile(toFile);
            for i=1:length(breakpointInfos)
                info=breakpointInfos(i);
                info.fileName=fromFile;
                breakpoint=matlab.internal.debugger.breakpoints.createSourceBreakpoint(...
                fromFile,info.lineNumber,info.expression,info.anonymousIndex,info.columnNumber,info.isEnabled);

                try %#ok<TRYNC>
                    matlab.internal.debugger.breakpoints.setBreakpoint(breakpoint);
                end
            end
        end

        function breakpoints=getBreakpointsForFile(obj,filename)
            if obj.isUsingBreakpointStore(filename)
                breakpoints=matlab.internal.debugger.breakpoints.getEditorViewBreakpoints(filename);
            else
                breakpoints=matlab.internal.debugger.breakpoints.getSourceBreakpointsForFile(filename);
            end
        end

        function flag=isUsingBreakpointStore(obj,filename)
            flag=obj.breakpointStore.hasBreakpointData(filename);
        end
    end
end