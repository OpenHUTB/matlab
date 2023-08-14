function[harnessH,portInfo,error_occ,extractSubsysExc]=extractSubsystem(subsys,varargin)




    [harnessH,portInfo,error_occ,extractSubsysExc]=Simulink.harness.internal.extract(subsys,false,varargin{:});

end

