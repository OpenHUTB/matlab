function location=installer(varargin)










    narginchk(0,0);


    location=compiler.internal.runtime.utils.getExistingMCRInstallerWithValidation;
    if isempty(location)
        disp(getString(message('Compiler:runtime:downloadCommand')));
    end
