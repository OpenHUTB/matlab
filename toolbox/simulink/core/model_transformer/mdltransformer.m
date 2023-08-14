function mdltransformer(system,varargin)



    if~license('test','SL_Verification_Validation')

        DAStudio.error('sl_pir_cpp:creator:MdlXformerLicenseFail');
    end

    if builtin('_license_checkout','SL_Verification_Validation','quiet')>0
        DAStudio.error('sl_pir_cpp:creator:MdlXformerLicenseCheckOutFail');
    end

    if nargin<1||nargin>2
        DAStudio.error('sl_pir_cpp:creator:MdlXformerUsage');
    end

    system=convertStringsToChars(system);

    if nargin==2
        varargin=convertStringsToChars(varargin);
    end

    if~((length(system)==1&&ishandle(system))||ischar(system))
        DAStudio.error('sl_pir_cpp:creator:MdlXformerIllegalArg');
    end

    C=textscan(system,'%s','Delimiter','/');
    inputModel=C{1}{1};

    if~bdIsLoaded(inputModel)
        open_system(inputModel);
    end

    mdltransformer_exe(system,varargin);
end

function charOut=convertStringsToChars(argIn)
    if isstring(argIn)
        charOut=argIn.char;
    else
        charOut=argIn;
    end
end
