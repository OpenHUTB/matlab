function[data,auxCodeInfo,inclusion]=transformInferenceReport(report,varargin)





    validateattributes(report,{'eml.InferenceReport','struct'},{'scalar'});
    if isstruct(report)
        if isfield(report,'inference')
            inference=report.inference;
        else
            inference=[];
        end
    else
        inference=report;
        report=[];
    end

    auxCodeInfo=[];
    if isempty(inference)
        if~isfield(report,'scripts')
            data=[];
            fcnIds=[];
            includedScriptIds=[];
            return;
        end
        allFcns=[];
        scripts=[];
    else
        validateattributes(inference,{'eml.InferenceReport'},{'scalar'});
        allFcns=inference.Functions;
        scripts=inference.Scripts;
    end

    options=processArguments();

    if~isempty(options.Inclusion)
        fcnIds=options.Inclusion.functionIds;
        includedScriptIds=options.Inclusion.scriptIds;
    else
        [fcnIds,includedScriptIds]=getIncludedFunctions(report,ShowUserVisibleOnly=options.HideInternalFunctions);
    end
    inclusion.functionIds=fcnIds;
    inclusion.scriptIds=includedScriptIds;

    if~isempty(inference)&&isempty(fcnIds)
        data=[];
        return;
    end

    mask=false(length(allFcns),1);
    mask(fcnIds)=true;
    fcns=allFcns(mask);
    fcnTotal=numel(fcns);
    includedScripts=scripts(includedScriptIds);
    includedScriptCount=numel(includedScripts);

    runDca=options.DoDeadCodeAnalysis&&isfield(report,'summary')&&...
    isfield(report.summary,'passed')&&report.summary.passed;

    if isempty(options.LineMaps)
        [lineMaps,lineStarts]=reportToLineMaps(report,includedScriptIds);
    else
        lineMaps=options.LineMaps.lineMaps;
        lineStarts=options.LineMaps.lineStarts;
    end


    parentData=options.ParentReportData;
    if~isempty(parentData)&&isfield(parentData.report,'inference')
        parentReport=parentData.report.inference;
        parentData=parentData.processed;
        fcnOffset=numel(parentReport.Functions);
        scriptOffset=numel(parentReport.Scripts);
        mxInfoOffset=numel(parentReport.MxInfos);
        mxArrayOffset=numel(parentReport.MxArrays);
    else
        parentData=[];
        fcnOffset=0;
        scriptOffset=0;
        mxInfoOffset=0;
        mxArrayOffset=0;
    end



    [coderMessages,unownedMessages]=indexCoderMessages(report);

    mxArrayCount=0;
    if~isempty(inference)


        mxArrayCount=numel(inference.MxArrays);

        fcnTypes=determineFunctionTypes();
        [fcnSpecs,fcnClassSpecs,classInfos,scriptFcns]=analyzeFunctionSpecializations();
        if runDca
            fdcMode='full';
        else
            fdcMode='partial';
        end
        [dcaResults,deadFuncs]=findDeadCode(report,fcnIds,fdcMode);
        [variables,expressions,callSites,inferMessages,otherMessages,deadCode,mxValueIdMap]=processFunctionProperties();
        includedScripts=processScripts(scriptFcns);

        if fcnOffset~=0
            outerFcnIds=cell(1,fcnTotal);
            for ii=1:numel(outerFcnIds)
                outerFcnIds{ii}=fcns(ii).OuterFunctionIDs+fcnOffset;
            end
        else
            outerFcnIds={fcns.OuterFunctionIDs};
        end



        fcnStructs=struct(...
        'FunctionName',{fcns.FunctionName},...
        'FunctionID',num2cell(fcnIds+fcnOffset),...
        'ScriptID',num2cell([fcns.ScriptID]+scriptOffset),...
        'Specialization',num2cell(fcnSpecs),...
        'ClassName',{fcns.ClassName},...
        'ClassSpecialization',num2cell(fcnClassSpecs),...
        'MultiSigName',{fcns.MultisignatureEntryPointName},...
        'IsTransparent',{fcns.IsTransparent},...
        'IsAutoExtrinsic',{fcns.IsAutoExtrinsic},...
        'IsExtrinsic',{fcns.IsExtrinsic},...
        'IsLocationLogged',{fcns.IsLocationLogged},...
        'Majority',{fcns.Majority},...
        'OuterFunctionIDs',outerFcnIds,...
        'TextStart',num2cell([fcns.TextStart]),...
        'TextLength',num2cell([fcns.TextLength]),...
        'TextLine',num2cell(getFunctionTextLines()),...
        'FunctionType',num2cell(fcnTypes(:)')...
        );
        if isscalar(fcnStructs)
            fcnStructs={fcnStructs};
        end
        if isscalar(includedScripts)
            includedScripts={includedScripts};
        end

        data.RootFunctionIDs=inference.RootFunctionIDs(ismember(inference.RootFunctionIDs,fcnIds));

        if strcmp(options.Structure,'layered')
            data.Functions=fcnStructs;
            data.Variables=variables;
            data.Expressions=expressions;
            data.CallSites=callSites;
            data.InferenceMessages=inferMessages;
            data.CoderMessages=otherMessages;
        else
            [fcnStructs.Variables]=variables{:};
            [fcnStructs.Expressions]=expressions{:};
            tempCell=mat2cell(callSites,1,ones(1,fcnTotal));%#ok<MMTC>
            [fcnStructs.CallSites]=tempCell{:};
            [fcnStructs.InferenceMessages]=inferMessages{:};
            [fcnStructs.CoderMessages]=otherMessages{:};
            data.Functions=fcnStructs;
        end

        data.Scripts=includedScripts;
        [mxInfos,exportableMxArrays]=processMxInfos(inference.MxInfos,fcns,mxValueIdMap,...
        mxInfoOffset,mxArrayOffset);
        data.MxInfos=mxInfos;
        data.MxArrays=processMxArrays(inference.MxArrays,mxArrayOffset,exportableMxArrays);
        data.ClassData=classInfos;
        data.DeadCode=deadCode;
        data.UnownedMessages=[];

        if~isempty(parentData)
            data=concatData(parentData,data);
        end
    else


        [data.Scripts,data.UnownedMessages]=processErrorScripts(report.scripts,unownedMessages);
    end



    function parsed=processArguments()
        ip=inputParser();
        ip.addParameter('HideInternalFunctions',true,@islogical);
        ip.addParameter('LegacySpecializationMode',false,@islogical);
        ip.addParameter('Structure','layered',@(v)any(validatestring(v,{'legacy','layered'})));
        ip.addParameter('Inclusion',[],@(v)all(isfield(v,{'functionIds','scriptIds'})));
        ip.addParameter('LineMaps',{},@(s)all(isfield(s,{'lineMaps','lineStarts'})));
        ip.addParameter('ParentReportData',[],@(s)isempty(s)||all(isfield(s,{'processed','report'})));
        ip.addParameter('Generated',false,@islogical);
        ip.addParameter('DoDeadCodeAnalysis',false,@islogical);
        ip.parse(varargin{:});
        parsed=ip.Results;
    end


    function funcTypes=determineFunctionTypes()
        funcTypes=zeros(1,numel(fcns));
        for i=1:numel(fcns)
            fcn=fcns(i);
            if fcn.ScriptID>0
                script=scripts(fcn.ScriptID);
            else
                script=[];
            end

            if isempty(fcn.FunctionName)
                type=coder.report.FunctionType.PFunction;
            elseif fcn.FunctionName(1)=='@'
                type=coder.report.FunctionType.Anonymous;
            elseif~isempty(fcn.OuterFunctionIDs)
                type=coder.report.FunctionType.Nested;
            elseif~isempty(fcn.ClassName)
                if strcmp(fcn.FunctionName,fcn.ClassName)||endsWith(fcn.ClassName,['.',fcn.FunctionName])
                    type=coder.report.FunctionType.Constructor;
                else
                    type=coder.report.FunctionType.Method;
                end
            elseif isempty(script)
                type=coder.report.FunctionType.Extrinsic;
            elseif strcmp(fcn.FunctionName,script.ScriptName)
                type=coder.report.FunctionType.EntryPoint;
            else
                type=coder.report.FunctionType.Local;
            end

            funcTypes(i)=uint8(type);
        end
    end


    function[specIds,fcnClassSpecs,classInfos,scriptContents]=analyzeFunctionSpecializations
        specValues=[fcns.TextStart];
        assert(fcnTotal==numel(specValues));










        records=cell(fcnTotal,8);

        watchIndex=size(records,2);
        origIndexIndex=watchIndex-2;
        isCell=iscell(specValues);


        for i=1:fcnTotal
            fcn=fcns(i);
            if isCell
                specValue=specValues{i};
            else
                specValue=specValues(i);
            end
            records{i,1}=fcn.ScriptID;
            records{i,2}=fcn.ClassdefUID;
            records{i,3}=fcn.ClassName;
            records{i,4}=fcnIds(i);
            records{i,5}=fcnTypes(i)==coder.report.FunctionType.Method;
            records{i,6}=i;
            records{i,7}=~isempty(fcn.ClassName);
            records{i,8}=specValue;
        end

        records=sortrows(records,[1,2,watchIndex]);

        specIds=zeros(1,fcnTotal);
        scriptContents=cell(includedScriptCount,1);
        prevWatch=[];
        prevScript=-1;
        prevClass=-1;
        prevSpec=0;
        scriptBlockCounter=1;
        scriptBlockStart=1;


        for i=1:fcnTotal
            record=records(i,:);
            sameScript=prevScript==record{1};

            if sameScript&&prevClass==record{2}&&record{watchIndex}==prevWatch

                if prevSpec==0



                    applyFunctionSpecialization(i-1,1);
                    prevSpec=1;
                end
                prevSpec=prevSpec+1;
                applyFunctionSpecialization(i,prevSpec);
            else

                prevSpec=0;
                prevClass=record{2};
                prevScript=record{1};
                prevWatch=record{watchIndex};
                applyFunctionSpecialization(i,0);
            end

            if scriptBlockStart~=i&&~sameScript
                recordScriptFunctions(i-1);
            end
        end
        recordScriptFunctions(fcnTotal);


        records=sortrows(records(cell2mat(records(:,7)),:),[3,2,4]);
        fcnClassSpecs=repmat(-1,1,fcnTotal);
        origClassNames=unique(records(:,3),'stable');
        classInfos=struct(...
        'ClassName',origClassNames,...
        'ClassIDs',[],...
        'Specialized',false,...
        'Methods',{{}},...
        'StaticMethods',[]);

        prevClass=[];
        prevUid=-2;
        specCount=-1;
        nameIndex=0;
        classIdCounter=0;
        blockStart=intmax();

        for i=1:size(records,1)
            record=records(i,:);
            classdefUid=record{2};

            if strcmp(prevClass,record{3})

                if prevUid~=classdefUid
                    if prevUid>=0

                        if specCount==0

                            classInfos(nameIndex).Specialized=true;
                            specCount=1;
                        end
                        applyClassSpecialization(i-1);
                        specCount=specCount+1;
                    end
                    appendUidForCurrentClass();
                    prevUid=classdefUid;
                    blockStart=i;
                else

                end
            else

                applyClassSpecialization(i-1);
                prevUid=classdefUid;
                prevClass=record{3};
                nameIndex=nameIndex+1;
                newClassEntry();
                blockStart=i;
                specCount=0;
            end

            if record{5}
                if classdefUid~=-1
                    classInfos(nameIndex).Methods{end}{end+1}=record{4};
                else
                    classInfos(nameIndex).StaticMethods(end+1)=record{4};
                end
            end
        end
        applyClassSpecialization(size(records,1));


        function applyFunctionSpecialization(index,specId)
            specIds(records{index,origIndexIndex})=specId;
        end

        function applyClassSpecialization(blockEnd)
            if blockStart>blockEnd
                return;
            end
            fcnClassSpecs(cell2mat(records(blockStart:blockEnd,origIndexIndex)))=specCount;
        end

        function recordScriptFunctions(inclusiveBlockEnd)
            blockLen=inclusiveBlockEnd-scriptBlockStart+1;
            if blockLen>0
                if records{scriptBlockStart,1}>0
                    blockContents=zeros(blockLen,1);
                    for scIdx=1:blockLen
                        blockContents(scIdx)=records{scIdx+scriptBlockStart-1,4};
                    end
                    scriptContents{scriptBlockCounter}=blockContents;
                    scriptBlockCounter=scriptBlockCounter+1;
                end
                scriptBlockStart=inclusiveBlockEnd+1;
            end
        end

        function newClassEntry()
            classInfos(nameIndex).Specialized=false;
            classInfos(nameIndex).ClassIDs=[];
            classInfos(nameIndex).StaticMethods=[];
            appendUidForCurrentClass();
        end

        function appendUidForCurrentClass()
            if classdefUid==-1
                return;
            end
            classIdCounter=classIdCounter+1;
            classInfos(nameIndex).ClassIDs(end+1)=classIdCounter;
            classInfos(nameIndex).Methods{end+1}={};
        end
    end


    function[allVars,allExprs,allCalls,allInfMessages,allCoderMessages,allDc,mxValueIdMap]=processFunctionProperties()
        emptyCallStruct=cell2struct(cell(0,4),{'Callee','TextStart','TextLength','TextLine'},2);
        allCalls=struct('Caller',num2cell(fcnIds+fcnOffset),'CallSites',[]);
        allVars=cell(1,fcnTotal);
        allExprs=allVars;
        allInfMessages=allVars;
        allCoderMessages=allVars;
        allDc=allVars;
        varCounter=0;
        exprCounter=0;
        transparency=repmat(-1,numel(allFcns),1);
        hasAnyMessages=false;
        auxCodeInfo=cell(1,numel(allFcns));

        mxValueIdMap=cell(1,mxArrayCount);
        for i=1:fcnTotal
            fcn=fcns(i);
            if fcn.ScriptID<=0
                continue;
            end

            [allVars{i},allExprs{i},varCounter,exprCounter,mxValueIdMap]=processInfoLocations(...
            fcn.MxInfoLocations,dcaResults(i).variableLocationIds,dcaResults(i).expressionLocationIds,...
            scripts(fcn.ScriptID),mxInfoOffset,mxArrayOffset,varCounter,exprCounter,mxValueIdMap);

            [allInfMessages{i},allCoderMessages{i},fcnHasMessages]=processAllMessages(fcn,...
            coderMessages{fcnIds(i)});
            if runDca
                allDc{i}=dcaResults(i).deadCode;
            end
            hasAnyMessages=hasAnyMessages||fcnHasMessages;



            fcnCalls=fcn.CallSites;
            [~,uniqueIndices]=unique([fcnCalls.TextStart;fcnCalls.CalledFunctionID]','rows');
            fcnCalls=fcnCalls(uniqueIndices);

            pendingCallSites=emptyCallStruct;
            for ic=1:numel(fcnCalls)
                processCallSites(fcnIds(i),fcnCalls(ic));
            end
            allCalls(i).CallSites=pendingCallSites;

            auxCodeInfo{fcnIds(i)}=dcaResults(i);
        end

        if~hasAnyMessages
            allInfMessages={};
        end


        function processCallSites(callerId,callSite,topSite)
            calleeId=callSite.CalledFunctionID;
            callee=allFcns(calleeId);
            isCallerTransparent=isFcnTransparent(callerId);
            recordCall=true;
            if nargin<3
                topSite=callSite;
            end



            if~isCallerTransparent&&(callee.IsAutoExtrinsic||callee.IsExtrinsic)
                recordCall=true;
            elseif isFcnTransparent(calleeId)
                recordCall=false;
                if~isempty(callee.CallSites)
                    subSites=[callee.CallSites];
                    for fcnIDIdx=1:numel(subSites)
                        processCallSites(callerId,subSites(fcnIDIdx),topSite);
                    end
                end
            elseif~mask(calleeId)
                recordCall=false;
            end
            if recordCall
                callStart=topSite.TextStart;
                callLen=topSite.TextLength;
                if callStart>=0
                    callText=scripts(fcn.ScriptID).ScriptText(...
                    topSite.TextStart+1:topSite.TextStart+topSite.TextLength);
                    if startsWith(callText,'[')


                        extents=regexp(callText,...
                        '=(?:[\s]|\.\.\.[^\r^\n]*[\r\n]{1,2})+([^\s\(]+(?=[\(\s]))',...
                        'tokenExtents','once','dotexceptnewline');
                        if~isempty(extents)
                            callStart=callStart+extents(1)-1;
                            callLen=numel(callText)-extents(1)+1;
                        end
                    end
                end
                nextIdx=numel(pendingCallSites)+1;
                pendingCallSites(nextIdx).Callee=calleeId+fcnOffset;
                pendingCallSites(nextIdx).TextStart=callStart;
                pendingCallSites(nextIdx).TextLength=callLen;
                pendingCallSites(nextIdx).TextLine=positionToLine(allFcns(callerId),callStart);
            end
        end


        function transparent=isFcnTransparent(fcnIndex)
            transparent=transparency(fcnIndex);
            if transparent==-1
                transparent=isTransparent(allFcns(fcnIndex));
                transparency(fcnIndex)=transparent;
            end
        end
    end


    function scriptStructs=processScripts(scriptFcns)
        scriptStructs=repmat(scalarScriptStruct(),includedScriptCount,1);

        for i=1:includedScriptCount
            script=includedScripts(i);
            scriptId=includedScriptIds(i);

            scriptStructs(i).ScriptID=scriptId+scriptOffset;
            scriptStructs(i).Name=script.ScriptName;
            scriptStructs(i).InstanceID=script.ScriptInstanceID;
            scriptStructs(i).Path=script.ScriptPath;
            scriptStructs(i).Text=script.ScriptText;
            scriptStructs(i).IsUserVisible=script.IsUserVisible;
            scriptStructs(i).Functions=scriptFcns{i};
            scriptStructs(i).LineStarts=lineStarts{scriptId};
            if~isempty(deadFuncs{scriptId})
                scriptStructs(i).DeadFunctions=deadFuncs{scriptId};
            end
        end
    end


    function[infMessages,buildMessages,hasMessages]=processAllMessages(fcn,fcnCoderMessages)
        hasMessages=false;
        if isempty(fcn.Messages)&&isempty(fcnCoderMessages)
            infMessages=[];
            buildMessages=[];
            return;
        end
        hasMessages=true;

        messages=fcn.Messages;
        infMessages=repmat(scalarMessageStruct(),numel(messages),1);
        buildMessages=repmat(scalarMessageStruct(),numel(fcnCoderMessages),1);

        for i=1:numel(fcnCoderMessages)
            messageCell=fcnCoderMessages(i);
            buildMessages(i)=convertMessage(messageCell);
        end
        for i=1:numel(messages)
            infMessages(i)=convertMessage(messages(i));
        end

        function converted=convertMessage(message)
            converted.MessageID=message.MsgID;
            converted.MessageType=message.MsgTypeName;
            converted.TextStart=message.TextStart;
            converted.TextLength=message.TextLength;
            converted.TextLine=positionToLine(fcn,message.TextStart);
            converted.Text=message.MsgText;
            converted.ScriptID=fcn.ScriptID;
            if isfield(message,'Ordinal')||isprop(message,'Ordinal')
                converted.Ordinal=message.Ordinal;
            else
                converted.Ordinal=-1;
            end
            [~,topic]=coder.internal.moreinfo('-lookup',message.MsgID);
            converted.HasMoreInfo=~isempty(topic);
        end
    end


    function lineNum=positionToLine(fcn,zeroBasedPos)
        if fcn.ScriptID<=0
            lineNum=0;
            return;
        end

        position=zeroBasedPos+1;
        lineMap=lineMaps{fcn.ScriptID};
        if position>0&&position<=numel(lineMap)
            lineNum=lineMap(position);
        elseif position<=0
            lineNum=position;
        else
            lineNum=numel(lineMap);
        end
    end

    function textLines=getFunctionTextLines()
        textLines=zeros(1,numel(fcns));
        for i=numel(fcns)
            textLines(i)=positionToLine(fcns(i),fcns(i).TextStart);
        end
    end
end


function[flattened,exportable]=processMxInfos(mxInfos,fcns,mxValueIdMap,mxInfoOffset,mxArrayOffset)
    count=numel(mxInfos);
    if mxInfoOffset==0&&mxArrayOffset==0
        flattenExtraOpts={'CustomObjectSerializer',@filterSafeMxInfos,...
        'CustomObjectArraySerializer',@filterSafeMxInfos};
    else
        flattenExtraOpts={};
    end
    flattened=codergui.internal.flattenForJson(mxInfos,true,flattenExtraOpts{:});
    assert(numel(flattened)==count);

    [~,cyclicFilter]=findCyclicMxInfos(fcns,mxInfos);
    tagCyclicTypes=~isempty(cyclicFilter);

    exportable=true(numel(mxValueIdMap),1);
    for i=1:count
        mxInfo=mxInfos{i};
        flattened{i}.MatlabType=class(mxInfo);
        flattened{i}.MxInfoID=i+mxInfoOffset;


        if strcmp(mxInfo.Class,'coder.internal.indexInt')
            flattened{i}.Class='double';
        elseif isa(mxInfo,'eml.MxClassInfo')
            [propFilter,filteredProps]=codergui.evalprivate('createClassPropertyFilter',mxInfo);
            flattened{i}.ClassProperties=flattened{i}.ClassProperties(propFilter);
            if~isempty(flattened{i}.ClassProperties)
                if mxInfoOffset~=0
                    tempCell=num2cell([flattened{i}.ClassProperties.MxInfoID]+mxInfoOffset);
                    [flattened{i}.ClassProperties.MxInfoID]=tempCell{:};
                end
                if mxArrayOffset~=0
                    tempCell=num2cell([flattened{i}.ClassProperties.MxValueID]+mxArrayOffset);
                    [flattened{i}.ClassProperties.MxValueID]=tempCell{:};
                end
            end


            for j=1:numel(filteredProps)
                prop=filteredProps(j);
                mxValueId=prop.MxValueID;
                if mxValueId>0&&exportable(mxValueId)
                    mxInfoIds=mxValueIdMap{mxValueId};



                    if isempty(mxInfoIds)||isequal(mxInfoIds,prop.MxInfoID)
                        exportable(mxValueId)=false;
                    end
                end
            end
        end
        if tagCyclicTypes&&cyclicFilter(i)
            flattened{i}.Cyclic=true;
        end
    end
end


function processed=processMxArrays(mxArrays,idOffset,exportable)
    count=numel(mxArrays);
    processed=cell2struct(cell(count,5),...
    {'MxArrayID','MatlabType','Value','ValueString','Exportable'},2);


    maxTotalExportableSize=1e+8;

    totalExportableSize=0;




    fmtSpacing=get(0,'FormatSpacing');%#ok<GETFSP> 
    for i=1:count
        value=mxArrays{i};
        processed(i).MatlabType=class(value);
        processed(i).MxArrayID=i+idOffset;
        if isscalar(value)&&(isfimath(value)||isnumerictype(value)||isfi(value))
            processed(i).Value=codergui.internal.flattenForJson(value);
            processed(i).ValueString='';
        else
            processed(i).ValueString=formatMxValue(value,fmtSpacing);
        end




        if exportable(i)&&totalExportableSize<maxTotalExportableSize
            totalExportableSize=totalExportableSize+whos('value').bytes;
            if totalExportableSize<=maxTotalExportableSize
                processed(i).Exportable=exportable(i);
            end
        end
    end
end


function strVal=formatMxValue(mxValue,fmtSpacing)


    if(isobject(mxValue)&&~isstring(mxValue)&&~isenum(mxValue))||...
        (((~isscalar(mxValue)&&isnumeric(mxValue))||iscell(mxValue))&&numel(mxValue)>9)
        strVal=sizeAndClass(mxValue);
    else
        strVal=strtrim(fullDisplay(mxValue));
    end

    function value=sizeAndClass(mxValue)
        s=num2str(size(mxValue));
        s=regexprep(s,'[\s]+','x');
        value=sprintf('[%s %s]',s,class(mxValue));
    end

    function value=fullDisplay(mxValue)
        value=[];
        try
            format('compact');
            rawValue=evalc('disp(mxValue)');
            if numel(rawValue)<500
                rawValue=regexprep(strtrim(rawValue),'[\s]+',' ');
                if numel(rawValue)<50
                    value=rawValue;
                end
            end
        catch
        end
        if isempty(value)
            value=sizeAndClass(mxValue);
        end
        format(fmtSpacing);
    end
end


function[indexed,unowned]=indexCoderMessages(report)
    indexed={};
    unowned={};

    if~isfield(report,'summary')
        return;
    end
    hasInference=isfield(report,'inference')&&~isempty(report.inference);
    if hasInference
        indexed=cell(size(report.inference.Functions));
    end
    if~isfield(report.summary,'coderMessages')
        return;
    end

    coderMessages=report.summary.coderMessages;
    for i=1:numel(coderMessages)
        msg=coderMessages{i};
        fcnId=msg.FunctionID;
        if hasInference&&fcnId>0
            if numel(indexed)>=fcnId
                index=numel(indexed{fcnId})+1;
            else
                index=1;
            end
            indexed{fcnId}(index)=msg;%#ok<AGROW>
        else
            unowned{end+1}=msg;%#ok<AGROW>
        end
    end
end


function messageStruct=scalarMessageStruct()
    messageStruct=cell2struct(cell(1,9),{...
    'MessageID','MessageType','Ordinal','TextStart',...
    'TextLength','TextLine','Text','HasMoreInfo','ScriptID'},2);
end


function scriptStruct=scalarScriptStruct()
    scriptStruct=cell2struct(cell(1,7),{'ScriptID','Name','InstanceID',...
    'Path','Text','IsUserVisible','DeadFunctions'},2);
end


function[errorScripts,messages]=processErrorScripts(scriptCell,rawMessages)
    [~,uniqueIndices]=unique(cellfun(@(s)s.ScriptPath,scriptCell,'UniformOutput',false),'stable');
    errorScripts=repmat(scalarScriptStruct(),numel(uniqueIndices),1);
    for i=1:numel(uniqueIndices)
        scriptIndex=uniqueIndices(i);
        errorScripts(i).ScriptID=i;
        errorScripts(i).Name=scriptCell{scriptIndex}.ScriptName;
        errorScripts(i).Text=scriptCell{scriptIndex}.ScriptText;
        errorScripts(i).Path=scriptCell{scriptIndex}.ScriptPath;
        errorScripts(i).IsUserVisible=true;
        errorScripts(i).InstanceID=1;
    end

    messages=repmat(scalarMessageStruct(),numel(rawMessages),1);
    scriptId=min(numel(scriptCell),1);
    for i=1:numel(rawMessages)
        rawMessage=rawMessages{i};
        messages(i).MessageID=rawMessage.MsgID;
        messages(i).MessageType=rawMessage.MsgTypeName;
        messages(i).Text=rawMessage.MsgText;
        messages(i).TextStart=-1;
        messages(i).TextLength=-1;
        messages(i).TextLine=0;
        messages(i).Ordinal=i-1;
        messages(i).ScriptID=scriptId;
        [~,topic]=coder.internal.moreinfo('-lookup',rawMessage.MsgID);
        messages(i).HasMoreInfo=~isempty(topic);
    end
end


function parentData=concatData(parentData,data)
    parentData.Functions=[unwrap(parentData.Functions),unwrap(data.Functions)];
    parentData.Scripts=[unwrap(parentData.Scripts),unwrap(data.Scripts)];
    parentData.Variables=[unwrap(parentData.Variables),unwrap(data.Variables)];
    parentData.Expressions=[unwrap(parentData.Expressions),unwrap(data.Expressions)];
    parentData.CallSites=[unwrap(parentData.CallSites),unwrap(data.CallSites)];
    parentData.MxInfos=[unwrap(parentData.MxInfos),unwrap(data.MxInfos)];
    parentData.MxArrays=[unwrap(parentData.MxArrays),unwrap(data.MxArrays)];
    parentData.InferenceMessages=[unwrap(parentData.InferenceMessages),unwrap(data.InferenceMessages)];
    parentData.CoderMessages=[unwrap(parentData.CoderMessages),unwrap(data.CoderMessages)];
    parentData.ClassData=[unwrap(parentData.ClassData),unwrap(data.ClassData)];
    parentData.DeadCode=[unwrap(parentData.DeadCode),unwrap(data.DeadCode)];
end


function val=unwrap(val)
    if iscell(val)&&isscalar(val)
        val=val{1};
    else
        val=reshape(val,1,numel(val));
    end
end


function out=filterSafeMxInfos(obj)

    if any(strcmp(class(obj),{'eml.MxPropertyInfo','eml.MxFieldInfo'}))
        out=obj;
    else
        out=[];
    end
end
