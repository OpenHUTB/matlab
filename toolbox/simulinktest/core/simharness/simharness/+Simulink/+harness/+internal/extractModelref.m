function[harnessH,portInfo,error_occ,extractSubsysExc]=extractModelref(mdlref,varargin)




    [harnessH,portInfo,error_occ,extractSubsysExc]=Simulink.harness.internal.extract(mdlref,true,varargin{:});

end

