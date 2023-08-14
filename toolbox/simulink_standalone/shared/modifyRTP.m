function out_rtp=modifyRTP(in_rtp,varargin)
































    processedArgs=...
    loc_ProcessArguments(in_rtp,varargin{:});

    locRTPParameters=processedArgs.rtpParameters;

    for idx=1:length(processedArgs.newParameterValues)
        locRTPParameters=loc_setOneRTPParam(...
        locRTPParameters,...
        processedArgs.newParameterValues(idx).name,...
        processedArgs.newParameterValues(idx).value...
        );
    end

    out_rtp=loc_ConstructOutput(...
    in_rtp,...
    locRTPParameters,...
    processedArgs.expandFlag,...
    processedArgs.rtpIdx,...
    {processedArgs.newParameterValues.name}...
    );
end





function results=loc_ProcessArguments(in_rtp,varargin)
    results=struct(...
    'rtpIdx',[],...
    'expandFlag',[],...
    'argIdx',[],...
    'rtpParameters',[],...
    'newParameterValues',[]...
    );

    if nargin<2
        error(message('RTW:rsim:modifyRTPInvalidNumberOfArguments'));
    end


    if~isstruct(in_rtp)||~isfield(in_rtp,'parameters')
        error(message(...
        'RTW:rsim:SetRTPParamBadRTP',...
        'the rtp must be a struct with a field named "parameters"')...
        );
    end


    if isnumeric(varargin{1})
        results.rtpIdx=varargin{1};
        if length(results.rtpIdx)>1||results.rtpIdx<1||~isreal(results.rtpIdx)
            error(message('RTW:rsim:SetRTPParamBadIdx'));
        end
        results.argIdx=2;
        results.expandFlag=true;
    else
        results.rtpIdx=1;
        results.argIdx=1;
        results.expandFlag=false;
    end


    if~iscell(in_rtp.parameters)
        results.rtpParameters=in_rtp.parameters;
    else
        if results.rtpIdx>length(in_rtp.parameters)
            results.rtpParameters=in_rtp.parameters{1};
        else
            results.rtpParameters=in_rtp.parameters{results.rtpIdx};
        end
    end


    loc_verifyRTPParametersFormat(results.rtpParameters);



    nvarargin=length(varargin);
    if~(mod(nvarargin-results.argIdx+1,2)==0)
        error(message('RTW:rsim:SetRTPParamBadParamCount'));
    end

    results.newParameterValues=repmat(...
    struct('name',[],'value',[]),...
    1,...
    (nvarargin-results.argIdx+1)/2...
    );

    for idx=1:length(results.newParameterValues)
        paramName=varargin{results.argIdx+2*idx-2};
        paramValue=varargin{results.argIdx+2*idx-1};
        if isempty(paramName)
            error(message('RTW:rsim:SetRTPParamEmptyParameterArgument'));
        elseif~matlab.internal.datatypes.isScalarText(paramName)
            error(message(...
            'RTW:rsim:SetRTPParamNonStringParameterName',...
            paramName)...
            );
        end
        results.newParameterValues(idx)=struct('name',paramName,'value',paramValue);
    end
end



function loc_verifyRTPParametersFormat(rtpParameters)
    rtpIsBad=false;
    reason=[];

    if~isstruct(rtpParameters)
        rtpIsBad=true;
        reason='the rtp must be a struct';
    elseif~isfield(rtpParameters,'dataTypeName')||...
        ~isfield(rtpParameters,'dataTypeId')||...
        ~isfield(rtpParameters,'complex')||...
        ~isfield(rtpParameters,'dtTransIdx')||...
        ~isfield(rtpParameters,'values')||...
        ~isfield(rtpParameters,'map')||...
        ~isfield(rtpParameters,'structParamInfo')
        rtpIsBad=true;
        reason='the rtp does not have the correct format';
    elseif~isempty([rtpParameters.map])
        tempMap=[rtpParameters.map];
        tempMap=tempMap(1);
        if~isfield(tempMap,'Identifier')||...
            ~isfield(tempMap,'ValueIndices')||...
            ~isfield(tempMap,'Dimensions')||...
            ~isfield(tempMap,'FixedPointCellIndex')
            rtpIsBad=true;
            reason='the "map" subfield of the rtp does not have the correct format';
        end
    elseif~isempty([rtpParameters.structParamInfo])
        tempStructParamInfo=[rtpParameters.structParamInfo];
        tempStructParamInfo=tempStructParamInfo(1);
        if~isfield(tempStructParamInfo,'Identifier')||...
            ~isfield(tempStructParamInfo,'ModelParam')||...
            ~isfield(tempStructParamInfo,'BlockPath')||...
            ~isfield(tempStructParamInfo,'CAPIIdx')
            rtpIsBad=true;
            reason='the "structParamInfo" subfield of the rtp does not have the correct format';
        end
    end

    if rtpIsBad
        error(message(...
        'RTW:rsim:SetRTPParamBadRTP',...
        reason)...
        );
    end
end




function out_rtp=loc_ConstructOutput(in_rtp,rtpParameters,expandFlag,rtpIdx,parameterNames)


    out_rtp=in_rtp;

    if~iscell(out_rtp.parameters)
        if expandFlag
            p1=out_rtp.parameters;
            out_rtp.parameters=[];
            out_rtp.parameters{1}=p1;
        else
            out_rtp.parameters=rtpParameters;

            out_rtp=loc_RecordTunedParameters(...
            out_rtp,...
            parameterNames,...
rtpIdx...
            );

            return;
        end
    end

    numsets=length(out_rtp.parameters);
    if rtpIdx>numsets
        for i=(numsets+1):rtpIdx
            out_rtp.parameters{i}=out_rtp.parameters{1};
        end
    end

    out_rtp.parameters{rtpIdx}=rtpParameters;

    out_rtp=loc_RecordTunedParameters(...
    out_rtp,...
    parameterNames,...
rtpIdx...
    );
end




function rtp=loc_RecordTunedParameters(rtp,parameterNames,rtpIdx)
    tunedParameters=struct(...
    'name',[],...
    'transitionIdx',[],...
    'mapIdx',[],...
    'isStruct',[]...
    );

    tunedParameters=repmat(tunedParameters,1,length(parameterNames));

    if iscell(rtp.parameters)
        rtpParameters=rtp.parameters{rtpIdx};
    else
        rtpParameters=rtp.parameters;
    end

    for i=1:length(parameterNames)
        parameterInfo=loc_parseParameterName(parameterNames{i});
        parameterName=parameterInfo.name;

        rtpLocation=loc_FindParameterInRTP(...
        rtpParameters,...
parameterName...
        );

        tunedParameters(i).name=parameterName;
        tunedParameters(i).transitionIdx=rtpLocation.transitionIdx;
        tunedParameters(i).mapIdx=rtpLocation.mapIdx;
        tunedParameters(i).isStruct=rtpLocation.isStruct;
    end

    if isfield(rtp,'internal')&&isfield(rtp.internal,'tunedParameters')
        if length(rtp.internal.tunedParameters)<rtpIdx
            rtp.internal.tunedParameters{rtpIdx}=tunedParameters;
        else
            rtp.internal.tunedParameters{rtpIdx}=[rtp.internal.tunedParameters{rtpIdx},tunedParameters];
        end
    else
        rtp.internal.tunedParameters{rtpIdx}=tunedParameters;
    end
end





function rtpParameters=loc_setOneRTPParam(rtpParameters,parameterName,newValue)
    assert(~isempty(parameterName));
    assert(matlab.internal.datatypes.isScalarText(parameterName));

    variableInfo=loc_parseParameterName(parameterName);
    rtpLocation=loc_FindParameterInRTP(rtpParameters,variableInfo.name);

    if isempty(rtpLocation.transitionIdx)
        error(message('RTW:rsim:SetRTPParamBadIdentifier',parameterName));
    end


    if isa(newValue,'Simulink.Parameter')
        newValue=newValue.Value;
    end

    isStructParam=...
    isstruct(rtpParameters(rtpLocation.transitionIdx).values);

    if isStructParam
        rtpParameters=loc_verifyAndReplaceStructParam(...
        rtpParameters,...
        newValue,...
        rtpLocation.transitionIdx,...
        variableInfo.name,...
        variableInfo.subFieldPath...
        );
    else
        rtpParameterInfo=loc_getRTPTransitionInfo(...
        rtpParameters,...
        rtpLocation.transitionIdx,...
        rtpLocation.mapIdx...
        );

        rtpParameters=loc_verifyAndReplaceNonStructParam(...
        parameterName,...
        rtpParameters,...
        newValue,...
        rtpParameterInfo,...
rtpLocation...
        );
    end
end




function rtpParameterInfo=loc_getRTPTransitionInfo(...
    rtpParameters,...
    transitionIdx,...
mapIdx...
    )

    rtpParameterInfo=struct(...
    'dataType',[],...
    'dimensions',[],...
    'isComplex',false,...
    'isFixedPoint',false,...
    'fixedPointNumericType',[],...
    'fixedPointCellIndex',[]...
    );

    transitionInfo=rtpParameters(transitionIdx);
    map=rtpParameters(transitionIdx).map(mapIdx);

    rtpParameterInfo.dataType=transitionInfo.dataTypeName;

    rtpParameterInfo.dimensions=map.Dimensions;

    rtpParameterInfo.isComplex=transitionInfo.complex;

    rtpParameterInfo.isFixedPoint=...
    iscell(transitionInfo.values)&&...
    ~isempty(transitionInfo.values)&&...
    isa(transitionInfo.values{1},'embedded.fi');

    if rtpParameterInfo.isFixedPoint
        rtpParameterInfo.fixedPointNumericType=...
        transitionInfo.values{1}.numerictype();

        rtpParameterInfo.fixedPointCellIndex=...
        map.FixedPointCellIndex;
    end
end




function variableInfo=loc_parseParameterName(parameterName)
    variableInfo=struct(...
    'name',[],...
    'index',[],...
    'subFieldPath',[]...
    );



    [topStructNameAndIndex,subFieldPath]=strtok(parameterName,'.');
    [variableInfo.name,variableInfo.index]=strtok(topStructNameAndIndex,'(');
    variableInfo.subFieldPath=strcat(variableInfo.index,subFieldPath);
end




function rtpLocation=loc_FindParameterInRTP(rtpParameters,parameterName)
    rtpLocation=struct(...
    'transitionIdx',[],...
    'mapIdx',[],...
    'isStruct',[]...
    );

    isStruct=false;
    foundParameter=false;
    for i=1:length(rtpParameters)
        mapIdx=[];
        if isempty(rtpParameters(i).values)
            continue;
        end
        if isstruct(rtpParameters(i).values)
            assert(...
            ~isempty(rtpParameters(i).structParamInfo)&&...
            isfield(rtpParameters(i).structParamInfo,'Identifier')&&...
            length(rtpParameters(i).structParamInfo)==1...
            );
            rtpStructName=rtpParameters(i).structParamInfo(1).Identifier;
            foundParameter=strcmp(parameterName,rtpStructName);
            isStruct=true;
        else
            if~isempty(rtpParameters(i).map)
                assert(isfield(rtpParameters(i).map,'Identifier'));
                rtpPrmNames={rtpParameters(i).map.Identifier};
                matches=strcmp(rtpPrmNames,parameterName);
                if any(matches)
                    if nnz(matches)>1
                        error(message(...
                        'RTW:rsim:duplicateParametersInRTP',...
                        parameterName)...
                        );
                    end
                    foundParameter=true;
                    mapIdx=find(matches);
                    assert(isscalar(mapIdx));
                end
            else
                continue;
            end
        end
        if foundParameter
            rtpLocation.transitionIdx=i;
            rtpLocation.mapIdx=mapIdx;
            rtpLocation.isStruct=isStruct;
            break;
        end
    end
end




function rtpParameters=loc_verifyAndReplaceNonStructParam(...
    parameterName,...
    rtpParameters,...
    newValue,...
    rtpParameterInfo,...
rtpLocation...
    )






    expectedDataType=rtpParameterInfo.dataType;



    if ischar(newValue)||isstring(newValue)
        originalNewValueForErrorReporting=newValue;
        [newValue,str2numWorked]=str2num(newValue);
        if~str2numWorked
            error(message(...
            'RTW:rsim:modifyRTPCannotConvertString',...
            parameterName,...
originalNewValueForErrorReporting...
            ));
        end
    end

    if strcmpi(expectedDataType,'boolean')

        newValue=uint8(logical(newValue));
    elseif rtpParameterInfo.isFixedPoint

        assert(~isempty(rtpParameterInfo.fixedPoint));
        newValue=fi(newValue,rtpParameterInfo.fixedPointNumericType);
    elseif~isequal(class(newValue),expectedDataType)

        try
            newValue=feval(expectedDataType,newValue);
        catch


            error(message(...
            'RTW:rsim:modifyRTPCouldNotCastNewValue',...
            parameterName,...
            class(newValue),...
            expectedDataType)...
            );
        end
    end


    expectedDimensions=rtpParameterInfo.dimensions;
    actualDimensions=size(newValue);
    if~isequal(expectedDimensions,actualDimensions)
        error(message(...
        'RTW:rsim:SetRTPParamBadValueDimensions',...
        actualDimensions(1),...
        actualDimensions(2),...
        parameterName,...
        expectedDimensions(1),...
        expectedDimensions(2))...
        );
    end


    expectedComplexity=rtpParameterInfo.isComplex;
    actualComplexity=~isreal(newValue);
    if~isequal(expectedComplexity,actualComplexity)
        expectedComplexityString='real';
        actualComplexityString='real';
        if expectedComplexity
            expectedComplexityString='complex';
        else
            actualComplexityString='complex';
        end

        error(message(...
        'RTW:rsim:SetRTPParamBadValueComplexity',...
        parameterName,...
        expectedComplexityString,...
        actualComplexityString)...
        );
    end


    if rtpParameterInfo.isFixedPoint
        assert(...
        ~isempty(rtpParameterInfo.FixedPointCellIndex)&&...
        rtpParameterInfo.FixedPointCellIndex>=0...
        );

        rtpParameters(rtpLocation.transitionIdx).values{rtpParameterInfo.FixedPointCellIndex}=...
        newValue;
    else
        map=rtpParameters(rtpLocation.transitionIdx).map(rtpLocation.mapIdx);
        numElements=prod(actualDimensions);
        fullInd=linspace(map.ValueIndices(1),map.ValueIndices(2),numElements);
        rtpParameters(rtpLocation.transitionIdx).values(fullInd)=newValue(:);
    end
end




function p=loc_verifyAndReplaceStructParam(p,newValue,transitionIdx,structName,subFieldPath)



    assert(isstruct(p(transitionIdx).values));
    currTopStructVal=p(transitionIdx).values;

    try
        currSubfieldVal=loc_retrieveSubfield(currTopStructVal,subFieldPath);
    catch err
        if strcmp(err.identifier,'loc_retrieveSubfield:SomethingHappened')
            fullPath=[structName,subFieldPath];

            error(message(...
            'RTW:rsim:VerifyReplaceStructParamBadSubfield',...
            fullPath,...
            structName)...
            );
        end
    end

    try
        loc_verifyStructParamHelper(currSubfieldVal,newValue);
    catch err
        pathName=structName;
        if~isempty(err.message)
            pathName=[structName,err.message];
        end
        switch err.identifier
        case 'loc_verifyStructParamHelper:StructMismatch'
            error(message(...
            'RTW:rsim:VerifyReplaceStructParamStructMismatch',...
            pathName)...
            );
        case 'loc_verifyStructParamHelper:ClassMismatch'
            error(message(...
            'RTW:rsim:VerifyReplaceStructParamClassMismatch',...
            pathName)...
            );
        case 'loc_verifyStructParamHelper:SizeMismatch'
            error(message(...
            'RTW:rsim:VerifyReplaceStructParamSizeMismatch',...
            pathName)...
            );
        case 'loc_verifyStructParamHelper:fiMismatch'
            error(message(...
            'RTW:rsim:VerifyReplaceStructParamFiMismatch',...
            pathName)...
            );
        case 'loc_verifyStructParamHelper:fieldNameMismatch'
            error(message(...
            'RTW:rsim:VerifyReplaceStructParamFieldNameMismatch',...
            pathName)...
            );
        case 'loc_verifyStructParamHelper:ComplexityMismatch'
            error(message(...
            'RTW:rsim:VerifyReplaceStructParamComplexity',...
            pathName)...
            );
        end
    end

    newStructVal=loc_replaceSubfield(newValue,currTopStructVal,subFieldPath);
    p(transitionIdx).values=newStructVal;
end




function subField=loc_retrieveSubfield(currVal,subFieldPath)
    if isempty(subFieldPath)
        subField=currVal;
    else
        try
            subField=eval(strcat('currVal',subFieldPath));
        catch err
            ME=MException('loc_retrieveSubfield:SomethingHappened','');
            throw(ME);
        end
    end
end




function loc_verifyStructParamHelper(target,candidate)












    targetIsStruct=isstruct(target);
    candidateIsStruct=isstruct(candidate);
    structMismatch=...
    (targetIsStruct&&~candidateIsStruct)||...
    (~targetIsStruct&&candidateIsStruct);

    if(structMismatch)

        ME=MException('loc_verifyStructParamHelper:StructMismatch','');
        throw(ME);
    end

    targetAndCandidateAreBothStructs=...
    targetIsStruct&&candidateIsStruct;

    if~targetAndCandidateAreBothStructs

        if~isequal(size(target),size(candidate))
            ME=MException('loc_verifyStructParamHelper:SizeMismatch','');
            throw(ME);
        end


        if~isequal(isreal(target),isreal(candidate))
            ME=MException('loc_verifyStructParamHelper:ComplexityMismatch','');
            throw(ME);
        end


        if isequal(class(target),class(candidate))
            return;
        end


        try
            if isa(target,'embedded.fi')
                fi(candidate,target.numerictype());
            else
                feval(class(target),candidate);
            end
        catch
            ME=MException('loc_verifyStructParamHelper:ClassMismatch','');
            throw(ME);
        end
    else


        targetFields=fieldnames(target);
        candidateFields=fieldnames(candidate);

        if~isSubset(candidateFields,targetFields)
            ME=MException('loc_verifyStructParamHelper:fieldNameMismatch','');
            throw(ME);
        end


        for j=1:length(candidate)
            for i=1:length(candidateFields)
                assert(isfield(target,candidateFields(i)));
                assert(isequal(size(candidate),size(target)));
                newTarget=target(j).(candidateFields{i});
                newCandidate=candidate(j).(candidateFields{i});
                try
                    loc_verifyStructParamHelper(newTarget,newCandidate);
                catch err
                    if strcmp(err.identifier,'loc_verifyStructParamHelper:ClassMismatch')
                        fieldPath=['(',num2str(j),').',targetFields{i},err.message];
                        ME=MException('loc_verifyStructParamHelper:ClassMismatch',fieldPath);
                        throw(ME);
                    elseif strcmp(err.identifier,'loc_verifyStructParamHelper:SizeMismatch')
                        fieldPath=['(',num2str(j),').',targetFields{i},err.message];
                        ME=MException('loc_verifyStructParamHelper:SizeMismatch',fieldPath);
                        throw(ME);
                    elseif strcmp(err.identifier,'loc_verifyStructParamHelper:fiMismatch')
                        fieldPath=['(',num2str(j),').',targetFields{i},err.message];
                        ME=MException('loc_verifyStructParamHelper:fiMismatch',fieldPath);
                        throw(ME);
                    elseif strcmp(err.identifier,'loc_verifyStructParamHelper:fieldNameMismatch')
                        fieldPath=['(',num2str(j),').',targetFields{i},err.message];
                        ME=MException('loc_verifyStructParamHelper:fieldNameMismatch',fieldPath);
                        throw(ME);
                    elseif strcmp(err.identifier,'loc_verifyStructParamHelper:ComplexityMismatch')
                        fieldPath=['(',num2str(j),').',targetFields{i},err.message];
                        ME=MException('loc_verifyStructParamHelper:fieldNameMismatch',fieldPath);
                        throw(ME);
                    end
                end
            end
        end
    end
end







function newStructVal=loc_replaceSubfield(...
    newSubfieldVal,...
    currStructVal,...
subFieldPath...
    )

    newStructVal=currStructVal;
    fullSubFieldPath=strcat('newStructVal',subFieldPath);
    subFieldVal=eval(fullSubFieldPath);

    updatedSubFieldVal=loc_replaceSubfieldHelper(...
    subFieldVal,...
newSubfieldVal...
    );%#ok (used in eval)

    evalString=strcat(fullSubFieldPath,' = updatedSubFieldVal;');
    eval(evalString);
end



function target=loc_replaceSubfieldHelper(target,replacer)
    if~isstruct(replacer)
        if isequal(class(target),class(replacer))
            target=replacer;
            return
        end

        assert(~isstruct(target));
        if isa(target,'embedded.fi')
            target=fi(replacer,target.numerictype());
        else
            target=feval(class(target),replacer);
        end
    else
        replacerFields=fields(replacer);
        for i=1:length(target)
            for j=1:length(replacerFields)
                assert(isfield(target,replacerFields{j}));
                target(i).(replacerFields{j})=loc_replaceSubfieldHelper(...
                target(i).(replacerFields{j}),...
                replacer(i).(replacerFields{j})...
                );
            end
        end
    end
end




function isSubset=isSubset(subsetCandidate,superSet)
    isSubset=all(ismember(subsetCandidate,superSet));
end