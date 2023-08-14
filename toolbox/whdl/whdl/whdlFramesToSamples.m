function[samples,ctrl,len]=whdlFramesToSamples(varargin)































































%#codegen

    if coder.target('MATLAB')
        if~(builtin('license','checkout','LTE_HDL_Toolbox'))
            error(message('whdl:whdl:NoLicenseAvailable'));
        end
    else
        coder.license('checkout','LTE_HDL_Toolbox');
    end

    [samples,ctrl,len]=commhdlMultipleFramesToSamples(varargin{:});

end
