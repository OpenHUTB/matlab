function[out1,varargout]=custom_logger_lib(action,in1,in2,in3,in4,varargin)
    persistent pIdx uniqueTypes mappingInfo
    if isempty(pIdx)
        pIdx=uint32(2);
        mappingInfo='';
    end


    switch action
    case 'registerTypes'

        varargout{1}=[];
        out1=[];

        typeList=unique(strsplit(in1,'<>'));

        t=getSampleTypeInfo();
        for ii=1:length(typeList)
            currTypeStr=typeList{ii};
            if~isempty(currTypeStr)
                t=[t,parseType(currTypeStr)];
            end
        end
        t(1)=[];

        uniqueTypes=t;
    case 'registerlogIdxIDMapping'

        varargout{1}=[];
        out1=[];
        mappingInfo=in1;
    case 'fetchMappingInfo'
        out1=mappingInfo;
        mappingInfo='';
    case 'fetchUniqueTypes'

        out1=[];
        fieldNs=fieldnames(uniqueTypes);
        typeDescLen=length(fieldNs);
        varargout=cell(1,typeDescLen);
        varargout{1}={uniqueTypes.(fieldNs{1})};
        varargout{2}={uniqueTypes.(fieldNs{2})};
        for ii=3:typeDescLen
            varargout{ii}=[uniqueTypes.(fieldNs{ii})];
        end
    case 'getNumTypes'
        out1=length(uniqueTypes);
    case 'getDimensions'

        out1=uniqueTypes(in1).Dimension;
    case 'getVarDimInfo'

        out1=(Inf==uniqueTypes(in1).Dimension);
    case 'getExampleVal'


        typeInfo=uniqueTypes(in1);

        [out1,varargout{1}]=getExampleVal(typeInfo.Typename,typeInfo.Dimension,typeInfo.Complexity,typeInfo.Numerictype,typeInfo.Fimath,typeInfo.FieldTypesInfo);
    case 'get_all_loggable_expr_info'
        mexName=in1;


        [~,~,indexMappingInfo,~]=safeInvokeHiddenEntryPoints(mexName,'customFetchLoggedData');
        exprMappingInfo=parseFunctionInfo(indexMappingInfo);
        out1=exprMappingInfo;
    case 'get_logged_data'
        mexName=in1;






        [dataBuffer,dataInfo,indexMappingInfo,numLoggedExprs]=feval(mexName,'customFetchLoggedData');
        exprMappingInfo=parseFunctionInfo(indexMappingInfo);
        formattedData=buildData(exprMappingInfo,dataInfo,dataBuffer,numLoggedExprs);
        out1=formattedData;
    case 'enable_location_logging_for_functions'
        mexName=in1;


        fcnNames=strsplit(in2,',','CollapseDelimiters',false);
        fullScriptPaths=strsplit(in3,',','CollapseDelimiters',false);
        varsToLogStrs=strsplit(in4,',','CollapseDelimiters',false);
        [~,~,indexMappingInfo,~]=feval(mexName,'customFetchLoggedData');
        evalc('clearInstrumentationResults(mexName);');
        exprMappingInfo=parseFunctionInfo(indexMappingInfo);

        indicesToLog=[];
        assert(length(fcnNames)==length(fullScriptPaths));
        for ii=1:length(fcnNames)
            fcnName=fcnNames{ii};
            [~,fileName,~]=fileparts(fullScriptPaths{ii});
            varsToLogStr=varsToLogStrs{ii};
            if isempty(strtrim(varsToLogStr))
                varsToLog={};
            else
                varsToLog=strsplit(varsToLogStr,'<>');
            end

            interestingFcns=exprMappingInfo(strcmp({exprMappingInfo.FunctionName},fcnName));


            if isempty(interestingFcns)

                for kk=1:length(exprMappingInfo)
                    exprMapInfo=exprMappingInfo(kk);
                    if exprMapInfo.HasSpecialization...
                        &&strcmp([exprMapInfo.FunctionName,'_s',num2str(exprMapInfo.SpecializationNumber)],fcnName)
                        interestingFcns(end+1)=exprMapInfo;%#ok<AGROW>
                    end
                end
            end




            [~,fileNames,~]=cellfun(@(in)fileparts(in),{interestingFcns.FunctionPath},'UniformOutput',false);
            interestingFcns=interestingFcns(strcmp(fileNames,fileName));


            indices=cellfun(@(v)strcmp({interestingFcns.ExprId},v),varsToLog,'UniformOutput',false);
            consolIndices=[];
            for mm=1:length(indices)
                if 1==mm
                    consolIndices=indices{mm};
                else
                    consolIndices=consolIndices|indices{mm};
                end
            end
            interestingFcns3=interestingFcns(consolIndices);
            indicesToLog=[indicesToLog,cellfun(@(x)str2double(x),{interestingFcns3.staticIdx})];%#ok<AGROW>
        end

        maxIdx=max(indicesToLog);

        vals=false(1,maxIdx+1);

        vals(indicesToLog)=true;
        f2fCustomCoderEnableLogState(vals);
        out1=vals;
    case 'enable_all_locations_logging'

        instrumentedExprs=100;

        vals=true(1,instrumentedExprs);
        f2fCustomCoderEnableLogState(vals);
    otherwise
        error(['invalid action ',action]);
    end
end


function varargout=safeInvokeHiddenEntryPoints(mexName,epName)
    varargout=cell(1,nargout);
    [varargout{:}]=feval(mexName,epName);


    evalc('clearInstrumentationResults(mexName);');
end

function S=getSampleExprInfo()
    S.FunctionName='';
    S.FunctionPath='';
    S.ExprId='';
    S.TypeInfo=getSampleTypeInfo();
end

function Ti=getSampleTypeInfo()
    Ti=LogTypeInfo();
end

function out=getDynamicMatrixPrefix()
    out='^(dynamic )?matrix ((?:-?\d+\??x)*-?\d+\??)';
end



function t=parseType(typeStr)
    [tokens,pos]=regexp(typeStr,[getDynamicMatrixPrefix(),' (struct .+)'],'tokens');
    if 1==pos


        t=parseStructType(tokens{1}{3},9);
        x=cellfun(@(x)str2double(x),(strsplit(tokens{1}{2},'x')),'UniformOutput',true);
        if 1==length(x)&&0==x


            t.Dimension=[0,1];
        else
            t.Dimension=sanitizeDimension(x);
        end
    elseif length(typeStr)>=6&&strcmp(typeStr(1:6),'struct')
        t=parseStructType(typeStr,9);
    else
        t=parseOtherTypes(typeStr);
    end
end



function t=parseOtherTypes(inTypeStr)
    typeStr=inTypeStr(1:end);



    [matches,~]=regexp(typeStr,'^(fixpt )?(dynamic )?(matrix (-?\d+\??x)*-?\d+\?? )?(complex )?(char|single|logical|double|u?int(8|16|32|64)|(u|s)fix\d+_En?\d+|(u|s)fix\d+)','tokens','once');

    if isempty(matches)
        t=[];
        return;
    end

    t=getSampleTypeInfo();

    isFixpt=~isempty(matches{1});
    dynamicPart=matches{2};
    matrixPart=matches{3};
    if~isempty(dynamicPart)



    end

    if~isempty(matrixPart)



        d=strsplit(matrixPart,' ');
        x=cellfun(@(x)str2double(x),(strsplit(d{2},'x')),'UniformOutput',true);
        t.Dimension=sanitizeDimension(x);
    else

        t.Dimension=[1,1];
    end
    if isempty(matches{4})
        t.Complexity=false;
    else
        t.Complexity=true;
    end

    baseType=matches{5};
    if isFixpt
        t.Typename='embedded.fi';
        t.Numerictype=numerictype(baseType);
        if regexp(baseType,'(u)?int.')
            t=createFixedPointClone(t);
        end
    else
        t.Typename=baseType;
    end

    if false&&1==regexp(baseType,'(u)?int.')



        tmp=createFixedPointClone(t);
        t(end+1)=tmp;
    end
end

function dim=sanitizeDimension(inDim)
    inDim(isnan(inDim))=Inf;
    if 1==length(inDim)

        dim=[inDim,1];
    else
        dim=inDim;
    end
end


function tmp=createFixedPointClone(t)
    tmp=t.copy();
    switch(t.Typename)
    case 'int8'
        tmp.Numerictype=numerictype(1,8,0);
    case 'uint8'
        tmp.Numerictype=numerictype(0,8,0);
    case 'int16'
        tmp.Numerictype=numerictype(1,16,0);
    case 'uint16'
        tmp.Numerictype=numerictype(0,16,0);
    case 'int32'
        tmp.Numerictype=numerictype(1,32,0);
    case 'uint32'
        tmp.Numerictype=numerictype(0,32,0);
    case 'int64'
        tmp.Numerictype=numerictype(1,64,0);
    case 'uint64'
        tmp.Numerictype=numerictype(0,64,0);
    end
    tmp.Typename='embedded.fi';
end

function[t,currIter]=parseStructType(typeStr,currIter)


    t=getSampleTypeInfo();
    t.Typename='struct';
    t.Dimension=[1,1];
    t.Complexity=false;
    [t.FieldTypesInfo,currIter]=parseStructFields(typeStr,currIter);
end

function[t,currIter]=parseStructFields(eTypeStr,currIter)

    t=repmat(getSampleTypeInfo(),1,0);

    currField='';
    maxIter=length(eTypeStr);
    currStartPos=currIter;
    while(currIter<=maxIter)
        if eTypeStr(currIter)==','||eTypeStr(currIter)==':'
            currTypeStr='';
        end

        if eTypeStr(currIter)==':'
            currField=strtrim(eTypeStr(currStartPos:currIter-1));
            currStartPos=currIter+1;
        end




        tmpTypeN=strtrim(eTypeStr(currStartPos:currIter-1));
        [matches,tmpIsStructArr]=regexp(tmpTypeN,[getDynamicMatrixPrefix,' struct'],'tokens');
        isNonScalarStruct=~isempty(tmpIsStructArr)&&1==tmpIsStructArr;
        if eTypeStr(currIter)=='{'&&(isNonScalarStruct||strcmp(tmpTypeN,'struct'))



            [fieldTypeInfo,currIter]=parseStructType(eTypeStr,currIter+1);
            fieldTypeInfo.FieldName=currField;


            if isNonScalarStruct
                x=cellfun(@(x)str2double(x),(strsplit(matches{1}{2},'x')),'UniformOutput',true);
                fieldTypeInfo.Dimension=sanitizeDimension(x);
            end
            t(end+1)=fieldTypeInfo;
            if currIter>maxIter

                return;
            end
        end

        currChar=eTypeStr(currIter);
        if currChar==','||currIter==maxIter||currChar=='}'
            if currChar==','||currChar=='}'
                currTypeStr=eTypeStr(currStartPos:currIter-1);
            else
                currTypeStr=eTypeStr(currStartPos:currIter);
            end



            isScalarStruct=length(currTypeStr)>=6&&strcmp(currTypeStr(1:6),'struct');
            tmpIsStructArr=regexp(currTypeStr,'^matrix (?:\dx)*\d+ struct');
            isNonScalarStruct=~isempty(tmpIsStructArr)&&1==tmpIsStructArr;
            if~isScalarStruct&&~isNonScalarStruct
                fieldTypeInfo=parseOtherTypes(currTypeStr);

                if~isempty(fieldTypeInfo)
                    fieldTypeInfo.FieldName=currField;
                    t(end+1)=fieldTypeInfo;
                end
            end

            currStartPos=currIter+1;


            if eTypeStr(currIter)=='}'
                currIter=currIter+1;
                return;
            end
        end

        currIter=currIter+1;
    end

end

function S=parseFunctionInfo(mappingInfo)
    fcnInfos=strsplit(mappingInfo,';');
    S=getExprInfo('','','',0,'',false,'');
    S(1)=[];
    if isempty(mappingInfo)

        return;
    end





    splMap=coder.internal.lib.Map();
    splMapKeyBldr=@(fcnPath,fcnName)[fcnPath,':',fcnName];
    for ii=1:length(fcnInfos)
        fcnInfo=fcnInfos{ii};

        infos=strsplit(fcnInfo,'$$');



        fcnLocInfo=infos{1};
        fcnNamePathC=strsplit(fcnLocInfo,',');
        fcnName=fcnNamePathC{1};
        fcnPath=fcnNamePathC{2};
        splMapKey=splMapKeyBldr(fcnPath,fcnName);
        if~splMap.isKey(splMapKey)
            splMap(splMapKey)=1;
        else
            splMap(splMapKey)=splMap(splMapKey)+1;
        end
    end
    nonSplIndices=cellfun(@(val)val==1,splMap.values);
    splkeys=splMap.keys;
    nonSplKeys=splkeys(nonSplIndices);

    splMap=splMap.remove(nonSplKeys);



    splCountMap=coder.internal.lib.Map();
    cellfun(@(key)splCountMap.add(key,0),splMap.keys);
    for ii=1:length(fcnInfos)
        fcnInfo=fcnInfos{ii};

        infos=strsplit(fcnInfo,'$$');



        fcnLocInfo=infos{1};
        fcnNamePathC=strsplit(fcnLocInfo,',');
        fcnName=fcnNamePathC{1};
        fcnPath=fcnNamePathC{2};
        splMapKey=splMapKeyBldr(fcnPath,fcnName);

        splNum=-1;
        hasSpecialization=splMap.isKey(splMapKey);
        if hasSpecialization
            splCountMap(splMapKey)=splCountMap(splMapKey)+1;
            splNum=splCountMap(splMapKey);
        end

        jj=2;
        while(jj<length(infos))
            if strcmp(infos{jj},'inputs')
                exprType=coder.internal.ComparisonPlotService.INPUT_EXPR;
                jj=jj+1;
                if strcmp(infos{jj},'outputs')

                    continue;
                end
            elseif strcmp(infos{jj},'outputs')
                exprType=coder.internal.ComparisonPlotService.OUTPUT_EXPR;
                jj=jj+1;
            else
                error('unknown expression type');
            end
            exprListInfo=infos{jj};
            exprs=strsplit(exprListInfo,'<>');
            for kk=1:length(exprs)
                exprInfo=exprs{kk};
                if isempty(exprInfo)
                    continue;
                end
                expInfoC=strsplit(exprInfo,',');
                exprID=expInfoC{1};
                exprLogIndex=expInfoC{2};
                S(end+1)=getExprInfo(fcnName,fcnPath,exprID,exprLogIndex,exprType,hasSpecialization,splNum);
            end
            jj=jj+1;
        end
    end
end

function S=getExprInfo(fcnName,fcnPath,exprId,logIdx,exprType,hasSpecialization,splNum)
    S.FunctionName=fcnName;
    S.FunctionPath=fcnPath;
    S.ExprId=exprId;
    S.exprType=exprType;
    S.staticIdx=logIdx;
    S.HasSpecialization=hasSpecialization;
    S.SpecializationNumber=splNum;
end

function formattedData=buildData(exprMappingInfo,dataInfo,dataBuffer,numLoggedExprs)
    numExprsInstrumented=length(exprMappingInfo);


    assert(numLoggedExprs==length(dataInfo)-1);
    formattedData=repmat(getEmptyDataStruct(),1,numLoggedExprs);

    indicesNotUsed=[];
    exprLoggedCnt=1;
    for ii=1:numExprsInstrumented
        exprStaticInfo=exprMappingInfo(ii);

        staticIdx=str2double(exprStaticInfo.staticIdx);
        if staticIdx>length(dataInfo)
            break;
        end
        dynamicIdx=dataInfo(staticIdx);
        if dynamicIdx.ActualIndex==0||dynamicIdx.ActualIndex>length(dataBuffer)
            indicesNotUsed=[indicesNotUsed,exprLoggedCnt];%#ok<AGROW>
            exprLoggedCnt=exprLoggedCnt+1;
            continue;
        end
        data=dataBuffer(dynamicIdx.ActualIndex);

        if isempty(dynamicIdx.FieldNames)
            S=buildExprData(data,exprStaticInfo,ii);
        elseif strcmp(dynamicIdx.FieldNames,'_re:_im')

            rawRealData=dataBuffer(dynamicIdx.ActualIndex);
            realData=castToType(trimData(rawRealData),rawRealData.Class,data.NumericType,data.Fimath);
            rawImgData=dataBuffer(dynamicIdx.ActualIndex+1);
            imgData=castToType(trimData(rawImgData),rawImgData.Class,data.NumericType,data.Fimath);
            loggedData=complex(realData,imgData);
            S=buildExprDataComplex(loggedData,exprStaticInfo,ii,rawRealData.Dims,rawRealData.Varsize);
        elseif strcmp(dynamicIdx.FieldNames(1:6),'struct')
            S=buildStructExprData(dataBuffer,dynamicIdx,exprStaticInfo,ii);
        end

        formattedData(exprLoggedCnt)=S;
        exprLoggedCnt=exprLoggedCnt+1;
    end
    formattedData(indicesNotUsed)=[];
end

function S=buildStructExprData(dataBuffer,dynamicIdx,exprStaticInfo,idx)
    t=dynamicIdx.FieldNames;
    actualIdx=dynamicIdx.ActualIndex;
    loggedData=buildStructLoggedData(dataBuffer,actualIdx,t,1);

    S=getEmptyDataStruct();
    S.FunctionName=exprStaticInfo.FunctionName;
    S.FunctionPath=exprStaticInfo.FunctionPath;
    S.HasFunctionSpecialization=exprStaticInfo.HasSpecialization;
    S.FunctionSpecializationNumber=exprStaticInfo.SpecializationNumber;
    S.ExprId=exprStaticInfo.ExprId;
    S.ExprType=exprStaticInfo.exprType;
    S.Dims=[1,1];
    S.Varsize=0;
    S.LoggedData=loggedData;
    S.idx=idx;
end

function[lData,actualIdx,currIter]=buildStructLoggedData(dataBuffer,actualIdx,structDesc,currIter)





    assert(strcmp(structDesc(currIter:currIter+6),'struct '));

    currIter=currIter+8;

    endIter=length(structDesc);
    currFieldStart=currIter;
    while(currIter<=endIter)
        if structDesc(currIter)=='('
            fieldName=structDesc(currFieldStart:currIter-1);

            if currIter+7<=endIter&&strcmp(structDesc(currIter:currIter+7),'(struct ')
                currIter=currIter+1;
                [lData.(fieldName),actualIdx,currIter]=buildStructLoggedData(dataBuffer,actualIdx,structDesc,currIter);
            elseif currIter+8<=endIter&&strcmp(structDesc(currIter:currIter+8),'(_re:_im)')

                rawRealData=dataBuffer(actualIdx);
                realData=castToType(trimData(rawRealData),rawRealData.Class,rawRealData.NumericType,rawRealData.Fimath);
                rawImgData=dataBuffer(actualIdx+1);
                imgData=castToType(trimData(rawImgData),rawImgData.Class,rawImgData.NumericType,rawImgData.Fimath);
                lData.(fieldName)=complex(realData,imgData);
                actualIdx=actualIdx+2;


                currIter=currIter+9;
            end
            if currIter<=endIter&&(structDesc(currIter)==','||structDesc(currIter)==')')


                if structDesc(currIter)==')'


                    currIter=currIter+1;
                    return
                else

                    currIter=currIter+1;
                end

                currFieldStart=currIter;
            end

        elseif(structDesc(currIter)==','||structDesc(currIter)==')')


            fieldName=structDesc(currFieldStart:currIter-1);
            rawData=dataBuffer(actualIdx);
            lData.(fieldName)=castToType(trimData(rawData),rawData.Class,rawData.NumericType,rawData.Fimath);
            actualIdx=actualIdx+1;
            currFieldStart=currIter+1;
            if structDesc(currIter)==')'








                currIter=currIter+2;
                return;
            end
        end

        currIter=currIter+1;
    end
end

function S=buildExprData(data,exprStaticInfo,idx)
    S=getEmptyDataStruct();
    S.FunctionName=exprStaticInfo.FunctionName;
    S.FunctionPath=exprStaticInfo.FunctionPath;
    S.HasFunctionSpecialization=exprStaticInfo.HasSpecialization;
    S.FunctionSpecializationNumber=exprStaticInfo.SpecializationNumber;
    S.ExprId=exprStaticInfo.ExprId;
    S.ExprType=exprStaticInfo.exprType;
    S.Dims=data.Dims;
    S.Varsize=data.Varsize;
    loggedData=castToType(trimData(data),data.Class,data.NumericType,data.Fimath);
    if~data.Varsize
        S.LoggedData=reshapeLoggedData(loggedData,data.Dims);
    else
        S.LoggedData=loggedData;
    end


    S.idx=idx;
end

function rData=reshapeLoggedData(loggedData,dims)
    numDataPoints=length(loggedData)/prod(dims);

    rDim=dims;
    if length(dims)==2&&any(dims==1)
        if dims(1)==1

            rDim=fliplr(rDim);
            rDim(end)=rDim(end)*numDataPoints;
        else

            rDim(end)=rDim(end)*numDataPoints;
        end
        rData=permute(reshape(loggedData,rDim),fliplr(1:length(dims)));
    elseif length(dims)==2

        rDim(end)=rDim(end)*numDataPoints;
        rData=reshape(loggedData,rDim);
    else

        rDim=fliplr(rDim);
        rDim(end)=rDim(end)*numDataPoints;
        rData=permute(reshape(loggedData,rDim),fliplr(1:length(dims)));
    end
end

function trimmedData=trimData(data)
    trimmedData=data.Data(1:data.DataSize-1);
end

function S=buildExprDataComplex(loggedData,exprStaticInfo,idx,dims,varsize)
    S=getEmptyDataStruct();
    S.FunctionName=exprStaticInfo.FunctionName;
    S.FunctionPath=exprStaticInfo.FunctionPath;
    S.HasFunctionSpecialization=exprStaticInfo.HasSpecialization;
    S.FunctionSpecializationNumber=exprStaticInfo.SpecializationNumber;
    S.ExprId=exprStaticInfo.ExprId;
    S.ExprType=exprStaticInfo.exprType;
    S.Dims=dims;
    S.Varsize=varsize;
    if~varsize
        S.LoggedData=reshapeLoggedData(loggedData,dims);
    else
        S.LoggedData=loggedData;
    end
    S.idx=idx;
end

function S=getEmptyDataStruct()
    S.FunctionName='';
    S.FunctionPath='';
    S.HasFunctionSpecialization=false;
    S.FunctionSpecializationNumber=[];
    S.ExprId='';
    S.ExprType='';
    S.Dims=[];
    S.Varsize=[];
    S.idx=0;
    S.LoggedData=[];
end

function vals=castToType(rawData,typeName,numericType,cfimath)
    switch typeName
    case 'embedded.fi'
        [~,fm]=evalc(cfimath);
        [~,nt]=evalc(numericType);
        intExample=fi2sim(fi(0,nt,fm));
        ints=typecast(rawData,class(intExample));
        rows=size(intExample,1);
        cols=numel(ints)/rows;
        ints=reshape(ints,rows,cols);
        vals=sim2fi(ints,nt);
        vals=setfimath(vals,fm);
    case 'logical'
        vals=logical(rawData);
    case 'char'


        vals=char(typecast(rawData,'uint32'));
    otherwise
        vals=typecast(rawData,typeName);
    end

end