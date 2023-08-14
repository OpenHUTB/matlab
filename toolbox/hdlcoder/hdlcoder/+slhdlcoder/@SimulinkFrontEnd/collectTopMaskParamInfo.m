function collectTopMaskParamInfo(this,blockInfo,configManager,thisNtwk)





    if isempty(this.hParamArgMap)
        return;
    end


    maskInfo=addModelRefMask(this,thisNtwk,blockInfo);


    maskInfo=addSubsysMask(this,blockInfo,thisNtwk,maskInfo);


    maskInfo=collectMaskUseCases(this,configManager,thisNtwk,maskInfo);



    paramInfo=crossCheckWithParamArgs(this,thisNtwk,maskInfo);


    for ii=1:length(paramInfo)
        param=paramInfo{ii};
        paramVal=convertMaskValueToInt(param.Val);
        paramDataType=param.DataType;
        thisNtwk.addGenericPort(param.Name,paramVal,paramDataType);
        useCases=param.useCases;
        for jj=1:length(useCases)
            usecase=useCases{jj};
            hC=thisNtwk.findComponent('sl_handle',usecase.slbh);

            if~isa(hC,'hdlcoder.ctx_ref_comp')
                if isa(hC,'hdlcoder.ntwk_instance_comp')
                    hC.addGenericPort(param.Name,param.Name,paramDataType);
                else
                    hC.addGenericPort(param.Name,paramVal,paramDataType);
                end
            end
        end
    end
end

function maskInfo=addModelRefMask(this,thisNtwk,blockInfo)
    otherblocks=[blockInfo.OtherBlocks,blockInfo.EnablePort,blockInfo.ResetPort,...
    blockInfo.StateControl,blockInfo.StateEnablePort,blockInfo.TriggerPort];
    maskInfo={};
    for k=1:length(otherblocks)
        slbh=otherblocks(k);
        typ=get_param(slbh,'BlockType');
        switch typ
        case 'ModelReference'
            blockPath=getfullname(slbh);



            paramArgVals=get_param(slbh,'ParameterArgumentValues');
            if~isempty(paramArgVals)&&~isempty(blockPath)
                paramNames=fields(paramArgVals);
                paramValues=struct2cell(paramArgVals);
                maskValues=get_param(slbh,'MaskValues');

                if~isempty(maskValues)
                    maskNames=get_param(slbh,'MaskNames');
                    for kk=1:length(maskValues)
                        for jj=1:length(paramValues)
                            if strcmp(maskNames{kk},paramValues{jj})==1
                                paramValues{jj}=maskValues{kk};
                                break;
                            end
                        end
                    end
                end

                hC=thisNtwk.findComponent('sl_handle',slbh);
                hChildNtwk=hC.ReferenceNetwork;
                for itr=0:(hChildNtwk.NumberOfPirGenericPorts-1)
                    genericName=hChildNtwk.getGenericPortName(itr);
                    for kk=1:length(paramNames)
                        paramName=paramNames{kk};

                        if strcmpi(paramName,genericName)==1
                            hCParamVal=paramValues{kk};
                            maskVal=str2num(hCParamVal);%#ok
                            if isempty(maskVal)
                                if this.hParamArgMap.isKey(hCParamVal)
                                    genericVal=hChildNtwk.getGenericPortValue(itr);
                                    pirType=hChildNtwk.getGenericPortDataType(itr);
                                    maskInfo=addUseCase(maskInfo,slbh,...
                                    hCParamVal,genericVal,pirType.getLeafType,typ);
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function maskInfo=addSubsysMask(this,blockInfo,thisNtwk,maskInfo)
    otherblocks=[blockInfo.OtherBlocks,blockInfo.EnablePort,blockInfo.StateControl,...
    blockInfo.StateEnablePort,blockInfo.TriggerPort];
    for k=1:length(otherblocks)
        slbh=otherblocks(k);
        typ=get_param(slbh,'BlockType');
        switch typ
        case 'SubSystem'
            hC=thisNtwk.findComponent('sl_handle',slbh);
            maskNames={};
            if isprop(slbh,'MaskNames')
                maskNames=get_param(slbh,'MaskNames');
            end
            if isa(hC,'hdlcoder.ntwk_instance_comp')
                hChildNtwk=hC.ReferenceNetwork;

                numGenericPorts=hChildNtwk.NumberOfPirGenericPorts;
                if numGenericPorts>0
                    for itr=0:(numGenericPorts-1)
                        genericName=hChildNtwk.getGenericPortName(itr);


                        if this.hParamArgMap.isKey(genericName)&&~any(strcmp(maskNames,genericName))
                            pirType=hChildNtwk.getGenericPortDataType(itr);
                            genericVal=hChildNtwk.getGenericPortValue(itr);
                            maskInfo=addUseCase(maskInfo,slbh,genericName,...
                            genericVal,pirType.getLeafType,typ);
                        end
                    end
                end
            end
        end
    end
end

function maskInfo=collectMaskUseCases(this,configManager,...
    thisNtwk,maskInfo)
    paramArgs=this.hParamArgMap.keys;
    maskNames={};
    if isprop(thisNtwk.SimulinkHandle,'MaskNames')
        maskNames=get_param(thisNtwk.SimulinkHandle,'MaskNames');
    end

    for k=1:length(paramArgs)

        if any(strcmp(maskNames,paramArgs{k}))
            continue;
        end
        maskVar=Simulink.findVars(getfullname(thisNtwk.SimulinkHandle),...
        'SearchMethod','cached','Name',paramArgs{k});
        if isempty(maskVar)
            continue;
        end
        paramArgName=paramArgs{k};
        usedBlocks=maskVar.UsedByBlocks;
        for ii=1:length(usedBlocks)
            slbh=get_param(usedBlocks{ii},'Handle');
            typ=get_param(slbh,'BlockType');
            hC=thisNtwk.findComponent('sl_handle',slbh);
            if isempty(hC)
                continue;
            end

            switch typ
            case 'Constant'
                blkValStr='Value';
                genericName=get_param(slbh,blkValStr);
                if isempty(regexp(genericName,paramArgName,'once'))
                    msgobj=message('hdlcoder:engine:parameterconstantdialog',paramArgName);
                    this.updateChecks(getfullname(slbh),'block',msgobj,'Warning');
                    continue;
                end

                if~strcmp(genericName,paramArgName)
                    msgobj=message('hdlcoder:engine:unsupportedparameterstatement',paramArgName);
                    this.updateChecks(getfullname(slbh),'block',msgobj,'Warning');
                    continue;
                end

                impl=this.pirGetImplementation(slbh,configManager);
                if isa(impl,'hdldefaults.ConstantSpecialHDLEmission')
                    continue;
                end
                genericVal=impl.getBlockDialogValue(slbh);
            case 'Gain'
                blkValStr='Gain';
                genericName=get_param(slbh,blkValStr);
                if isempty(regexp(genericName,paramArgName,'once'))
                    msgobj=message('hdlcoder:engine:parametergaindialog',paramArgName);
                    this.updateChecks(getfullname(slbh),'block',msgobj,'Warning');
                    continue;
                end

                if~strcmp(genericName,paramArgName)
                    msgobj=message('hdlcoder:engine:unsupportedparameterstatement',paramArgName);
                    this.updateChecks(getfullname(slbh),'block',msgobj,'Warning');
                    continue;
                end
                impl=this.pirGetImplementation(slbh,configManager);
                constMultiplierOptimParam=impl.getImplParams('ConstMultiplierOptimization');
                if~isempty(constMultiplierOptimParam)&&...
                    ~strcmpi(constMultiplierOptimParam,'none')
                    msgobj=message('hdlcoder:engine:parametergaincsd',genericName);
                    this.updateChecks(getfullname(slbh),'block',msgobj,'Warning');
                    continue;
                end
                genericVal=impl.getBlockDialogValue(slbh);
            case 'SubSystem'
                foundGenericPort=false;
                maskType=get(slbh,'MaskType');
                if isa(hC,'hdlcoder.ntwk_instance_comp')
                    hChildNtwk=hC.ReferenceNetwork;

                    numGenericPorts=hChildNtwk.NumberOfPirGenericPorts;
                    if numGenericPorts>0
                        for itr=0:(numGenericPorts-1)
                            genericName=hChildNtwk.getGenericPortName(itr);
                            if strcmp(genericName,paramArgs{k})
                                foundGenericPort=true;
                                break;
                            end
                        end
                    end
                    if~foundGenericPort

                        msgobj=message('hdlcoder:engine:unsupportedparametrizedblock',paramArgs{k});
                        this.updateChecks(getfullname(slbh),'block',msgobj,'Warning');
                    end
                    continue;
                elseif strcmpi(maskType,'Compare To Constant')
                    blkValStr='const';
                    genericName=get_param(slbh,blkValStr);
                    if isempty(regexp(genericName,paramArgName,'once'))
                        msgobj=message('hdlcoder:engine:parametercmpconstantdialog',paramArgName);
                        this.updateChecks(getfullname(slbh),'block',msgobj,'Warning');
                        continue;
                    end

                    if~strcmp(genericName,paramArgName)
                        msgobj=message('hdlcoder:engine:unsupportedparameterstatement',paramArgName);
                        this.updateChecks(getfullname(slbh),'block',msgobj,'Warning');
                        continue;
                    end

                    impl=this.pirGetImplementation(slbh,configManager);
                    genericVal=impl.getBlockDialogValue(slbh);

                else
                    msgobj=message('hdlcoder:engine:unsupportedparametrizedblock',paramArgs{k});
                    this.updateChecks(getfullname(slbh),'block',msgobj,'Error');
                    continue;
                end
            case 'ModelReference'
                continue;
            otherwise
                msgobj=message('hdlcoder:engine:unsupportedparametrizedblock',paramArgs{k});
                this.updateChecks(getfullname(slbh),'block',msgobj,'Error');
                continue;
            end


            if~this.hParamArgMap.isKey(genericName)
                continue;
            end


            convgname=str2num(genericName);%#ok
            if~isempty(convgname)&&(isnumeric(convgname)||isenum(convgname))
                continue;
            end


            if isenum(genericVal)
                continue;
            end


            if~ismatrix(genericVal)
                msgobj=message('hdlcoder:engine:unsupportedgenericvalue',genericName);
                this.updateChecks(getfullname(slbh),'block',msgobj,'Error');
                continue;
            end


            genericValFi=pirelab.convertInt2fi(genericVal);
            if~isfi(genericValFi)
                msgobj=message('hdlcoder:engine:unsupportedparametrizedtype',genericName);
                this.updateChecks(getfullname(slbh),'block',msgobj,'Warning');
                continue;
            end
            wordlength=genericValFi.WordLength;
            maxWL=32;
            if this.HDLCoder.getParameter('isVHDL')&&~genericValFi.issigned
                maxWL=31;
            end
            if wordlength>maxWL
                msgobj=message('hdlcoder:engine:ParamDataTypeTooBig',...
                genericName,int2str(wordlength),int2str(maxWL));
                this.updateChecks(getfullname(slbh),'block',msgobj,'Error');
                continue;
            end

            if~strcmpi(typ,'Subsystem')
                rto=get_param(slbh,'RuntimeObject');
            else
                maskType=get(slbh,'MaskType');
                if strcmpi(maskType,'Compare To Constant')
                    const_slbh=find_system(getfullname(slbh),'findAll','on',...
                    'SearchDepth','1','LookUnderMasks','all',...
                    'FollowLinks','on','BlockType','Constant');

                    rto=get_param(const_slbh,'RuntimeObject');
                    blkValStr='Value';
                else
                    msgobj=message('hdlcoder:engine:unsupportedgenerictype',maskName);
                    this.updateChecks(getfullname(slbh),'block',msgobj,'Error');
                    continue;
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


            pirType=pirelab.convertSLType2PirType(genericDataType);
            if~isscalar(genericValFi)
                arraySize=numel(genericValFi);
                pirType=pirelab.createPirArrayType(pirType,arraySize);
            end

            maskInfo=addUseCase(maskInfo,slbh,genericName,genericValFi,...
            pirType,typ);
        end
    end
end

function paramInfo=crossCheckWithParamArgs(this,thisNtwk,maskInfo)
    paramInfo={};
    if~isempty(this.hParamArgMap.keys)
        paramNames=this.hParamArgMap.keys;
        paramInfo={};
        for ii=1:length(paramNames)
            paramName=paramNames{ii};
            paramUsed=false;
            for jj=1:length(maskInfo)
                if strcmpi(paramName,maskInfo{jj}.Name)==1
                    paramUsed=true;

                    useCases=maskInfo{jj}.useCases;
                    firstslbh=useCases{1}.slbh;
                    firstUCDTyp=useCases{1}.DataType;
                    if firstUCDTyp.isArrayType
                        firstUCDTyp=firstUCDTyp.getLeafType;
                    end
                    psigned_f=firstUCDTyp.Signed;
                    pwordlength_f=firstUCDTyp.WordLength;
                    pfraclength_f=firstUCDTyp.FractionLength;
                    pdifftype=false;
                    for kk=2:length(useCases)
                        secondUCDTyp=useCases{kk}.DataType;
                        secondslbh=useCases{kk}.slbh;
                        if secondUCDTyp.isArrayType
                            secondUCDTyp=secondUCDTyp.getLeafType;
                        end
                        psigned_s=secondUCDTyp.Signed;
                        pwordlength_s=secondUCDTyp.WordLength;
                        pfraclength_s=secondUCDTyp.FractionLength;

                        if~isequal(psigned_f,psigned_s)||~isequal(pwordlength_f,pwordlength_s)||...
                            ~isequal(pfraclength_f,pfraclength_s)
                            link1=sprintf(' %s',hdlMsgWithLink(getfullname(firstslbh)));
                            link2=hdlMsgWithLink(secondslbh);
                            msgobj=message('hdlcoder:engine:differentparametertype',paramName,link1,link2);
                            this.updateChecks(getfullname(secondslbh),'block',msgobj,'Warning');
                            pdifftype=true;
                            break;
                        end
                    end
                    if pdifftype==false
                        paramInfo{end+1}=maskInfo{jj};
                    end
                    break;
                end
            end
            if~paramUsed&&strcmp(get_param(thisNtwk.SimulinkHandle,'Type'),'block_diagram')
                msgobj=message('hdlcoder:engine:unsupportedparametername',paramName);
                this.updateChecks(getfullname(thisNtwk.SimulinkHandle),'block',msgobj,'Warning');
            end
        end
    end
end


function maskInfo=addUseCase(maskInfo,slbh,genericName,genericVal,...
    pirType,blkType)
    param.Name=genericName;
    param.Val=genericVal;
    param.DataType=pirType;
    usecase.slbh=slbh;
    usecase.blktype=blkType;
    usecase.blkPath=getfullname(slbh);
    usecase.blkGenericValue=param.Val;
    usecase.DataType=param.DataType;
    foundMask=false;

    for jj=1:length(maskInfo)
        mask=maskInfo{jj};
        if strcmpi(param.Name,mask.Name)
            foundMask=true;
            maskInfo{jj}.useCases{end+1}=usecase;
        end
    end

    if foundMask==false
        param.useCases={};
        param.useCases{end+1}=usecase;
        maskInfo{end+1}=param;%#ok<*AGROW>
    end
end







