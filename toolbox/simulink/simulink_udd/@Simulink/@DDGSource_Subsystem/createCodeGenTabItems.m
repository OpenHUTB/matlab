function items=createCodeGenTabItems(source)
    items={};
    dialogRefresh=true;
    isVisible=true;

    thisBlockH=source.getBlock.Handle;


    systemCodeIsEnabled=getIsSystemCodeIsEnabled(source);

    items=addWidget(source,items,'RTWSystemCode',isVisible,dialogRefresh,systemCodeIsEnabled);

    sysCode=get_param(thisBlockH,'RTWSystemCode');

    isNonreusableFunc=false;
    isReusableFunc=false;

    if systemCodeIsEnabled
        isNonreusableFunc=strcmp(sysCode,'Nonreusable function');
        isReusableFunc=strcmp(sysCode,'Reusable function');
    end

    fcnNameOptsIsVisible=false;
    fileNameOptsIsVisible=false;
    if(isNonreusableFunc||isReusableFunc)
        fcnNameOptsIsVisible=true;
        fileNameOptsIsVisible=true;
    end


    items=addWidget(source,items,'RTWFcnNameOpts',fcnNameOptsIsVisible,dialogRefresh);

    fcnNameIsVisible=false;
    if fcnNameOptsIsVisible&&getFcnNameIsUserSpecified(thisBlockH)
        fcnNameIsVisible=true;
    end


    items=addWidget(source,items,'RTWFcnName',fcnNameIsVisible);


    items=addWidget(source,items,'RTWFileNameOpts',fileNameOptsIsVisible,dialogRefresh);

    fileNameIsVisible=false;
    if fileNameOptsIsVisible&&getFileNameIsUserSpecified(thisBlockH)
        fileNameIsVisible=true;
    end


    items=addWidget(source,items,'RTWFileName',fileNameIsVisible);

    isErt=getIsERTTarget(source.getBlock.Handle);

    interfaceSpecIsVisible=false;
    if isNonreusableFunc&&(isErt||getIsLibrary(source))

        interfaceSpecIsVisible=true;
    end


    items=addWidget(source,items,'FunctionInterfaceSpec',interfaceSpecIsVisible);


    items=addWidget(source,items,'FunctionWithSeparateData',interfaceSpecIsVisible,dialogRefresh);

    memFuncIsVisible=false;
    if(isNonreusableFunc||isReusableFunc)&&isErt
        memFuncIsVisible=true;
    end



    items=addWidget(source,items,'RTWMemSecFuncInitTerm',memFuncIsVisible);


    items=addWidget(source,items,'RTWMemSecFuncExecute',memFuncIsVisible);

    showMemData=false;
    if interfaceSpecIsVisible&&isStandalone(thisBlockH)&&isErt
        showMemData=true;
    end


    items=addWidget(source,items,'RTWMemSecDataConstants',showMemData);


    items=addWidget(source,items,'RTWMemSecDataInternal',showMemData);


    items=addWidget(source,items,'RTWMemSecDataParameters',showMemData);
end



function ret=isStandalone(blkH)
    ret=false;
    prmVal=get_param(blkH,'FunctionWithSeparateData');
    if strcmp(prmVal,'on')
        ret=true;
    end
end

function ret=getFcnNameIsUserSpecified(blkH)
    ret=false;
    prmVal=get_param(blkH,'RTWFcnNameOpts');
    if strcmp(prmVal,'User specified')
        ret=true;
    end
end

function ret=getFileNameIsUserSpecified(blkH)
    ret=false;
    prmVal=get_param(blkH,'RTWFileNameOpts');
    if strcmp(prmVal,'User specified')
        ret=true;
    end
end


function ret=getIsLibrary(source)
    ret=source.isLibraryBlock(source.getBlock);
end

function isERT=getIsERTTarget(blockH)

    isERT=false;
    model=bdroot(blockH);
    sysTargetFile=lower(get_param(model,'SystemTargetFile'));

    if strcmp(sysTargetFile,'grt.tlc')

        return;
    end

    if strcmp(sysTargetFile,'ert.tlc')
        isERT=true;
        return;
    end


    [~,rtwgensettings]=coder.internal.getSTFInfo(model);
    if isfield(rtwgensettings,'DerivedFrom')
        isERT=strcmp(rtwgensettings.DerivedFrom,'ert.tlc');
    end
end

function ret=getIsSystemCodeIsEnabled(source)
    ret=false;
    block=source.getBlock;
    ssType=Simulink.SubsystemType(block.handle);
    if ssType.isSimulinkFunction()||ssType.isMessageTriggeredFunction()
        return;
    end
    ret=getIsAtomicSubsystem(source);
end

function ret=getIsAtomicSubsystem(source)



    ret=true;
    if getIsCondExecSubsystem(source,source.getBlock)
        return;
    end

    prmVal=get_param(source.getBlock.Handle,'TreatAsAtomicUnit');
    if strcmp(prmVal,'off')
        ret=false;
    end
end

