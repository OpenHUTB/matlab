function numCls=genClassMdl(this,aClsIdx,aNumCls,aThisPortMap)



    numCls=aNumCls;
    clsInfo=this.fCandidateInfo(aClsIdx);
    if clsInfo.isExcluded||isempty(find([clsInfo.Objects.isExcluded]==0,1))
        return;
    end

    clsName=['icm_',clsInfo.Class];




    xformedClsInfo=struct('Class',clsInfo.Class,'ClassMdlRef',clsName,'MemberFcns',[],'Objects',[]);

    if exist([this.fXformDir,clsName,'.slx'])>0
        delete([this.fXformDir,clsName,'.slx']);
    end

    close_system(clsName,0);
    mdlHandle=new_system(clsName,'Model');%#ok



    hasExistingDD=false;
    if this.fIsForBosch>0
        hasExistingDD=setDataDictionaryForClsMdl(this.fMdl,clsName);
    end

    set_param(clsName,'SolverType','Fixed-step');
    set_param(clsName,'ModelFunctionsGlobalVisibility','off');

    if this.fIsForBosch>0
        cfs_copy_ref=copy(getActiveConfigSet(this.fMdl));
        cfs_copy=cfs_copy_ref.getRefConfigSet;
        if length(clsInfo.Objects)>1
            set_param(cfs_copy,'ModelReferenceNumInstancesAllowed','Multi');
        end
        set_param(cfs_copy,'BusObjectLabelMismatch','none');
        cfs_name=cfs_copy_ref.getFullName;
        newConfigObj=attachConfigSetCopy(clsName,cfs_copy,true);
        setActiveConfigSet(clsName,newConfigObj.Name);
    end


    memberVarTypes=addInitialParams(clsName,clsInfo.MemberVars,clsInfo.Objects(1).InitVal,...
    clsInfo.ConstVars,clsInfo.Objects(1).ConstVal,this.fIsForBosch);


    oriPosMemberVarDSM=[100,100,140,140];
    xformedClsInfo.MemberFcns={};
    nestedClsInfos=[];
    wsHandle=get_param(clsName,'modelworkspace');
    numNestedObj=0;
    if this.fIsForBosch==2&&(isa(clsInfo.MemberVars,'Simulink.AliasType')||isa(clsInfo.MemberVars,'Simulink.NumericType'))










        temp=Simulink.Signal;
        if isa(clsInfo.MemberVars,'Simulink.AliasType')
            temp.DataType=clsInfo.MemberVars.BaseType;
        else
            temp.DataType=clsInfo.MemberVars.tostring;
        end
        temp.InitialValue='initVal_v';
        wsHandle.assignin('v',temp);
    else
        for vIdx=1:length(clsInfo.MemberVars)
            pos=oriPosMemberVarDSM;
            pos(1)=pos(1)+100*numNestedObj;
            pos(3)=pos(3)+100*numNestedObj;
            memberVar=clsInfo.MemberVars(vIdx);
            memberDSM=[clsName,'/',memberVar.Name];

            nestedClsInfo=isNestedObject(this,memberVar);

            if isempty(nestedClsInfo)














                temp=Simulink.Signal;
                if~(isempty(memberVar.Complexity)||strcmpi(memberVar.Complexity,'auto'))
                    temp.Complexity=memberVar.Complexity;
                end
                if~(isempty(memberVar.DataType)||strcmpi(memberVar.DataType,'Inherit: auto'))
                    temp.DataType=memberVar.DataType;
                end
                temp.InitialValue=['initVal_',memberVar.Name];
                wsHandle.assignin(memberVar.Name,temp);
            else
                numNestedObj=numNestedObj+1;
                nestedClsInfos=[nestedClsInfos,nestedClsInfo];
                nestedClsName=['icm_',nestedClsInfo.Class];



                add_block('built-in/ModelReference',memberDSM,...
                'Position',pos,...
                'ModelName',nestedClsName);
                set_param(memberDSM,'SimulationMode','Normal');

                modelArguments=get_param(memberDSM,'ParameterArgumentNames');
                modelArg=strsplit(modelArguments,',');
                modelArgVals=[];
                for aIdx=1:length(modelArg)
                    modelArgStr=modelArg{aIdx};
                    if startsWith(modelArgStr,'initVal_')
                        modelArgVals=[modelArgVals,'initVal_',memberVar.Name,'.',modelArgStr(9:end)];
                    else
                        modelArgVals=[modelArgVals,memberVar.Name,'.',modelArgStr];
                    end
                    if aIdx<length(modelArg)
                        modelArgVals=[modelArgVals,','];%#ok
                    end
                end
                set_param(memberDSM,'ParameterArgumentValues',modelArgVals);
            end
        end
    end

    if numNestedObj>0
        areaPos=[80,70,60+100*numNestedObj,160];
        add_block('built-in/Area',[clsName,'/Member Objects'],'Position',areaPos);
    end


    accessFcns=addGetSetFunc(this,aClsIdx,clsName,memberVarTypes,clsInfo,150);
    xformedClsInfo.MemberFcns=[xformedClsInfo.MemberFcns;accessFcns];


    oriPosMemberFcn=[100,440];
    max_height=0;





    for fIdx=1:length(clsInfo.MemberFcns)
        oriLibBlk=clsInfo.MemberFcns(fIdx).Fcn;
        blkPath=strsplit(oriLibBlk,'/');
        fcnBlkName=[clsName,'/',char(blkPath(end))];
        xformedClsInfo.MemberFcns=[xformedClsInfo.MemberFcns;{fcnBlkName}];
        clsInfo.MemberFcns(fIdx).XformedFcn=fcnBlkName;


        pos=get_param(oriLibBlk,'position');
        width=pos(3)-pos(1);
        height=pos(4)-pos(2);
        if max_height<height
            max_height=height;
        end
        pos=[oriPosMemberFcn,oriPosMemberFcn(1)+width,oriPosMemberFcn(2)+height];
        oriPosMemberFcn(1)=oriPosMemberFcn(1)+width+100;
        add_block(oriLibBlk,fcnBlkName,'position',pos);
        modifyFcnForNestedObj(this,fcnBlkName,nestedClsInfos,aThisPortMap);
        set_param(fcnBlkName,'LinkStatus','none');



        addSimulinkFcnTriggerPort(fcnBlkName,strrep(blkPath{end},' ',''));



        if clsInfo.HasThis
            if clsInfo.IsaBus==0
                removeThisDSM(clsInfo,clsInfo.MemberFcns(fIdx),{'v'},aThisPortMap,0);
            else
                removeThisDSM(clsInfo,clsInfo.MemberFcns(fIdx),{clsInfo.MemberVars.Name},aThisPortMap,1);
            end
        end


        replaceIOwithArgIO(clsInfo.MemberFcns(fIdx));


        removeMaskFromFcn(clsInfo.MemberFcns(fIdx),this.fMaskedProperties);
    end

    areaPos=[80,410,oriPosMemberFcn(1)-80,max_height+470];
    add_block('built-in/Area',[clsName,'/Member Functions'],'Position',areaPos);

    this.fXformedInfo=[this.fXformedInfo,xformedClsInfo];
    numCls=numCls+1;
    this.fIcmCls2IdxMap(clsName)=numCls;
    save_system(clsName,[this.fXformDir,clsName,'.slx']);
end

function hasExistingDD=setDataDictionaryForClsMdl(aMdl,aClsMdl)
    hasExistingDD=false;
    try
        ddFile=get_param(aMdl,'datadictionary');
        if exist(ddFile)
            set_param(aClsMdl,'datadictionary',ddFile);
            hasExistingDD=true;
        end
    catch
    end
end

function nestedCls=isNestedObject(m2mObj,aMemberVar)
    nestedCls=[];
    if~isempty(aMemberVar.DataType)&&~isempty(strfind(aMemberVar.DataType,'Bus: '))
        dataTypeStr=aMemberVar.DataType;
        dataTypeStr=strrep(dataTypeStr,' ','');
        dataTypeStr=dataTypeStr(5:end);
        cIdx=find(strcmpi(dataTypeStr,{m2mObj.fCandidateInfo.Class}));
        if~isempty(cIdx)&&~m2mObj.fCandidateInfo(cIdx).isExcluded
            nestedCls=m2mObj.fCandidateInfo(cIdx);
        end
    end
end

function modifyFcnForNestedObj(aM2mObj,aFcnBlk,aNestedClsInfos,aThisPortMap)
    if isempty(aNestedClsInfos)
        return;
    end

    linkedSSMap=containers.Map('KeyType','char','ValueType','any');
    fcn2ClsMap=containers.Map('KeyType','char','ValueType','any');
    for cIdx=1:length(aNestedClsInfos)
        for fIdx=1:length(aNestedClsInfos(cIdx).MemberFcns)
            fcn=aNestedClsInfos(cIdx).MemberFcns(fIdx).Fcn;
            linkedSSs=find_system(aFcnBlk,...
            'LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.allVariants,...
            'FollowLinks','on',...
            'BlockType','SubSystem',...
            'ReferenceBlock',fcn);
            linkedSSMap(fcn)=linkedSSs;

            clsName=['icm_',aNestedClsInfos(cIdx).Class];



            fcn2ClsMap(fcn)=clsName;
        end
    end

    set_param(aFcnBlk,'LinkStatus','none');

    fcns=keys(linkedSSMap);
    for fIdx=1:length(fcns)
        linkedSSs=linkedSSMap(fcns{fIdx});
        for sIdx=1:length(linkedSSs)
            paramObj=get_param(linkedSSs{sIdx},'object');
            params=paramObj.get;
            thisIOsIdx=aThisPortMap(fcns{fIdx});
            lineHandles=params.LineHandles;

            thisInLine=lineHandles.Inport(thisIOsIdx(1));
            thisInSrc=get_param(thisInLine,'SrcBlockHandle');
            dsmName=get_param([getfullname(thisInSrc),'/readVariable'],'DataStoreName');
            instName=get_param([getfullname(thisInSrc),'/readVariable'],'DataStoreElements');
            instName=instName(length(dsmName)+2:end);
            delete_line(thisInLine);
            delete_block(thisInSrc);

            thisOutLine=lineHandles.Outport(thisIOsIdx(2));
            thisOutDst=get_param(thisOutLine,'DstBlockHandle');
            delete_line(thisOutLine);
            delete_block(thisOutDst);


            refBlock=strsplit(fcns{fIdx},'/');
            fcnName=strrep(char(refBlock(end)),' ','');
            fcnBlkName=char(refBlock(end));
            fcnCallerBlk=[params.Path,'/Caller_',params.Name];
            add_block('built-in/FunctionCaller',fcnCallerBlk,'Position',params.Position,'Tag',params.Tag);
            if isKey(aM2mObj.fSS2FcnCallMap,params.Parent)
                aM2mObj.fSS2FcnCallMap(params.Parent)=[aM2mObj.fSS2FcnCallMap(params.Parent),{fcnCallerBlk}];
            else
                aM2mObj.fSS2FcnCallMap(params.Parent)={fcnCallerBlk};
            end


            memberFcn=[fcn2ClsMap(fcns{fIdx}),'/',fcnBlkName];
            fcnPrototype=get_param(memberFcn,'FunctionPrototype');
            if contains(fcnPrototype,'=')
                fcnPrototype=strrep(fcnPrototype,['= ',fcnName],['= ',instName,'.',fcnName]);
            else
                fcnPrototype=[instName,'.',fcnPrototype];
            end
            set_param(fcnCallerBlk,'FunctionPrototype',fcnPrototype);



            findEqual=strfind(fcnPrototype,'=');
            if~isempty(findEqual)
                outputArgs=fcnPrototype(1:findEqual-1);
                outputArgs=strrep(outputArgs,' ','');
                outputArgs=strrep(outputArgs,'[','');
                outputArgs=strrep(outputArgs,']','');
                outputArg=strsplit(outputArgs,',');
                outArgSpec=[];
                for aIdx=1:length(outputArg)
                    dataType=get_param([memberFcn,'/',char(outputArg(aIdx))],'OutDataTypeStr');
                    dataType=aM2mObj.getBasicNumericType(dataType,fcnCallerBlk);
                    if aIdx==length(outputArg)
                        outArgSpec=[outArgSpec,dataType];%#ok
                    else
                        outArgSpec=[outArgSpec,dataType,','];%#ok
                    end
                end

            end


            frontParenthesis=strfind(fcnPrototype,'(');
            BackParenthesis=strfind(fcnPrototype,')');
            if~(isempty(frontParenthesis)||frontParenthesis==BackParenthesis-1)
                inputArgs=fcnPrototype(frontParenthesis+1:BackParenthesis-1);
                inputArg=strsplit(inputArgs,',');
                inArgSpec=[];
                for aIdx=1:length(inputArg)
                    dataType=get_param([memberFcn,'/',char(inputArg(aIdx))],'OutDataTypeStr');
                    dataType=aM2mObj.getBasicNumericType(dataType,fcnCallerBlk);
                    if aIdx==length(inputArg)
                        inArgSpec=[inArgSpec,dataType];%#ok
                    else
                        inArgSpec=[inArgSpec,dataType,','];%#ok
                    end
                end

            end


            rewireFcnCallerBlk(aM2mObj,fcnCallerBlk,params,aThisPortMap(fcns{fIdx}));
            delete_block(linkedSSs{sIdx});
        end
    end
end

function aMemberVarTypes=addInitialParams(aClsName,aMemberVars,aMemberVals,aConstVars,aConstVals,aIsForBosch)
    wsHandle=get_param(aClsName,'modelworkspace');
    aMemberVarTypes=containers.Map('KeyType','char','ValueType','char');
    argumentList=[];
    for vIdx=1:length(aMemberVars)
        if isa(aMemberVars(vIdx),'Simulink.BusElement')
            temp=Simulink.Parameter;
            temp.Description=aMemberVars(vIdx).Description;
            temp.Value=eval(['aMemberVals.',aMemberVars(vIdx).Name]);
            temp.Min=aMemberVars(vIdx).Min;
            temp.Max=aMemberVars(vIdx).Max;
            temp.DataType=aMemberVars(vIdx).DataType;
            wsHandle.assignin(['initVal_',aMemberVars(vIdx).Name],temp);
            argumentList=[argumentList,' initVal_',aMemberVars(vIdx).Name,','];%#ok
            aMemberVarTypes(aMemberVars(vIdx).Name)=aMemberVars(vIdx).DataType;
        elseif aIsForBosch==2&&(isa(aMemberVars(vIdx),'Simulink.AliasType')||isa(aMemberVars(vIdx),'Simulink.NumericType'))
            temp=Simulink.Parameter;
            temp.Value=0;
            temp.Description=aMemberVars(vIdx).Description;
            if isa(aMemberVars(vIdx),'Simulink.AliasType')
                temp.DataType=aMemberVars(vIdx).BaseType;
            else
                temp.DataType=aMemberVars(vIdx).tostring;
            end
            wsHandle.assignin('initVal_v',temp);
            argumentList=[argumentList,' initVal_v,'];%#ok
            if isa(aMemberVars(vIdx),'Simulink.AliasType')
                aMemberVarTypes('v')=aMemberVars(vIdx).BaseType;
            else
                aMemberVarTypes('v')=aMemberVars(vIdx).tostring;
            end
        end
    end

    for vIdx=1:length(aConstVars)
        if~isa(aConstVars(vIdx),'Simulink.BusElement')
            error('ConstVar should be of Simulink.BusElement type');
        end
        temp=Simulink.Parameter;
        temp.Description=aConstVars(vIdx).Description;
        temp.DataType=aConstVars(vIdx).DataType;
        temp.Value=eval(['aConstVals.',aConstVars(vIdx).Name]);
        temp.Min=aConstVars(vIdx).Min;
        temp.Max=aConstVars(vIdx).Max;
        wsHandle.assignin(aConstVars(vIdx).Name,temp);
        argumentList=[argumentList,' ',aConstVars(vIdx).Name,','];%#ok
    end
    set_param(aClsName,'ParameterArgumentNames',argumentList);
end

function addTriggerPort(aMemberFcn)
    blkPath=strsplit(aMemberFcn.XformedFcn,'/');
    add_block('simulink/User-Defined Functions/Simulink Function',[blkPath{1},'/SimulinkFunction']);
    fcnName=strrep(blkPath{end},' ','');
    trigBlkName=[aMemberFcn.XformedFcn,'/',fcnName];
    add_block([blkPath{1},'/SimulinkFunction/f'],trigBlkName,'position',[500,20,520,40]);
    set_param(trigBlkName,'FunctionName',fcnName);
    delete_block([blkPath{1},'/SimulinkFunction']);
end


function replaceMaskedSSThisAccess(aClsInfo,aMemberFcn,aMemberVars,aThisDSM,aIsaBus)
    thisAccess=get_param([aMemberFcn.XformedFcn,'/',aThisDSM],'DSReadWriteBlocks');
    for vIdx=1:length(aMemberVars)
        if aIsaBus
            regExpr=['(',aThisDSM,'.',aMemberVars{vIdx},'$|',aThisDSM,'.',aMemberVars{vIdx},'\.+)'];
        else
            regExpr=aThisDSM;
        end
        maskedSubsys=find_system(aMemberFcn.XformedFcn,...
        'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.allVariants,...
        'regexp','on',...
        'FollowLinks','on',...
        'BlockType','SubSystem',...
        'MaskValueString',regExpr);
        thisAccess=get_param([aMemberFcn.XformedFcn,'/',aThisDSM],'DSReadWriteBlocks');
        for bIdx=1:length(maskedSubsys)
            dsrwType=accessSubsys(maskedSubsys{bIdx},[thisAccess.handle]);
            if isempty(dsrwType)
                maskObj=Simulink.Mask.get(maskedSubsys{bIdx});
                maskObj.Parameters.Value=aMemberVars{vIdx};
            else
                posMaskedSS=get_param(maskedSubsys{bIdx},'Position');
                delete_block(maskedSubsys{bIdx});
                clsMdl=bdroot(aMemberFcn.XformedFcn);
                foundAccessFcn=false;
                if strcmpi(dsrwType,'DataStoreWrite')
                    if~isempty(find(strcmpi(aMemberVars{vIdx},aClsInfo.SetFcns)))
                        fcnPrototype=get_param([clsMdl,'/setVar_',aMemberVars{vIdx}],'FunctionPrototype');
                        foundAccessFcn=true;
                    end
                else
                    if~isempty(find(strcmpi(aMemberVars{vIdx},aClsInfo.GetFcns)))
                        fcnPrototype=get_param([clsMdl,'/getVar_',aMemberVars{vIdx}],'FunctionPrototype');
                        foundAccessFcn=true;
                    end
                end
                if foundAccessFcn
                    add_block('built-in/FunctionCaller',maskedSubsys{bIdx},'FunctionPrototype',fcnPrototype,'Position',posMaskedSS);
                else
                    add_block(['built-in/',dsrwType],maskedSubsys{bIdx},'DataStoreName',aMemberVars{vIdx},'Position',posMaskedSS);
                end
            end
        end
    end
end

function replaceRemainThisAccess(aMemberFcn,aThisDSM)
    thisAccess=get_param([aMemberFcn.XformedFcn,'/',aThisDSM],'DSReadWriteBlocks');
    for aIdx=1:length(thisAccess)
        paramObj=get_param(thisAccess(aIdx).handle,'object');
        params=paramObj.get;
        fullname=getfullname(thisAccess(aIdx).handle);
        delete_block(thisAccess(aIdx).handle);


        dsmElements=params.DataStoreElements;
        dsmElements=dsmElements(length(aThisDSM)+2:end);
        dsmField=strsplit(dsmElements,'.');
        dsmName=dsmField{1};

        add_block(['built-in/',params.BlockType],fullname,...
        'position',params.Position,...
        'DataStoreName',dsmName,...
        'DataStoreElements',dsmElements,...
        'SampleTime',params.SampleTime);
    end
end

function removeThisDSM(aClsInfo,aMemberFcn,aMemberVars,aThisPortMap,aIsaBus)
    if~(isempty(aMemberFcn.ThisIn)||isempty(aMemberFcn.ThisOut))
        thisInport=[aMemberFcn.XformedFcn,'/',aMemberFcn.ThisIn];
        thisOutport=[aMemberFcn.XformedFcn,'/',aMemberFcn.ThisOut];
        aThisPortMap(aMemberFcn.Fcn)=[str2num(get_param(thisInport,'port')),str2num(get_param(thisOutport,'port'))];
        iConnectivity=get_param(thisInport,'PortConnectivity');
        oConnectivity=get_param(thisOutport,'PortConnectivity');
        if isempty(iConnectivity.DstBlock)||length(iConnectivity.DstBlock)>1||...
            isempty(oConnectivity.SrcBlock)||length(oConnectivity.SrcBlock)>1
            error('Block with this port connectivity should not even be considered as candidate!!');
        else
            thisDSW=iConnectivity.DstBlock;
            thisDSR=oConnectivity.SrcBlock;
            thisDSM=get_param(thisDSW,'DataStoreName');
            if strcmpi(thisDSM,get_param(thisDSR,'DataStoreName'))

                delete_line(aMemberFcn.XformedFcn,[aMemberFcn.ThisIn,'/1'],[get_param(thisDSW,'Name'),'/1']);
                delete_line(aMemberFcn.XformedFcn,[get_param(thisDSR,'Name'),'/1'],[aMemberFcn.ThisOut,'/1']);

                delete_block([aMemberFcn.XformedFcn,'/',aMemberFcn.ThisIn]);
                delete_block([aMemberFcn.XformedFcn,'/',aMemberFcn.ThisOut]);
                delete_block(thisDSR);
                delete_block(thisDSW);

                replaceMaskedSSThisAccess(aClsInfo,aMemberFcn,aMemberVars,thisDSM,aIsaBus);

                replaceRemainThisAccess(aMemberFcn,thisDSM);


                pos=get_param([aMemberFcn.XformedFcn,'/',thisDSM],'Position');
                delete_block([aMemberFcn.XformedFcn,'/',thisDSM]);


                blkPath=strsplit(aMemberFcn.XformedFcn,'/');
                trigBlkName=[aMemberFcn.XformedFcn,'/',char(blkPath(end))];
                pos(3)=pos(1)+20;
                pos(4)=pos(2)+20;
                set_param(trigBlkName,'position',pos);
            else
                error('DSMs of DSR and DSW are not the same !!');
            end
        end
    end
end

function result=accessSubsys(aSubsys,aThisAccessHandle)
    result=[];
    blksInSS=get_param(aSubsys,'Blocks');
    if length(blksInSS)~=2
        return;
    end
    bIdx=0;
    pIdx=0;
    dsrwType=[];
    for idx=1:length(blksInSS)
        type=get_param([aSubsys,'/',blksInSS{idx}],'BlockType');
        if strcmpi(type,'Inport')||strcmpi(type,'Outport')
            pIdx=idx;
        elseif strcmpi(type,'DataStoreRead')||strcmpi(type,'DataStoreWrite')
            dsrwType=type;
            bIdx=idx;
        end
    end
    if bIdx==0||pIdx==0
        return;
    end

    dsrw=[aSubsys,'/',blksInSS{bIdx}];
    if any(aThisAccessHandle==get_param(dsrw,'handle'))
        result=dsrwType;
    end
end

function replaceIOwithArgIO(aMemberFcn)
    inports=find_system(aMemberFcn.XformedFcn,'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants,'SearchDepth',1,'BlockType','Inport');
    outports=find_system(aMemberFcn.XformedFcn,'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants,'SearchDepth',1,'BlockType','Outport');
    for ii=1:length(inports)
        blkObj=get_param(inports{ii},'object');
        params=blkObj.get;
        delete_block(inports{ii});
        ArgInport=[params.Parent,'/a',params.Name];
        add_block('built-in/Argin',ArgInport,...
        'ArgumentName',['a',params.Name],...
        'Position',params.Position);
        if~strcmpi(params.SignalType,'auto')
            set_param(ArgInport,'SignalType',params.SignalType);
        end
        if~strcmpi(params.OutDataTypeStr,'Inherit: auto')
            set_param(ArgInport,'OutDataTypeStr',params.OutDataTypeStr);
        end
    end
    for ii=1:length(outports)
        blkObj=get_param(outports{ii},'object');
        params=blkObj.get;
        delete_block(outports{ii});
        ArgOutport=[params.Parent,'/a',params.Name];
        add_block('built-in/Argout',ArgOutport,...
        'ArgumentName',['a',params.Name],...
        'Position',params.Position);
        if~strcmpi(params.SignalType,'auto')
            set_param(ArgOutport,'SignalType',params.SignalType);
        end
        if~strcmpi(params.OutDataTypeStr,'Inherit: auto')
            set_param(ArgOutport,'OutDataTypeStr',params.OutDataTypeStr);
        end
    end
end

function modifiedSS=removeStructAccessFromMaskParam(aSubsystem,aMaskParam)
    modifiedSS=[];
    maskObj=Simulink.Mask.get(aSubsystem);
    if isempty(maskObj)||isempty(maskObj.Parameters)
        return;
    end

    shouldDisableLink=false;
    for pIdx=1:length(maskObj.Parameters)
        paramValue=maskObj.Parameters(pIdx).Value;
        if strfind(paramValue,[aMaskParam,'.'])==1
            maskObj.Parameters(pIdx).Value=paramValue(length(aMaskParam)+2:end);
            shouldDisableLink=true;
        end
    end

    if shouldDisableLink
        modifiedSS=aSubsystem;
        set_param(aSubsystem,'linkstatus','none');
    end
end

function removeMaskFromFcn(aMemberFcn,aMaskedProperties)
    maskObj=Simulink.Mask.get(aMemberFcn.XformedFcn);
    if isempty(maskObj)||isempty(maskObj.Parameters)
        return;
    end
    maskParamName=maskObj.Parameters.Name;
    maskParamVal=maskObj.Parameters.Value;

    subsystems=find_system(aMemberFcn.XformedFcn,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.allVariants,'BlockType','SubSystem');
    modifiedSSs={};
    for sIdx=1:length(subsystems)
        if strcmpi(aMemberFcn.XformedFcn,subsystems{sIdx})
            continue;
        end
        modifiedSSs=[modifiedSSs,removeStructAccessFromMaskParam(subsystems{sIdx},maskParamVal)];
    end

    blkTypes=keys(aMaskedProperties);
    for kIdx=1:length(blkTypes)
        properties=aMaskedProperties(blkTypes{kIdx});
        correctMaskedProperties(aMemberFcn.XformedFcn,maskParamName,blkTypes{kIdx},properties,modifiedSSs);
    end
    maskObj.delete;
end

function isParent=isParentOfBlock(aBlk,aModifiedSSs)
    isParent=false;
    blkName=getfullname(aBlk);
    for sIdx=1:length(aModifiedSSs)
        ssName=getfullname(aModifiedSSs{sIdx});
        if contains(blkName,ssName)&&strfind(blkName,ssName)==1
            isParent=true;
            return;
        end
    end
end

function correctMaskedProperties(aFcnBlk,aMaskParamVal,aBlkType,aProperties,aModifiedSSs)
    blks=find_system(aFcnBlk,'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants,...
    'BlockType',aBlkType);
    for bIdx=1:length(blks)
        if isParentOfBlock(blks{bIdx},aModifiedSSs)
            continue;
        end
        for pIdx=1:length(aProperties)
            property=aProperties{pIdx};
            propVal=get_param(blks{bIdx},property);
            findMaskParamVal=strfind(propVal,[aMaskParamVal,'.']);
            if~isempty(findMaskParamVal)&&findMaskParamVal(1)==1
                set_param(blks{bIdx},property,propVal(length(aMaskParamVal)+2:end));
            end
        end
    end
end

function accessFcns=addGetSetFunc(this,aClsIdx,aClsName,aMemberVarTypes,aClsInfo,aYoffset)
    GetFcns=aClsInfo.GetFcns;
    SetFcns=aClsInfo.SetFcns;
    accessFcns={};
    oriPosAccessFcn=[100,120+aYoffset];
    fcnWidth=80;
    fcnHeight=50;
    gapWidth=100;
    drawArea=false;
    for idx=1:length(GetFcns)
        pos=[oriPosAccessFcn,oriPosAccessFcn(1)+fcnWidth,oriPosAccessFcn(2)+fcnHeight];
        oriPosAccessFcn(1)=oriPosAccessFcn(1)+fcnWidth+gapWidth;
        if strcmpi(GetFcns{idx},'@')
            if isempty(aClsInfo.MemberVars)
                continue;
            end
            aFcnName='getAll';
        else
            aFcnName=['getVar_',GetFcns{idx}];
        end
        aFcnFullName=[aClsName,'/',aFcnName];
        add_block('built-in/SubSystem',aFcnFullName,'Position',pos);
        addSimulinkFcnTriggerPort(aFcnFullName,aFcnName);
        if strcmpi(GetFcns{idx},'@')
            if isa(aClsInfo.MemberVars(1),'Simulink.BusElement')
                addDataStoreRead(this,aClsIdx,aFcnFullName,GetFcns{idx},aMemberVarTypes,aClsInfo.Class);
            end
        else
            addDataStoreRead(this,aClsIdx,aFcnFullName,GetFcns{idx},aMemberVarTypes(GetFcns{idx}));
        end
        accessFcns=[accessFcns;{aFcnFullName}];%#ok
        drawArea=true;
    end

    for idx=1:length(SetFcns)
        pos=[oriPosAccessFcn,oriPosAccessFcn(1)+fcnWidth,oriPosAccessFcn(2)+fcnHeight];
        oriPosAccessFcn(1)=oriPosAccessFcn(1)+fcnWidth+gapWidth;
        if strcmpi(GetFcns{idx},'@')
            if isempty(aClsInfo.MemberVars)
                continue;
            end
            aFcnName='setAll';
        else
            aFcnName=['setVar_',GetFcns{idx}];
        end
        aFcnFullName=[aClsName,'/',aFcnName];
        add_block('built-in/SubSystem',aFcnFullName,'Position',pos);
        addSimulinkFcnTriggerPort(aFcnFullName,aFcnName);

        if strcmpi(SetFcns{idx},'@')
            if isa(aClsInfo.MemberVars(1),'Simulink.BusElement')
                addDataStoreWrite(this,aClsIdx,aFcnFullName,SetFcns{idx},aMemberVarTypes,aClsInfo.Class);
            end
        else
            addDataStoreWrite(this,aClsIdx,aFcnFullName,SetFcns{idx},aMemberVarTypes(SetFcns{idx}));
        end
        accessFcns=[accessFcns;{aFcnFullName}];%#ok
        drawArea=true;
    end

    if drawArea
        areaPos=[80,80+aYoffset,oriPosAccessFcn(1)-80,190+aYoffset];
        add_block('built-in/Area',[aClsName,'/Get,Set Functions'],'Position',areaPos);
    end
end

function fcnName=addSimulinkFcnTriggerPort(aFcnBlk,aFcnName)
    currSys=bdroot(aFcnBlk);
    add_block('simulink/User-Defined Functions/Simulink Function',[currSys,'/SimulinkFunction']);
    trigPort=[aFcnBlk,'/',aFcnName];
    handle=add_block([currSys,'/SimulinkFunction/f'],trigPort,'MakeNameUnique','on','position',[500,20,520,40]);
    fcnName=get_param(handle,'Name');
    if~strcmpi(fcnName,aFcnName)
        delete_block([aFcnBlk,'/',fcnName]);
        set_param([aFcnBlk,'/',aFcnName],'Name',fcnName);
        add_block([currSys,'/SimulinkFunction/f'],trigPort,'position',[500,20,520,40]);
    end
    set_param(trigPort,'FunctionName',aFcnName);
    delete_block([currSys,'/SimulinkFunction']);
end

function foundClass=searchExistingClass(icmObj,aCurrClsIdx,aElement)
    foundClass=false;
end


function addDataStoreRead(icmObj,aCurrClsIdx,aFcnBlk,aElement,aDataType,aBusTypeStr)
    if~strcmpi(aElement,'@')
        dataTypeStr=aDataType;
        dsAccess=[aFcnBlk,'/',aElement];

        if contains(dataTypeStr,'Bus: ')&&isKey(icmObj.fIcmCls2IdxMap,['icm_',dataTypeStr(6:end)])
            fcnPrototype=get_param(['icm_',dataTypeStr(6:end),'/getAll'],'FunctionPrototype');
            fcnPrototype=strrep(fcnPrototype,['= getAll'],['= ',aElement,'.getAll']);
            add_block('built-in/FunctionCaller',dsAccess,'FunctionPrototype',fcnPrototype,'Position',[50,180,90,220]);
        else
            add_block('built-in/DataStoreRead',dsAccess,'Position',[50,180,90,220]);
            set_param(dsAccess,'DataStoreName',aElement);
        end

        add_block('built-in/Argout',[aFcnBlk,'/aOut'],...
        'ArgumentName','aOut',...
        'OutDataTypeStr',dataTypeStr,...
        'Position',[190,193,220,207]);
        add_line(aFcnBlk,[aElement,'/1'],'aOut/1','autorouting','on');
    else
        clsInfo=icmObj.fCandidateInfo(aCurrClsIdx);

        elements=clsInfo.MemberVars;
        numElements=length(elements);

        minY=180;
        maxY=100*numElements+120;
        centerY=(minY+maxY)/2;


        add_block('built-in/BusCreator',[aFcnBlk,'/BusCreator'],...
        'OutDataTypeStr',['Bus: ',clsInfo.Class],...
        'Inputs',num2str(numElements),...
        'Position',[190,centerY-20*numElements,200,centerY+20*numElements]);

        add_block('built-in/Argout',[aFcnBlk,'/aOut'],...
        'ArgumentName','aOut',...
        'OutDataTypeStr',['Bus: ',aBusTypeStr],...
        'Position',[290,centerY-7,320,centerY+7]);

        add_line(aFcnBlk,'BusCreator/1','aOut/1','autorouting','on');

        for eIdx=1:numElements
            dsAccess=[aFcnBlk,'/',elements(eIdx).Name];
            dataTypeStr=elements(eIdx).DataType;
            if contains(dataTypeStr,'Bus: ')&&isKey(icmObj.fIcmCls2IdxMap,['icm_',dataTypeStr(6:end)])
                fcnPrototype=get_param(['icm_',dataTypeStr(6:end),'/getAll'],'FunctionPrototype');
                fcnPrototype=strrep(fcnPrototype,['= getAll'],['= ',elements(eIdx).Name,'.getAll']);
                add_block('built-in/FunctionCaller',dsAccess,'FunctionPrototype',fcnPrototype,'Position',[50,100*eIdx+80,90,100*eIdx+120]);
            else
                add_block('built-in/DataStoreRead',dsAccess,'Position',[50,100*eIdx+80,90,100*eIdx+120]);
                set_param(dsAccess,'DataStoreName',elements(eIdx).Name);

            end
            add_line(aFcnBlk,[elements(eIdx).Name,'/1'],['BusCreator/',num2str(eIdx)],'autorouting','on');
        end
    end
end

function addDataStoreWrite(icmObj,aCurrClsIdx,aFcnBlk,aElement,aDataTypeStr,aBusTypeStr)
    if~strcmpi(aElement,'@')
        add_block('built-in/Argin',[aFcnBlk,'/aIn'],...
        'ArgumentName','aIn',...
        'OutDataTypeStr',aDataTypeStr,...
        'Position',[50,193,80,207]);
        dsAccess=[aFcnBlk,'/',aElement];

        dataTypeStr=aDataTypeStr;

        if contains(dataTypeStr,'Bus: ')&&isKey(icmObj.fIcmCls2IdxMap,['icm_',dataTypeStr(6:end)])
            fcnPrototype=get_param(['icm_',dataTypeStr(6:end),'/setAll'],'FunctionPrototype');
            fcnPrototype=[aElement,'.',fcnPrototype];
            add_block('built-in/FunctionCaller',dsAccess,'FunctionPrototype',fcnPrototype,'Position',[350,180,390,220]);
        else
            add_block('built-in/DataStoreWrite',dsAccess,'Position',[350,180,390,220]);
            set_param(dsAccess,'DataStoreName',aElement);
        end

        add_line(aFcnBlk,'aIn/1',[aElement,'/1'],'autorouting','on');
    else

        clsInfo=icmObj.fCandidateInfo(aCurrClsIdx);

        elements=clsInfo.MemberVars;
        numElements=length(elements);

        minY=180;
        maxY=100*numElements+120;
        centerY=(minY+maxY)/2;

        outSigStr=[];
        for eIdx=1:numElements-1
            outSigStr=[outSigStr,elements(eIdx).Name,','];
        end
        outSigStr=[outSigStr,elements(end).Name];

        add_block('built-in/BusSelector',[aFcnBlk,'/BusSelector'],...
        'OutputSignals',outSigStr,...
        'Position',[190,centerY-20*numElements,200,centerY+20*numElements]);

        add_block('built-in/ArgIn',[aFcnBlk,'/aIn'],...
        'ArgumentName','aIn',...
        'OutDataTypeStr',['Bus: ',aBusTypeStr],...
        'Position',[100,centerY-7,130,centerY+7]);

        add_line(aFcnBlk,'aIn/1','BusSelector/1','autorouting','on');

        for eIdx=1:numElements
            dsAccess=[aFcnBlk,'/',elements(eIdx).Name];
            dataTypeStr=elements(eIdx).DataType;
            if contains(dataTypeStr,'Bus: ')&&isKey(icmObj.fIcmCls2IdxMap,['icm_',dataTypeStr(6:end)])
                fcnPrototype=get_param(['icm_',dataTypeStr(6:end),'/setAll'],'FunctionPrototype');
                fcnPrototype=[elements(eIdx).Name,'.',fcnPrototype];
                add_block('built-in/FunctionCaller',dsAccess,'FunctionPrototype',fcnPrototype,'Position',[350,100*eIdx+80,390,100*eIdx+120]);
            else
                add_block('built-in/DataStoreWrite',dsAccess,'Position',[350,100*eIdx+80,390,100*eIdx+120]);
                set_param(dsAccess,'DataStoreName',elements(eIdx).Name);

            end
            add_line(aFcnBlk,['BusSelector/',num2str(eIdx)],[elements(eIdx).Name,'/1'],'autorouting','on');
        end
    end
end
