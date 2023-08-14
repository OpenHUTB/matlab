classdef DistributionTypes
    
    properties
        name = '';
        val = 0;
    end
    
    methods
      function t = DistributionTypes(n, v)
         t.name = n;
         t.val = v;
      end     
    end

    enumeration
        CAUCHY       (DAStudio.message('sltest:fuzzer:DistroCauchy'), Simulink.fuzzer.internal.DistributionIndex.CAUCHY_DISTRO.val)
        CHISQUARED   (DAStudio.message('sltest:fuzzer:DistroChiSquared'), Simulink.fuzzer.internal.DistributionIndex.CHISQUARED_DISTRO.val)
        FISHERF      (DAStudio.message('sltest:fuzzer:DistroFisherF'), Simulink.fuzzer.internal.DistributionIndex.FISHERF_DISTRO.val)
        GAUSSIAN     (DAStudio.message('sltest:fuzzer:DistroGaussian'), Simulink.fuzzer.internal.DistributionIndex.GAUSSIAN_DISTRO.val)
        LOGNORM      (DAStudio.message('sltest:fuzzer:DistroLogNormal'), Simulink.fuzzer.internal.DistributionIndex.LOGNORM_DISTRO.val)
        STUDENTT     (DAStudio.message('sltest:fuzzer:DistroStudentT'), Simulink.fuzzer.internal.DistributionIndex.STUDENTT_DISTRO.val)
        UNIFORM      (DAStudio.message('sltest:fuzzer:DistroUniform'), Simulink.fuzzer.internal.DistributionIndex.UNIFORM_DISTRO.val)
   end
end

