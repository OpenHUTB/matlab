









































function out=inspect(aObj,varargin)

    if(~builtin('license','checkout','Simulink_Code_Inspector'))
        DAStudio.error('Slci:slci:ERROR_LICENSE');
    end


    if nargin==3

        p=inputParser();
        paramName='UtilsFile';
        default='';
        validationFcn=@(x)assert(ischar(x)||iscellstr(x)||isstring(x));
        p.addParameter(paramName,default,validationFcn);
        p.parse(varargin{1:end});

        res=p.Results;
        aObj.setTargetUtilsFile(res.UtilsFile);
        aObj.setBaselineUtilsFile(res.UtilsFile);
    elseif nargin>=5

        p=inputParser();
        paramName='BaselineUtilsFile';
        default='';
        validationFcn=@(x)assert(ischar(x)||iscellstr(x)||isstring(x));
        p.addParameter(paramName,default,validationFcn);

        paramName='TargetUtilsFile';
        p.addParameter(paramName,default,validationFcn);

        p.parse(varargin{1:end});

        res=p.Results;
        aObj.setTargetUtilsFile(res.TargetUtilsFile);
        aObj.setBaselineUtilsFile(res.BaselineUtilsFile);
    end

    if isempty(aObj.getTargetUtilsFile)||isempty(aObj.getBaselineUtilsFile)
        out=-4;
        aObj.setVerificationResult(out)
        return;
    end


    tfname=fullfile(aObj.getTargetUtilsFolder,...
    [aObj.getTargetUtilsFile,aObj.getTargetLangSuffix]);

    if~exist(tfname,'file')
        out=-3;
        aObj.setVerificationResult(out)
        return;
    end

    bfname=fullfile(aObj.getBaselineUtilsFolder,...
    [aObj.getBaselineUtilsFile,aObj.getTargetLangSuffix]);

    if~exist(bfname,'file')
        out=-3;
        aObj.setVerificationResult(out)
        return;
    end

    aObj.setEDGOptions();


    pCallInspect=slci.internal.Profiler('SLCI','UtilsInspect',...
    '','');

    slciLibName=slci.internal.getSLCILibName();


    inBat=exist('qeinbat','file')&&qeinbat;
    if~inBat&&~slci.internal.isCompilerInstalled()
        DAStudio.error('Slci:slci:ERROR_COMPILER')
    end

    slci.internal.loadSlciLibrary(slciLibName);

    try



        out=calllib(slciLibName,'slciCUtilsMain',aObj);
    catch ME
        aObj.HandleException(ME);
        out=-1;
    end


    aObj.setVerificationResult(out)


    slci.internal.unloadSlciLibrary(slciLibName);


    pCallInspect.stop();

end

