function errMsg=identify(this)



    mdls=[{this.fMdl},this.fRefMdls];
    errMsg=[];
    this.fCandidateInfo=struct('Class',{},'HasThis',{},'IsaBus',{},'MaskParamType',{},'MemberFcns',{},'GetFcns',{},'SetFcns',{},'Objects',{},'MemberVars',{},'ConstVars',{},'isExcluded',{});
    this.fCls2IdxMap=containers.Map('KeyType','char','ValueType','any');
    this.fObj2IdxMap=containers.Map('KeyType','char','ValueType','any');
    currClsLen=0;
    for mIdx=1:length(mdls)
        result=Simulink.SLPIR.ModelXform.ICMAnalysis(mdls{mIdx},int32(this.fIsForBosch));


        [result,fcnCallsToMaskParamMap]=checkNestedMaskParamType(mdls{mIdx},result);


        result=filterCandidatesAccessedByStateFlow(result);






        [result,nestedObj]=preprocessClsDependency(mdls{mIdx},result);
        this.fNestedObj=[this.fNestedObj,nestedObj];

        for cIdx=1:length(result)
            infoIdx=obtainInfoIdx(this,result(cIdx),currClsLen+1);
            busInfo=evalinGlobalScope(mdls{mIdx},result(cIdx).Class);
            if infoIdx==currClsLen+1
                currClsLen=currClsLen+1;

                if result(cIdx).HasThis

                    if isa(busInfo,'Simulink.Bus')
                        this.fCandidateInfo(infoIdx).MemberVars=busInfo.Elements;
                    elseif this.fIsForBosch==2&&(isa(busInfo,'Simulink.AliasType')||isa(busInfo,'Simulink.NumericType'))
                        this.fCandidateInfo(infoIdx).MemberVars=busInfo;
                        this.fCandidateInfo(infoIdx).IsaBus=0;
                    else
                        error('UnSupported MemberVar data type...');
                    end
                else

                    this.fCandidateInfo(infoIdx).ConstVars=busInfo.Elements;
                end
                if~isempty(result(cIdx).MaskParamType)

                    busInfo=evalinGlobalScope(mdls{mIdx},result(cIdx).MaskParamType);
                    this.fCandidateInfo(infoIdx).ConstVars=busInfo.Elements;
                end
            else
                for fIdx=1:length(result(cIdx).MemberFcns)
                    if isempty(find(strcmpi({this.fCandidateInfo(infoIdx).MemberFcns.Fcn},result(cIdx).MemberFcns(fIdx).Fcn),1))
                        this.fCandidateInfo(infoIdx).MemberFcns=unique([this.fCandidateInfo(infoIdx).MemberFcns;result(cIdx).MemberFcns(fIdx)]);
                    end
                end
                this.fCandidateInfo(infoIdx).GetFcns=unique([this.fCandidateInfo(infoIdx).GetFcns;result(cIdx).GetFcns]);
                this.fCandidateInfo(infoIdx).SetFcns=unique([this.fCandidateInfo(infoIdx).SetFcns;result(cIdx).SetFcns]);
            end
            this.fCandidateInfo(infoIdx).GetFcns=unique([this.fCandidateInfo(infoIdx).GetFcns;'@']);
            this.fCandidateInfo(infoIdx).SetFcns=unique([this.fCandidateInfo(infoIdx).SetFcns;'@']);


            currObjLen=length(this.fCandidateInfo(infoIdx).Objects);
            for oIdx=1:length(result(cIdx).Objects)
                idxVal=[infoIdx,currObjLen+oIdx];
                objInfo=result(cIdx).Objects(oIdx);
                objInfo.InitVal=[];
                objInfo.ConstVal=[];
                objInfo.isExcluded=0;
                objInfo.isNestedObj=~isempty(find(objInfo.DSM==this.fNestedObj));
                if result(cIdx).HasThis
                    if isempty(find(result(cIdx).Objects(oIdx).DSM==this.fNestedObj))
                        InitialValue=get_param(result(cIdx).Objects(oIdx).DSM,'InitialValue');

                        objInfo.InitVal=evalinGlobalScope(mdls{mIdx},InitialValue);
                    else

                        objInfo.InitVal=getInitBusStruct(this,mdls{mIdx},result(cIdx).Class);
                    end
                end


                objInfo.DSM=[];
                if result(cIdx).Objects(oIdx).DSM>0
                    dsmSID=Simulink.ID.getSID(result(cIdx).Objects(oIdx).DSM);
                    objInfo.DSM=dsmSID;
                    this.fObj2IdxMap(dsmSID)=idxVal;
                end

                maskParam=[];
                for fIdx=1:length(result(cIdx).Objects(oIdx).FcnCalls)
                    if isempty(maskParam)
                        maskParamStr=get_param(result(cIdx).Objects(oIdx).FcnCalls(fIdx).LinkedSS,'MaskValueString');
                        if isKey(fcnCallsToMaskParamMap,result(cIdx).Objects(oIdx).FcnCalls(fIdx).LinkedSS)
                            maskParam=fcnCallsToMaskParamMap(result(cIdx).Objects(oIdx).FcnCalls(fIdx).LinkedSS);
                        elseif~isempty(maskParamStr)
                            maskParam={maskParamStr};
                        end
                    end


                    linkedSSSID=Simulink.ID.getSID(result(cIdx).Objects(oIdx).FcnCalls(fIdx).LinkedSS);
                    objInfo.FcnCalls(fIdx).LinkedSS=linkedSSSID;
                    this.fObj2IdxMap(linkedSSSID)=idxVal;
                    objInfo.FcnCalls(fIdx).This=[];
                    if(result(cIdx).Objects(oIdx).FcnCalls(fIdx).This>0)
                        objInfo.FcnCalls(fIdx).This=Simulink.ID.getSID(result(cIdx).Objects(oIdx).FcnCalls(fIdx).This);
                    end
                end

                if~isempty(maskParam)
                    busInitVal=evalinGlobalScope(mdls{mIdx},maskParam{1});
                    if isa(busInitVal,'Simulink.Parameter')
                        if length(maskParam)==1
                            objInfo.ConstVal=busInitVal.Value;
                        else
                            busInitValue=busInitVal.Value;
                            initStrToEval=['busInitValue'];
                            for hIdx=1:length(maskParam)-1
                                initStrToEval=[initStrToEval,'.',maskParam{hIdx+1}];
                            end
                            objInfo.ConstVal=eval(initStrToEval);
                        end
                    elseif isa(busInitVal,'Simulink.Signal')
                        objInfo.ConstVal=evalin('base',busInitVal.InitialValue);
                    end
                end

                for fIdx=1:length(result(cIdx).Objects(oIdx).GetCalls)
                    getCallSID=Simulink.ID.getSID(result(cIdx).Objects(oIdx).GetCalls{fIdx});
                    objInfo.GetCalls{fIdx}=getCallSID;
                    this.fObj2IdxMap(getCallSID)=idxVal;
                end
                for fIdx=1:length(result(cIdx).Objects(oIdx).SetCalls)
                    setCallSID=Simulink.ID.getSID(result(cIdx).Objects(oIdx).SetCalls{fIdx});
                    objInfo.SetCalls{fIdx}=setCallSID;
                    this.fObj2IdxMap(setCallSID)=idxVal;
                end
                this.fCandidateInfo(infoIdx).Objects=[this.fCandidateInfo(infoIdx).Objects,objInfo];
            end
        end
    end
    if isempty(errMsg)
        errMsg=this.fCandidateInfo;
    end
end

function tf=isMemberAccessedByStateFlow(aCls)
    tf=false;
    objs=aCls.Objects;
    for oIdx=1:length(objs)
        fcalls=objs(oIdx).FcnCalls;
        for fIdx=1:length(fcalls)
            if fcalls(fIdx).This<0
                continue;
            end
            dsRWs=get_param(fcalls(fIdx).This,'DSReadWriteBlocks');
            for aIdx=1:length(dsRWs)
                if strcmpi(get_param(dsRWs(aIdx).handle,'BlockType'),'SubSystem')
                    tf=true;
                    return;
                end
            end
        end
    end
end


function result=filterCandidatesAccessedByStateFlow(aResult)
    result=aResult;
    cIdxToBeFiltered=[];
    for cIdx=1:length(aResult)
        if isMemberAccessedByStateFlow(aResult(cIdx))
            cIdxToBeFiltered=[cIdxToBeFiltered,cIdx];
        end
    end
    result(cIdxToBeFiltered)='';
end




function[result,nestedObj]=preprocessClsDependency(aMdl,aResult)
    result=[];
    fcnThisDsmMap=containers.Map('KeyType','double','ValueType','any');

    fcnThisDSMs=[];
    for cIdx=1:length(aResult)
        for oIdx=1:length(aResult(cIdx).Objects)
            thisDsmInFcn=[aResult(cIdx).Objects(oIdx).FcnCalls.This];
            fcnThisDSMs=[fcnThisDSMs,thisDsmInFcn];
        end
    end

    nestedObj=[];
    for cIdx=1:length(aResult)
        for oIdx=1:length(aResult(cIdx).Objects)
            if~isempty(find(fcnThisDSMs==aResult(cIdx).Objects(oIdx).DSM,1))
                nestedObj=[nestedObj,aResult(cIdx).Objects(oIdx).DSM];
            end
        end
    end

    while~isempty(aResult)
        leafClsIdx=[];
        allClasses={aResult.Class};
        for cIdx=1:length(aResult)
            isLeaf=1;
            busInfo=evalinGlobalScope(aMdl,aResult(cIdx).Class);
            if isa(busInfo,'Simulink.Bus')
                busElements=busInfo.Elements;
                for eIdx=1:length(busElements)
                    findBusColon=strfind(busElements(eIdx).DataType,'Bus: ');
                    if~isempty(findBusColon)&&findBusColon==1&&...
                        ~isempty(find(strcmpi(busElements(eIdx).DataType(6:end),allClasses)))
                        isLeaf=0;
                        break;
                    end
                end
            end
            if isLeaf
                result=[result,aResult(cIdx)];
                leafClsIdx=[leafClsIdx,cIdx];
            end
        end
        aResult(leafClsIdx)=[];
    end
    aaa=3;























end

function infoIdx=obtainInfoIdx(aM2mObj,aCandCls,aCurrIdx)
    emptyClsInfo=struct('Class',aCandCls.Class,...
    'HasThis',aCandCls.HasThis,...
    'IsaBus',1,...
    'MaskParamType',aCandCls.MaskParamType,...
    'MemberFcns',aCandCls.MemberFcns,...
    'GetFcns',[],...
    'SetFcns',[],...
    'Objects',[],...
    'MemberVars',[],...
    'ConstVars',[],...
    'isExcluded',0);
    emptyClsInfo.GetFcns=aCandCls.GetFcns;
    emptyClsInfo.SetFcns=aCandCls.SetFcns;
    paramType=aCandCls.MaskParamType;
    if isempty(aCandCls.MaskParamType)
        paramType='';
    end
    if isKey(aM2mObj.fCls2IdxMap,aCandCls.Class)
        mapEntry=aM2mObj.fCls2IdxMap(aCandCls.Class);
        if isKey(mapEntry,paramType)
            infoIdx=mapEntry(paramType);
        else
            infoIdx=aCurrIdx;
            mapEntry(paramType)=infoIdx;
            aM2mObj.fCls2IdxMap(aCandCls.Class)=mapEntry;
            aM2mObj.fCandidateInfo=[aM2mObj.fCandidateInfo,emptyClsInfo];
        end
    else
        infoIdx=aCurrIdx;
        mapEntry=containers.Map('KeyType','char','ValueType','double');
        mapEntry(paramType)=infoIdx;
        aM2mObj.fCls2IdxMap(aCandCls.Class)=mapEntry;
        aM2mObj.fCandidateInfo=[aM2mObj.fCandidateInfo,emptyClsInfo];
    end
end

function[result,fcnCallsToMaskParamMap]=checkNestedMaskParamType(aMdl,aPotentialClasses)
    fcnCallsToMaskParamMap=containers.Map('KeyType','double','ValueType','any');
    result=[];
    for cIdx=1:length(aPotentialClasses)
        cls=aPotentialClasses(cIdx);
        if~isempty(cls.MaskParamType)
            result=[result,cls];
            continue;
        end





        for oIdx=1:length(cls.Objects)
            obj=cls.Objects(oIdx);
            maskHiers={};
            for fIdx=1:length(obj.FcnCalls)
                linkedSS=obj.FcnCalls(fIdx).LinkedSS;
                maskVals=get_param(linkedSS,'MaskValues');
                if isempty(maskVals)
                    continue;
                end
                if length(maskVals)>1

                    continue;
                end
                maskHiers=strsplit(maskVals{1},'.');
                nMaskHiers=length(maskHiers);
                if nMaskHiers==1
                    continue;
                end
                for hIdx=1:nMaskHiers-1
                    maskParamName=maskHiers{nMaskHiers-hIdx};
                    parent=get_param(linkedSS,'Parent');
                    maskObj=Simulink.Mask.get(parent);
                    while isempty(maskObj)||~strcmpi(maskObj.Parameters.Name,maskParamName)
                        parent=get_param(parent,'Parent');
                        if isempty(parent)

                        end
                        maskObj=Simulink.Mask.get(parent);
                    end
                    maskHiers{nMaskHiers-hIdx}=maskObj.Parameters.Value;
                end
                fcnCallsToMaskParamMap(linkedSS)=maskHiers;
                busParamAll=evalinGlobalScope(aMdl,maskHiers{1});

                busType=busParamAll.DataType(6:end);
                busInfo=evalinGlobalScope(aMdl,busType);
                for hIdx=1:nMaskHiers-1
                    eIdx=1;
                    while~strcmpi(busInfo.Elements(eIdx).Name,maskHiers{hIdx+1})
                        eIdx=eIdx+1;
                    end
                    busType=busInfo.Elements(eIdx).DataType(6:end);
                    busInfo=evalinGlobalScope(aMdl,busType);
                end
                if~isempty(cls.MaskParamType)&&~strcmpi(cls.MaskParamType,busType)

                end
                cls.MaskParamType=busType;
            end
        end
        result=[result,cls];
    end
end
