classdef AppConfigType








    enumeration
        InitialState("InitialState","InitialState",true)
        ExternalInput("ExternalInput","ExternalInput",true)
        ModelParameter("ModelParameter","ModelParameters",true)
        ReferenceWorkspaceVariable("ReferenceWorkspaceVariable","Variables",true)
        LoggedSignal("LoggedSignal","",false)
    end

    properties
Name
SimInputName
HasSet
        Set=""
        Sets=""
    end

    methods
        function obj=AppConfigType(name,simInName,hasSet)
            obj.Name=name;
            obj.SimInputName=simInName;
            obj.HasSet=hasSet;

            if hasSet
                obj.Set=name+"Set";
                obj.Sets=obj.Set+"s";
            end
        end
    end

    methods(Static)
        function names=names()
            object=simulink.compiler.internal.AppConfigType.InitialState;
            names=[enumeration(object).Name];
        end

        function names=setNames()
            object=simulink.compiler.internal.AppConfigType.InitialState;
            names=[enumeration(object).Set];
            names=names(~arrayfun(@isempty,names));
        end

        function names=setsNames()
            object=simulink.compiler.internal.AppConfigType.InitialState;
            names=[enumeration(object).Sets];
            names=names(~arrayfun(@isempty,names));
        end
    end
end
