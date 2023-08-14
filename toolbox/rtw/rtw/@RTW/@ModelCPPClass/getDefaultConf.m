function getDefaultConf(hSrc)













    hModel=hSrc.ModelHandle;

    if~ishandle(hModel)
        DAStudio.error('RTW:fcnClass:invalidMdlHdl');
    else
        try
            obj=get_param(hModel,'object');
            if~obj.isa('Simulink.BlockDiagram')
                DAStudio.error('RTW:fcnClass:invalidMdlHdl');
            end
        catch theMe
            DAStudio.error('RTW:fcnClass:invalidMdlHdl');
        end
    end

    simStatus=get_param(hModel,'SimulationStatus');

    fullname=getfullname(hModel);

    compileObj=coder.internal.CompileModel;

    if hSrc.needsCompilation()&&...
        ~strcmpi(simStatus,'paused')&&~strcmpi(simStatus,'initializing')&&...
        ~strcmpi(simStatus,'running')
        try
            if strcmpi(get_param(hModel,'SimulationMode'),'accelerator')
                DAStudio.error('RTW:fcnClass:accelSimForbiddenForCPP')
            end
            lastWarnSaved=lastwarn;
            lastwarn('');

            compileObj.compile(hModel);

            if~isempty(lastwarn)
                disp([DAStudio.message('RTW:fcnClass:fcnProtoCtlWarn'),lastwarn]);
            end
            lastwarn(lastWarnSaved);
        catch me
            DAStudio.error('RTW:fcnClass:modelNotCompile',me.message);
        end
    end

    hSrc.setDefaultStepMethodName();
    hSrc.setDefaultClassName();
    hSrc.setDefaultNamespace();

    [inpH,outpH]=hSrc.getPortHandles(hModel);

    hSrc.Data=[];
    posInArgs=1;

    for i=1:length(inpH)
        portType=get_param(inpH(i),'BlockType');
        if strcmpi(portType,'Inport')
            portNumStr=get_param(inpH(i),'Port');
            portNum=str2double(portNumStr)-1;

        else
            assert(hSrc.isControlPort(inpH(i)));
            portNum=i-1;
        end
        argSpec=hSrc.getPortDefaultConf(inpH(i),portNum,posInArgs);
        posInArgs=posInArgs+1;
        hSrc.Data=[hSrc.Data;argSpec];
    end

    for i=1:length(outpH)
        portNumStr=get_param(outpH(i),'Port');
        portNum=str2double(portNumStr)-1;

        argSpec=hSrc.getPortDefaultConf(outpH(i),portNum,posInArgs);
        posInArgs=posInArgs+1;
        hSrc.Data=[hSrc.Data;argSpec];
    end

