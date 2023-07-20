classdef(Sealed)FaultLibrariesList<handle
    properties(Access=private)
        customFaultLibraries={}
    end

    methods(Access=private)
        function obj=FaultLibrariesList
        end
    end

    methods(Static)
        function singleObj=getInstance
            persistent localObj
            if isempty(localObj)||~isvalid(localObj)
                localObj=FaultLibrariesList;
            end
            singleObj=localObj;
        end
    end

    methods
        function faultLibraries=getCustomFaultLibrariesList(obj)
            faultLibraries=obj.customFaultLibraries;
        end

        function addToCustomFaultLibrariesList(obj,newLibrary)
            if isempty(obj.customFaultLibraries)
                obj.customFaultLibraries={newLibrary};
            else
                obj.customFaultLibraries=[obj.customFaultLibraries,{newLibrary}];
            end
        end

        function val=clearCustomFaultLibrariesList(obj)
            obj.customFaultLibraries={};
            val=true;
        end

    end
end
