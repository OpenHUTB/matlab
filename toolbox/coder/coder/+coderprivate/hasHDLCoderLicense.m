function b=hasHDLCoderLicense(checkout,featureEnabled)%#ok<INUSL>





    if nargin<2
        featureEnabled=false;
    end

    if~(builtin('license','checkout','MATLAB_Coder')&&builtin('license','checkout','Simulink_HDL_Coder'))
        error(message('Coder:common:NoHDLCoderTargetEnabled'));
    end

    b=isMLHDLCInstalled(featureEnabled);

    if~b
        error(message('Coder:common:NoHDLCoderTargetEnabled'));
    end

end


function b=isMLHDLCInstalled(featureEnabled)

    persistent mlhdlcinstalled;
    if isempty(mlhdlcinstalled)

        issupportedOS=getSupportedOS4SLHDLC;
        codegen_available=exist('codegen','file')~=0;
        pir_available=exist('pir_udd','file')==3;
        license_available=builtin('license','test','MATLAB_Coder');

        mlhdlcinstalled=featureEnabled...
        &&license_available...
        &&issupportedOS...
        &&pir_available...
        &&codegen_available;

    end

    b=mlhdlcinstalled;

end


function issupportedOS=getSupportedOS4SLHDLC

    supportedOSList={'PCWIN','PCWIN64','GLNXA64','MACA64','MACI64'};
    issupportedOS=any(strcmp(computer,supportedOSList));

end
