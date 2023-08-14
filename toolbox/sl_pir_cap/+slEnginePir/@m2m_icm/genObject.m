function numObj=genObject(this,aClsIdx,aObjIdx,aNumCls,aNumObj,aThisPortMap)



    numObj=aNumObj;
    clsInfo=this.fCandidateInfo(aClsIdx);
    objectInfo=clsInfo.Objects(aObjIdx);

    if clsInfo.isExcluded||objectInfo.isExcluded||objectInfo.isNestedObj
        return;
    end

    numObj=numObj+1;
    xformedObjInfo=struct('ObjMdlRef',[],'FcnCalls',[]);

    traceBefore={};
    traceAfter={};

    clsName=['icm_',clsInfo.Class];




    thisInMap=containers.Map('KeyType','char','ValueType','double');
    thisOutMap=containers.Map('KeyType','char','ValueType','double');
    initValMap=containers.Map('KeyType','char','ValueType','any');


    if~isempty(objectInfo.InitVal)
        if clsInfo.IsaBus
            fieldName=fieldnames(objectInfo.InitVal);
            for vIdx=1:length(fieldName)
                try
                    initValMap(['initVal_',fieldName{vIdx}])=eval(['objectInfo.InitVal.',fieldName{vIdx}]);
                catch ME
                    error(ME.message);
                end
            end
        else
            initValMap('initVal_v')=0;
        end
    end
    if~isempty(objectInfo.ConstVal)
        fieldName=fieldnames(objectInfo.ConstVal);
        for vIdx=1:length(fieldName)
            initValMap(fieldName{vIdx})=eval(['objectInfo.ConstVal.',fieldName{vIdx}]);
        end
    end


    objectInfo.clsName=clsName;
    objectInfo.prefix=this.fPrefix;
    [objName,traceBefore,traceAfter]=...
    insertClassInstance(objectInfo,traceBefore,traceAfter,initValMap);
    sid=Simulink.ID.getSID(objName);
    xformedObjInfo.ObjMdlRef=sid;
    this.fIcmObj2IdxMap(sid)=[aNumCls,numObj];


    objName=get_param(objName,'Name');
    xformedObjInfo.FcnCalls={};
    for fIdx=1:length(objectInfo.FcnCalls)
        fcnCall=objectInfo.FcnCalls(fIdx);
        fcnCall.clsName=clsName;
        fcnCall.objName=objName;
        fcnCall.prefix=this.fPrefix;
        [fcnCaller,traceBefore,traceAfter]=...
        replaceLibBlkwithFcnCaller(this,fcnCall,traceBefore,traceAfter,aThisPortMap);
        sid=Simulink.ID.getSID(fcnCaller);
        xformedObjInfo.FcnCalls=[xformedObjInfo.FcnCalls;{sid}];
        this.fIcmObj2IdxMap(sid)=[aNumCls,numObj];
    end


    GetSetCalls=struct('clsName',clsName,'objName',objName,'prefix',this.fPrefix,...
    'GetCalls',[],'SetCalls',[]);
    GetSetCalls.GetCalls=[{},objectInfo.GetCalls];
    GetSetCalls.SetCalls=[{},objectInfo.SetCalls];
    [fcnCallers,traceBefore,traceAfter]=...
    replaceDSeadRWriteWithGetSet(this,GetSetCalls,traceBefore,traceAfter,this.fIsForBosch);
    xformedObjInfo.FcnCalls=[xformedObjInfo.FcnCalls;fcnCallers];
    for fIdx=1:length(fcnCallers)
        sid=Simulink.ID.getSID(fcnCallers{fIdx});
        this.fIcmObj2IdxMap(sid)=[aNumCls,numObj];
    end


    if~(isempty(traceBefore)&&isempty(traceAfter))
        traceability=struct('Before',[],'After',[]);
        traceability.Before=traceBefore;
        traceability.After=traceAfter;
        this.fTraceabilityMap=[this.fTraceabilityMap,traceability];
    end
    this.fXformedInfo(end).Objects=[this.fXformedInfo(end).Objects,xformedObjInfo];

end

function[objName,traceBefore,traceAfter]=...
    insertClassInstance(aObjectInfo,aTraceBefore,aTraceAfter,aInitValMap)
    traceBefore=aTraceBefore;
    traceAfter=aTraceAfter;


    if~isempty(aObjectInfo.DSM)

        traceBefore=[traceBefore;aObjectInfo.DSM];
        dsmName=[aObjectInfo.prefix,getfullname(aObjectInfo.DSM)];
        paramObj=get_param(dsmName,'Object');
        params=paramObj.get;
        objName=dsmName;

        delete_block(dsmName);
        add_block('built-in/ModelReference',dsmName,...
        'Position',params.Position,...
        'ModelName',aObjectInfo.clsName);
        set_param(dsmName,'SimulationMode','Normal');

        modelArguments=get_param(dsmName,'ParameterArgumentNames');
        modelArg=strsplit(modelArguments,',');
        modelArgVals=[];
        for aIdx=1:length(modelArg)
            modelArgStr=convertInitVal2ArgStr(aInitValMap(modelArg{aIdx}));
            modelArgVals=[modelArgVals,modelArgStr];%#ok
            if aIdx<length(modelArg)
                modelArgVals=[modelArgVals,','];%#ok
            end
        end
        set_param(dsmName,'ParameterArgumentValues',modelArgVals);
        traceAfter=[traceAfter;Simulink.ID.getSID(dsmName)];
    else
        fcnCalls={aObjectInfo.FcnCalls.LinkedSS};

        pathLen=-1;
        topMostIdx=0;
        for fIdx=1:length(fcnCalls)
            path=get_param(fcnCalls{fIdx},'Parent');
            if pathLen<0||pathLen>length(path)
                topMostIdx=fIdx;
                pathLen=length(path);
            end
        end
        instPath=get_param(fcnCalls{topMostIdx},'Parent');
        maskObj=Simulink.Mask.get(fcnCalls{topMostIdx});
        instName=['icmInst_',maskObj.Parameters.Value];
        objName=[aObjectInfo.prefix,instPath,'/',instName];


        add_block('built-in/ModelReference',objName,...
        'ModelName',aObjectInfo.clsName,...
        'SimulationMode','Normal');
        num=0;
        while~isempty(find_system([aObjectInfo.prefix,instPath],'SearchDepth',1,'Position',[50,50+num*100,150,(num+1)*100]))
            num=num+1;
        end
        set_param(objName,'Position',[50,50+num*100,150,(num+1)*100]);

        modelArguments=get_param(objName,'ParameterArgumentNames');
        modelArg=strsplit(modelArguments,',');
        modelArgVals=[];
        for aIdx=1:length(modelArg)
            modelArgVals=[modelArgVals,num2str(aInitValMap(modelArg{aIdx}))];%#ok
            if aIdx<length(modelArg)
                modelArgVals=[modelArgVals,','];%#ok
            end
        end
        set_param(objName,'ParameterArgumentValues',modelArgVals);
        traceAfter=[traceAfter;Simulink.ID.getSID(objName)];
    end
end

function argStr=convertInitVal2ArgStr(aInitVal)
    if isa(aInitVal,'struct')
        argStr='struct(';
        structFields=fields(aInitVal);
        for fIdx=1:length(structFields)
            argStr=[argStr,'''',structFields{fIdx},''', '...
            ,convertInitVal2ArgStr(eval(['aInitVal.',structFields{fIdx},'']))];
            argStr=[argStr,', '];
        end
        argStr=[argStr(1:end-2),')'];
    else
        if isfi(aInitVal)
            argStr=aInitVal.tostring;
        else
            dataType=class(aInitVal);
            sizeofVal=size(aInitVal);
            if sizeofVal(1)>1||sizeofVal(2)>1
                argStr=[dataType,'(['];
                for yIdx=1:sizeofVal(1)
                    for xIdx=1:sizeofVal(2)
                        argStr=[argStr,num2str(double(aInitVal(yIdx,xIdx))),' '];
                    end
                    argStr=[argStr,';'];
                end
                argStr=[argStr,'])'];
            else
                argStr=[dataType,'(',num2str(double(aInitVal)),')'];
            end
        end
    end
end

function[fcnCallerBlk,traceBefore,traceAfter]=...
    replaceLibBlkwithFcnCaller(aM2mObj,aFcnCall,aTraceBefore,aTraceAfter,aThisPortMap)
    traceBefore=aTraceBefore;
    traceAfter=aTraceAfter;
    linkedSS=Simulink.ID.getSID([aFcnCall.prefix,getfullname(aFcnCall.LinkedSS)]);
    traceBefore=[traceBefore;aFcnCall.LinkedSS];
    paramObj=get_param(linkedSS,'object');
    referenceBlock=get_param(aFcnCall.LinkedSS,'ReferenceBlock');
    params=paramObj.get;


    if~isempty(aFcnCall.This)
        thisIOsIdx=aThisPortMap(referenceBlock);
        lineHandles=params.LineHandles;

        thisInLine=lineHandles.Inport(thisIOsIdx(1));
        thisInSrc=get_param(thisInLine,'SrcBlockHandle');
        delete_line(thisInLine);
        delete_block(thisInSrc);

        thisOutLine=lineHandles.Outport(thisIOsIdx(2));
        thisOutDst=get_param(thisOutLine,'DstBlockHandle');
        delete_line(thisOutLine);
        delete_block(thisOutDst);
    end


    refBlock=strsplit(referenceBlock,'/');
    fcnName=strrep(char(refBlock(end)),' ','');
    fcnBlkName=char(refBlock(end));
    fcnCallerBlk=[params.Path,'/Caller_',params.Name];
    if isempty(aFcnCall.This)
        delete_block(linkedSS);
    end
    add_block('built-in/FunctionCaller',fcnCallerBlk,'Position',params.Position,'Tag',params.Tag);
    if isKey(aM2mObj.fSS2FcnCallMap,params.Parent)
        aM2mObj.fSS2FcnCallMap(params.Parent)=[aM2mObj.fSS2FcnCallMap(params.Parent),{fcnCallerBlk}];
    else
        aM2mObj.fSS2FcnCallMap(params.Parent)={fcnCallerBlk};
    end
    traceAfter=[traceAfter;Simulink.ID.getSID(fcnCallerBlk)];


    memberFcn=[aFcnCall.clsName,'/',fcnBlkName];
    fcnPrototype=get_param(memberFcn,'FunctionPrototype');
    if contains(fcnPrototype,'=')
        fcnPrototype=strrep(fcnPrototype,['= ',fcnName],['= ',aFcnCall.objName,'.',fcnName]);
    else
        fcnPrototype=[aFcnCall.objName,'.',fcnPrototype];
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


    if~isempty(aFcnCall.This)
        rewireFcnCallerBlk(aM2mObj,fcnCallerBlk,params,aThisPortMap(referenceBlock));
        delete_block(linkedSS);
    end
end

function[fcnCallers,traceBefore,traceAfter]=...
    replaceDSeadRWriteWithGetSet(aM2mObj,aGetSetCalls,aTraceBefore,aTraceAfter,aIsForBosch)

    fcnCallers={};
    traceBefore=aTraceBefore;
    traceAfter=aTraceAfter;
    for cIdx=1:length(aGetSetCalls.GetCalls)
        traceBefore=[traceBefore;aGetSetCalls.GetCalls{cIdx}];%#ok
        dsr=[aGetSetCalls.prefix,getfullname(aGetSetCalls.GetCalls{cIdx})];
        paramObj=get_param(dsr,'object');
        params=paramObj.get;
        if isempty(params.DataStoreElements)&&...
            strcmpi(get_param(params.Parent,'ReferenceBlock'),"ASCET2SimulinkLib/Read Variable")
            fcnName='getAll';
            A2SReadVar=params.Parent;
            paramObj=get_param(A2SReadVar,'object');
            params=paramObj.get;
            delete_block(A2SReadVar);
        else
            memberVar=params.DataStoreElements(length(params.DataStoreName)+2:end);
            fcnName=['getVar_',memberVar];
            delete_block(dsr);
        end


        fcnCallerBlk=[params.Parent,'/',params.Name];
        add_block('built-in/FunctionCaller',fcnCallerBlk,'Position',params.Position,'Tag',params.Tag);
        if isKey(aM2mObj.fSS2FcnCallMap,params.Parent)
            aM2mObj.fSS2FcnCallMap(params.Parent)=[aM2mObj.fSS2FcnCallMap(params.Parent),{fcnCallerBlk}];
        else
            aM2mObj.fSS2FcnCallMap(params.Parent)={fcnCallerBlk};
        end
        traceAfter=[traceAfter;Simulink.ID.getSID(fcnCallerBlk)];%#ok


        memberFcn=[aGetSetCalls.clsName,'/',fcnName];
        fcnPrototype=get_param(memberFcn,'FunctionPrototype');
        fcnPrototype=strrep(fcnPrototype,['= ',fcnName],['= ',aGetSetCalls.objName,'.',fcnName]);
        set_param(fcnCallerBlk,'FunctionPrototype',fcnPrototype);


        findEqual=strfind(fcnPrototype,'=');
        outputArg=fcnPrototype(1:findEqual-1);
        outputArg=strrep(outputArg,' ','');
        dataType=get_param([memberFcn,'/',outputArg],'OutDataTypeStr');
        outArgSpec=aM2mObj.getBasicNumericType(dataType,fcnCallerBlk);

        fcnCallers=[fcnCallers;{Simulink.ID.getSID(fcnCallerBlk)}];%#ok
    end


    for cIdx=1:length(aGetSetCalls.SetCalls)
        traceBefore=[traceBefore;aGetSetCalls.SetCalls{cIdx}];%#ok
        dsw=[aGetSetCalls.prefix,getfullname(aGetSetCalls.SetCalls{cIdx})];
        paramObj=get_param(dsw,'object');
        params=paramObj.get;
        delete_block(dsw);
        memberVar=params.DataStoreElements(length(params.DataStoreName)+2:end);
        fcnName=['setVar_',memberVar];
        fcnCallerBlk=[params.Parent,'/',aGetSetCalls.objName,'.',fcnName];
        add_block('built-in/FunctionCaller',fcnCallerBlk,'Position',params.Position,'Tag',params.Tag);
        if isKey(aM2mObj.fSS2FcnCallMap,params.Parent)
            aM2mObj.fSS2FcnCallMap(params.Parent)=[aM2mObj.fSS2FcnCallMap(params.Parent),{fcnCallerBlk}];
        else
            aM2mObj.fSS2FcnCallMap(params.Parent)={fcnCallerBlk};
        end
        traceAfter=[traceAfter;Simulink.ID.getSID(fcnCallerBlk)];%#ok


        memberFcn=[aGetSetCalls.clsName,'/',fcnName];
        fcnPrototype=get_param(memberFcn,'FunctionPrototype');
        fcnPrototype=[aGetSetCalls.objName,'.',fcnPrototype];%#ok
        set_param(fcnCallerBlk,'FunctionPrototype',fcnPrototype);


        frontParenthesis=strfind(fcnPrototype,'(');
        BackParenthesis=strfind(fcnPrototype,')');
        inputArg=fcnPrototype(frontParenthesis+1:BackParenthesis-1);
        inputArg=strrep(inputArg,' ','');
        dataType=get_param([memberFcn,'/',inputArg],'OutDataTypeStr');
        inArgSpec=aM2mObj.getBasicNumericType(dataType,fcnCallerBlk);

        fcnCallers=[fcnCallers;{Simulink.ID.getSID(fcnCallerBlk)}];%#ok
    end
end
































function rewireFcnCallerBlk(aM2mObj,aFcnCallerBlk,aParams,aThisIOsIdx)
    currSys=get_param(aFcnCallerBlk,'Parent');
    aM2mObj.fRemovedInputLines=containers.Map('KeyType','double','ValueType','any');
    aM2mObj.fRemovedOutputLines=containers.Map('KeyType','double','ValueType','any');

    for lIdx=1:length(aParams.LineHandles.Inport)
        if lIdx~=aThisIOsIdx(1)&&aParams.LineHandles.Inport(lIdx)>0
            lineObj=get_param(aParams.LineHandles.Inport(lIdx),'object');
            SrcPortHandle=lineObj.SrcPortHandle;
            segInfo=lineObj.get;
            delete_line(aParams.LineHandles.Inport(lIdx));
            portHandles=get_param(aFcnCallerBlk,'PortHandles');
            if(lIdx>aThisIOsIdx(1))
                newLIdx=lIdx-1;
            else
                newLIdx=lIdx;
            end
            DstPortHandle=portHandles.Inport(newLIdx);
            aM2mObj.fRemovedInputLines(newLIdx)=segInfo;
            add_line(currSys,SrcPortHandle,DstPortHandle,'autorouting','on');
        end
    end

    for lIdx=1:length(aParams.LineHandles.Outport)
        if lIdx~=aThisIOsIdx(2)&&aParams.LineHandles.Outport(lIdx)>0
            lineObj=get_param(aParams.LineHandles.Outport(lIdx),'object');
            DstPortHandle=lineObj.DstPortHandle;
            segInfo=lineObj.get;
            delete_line(aParams.LineHandles.Outport(lIdx));
            portHandles=get_param(aFcnCallerBlk,'PortHandles');
            if(lIdx>aThisIOsIdx(2))
                newLIdx=lIdx-1;
            else
                newLIdx=lIdx;
            end
            SrcPortHandle=portHandles.Outport(newLIdx);
            aM2mObj.fRemovedOutputLines(newLIdx)=segInfo;
            for hIdx=1:length(DstPortHandle)
                add_line(currSys,SrcPortHandle,DstPortHandle(hIdx),'autorouting','on');
            end
        end
    end

    lineHandles=get_param(aFcnCallerBlk,'LineHandles');
    pIdxes=keys(aM2mObj.fRemovedInputLines);
    for pIdx=1:length(pIdxes)
        newSeg=get_param(lineHandles.Inport(pIdxes{pIdx}),'object');
        aM2mObj.setSegmentParam(newSeg,aM2mObj.fRemovedInputLines(pIdxes{pIdx}));
    end

    pIdxes=keys(aM2mObj.fRemovedOutputLines);
    for pIdx=1:length(pIdxes)
        newSeg=get_param(lineHandles.Outport(pIdxes{pIdx}),'object');
        aM2mObj.setSegmentParam(newSeg,aM2mObj.fRemovedOutputLines(pIdxes{pIdx}));
    end
end
