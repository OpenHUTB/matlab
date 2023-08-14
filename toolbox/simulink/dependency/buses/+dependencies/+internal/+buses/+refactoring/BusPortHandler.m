classdef BusPortHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types=i_getTypes();
        RenameOnly=true;
    end

    methods
        function refactor(~,dependency,newName)
            oldSignal=dependency.DownstreamComponent.Path;
            newSignal=split(oldSignal,".");
            newSignalName=string(split(newName,"."));
            newSignalName=newSignalName(end);

            newSignal(end)=newSignalName;
            newSignal=join(newSignal,".");

            component=dependency.UpstreamComponent.Path;
            oldParam=get_param(component,"Element");

            newParam=extractAfter(oldParam,oldSignal);
            newParam=newSignal+newParam;
            set_param(component,"Element",newParam);
        end
    end
end

function types=i_getTypes()
    import dependencies.internal.buses.util.BusTypes
    strTypes=[BusTypes.BusPortTypes.refElementType];
    types=cellstr(strTypes(:));
end
