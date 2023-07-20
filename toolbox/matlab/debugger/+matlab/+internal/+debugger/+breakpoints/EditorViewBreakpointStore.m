classdef EditorViewBreakpointStore


    properties
FileBreakpointMap
    end

    methods(Static)
        function obj=getInstance()
            mlock;
            persistent instance;
            if isempty(instance)
                instance=matlab.internal.debugger.breakpoints.EditorViewBreakpointStore();
            end
            obj=instance;
        end
    end

    methods
        function flag=hasBreakpointData(obj,filename)


            flag=obj.FileBreakpointMap.isKey(filename);
        end

        function data=getFileBreakpointData(obj,filename)

            data=[];
            if obj.FileBreakpointMap.isKey(filename)
                data=obj.FileBreakpointMap(filename);
            end
        end
    end

    methods(Access=private)
        function obj=EditorViewBreakpointStore()
            obj.FileBreakpointMap=containers.Map;
            obj.initListeners();
        end

        function initListeners(obj)
            connector.ensureServiceOn;
            message.subscribe('/debugger/breakpoints/editorbreakpointstore/setData',@obj.handleSetData);
        end

        function handleSetData(obj,data)
            filename=data.filename;
            if~isfield(data,'breakpointData')
                obj.removeBreakpointData(filename);
            else
                breakpointData=data.breakpointData;
                obj.addBreakpointData(filename,breakpointData);
            end
        end

        function addBreakpointData(obj,filename,breakpointData)
            obj.FileBreakpointMap(filename)=breakpointData;
        end

        function removeBreakpointData(obj,filename)
            if obj.hasBreakpointData(filename)
                obj.FileBreakpointMap.remove(filename);
            end
        end
    end
end
