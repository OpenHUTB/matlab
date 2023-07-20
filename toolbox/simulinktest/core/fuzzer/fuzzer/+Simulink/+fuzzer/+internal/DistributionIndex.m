classdef DistributionIndex
    
    properties
        val = 0;
        valStr = '';
    end
    
    methods
      function t = DistributionIndex(v)
         t.val = v;
         t.valStr = num2str(v);
      end     
    end
    
    enumeration
        CAUCHY_DISTRO (0)
        CHISQUARED_DISTRO (1)
        FISHERF_DISTRO (2)
        GAUSSIAN_DISTRO (3)
        LOGNORM_DISTRO (4)
        STUDENTT_DISTRO (5)
        UNIFORM_DISTRO (6)
    end
end