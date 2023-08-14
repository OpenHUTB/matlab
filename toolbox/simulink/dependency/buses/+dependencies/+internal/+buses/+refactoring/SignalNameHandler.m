classdef SignalNameHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types=cellstr(dependencies.internal.buses.analysis.SignalNameAnalyzer.Type);
        RenameOnly=true;
    end

    methods

        function refactor(~,dependency,newName)
            newSignalName=string(split(newName,"."));
            newSignalName=newSignalName(end);

            component=dependency.UpstreamComponent.Path;
            colonIdx=strfind(component,":");
            colonIdx=colonIdx(end);

            portNumber=str2double(extractAfter(component,colonIdx));
            component=extractBefore(component,colonIdx);
            portHandles=get_param(component,"PortHandles");
            portHandle=portHandles.Outport(portNumber);

            set(portHandle,'SignalNameFromLabel',newSignalName);
        end

    end

end
