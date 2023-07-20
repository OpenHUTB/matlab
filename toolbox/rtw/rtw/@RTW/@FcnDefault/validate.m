function[status,msg]=validate(hSrc,hDlg,modelName,fromBuild,callMode)




    if nargin>2
        modelName=convertStringsToChars(modelName);
    end

    if nargin>4
        callMode=convertStringsToChars(callMode);
    end

    status=1;
    msg='';

    hModel=hSrc.ModelHandle;

    if isempty(hModel)||hModel==0
        hModel=modelName;
    end

    if hSrc.RightClickBuild
        hModel=bdroot(hSrc.SubsysBlockHdl);


        modelToCompile=hSrc.ModelHandle;
    else

        modelToCompile=hModel;
    end


    cs=getActiveConfigSet(hModel);
    commitBuild=slprivate('checkSimPrm',cs);
    if(~commitBuild)
        msg=DAStudio.message('RTW:fcnClass:validationCanceled');
        status=0;
        return;
    end

    cs=getActiveConfigSet(hModel);
    fullname=getfullname(modelToCompile);

    if strcmp(get_param(cs,'CombineOutputUpdateFcns'),'off')
        msg=DAStudio.message('RTW:fcnClass:combineOutputUpdate',fullname);
    elseif strcmp(get_param(cs,'MultiInstanceERTCode'),'on')
        msg=DAStudio.message('RTW:fcnClass:reusableCode',fullname);
    elseif strcmp(get_param(cs,'SolverType'),'Variable-step')&&...
        ~(hSrc.RightClickBuild)
        msg=DAStudio.message('RTW:fcnClass:variableStepType',fullname);
    end

    if~isempty(msg)
        status=0;
        return;
    end

    compileObj=coder.internal.CompileModel;


    try
        if strcmpi(get_param(hModel,'SimulationMode'),'accelerator')
            DAStudio.error('RTW:fcnClass:accelSimForbiddenForFPC')
        end
        lastWarnSaved=lastwarn;
        lastwarn('');

        compileObj.compile(hModel);

        if~isempty(lastwarn)
            disp([DAStudio.message('RTW:fcnClass:fcnProtoCtlWarn'),lastwarn]);
        end
        lastwarn(lastWarnSaved);
    catch me
        msg=DAStudio.message('RTW:fcnClass:modelNotCompile',me.message);
        status=0;

        return;
    end

    if(strcmpi(callMode,'interactive')||strcmpi(callMode,'finalValidation'))

        sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.embeddedCoder);
        uddobj=get_param(modelToCompile,'UDDObject');
        singleRate=uddobj.outputFcnHasSinglePeriodicRate();
        delete(sess);
        if~singleRate&&~strcmp(get_param(cs,'SolverMode'),'SingleTasking')
            msg=DAStudio.message('RTW:fcnClass:singleTasking',fullname);
        end
        if strcmp(get_param(cs,'ConcurrentTasks'),'on')
            msg=DAStudio.message('RTW:fcnClass:noConcurrentTasks',fullname);
        end
    end

    hSrc.Multirate=~singleRate;
