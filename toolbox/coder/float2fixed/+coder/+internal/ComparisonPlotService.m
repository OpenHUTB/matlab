classdef ComparisonPlotService
    properties(Constant)
        INPUT_EXPR='INPUT';
        OUTPUT_EXPR='OUTPUT';
        LOCAL_EXPR='LOCAL';
        INOUT_EXPR='INPUT_OUTPUT';
    end


    methods(Static,Hidden)

        function closePlots(plottedFigureHandles)
            for ii=1:length(plottedFigureHandles)
                f=plottedFigureHandles{ii};
                if ishandle(f)
                    close(f);
                end
            end
        end

        function data=cell2mat(cellArr)
            assert(iscell(cellArr));
            if isfi(cellArr{1})
                isColumn=iscolumn(cellArr{1});
                if isColumn
                    dim=1;
                else
                    dim=2;
                end
                data=zeros(length(cellArr),size(cellArr{1},dim),'like',cellArr{1});



                if~isColumn
                    for mm=1:size(cellArr,1);data(mm,:)=cellArr{mm};end
                else


                    for mm=1:size(cellArr,1);data(mm,:)=transpose(cellArr{mm});end
                end
            else
                if iscolumn(cellArr{1})


                    data=transpose(horzcat(cellArr{:,1}));
                else
                    data=vertcat(cellArr{:,1});
                end
            end
        end







        function plotUsingSDI(functionName,floatSimLoggedVals,fixedSimLoggedVals,selectSignals,sdiRunNameSuffix,fxpConv)

            disp(fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:genSDIPlot',functionName));

            Simulink.sdi.view();

            floatSelectedSignal=[];
            fixedSelectedSignal=[];

            [floatRun,~,~]=Simulink.sdi.createRun([functionName,' original run  : ',sdiRunNameSuffix]);
            [fixptRun,~,~]=Simulink.sdi.createRun([functionName,' converter run : ',sdiRunNameSuffix]);

            if~isempty(floatSimLoggedVals.inputs)||~isempty(floatSimLoggedVals.outputs)
                if 2==coder.internal.f2ffeature('MEXLOGGING')
                    floatTrimDataFcn=@(data)data(1:end);
                    fixedTrimDataFcn=@(data)data(1:end);
                else
                    floatIterCount=floatSimLoggedVals.iter-1;
                    fixedIterCount=fixedSimLoggedVals.iter-1;

                    floatTrimDataFcn=@(data)data(1:floatIterCount);
                    fixedTrimDataFcn=@(data)data(1:fixedIterCount);
                end


                exprType=coder.internal.ComparisonPlotService.INPUT_EXPR;
                floatInRes=floatSimLoggedVals.inputs;
                fixedInRes=fixedSimLoggedVals.inputs;


                varList=union(fieldnames(floatInRes),fieldnames(fixedInRes));

                floatInResList=cell(1,length(varList));
                for nn=1:length(varList)
                    var=varList{nn};
                    if isfield(floatInRes,var)
                        floatInResList{nn}=floatInRes.(var);
                    else
                        floatInResList{nn}=[];
                    end
                end
                fixedInResList=cell(1,length(varList));
                for nn=1:length(varList)
                    var=varList{nn};
                    if isfield(fixedInRes,var)
                        fixedInResList{nn}=fixedInRes.(var);
                    else
                        fixedInResList{nn}=[];
                    end
                end



                plotFloatFixedResults(exprType,varList,floatRun,floatInResList,floatTrimDataFcn,fixptRun,fixedInResList,fixedTrimDataFcn)



                exprType=coder.internal.ComparisonPlotService.OUTPUT_EXPR;
                floatOutRes=floatSimLoggedVals.outputs;
                fixedOutRes=fixedSimLoggedVals.outputs;



                varList=union(fieldnames(floatOutRes),fieldnames(fixedOutRes));
                floatOutResList=cell(1,length(varList));
                for nn=1:length(varList)
                    var=varList{nn};
                    if isfield(floatOutRes,var)
                        floatOutResList{nn}=floatOutRes.(var);
                    else
                        floatOutResList{nn}=[];
                    end
                end

                fixedOutResList=cell(1,length(varList));
                for nn=1:length(varList)
                    var=varList{nn};
                    if isfield(fixedOutRes,var)
                        fixedOutResList{nn}=fixedOutRes.(var);
                    else
                        fixedOutResList{nn}=[];
                    end
                end


                plotFloatFixedResults(exprType,varList,floatRun,floatOutResList,floatTrimDataFcn,fixptRun,fixedOutResList,fixedTrimDataFcn)
            end

            if~isempty(floatSimLoggedVals.exprs)

                exprType=coder.internal.ComparisonPlotService.LOCAL_EXPR;

                exprList=union(floatSimLoggedVals.exprs.keys,fixedSimLoggedVals.exprs.keys);
                floatExprResults=cell(1,length(exprList));
                fixedExprResults=cell(1,length(exprList));
                for mm=1:length(exprList)
                    exprID=exprList{mm};
                    if floatSimLoggedVals.exprs.isKey(exprID)
                        floatExprResults{mm}=floatSimLoggedVals.exprs(exprID).data;
                    end

                    if fixedSimLoggedVals.exprs.isKey(exprID)
                        fixedExprResults{mm}=fixedSimLoggedVals.exprs(exprID).data;
                    end
                end

                plotFloatFixedResults(exprType,exprList,floatRun,floatExprResults,@(x)x,fixptRun,fixedExprResults,@(x)x);
            end

            if selectSignals&&~isempty(floatSelectedSignal)&&~isempty(fixedSelectedSignal)...
                &&Simulink.sdi.isValidSignalID(floatSelectedSignal)...
                &&Simulink.sdi.isValidSignalID(fixedSelectedSignal)

                sig=Simulink.sdi.getSignal(floatSelectedSignal);
                sig.Checked=true;

                sig=Simulink.sdi.getSignal(fixedSelectedSignal);
                sig.Checked=true;
            end

            function plotFloatFixedResults(varType,varList,floatRun,floatPtResults,floatTrimDataFcn,fixptRun,fixedPtResults,fixedTrimDataFcn)

                for varindex=1:length(varList)
                    varname=varList{varindex};

                    switch varType
                    case coder.internal.ComparisonPlotService.OUTPUT_EXPR
                        str=['--------------  ',fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:outVar'),' : ',varname,'  --------------'];
                    case coder.internal.ComparisonPlotService.INPUT_EXPR
                        str=['--------------  ',fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:inVar'),' : ',varname,'  --------------'];
                    case coder.internal.ComparisonPlotService.LOCAL_EXPR
                        str=['--------------  ',fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:expr'),' : ',varname,'  --------------'];
                    otherwise
                        assert(false);
                    end
                    disp(str);


                    floatVarVal=floatPtResults{varindex};
                    if isempty(floatVarVal)
                        str=fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:notFoundInFPSimResults',varname);
                        disp(str);
                        disp(fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:skipVarComparison'));
                        continue;
                    end
                    fixedPtVarVal=fixedPtResults{varindex};
                    if isempty(fixedPtVarVal)
                        str=fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:notFoundInFixptSimResults',varname);
                        disp(str);
                        disp(fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:skipVarComparison'));
                        continue;
                    end

                    floatVarVal=floatTrimDataFcn(floatVarVal);
                    fixedPtVarVal=fixedTrimDataFcn(fixedPtVarVal);



                    if~(size(fixedPtVarVal)==size(floatVarVal))
                        str=fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:mismatch4FixPtAndFloatingPt',varList{varindex});
                        disp(str);
                        disp(fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:skipVarComparison'));
                        continue;
                    end

                    if length(floatVarVal)~=length(fixedPtVarVal)
                        disp(fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:loggedValsUnequalLength'));
                        disp(fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:skipVarComparison'));
                        continue;
                    end

                    varInfo.name=varname;
                    varInfo.functionName=functionName;



                    if iscell(floatVarVal)
                        floatVals=coder.internal.ComparisonPlotService.cell2mat(floatVarVal);
                        fixedVals=coder.internal.ComparisonPlotService.cell2mat(fixedPtVarVal);
                    else
                        floatVals=floatVarVal;
                        fixedVals=fixedPtVarVal;
                    end
                    if 1<=length(floatVarVal)
                        if iscell(floatVarVal)
                            varInfo.exampleValue=floatVarVal{1};
                        else
                            varInfo.exampleValue=floatVarVal(1);
                        end
                    else
                        varInfo.exampleValue=[];
                    end
                    [floatSignals,fixedSignals]=plotSignals(varInfo,floatRun,floatVals,fixptRun,fixedVals);


                    if isempty(floatSelectedSignal)&&1<=length(floatSignals)...
                        &&Simulink.sdi.isValidSignalID(floatSignals(1))
                        floatSelectedSignal=floatSignals(1);
                    end
                    if isempty(fixedSelectedSignal)&&1<=length(fixedSignals)...
                        &&Simulink.sdi.isValidSignalID(fixedSignals(1))
                        fixedSelectedSignal=fixedSignals(1);
                    end
                end

                function[run1Signals,run2Signals]=plotSignals(varInfo,run1,run1Vals,run2,run2Vals)
                    run1Signals=[];
                    run2Signals=[];
                    if isstruct(run1Vals)
                        structFields=fields(run1Vals);
                        for ii=1:length(structFields)
                            field=structFields{ii};


                            fieldVarInfo=varInfo;
                            fieldVarInfo.name=[varInfo.name,'.',field];

                            varRun1Vals=vertcat(run1Vals.(field));
                            varRun2Vals=vertcat(run2Vals.(field));
                            [sigs1,sigs2]=plotSignals(fieldVarInfo,run1,varRun1Vals,run2,varRun2Vals);
                            run1Signals=[run1Signals,sigs1];%#ok<AGROW>
                            run2Signals=[run2Signals,sigs2];%#ok<AGROW>
                        end
                    else
                        [sigs1,sigs2]=addToRuns(varInfo,run1,run1Vals,run2,run2Vals);
                        sigs1=sigs1(:);
                        sigs2=sigs2(:);
                        if iscolumn(sigs1)
                            sigs1=sigs1';
                        end
                        if iscolumn(sigs2)
                            sigs2=sigs2';
                        end
                        run1Signals=[run1Signals,sigs1];
                        run2Signals=[run2Signals,sigs2];
                    end
                end

                function[floatSignals,fixedSignals]=addToRuns(varInfo,floatRun,floatVals,fixedRun,fixedVals)

                    varName=varInfo.name;



                    disp(fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:genComparisonPlot'));


                    [original_timeseries]=buildTimeSeriesObjects(varName,floatVals);
                    [converted_timeseries]=buildTimeSeriesObjects(varName,fixedVals);

                    floatSignals=Simulink.sdi.addToRun(floatRun,'vars',original_timeseries);
                    fixedSignals=Simulink.sdi.addToRun(fixedRun,'vars',converted_timeseries);

                    function[ts]=buildTimeSeriesObjects(varName,vals)
                        ts=timeseries(vals);
                        ts.Name=varName;
                    end
                end
            end

            function compareRuns(sdiEngine,run1,run2,selectedSignal)
                if sdiEngine.isValidRunID(run1)&&sdiEngine.isValidRunID(run2)
                    Simulink.sdi.view(Simulink.sdi.GUITabType.CompareRuns);

                    [~]=Simulink.sdi.compareRuns(run1,run2,Simulink.sdi.AlignType.SignalName);
                    if sdiEngine.isValidSignalID(selectedSignal)
                        gui=Simulink.sdi.Instance.gui;
                        gui.plotSignalInComparedRun(selectedSignal);
                    end
                end
            end
        end

        function compareWithSDI(runID,varName,floatVarVal,fixedPtVarVal)
            [floatTS,fixedTS]=buildTimeSeriesObjects(varName,coder.internal.ComparisonPlotService.cell2mat(floatVarVal),coder.internal.ComparisonPlotService.cell2mat(fixedPtVarVal));
            setupRun(runID,floatTS,fixedTS);

            function setupRun(runID,floatTS,fixedTS)
                assert(~iscell(floatTS));
                assert(~iscell(fixedTS));
                for jj=1:length(floatTS)
                    tmpFltTS=floatTS(jj);
                    tmpFxdTS=fixedTS(jj);
                    signalIDs=Simulink.sdi.addToRun(runID,'vars',tmpFltTS,tmpFxdTS);

                    assert(~isempty(signalIDs));
                end
            end

            function[floatTS,fixedTS]=buildTimeSeriesObjects(varName,floatVarVal,fixedPtVarVal)
                assert(~iscell(floatVarVal));
                assert(~iscell(fixedPtVarVal));
                floatTS=[];fixedTS=[];
                if false&&iscell(floatVarVal)
                    assert(length(floatVarVal)==length(fixedPtVarVal));
                    for ii=1:length(floatVarVal)
                        [tmpFltTS,tmpFxdTS]=buildTimeSeriesObjects(varName,floatVarVal{ii},fixedPtVarVal{ii});
                        floatTS=[floatTS,tmpFltTS];%#ok<AGROW>
                        fixedTS=[fixedTS,tmpFxdTS];%#ok<AGROW>
                    end
                elseif isstruct(floatVarVal)
                    floatFields=fieldnames(floatVarVal);
                    fixedFields=fieldnames(fixedPtVarVal);
                    assert(all(strcmp(floatFields,fixedFields)));
                    for ii=1:size(floatFields)
                        fieldName=floatFields{ii};
                        [tmpFltTS,tmpFxdTS]=buildTimeSeriesObjects([varName,'.',fieldName]...
                        ,floatVarVal.(fieldName)...
                        ,fixedPtVarVal.(fieldName));
                        floatTS=[floatTS,tmpFltTS];%#ok<AGROW>
                        fixedTS=[fixedTS,tmpFxdTS];%#ok<AGROW>
                    end
                else
                    if~isreal(floatVarVal)
                        assert(~isreal(fixedPtVarVal));

                        realFlVal=real(floatVarVal);imagFlVal=imag(floatVarVal);
                        floatRealTS=timeseries(realFlVal,1:size(realFlVal));
                        floatRealTS.Name=['float: real: ',varName];
                        floatImagTS=timeseries(imagFlVal,1:size(imagFlVal));
                        floatImagTS.Name=['float: imag: ',varName];
                        floatTS=[floatRealTS,floatImagTS];


                        realFxdVal=real(fixedPtVarVal);imagFxdVal=imag(fixedPtVarVal);
                        fixedRealTS=timeseries(realFxdVal,1:size(realFxdVal));
                        fixedRealTS.Name=['fixed: real : ',varName];
                        fixedImagTS=timeseries(imagFxdVal,1:size(imagFxdVal));
                        fixedImagTS.Name=['fixed : imag : ',varName];
                        fixedTS=[fixedRealTS,fixedImagTS];
                    else
                        floatTS=timeseries(floatVarVal,1:size(floatVarVal));
                        floatTS.Name=['float: ',varName];
                        fixedTS=timeseries(fixedPtVarVal,1:size(fixedPtVarVal));
                        fixedTS.Name=['fixed: ',varName];
                    end
                end
            end
        end
    end
    methods(Static)

        function compareFixedPtAndFloatingPlots(functionName,floatSimLoggedVals,fixedSimLoggedVals,plotCompareFixedPtAndFloat,plotFunction,enableSDIPlotting,fxpConv)



            if~strcmp(func2str(plotFunction),func2str(coder.internal.Float2FixedConverter.INBUILT_PLOT_FUNCTION))
                disp(fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:genCustomComparisonPlot',functionName,func2str(plotFunction)));
            end



            if~isempty(plotFunction)&&strcmp(func2str(coder.internal.Float2FixedConverter.INBUILT_PLOT_FUNCTION),func2str(plotFunction))
                dispPlotInfo(functionName);
            end

            function dispPlotInfo(dName)
                disp(sprintf('### %s ####\n',fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:beginFixptErrAnalysis',dName)));%#ok<*DSPS>
                disp(fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:errCalcInfo'));
                disp(sprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'));
                disp(fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:errF2FValues','--------------------->'));
                disp(sprintf('%s (Mpe) ---> max(E) * (max(E)>0) ',fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:maxPosErr')));
                disp(sprintf('%s (Mne) ---> min(E) * (min(E)<0) ',fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:maxNegErr')));
                disp(fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:topErr','-----------------> Mpe (if Mpe > abs(Mne))','Mne)'));
                disp(fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:maxAbsVal','---> max(abs('));
                disp(sprintf('%s (MPE) -> 100 * (abs(TE) / MAE)',fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:maxPercentageErr')));
                disp(sprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n'));
            end

            if~isempty(floatSimLoggedVals.inputs)||~isempty(floatSimLoggedVals.outputs)
                if 2==coder.internal.f2ffeature('MEXLOGGING')
                    if enableSDIPlotting
                        floatTrimDataFcn=@(data)data(1:end);
                        fixedTrimDataFcn=@(data)data(1:end);
                    else
                        floatTrimDataFcn=@(data)data(1:end,:);
                        fixedTrimDataFcn=@(data)data(1:end,:);
                    end
                else
                    floatIterCount=floatSimLoggedVals.iter-1;
                    fixedIterCount=fixedSimLoggedVals.iter-1;

                    if enableSDIPlotting
                        floatTrimDataFcn=@(data)data(1:floatIterCount);
                        fixedTrimDataFcn=@(data)data(1:fixedIterCount);
                    else
                        floatTrimDataFcn=@(data)data(1:floatIterCount,:);
                        fixedTrimDataFcn=@(data)data(1:fixedIterCount,:);
                    end
                end


                exprType=coder.internal.ComparisonPlotService.INPUT_EXPR;
                floatInResults=floatSimLoggedVals.inputs;
                fixedInResults=fixedSimLoggedVals.inputs;


                varList=fieldnames(floatInResults);
                floatInResultsList=cellfun(@(fld)floatInResults.(fld),varList,'UniformOutput',false);
                fixedInResultsList=cellfun(@(fld)fixedInResults.(fld),varList,'UniformOutput',false);
                plotFloatFixedResults(exprType,varList,floatInResultsList,floatTrimDataFcn,fixedInResultsList,fixedTrimDataFcn);


                exprType=coder.internal.ComparisonPlotService.OUTPUT_EXPR;
                floatOutResults=floatSimLoggedVals.outputs;
                fixedOutResults=fixedSimLoggedVals.outputs;


                varList=fieldnames(floatOutResults);
                floatOutResultsList=cellfun(@(fld)floatOutResults.(fld),varList,'UniformOutput',false);
                fixedOutResultsList=cellfun(@(fld)fixedOutResults.(fld),varList,'UniformOutput',false);

                plotFloatFixedResults(exprType,varList,floatOutResultsList,floatTrimDataFcn,fixedOutResultsList,fixedTrimDataFcn);
            end

            if~isempty(floatSimLoggedVals.exprs)

                exprType=coder.internal.ComparisonPlotService.LOCAL_EXPR;
                exprList=union(floatSimLoggedVals.exprs.keys,fixedSimLoggedVals.exprs.keys);
                floatExprResults=cell(1,length(exprList));
                fixedExprResults=cell(1,length(exprList));
                for mm=1:length(exprList)
                    exprID=exprList{mm};
                    if floatSimLoggedVals.exprs.isKey(exprID)
                        floatExprResults{mm}=floatSimLoggedVals.exprs(exprID).data;
                    end

                    if fixedSimLoggedVals.exprs.isKey(exprID)
                        fixedExprResults{mm}=fixedSimLoggedVals.exprs(exprID).data;
                    end
                end

                plotFloatFixedResults(exprType,exprList,floatExprResults,@(x)x,fixedExprResults,@(x)x);
            end




            function plotFloatFixedResults(varType,varList,floatPtResults,floatTrimDataFcn,fixedPtResults,fixedTrimDataFcn)


                if enableSDIPlotting
                    [runID,~,~]=Simulink.sdi.createRun('f2f Run #');
                end

                if~isempty(varList)
                    for varindex=1:length(varList)
                        varname=varList{varindex};
                        switch varType
                        case coder.internal.ComparisonPlotService.OUTPUT_EXPR
                            str=['--------------  ',fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:outVar'),' : ',varname,'  --------------'];
                        case coder.internal.ComparisonPlotService.INPUT_EXPR
                            str=['--------------  ',fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:inVar'),' : ',varname,'  --------------'];
                        case coder.internal.ComparisonPlotService.LOCAL_EXPR
                            str=['--------------  ',fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:expr'),' : ',varname,'  --------------'];
                        otherwise
                            assert(false);
                        end
                        disp(str);

                        floatVarVal=floatPtResults{varindex};
                        if isempty(floatVarVal)
                            str=fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:notFoundInFPSimResults',varname);
                            disp(str);
                            disp(fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:skipVarComparison'));
                            continue;
                        end
                        fixedPtVarVal=fixedPtResults{varindex};
                        if isempty(fixedPtVarVal)
                            str=fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:notFoundInFixptSimResults',varname);
                            disp(str);
                            disp(fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:skipVarComparison'));
                            continue;
                        end



                        if~(size(fixedPtVarVal)==size(floatVarVal))
                            str=fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:mismatch4FixPtAndFloatingPt',varList{varindex});
                            disp(str);
                            disp(fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:skipVarComparison'));
                            continue;
                        end

                        if length(floatVarVal)~=length(fixedPtVarVal)
                            disp(fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:loggedValsUnequalLength'));
                            disp(fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:skipVarComparison'));
                            continue;
                        end

                        if enableSDIPlotting
                            Simulink.sdi.view(Simulink.sdi.GUITabType.CompareSignals);
                            coder.internal.ComparisonPlotService.compareWithSDI(runID,varname,floatTrimDataFcn(floatVarVal),fixedTrimDataFcn(fixedPtVarVal));
                        else
                            plotUsingPlotFunction(varType,functionName,varname,floatTrimDataFcn(floatVarVal),fixedTrimDataFcn(fixedPtVarVal),plotCompareFixedPtAndFloat,plotFunction,fxpConv);
                        end
                    end
                end
            end

            function plotUsingPlotFunction(varType,functionName,varname,floatVarVal,fixedPtVarVal,plotCompareFixedPtAndFloat,plotFunction,fxpConv)
                varInfo.name=varname;
                varInfo.functionName=functionName;
                varInfo.isOutput=strcmp(varType,coder.internal.ComparisonPlotService.OUTPUT_EXPR);
                varInfo.isInput=strcmp(varType,coder.internal.ComparisonPlotService.INPUT_EXPR);

                if plotCompareFixedPtAndFloat
                    disp(fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:genComparisonPlot'));





                    invokePlotFunction(varInfo,floatVarVal,fixedPtVarVal,plotFunction);
                else
                    disp(fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:skipComparisonPlot'));
                end

                function invokePlotFunction(varInfo,floatVarVal,fixedPtVarVal,plotFunction)
                    varName=varInfo.name;
                    fcnName=varInfo.functionName;

                    plotVals(fcnName,varName,floatVarVal,fixedPtVarVal);


                    function plotVals(fcnName,varName,floatVals,fixedVals)
                        if iscell(floatVals)
                            isAStruct=floatVals{1};
                        else
                            isAStruct=floatVals(1);
                        end
                        if isstruct(isAStruct)
                            plotStructs(varName,floatVals,fixedVals);
                        else
                            plotMatrices(varName,floatVals,fixedVals);
                        end

                        function plotStructs(varName,floatVals,fixedVals)
                            if iscell(floatVals)
                                matFloatVals=coder.internal.ComparisonPlotService.cell2mat(floatVals);
                                matFixedVals=coder.internal.ComparisonPlotService.cell2mat(fixedVals);
                            else
                                matFloatVals=floatVals;
                                matFixedVals=fixedVals;
                            end
                            structFields=fieldnames(matFloatVals);
                            for ii=1:length(structFields)
                                field=structFields{ii};

                                strctVarName=[varName,'.',field];
                                plotStr=fxpConv.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:plotting');
                                disp([plotStr,' : ',strctVarName,newline]);

                                plotVals(fcnName,strctVarName,{matFloatVals.(field)}',{matFixedVals.(field)}');
                            end
                        end

                        function plotMatrices(varName,floatVals,fixedVals)

                            plotUtil(fcnName,varName,floatVals,fixedVals);
                        end

                        function figsOpened=plotUtil(fcnName,varName,floatVals,fixedVals)
                            varInfo.name=varName;
                            varInfo.functionName=fcnName;
                            varInfo.DoubleToSingle=fxpConv.fxpCfg.DoubleToSingle;
                            try
                                figsBefore=findall(0,'Type','figure');
                                plotFunction(varInfo,floatVals,fixedVals);
                                figsNow=findall(0,'Type','figure');
                                figsOpened=setdiff(figsNow,figsBefore);
                            catch ex
                                warning(message('Coder:FxpConvDisp:FXPCONVDISP:customPlottingError',varname,func2str(plotFunction)));
                                disp(ex.message);
                            end
                        end
                    end
                end
            end
        end
    end

    methods(Static)

        function[inputFigsOpened,outputFigsOpened]=customCompareFixedPtAndFloatingPlots(functionName,floatSimLoggedVals,fixedSimLoggedVals,plotCompareFixedPtAndFloat,plotFunction,enableSDIPlotting,getMessageText,isDouble2Single,isCLIWorkflow)
            inputFigsOpened=[];
            outputFigsOpened=[];


            if~strcmp(func2str(plotFunction),func2str(coder.internal.Float2FixedConverter.INBUILT_PLOT_FUNCTION))
                disp(getMessageText('Coder:FxpConvDisp:FXPCONVDISP:genCustomComparisonPlot',functionName,func2str(plotFunction)));
            end



            if isCLIWorkflow


                if~isempty(plotFunction)&&strcmp(func2str(coder.internal.Float2FixedConverter.INBUILT_PLOT_FUNCTION),func2str(plotFunction))
                    dispPlotInfo(functionName);
                end
            end

            function dispPlotInfo(dName)
                disp(sprintf('### %s ####\n',getMessageText('Coder:FxpConvDisp:FXPCONVDISP:beginFixptErrAnalysis',dName)));%#ok<*DSPS>
                disp(getMessageText('Coder:FxpConvDisp:FXPCONVDISP:errCalcInfo'));
                disp(sprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'));
                disp(getMessageText('Coder:FxpConvDisp:FXPCONVDISP:errF2FValues','--------------------->'));
                disp(sprintf('%s (Mpe) ---> max(E) * (max(E)>0) ',getMessageText('Coder:FxpConvDisp:FXPCONVDISP:maxPosErr')));
                disp(sprintf('%s (Mne) ---> min(E) * (min(E)<0) ',getMessageText('Coder:FxpConvDisp:FXPCONVDISP:maxNegErr')));
                disp(getMessageText('Coder:FxpConvDisp:FXPCONVDISP:topErr','-----------------> Mpe (if Mpe > abs(Mne))','Mne)'));
                disp(getMessageText('Coder:FxpConvDisp:FXPCONVDISP:maxAbsVal','---> max(abs('));
                disp(sprintf('%s (MPE) -> 100 * (abs(TE) / MAE)',getMessageText('Coder:FxpConvDisp:FXPCONVDISP:maxPercentageErr')));
                disp(sprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n'));
            end


            if~isempty(floatSimLoggedVals.inputs)||~isempty(floatSimLoggedVals.outputs)



                if enableSDIPlotting
                    floatTrimDataFcn=@(data)data(1:end);
                    fixedTrimDataFcn=@(data)data(1:end);
                else
                    floatTrimDataFcn=@(data)data(1:end,:);
                    fixedTrimDataFcn=@(data)data(1:end,:);
                end


                exprType=coder.internal.ComparisonPlotService.INPUT_EXPR;
                floatInResults=floatSimLoggedVals.inputs;
                fixedInResults=fixedSimLoggedVals.inputs;
                if isempty(floatInResults)
                    floatInResults=struct;
                end
                if isempty(fixedInResults)
                    fixedInResults=struct;
                end



                varList=union(fieldnames(floatInResults),fieldnames(fixedInResults),'stable');
                floatInResultsList=cell(1,length(varList));
                for nn=1:length(varList)
                    varN=varList{nn};
                    if isfield(floatInResults,varN)
                        floatInResultsList{nn}=floatInResults.(varN);
                    else
                        floatInResultsList{nn}=[];
                    end

                end

                fixedInResultsList=cell(1,length(varList));
                for nn=1:length(varList)
                    varN=varList{nn};
                    if isfield(fixedInResults,varN)
                        fixedInResultsList{nn}=fixedInResults.(varN);
                    else
                        fixedInResultsList{nn}=[];
                    end

                end


                inputFigsOpened=plotFloatFixedResults(exprType,varList,floatInResultsList,floatTrimDataFcn,fixedInResultsList,fixedTrimDataFcn);



                exprType=coder.internal.ComparisonPlotService.OUTPUT_EXPR;
                floatOutResults=floatSimLoggedVals.outputs;
                if isempty(floatOutResults)
                    floatOutResults=struct;
                end
                fixedOutResults=fixedSimLoggedVals.outputs;
                if isempty(fixedOutResults)
                    fixedOutResults=struct;
                end



                varList=union(fieldnames(floatOutResults),fieldnames(fixedOutResults),'stable');
                floatOutResultsList=cell(1,length(varList));
                for nn=1:length(varList)
                    varN=varList{nn};
                    if isfield(floatOutResults,varN)
                        floatOutResultsList{nn}=floatOutResults.(varN);
                    else
                        floatOutResultsList{nn}=[];
                    end
                end
                fixedOutResultsList=cell(1,length(varList));
                for nn=1:length(varList)
                    varN=varList{nn};
                    if isfield(fixedOutResults,varN)
                        fixedOutResultsList{nn}=fixedOutResults.(varN);
                    else
                        fixedOutResultsList{nn}=[];
                    end
                end




                outputFigsOpened=plotFloatFixedResults(exprType,varList,floatOutResultsList,floatTrimDataFcn,fixedOutResultsList,fixedTrimDataFcn);

            end

            if~isempty(floatSimLoggedVals.exprs)

                exprType=coder.internal.ComparisonPlotService.LOCAL_EXPR;
                exprList=union(floatSimLoggedVals.exprs.keys,fixedSimLoggedVals.exprs.keys);
                floatExprResults=cell(1,length(exprList));
                fixedExprResults=cell(1,length(exprList));
                for mm=1:length(exprList)
                    exprID=exprList{mm};
                    if floatSimLoggedVals.exprs.isKey(exprID)
                        floatExprResults{mm}=floatSimLoggedVals.exprs(exprID).data;
                    end

                    if fixedSimLoggedVals.exprs.isKey(exprID)
                        fixedExprResults{mm}=fixedSimLoggedVals.exprs(exprID).data;
                    end
                end

                plotFloatFixedResults(exprType,exprList,floatExprResults,@(x)x,fixedExprResults,@(x)x);
            end




            function varFigsOpened=plotFloatFixedResults(varType,varList,floatPtResults,floatTrimDataFcn,fixedPtResults,fixedTrimDataFcn)


                if enableSDIPlotting
                    [runID,~,~]=Simulink.sdi.createRun('f2f Run #');
                end

                varFigsOpened=struct;
                if~isempty(varList)
                    for varindex=1:length(varList)
                        varname=varList{varindex};


                        if isCLIWorkflow
                            switch varType
                            case coder.internal.ComparisonPlotService.OUTPUT_EXPR
                                str=['--------------  ',getMessageText('Coder:FxpConvDisp:FXPCONVDISP:outVar'),' : ',varname,'  --------------'];
                            case coder.internal.ComparisonPlotService.INPUT_EXPR
                                str=['--------------  ',getMessageText('Coder:FxpConvDisp:FXPCONVDISP:inVar'),' : ',varname,'  --------------'];
                            case coder.internal.ComparisonPlotService.LOCAL_EXPR
                                str=['--------------  ',getMessageText('Coder:FxpConvDisp:FXPCONVDISP:expr'),' : ',varname,'  --------------'];
                            otherwise
                                assert(false);
                            end
                            disp(str);
                        end

                        floatVarVal=floatPtResults{varindex};
                        if isempty(floatVarVal)
                            str=getMessageText('Coder:FxpConvDisp:FXPCONVDISP:notFoundInFPSimResults',varname);
                            disp(str);
                            disp(getMessageText('Coder:FxpConvDisp:FXPCONVDISP:skipVarComparison'));
                            continue;
                        end
                        fixedPtVarVal=fixedPtResults{varindex};
                        if isempty(fixedPtVarVal)
                            str=getMessageText('Coder:FxpConvDisp:FXPCONVDISP:notFoundInFixptSimResults',varname);
                            disp(str);
                            disp(getMessageText('Coder:FxpConvDisp:FXPCONVDISP:skipVarComparison'));
                            continue;
                        end



                        if~(size(fixedPtVarVal)==size(floatVarVal))
                            str=getMessageText('Coder:FxpConvDisp:FXPCONVDISP:mismatch4FixPtAndFloatingPt',varList{varindex});
                            disp(str);
                            disp(getMessageText('Coder:FxpConvDisp:FXPCONVDISP:skipVarComparison'));
                            continue;
                        end

                        if length(floatVarVal)~=length(fixedPtVarVal)
                            disp(getMessageText('Coder:FxpConvDisp:FXPCONVDISP:loggedValsUnequalLength'));
                            disp(getMessageText('Coder:FxpConvDisp:FXPCONVDISP:skipVarComparison'));
                            continue;
                        end

                        if enableSDIPlotting
                            Simulink.sdi.view(Simulink.sdi.GUITabType.CompareSignals);
                            coder.internal.ComparisonPlotService.compareWithSDI(runID,varname,floatTrimDataFcn(floatVarVal),fixedTrimDataFcn(fixedPtVarVal));
                        else
                            varFigsOpened.(varname)=plotUsingPlotFunction(varType,functionName,varname,floatTrimDataFcn(floatVarVal),fixedTrimDataFcn(fixedPtVarVal),plotCompareFixedPtAndFloat,plotFunction);
                        end
                    end
                end
            end

            function figsOpened=plotUsingPlotFunction(varType,functionName,varname,floatVarVal,fixedPtVarVal,plotCompareFixedPtAndFloat,plotFunction)
                figsOpened=[];
                varInfo.name=varname;
                varInfo.functionName=functionName;
                varInfo.isOutput=strcmp(varType,coder.internal.ComparisonPlotService.OUTPUT_EXPR);
                varInfo.isInput=strcmp(varType,coder.internal.ComparisonPlotService.INPUT_EXPR);

                if plotCompareFixedPtAndFloat


                    if isCLIWorkflow
                        disp(getMessageText('Coder:FxpConvDisp:FXPCONVDISP:genComparisonPlot'));
                    end

                    figsOpened=invokePlotFunction(varInfo,floatVarVal,fixedPtVarVal,plotFunction);
                else
                    disp(getMessageText('Coder:FxpConvDisp:FXPCONVDISP:skipComparisonPlot'));
                end

                function figsOpened=invokePlotFunction(varInfo,floatVarVal,fixedPtVarVal,plotFunction)
                    varName=varInfo.name;
                    fcnName=varInfo.functionName;

                    figsOpened=plotVals(fcnName,varName,floatVarVal,fixedPtVarVal);


                    function figsOpened=plotVals(fcnName,varName,floatVals,fixedVals)
                        if iscell(floatVals)
                            isAStruct=floatVals{1};
                        else
                            isAStruct=floatVals(1);
                        end
                        if isstruct(isAStruct)
                            figsOpened=plotStructs(varName,floatVals,fixedVals);
                        else
                            figsOpened=plotMatrices(varName,floatVals,fixedVals);
                        end

                        function figsOpened=plotStructs(varName,floatVals,fixedVals)
                            figsOpened=struct();
                            if iscell(floatVals)
                                matFloatVals=coder.internal.ComparisonPlotService.cell2mat(floatVals);
                                matFixedVals=coder.internal.ComparisonPlotService.cell2mat(fixedVals);
                            else
                                matFloatVals=floatVals;
                                matFixedVals=fixedVals;
                            end
                            structFields=fieldnames(matFloatVals);
                            for ii=1:length(structFields)
                                field=structFields{ii};

                                structVarName=[varName,'.',field];


                                if isCLIWorkflow
                                    plotStr=getMessageText('Coder:FxpConvDisp:FXPCONVDISP:plotting');
                                    disp([plotStr,' : ',structVarName,newline]);
                                end

                                tmpFigsOpened=plotVals(fcnName,structVarName,matFloatVals.(field),matFixedVals.(field));%#ok<NASGU>


                                evalc(['figsOpened.',field,' = tmpFigsOpened;']);
                            end
                        end

                        function figsOpened=plotMatrices(varName,floatVals,fixedVals)

                            figsOpened=plotUtil(fcnName,varName,floatVals,fixedVals);
                        end

                        function figsOpened=plotUtil(fcnName,varName,floatVals,fixedVals)
                            figsOpened=[];
                            varInfo.name=varName;
                            varInfo.functionName=fcnName;
                            varInfo.DoubleToSingle=isDouble2Single;
                            try
                                figsBefore=findall(0,'Type','figure');
                                plotFunction(varInfo,floatVals,fixedVals);
                                figsNow=findall(0,'Type','figure');
                                figsOpened=setdiff(figsNow,figsBefore);
                            catch ex
                                warning(message('Coder:FxpConvDisp:FXPCONVDISP:customPlottingError',varname,func2str(plotFunction)));
                                disp(ex.message);
                            end
                        end
                    end
                end
            end
        end
    end
end