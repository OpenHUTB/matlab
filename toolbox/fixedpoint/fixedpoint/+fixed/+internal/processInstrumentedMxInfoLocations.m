function[CompilationReport,instrumentedVariables]=processInstrumentedMxInfoLocations(results,opts)




    if isempty(results)
        error(message('fixed:instrumentation:noLoggedData'));
    end

    if nargin<2
        opts=fixed.internal.getDefaultInstrumentationOptions();
    end

    if~isfield(results,'Functions')||isempty(results.Functions)
        error(message('fixed:instrumentation:noLoggedFunctions'));
    end

    CompilationReport=results.CompilationReport;

    REASON_UNKNOWN=0;%#ok<NASGU>
    REASON_ARGIN=1;%#ok<NASGU>
    REASON_ASSIGN=2;
    REASON_CALL=3;%#ok<NASGU>
    REASON_MULTICALL=4;
    REASON_ADD=5;%#ok<NASGU>
    REASON_SUBTRACT=6;%#ok<NASGU>
    REASON_MULTIPLY=7;%#ok<NASGU>
    REASON_DIVIDE=8;%#ok<NASGU>
    REASON_FORINDEX=9;
    REASON_CPPSYSOBJ=10;

    inference_report=CompilationReport.inference;
    if isempty(inference_report.MxInfos)

        return
    end

    Functions=inference_report.Functions;
    isCallerMLFcnBlk=~isempty(regexpi(results.MexFileName,'^#'));


    instrumentedVariables.MexFileName=results.MexFileName;
    instrumentedVariables.TimeStamp=results.TimeStamp;
    instrumentedVariables.BuildDirectory=results.buildDir;
    instrumentedVariables.NumberOfHistogramBins=results.NumberOfHistogramBins;
    MxInfos=inference_report.MxInfos;
    instrumentedVariables.MxInfos=MxInfos;
    instrumentedVariables.MxArrays=inference_report.MxArrays;

    isNumericMxInfo=false(length(MxInfos),1);
    for i=1:length(MxInfos)
        isNumericMxInfo(i)=is_numeric_MxInfo(MxInfos{i});
    end

    loggableFieldNames=cell(length(MxInfos),1);
    loggableFieldMxInfoIDs=cell(length(MxInfos),1);
    for i=1:length(MxInfos)
        [loggableFieldNames{i},loggableFieldMxInfoIDs{i}]=...
        getLoggableFieldNames(i,MxInfos,isNumericMxInfo);
    end

    isLoggableMxInfo=false(length(MxInfos),1);
    for i=1:length(MxInfos)
        isLoggableMxInfo(i)=isNumericMxInfo(i)||~isempty(loggableFieldNames{i});
    end




    NamedToolTipOffset=length(inference_report.MxInfos);
    number_of_functions=length(results.Functions);
    number_of_named_variables_by_mxInfoID=0;


    instr_fun_index=0;
    for i=1:number_of_functions
        FunctionID=results.Functions(i).FunctionID;
        if FunctionID<=0||FunctionID>length(Functions)

            continue
        end
        ThisFunction=Functions(FunctionID);
        MxInfoLocations=ThisFunction.MxInfoLocations;
        if isempty(MxInfoLocations)




            continue
        end
        if ThisFunction.ScriptID<=0||ThisFunction.ScriptID>length(inference_report.Scripts)

            continue
        end

        instr_fun_index=instr_fun_index+1;


        [unicodemap,mnormal]=emlcprivate('makeunicodemap',...
        inference_report.Scripts(ThisFunction.ScriptID).ScriptText);
        ScriptText=mnormal;
        ThisFunctionLoggedLocations=results.Functions(i).loggedLocations;







        InstrumentedMxInfoLocations=initialize_InstrumentedMxInfoLocations(...
        MxInfoLocations,...
        instrumentedVariables.NumberOfHistogramBins,...
        MxInfos);

        names_and_mxinfoids={};

        if~isempty(ThisFunctionLoggedLocations)





































            for j=1:length(ThisFunctionLoggedLocations)
                LoggedFieldNames=ThisFunctionLoggedLocations(j).Fields;
                if~isempty(LoggedFieldNames)
                    MxInfoID=ThisFunctionLoggedLocations(j).Locations(1).MxInfoID;
                    if MxInfoID>0&&MxInfoID<=length(loggableFieldNames)&&MxInfoID<=length(loggableFieldMxInfoIDs)
                        ThisFunctionLoggedLocations(j).LoggedFieldMxInfoIDs=...
                        getLoggedFieldMxInfoIDs(LoggedFieldNames,...
                        loggableFieldNames{MxInfoID},...
                        loggableFieldMxInfoIDs{MxInfoID});
                    end
                end
            end





            for j=1:length(ThisFunctionLoggedLocations)
                text_start=ThisFunctionLoggedLocations(j).Locations(1).TextStart;
                text_length=ThisFunctionLoggedLocations(j).Locations(1).TextLength;
                [text_start,text_length]=emlcprivate('uniposition',unicodemap,text_start,text_length);
                sub_text=ScriptText(text_start:(text_start+text_length-1));
                if isempty(ThisFunctionLoggedLocations(j).Fields)
                    ThisFunctionLoggedLocations(j).Fields=...
                    getFieldNamesFromText(sub_text);
                else











                    field=getFieldNamesFromText(sub_text);
                    if~isempty(field)&&~isequal(ThisFunctionLoggedLocations(j).Locations(1).Reason,REASON_CPPSYSOBJ)
                        ThisFunctionLoggedLocations(j).Fields=...
                        strcat(field,{'.'},ThisFunctionLoggedLocations(j).Fields);

                        if isfield(ThisFunctionLoggedLocations(j),'ExplodedField')
                            ThisFunctionLoggedLocations(j).ExplodedField=...
                            strcat(field,{'.'},ThisFunctionLoggedLocations(j).ExplodedField);
                        end
                    end
                end
            end




            T=mtree(ScriptText);
            var_nodes=mtfind(T,'Isvar',true);
            var_names=strings(var_nodes)';
            var_nodes_TextStart=lefttreepos(var_nodes);
            var_nodes_TextEnd=righttreepos(var_nodes);
            var_nodes_TextLength=var_nodes_TextEnd-var_nodes_TextStart+1;
            var_nodes_TextStart_TextLength=[var_nodes_TextStart,var_nodes_TextLength];
            var_nodes_TextStart_TextLength_sorted=sortrows(var_nodes_TextStart_TextLength);




            mxInfoLocation_TextStarts=[InstrumentedMxInfoLocations(:).TextStart]';
            mxInfoLocation_TextLengths=[InstrumentedMxInfoLocations(:).TextLength]';
            [mxInfoLocation_TextStarts,mxInfoLocation_TextLengths]=emlcprivate('uniposition',unicodemap,mxInfoLocation_TextStarts,mxInfoLocation_TextLengths);
            mxInfoLocation_MxInfoIDs=[InstrumentedMxInfoLocations(:).MxInfoID]';
            mxInfoLocation_LoggableMxInfoIDs=false(size(mxInfoLocation_MxInfoIDs));
            for kk=1:length(mxInfoLocation_LoggableMxInfoIDs)
                mxInfoLocation_LoggableMxInfoIDs(kk)=isLoggableMxInfo(mxInfoLocation_MxInfoIDs(kk));
            end
            mxInfoLocation_TextStart_TextLength=[mxInfoLocation_TextStarts,...
            mxInfoLocation_TextLengths,...
            mxInfoLocation_MxInfoIDs];
            [mxInfoLocation_TextStart_TextLength_sorted,mxInfoLocation_TextStart_TextLength_sorted_index]=...
            sortrows(mxInfoLocation_TextStart_TextLength);

            m_to_v=correlaterows(mxInfoLocation_TextStart_TextLength_sorted(:,1:2),var_nodes_TextStart_TextLength_sorted);

            mxInfoLocation_to_VarNodeIndex(mxInfoLocation_TextStart_TextLength_sorted_index)=m_to_v;







            SimMinVector={};
            SimMaxVector={};
            IsAlwaysIntegerVector={};
            NumberOfZerosVector={};
            NumberOfPositiveValuesVector={};
            NumberOfNegativeValuesVector={};
            TotalNumberOfValuesVector={};
            NumberOfSaturationsVector={};
            NumberOfOverflowWrapsVector={};
            SimSumVector={};
            HistogramOfPositiveValuesVector={};
            HistogramOfNegativeValuesVector={};
            LoggedFieldNamesVector={};
            LoggedTextStarts=[];
            LoggedTextLengths=[];
            LoggedMxInfoIDs=[];
            Reasons=[];
            VarIDsMappingInfo={};
            for j=1:length(ThisFunctionLoggedLocations)
                LoggedLocation=ThisFunctionLoggedLocations(j);
                Locations=LoggedLocation.Locations;
                for k=1:length(Locations)

                    Location=Locations(k);
                    SimMinVector{end+1}=LoggedLocation.SimMin;%#ok<*AGROW>
                    SimMaxVector{end+1}=LoggedLocation.SimMax;%#ok<*AGROW>
                    IsAlwaysIntegerVector{end+1}=LoggedLocation.IsAlwaysInteger;%#ok<*AGROW>
                    NumberOfZerosVector{end+1}=LoggedLocation.NumberOfZeros;%#ok<*AGROW>
                    SimSumVector{end+1}=LoggedLocation.SimSum;%#ok<*AGROW>
                    NumberOfPositiveValuesVector{end+1}=LoggedLocation.NumberOfPositiveValues;%#ok<*AGROW>
                    NumberOfNegativeValuesVector{end+1}=LoggedLocation.NumberOfNegativeValues;%#ok<*AGROW>
                    TotalNumberOfValuesVector{end+1}=LoggedLocation.TotalNumberOfValues;%#ok<*AGROW>
                    NumberOfSaturationsVector{end+1}=LoggedLocation.Saturations;
                    NumberOfOverflowWrapsVector{end+1}=LoggedLocation.OverflowWraps;


                    HistogramOfPositiveValuesVector{end+1}=double(LoggedLocation.HistogramOfPositiveValues');%#ok<*AGROW>
                    HistogramOfNegativeValuesVector{end+1}=double(LoggedLocation.HistogramOfNegativeValues');%#ok<*AGROW>
                    LoggedFieldNamesVector{end+1}=LoggedLocation.Fields;%#ok<*AGROW>
                    MxInfoID=Location.MxInfoID;
                    TextStart=Location.TextStart;
                    TextLength=Location.TextLength;
                    [TextStart,TextLength]=emlcprivate('uniposition',unicodemap,TextStart,TextLength);
                    LoggedTextStarts=[LoggedTextStarts;TextStart];%#ok<*AGROW>
                    LoggedTextLengths=[LoggedTextLengths;TextLength];%#ok<*AGROW>
                    LoggedMxInfoIDs=[LoggedMxInfoIDs;MxInfoID];%#ok<*AGROW>
                    Reasons=[Reasons;Location.Reason];%#ok<*AGROW>





                    if isfield(LoggedLocation,'VarIDsArrayIdx')
                        varIDInfo.idx=LoggedLocation.VarIDsArrayIdx;






                        if(numel(LoggedLocation.Fields)==1&&...
                            isempty(LoggedLocation.ExplodedField))
                            varIDInfo.field=LoggedLocation.Fields(1);
                        else
                            varIDInfo.field=LoggedLocation.ExplodedField;
                        end
                        VarIDsMappingInfo=[VarIDsMappingInfo;{varIDInfo}];%#ok<*AGROW>
                    else
                        varIDInfo=struct('idx',-1,'field','');
                        VarIDsMappingInfo=[VarIDsMappingInfo;{varIDInfo}];%#ok<*AGROW>
                    end
                end
            end







            forStatements=mtfind(T,'Kind','FOR');
            if~isempty(forStatements)
                forStarts=lefttreepos(forStatements);
                forLengths=righttreepos(forStatements)-forStarts+1;
                forIndices=path(forStatements,'Index');
                forIndexStarts=lefttreepos(forIndices);
                forIndexLengths=righttreepos(forIndices)-forIndexStarts+1;

                [LoggedStartsLengthsSorted,LoggedStartsLengthsSorted_index]=sortrows([LoggedTextStarts,LoggedTextLengths]);
                [ForStartsLengthsSorted,ForStartsLengthsSorted_index]=sortrows([forStarts,forLengths]);
                forIndexStartsSorted=forIndexStarts(ForStartsLengthsSorted_index);
                forIndexLengthsSorted=forIndexLengths(ForStartsLengthsSorted_index);

                Logs_to_for_index=correlaterows(LoggedStartsLengthsSorted,ForStartsLengthsSorted);
                for j=1:length(Logs_to_for_index)
                    if(Logs_to_for_index(j)~=0)

                        LoggedStartsLengthsSorted(j,1)=forIndexStartsSorted(Logs_to_for_index(j));
                        LoggedStartsLengthsSorted(j,2)=forIndexLengthsSorted(Logs_to_for_index(j));
                    end
                end

                LoggedStartsLengthsSorted(LoggedStartsLengthsSorted_index,:)=LoggedStartsLengthsSorted;
                LoggedTextStarts=LoggedStartsLengthsSorted(:,1);
                LoggedTextLengths=LoggedStartsLengthsSorted(:,2);
            end













            multicall_LoggedReasons_index=find(Reasons==REASON_MULTICALL);
            if~isempty(multicall_LoggedReasons_index)
                multicall_LoggedTextStarts=LoggedTextStarts(multicall_LoggedReasons_index);
                for kk=1:length(multicall_LoggedTextStarts)
                    multicall_LoggedTextStart=multicall_LoggedTextStarts(kk);
                    matching_textStarts=multicall_LoggedTextStart==mxInfoLocation_TextStarts;
                    matching_numerics=matching_textStarts&mxInfoLocation_LoggableMxInfoIDs;


                    MxInfoID=mxInfoLocation_MxInfoIDs(matching_numerics);
                    TextLength=mxInfoLocation_TextLengths(matching_numerics);
                    if~isempty(MxInfoID)
                        MxInfoID=MxInfoID(1);
                        TextLength=TextLength(1);
                        LoggedMxInfoIDs(multicall_LoggedReasons_index(kk))=MxInfoID;
                        LoggedTextLengths(multicall_LoggedReasons_index(kk))=TextLength;
                    end
                end
            end




            unknown_LoggedMxInfoIDs_index=find(LoggedMxInfoIDs<=0);
            if~isempty(unknown_LoggedMxInfoIDs_index)
                unknown_LoggedTextStarts=LoggedTextStarts(unknown_LoggedMxInfoIDs_index);
                for kk=1:length(unknown_LoggedTextStarts)
                    unknown_LoggedTextStart=unknown_LoggedTextStarts(kk);
                    matching_textStarts=unknown_LoggedTextStart==mxInfoLocation_TextStarts;
                    matching_numerics=matching_textStarts&mxInfoLocation_LoggableMxInfoIDs;


                    MxInfoID=mxInfoLocation_MxInfoIDs(matching_numerics);
                    TextLength=mxInfoLocation_TextLengths(matching_numerics);
                    if~isempty(MxInfoID)
                        MxInfoID=MxInfoID(1);
                        TextLength=TextLength(1);
                        LoggedMxInfoIDs(unknown_LoggedMxInfoIDs_index(kk))=MxInfoID;
                        LoggedTextLengths(unknown_LoggedMxInfoIDs_index(kk))=TextLength;
                    end
                end
            end




            unknown_LoggedMxInfoIDs_index=find(LoggedMxInfoIDs<=0);
            if~isempty(unknown_LoggedMxInfoIDs_index)
                SimMinVector(unknown_LoggedMxInfoIDs_index)=[];
                SimMaxVector(unknown_LoggedMxInfoIDs_index)=[];
                IsAlwaysIntegerVector(unknown_LoggedMxInfoIDs_index)=[];
                NumberOfZerosVector(unknown_LoggedMxInfoIDs_index)=[];
                NumberOfPositiveValuesVector(unknown_LoggedMxInfoIDs_index)=[];
                NumberOfNegativeValuesVector(unknown_LoggedMxInfoIDs_index)=[];
                TotalNumberOfValuesVector(unknown_LoggedMxInfoIDs_index)=[];
                NumberOfSaturationsVector(unknown_LoggedMxInfoIDs_index)=[];
                NumberOfOverflowWrapsVector(unknown_LoggedMxInfoIDs_index)=[];
                SimSumVector(unknown_LoggedMxInfoIDs_index)=[];
                HistogramOfPositiveValuesVector(unknown_LoggedMxInfoIDs_index)=[];
                HistogramOfNegativeValuesVector(unknown_LoggedMxInfoIDs_index)=[];
                LoggedFieldNamesVector(unknown_LoggedMxInfoIDs_index)=[];
                LoggedTextStarts(unknown_LoggedMxInfoIDs_index)=[];
                LoggedTextLengths(unknown_LoggedMxInfoIDs_index)=[];
                LoggedMxInfoIDs(unknown_LoggedMxInfoIDs_index)=[];
                Reasons(unknown_LoggedMxInfoIDs_index)=[];
                VarIDsMappingInfo{unknown_LoggedMxInfoIDs_index}=[];
            end

            isSetNode=(Reasons==REASON_ASSIGN)|(Reasons==REASON_MULTICALL)|...
            (Reasons==REASON_FORINDEX);
            setNodeTextStarts=LoggedTextStarts(isSetNode);
            setNodeMxInfoIDs=LoggedMxInfoIDs(isSetNode);

            LoggedLocations=[LoggedTextStarts,LoggedTextLengths,LoggedMxInfoIDs];



            nLoggedLocations=size(LoggedLocations,1);
            j=1;

            while j<nLoggedLocations
                jj=nLoggedLocations;
                thisLL=LoggedLocations(j,:);


                while jj>j
                    if isequal(thisLL,LoggedLocations(jj,:))

                        SimMinVector{j}=min(SimMinVector{j},SimMinVector{jj});
                        SimMaxVector{j}=max(SimMaxVector{j},SimMaxVector{jj});
                        IsAlwaysIntegerVector{j}=IsAlwaysIntegerVector{j}&...
                        IsAlwaysIntegerVector{jj};
                        NumberOfZerosVector{j}=NumberOfZerosVector{j}+...
                        NumberOfZerosVector{jj};
                        NumberOfPositiveValuesVector{j}=NumberOfPositiveValuesVector{j}+...
                        NumberOfPositiveValuesVector{jj};
                        NumberOfNegativeValuesVector{j}=NumberOfNegativeValuesVector{j}+...
                        NumberOfNegativeValuesVector{jj};
                        TotalNumberOfValuesVector{j}=TotalNumberOfValuesVector{j}+...
                        TotalNumberOfValuesVector{jj};
                        NumberOfOverflowWrapsVector{j}=NumberOfOverflowWrapsVector{j}+...
                        NumberOfOverflowWrapsVector{jj};
                        NumberOfSaturationsVector{j}=NumberOfSaturationsVector{j}+...
                        NumberOfSaturationsVector{jj};
                        SimSumVector{j}=SimSumVector{j}+SimSumVector{jj};
                        if isequal(size(HistogramOfPositiveValuesVector{j}),size(HistogramOfPositiveValuesVector{jj}))
                            HistogramOfPositiveValuesVector{j}=HistogramOfPositiveValuesVector{j}+...
                            HistogramOfPositiveValuesVector{jj};
                        end
                        if isequal(size(HistogramOfNegativeValuesVector{j}),size(HistogramOfNegativeValuesVector{jj}))
                            HistogramOfNegativeValuesVector{j}=HistogramOfNegativeValuesVector{j}+...
                            HistogramOfNegativeValuesVector{jj};
                        end
                        VarIDsMappingInfo(j)={[VarIDsMappingInfo{j},VarIDsMappingInfo{jj}]};

                        SimMinVector(jj)=[];
                        SimMaxVector(jj)=[];
                        IsAlwaysIntegerVector(jj)=[];
                        NumberOfZerosVector(jj)=[];
                        NumberOfPositiveValuesVector(jj)=[];
                        NumberOfNegativeValuesVector(jj)=[];
                        TotalNumberOfValuesVector(jj)=[];
                        NumberOfOverflowWrapsVector(jj)=[];
                        NumberOfSaturationsVector(jj)=[];
                        SimSumVector(jj)=[];
                        HistogramOfPositiveValuesVector(jj)=[];
                        HistogramOfNegativeValuesVector(jj)=[];
                        LoggedFieldNamesVector(jj)=[];
                        LoggedTextStarts(jj)=[];
                        LoggedTextLengths(jj)=[];
                        LoggedMxInfoIDs(jj)=[];
                        Reasons(jj)=[];
                        VarIDsMappingInfo(jj)=[];
                        LoggedLocations(jj,:)=[];

                        nLoggedLocations=nLoggedLocations-1;
                    end
                    jj=jj-1;
                end
                j=j+1;
            end




            [LoggedLocations,LoggedLocations_sorted_index]=sortrows(LoggedLocations);
            SimMinVector=SimMinVector(LoggedLocations_sorted_index);
            SimMaxVector=SimMaxVector(LoggedLocations_sorted_index);
            IsAlwaysIntegerVector=IsAlwaysIntegerVector(LoggedLocations_sorted_index);
            NumberOfZerosVector=NumberOfZerosVector(LoggedLocations_sorted_index);
            NumberOfPositiveValuesVector=NumberOfPositiveValuesVector(LoggedLocations_sorted_index);
            NumberOfNegativeValuesVector=NumberOfNegativeValuesVector(LoggedLocations_sorted_index);
            TotalNumberOfValuesVector=TotalNumberOfValuesVector(LoggedLocations_sorted_index);
            NumberOfOverflowWrapsVector=NumberOfOverflowWrapsVector(LoggedLocations_sorted_index);
            NumberOfSaturationsVector=NumberOfSaturationsVector(LoggedLocations_sorted_index);
            SimSumVector=SimSumVector(LoggedLocations_sorted_index);
            HistogramOfPositiveValuesVector=HistogramOfPositiveValuesVector(LoggedLocations_sorted_index);
            HistogramOfNegativeValuesVector=HistogramOfNegativeValuesVector(LoggedLocations_sorted_index);
            LoggedTextStarts=LoggedTextStarts(LoggedLocations_sorted_index);
            LoggedTextLengths=LoggedTextLengths(LoggedLocations_sorted_index);
            Reasons=Reasons(LoggedLocations_sorted_index);
            VarIDsMappingInfo=VarIDsMappingInfo(LoggedLocations_sorted_index);
            LoggedFieldNamesVector=LoggedFieldNamesVector(LoggedLocations_sorted_index);
            LoggedMxInfoIDs=LoggedMxInfoIDs(LoggedLocations_sorted_index);%#ok

            mxInfoLocation_to_LoggedLocationsIndex=...
            correlaterows(mxInfoLocation_TextStart_TextLength_sorted,LoggedLocations);

            mxInfoLocation_to_LoggedLocationsIndex(mxInfoLocation_TextStart_TextLength_sorted_index)=...
            mxInfoLocation_to_LoggedLocationsIndex;











            for j=1:length(InstrumentedMxInfoLocations)
                if mxInfoLocation_to_VarNodeIndex(j)~=0
                    InstrumentedMxInfoLocations(j).SymbolName=var_names{mxInfoLocation_to_VarNodeIndex(j)};
                end
            end


            full_names_and_mxinfoids={
            InstrumentedMxInfoLocations(:).SymbolName
            InstrumentedMxInfoLocations(:).MxInfoID
            }';
            names=char({InstrumentedMxInfoLocations(:).SymbolName});
            id_strs=char({InstrumentedMxInfoLocations(:).MxInfoIDStr});

            spaces=' ';spaces=spaces(ones(size(names,1),1));

            full_names_and_id_strs=[names,spaces,id_strs];

            [unique_names_and_id_strs,unique_index]=unique(full_names_and_id_strs,'rows','legacy');
            names_and_mxinfoids=full_names_and_mxinfoids(unique_index,:);


            named_variable_index=unique_names_and_id_strs(:,1)~=' ';
            names_and_mxinfoids=names_and_mxinfoids(named_variable_index,:);
            number_of_named_variables_by_mxInfoID=size(names_and_mxinfoids,1);

            names=names_and_mxinfoids(:,1);
            named_mxinfoids=[names_and_mxinfoids{:,2}];

            for j=1:length(InstrumentedMxInfoLocations)
                SymbolName=InstrumentedMxInfoLocations(j).SymbolName;
                if~isempty(SymbolName)
                    MxInfoID=InstrumentedMxInfoLocations(j).MxInfoID;
                    name_match_index=find(ismember(names,SymbolName,'legacy')==1);
                    id_match_index=named_mxinfoids(name_match_index)==MxInfoID;
                    InstrumentedMxInfoLocations(j).SymbolID=name_match_index(id_match_index);
                end
            end


            for j=1:length(InstrumentedMxInfoLocations)
                idx=mxInfoLocation_to_LoggedLocationsIndex(j);
                if idx~=0












                    nLoggedFields=numel(SimMinVector{idx});
                    InstrumentedMxInfoLocations(j).IsLoggedLocation=true;
                    InstrumentedMxInfoLocations(j).SimMin(1:nLoggedFields)=SimMinVector{idx};
                    InstrumentedMxInfoLocations(j).SimMax(1:nLoggedFields)=SimMaxVector{idx};
                    InstrumentedMxInfoLocations(j).OverflowWraps(1:nLoggedFields)=NumberOfOverflowWrapsVector{idx};
                    InstrumentedMxInfoLocations(j).Saturations(1:nLoggedFields)=NumberOfSaturationsVector{idx};
                    if~isempty(LoggedFieldNamesVector{idx})





                        InstrumentedMxInfoLocations(j).LoggedFieldNames(1:nLoggedFields)=LoggedFieldNamesVector{idx};
                    end
                    InstrumentedMxInfoLocations(j).IsAlwaysInteger(1:nLoggedFields)=IsAlwaysIntegerVector{idx};
                    InstrumentedMxInfoLocations(j).NumberOfZeros(1:nLoggedFields)=NumberOfZerosVector{idx};
                    InstrumentedMxInfoLocations(j).NumberOfNegativeValues(1:nLoggedFields)=NumberOfNegativeValuesVector{idx};
                    InstrumentedMxInfoLocations(j).NumberOfPositiveValues(1:nLoggedFields)=NumberOfPositiveValuesVector{idx};
                    InstrumentedMxInfoLocations(j).TotalNumberOfValues(1:nLoggedFields)=TotalNumberOfValuesVector{idx};
                    InstrumentedMxInfoLocations(j).SimSum(1:nLoggedFields)=SimSumVector{idx};
                    InstrumentedMxInfoLocations(j).HistogramOfPositiveValues(1:nLoggedFields,:)=HistogramOfPositiveValuesVector{idx};
                    InstrumentedMxInfoLocations(j).HistogramOfNegativeValues(1:nLoggedFields,:)=HistogramOfNegativeValuesVector{idx};
                    InstrumentedMxInfoLocations(j).Reason=Reasons(idx);
                    InstrumentedMxInfoLocations(j).VarIDsArrayIndex=VarIDsMappingInfo{idx};
                end
            end



            for j=1:length(InstrumentedMxInfoLocations)
                if isequal('=',InstrumentedMxInfoLocations(j).NodeTypeName)

                    TextStart=InstrumentedMxInfoLocations(j).TextStart;
                    TextLength=InstrumentedMxInfoLocations(j).TextLength;
                    [TextStart,TextLength]=emlcprivate('uniposition',unicodemap,TextStart,TextLength);
                    if TextLength>0
                        str=ScriptText(TextStart:(TextStart+TextLength-1));
                        if~isempty(str)
                            idx=find(TextStart==LoggedTextStarts,1);
                            if~isempty(idx)
                                InstrumentedMxInfoLocations(j).IsLoggedLocation=true;
                                InstrumentedMxInfoLocations(j).SimMin=SimMinVector{idx};
                                InstrumentedMxInfoLocations(j).SimMax=SimMaxVector{idx};
                                InstrumentedMxInfoLocations(j).IsAlwaysInteger=IsAlwaysIntegerVector{idx};
                                InstrumentedMxInfoLocations(j).NumberOfZeros=NumberOfZerosVector{idx};
                                InstrumentedMxInfoLocations(j).NumberOfNegativeValues=NumberOfNegativeValuesVector{idx};
                                InstrumentedMxInfoLocations(j).NumberOfPositiveValues=NumberOfPositiveValuesVector{idx};
                                InstrumentedMxInfoLocations(j).OverflowWraps=NumberOfOverflowWrapsVector{idx};
                                InstrumentedMxInfoLocations(j).Saturations=NumberOfSaturationsVector{idx};
                                InstrumentedMxInfoLocations(j).TotalNumberOfValues=TotalNumberOfValuesVector{idx};
                                InstrumentedMxInfoLocations(j).SimSum=SimSumVector{idx};
                                InstrumentedMxInfoLocations(j).HistogramOfPositiveValues=HistogramOfPositiveValuesVector{idx};
                                InstrumentedMxInfoLocations(j).HistogramOfNegativeValues=HistogramOfNegativeValuesVector{idx};
                                InstrumentedMxInfoLocations(j).Reason=Reasons(idx);
                                InstrumentedMxInfoLocations(j).VarIDsArrayIndex=VarIDsMappingInfo{idx};
                            end
                        end
                    end
                end
            end


            TextStarts=[InstrumentedMxInfoLocations(:).TextStart]';
            TextLengths=[InstrumentedMxInfoLocations(:).TextLength]';
            [TextStarts,TextLengths]=emlcprivate('uniposition',unicodemap,TextStarts,TextLengths);%#ok
            SymbolIDs=[InstrumentedMxInfoLocations(:).SymbolID]';
            Symbol_TextStarts=zeros(size(TextStarts));
            Symbol_TextStarts(SymbolIDs~=0)=TextStarts(SymbolIDs~=0);
            MxInfoIDs=[InstrumentedMxInfoLocations(:).MxInfoID]';
            Symbol_MxInfoIDs=zeros(size(MxInfoIDs));
            Symbol_MxInfoIDs(SymbolIDs~=0)=MxInfoIDs(SymbolIDs~=0);



            Symbols_to_Logs_Index=correlaterows(Symbol_TextStarts,LoggedTextStarts);











            Symbol_IsNumeric=zeros(size(Symbol_MxInfoIDs));
            Symbol_IsNumeric(Symbol_MxInfoIDs~=0)=isLoggableMxInfo(Symbol_MxInfoIDs(Symbol_MxInfoIDs~=0));
            setNode_IsNumeric=ones(size(setNodeMxInfoIDs));
            Symbols_that_match_sets=correlaterows([Symbol_TextStarts,Symbol_IsNumeric],...
            [setNodeTextStarts,setNode_IsNumeric]);
            Symbols_to_Sets_Index=zeros(size(Symbols_to_Logs_Index));
            Symbols_to_Sets_Index(Symbols_that_match_sets~=0)=Symbols_to_Logs_Index(Symbols_that_match_sets~=0);
            for j=1:length(InstrumentedMxInfoLocations)


                idx=Symbols_to_Sets_Index(j);
                if idx~=0

























                    if isequal(InstrumentedMxInfoLocations(j).LoggedFieldNames,...
                        LoggedFieldNamesVector{idx})
                        InstrumentedMxInfoLocations(j).SimMin=...
                        min(InstrumentedMxInfoLocations(j).SimMin,...
                        SimMinVector{idx});
                        InstrumentedMxInfoLocations(j).SimMax=...
                        max(InstrumentedMxInfoLocations(j).SimMax,...
                        SimMaxVector{idx});
                        InstrumentedMxInfoLocations(j).IsAlwaysInteger=...
                        InstrumentedMxInfoLocations(j).IsAlwaysInteger&...
                        IsAlwaysIntegerVector{idx};


                        InstrumentedMxInfoLocations(j).NumberOfZeros=...
                        NumberOfZerosVector{idx};
                        InstrumentedMxInfoLocations(j).NumberOfPositiveValues=...
                        NumberOfPositiveValuesVector{idx};
                        InstrumentedMxInfoLocations(j).NumberOfNegativeValues=...
                        NumberOfNegativeValuesVector{idx};
                        InstrumentedMxInfoLocations(j).TotalNumberOfValues=...
                        TotalNumberOfValuesVector{idx};
                        InstrumentedMxInfoLocations(j).SimSum=...
                        SimSumVector{idx};
                        InstrumentedMxInfoLocations(j).HistogramOfPositiveValues=...
                        HistogramOfPositiveValuesVector{idx};
                        InstrumentedMxInfoLocations(j).HistogramOfNegativeValues=...
                        HistogramOfNegativeValuesVector{idx};
                        InstrumentedMxInfoLocations(j).VarIDsArrayIndex=...
                        [InstrumentedMxInfoLocations(j).VarIDsArrayIndex,VarIDsMappingInfo{idx}];
                    else

                        [~,ia,ib]=intersect(InstrumentedMxInfoLocations(j).LoggedFieldNames,...
                        LoggedFieldNamesVector{idx},'legacy');

                        InstrumentedMxInfoLocations(j).SimMin(ia)=...
                        min(InstrumentedMxInfoLocations(j).SimMin(ia),...
                        SimMinVector{idx}(ib));
                        InstrumentedMxInfoLocations(j).SimMax(ia)=...
                        max(InstrumentedMxInfoLocations(j).SimMax(ia),...
                        SimMaxVector{idx}(ib));
                        InstrumentedMxInfoLocations(j).IsAlwaysInteger(ia)=...
                        InstrumentedMxInfoLocations(j).IsAlwaysInteger(ia)&...
                        IsAlwaysIntegerVector{idx}(ib);


                        InstrumentedMxInfoLocations(j).NumberOfZeros(ia)=...
                        NumberOfZerosVector{idx}(ib);
                        InstrumentedMxInfoLocations(j).NumberOfPositiveValues(ia)=...
                        NumberOfPositiveValuesVector{idx}(ib);
                        InstrumentedMxInfoLocations(j).NumberOfNegativeValues(ia)=...
                        NumberOfNegativeValuesVector{idx}(ib);
                        InstrumentedMxInfoLocations(j).TotalNumberOfValues(ia)=...
                        TotalNumberOfValuesVector{idx}(ib);
                        InstrumentedMxInfoLocations(j).SimSum(ia)=...
                        SimSumVector{idx}(ib);
                        InstrumentedMxInfoLocations(j).HistogramOfPositiveValues(ia,:)=...
                        HistogramOfPositiveValuesVector{idx}(ib,:);
                        InstrumentedMxInfoLocations(j).HistogramOfNegativeValues(ia,:)=...
                        HistogramOfNegativeValuesVector{idx}(ib,:);
                        InstrumentedMxInfoLocations(j).VarIDsArrayIndex=...
                        [InstrumentedMxInfoLocations(j).VarIDsArrayIndex,VarIDsMappingInfo{idx}];
                    end
                end
            end


            number_of_unique_named_variables=length(named_mxinfoids);
            synthesized_logged_field_names=cell(number_of_unique_named_variables,1);
            synthesized_logged_mx_info_ids=cell(number_of_unique_named_variables,1);

            for j=1:length(InstrumentedMxInfoLocations)
                SymbolID=InstrumentedMxInfoLocations(j).SymbolID;
                if(SymbolID~=0)
                    synthesized_logged_field_names{SymbolID}=InstrumentedMxInfoLocations(j).LoggedFieldNames;
                    synthesized_logged_mx_info_ids{SymbolID}=InstrumentedMxInfoLocations(j).LoggedFieldMxInfoIDs;
                end
            end
            synthesized_textstarts=cell(number_of_unique_named_variables,1);
            synthesized_is_argin=false(number_of_unique_named_variables,1);
            synthesized_is_argout=false(number_of_unique_named_variables,1);
            synthesized_is_global=false(number_of_unique_named_variables,1);
            synthesized_is_persistent=false(number_of_unique_named_variables,1);
            synthesized_mins=cell(number_of_unique_named_variables,1);
            synthesized_maxs=cell(number_of_unique_named_variables,1);
            synthesized_is_always_integers=cell(number_of_unique_named_variables,1);
            synthesized_numberOfZeros=cell(number_of_unique_named_variables,1);
            synthesized_numberOfPositiveValues=cell(number_of_unique_named_variables,1);
            synthesized_numberOfNegativeValues=cell(number_of_unique_named_variables,1);
            synthesized_totalNumberOfValues=cell(number_of_unique_named_variables,1);
            synthesized_simSum=cell(number_of_unique_named_variables,1);
            synthesized_histogramOfPositiveValues=cell(number_of_unique_named_variables,1);
            synthesized_histogramOfNegativeValues=cell(number_of_unique_named_variables,1);
            synthesized_InstrumentedMxinfoLocationIDs=cell(number_of_unique_named_variables,1);
            number_of_logged_field_mx_info_ids=zeros(number_of_unique_named_variables,1);
            for j=1:number_of_unique_named_variables
                n_logs=max(1,length(synthesized_logged_field_names{j}));
                synthesized_mins{j}=inf(1,n_logs);
                synthesized_maxs{j}=-inf(1,n_logs);
                synthesized_is_always_integers{j}=true(1,n_logs);
                synthesized_numberOfZeros{j}=zeros(1,n_logs);
                synthesized_numberOfPositiveValues{j}=zeros(1,n_logs);
                synthesized_numberOfNegativeValues{j}=zeros(1,n_logs);
                synthesized_totalNumberOfValues{j}=zeros(1,n_logs);
                synthesized_simSum{j}=zeros(1,n_logs);
                synthesized_histogramOfPositiveValues{j}=zeros(n_logs,instrumentedVariables.NumberOfHistogramBins);
                synthesized_histogramOfNegativeValues{j}=zeros(n_logs,instrumentedVariables.NumberOfHistogramBins);
            end

            for j=1:length(InstrumentedMxInfoLocations)
                SymbolID=InstrumentedMxInfoLocations(j).SymbolID;
                if(SymbolID~=0)
                    if length(synthesized_mins{SymbolID})==length(InstrumentedMxInfoLocations(j).SimMin)
                        synthesized_mins{SymbolID}=...
                        min(synthesized_mins{SymbolID},InstrumentedMxInfoLocations(j).SimMin);
                        synthesized_InstrumentedMxinfoLocationIDs{SymbolID}=[synthesized_InstrumentedMxinfoLocationIDs{SymbolID},j];
                    end
                    if length(synthesized_maxs{SymbolID})==length(InstrumentedMxInfoLocations(j).SimMax)
                        synthesized_maxs{SymbolID}=...
                        max(synthesized_maxs{SymbolID},InstrumentedMxInfoLocations(j).SimMax);
                    end
                    if length(synthesized_is_always_integers{SymbolID})==length(InstrumentedMxInfoLocations(j).IsAlwaysInteger)
                        synthesized_is_always_integers{SymbolID}=...
                        synthesized_is_always_integers{SymbolID}&InstrumentedMxInfoLocations(j).IsAlwaysInteger;
                    end
                    if length(synthesized_numberOfZeros{SymbolID})==length(InstrumentedMxInfoLocations(j).NumberOfZeros)





                        synthesized_numberOfZeros{SymbolID}=...
                        synthesized_numberOfZeros{SymbolID}+...
                        InstrumentedMxInfoLocations(j).NumberOfZeros;
                        synthesized_numberOfPositiveValues{SymbolID}=...
                        synthesized_numberOfPositiveValues{SymbolID}+...
                        InstrumentedMxInfoLocations(j).NumberOfPositiveValues;
                        synthesized_numberOfNegativeValues{SymbolID}=...
                        synthesized_numberOfNegativeValues{SymbolID}+...
                        InstrumentedMxInfoLocations(j).NumberOfNegativeValues;
                        synthesized_totalNumberOfValues{SymbolID}=...
                        synthesized_totalNumberOfValues{SymbolID}+...
                        InstrumentedMxInfoLocations(j).TotalNumberOfValues;
                        synthesized_simSum{SymbolID}=...
                        synthesized_simSum{SymbolID}+...
                        InstrumentedMxInfoLocations(j).SimSum;
                        synthesized_histogramOfPositiveValues{SymbolID}=...
                        synthesized_histogramOfPositiveValues{SymbolID}+...
                        InstrumentedMxInfoLocations(j).HistogramOfPositiveValues;
                        synthesized_histogramOfNegativeValues{SymbolID}=...
                        synthesized_histogramOfNegativeValues{SymbolID}+...
                        InstrumentedMxInfoLocations(j).HistogramOfNegativeValues;
                    end
                    synthesized_textstarts{SymbolID}(end+1)=...
                    InstrumentedMxInfoLocations(j).TextStart;
                    synthesized_is_argin(SymbolID)=...
                    synthesized_is_argin(SymbolID)||...
                    InstrumentedMxInfoLocations(j).IsArgin;
                    synthesized_is_argout(SymbolID)=...
                    synthesized_is_argout(SymbolID)||...
                    InstrumentedMxInfoLocations(j).IsArgout;
                    synthesized_is_global(SymbolID)=...
                    synthesized_is_global(SymbolID)||...
                    InstrumentedMxInfoLocations(j).IsGlobal;
                    synthesized_is_persistent(SymbolID)=...
                    synthesized_is_persistent(SymbolID)||...
                    InstrumentedMxInfoLocations(j).IsPersistent;
                    number_of_logged_field_mx_info_ids(SymbolID)=length([InstrumentedMxInfoLocations(j).LoggedFieldMxInfoIDs{:}]);
                end
            end

            for j=1:length(InstrumentedMxInfoLocations)
                SymbolID=InstrumentedMxInfoLocations(j).SymbolID;
                if(SymbolID~=0)
                    if length(synthesized_mins{SymbolID})==length(InstrumentedMxInfoLocations(j).SimMin)
                        InstrumentedMxInfoLocations(j).SimMin=...
                        min(synthesized_mins{SymbolID},InstrumentedMxInfoLocations(j).SimMin);
                    end
                    if length(synthesized_maxs{SymbolID})==length(InstrumentedMxInfoLocations(j).SimMax)
                        InstrumentedMxInfoLocations(j).SimMax=...
                        max(synthesized_maxs{SymbolID},InstrumentedMxInfoLocations(j).SimMax);
                    end
                    if length(synthesized_is_always_integers{SymbolID})==length(InstrumentedMxInfoLocations(j).IsAlwaysInteger)
                        InstrumentedMxInfoLocations(j).IsAlwaysInteger=...
                        synthesized_is_always_integers{SymbolID}&InstrumentedMxInfoLocations(j).IsAlwaysInteger;
                    end
                    if length(synthesized_numberOfZeros{SymbolID})==length(InstrumentedMxInfoLocations(j).NumberOfZeros)
                        InstrumentedMxInfoLocations(j).NumberOfZeros=...
                        synthesized_numberOfZeros{SymbolID};
                        InstrumentedMxInfoLocations(j).NumberOfPositiveValues=...
                        synthesized_numberOfPositiveValues{SymbolID};
                        InstrumentedMxInfoLocations(j).NumberOfNegativeValues=...
                        synthesized_numberOfNegativeValues{SymbolID};
                        InstrumentedMxInfoLocations(j).TotalNumberOfValues=...
                        synthesized_totalNumberOfValues{SymbolID};
                        InstrumentedMxInfoLocations(j).SimSum=...
                        synthesized_simSum{SymbolID};
                        InstrumentedMxInfoLocations(j).HistogramOfPositiveValues=...
                        synthesized_histogramOfPositiveValues{SymbolID};
                        InstrumentedMxInfoLocations(j).HistogramOfNegativeValues=...
                        synthesized_histogramOfNegativeValues{SymbolID};
                    end
                end
            end

            InstrumentedMxInfoLocations=strip_unlogged_fields_from_InstrumentedMxInfoLocations(InstrumentedMxInfoLocations);

        end











        UnnamedToolTipOffset=number_of_named_variables_by_mxInfoID;
        for j=1:length(InstrumentedMxInfoLocations)
            if isLoggableMxInfo(InstrumentedMxInfoLocations(j).MxInfoID)&&...
                (InstrumentedMxInfoLocations(j).SymbolID~=0)

                InstrumentedMxInfoLocations(j).IsInstrumented=true;
                ToolTipID=InstrumentedMxInfoLocations(j).SymbolID+NamedToolTipOffset;
                InstrumentedMxInfoLocations(j).ToolTipID=ToolTipID;
            elseif any(InstrumentedMxInfoLocations(j).SimMin<=InstrumentedMxInfoLocations(j).SimMax)

                InstrumentedMxInfoLocations(j).IsInstrumented=true;
                UnnamedToolTipOffset=UnnamedToolTipOffset+1;
                ToolTipID=NamedToolTipOffset+UnnamedToolTipOffset;
                InstrumentedMxInfoLocations(j).ToolTipID=ToolTipID;
            else

                InstrumentedMxInfoLocations(j).IsInstrumented=false;
                ToolTipID=InstrumentedMxInfoLocations(j).MxInfoID;
                InstrumentedMxInfoLocations(j).ToolTipID=ToolTipID;
            end
        end
        NamedToolTipOffset=NamedToolTipOffset+UnnamedToolTipOffset;


        instrumentedVariables.Functions(instr_fun_index).FunctionName=results.Functions(i).FunctionName;
        instrumentedVariables.Functions(instr_fun_index).FunctionID=results.Functions(i).FunctionID;

        instrumentedVariables.Functions(instr_fun_index).NamedVariables=[];
        k=1;
        for j=1:size(names_and_mxinfoids,1)
            if any(synthesized_mins{j}<=synthesized_maxs{j})

                SymbolName=names_and_mxinfoids{j,1};
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).SymbolName=SymbolName;
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).MxInfoID=names_and_mxinfoids{j,2};
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).SimMin=synthesized_mins{j};
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).SimMax=synthesized_maxs{j};
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).IsAlwaysInteger=synthesized_is_always_integers{j};
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).NumberOfZeros=synthesized_numberOfZeros{j};
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).NumberOfPositiveValues=synthesized_numberOfPositiveValues{j};
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).NumberOfNegativeValues=synthesized_numberOfNegativeValues{j};
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).TotalNumberOfValues=synthesized_totalNumberOfValues{j};
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).SimSum=synthesized_simSum{j};
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).HistogramOfPositiveValues=synthesized_histogramOfPositiveValues{j};
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).HistogramOfNegativeValues=synthesized_histogramOfNegativeValues{j};
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).LoggedFieldNames=synthesized_logged_field_names{j};
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).LoggedFieldMxInfoIDs=synthesized_logged_mx_info_ids{j};
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).TextStarts=synthesized_textstarts{j};
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).TextLength=length(SymbolName);
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).IsArgin=synthesized_is_argin(j);
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).IsArgout=synthesized_is_argout(j);
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).IsGlobal=synthesized_is_global(j);
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).IsPersistent=synthesized_is_persistent(j);
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).IsCppSystemObject=false;
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).MxInfoLocationIDs=synthesized_InstrumentedMxinfoLocationIDs{j};
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).SpecifiedDT=[];
                instrumentedVariables.Functions(instr_fun_index).NamedVariables(k).CompiledDT=[];
                k=k+1;
            end
        end







        isSOnode=(Reasons==REASON_CPPSYSOBJ);
        if any(isSOnode)

            [InstrumentedMxInfoLocations,instrumentedVariables]=processLogableCppSystemObject(InstrumentedMxInfoLocations,...
            isSOnode,T,LoggedTextStarts,LoggedTextLengths,mxInfoLocation_TextStarts,...
            mxInfoLocation_TextLengths,mxInfoLocation_MxInfoIDs,LoggedFieldNamesVector,...
            SimMinVector,SimMaxVector,IsAlwaysIntegerVector,NumberOfZerosVector,...
            NumberOfPositiveValuesVector,NumberOfNegativeValuesVector,TotalNumberOfValuesVector,...
            SimSumVector,HistogramOfPositiveValuesVector,HistogramOfNegativeValuesVector,...
            instrumentedVariables.NumberOfHistogramBins>0,REASON_CPPSYSOBJ,...
            isCallerMLFcnBlk,instrumentedVariables);
        end


        CompilationReport.InstrumentedData.InstrumentedFunctions(instr_fun_index).FunctionID=FunctionID;
        CompilationReport.InstrumentedData.InstrumentedFunctions(instr_fun_index).InstrumentedMxInfoLocations=InstrumentedMxInfoLocations;
    end



    originalToolTipIDs=[];
    for i=1:length(CompilationReport.InstrumentedData.InstrumentedFunctions)
        if~isempty(CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations)
            originalToolTipIDs=[...
originalToolTipIDs
            [CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(:).ToolTipID]'
            ];
        end
    end
    if max(originalToolTipIDs)>=intmax('int32')


        error(message('fixed:instrumentation:ProjectTooLarge','showInstrumentationResults'));
    end



    number_of_MxInfos=length(inference_report.MxInfos);
    loggedToolTipID_index=originalToolTipIDs>number_of_MxInfos;
    [~,~,J]=unique(originalToolTipIDs(loggedToolTipID_index),'first','legacy');
    J=J+number_of_MxInfos;
    k=0;
    for i=1:length(CompilationReport.InstrumentedData.InstrumentedFunctions)
        for j=1:length(CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations)
            if CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).ToolTipID>number_of_MxInfos
                k=k+1;
                CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).ToolTipID=J(k);
            end
        end
    end
    if isempty(J)
        MaxToolTipID=number_of_MxInfos;
    else
        MaxToolTipID=max(J);
    end


    CompilationReport.InstrumentedData.options=opts;


    CompilationReport.InstrumentedData.MaxToolTipID=MaxToolTipID;

    [CompilationReport,instrumentedVariables]=...
    proposeWordLengthsFractionLengthsOutOfRange(CompilationReport,instrumentedVariables);


    instrumentedVariables=populate_InstanceCount_NumberOfInstances(instrumentedVariables);


    CompilationReport.InstrumentedData.InstrumentedVariables=instrumentedVariables;

end

function[InstrumentedMxInfoLocations,instrumentedVariables]=processLogableCppSystemObject(InstrumentedMxInfoLocations,...
    isSOnode,T,LoggedTextStarts,LoggedTextLengths,mxInfoLocation_TextStarts,...
    mxInfoLocation_TextLengths,mxInfoLocation_MxInfoIDs,LoggedFieldNamesVector,...
    SimMinVector,SimMaxVector,IsAlwaysIntegerVector,NumberOfZerosVector,...
    NumberOfPositiveValuesVector,NumberOfNegativeValuesVector,TotalNumberOfValuesVector,...
    SimSumVector,HistogramOfPositiveValuesVector,HistogramOfNegativeValuesVector,...
    isHistogramEnabled,REASON_CPPSYSOBJ,isCallerMLFcnBlk,instrumentedVariables)











    isSOnodeIdx=find(isSOnode);
    dot_nodes=mtfind(T,'Kind','DOT');
    dot_nodes_parents=Parent(dot_nodes);
    dot_nodes_parents_indices=indices(dot_nodes_parents);
    isEqualsNode=iskind(dot_nodes_parents,'EQUALS');
    eq_nodes_indices=dot_nodes_parents_indices(isEqualsNode);
    not_eq_nodes_indices=dot_nodes_parents_indices(~isEqualsNode);
    while~isempty(not_eq_nodes_indices)




        tmp_nodes=select(T,not_eq_nodes_indices);
        tmp_nodes_parents=Parent(tmp_nodes);
        tmp_nodes_parents_indices=indices(tmp_nodes_parents);
        isEqualsNode=iskind(tmp_nodes_parents,'EQUALS');
        eq_nodes_indices=[eq_nodes_indices,tmp_nodes_parents_indices(isEqualsNode)];
        not_eq_nodes_indices=tmp_nodes_parents_indices(~isEqualsNode);
    end
    dot_nodes_parents=select(T,eq_nodes_indices);
    dot_nodes_parents_right=Right(dot_nodes_parents);
    dot_nodes_parents_right_TextStarts=lefttreepos(dot_nodes_parents_right);
    dot_nodes_parents_right_TextLengths=righttreepos(dot_nodes_parents_right)-lefttreepos(dot_nodes_parents_right)+1;
    LoggedLocations=[LoggedTextStarts(isSOnode),LoggedTextLengths(isSOnode)];
    dot_nodes_parents_right_TextLocations=[dot_nodes_parents_right_TextStarts,dot_nodes_parents_right_TextLengths];
    [~,~,id]=intersect(LoggedLocations,dot_nodes_parents_right_TextLocations,'rows');
    ind=indices(dot_nodes_parents_right);
    ind_interest=ind(id);
    sysobj_constructor_node=select(T,ind_interest);
    sysobj_var_node=Left(Parent(sysobj_constructor_node));
    sysobj_var_TextLocations=[sysobj_var_node.lefttreepos,sysobj_var_node.righttreepos-sysobj_var_node.lefttreepos+1];
    mxInfoLocation_TextLocations=[mxInfoLocation_TextStarts,mxInfoLocation_TextLengths];
    [~,im,~]=intersect(mxInfoLocation_TextLocations,sysobj_var_TextLocations,'rows');
    soNodeMxInfoID=mxInfoLocation_MxInfoIDs(im);

    if isCallerMLFcnBlk


        symbolIdx=numel(instrumentedVariables.Functions(end).NamedVariables);
        symbolToIdxMap=containers.Map('KeyType','char','ValueType','double');
        if(symbolIdx==0)


            instrumentedVariables.Functions(end).NamedVariables(1).TextStarts=[];
            instrumentedVariables.Functions(end).NamedVariables(1).MxInfoLocationIDs=[];
            instrumentedVariables.Functions(end).NamedVariables(1).SpecifiedDT=[];
            instrumentedVariables.Functions(end).NamedVariables(1).CompiledDT=[];
        end
    end




    for k=1:length(isSOnodeIdx)





        nTotalFields=length(LoggedFieldNamesVector{isSOnodeIdx(k)});
        unusedProps=regexp(LoggedFieldNamesVector{isSOnodeIdx(k)},'^_');
        if(length(cell2mat(unusedProps))==nTotalFields)
            continue;
        end
        if isCallerMLFcnBlk
            sysObjMxInfo=instrumentedVariables.MxInfos{soNodeMxInfoID(k)};
            FieldNamesMxInfoIds=cell(1,nTotalFields);
            for j=nTotalFields:-1:1
                if strcmp(LoggedFieldNamesVector{isSOnodeIdx(k)}{j}(1),'_')



                    clearLoggingDataForUnusedField();
                    FieldNamesMxInfoIds(j)=[];
                else



                    for l=numel(sysObjMxInfo.ClassProperties):-1:1
                        if strcmpi(sysObjMxInfo.ClassProperties(l).PropertyName,LoggedFieldNamesVector{isSOnodeIdx(k)}{j})
                            FieldNamesMxInfoIds{j}=sysObjMxInfo.ClassProperties(l).MxInfoID;
                            break;
                        end
                    end
                end
            end
        else



            for j=nTotalFields:-1:1
                if strcmp(LoggedFieldNamesVector{isSOnodeIdx(k)}{j}(1),'_')
                    clearLoggingDataForUnusedField();
                end
            end
        end
        nFields=numel(LoggedFieldNamesVector{isSOnodeIdx(k)});
        SymbolName=InstrumentedMxInfoLocations(im(k)).SymbolName;
        if isCallerMLFcnBlk
            if symbolToIdxMap.isKey(SymbolName)&&(instrumentedVariables.Functions(end).NamedVariables(symbolToIdxMap(SymbolName)).MxInfoID==soNodeMxInfoID(k))

                currSymbolIdx=symbolToIdxMap(SymbolName);
            else

                symbolIdx=symbolIdx+1;
                symbolToIdxMap(SymbolName)=symbolIdx;
                currSymbolIdx=symbolIdx;
                instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).SymbolName=SymbolName;
                instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).MxInfoID=soNodeMxInfoID(k);
                instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).LoggedFieldNames=LoggedFieldNamesVector{isSOnodeIdx(k)};
                instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).LoggedFieldMxInfoIDs=FieldNamesMxInfoIds;
                instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).IsArgin=false;
                instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).IsArgout=false;
                instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).IsGlobal=false;
                instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).IsPersistent=false;
                instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).IsCppSystemObject=true;
            end
        end
        matchingIdx=find(mxInfoLocation_MxInfoIDs==soNodeMxInfoID(k));
        for j=1:length(matchingIdx)
            currIdx=matchingIdx(j);
            if strcmp(InstrumentedMxInfoLocations(currIdx).NodeTypeName,'var')&&...
                strcmp(InstrumentedMxInfoLocations(currIdx).SymbolName,SymbolName)




                if(InstrumentedMxInfoLocations(currIdx).SimMin>InstrumentedMxInfoLocations(currIdx).SimMax)


                    InstrumentedMxInfoLocations(currIdx).IsLoggedLocation=true;
                    InstrumentedMxInfoLocations(currIdx).IsInstrumented=true;
                    InstrumentedMxInfoLocations(currIdx).LoggedFieldNames=LoggedFieldNamesVector{isSOnodeIdx(k)};
                    InstrumentedMxInfoLocations(currIdx).SimMin=SimMinVector{isSOnodeIdx(k)};
                    InstrumentedMxInfoLocations(currIdx).SimMax=SimMaxVector{isSOnodeIdx(k)};
                    InstrumentedMxInfoLocations(currIdx).OverflowWraps=zeros(1,nFields);
                    InstrumentedMxInfoLocations(currIdx).Saturations=zeros(1,nFields);
                    InstrumentedMxInfoLocations(currIdx).IsAlwaysInteger=IsAlwaysIntegerVector{isSOnodeIdx(k)};
                    InstrumentedMxInfoLocations(currIdx).NumberOfZeros=NumberOfZerosVector{isSOnodeIdx(k)};
                    InstrumentedMxInfoLocations(currIdx).NumberOfPositiveValues=NumberOfPositiveValuesVector{isSOnodeIdx(k)};
                    InstrumentedMxInfoLocations(currIdx).NumberOfNegativeValues=NumberOfNegativeValuesVector{isSOnodeIdx(k)};
                    InstrumentedMxInfoLocations(currIdx).TotalNumberOfValues=TotalNumberOfValuesVector{isSOnodeIdx(k)};
                    InstrumentedMxInfoLocations(currIdx).SimSum=SimSumVector{isSOnodeIdx(k)};
                    InstrumentedMxInfoLocations(currIdx).HistogramOfPositiveValues=HistogramOfPositiveValuesVector{isSOnodeIdx(k)};
                    InstrumentedMxInfoLocations(currIdx).HistogramOfNegativeValues=HistogramOfNegativeValuesVector{isSOnodeIdx(k)};
                    InstrumentedMxInfoLocations(currIdx).Reason=REASON_CPPSYSOBJ;
                else









                    if~all(strcmp(InstrumentedMxInfoLocations(currIdx).LoggedFieldNames,...
                        LoggedFieldNamesVector{isSOnodeIdx(k)}))
                        continue;
                    end



                    InstrumentedMxInfoLocations(currIdx).SimMin=min(SimMinVector{isSOnodeIdx(k)},InstrumentedMxInfoLocations(currIdx).SimMin);
                    InstrumentedMxInfoLocations(currIdx).SimMax=max(SimMaxVector{isSOnodeIdx(k)},InstrumentedMxInfoLocations(currIdx).SimMax);
                    InstrumentedMxInfoLocations(currIdx).OverflowWraps=zeros(1,nFields);
                    InstrumentedMxInfoLocations(currIdx).Saturations=zeros(1,nFields);
                    InstrumentedMxInfoLocations(currIdx).IsAlwaysInteger=IsAlwaysIntegerVector{isSOnodeIdx(k)}|InstrumentedMxInfoLocations(currIdx).IsAlwaysInteger;
                    InstrumentedMxInfoLocations(currIdx).NumberOfZeros=NumberOfZerosVector{isSOnodeIdx(k)}+InstrumentedMxInfoLocations(currIdx).NumberOfZeros;
                    InstrumentedMxInfoLocations(currIdx).NumberOfPositiveValues=NumberOfPositiveValuesVector{isSOnodeIdx(k)}+InstrumentedMxInfoLocations(currIdx).NumberOfPositiveValues;
                    InstrumentedMxInfoLocations(currIdx).NumberOfNegativeValues=NumberOfNegativeValuesVector{isSOnodeIdx(k)}+InstrumentedMxInfoLocations(currIdx).NumberOfNegativeValues;
                    InstrumentedMxInfoLocations(currIdx).TotalNumberOfValues=TotalNumberOfValuesVector{isSOnodeIdx(k)}+InstrumentedMxInfoLocations(currIdx).TotalNumberOfValues;
                    InstrumentedMxInfoLocations(currIdx).SimSum=SimSumVector{isSOnodeIdx(k)}+InstrumentedMxInfoLocations(currIdx).SimSum;
                    InstrumentedMxInfoLocations(currIdx).HistogramOfPositiveValues=HistogramOfPositiveValuesVector{isSOnodeIdx(k)}+InstrumentedMxInfoLocations(currIdx).HistogramOfPositiveValues;
                    InstrumentedMxInfoLocations(currIdx).HistogramOfNegativeValues=HistogramOfNegativeValuesVector{isSOnodeIdx(k)}+InstrumentedMxInfoLocations(currIdx).HistogramOfNegativeValues;
                end
                if isCallerMLFcnBlk

                    InstrumentedMxInfoLocations(currIdx).LoggedFieldMxInfoIDs=FieldNamesMxInfoIds;
                    instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).TextLength=InstrumentedMxInfoLocations(currIdx).TextLength;
                    instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).TextStarts(end+1)=InstrumentedMxInfoLocations(currIdx).TextStart;
                    instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).SimMin=InstrumentedMxInfoLocations(currIdx).SimMin;
                    instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).SimMax=InstrumentedMxInfoLocations(currIdx).SimMax;
                    instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).IsAlwaysInteger=InstrumentedMxInfoLocations(currIdx).IsAlwaysInteger;
                    instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).NumberOfZeros=InstrumentedMxInfoLocations(currIdx).NumberOfZeros;
                    instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).NumberOfPositiveValues=InstrumentedMxInfoLocations(currIdx).NumberOfPositiveValues;
                    instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).NumberOfNegativeValues=InstrumentedMxInfoLocations(currIdx).NumberOfNegativeValues;
                    instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).TotalNumberOfValues=InstrumentedMxInfoLocations(currIdx).TotalNumberOfValues;
                    instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).SymbolName=SymbolName;
                    instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).SimSum=InstrumentedMxInfoLocations(currIdx).SimSum;
                    instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).HistogramOfPositiveValues=InstrumentedMxInfoLocations(currIdx).HistogramOfPositiveValues;
                    instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).HistogramOfNegativeValues=InstrumentedMxInfoLocations(currIdx).HistogramOfNegativeValues;
                    instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).MxInfoLocationIDs(end+1)=currIdx;
                    instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).IsArgin=instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).IsArgin||...
                    InstrumentedMxInfoLocations(currIdx).IsArgin;
                    instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).IsArgout=instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).IsArgin||...
                    InstrumentedMxInfoLocations(currIdx).IsArgout;
                    instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).IsGlobal=instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).IsArgin||...
                    InstrumentedMxInfoLocations(currIdx).IsGlobal;
                    instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).IsPersistent=instrumentedVariables.Functions(end).NamedVariables(currSymbolIdx).IsArgin||...
                    InstrumentedMxInfoLocations(currIdx).IsPersistent;
                end
            end
        end

    end
    function clearLoggingDataForUnusedField()

        LoggedFieldNamesVector{isSOnodeIdx(k)}(j)=[];
        SimMinVector{isSOnodeIdx(k)}(j)=[];
        SimMaxVector{isSOnodeIdx(k)}(j)=[];
        IsAlwaysIntegerVector{isSOnodeIdx(k)}(j)=[];
        NumberOfZerosVector{isSOnodeIdx(k)}(j)=[];
        NumberOfPositiveValuesVector{isSOnodeIdx(k)}(j)=[];
        NumberOfNegativeValuesVector{isSOnodeIdx(k)}(j)=[];
        TotalNumberOfValuesVector{isSOnodeIdx(k)}(j)=[];
        SimSumVector{isSOnodeIdx(k)}(j)=[];
        if isHistogramEnabled
            HistogramOfPositiveValuesVector{isSOnodeIdx(k)}(j,:)=[];
            HistogramOfNegativeValuesVector{isSOnodeIdx(k)}(j,:)=[];
        end
    end
end


function a_to_b=correlaterows(a,b)

















    [a_sorted,a_idx]=sortrows(a);
    [b_sorted,b_idx]=sortrows(b);

    a_to_b=zeros(size(a,1),1);
    k=1;
    j=1;
    while j<=size(a,1)&&k<=size(b,1)
        a_j=a_sorted(j,:);
        b_k=b_sorted(k,:);

        if isequal(a_j,b_k)


            orig_j=a_idx(j,1);
            orig_k=b_idx(k,1);
            a_to_b(orig_j)=orig_k;
            j=j+1;
        elseif lerows(a_j,b_k)
            j=j+1;
        else
            k=k+1;
        end
    end
end


function t=lerows(a,b)



    [~,I]=sortrows([a;b]);
    t=I(1)==1;
end


function field_cell=getFieldNamesFromText(sub_text)










    sub_text_tree=mtree(sub_text);
    if~isempty(mtfind(sub_text_tree,'Kind','FOR'))


        field_cell={};
    else
        field_names=get_struct_fields(sub_text);
        if isempty(field_names)
            field_cell={};
        else
            fieldStr=sprintf('%s.',field_names{:});
            fieldStr(end)=[];
            field_cell={fieldStr};
        end
    end
end

function[field_names,variable_name]=get_struct_fields(str)
    T=mtree(str);
    n=T.select(1);
    variable_name='';
    field_names={};
    walk_tree(n);
    function walk_tree(n)
        kind=n.kind;
        switch kind
        case 'PRINT'


            walk_tree(n.Arg);
        case{'EQUALS','SUBSCR'}



            walk_tree(n.Left);
        case 'DOT'

            walk_tree(n.Left);
            walk_tree(n.Right);
        case 'DOTLP'




            walk_tree(n.Left);
        case 'ID'

            variable_name=n.string;
        case 'FIELD'

            field_names{end+1}=n.string;
        end
    end
end


function t=is_numeric_MxInfo(mx_info)
    t=false;
    switch class(mx_info)
    case{'eml.MxFiInfo','eml.MxNumericInfo'}
        t=true;
    case{'eml.MxInfo'}
        if isequal(mx_info.Class,'logical')
            t=true;
        end
    end
end


function LoggedFieldMxInfoIDs=getLoggedFieldMxInfoIDs(logged_field_names,loggable_field_names,loggable_field_mx_info_ids)


    [~,ia,ib]=intersect(logged_field_names,loggable_field_names,'legacy');
    LoggedFieldMxInfoIDs=cell(1,length(logged_field_names));
    LoggedFieldMxInfoIDs(ia)=loggable_field_mx_info_ids(ib);
end


function[loggable_field_names,loggable_field_mx_info_ids]=getLoggableFieldNames(mx_info_id,MxInfos,isNumericMxInfo)
    loggable_field_names={};
    loggable_field_mx_info_ids={};
    name={};
    ids=[];
    field_tree_listing(mx_info_id);

    function field_tree_listing(mx_info_id)
        mx_info=MxInfos{mx_info_id};
        if isa(mx_info,'eml.MxStructInfo')
            for i=1:length(mx_info.StructFields)
                name{end+1}=mx_info.StructFields(i).FieldName;
                ids(end+1)=mx_info.StructFields(i).MxInfoID;
                nextRootID=mx_info.StructFields(i).MxInfoID;
                field_tree_listing(nextRootID);
                if isNumericMxInfo(nextRootID)
                    nameStr=sprintf('%s.',name{:});
                    nameStr(end)=[];
                    loggable_field_names{end+1}=nameStr;
                    loggable_field_mx_info_ids{end+1}=ids;
                end
                name(end)=[];
                ids(end)=[];
            end
        elseif isa(mx_info,'eml.MxCellInfo')
            for i=1:numel(mx_info.CellElements)
                if mx_info.Homogeneous
                    idx=':';
                else
                    idx=int2str(i);
                end
                name{end+1}=['{',idx,'}'];
                ids(end+1)=mx_info.CellElements(i);
                nextRootID=mx_info.CellElements(i);
                field_tree_listing(nextRootID);
                if isNumericMxInfo(nextRootID)
                    nameStr=sprintf('%s',name{:});
                    loggable_field_names{end+1}=nameStr;
                    loggable_field_mx_info_ids{end+1}=ids;
                end
                name(end)=[];
                ids(end)=[];
            end
        end
    end
end


function[CompilationReport,instrumentedVariables]=proposeWordLengthsFractionLengthsOutOfRange(CompilationReport,instrumentedVariables)

    opts=CompilationReport.InstrumentedData.options;

    MxInfos=CompilationReport.inference.MxInfos;
    MxArrays=CompilationReport.inference.MxArrays;



    anyScaledTypes=false;
    anyBinaryPointScaledDoubleTypes=false;%#ok<NASGU>
    for i=1:length(MxArrays)
        if isnumerictype(MxArrays{i})
            T=MxArrays{i};
            if isscaledtype(T)
                anyScaledTypes=true;
            end
            if isscaleddouble(T)&&~isscalingslopebias(T)
                anyBinaryPointScaledDoubleTypes=true;%#ok<NASGU>
                break;
            end
        end
    end




    anyFloatToPropose=false;
    if~isdouble(opts.defaultDT)

        for i=1:length(MxInfos)
            if isa(MxInfos{i},'eml.MxNumericInfo')&&isequal(MxInfos{i}.Class,'double')
                anyFloatToPropose=true;
                break
            end
        end
        if~anyFloatToPropose


            for i=1:length(MxArrays)
                if isnumerictype(MxArrays{i})&&isfloat(MxArrays{i})
                    anyFloatToPropose=true;
                    break
                end
            end
        end
    end











    REASON_CPPSYSOBJ=10;
    for i=1:length(CompilationReport.InstrumentedData.InstrumentedFunctions)
        for j=1:length(CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations)
            if logsAreCommensurate(CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j))
                nfields=length(CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).LoggedFieldMxInfoIDs);
                SimMinVector=CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).SimMin;
                if nfields==0&&length(SimMinVector)==1

                    isCppSystemObject=false;
                    MxInfoID=CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).MxInfoID;
                    if MxInfoID>0&&MxInfoID<=length(MxInfos)
                        MxInfo=MxInfos{MxInfoID};
                        SimMin=CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).SimMin;
                        SimMax=CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).SimMax;
                        IsAlwaysInteger=CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).IsAlwaysInteger;
                        [proposedSignedness,proposedWL,proposedFL,outOfRange,ratioOfRange]=proposeWlFlRange(MxInfo,MxArrays,SimMin,SimMax,IsAlwaysInteger,...
                        opts,anyScaledTypes,anyFloatToPropose,isCppSystemObject);
                        CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).ProposedSignedness{1}=proposedSignedness;
                        CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).ProposedWordLengths{1}=proposedWL;
                        CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).ProposedFractionLengths{1}=proposedFL;
                        CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).OutOfRange{1}=outOfRange;
                        CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).RatioOfRange{1}=ratioOfRange;
                    end
                elseif nfields==0&&length(SimMinVector)>1

                    isCppSystemObject=false;
                    for k=1:length(SimMinVector)

                        LoggedFieldMxInfoID=1;
                        if~isempty(LoggedFieldMxInfoID)
                            MxInfoID=LoggedFieldMxInfoID(end);
                            if MxInfoID>0&&MxInfoID<=length(MxInfos)
                                MxInfo=MxInfos{MxInfoID};
                                if k<=length(CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).SimMin)...
                                    &&isfinite(CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).SimMin(k))
                                    SimMin=CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).SimMin(k);
                                    SimMax=CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).SimMax(k);
                                    IsAlwaysInteger=CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).IsAlwaysInteger(k);
                                    [proposedSignedness,proposedWL,proposedFL,outOfRange,ratioOfRange]=proposeWlFlRange(MxInfo,MxArrays,SimMin,SimMax,IsAlwaysInteger,...
                                    opts,anyScaledTypes,anyFloatToPropose,isCppSystemObject);
                                    CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).ProposedSignedness{k}=proposedSignedness;
                                    CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).ProposedWordLengths{k}=proposedWL;
                                    CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).ProposedFractionLengths{k}=proposedFL;
                                    CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).OutOfRange{k}=outOfRange;
                                    CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).RatioOfRange{k}=ratioOfRange;
                                end
                            end
                        end
                    end
                else

                    isCppSystemObject=CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).Reason==REASON_CPPSYSOBJ;
                    if isCppSystemObject



                        isCppSystemObjectProp=isSystemObjectInputNotFloat(CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).MxInfoID,...
                        CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).LoggedFieldNames,MxInfos,MxArrays);
                    else
                        isCppSystemObjectProp=false(1,nfields);
                    end
                    for k=1:nfields
                        LoggedFieldMxInfoID=CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).LoggedFieldMxInfoIDs{k};
                        if~isempty(LoggedFieldMxInfoID)
                            MxInfoID=LoggedFieldMxInfoID(end);
                            if MxInfoID>0&&MxInfoID<=length(MxInfos)
                                MxInfo=MxInfos{MxInfoID};
                                if k<=length(CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).SimMin)...
                                    &&isfinite(CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).SimMin(k))
                                    SimMin=CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).SimMin(k);
                                    SimMax=CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).SimMax(k);
                                    IsAlwaysInteger=CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).IsAlwaysInteger(k);
                                    [proposedSignedness,proposedWL,proposedFL,outOfRange,ratioOfRange]=proposeWlFlRange(MxInfo,MxArrays,SimMin,SimMax,IsAlwaysInteger,...
                                    opts,anyScaledTypes,anyFloatToPropose,isCppSystemObjectProp(k));
                                    CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).ProposedSignedness{k}=proposedSignedness;
                                    CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).ProposedWordLengths{k}=proposedWL;
                                    CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).ProposedFractionLengths{k}=proposedFL;
                                    CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).OutOfRange{k}=outOfRange;
                                    CompilationReport.InstrumentedData.InstrumentedFunctions(i).InstrumentedMxInfoLocations(j).RatioOfRange{k}=ratioOfRange;
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    for i=1:length(instrumentedVariables.Functions)
        if isfield(instrumentedVariables.Functions(i),'NamedVariables')
            for j=1:length(instrumentedVariables.Functions(i).NamedVariables)
                nfields=length(instrumentedVariables.Functions(i).NamedVariables(j).LoggedFieldMxInfoIDs);
                SimMinVector=instrumentedVariables.Functions(i).NamedVariables(j).SimMin;
                if nfields==0&&length(SimMinVector)==1

                    isCppSystemObject=false;
                    MxInfoID=instrumentedVariables.Functions(i).NamedVariables(j).MxInfoID;
                    if MxInfoID>0&&MxInfoID<=length(MxInfos)
                        MxInfo=MxInfos{MxInfoID};
                        SimMin=instrumentedVariables.Functions(i).NamedVariables(j).SimMin;
                        SimMax=instrumentedVariables.Functions(i).NamedVariables(j).SimMax;
                        IsAlwaysInteger=instrumentedVariables.Functions(i).NamedVariables(j).IsAlwaysInteger;
                        [proposedSignedness,proposedWL,proposedFL,outOfRange,ratioOfRange]=proposeWlFlRange(MxInfo,MxArrays,SimMin,SimMax,IsAlwaysInteger,...
                        opts,anyScaledTypes,anyFloatToPropose,isCppSystemObject);
                        instrumentedVariables.Functions(i).NamedVariables(j).ProposedSignedness{1}=proposedSignedness;
                        instrumentedVariables.Functions(i).NamedVariables(j).ProposedWordLengths{1}=proposedWL;
                        instrumentedVariables.Functions(i).NamedVariables(j).ProposedFractionLengths{1}=proposedFL;
                        instrumentedVariables.Functions(i).NamedVariables(j).OutOfRange{1}=outOfRange;
                        instrumentedVariables.Functions(i).NamedVariables(j).RatioOfRange{1}=ratioOfRange;
                    end
                elseif nfields==0&&length(SimMinVector)>1

                    isCppSystemObject=false;
                    for k=1:length(SimMin)

                        LoggedFieldMxInfoID=1;
                        if~isempty(LoggedFieldMxInfoID)
                            MxInfoID=LoggedFieldMxInfoID(end);
                            if MxInfoID>0&&MxInfoID<=length(MxInfos)
                                MxInfo=MxInfos{MxInfoID};
                                SimMin=instrumentedVariables.Functions(i).NamedVariables(j).SimMin(k);
                                SimMax=instrumentedVariables.Functions(i).NamedVariables(j).SimMax(k);
                                IsAlwaysInteger=instrumentedVariables.Functions(i).NamedVariables(j).IsAlwaysInteger(k);
                                [proposedSignedness,proposedWL,proposedFL,outOfRange,ratioOfRange]=proposeWlFlRange(MxInfo,MxArrays,SimMin,SimMax,IsAlwaysInteger,...
                                opts,anyScaledTypes,anyFloatToPropose,isCppSystemObject);
                                instrumentedVariables.Functions(i).NamedVariables(j).ProposedSignedness{k}=proposedSignedness;
                                instrumentedVariables.Functions(i).NamedVariables(j).ProposedWordLengths{k}=proposedWL;
                                instrumentedVariables.Functions(i).NamedVariables(j).ProposedFractionLengths{k}=proposedFL;
                                instrumentedVariables.Functions(i).NamedVariables(j).OutOfRange{k}=outOfRange;
                                instrumentedVariables.Functions(i).NamedVariables(j).RatioOfRange{k}=ratioOfRange;
                            end
                        end
                    end

                else

                    isCppSystemObject=instrumentedVariables.Functions(i).NamedVariables(j).IsCppSystemObject;
                    if isCppSystemObject



                        isCppSystemObjectProp=isSystemObjectInputNotFloat(instrumentedVariables.Functions(i).NamedVariables(j).MxInfoID,...
                        instrumentedVariables.Functions(i).NamedVariables(j).LoggedFieldNames,MxInfos,MxArrays);
                    else
                        isCppSystemObjectProp=false(1,nfields);
                    end
                    for k=1:nfields
                        LoggedFieldMxInfoID=instrumentedVariables.Functions(i).NamedVariables(j).LoggedFieldMxInfoIDs{k};
                        if~isempty(LoggedFieldMxInfoID)
                            MxInfoID=LoggedFieldMxInfoID(end);
                            if MxInfoID>0&&MxInfoID<=length(MxInfos)
                                MxInfo=MxInfos{MxInfoID};
                                SimMin=instrumentedVariables.Functions(i).NamedVariables(j).SimMin(k);
                                SimMax=instrumentedVariables.Functions(i).NamedVariables(j).SimMax(k);
                                IsAlwaysInteger=instrumentedVariables.Functions(i).NamedVariables(j).IsAlwaysInteger(k);
                                [proposedSignedness,proposedWL,proposedFL,outOfRange,ratioOfRange]=proposeWlFlRange(MxInfo,MxArrays,SimMin,SimMax,IsAlwaysInteger,...
                                opts,anyScaledTypes,anyFloatToPropose,isCppSystemObjectProp(k));
                                instrumentedVariables.Functions(i).NamedVariables(j).ProposedSignedness{k}=proposedSignedness;
                                instrumentedVariables.Functions(i).NamedVariables(j).ProposedWordLengths{k}=proposedWL;
                                instrumentedVariables.Functions(i).NamedVariables(j).ProposedFractionLengths{k}=proposedFL;
                                instrumentedVariables.Functions(i).NamedVariables(j).OutOfRange{k}=outOfRange;
                                instrumentedVariables.Functions(i).NamedVariables(j).RatioOfRange{k}=ratioOfRange;
                            end
                        end
                    end
                end
            end
        end
    end

end
function isCppSystemObjectPropValueCustom=isSystemObjectInputNotFloat(sysObjMxInfoID,loggedFieldNames,MxInfos,MxArrays)

    sysObjMxInfo=MxInfos{sysObjMxInfoID};
    sysObjPropNames={sysObjMxInfo.ClassProperties(:).PropertyName};

    idx=strcmpi(sysObjPropNames,'cSFunObject');
    cSFunObjectProp=sysObjMxInfo.ClassProperties(idx);
    cSFunObjectMxInfo=MxInfos{cSFunObjectProp.MxInfoID};
    sysObjInstance=MxArrays{cSFunObjectMxInfo.SEACompID};
    inputDataTypeID=sysObjInstance.getInputDataTypeID();
    isCppSystemObjectInputNotFloat=~(inputDataTypeID(1)<14);
    nFields=numel(loggedFieldNames);
    isCppSystemObjectPropValueCustom=false(1,nFields);
    if isCppSystemObjectInputNotFloat
        for k=1:nFields
            propValue=get(sysObjInstance,regexprep(loggedFieldNames{k},'Custom',''));
            isCppSystemObjectPropValueCustom(k)=strncmpi(propValue,'Custom',6);
        end
    end
end
function[proposedSignedness,proposedWL,proposedFL,outOfRange,ratioOfRange]=proposeWlFlRange(MxInfo,MxArrays,SimMin,SimMax,IsAlwaysInteger,...
    opts,anyScaledTypes,anyFloatToPropose,isCppSystemObject)
    proposedSignedness=[];
    proposedWL=[];
    proposedFL=[];
    outOfRange=[];
    ratioOfRange=[];
    doProposeWL=opts.doProposeWL;
    doProposeFL=opts.doProposeFL;
    doOptimizeWholeNumbers=opts.doOptimizeWholeNumbers;
    percentSafetyMargin=opts.percentSafetyMargin;

    RangeFactor=1+percentSafetyMargin/100;
    if SimMin<=SimMax&&~isinf(SimMin)&&~isinf(SimMax)
        if anyScaledTypes&&(isa(MxInfo,'eml.MxFiInfo')||isCppSystemObject)&&isscaledtype(MxArrays{MxInfo.NumericTypeID})


            [proposedWL,proposedFL,outOfRange,ratioOfRange]=optimizeScaledTypes(MxArrays{MxInfo.NumericTypeID});
        elseif anyFloatToPropose...
            &&(isa(MxInfo,'eml.MxFiInfo')&&isfloat(MxArrays{MxInfo.NumericTypeID})...
            ||...
            isa(MxInfo,'eml.MxNumericInfo')&&...
            (isequal(MxInfo.Class,'double')||isequal(MxInfo.Class,'single')))
            [proposedSignedness,proposedWL,proposedFL]=optimizeFloatTypes(opts.defaultDT);
        end
    end
    function[proposedWL,proposedFL,outOfRange,ratioOfRange]=optimizeScaledTypes(T)
        proposedWL=[];
        proposedFL=[];
        outOfRange=[];
        ratioOfRange=[];
        if isscaledtype(T)



            [ratioOfRange,lowerbound,upperbound]=fixed.internal.ratioOfRange(T,SimMin,SimMax);




            if isscaleddouble(T)&&~isscalingslopebias(T)&&(doProposeWL||doProposeFL)
                [proposedWL,proposedFL]=proposeWlFl(T);



                if isscalar(SimMin)&&isscalar(SimMax)&&isscalar(lowerbound)&&isscalar(upperbound)
                    outOfRange=SimMin<lowerbound||SimMax>upperbound;
                end
            end
        end
    end
    function[proposedSignedness,proposedWL,proposedFL]=optimizeFloatTypes(T)
        proposedSignedness=[];
        proposedWL=[];
        proposedFL=[];
        if isscaledtype(T)&&~isscalingslopebias(T)&&(doProposeWL||doProposeFL)
            if isequal(T.Signedness,'Auto')
                if SimMin>=0
                    proposedSignedness='Unsigned';
                else
                    proposedSignedness='Signed';
                end
                T.Signedness=proposedSignedness;
            else
                proposedSignedness=T.Signedness;
            end
            [proposedWL,proposedFL]=proposeWlFl(T);
            if isempty(proposedWL)
                proposedWL=T.WordLength;
            end
            if isempty(proposedFL)
                proposedFL=T.FractionLength;
            end
        end
    end
    function[proposedWL,proposedFL]=proposeWlFl(T)

        proposedWL=[];
        proposedFL=[];
        if doProposeWL&&isequal(T.Scaling,'Unspecified')
            error(message('fixed:instrumentation:NoSpecifiedFractionLength'));
        end
        if doProposeWL&&doOptimizeWholeNumbers
            if IsAlwaysInteger
                [proposedWL,proposedFL]=optimizeWholeNumbers(T,SimMin,SimMax,RangeFactor);
            else
                proposedWL=fixed.GetMinWordLength([SimMin,SimMax]*RangeFactor,T.FractionLength,T.Signed);
            end
        elseif doProposeWL
            proposedWL=fixed.GetMinWordLength([SimMin,SimMax]*RangeFactor,T.FractionLength,T.Signed);
        elseif doProposeFL&&doOptimizeWholeNumbers
            if IsAlwaysInteger
                [proposedWL,proposedFL]=optimizeWholeNumbers(T,SimMin,SimMax,RangeFactor);
            else
                proposedFL=proposeFL(T,SimMin,SimMax,IsAlwaysInteger,RangeFactor);
            end
        elseif doProposeFL
            proposedFL=proposeFL(T,SimMin,SimMax,IsAlwaysInteger,RangeFactor);
        end
    end
end
function proposedFL=proposeFL(T,SimMin,SimMax,IsAlwaysInteger,RangeFactor)
    if SimMin==0&&SimMax==0



        proposedFL=0;
    else
        bestPrecisionExponents=fixed.GetBestPrecisionExponent([SimMin,SimMax]*RangeFactor,T.WordLength,T.Signed);
        proposedFL=min(-bestPrecisionExponents);
        if IsAlwaysInteger




            proposedFL=min(0,proposedFL);
        end
    end
end
function[proposedWL,proposedFL]=optimizeWholeNumbers(T,SimMin,SimMax,RangeFactor)
    if(SimMin==0&&SimMax==0||...
        SimMin==0&&SimMax==1||...
        SimMin==1&&SimMax==1)
        proposedFL=0;
        proposedWL=1;
    else
        proposedFL=0;
        proposedWL=fixed.GetMinWordLength([SimMin,SimMax]*RangeFactor,proposedFL,T.Signed);
    end
end
function t=logsAreCommensurate(InstrumentedMxInfoLocation)

    siz=size(InstrumentedMxInfoLocation.SimMin);
    t=isequal(siz,size(InstrumentedMxInfoLocation.SimMax))&&...
    isequal(siz,size(InstrumentedMxInfoLocation.IsAlwaysInteger));
    if~isempty(InstrumentedMxInfoLocation.LoggedFieldNames)
        t=t&&...
        isequal(siz,size(InstrumentedMxInfoLocation.LoggedFieldNames))&&...
        isequal(siz,size(InstrumentedMxInfoLocation.LoggedFieldMxInfoIDs));
    end
end

function InstrumentedMxInfoLocations=initialize_InstrumentedMxInfoLocations(...
    MxInfoLocations,...
    NumberOfHistogramBins,...
    MxInfos)





    for j=length(MxInfoLocations):-1:1
        InstrumentedMxInfoLocations(j)=...
        fixed.internal.InstrumentedMxInfoLocation(MxInfoLocations(j),...
        NumberOfHistogramBins,...
        MxInfos);
    end
end

function InstrumentedMxInfoLocations=strip_unlogged_fields_from_InstrumentedMxInfoLocations(InstrumentedMxInfoLocations)

    for i=1:length(InstrumentedMxInfoLocations)
        if length(InstrumentedMxInfoLocations(i).SimMin)>1

            NumberOfHistogramBins=size(InstrumentedMxInfoLocations(i).HistogramOfPositiveValues,2);
            for j=length(InstrumentedMxInfoLocations(i).SimMin):-1:1



                if InstrumentedMxInfoLocations(i).SimMin(j)>...
                    InstrumentedMxInfoLocations(i).SimMax(j)


                    InstrumentedMxInfoLocations(i).SimMin(j)=[];
                    InstrumentedMxInfoLocations(i).SimMax(j)=[];
                    InstrumentedMxInfoLocations(i).OverflowWraps(j)=[];
                    InstrumentedMxInfoLocations(i).Saturations(j)=[];
                    InstrumentedMxInfoLocations(i).IsAlwaysInteger(j)=[];
                    InstrumentedMxInfoLocations(i).NumberOfZeros(j)=[];
                    InstrumentedMxInfoLocations(i).NumberOfPositiveValues(j)=[];
                    InstrumentedMxInfoLocations(i).NumberOfNegativeValues(j)=[];
                    InstrumentedMxInfoLocations(i).TotalNumberOfValues(j)=[];
                    InstrumentedMxInfoLocations(i).SimSum(j)=[];
                    InstrumentedMxInfoLocations(i).HistogramOfPositiveValues(j,:)=[];
                    InstrumentedMxInfoLocations(i).HistogramOfNegativeValues(j,:)=[];
                    InstrumentedMxInfoLocations(i).LoggedFieldNames(j)=[];
                    if~isempty(InstrumentedMxInfoLocations(i).LoggedFieldMxInfoIDs)
                        InstrumentedMxInfoLocations(i).LoggedFieldMxInfoIDs(j)=[];
                    end
                end
            end
            if isempty(InstrumentedMxInfoLocations(i).SimMin)

                number_of_fields=1;
                InstrumentedMxInfoLocations(i).SimMin=inf;
                InstrumentedMxInfoLocations(i).SimMax=-inf;
                InstrumentedMxInfoLocations(i).OverflowWraps=0;
                InstrumentedMxInfoLocations(i).Saturations=0;
                InstrumentedMxInfoLocations(i).IsAlwaysInteger=true;
                InstrumentedMxInfoLocations(i).NumberOfZeros=0;
                InstrumentedMxInfoLocations(i).NumberOfPositiveValues=0;
                InstrumentedMxInfoLocations(i).NumberOfNegativeValues=0;
                InstrumentedMxInfoLocations(i).TotalNumberOfValues=0;
                InstrumentedMxInfoLocations(i).SimSum=0;
                InstrumentedMxInfoLocations(i).HistogramOfPositiveValues=zeros(number_of_fields,NumberOfHistogramBins);
                InstrumentedMxInfoLocations(i).HistogramOfNegativeValues=zeros(number_of_fields,NumberOfHistogramBins);
                InstrumentedMxInfoLocations(i).LoggedFieldNames={};
                InstrumentedMxInfoLocations(i).LoggedFieldMxInfoIDs={};
            end
        end
    end

end

function instrumentedVariables=populate_InstanceCount_NumberOfInstances(instrumentedVariables)




    function_names={instrumentedVariables.Functions(:).FunctionName};
    [function_InstanceCount,function_NumberOfInstances]=strings_to_instances(function_names);
    for i=1:length(instrumentedVariables.Functions)
        instrumentedVariables.Functions(i).InstanceCount=function_InstanceCount(i);
        instrumentedVariables.Functions(i).NumberOfInstances=function_NumberOfInstances(i);
        if isfield(instrumentedVariables.Functions(i),'NamedVariables')&&...
            ~isempty(instrumentedVariables.Functions(i).NamedVariables)
            variable_names={instrumentedVariables.Functions(i).NamedVariables(:).SymbolName};
            [variable_InstanceCount,variable_NumberOfInstances]=strings_to_instances(variable_names);
            for j=1:length(instrumentedVariables.Functions(i).NamedVariables)
                instrumentedVariables.Functions(i).NamedVariables(j).InstanceCount=variable_InstanceCount(j);
                instrumentedVariables.Functions(i).NamedVariables(j).NumberOfInstances=variable_NumberOfInstances(j);
            end
        end
    end
end

function[InstanceCount,NumberOfInstances]=strings_to_instances(A)
    [~,IA,IC]=unique(A,'stable');

    InstanceCount=zeros(size(IC));
    NumberOfInstances=zeros(size(IC));

    for n=1:length(IA)
        ic_index=IC==n;
        InstanceCount(ic_index)=1:sum(ic_index);
        NumberOfInstances(ic_index)=sum(ic_index);
    end

end














































