classdef SignalNameHandler<dependencies.internal.action.DependencyHandler




    properties(Constant)
        Types=dependencies.internal.buses.analysis.SignalNameAnalyzer.Type;
    end

    methods
        function unhilite=openUpstream(~,dependency)
            component=dependency.UpstreamComponent;
            portHandle=i_getPortHandle(component);
            hilite_system(portHandle,'find');
            unhilite=@()hilite_system(portHandle,'none');
        end
    end
end

function portHandle=i_getPortHandle(component)
    component=component.Path;
    colonIdx=strfind(component,":");
    colonIdx=colonIdx(end);
    portNumber=str2double(extractAfter(component,colonIdx));
    component=extractBefore(component,colonIdx);
    portHandles=get_param(component,"PortHandles");
    portHandle=portHandles.Outport(portNumber);
end
