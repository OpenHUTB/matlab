function varargout=power_PMSynchronousMachineParams(varargin)



















    if nargin==0&&nargout==0

        if~pmsl_checklicense('Power_System_Blocks')
            error(message('physmod:pm_sli:sl:InvalidLicense',pmsl_getproductname('Power_System_Blocks'),'power_PMSynchronousMachineParams'));
        else
            powerPMSMparameterEstimator;
        end
        return
    end

    if nargout==0
        power_PMSynchronousMachineParams_pr(varargin{:});
    else
        [varargout{1:nargout}]=power_PMSynchronousMachineParams_pr(varargin{:});
    end