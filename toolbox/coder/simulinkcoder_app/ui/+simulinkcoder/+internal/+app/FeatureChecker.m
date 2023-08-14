
classdef FeatureChecker<handle
    methods(Static=true)
        function out=isFunctionPrototypeControlFeatureOn
            out=simulinkcoder.internal.app.FeatureChecker.isLicenseReady;
        end
    end
    methods(Hidden,Static=true)
        function out=isLicenseReady
            licenses={'Matlab_Coder','Real-Time_Workshop','RTW_Embedded_Coder'};
            out=true;
            for i=1:length(licenses)
                out=out&&license('test',licenses{i});
            end
            out=out&&...
            dig.isProductInstalled('Embedded Coder');
        end
        function out=isUsageFeatureOn(arg)
            persistent usageFeatureValue
            if isempty(usageFeatureValue)
                usageFeatureValue=false;
            end
            if nargin==1
                usageFeatureValue=arg;
            end
            out=usageFeatureValue;
        end
    end
end



