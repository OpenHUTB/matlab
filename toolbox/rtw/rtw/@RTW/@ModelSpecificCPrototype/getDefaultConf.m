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
        catch ex
            DAStudio.error('RTW:fcnClass:invalidMdlHdl');
        end
    end

    fullname=getfullname(hModel);


    if isempty(hSrc.FunctionName)
        hSrc.FunctionName=sprintf('%s_custom',fullname);
    end
    if isempty(hSrc.InitFunctionName)
        hSrc.InitFunctionName=sprintf('%s_initialize',fullname);
    end

    [inpH,outpH]=hSrc.getPortHandles(hModel);

    portH=[inpH;outpH];

    inpNames=get_param(inpH,'Name');
    if ischar(inpNames)
        inpNames={inpNames};
    end
    outpNames=get_param(outpH,'Name');
    if ischar(outpNames)
        outpNames={outpNames};
    end
    portNames=[inpNames;outpNames];

    if isempty(portH)
        hSrc.Data=[];
        return;
    end


    if ischar(portNames)
        portNames={portNames};
    end

    simStatus=get_param(hModel,'SimulationStatus');

    compileObj=coder.internal.CompileModel;

    if~strcmpi(simStatus,'paused')&&~strcmpi(simStatus,'initializing')&&...
        ~strcmpi(simStatus,'running')
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
        catch ex
            DAStudio.error('RTW:fcnClass:modelNotCompile',ex.message);
        end
    end

    hSrc.Data=[];
    inPortInd=0;
    outPortInd=0;

    for i=1:length(portH)
        [argName,cat,qualifier]=hSrc.getPortDefaultConf(portH(i));
        portType=get_param(portH(i),'BlockType');
        if strcmpi(portType,'Inport')||hSrc.isControlPort(portH(i))
            portType='Inport';
            portInd=inPortInd;
            inPortInd=inPortInd+1;
        else
            portInd=outPortInd;
            outPortInd=outPortInd+1;
        end

        arg=RTW.FcnArgSpec(portNames{i},portType,cat,argName,...
        i,qualifier,portInd,i);
        hSrc.Data=[hSrc.Data;arg];
    end
    set_param(hModel,'RTWFcnClass',hSrc);

