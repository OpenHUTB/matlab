function plot(~,varargin)




    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    fw.launchSDI(Simulink.sdi.GUITabType.InspectSignals);
end
