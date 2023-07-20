function clonedetection(system,varargin)







    if nargin>0
        system=convertStringsToChars(system);
    end

    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if~license('test','SL_Verification_Validation')
        DAStudio.error('sl_pir_cpp:creator:CloneDetectionLicenseFail');
    end

    if builtin('_license_checkout','SL_Verification_Validation','quiet')>0
        DAStudio.error('sl_pir_cpp:creator:CloneDetectionLicenseCheckOutFail');
    end

    if nargin<1||nargin>2
        DAStudio.error('sl_pir_cpp:creator:CloneDetectionUsage');
    end

    if~((length(system)==1&&ishandle(system))||ischar(system))
        DAStudio.error('sl_pir_cpp:creator:CloneDetectionIllegalArg');
    end

    C=textscan(system,'%s','Delimiter','/');
    inputModel=C{1}{1};

    if~bdIsLoaded(inputModel)
        open_system(inputModel);
    end
    clone_detection_app.internal.launchCloneDetectorApp(get_param(system,'Name'));

end
