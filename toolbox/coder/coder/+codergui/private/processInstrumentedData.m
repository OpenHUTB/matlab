function[data,histograms,options]=processInstrumentedData(report,includedFcnIds,lineMaps)







    histograms=emptyHistogramStruct();
    if~isfield(report,'InstrumentedData')||isempty(report.InstrumentedData)
        data=[];
        options=[];
        return;
    end

    options=report.InstrumentedData.options;

    if options.doLog2Display
        numberFormatter=@baseTwoLogToStr;
    else
        numberFormatter=@compactNumberToStr;
    end

    fcns=report.InstrumentedData.InstrumentedFunctions;
    varFcns=report.InstrumentedData.InstrumentedVariables.Functions;
    if nargin>1&&~isempty(includedFcnIds)
        fcns=fcns(ismember([fcns.FunctionID],includedFcnIds));
        varFcns=varFcns(ismember([varFcns.FunctionID],includedFcnIds));
    end
    if nargin<3
        lineMaps=[];
    end

    builtInTypes={'int8','uint8','int16','uint16','int32','uint32','int64','uint64',...
    'double','single','half',...
    'logical'};

    mxInfos=report.inference.MxInfos;
    mxArrays=report.inference.MxArrays;
    reportFcns=report.inference.Functions;
    reportScripts=report.inference.Scripts;
    varFcns=indexByFunctionId(varFcns);

    data=cell2struct(cell(numel(fcns),3),{'functionId','variables','expressions'},2);
    histIdx=0;
    hasRatioOfRanges=false;
    hasProposalData=false;

    for i=1:numel(fcns)
        fcn=fcns(i);
        reportFcn=reportFcns(fcn.FunctionID);
        if reportFcn.ScriptID>0
            reportScript=reportScripts(reportFcn.ScriptID);
        else
            reportScript=[];
        end
        if~isempty(reportScript)&&~isempty(lineMaps)
            lineMap=lineMaps{reportFcn.ScriptID};
        else
            lineMap=[];
        end
        infoLocs=fcn.InstrumentedMxInfoLocations;
        if fcn.FunctionID<=numel(varFcns)&&~isempty(varFcns{fcn.FunctionID})
            namedVars=varFcns{fcn.FunctionID}.NamedVariables;
            [data(i).variables,varLookup]=toVarStruct(namedVars);
        else
            namedVars=[];
            data(i).variables=[];
            varLookup=[];
        end
        data(i).expressions=toExprStruct(infoLocs);
        data(i).functionId=fcn.FunctionID;
    end

    if~isempty(histograms)
        if~isempty(options.defaultDT)&&options.defaultDT.isfixed()
            histograms(1).DefaultDTWL=options.defaultDT.WordLength;
            if~options.defaultDT.isscalingunspecified()
                histograms(1).DefaultDTFL=options.defaultDT.FractionLength;
            end
        end
        if isfield(report,'summary')&&isfield(report.summary,'htmldirectory')

            spec=regexp(report.summary.htmldirectory,filesep,'split');
            spec=regexp(spec{end},'_','split');
            histograms(1).Tag=['_',spec{end}];
        else

            histograms(1).Tag='_MATLABCoder';
        end
    end

    options=codergui.internal.flattenForJson(options);
    options.hasHistograms=~isempty(histograms);
    options.hasRatioOfRanges=hasRatioOfRanges;
    options.hasProposalData=hasProposalData;


    function numericType=getNumericType(mxInfoId)
        numericType=[];
        mxInfo=mxInfos{mxInfoId};
        if isa(mxInfo,'eml.MxFiInfo')||isa(mxInfo,'eml.MxNumericTypeInfo')
            numericType=mxArrays{mxInfo.NumericTypeID};
            if numericType.isscalingbinarypoint&&(numericType.isfixed||numericType.isscaleddouble)

            else
                numericType=[];
            end
        end


        if isempty(numericType)&&...
            ismember(mxInfo.Class,builtInTypes)
            numericType=numerictype(mxInfo.Class);
        end
    end


    function[out,rootLookup]=toVarStruct(vars)
        rootLookup=zeros(size(infoLocs),'uint32');
        if isempty(vars)
            out={};
            return
        end

        out=rmfield(vars,{...
        'IsArgin',...
        'IsArgout',...
        'IsGlobal',...
        'IsPersistent',...
        'IsCppSystemObject',...
        'TextStarts',...
        'TextLength',...
        'InstanceCount',...
        'NumberOfInstances',...
        'MxInfoLocationIDs',...
        });
        mask=true(size(out));

        for ii=1:numel(out)
            if strcmp(mxInfos{vars(ii).MxInfoID}.Class,'cell')
                mask(ii)=false;
                continue
            end
            if isempty(vars(ii).LoggedFieldNames)

                denestRecord(ii,1);
            else


                out(ii).SimMinStr=vectorReformat(out(ii).SimMin);
                out(ii).SimMaxStr=vectorReformat(out(ii).SimMax);
            end
            rootLookup(vars(ii).MxInfoLocationIDs)=ii;
            out(ii).HistogramIndex=newHistogram(vars(ii),true);
        end
        out=out(mask);

        function denestRecord(idx,valueIdx)
            if~isempty(out(idx).ProposedSignedness)
                out(idx).ProposedSignedness=out(idx).ProposedSignedness{valueIdx};
                hasProposalData=hasProposalData||~isempty(out(idx).ProposedSignedness);
            end
            if~isempty(out(idx).ProposedFractionLengths)
                out(idx).ProposedFractionLengths=out(idx).ProposedFractionLengths{valueIdx};
                hasProposalData=hasProposalData||~isempty(out(idx).ProposedFractionLengths);
            end
            if~isempty(out(idx).ProposedWordLengths)
                out(idx).ProposedWordLengths=out(idx).ProposedWordLengths{valueIdx};
                hasProposalData=hasProposalData||~isempty(out(idx).ProposedWordLengths);
            end
            if~isempty(out(idx).RatioOfRange)
                out(idx).RatioOfRange=out(idx).RatioOfRange{valueIdx};
                hasRatioOfRanges=hasRatioOfRanges||~isempty(out(idx).RatioOfRange);
            end
            if~isempty(out(idx).OutOfRange)
                out(idx).OutOfRange=out(idx).OutOfRange{valueIdx};
            end
            out(idx).SimMinStr=numberFormatter(out(idx).SimMin);
            out(idx).SimMaxStr=numberFormatter(out(idx).SimMax);
        end
    end


    function out=toExprStruct(locations)
        out=codergui.internal.flattenForJson(locations);
        if~isempty(out)
            out(1).HistogramIndex=[];
            out(1).FieldIndex=[];
        end
        mask=true(size(out));

        for ii=1:numel(out)
            if varLookup(ii)~=0

                keep=false;
                if~isempty(locations(ii).LoggedFieldNames)&&~isempty(reportScript)



                    jj=ii-1;

                    childTextStart=locations(ii).TextStart+locations(ii).TextLength+1;
                    while jj>0&&locations(ii).TextStart==locations(jj).TextStart
                        code=reportScript.ScriptText(childTextStart:(locations(jj).TextStart+locations(jj).TextLength-1));
                        [~,fieldIdx]=ismember(code,locations(ii).LoggedFieldNames);
                        if fieldIdx~=0
                            varRecord=namedVars(varLookup(ii));
                            if~any(varRecord.TotalNumberOfValues)
                                break;
                            end



                            processRecord(ii,varRecord,fieldIdx);
                            out(ii).TextLength=locations(jj).TextLength;
                            out(ii).MxInfoID=locations(jj).MxInfoID;
                            out(ii).FieldIndex=fieldIdx;
                            keep=true;
                            break;
                        end
                        jj=jj-1;
                    end
                end
                if~keep
                    mask(ii)=false;
                end
            else

                processRecord(ii,locations(ii),1);
            end
        end

        out=rmfield(out(mask),{...
        'NodeTypeName',...
        'IsArgin',...
        'IsArgout',...
        'IsGlobal',...
        'IsPersistent',...
        'LoggedFieldToolTipIDs',...
        'LoggedFieldNames',...
        'LoggedFieldMxInfoIDs',...
        'Saturations',...
        'OverflowWraps',...
        'LogID',...
        'ToolTipID',...
        'SymbolName',...
        'SymbolID',...
        'Reason',...
        'MxInfoIDStr',...
'VarIDsArrayIndex'...
        });

        function processRecord(idx,src,valueIdx)

            if~isscalar(src.TotalNumberOfValues)
                out(idx).SimMin=src.SimMin(valueIdx);
                out(idx).SimMax=src.SimMax(valueIdx);
                out(idx).IsAlwaysInteger=src.IsAlwaysInteger(valueIdx);
                out(idx).IsAlwaysInteger=src.IsAlwaysInteger(valueIdx);
                out(idx).NumberOfZeros=src.NumberOfZeros(valueIdx);
                out(idx).NumberOfPositiveValues=src.NumberOfPositiveValues(valueIdx);
                out(idx).NumberOfNegativeValues=src.NumberOfNegativeValues(valueIdx);
                out(idx).TotalNumberOfValues=src.TotalNumberOfValues(valueIdx);
                out(idx).HistogramOfPositiveValues=src.HistogramOfNegativeValues(valueIdx,:);
                out(idx).HistogramOfNegativeValues=src.HistogramOfNegativeValues(valueIdx,:);
                out(idx).SimSum=src.SimSum(valueIdx);
            end
            if~isempty(src.ProposedSignedness)
                out(idx).ProposedSignedness=src.ProposedSignedness{valueIdx};
                hasProposalData=hasProposalData||~isempty(out(idx).ProposedSignedness);
            end
            if~isempty(src.ProposedFractionLengths)
                out(idx).ProposedFractionLengths=src.ProposedFractionLengths{valueIdx};
                hasProposalData=hasProposalData||~isempty(out(idx).ProposedFractionLengths);
            end
            if~isempty(src.ProposedWordLengths)
                out(idx).ProposedWordLengths=src.ProposedWordLengths{valueIdx};
                hasProposalData=hasProposalData||~isempty(out(idx).ProposedWordLengths);
            end
            if~isempty(src.RatioOfRange)
                out(idx).RatioOfRange=src.RatioOfRange{valueIdx};
                hasRatioOfRanges=hasRatioOfRanges||~isempty(out(idx).RatioOfRange);
            end
            if~isempty(src.OutOfRange)
                out(idx).OutOfRange=src.OutOfRange{valueIdx};
            end

            out(idx).SimMinStr=vectorReformat(out(idx).SimMin);
            out(idx).SimMaxStr=vectorReformat(out(idx).SimMax);
            out(idx).TextStart=out(idx).TextStart-1;
            if~options.doProposeForTemps&&isempty(src.SymbolName)
                out(idx).ProposedSignedness='';
                out(idx).ProposedWordLengths=[];
                out(idx).ProposedFractionLengths=[];
            end

            out(idx).HistogramIndex=newHistogram(out(idx),false);
        end
    end

    function str=vectorReformat(val)
        if isscalar(val)
            str=numberFormatter(val);
        else
            str=cell(size(val));
            for iii=1:numel(val)
                str{iii}=numberFormatter(val(iii));
            end
        end
    end

    function majorHistogramIndex=newHistogram(record,isVar)
        if~any(record.TotalNumberOfValues)
            majorHistogramIndex=0;
            return;
        end
        histIdx=histIdx+1;
        majorHistogramIndex=histIdx;

        histograms(histIdx).HistogramOfPositiveValues=sparse(record.HistogramOfPositiveValues);
        histograms(histIdx).HistogramOfNegativeValues=sparse(record.HistogramOfNegativeValues);
        histograms(histIdx).NumberOfZeros=record.NumberOfZeros;
        histograms(histIdx).NumberOfPositiveValues=record.NumberOfPositiveValues;
        histograms(histIdx).NumberOfNegativeValues=record.NumberOfNegativeValues;
        histograms(histIdx).TotalNumberOfValues=record.TotalNumberOfValues;
        histograms(histIdx).SimMin=record.SimMin;
        histograms(histIdx).SimMax=record.SimMax;
        histograms(histIdx).SimSum=record.SimSum;
        histograms(histIdx).FunctionName=reportFcn.FunctionName;

        if isVar
            fillVariableHistogram(record);
        else
            if~isempty(reportScript)
                snippet=reportScript.ScriptText(record.TextStart+1:(record.TextStart+record.TextLength));
                if~isempty(lineMap)
                    label=[snippet,' (line ',int2str(lineMap(record.TextStart+1)),')'];
                else
                    label=snippet;
                end
            else
                label='';
            end
            fillLocationHistogram(record,label);
        end
    end

    function fillVariableHistogram(record)
        if~isfield(record,'LoggedFieldNames')||isempty(record.LoggedFieldNames)

            fillLocationHistogram(record,record.SymbolName);
        else

            numFields=numel(record.LoggedFieldNames);
            histograms(histIdx).VariableName=strcat(record.SymbolName,'.',record.LoggedFieldNames);
            histograms(histIdx).ProposedSignednessStr=repmat({''},1,numFields);
            histograms(histIdx).ProposedWL=histograms(histIdx).ProposedSignednessStr;
            histograms(histIdx).ProposedFL=histograms(histIdx).ProposedSignednessStr;
            histograms(histIdx).WL=cell(1,numFields);
            histograms(histIdx).FL=cell(1,numFields);
            for ii=1:numFields
                if ii>numel(record.LoggedFieldMxInfoIDs)
                    break;
                elseif isempty(record.LoggedFieldMxInfoIDs{ii})
                    continue;
                end
                loggedFieldMxInfoID=record.LoggedFieldMxInfoIDs{ii};
                numericType=getNumericType(loggedFieldMxInfoID(end));
                if~isempty(numericType)
                    histograms(histIdx).ProposedSignednessStr{ii}=numericType.Signedness;
                    histograms(histIdx).WL{ii}=numericType.WordLength;
                    histograms(histIdx).FL{ii}=numericType.FractionLength;
                end
            end
        end
    end

    function fillLocationHistogram(record,name)
        numericType=getNumericType(record.MxInfoID);
        numericTypeStr='';
        if~isempty(numericType)
            histograms(histIdx).WL={numericType.WordLength};
            histograms(histIdx).FL={numericType.FractionLength};
            numericTypeStr=numericType.tostring;
        else
            histograms(histIdx).WL={[]};
            histograms(histIdx).FL={[]};
        end
        histograms(histIdx).ProposedSignednessStr={record.ProposedSignedness};
        histograms(histIdx).ProposedWL={record.ProposedWordLengths};
        histograms(histIdx).ProposedFL={record.ProposedFractionLengths};
        histograms(histIdx).VariableName={name};
        histograms(histIdx).NumericTypeString=numericTypeStr;
    end
end



function indexed=indexByFunctionId(structArray)
    for i=numel(structArray):-1:1
        indexed{structArray(i).FunctionID}=structArray(i);
    end
end



function str=baseTwoLogToStr(val)

    if isempty(val)
        str='-';
    elseif isequal(val,0)
        str='0';
    else
        [f,e]=log2(val);
        str=sprintf('%-+7.4f * 2^%d',f,e);
    end
end



function str=compactNumberToStr(val)
    str=fixed.internal.compactButAccurateNum2Str(val);
end



function histogramStruct=emptyHistogramStruct()
    histFields={...
    'HistogramOfPositiveValues',...
    'HistogramOfNegativeValues',...
    'NumberOfZeros',...
    'NumberOfPositiveValues',...
    'NumberOfNegativeValues',...
    'TotalNumberOfValues',...
    'SimMin',...
    'SimMax',...
    'SimSum',...
    'DefaultDTWL',...
    'DefaultDTFL',...
    'WL',...
    'FL',...
    'ProposedSignednessStr',...
    'ProposedWL',...
    'ProposedFL',...
    'FunctionName',...
    'VariableName',...
    'Tag',...
    };
    histogramStruct=cell2struct(cell(0,numel(histFields)),histFields,2);
end


