function autoblksparamerrorcheck(varargin)



    switch varargin{1}
    case 'isValidFilepath'
        filenamewithpath=varargin{2};

        if strcmp(filenamewithpath,'')
            errId=message("autoblks_shared:autoerrpmsm:noValidFileName");
            error(errId.getString);
        end

    case 'isFileNameAvbl'
        fileName=varargin{2};
        if strcmp(fileName,'')
            errId=message("autoblks_shared:autoerrpmsm:noValidFileName");
            error(errId.getString);
        end

    case 'isFileExists'
        filenamewithpath=varargin{2};
        if~isfile(filenamewithpath)
            errId=message("autoblks_shared:autoerrpmsm:noValidFileExist");
            error(errId.getString);
        end

    case 'isValidFileExtn'
        fileExtn=varargin{2};

        if~(strcmp(fileExtn,'.m')||strcmp(fileExtn,'.mat')||strcmp(fileExtn,'.xlsx'))
            errId=message("autoblks_shared:autoerrpmsm:noValidFileExtn");
            error(errId.getString);
        end

    case 'isValidMotorType'
        fileMotorType=varargin{2};
        if strcmp(fileMotorType,'"Interior PMSM"')
            errId=message("autoblks_shared:autoerrpmsm:motorTypeMismatch");
            error(errId.getString);
        end

    case 'isValidStruct'
        fileName=varargin{2};
        structName=varargin{3};
        load(fileName);
        if~exist(structName,'var')
            errId=message("autoblks_shared:autoerrpmsm:motorStructMismatch");
            error(errId.getString);
        end

    case 'inValidStructParam'
        errId=message("autoblks_shared:autoerrpmsm:motorInvalidStructParam");
        error(errId.getString);

    case 'isSimRunning'
        mdlName=varargin{2};
        SimStatus=get_param(mdlName,'SimulationStatus');
        if(strcmp(SimStatus,'running')||...
            strcmp(SimStatus,'paused'))
            errId=message("autoblks_shared:autoerrpmsm:motorInvalidLoadState");
            error(errId.getString);
        end

    end