function report=analyzeNetworkForCodegen(net,nameValueArgs)





    reportAllErrors=true;


    isCnnCodegenWorkflow=false;

    numTargetLibs=numel(nameValueArgs.TargetLibrary);


    loggers=repmat(coder.internal.DLCodegenErrorHandlerDispatcher.dispatchHandler(reportAllErrors),1,numTargetLibs);


    resultStruct=coder.internal.AnalyzeNetworkStructBuilder.buildEmptyStructArray(numTargetLibs);

    try

        [inputSizes,inputFormats]=iGetInputSizesAndFormats(net);
        layerInfoMap=dltargets.internal.NetworkInfo.constructLayerInfoMap(net,inputSizes,inputFormats);

        for i=1:numTargetLibs
            targetLib=nameValueArgs.TargetLibrary{i};



            dlcfg=coder.DeepLearningConfig(TargetLibrary=targetLib,DeepLearningAcceleration=true);


            loggers(i)=dltargets.internal.sharedNetwork.validateNetworkImpl(net,dlcfg,layerInfoMap,isCnnCodegenWorkflow,reportAllErrors);


            reportStructBuilder=coder.internal.AnalyzeNetworkStructBuilder(loggers(i),targetLib);
            resultStruct(i)=reportStructBuilder.buildReportStruct();

        end

    catch ME





        logger=coder.internal.DLCodegenErrorHandlerDispatcher.dispatchHandler(reportAllErrors);
        handleGenericError(logger,ME.identifier,ME.message);


        for i=1:numTargetLibs

            targetLib=nameValueArgs.TargetLibrary{i};


            reportStructBuilder=coder.internal.AnalyzeNetworkStructBuilder(logger,targetLib);
            resultStruct(i)=reportStructBuilder.buildReportStruct();
        end
    end

    if~nameValueArgs.Quiet
        displayReportSummary(resultStruct,loggers)
    end

    report=resultStruct;

end


function[inputSizes,inputFormats]=iGetInputSizesAndFormats(net)
    isDlnetwork=isa(net,'dlnetwork');
    if isDlnetwork&&~isempty(net.getExampleInputs)
        exampleInputs=net.getExampleInputs;
        fcn=@dltargets.internal.utils.NetworkValidationUtils.convertFormattedDlarrayToCodegenSizes;
        inputSizes=cellfun(@(exampleInput)fcn(exampleInput),exampleInputs,UniformOutput=false);
        inputFormats=cellfun(@dims,exampleInputs,UniformOutput=false);
    else
        inputLayers=dltargets.internal.getIOLayers(net);
        inputSizes=cell(numel(inputLayers),1);
        inputFormats=cell(numel(inputLayers),1);
        for i=1:numel(inputLayers)
            [inputSizes{i},inputFormats{i}]=dltargets.internal.utils.NetworkValidationUtils.getCodegenInputSizeAndFormatBasedOnLayer(inputLayers{i},isDlnetwork);
        end
    end
end


function displayReportSummary(resultStruct,loggers)

    summaryTbl=constructSummaryTable(resultStruct,loggers);
    summaryTbl=removeEmptyColumn(summaryTbl,'NetworkDiagnostics');
    summaryTbl=removeEmptyColumn(summaryTbl,'LayerDiagnostics');
    summaryTbl.Properties.RowNames={resultStruct.TargetLibrary};


    disp(newline);


    disp(summaryTbl);

end

function summaryTbl=constructSummaryTable(resultStruct,loggers)

    summaryTbl=table.empty;
    supportedFieldName=fieldName(coder.internal.AnalyzerStructFields.Supported);
    networkDiagnosticsFieldName=fieldName(coder.internal.AnalyzerStructFields.NetworkDiagnostics);
    layerDiagnosticsFieldName=fieldName(coder.internal.AnalyzerStructFields.LayerDiagnostics);
    incompatibleLayerTypesFieldName=fieldName(coder.internal.AnalyzerStructFields.IncompatibleLayerTypes);
    targetLibraryFieldName=fieldName(coder.internal.AnalyzerStructFields.TargetLibrary);


    for i=1:numel(resultStruct)

        currentResult=resultStruct(i);
        currentLogger=loggers(i);

        summaryStruct.(supportedFieldName)=iPrepareSupportedVariableName();
        summaryStruct.(networkDiagnosticsFieldName)=iPrepareNetworkDiagnosticsSummary();
        summaryStruct.(layerDiagnosticsFieldName)=iPrepareLayerDiagnosticsSummary();

        summaryTbl=[summaryTbl;struct2table(summaryStruct)];%#ok

    end



    function str=iPrepareSupportedVariableName()
        str="No";
        if currentResult.(supportedFieldName)
            str="Yes";
        end

    end

    function str=iPrepareNetworkDiagnosticsSummary()

        str="";
        if~isempty(currentResult.(networkDiagnosticsFieldName))

            numIssues=numel(currentResult.(networkDiagnosticsFieldName).Diagnostics);
            str=string(getString(message("dlcoder_spkg:ValidateNetwork:NetworkDiagnosticsSummary",num2str(numIssues))));


            cacheManager=coder.internal.AnalyzeNetworkCacheManager.instance;

            unique_id=cacheManager.insert({coder.internal.AnalyzerStructFields.NetworkDiagnostics,...
            currentResult.(networkDiagnosticsFieldName),...
            currentResult.(targetLibraryFieldName)});

            hyperlinkStr=getHyperlink(unique_id,'dlcoder_spkg:ValidateNetwork:SeeNetworkDiagnostics');

            str=str+hyperlinkStr;
        end

    end


    function str=iPrepareLayerDiagnosticsSummary()
        str="";
        if~isempty(currentResult.(layerDiagnosticsFieldName))
            tbl=currentLogger.FormattedLayerValidationLog;
            tableWithDistinctIssues=tbl(tbl.IssueId~="dlcoder_spkg:cnncodegen:unsupported_layer",:);
            numDistinctIssues=numel(unique(tableWithDistinctIssues.IssueId));
            numLayersWithDistinctIssues=numel(unique(tableWithDistinctIssues.LayerName));
            numUnsupportedLayerTypes=numel(currentResult.(incompatibleLayerTypesFieldName));
            cacheManager=coder.internal.AnalyzeNetworkCacheManager.instance;

            if numUnsupportedLayerTypes>0&&numDistinctIssues>0


                str=string(getString(message("dlcoder_spkg:ValidateNetwork:LayerDiagnosticsAndUnsupportedTypesSummary",num2str(numUnsupportedLayerTypes),num2str(numDistinctIssues),num2str(numLayersWithDistinctIssues))));

                unsupportedLayerTypesTbl=iCreateTableOfUnsupportedLayerTypes(currentResult.(incompatibleLayerTypesFieldName));


                unique_id=cacheManager.insert({coder.internal.AnalyzerStructFields.IncompatibleLayerTypes,...
                unsupportedLayerTypesTbl,...
                currentResult.(targetLibraryFieldName)});


                hyperlinkStr=getHyperlink(unique_id,'dlcoder_spkg:ValidateNetwork:SeeIncompatibleLayerTypes');


                str=str+hyperlinkStr;


                unique_id=cacheManager.insert({coder.internal.AnalyzerStructFields.LayerDiagnostics,...
                currentResult.(layerDiagnosticsFieldName),...
                currentResult.(targetLibraryFieldName)});

                hyperlinkStr=getHyperlink(unique_id,'dlcoder_spkg:ValidateNetwork:SeeLayerDiagnostics');


                str=str+hyperlinkStr;

            elseif numUnsupportedLayerTypes>0


                str=string(getString(message("dlcoder_spkg:ValidateNetwork:UnsupportedLayerTypesSummary",num2str(numUnsupportedLayerTypes))));

                unsupportedLayerTypesTbl=iCreateTableOfUnsupportedLayerTypes(currentResult.(incompatibleLayerTypesFieldName));


                unique_id=cacheManager.insert({coder.internal.AnalyzerStructFields.IncompatibleLayerTypes,...
                unsupportedLayerTypesTbl,...
                currentResult.(targetLibraryFieldName)});


                hyperlinkStr=getHyperlink(unique_id,'dlcoder_spkg:ValidateNetwork:SeeIncompatibleLayerTypes');
                str=str+hyperlinkStr;

            else


                str=string(getString(message("dlcoder_spkg:ValidateNetwork:LayerDiagnosticsSummary",num2str(numDistinctIssues),num2str(numLayersWithDistinctIssues))));


                unique_id=cacheManager.insert({coder.internal.AnalyzerStructFields.LayerDiagnostics,...
                currentResult.(layerDiagnosticsFieldName),...
                currentResult.(targetLibraryFieldName)});

                hyperlinkStr=getHyperlink(unique_id,'dlcoder_spkg:ValidateNetwork:SeeLayerDiagnostics');

                str=str+hyperlinkStr;

            end
        end


    end

end

function tbl=removeEmptyColumn(tbl,varName)
    if any(strcmp(tbl.Properties.VariableNames,varName))&&all(tbl.(varName)=="")
        tbl=removevars(tbl,varName);
    end
end

function hyperlinkStr=getHyperlink(unique_id,hyperlink_text_id)
    frontStr='<a href = "matlab:coder.internal.displaySummaryForAnalyzeNetwork(''';
    tailStr=[''')">',getString(message(hyperlink_text_id))];
    endStr='</a>';
    hyperlinkStr=string(sprintf(' %s%s%s%s',frontStr,unique_id,tailStr,endStr));
end

function tbl=iCreateTableOfUnsupportedLayerTypes(unsupportedLayerTypes)
    tbl=table(unsupportedLayerTypes,'VariableNames',"LayerType",'RowNames',string(categorical(1:numel(unsupportedLayerTypes))));
end