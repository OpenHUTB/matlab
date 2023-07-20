function[maskInfo,unsupportedParam]=collectMaskParamInfo(this,slbh,configManager)








    maskInfo={};
    unsupportedParam=false;

    if strcmpi(get_param(slbh,'Mask'),'on')

        maskNames=get_param(slbh,'MaskNames');

        for ii=1:length(maskNames)

            maskName=maskNames{ii};



            if isForEachSubsystem(slbh)>0
                blkH=isForEachSubsystem(slbh);
                blk=get_param(blkH,'Object');
                if~strcmp(blk.SubsysMaskParameterPartition(ii),'on')
                    continue;
                end
            end

            [maskUseCases,unsupportedCase]=collectMaskParameterUseCase(this,slbh,maskName,configManager);

            if unsupportedCase
                unsupportedParam=true;
                return;
            end


            if isempty(maskUseCases)
                continue;
            end


            reportDiff=compareUseCaseDataType(this,maskUseCases,maskName);
            if reportDiff
                unsupportedParam=true;
                return;
            end

            param.Name=maskName;
            usecase=maskUseCases{1};
            param.Value=usecase.BlockDialogValue;
            param.UseCases=maskUseCases;
            param.DataType=usecase.DataType;

            maskInfo{end+1}=param;%#ok<*AGROW>

        end

    end

end

function[useCases,unsupportedCase]=collectMaskParameterUseCase(this,slbh,maskName,configManager)


    useCases={};
    unsupportedCase=false;

    searchBlkDialog={};
    searchBlkDialog=searchBlkDialogUseCase(this,slbh,maskName,searchBlkDialog);

    for ii=1:length(searchBlkDialog)
        blkHandle=searchBlkDialog{ii};
        blkName=get_param(blkHandle,'Name');
        blkType=get_param(blkHandle,'BlockType');

        blockPath=getfullname(blkHandle);
        impl=configManager.getImplementationForBlock(blockPath);
        if~isempty(impl)&&isa(impl,'hdldefaults.SubsystemBlackBoxHDLInstantiation')
            continue;
        else
            try
                maskParamInfo=struct();
                maskParamInfo.maskName=maskName;
                maskParamInfo.blkHandle=searchBlkDialog{ii};
                msgobj=impl.validateMaskParameterInfo(maskParamInfo);
                if~isempty(msgobj)
                    reportUnsupportedCase(this,blkHandle,msgobj);
                    unsupportedCase=true;
                    return;
                end
                maskParamInfo=impl.getMaskParameterInfo(maskParamInfo);
            catch
                msgobj=message('hdlcoder:engine:unsupportedgenericblock',maskName);
                reportUnsupportedCase(this,blkHandle,msgobj);
                unsupportedCase=true;
                return;
            end
        end

        blkDialogValue=maskParamInfo.blkDialogValue;
        blkDialog=maskParamInfo.blkDialog;
        blkValStr=maskParamInfo.blkValStr;


        if~ismatrix(blkDialogValue)
            msgobj=message('hdlcoder:engine:unsupportedgenericvalue',maskName);
            reportUnsupportedCase(this,blkHandle,msgobj);
            unsupportedCase=true;
            return;
        end

        blkDialogValueFi=pirelab.convertInt2fi(blkDialogValue);
        if~isfi(blkDialogValueFi)
            msgobj=message('hdlcoder:engine:unsupportedgenerictype',maskName);
            reportUnsupportedCase(this,blkHandle,msgobj);
            unsupportedCase=true;
            return;
        end

        wordlength=blkDialogValueFi.WordLength;
        if wordlength>32
            msgobj=message('hdlcoder:engine:genericbwgreaterthan32',maskName);
            reportUnsupportedCase(this,blkHandle,msgobj);
            unsupportedCase=true;
            return;
        end

        if~strcmpi(blkType,'Subsystem')
            rto=get_param(blkHandle,'RuntimeObject');
        else
            maskType=get(blkHandle,'MaskType');
            if strcmpi(maskType,'Compare To Constant')
                const_slbh=find_system(getfullname(blkHandle),'findAll','on',...
                'SearchDepth','1','LookUnderMasks','all',...
                'FollowLinks','on','BlockType','Constant');

                rto=get_param(const_slbh,'RuntimeObject');
            else
                msgobj=message('hdlcoder:engine:unsupportedgenerictype',maskName);
                reportUnsupportedCase(this,blkHandle,msgobj);
                unsupportedCase=true;
                return;
            end
        end

        loc=0;
        for n=1:rto.NumRuntimePrms
            if strcmp(rto.RuntimePrm(n).Name,blkValStr)
                loc=n;
                break;
            end
        end
        genericDataType=rto.RuntimePrm(loc).DataType;


        pirtype=pirelab.convertSLType2PirType(genericDataType);
        if~isscalar(blkDialogValueFi)
            arraySize=numel(blkDialogValueFi);
            pirtype=pirelab.createPirArrayType(pirtype,arraySize);
        end

        usecase.BlockHandle=blkHandle;
        usecase.BlockName=blkName;
        usecase.BlockType=blkType;
        usecase.BlockPath=getfullname(blkHandle);
        usecase.BlockDialog=blkDialog;
        usecase.BlockDialogValue=blkDialogValueFi;
        usecase.DataType=pirtype;
        useCases{end+1}=usecase;

    end

end

function searchBlkDialog=searchBlkDialogUseCase(this,slbh,maskName,searchBlkDialog)%#ok<INUSL>


    maskVars=Simulink.findVars(getfullname(slbh),'SearchMethod','cached','WorkspaceType','mask','Name',maskName);

    if isempty(maskVars)
        return;
    end


    maskVar=[];
    for ii=1:length(maskVars)
        eachVar=maskVars(ii);
        hParent=get_param(eachVar.Workspace,'Handle');
        if isequal(hParent,slbh)
            maskVar=eachVar;
            break;
        end
    end

    if isempty(maskVar)
        return;
    end


    usedBlocks=maskVar.UsedByBlocks;
    for ii=1:length(usedBlocks)
        hblock=get_param(usedBlocks{ii},'Handle');
        searchBlkDialog{end+1}=hblock;
    end

end

function reportDiff=compareUseCaseDataType(this,maskUseCases,maskName)


    reportDiff=false;
    usecase=maskUseCases{1};
    dvalue=usecase.BlockDialogValue;
    pvalue=dvalue;
    psigned=dvalue.Signed;
    pwordlength=dvalue.WordLength;
    pfraclength=dvalue.FractionLength;
    for jj=2:length(maskUseCases)
        usecase_t=maskUseCases{jj};
        dvalue_t=usecase_t.BlockDialogValue;
        pvalue_t=dvalue_t;
        psigned_t=dvalue_t.Signed;
        pwordlength_t=dvalue_t.WordLength;
        pfraclength_t=dvalue_t.FractionLength;

        if~isequal(psigned,psigned_t)||...
            ~isequal(pwordlength,pwordlength_t)||...
            ~isequal(pfraclength,pfraclength_t)
            link_one=sprintf('   %s',hdlMsgWithLink(getfullname(usecase.BlockHandle)));
            link_two=hdlMsgWithLink(getfullname(usecase_t.BlockHandle));

            msgobj=message('hdlcoder:engine:differentgenerictype',maskName,link_one,link_two);
            reportUnsupportedCase(this,usecase_t.BlockHandle,msgobj);
            reportDiff=true;
            return;

        end

        if~isequal(pvalue,pvalue_t)
            link_one=sprintf('   %s',hdlMsgWithLink(getfullname(usecase.BlockHandle)));
            link_two=hdlMsgWithLink(getfullname(usecase_t.BlockHandle));

            msgobj=message('hdlcoder:engine:differentgenerictype',maskName,link_one,link_two);
            reportUnsupportedCase(this,usecase_t.BlockHandle,msgobj);
            reportDiff=true;
            return;

        end
    end

end


function reportUnsupportedCase(this,blkHandle,msgobj)
    blkParent=getSimulinkBlockHandle(get_param(blkHandle,'Parent'));
    if isForEachSubsystem(blkParent)>0


        this.updateChecks(getfullname(blkHandle),'block',msgobj,'error');
    else

        this.updateChecks(getfullname(blkHandle),'block',msgobj,'Warning');
    end

end

function blkH=isForEachSubsystem(slbh)

    blkH=find_system(slbh,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','BlockType','ForEach');
end





