function outframes=whdlSamplesToFrames(varargin)



































































%#codegen

    if coder.target('MATLAB')
        if~(builtin('license','checkout','LTE_HDL_Toolbox'))
            error(message('whdl:whdl:NoLicenseAvailable'));
        end
    else
        coder.license('checkout','LTE_HDL_Toolbox');
    end
    outframes=commhdlSamplesToMultipleFrames(varargin{:});

end
