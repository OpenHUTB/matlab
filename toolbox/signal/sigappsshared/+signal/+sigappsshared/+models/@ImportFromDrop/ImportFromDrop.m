classdef ImportFromDrop<handle







%#ok<*AGROW>

    properties(GetAccess='public',SetAccess='private')
        engine;
        targetRunID=inf;
NewVarNames
RepeatedVars
NewSignalMetaData
SigVals
SigValNames
NamesOfPurelyParentSignals
IDsOfPurelyParentSignals
NewAddedSignalIDs
NewAddedVarNames
ReImportExistingVarNames
WarnIfExceedsMaxNumColumns
ErrorIDForUnImportedInherentVars
AppName
    end
    properties(Constant,Access='private')
        INHERENTTYPES={'inherentTimetable','inherentTimeseries','inherentLabeledSignalSet','inherent'};
    end

    methods


        function this=ImportFromDrop(sdie)
            if nargin==0
                sdie=Simulink.sdi.Instance.engine;
            end


            this.engine=sdie;
        end


        function infoStruct=updateRepository(this,varNames,plotFlag,clientID,varargin)







            infoStruct=this.getInfoStructure();

            if nargin>4&&strcmp(varargin{1},'MetaStructure')
                this.NewSignalMetaData=varargin{2};
            end

            if nargin>6&&strcmp(varargin{3},'SigVals')


                this.SigVals=varargin{4};
                if~iscell(this.SigVals)
                    this.SigVals={this.SigVals};
                end
            end

            if isempty(varNames)&&isempty(this.SigVals)
                return;
            end

            [infoStruct,runIDs,earlyReturn]=this.checkIfRepeatedVariablesMetaChanged(this.NewSignalMetaData,varNames,infoStruct);

            if earlyReturn
                return;
            end

            if~isempty(this.SigVals)



                for idx=1:length(varNames)
                    varNameEmpty(idx)=strcmp(varNames{idx},'');
                end
                varNames(varNameEmpty)=getNewSignalNames(this,length(varNames(varNameEmpty)));


                this.SigValNames=varNames;
            end

            this.NewVarNames=varNames;
            this.RepeatedVars=[];









            safeTransaction(this.engine,@this.parseAndUpdateVars,varNames,plotFlag);
            safeTransaction(this.engine,@this.processNewVariables,this.NewVarNames,plotFlag,clientID,runIDs);
            safeTransaction(this.engine,@this.processRepeatedVariables,this.RepeatedVars,clientID);

            infoStruct.runID=this.targetRunID;
            infoStruct.newImportedSignalIDs=this.NewAddedSignalIDs;
            infoStruct.newImportedVarNames=this.NewAddedVarNames;
            infoStruct.errorIDForUnImportedInherentVars=this.ErrorIDForUnImportedInherentVars;

            clearModel(this);
        end


        function repeatedVarNames=getRepeatedVariableNames(this,varNames)

            if isinf(this.targetRunID)
                repeatedVarNames=[];
                return;
            end

            currentVarNames=getNamesOfPurelyParentSignals(this,this.targetRunID);
            repeatedVarNames=intersect(currentVarNames,varNames(:));
        end


        function runIDs=getRunIDs(this,appName)


            if appName=="SignalLabeler"
                runIDs=this.engine.getAllRunIDs('signallabeler');
            else
                runIDs=this.engine.getAllRunIDs('siganalyzer');
            end
        end

        function setTargetRunIDs(this,runIDs)
            if isempty(runIDs)
                this.targetRunID=inf;
            else



                if~any(runIDs==this.targetRunID)
                    runIDs=runIDs(1);
                    this.targetRunID=runIDs;
                end
            end
        end

        function infoStruct=getInfoStructure(~)
            infoStruct=struct(...
            'runID',[],...
            'newImportedSignalIDs',[],...
            'newImportedVarNames',[]);
        end

        function[infoStruct,runIDs,earlyReturn]=checkIfRepeatedVariablesMetaChanged(this,newSignalMetaData,varNames,infoStruct)



            earlyReturn=false;
            if nargin<4
                infoStruct=this.getInfoStructure();
            end


            this.ReImportExistingVarNames=true;
            this.WarnIfExceedsMaxNumColumns=true;
            this.AppName="SignalAnalyzer";
            if~isempty(newSignalMetaData)&&isfield(newSignalMetaData,'opts')
                this.ReImportExistingVarNames=newSignalMetaData.opts.reImportExistingVarNames;
                this.WarnIfExceedsMaxNumColumns=newSignalMetaData.opts.warnIfExceedsMaxNumColumns;
                this.AppName=newSignalMetaData.opts.appName;
            end

            runIDs=this.getRunIDs(this.AppName);
            this.setTargetRunIDs(runIDs);



            if~isempty(newSignalMetaData)&&isfinite(this.targetRunID)
                safeTransaction(this.engine,@this.getNamesOfPurelyParentSignals,this.targetRunID);
                [~,repeatedIdx]=intersect(this.NamesOfPurelyParentSignals,varNames);

                if~this.ReImportExistingVarNames&&~isempty(repeatedIdx)
                    infoStruct.repeatedVarNames=this.NamesOfPurelyParentSignals(repeatedIdx);
                    clearModel(this);
                    earlyReturn=true;
                    return;
                end

                if repeatedVarMetaChanged(this,this.IDsOfPurelyParentSignals(repeatedIdx),newSignalMetaData)
                    ME=MException('SDI:sigAnalyzer:RepeatedMetaChanged',getString(message('SDI:sigAnalyzer:RepeatedMetaChanged')));
                    throwAsCaller(ME);
                end
            end
        end
    end

    methods(Access=protected)

        function clearModel(this)
            this.NewVarNames=[];
            this.RepeatedVars=[];
            this.NewSignalMetaData=[];
            this.SigVals=[];
            this.SigValNames=[];
            this.NamesOfPurelyParentSignals=[];
            this.IDsOfPurelyParentSignals=[];
            this.NewAddedSignalIDs=[];
            this.NewAddedVarNames=[];
            this.ReImportExistingVarNames=[];
            this.ErrorIDForUnImportedInherentVars=[];
            this.WarnIfExceedsMaxNumColumns=[];
            this.AppName=[];
        end


        function parseAndUpdateVars(this,varNames,plotFlag)

            repeatedVars=[];
            varNames=varNames(:);
            if isinf(this.targetRunID)
                this.NewVarNames=varNames;
                this.RepeatedVars=repeatedVars;
                return;
            end



            [currentVarNames,currentVarIDs]=getNamesOfPurelyParentSignals(this,this.targetRunID);




            [repeatedVarNames,repeatedVarNamesIdx]=intersect(currentVarNames,varNames);
            repeatedVarIDs=currentVarIDs(repeatedVarNamesIdx);


            newVarNames=setdiff(varNames,currentVarNames);
            newVarNames=newVarNames(:);




            repeatedVars=repmat(struct('Name','','ID',-1,...
            'HasChildren',false,'ChildrenIDs',[],...
            'HasNonLeafChildren',false,'NonLeafChildrenIDs',[],...
            'DataColumChildrenIndices',[],'IsFinite',this.isAppSignalAnalyzer()),...
            numel(repeatedVarIDs),1);


            selectedDisplay=Simulink.sdi.getSelectedPlot(this.engine.sigRepository);



            outputRepeatedVars=[];
            for idx=1:numel(repeatedVars)
                varName=repeatedVarNames{idx};
                varID=repeatedVarIDs(idx);

                repeatedVars(idx).Name=varName;
                repeatedVars(idx).ID=varID;
                repeatedVars(idx).TmMode=this.engine.getSignalTmMode(varID);




                repeatedVars(idx).NonLeafChildrenIDs=getSignalNonLeafChildren(this,varID);
                repeatedVars(idx).HasNonLeafChildren=~isempty(repeatedVars(idx).NonLeafChildrenIDs);



                repeatedVars(idx).ChildrenIDs=signal.analyzer.SignalUtilities.getSignalLeafChildren(this.engine,varID);
                repeatedVars(idx).HasChildren=~isempty(repeatedVars(idx).ChildrenIDs);
                if this.isAppSignalAnalyzer()
                    repeatedVars(idx).IsFinite=logical(this.engine.getMetaDataV2(varID,'IsFinite'));
                end



                outputRepeatedVar=updateData(this,repeatedVars(idx));

                if outputRepeatedVar.DeleteSignalAndReImport
                    newVarNames=[newVarNames;varName];
                else


                    outputRepeatedVar.PlotOnCurrentDisplay=cell(1,numel(outputRepeatedVar.DataColumnNames));
                    outputRepeatedVar.UpdateDisplays=cell(1,numel(outputRepeatedVar.DataColumnNames));
                    if outputRepeatedVar.HasChildren
                        colsToUpdate=outputRepeatedVar.DataColumnsToUpdate;

                        for jj=1:numel(colsToUpdate)
                            dataColName=colsToUpdate{jj};
                            dataColIdx=strcmp(dataColName,outputRepeatedVar.DataColumnNames);
                            children=outputRepeatedVar.ChildrenForEachDataColumn{dataColIdx};
                            numChildren=numel(children);
                            outputRepeatedVar.PlotOnCurrentDisplay{dataColIdx}=false(1,numChildren);
                            outputRepeatedVar.UpdateDisplays{dataColIdx}=false(1,numChildren);
                            for k=1:numChildren
                                childID=children(k);
                                [outputRepeatedVar.PlotOnCurrentDisplay{dataColIdx}(k),...
                                outputRepeatedVar.UpdateDisplays{dataColIdx}(k)]=...
                                checkPlotStatus(this,childID,selectedDisplay,plotFlag);
                            end
                        end

                        colsToAdd=union(outputRepeatedVar.DataColumnsToAdd,...
                        outputRepeatedVar.DataColumnsToDeletAndReImport);

                        for jj=1:numel(colsToAdd)
                            dataColName=colsToAdd{jj};
                            dataColIdx=strcmp(dataColName,outputRepeatedVar.DataColumnNames);
                            children=outputRepeatedVar.ChildrenForEachDataColumn{dataColIdx};
                            numChildren=numel(children);
                            outputRepeatedVar.PlotOnCurrentDisplay{dataColIdx}=false(1,numChildren);
                            outputRepeatedVar.UpdateDisplays{dataColIdx}=false(1,numChildren);
                            for k=1:numChildren
                                outputRepeatedVar.PlotOnCurrentDisplay{dataColIdx}(k)=plotFlag;
                            end
                        end
                    else



                        [outputRepeatedVar.PlotOnCurrentDisplay{1},outputRepeatedVar.UpdateDisplays{1}]=...
                        checkPlotStatus(this,varID,selectedDisplay,plotFlag);
                    end
                    outputRepeatedVars=[outputRepeatedVars,outputRepeatedVar];
                end
            end
            this.NewVarNames=newVarNames;
            this.RepeatedVars=outputRepeatedVars;
        end

        function processNewVariables(this,newVarNames,plotFlag,clientID,runID)





            if isempty(newVarNames)
                return;
            end
            numVars=numel(newVarNames);
            varMetadata.AppendLSSNameToMembers=this.isAppSignalAnalyzer();
            varMetadata.IsNonFiniteSupported=this.isAppSignalAnalyzer();
            vars=repmat(struct('VarName','','VarValue',[],'TimeSourceRule','siganalyzer','sampleTimeOrRate',-1,'Metadata',varMetadata),numVars,1);
            importVar=true(length(vars),1);
            invalidInherentTimeDataIdx=[];
            for idx=1:numVars
                name=newVarNames{idx};
                if~this.isAppSignalAnalyzer()&&strcmp(this.NewSignalMetaData.data.tmMode,'file')
                    varValues=[0;1];
                    t=[0;1];
                elseif~isempty(this.SigVals)


                    sigIdx=strcmp(name,this.SigValNames);
                    varValues=this.SigVals{sigIdx};
                else




                    [varValues,err]=evaluatevars(name);%#ok<ASGLU>
                end



                if isa(varValues,'timetable')||isa(varValues,'timeseries')
                    vars(idx).VarName=name;
                    if isa(varValues,'timetable')
                        varValues.Properties.VariableNames=matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(varValues.Properties.VariableNames));
                    end
                    vars(idx).VarValue=varValues;



                    [isValidFlag,totalChannels]=this.checkInherentTimeData(vars(idx));
                    if~(isValidFlag)
                        invalidInherentTimeDataIdx=[invalidInherentTimeDataIdx,idx];
                        this.NewVarNames(strcmp(this.NewVarNames,name))=[];
                        continue;
                    end
                    if totalChannels>100&&this.WarnIfExceedsMaxNumColumns
                        response=warnIfFat(name);
                        if strcmp(response,'no')


                            importVar(idx)=false;

                            this.NewVarNames(strcmp(this.NewVarNames,name))=[];
                            continue;
                        end
                    end
                elseif isa(varValues,'labeledSignalSet')
                    vars(idx).VarName=name;



                    varValues=copy(varValues);

                    vars(idx).VarValue=varValues;
                    vars(idx).TimeInformation=varValues.TimeInformation;








                    switch varValues.TimeInformation
                    case "sampleRate"
                        vars(idx).startTime=0;
                        vars(idx).sampleTimeOrRate=varValues.SampleRate;
                    case "sampleTime"
                        vars(idx).startTime=0;
                        vars(idx).sampleTimeOrRate=varValues.SampleTime;
                    end

                    if isduration(vars(idx).sampleTimeOrRate)
                        vars(idx).sampleTimeOrRate=seconds(vars(idx).sampleTimeOrRate);
                    end



                    [isValidFlag,totalChannels]=this.checkInherentTimeData(vars(idx));
                    if~(isValidFlag)
                        invalidInherentTimeDataIdx=[invalidInherentTimeDataIdx,idx];
                        this.NewVarNames(strcmp(this.NewVarNames,name))=[];
                        continue;
                    end
                    if totalChannels>100&&this.WarnIfExceedsMaxNumColumns
                        response=warnIfFat(name);
                        if strcmp(response,'no')


                            importVar(idx)=false;

                            this.NewVarNames(strcmp(this.NewVarNames,name))=[];
                            continue;
                        end
                    end
                else
                    if isrow(varValues)
                        varValues=varValues(:);
                    end


                    if size(varValues,2)>100&&this.WarnIfExceedsMaxNumColumns
                        response=warnIfFat(name);
                        if strcmp(response,'no')


                            importVar(idx)=false;

                            this.NewVarNames(strcmp(this.NewVarNames,name))=[];
                            continue;
                        end
                    end





                    if isempty(this.NewSignalMetaData)||strcmp(this.NewSignalMetaData.data.tmMode,'samples')
                        t=(0:size(varValues,1)-1)';
                    elseif strcmp(this.NewSignalMetaData.data.tmMode,'fs')
                        startTime=this.NewSignalMetaData.data.startTime;
                        sampleRate=this.NewSignalMetaData.data.sampleTimeOrRate;
                        t=startTime+(0:size(varValues,1)-1)'/sampleRate;
                    elseif strcmp(this.NewSignalMetaData.data.tmMode,'ts')
                        startTime=this.NewSignalMetaData.data.startTime;
                        sampleTime=this.NewSignalMetaData.data.sampleTimeOrRate;
                        t=startTime+(0:size(varValues,1)-1)'*sampleTime;
                    elseif strcmp(this.NewSignalMetaData.data.tmMode,'tv')
                        t=this.NewSignalMetaData.data.timeVector;
                    end
                    vars(idx).VarName=name;
                    vars(idx).VarValue=[double(t),double(varValues)];
                end
            end


            vars(invalidInherentTimeDataIdx)=[];
            if~isempty(invalidInherentTimeDataIdx)
                this.ErrorIDForUnImportedInherentVars="ImportInvalidTimeInherentDataWarn";
                if this.isAppSignalAnalyzer()



                    msg=getString(message('SDI:sigAnalyzer:ImportInvalidTimeInherentDataWarn'));
                    titleStr=getString(message('SDI:sigAnalyzer:ImportWarning'));
                    okStr=getString(message('SDI:sigAnalyzer:Ok'));

                    Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                    'default',...
                    titleStr,...
                    msg,...
                    {okStr},...
                    0,...
                    -1,...
                    [],...
                    'clientID',clientID);

                end
                if isempty(vars)
                    return;
                end
            end

            vars(~importVar)=[];
            if isempty(vars)
                return;
            end


            wksParser=Simulink.sdi.internal.import.WorkspaceParser();
            varParser=parseVariables(wksParser,vars);
            if isempty(varParser)
                return;
            end

            if isempty(runID)



                if(this.AppName=="SignalLabeler")


                    newRunID=createRun(wksParser,this.engine,varParser,'','','signallabeler',false);
                else
                    newRunID=createRun(wksParser,this.engine,varParser,'','','siganalyzer',false);
                end

                this.targetRunID=newRunID;
            else

                addToRun(wksParser,this.engine,this.targetRunID,varParser);
                notify(this.engine,'signalsInsertedEvent',...
                Simulink.sdi.internal.SDIEvent('signalsInsertedEvent',...
                this.targetRunID));
            end


            safeTransaction(this.engine,@this.getNamesOfPurelyParentSignals,this.targetRunID);




            orderAlphabetically=~(this.AppName=="SignalLabeler"&&strcmp(this.NewSignalMetaData.data.tmMode,'file'));

            if orderAlphabetically
                [~,newParentSigIdx,newVarIdx]=intersect(this.NamesOfPurelyParentSignals,{vars.VarName});
            else
                [~,newParentSigIdx,newVarIdx]=intersect(this.NamesOfPurelyParentSignals,{vars.VarName},'Stable');
            end

            newParentSigIDs=this.IDsOfPurelyParentSignals(newParentSigIdx);
            newVars=vars(newVarIdx);

            this.NewAddedSignalIDs=newParentSigIDs;
            this.NewAddedVarNames=string({newVars.VarName});

            idsForPlot=[];
            isLSSMatFileExists=logical.empty();
            matFileObj=[];
            recurseAllChildrenIDs=[];
            parentSigChildrenIDs=[];
            for idx=1:numel(newParentSigIDs)


                leafChildrenIDs=signal.analyzer.SignalUtilities.getSignalLeafChildren(this.engine,newParentSigIDs(idx));
                if isempty(leafChildrenIDs)


                    if plotFlag
                        idsForPlot=[idsForPlot;newParentSigIDs(idx)];
                    end
                else
                    if plotFlag





                        s=struct('ChildrenIDs',leafChildrenIDs,...
                        'HasChildren',true);
                        s.TmMode=this.engine.getSignalTmMode(newParentSigIDs(idx));
                        s.Name=this.NewAddedVarNames(idx);
                        s=getComplexityAndDimensions(this,s);

                        plotCount=1;
                        for dataColIdx=1:numel(s.DataColumnNames)
                            childrenChannelIndices=s.DataColumChildrenIndices{dataColIdx};
                            childrenIDs=s.ChildrenForEachDataColumn{dataColIdx};
                            for k=1:numel(childrenChannelIndices)
                                if plotCount<11


                                    idsForPlot=[idsForPlot;childrenIDs(k)];
                                    plotCount=plotCount+1;
                                else
                                    break;
                                end
                            end
                            if plotCount>10
                                break;
                            end
                        end
                    end
                end
                isCurrentParentIDLSS=isa(newVars(idx).VarValue,'labeledSignalSet');
                if isCurrentParentIDLSS
                    recurseAllChildrenIDs=signal.sigappsshared.SignalUtilities.recurseGetAllChildren(this.engine,newParentSigIDs(idx));
                    parentSigChildrenIDs=getSignalChildren(this.engine,newParentSigIDs(idx));

                end
                if isempty(this.NewSignalMetaData)


                    currentParentSigIDTmMode=this.engine.getSignalTmMode(newParentSigIDs(idx));
                    updateTimeMetaData(this,newParentSigIDs(idx),newVars(idx),currentParentSigIDTmMode,isCurrentParentIDLSS,parentSigChildrenIDs,recurseAllChildrenIDs);
                else


                    updateTimeMetaData(this,newParentSigIDs(idx),newVars(idx),'',isCurrentParentIDLSS,parentSigChildrenIDs,recurseAllChildrenIDs);
                end
                if this.isAppSignalAnalyzer()

                    updateSignalMetaDataFlags(this,newParentSigIDs(idx),newVars(idx),true,leafChildrenIDs);

                    if isempty(isLSSMatFileExists)
                        LSSMatFileName=signal.sigappsshared.SignalUtilities.getStorageLSSFilename();
                        isLSSMatFileExists=exist(LSSMatFileName,'file')==2;
                        if isLSSMatFileExists
                            matFileObj=matfile(LSSMatFileName,'Writable',true);
                        end
                    end
                    addLabeledSignalSetToSavedFile(this,newParentSigIDs(idx),newVars(idx),isLSSMatFileExists,matFileObj,idx==1,isCurrentParentIDLSS,parentSigChildrenIDs,recurseAllChildrenIDs);
                end
            end

            if plotFlag

                Simulink.sdi.plotSignalsAndUpdateTableChecks(...
                this.engine.sigRepository,clientID,idsForPlot,true,'importFromDrop');
            end
        end

        function processRepeatedVariables(this,repeatedVars,clientID)


            if isempty(repeatedVars)
                return;
            end



            idsForPlotOnCurrentDisplay=[];
            idsForUpdateDisplay=[];
            for idx=1:numel(repeatedVars)
                s=repeatedVars(idx);
                if s.HasChildren
                    plotCount=1;


                    for dataColIdx=1:numel(s.DataColumnNames)
                        for k=1:numel(s.ChildrenForEachDataColumn{dataColIdx})
                            childID=s.ChildrenForEachDataColumn{dataColIdx}(k);
                            if s.PlotOnCurrentDisplay{dataColIdx}(k)&&(plotCount<11)



                                idsForPlotOnCurrentDisplay=[idsForPlotOnCurrentDisplay;childID];
                                plotCount=plotCount+1;
                            elseif s.UpdateDisplays{dataColIdx}(k)


                                idsForUpdateDisplay=[idsForUpdateDisplay;childID];
                            end
                        end
                    end
                else
                    sigID=s.ID;
                    if s.PlotOnCurrentDisplay{1}



                        idsForPlotOnCurrentDisplay=[idsForPlotOnCurrentDisplay;sigID];
                    elseif s.UpdateDisplays{1}


                        idsForUpdateDisplay=[idsForUpdateDisplay;sigID];
                    end
                end
            end

            if~isempty(idsForPlotOnCurrentDisplay)







                Simulink.sdi.plotSignalsAndUpdateTableChecks(...
                this.engine.sigRepository,clientID,idsForPlotOnCurrentDisplay,true,'importFromDrop');
            end
            if~isempty(idsForUpdateDisplay)




                Simulink.sdi.plotSignalsAndUpdateTableChecks(...
                this.engine.sigRepository,clientID,idsForUpdateDisplay,false,'importFromDrop');
            end

        end

        function updateStruct=updateData(this,sigStruct)

            varName=sigStruct.Name;
            sigTmMode=sigStruct.TmMode;
            runID=this.getRunIDs(this.AppName);

            if~isempty(this.SigVals)


                sigIdx=strcmp(sigStruct.Name,this.SigValNames);
                newValues=this.SigVals{sigIdx};
            else



                [newValues,err]=evaluatevars(varName);%#ok<ASGLU>
            end


            if strcmp(sigStruct.TmMode,'inherentLabeledSignalSet')

                deleteSignalAndReImport=true;

                removeLabeledSignalSetFromSavedFile(this,sigStruct.ID);
            elseif strcmp(sigStruct.TmMode,'inherentTimeseries')
                deleteSignalAndReImport=~isa(newValues,'timeseries');
                if~deleteSignalAndReImport


                    newName=newValues.Name;
                    if numel(sigStruct.ChildrenIDs)>0
                        oldName=this.engine.getSignalLabel(sigStruct.ChildrenIDs(1));
                    else
                        oldName=this.engine.getSignalLabel(sigStruct.ID);
                    end
                    dotIdx=strfind(oldName,'.');
                    paranIdx=strfind(oldName,'(');
                    if isempty(dotIdx)
                        oldName='';
                    else
                        if isempty(paranIdx)
                            oldName=oldName(dotIdx(1)+1:end);
                        else
                            oldName=oldName(dotIdx(1)+1:paranIdx(1)-1);
                        end
                    end
                    if~strcmp(newName,oldName)
                        deleteSignalAndReImport=true;
                    end
                end
            elseif strcmp(sigStruct.TmMode,'inherentTimetable')
                deleteSignalAndReImport=~istimetable(newValues);
            else
                deleteSignalAndReImport=~isnumeric(newValues)&&~islogical(newValues);
                if~deleteSignalAndReImport&&isrow(newValues)
                    newValues=newValues(:);
                end
            end

            if deleteSignalAndReImport
                this.deleteSignalAndChildren(sigStruct);
                updateStruct.DeleteSignalAndReImport=true;
                return;
            end



            [sigStruct,currentData]=getComplexityAndDimensions(this,sigStruct);
            updateStruct=struct(...
            'Name',sigStruct.Name,...
            'ID',sigStruct.ID,...
            'HasChildren',sigStruct.HasChildren,...
            'TmMode',sigStruct.TmMode,...
            'DataColumnNames',{sigStruct.DataColumnNames},...
            'ChildrenForEachDataColumn',{sigStruct.ChildrenForEachDataColumn},...
            'DeleteSignalAndReImport',false,...
            'DataColumnsToAdd',{{}},...
            'DataColumnsToDelete',{{}},...
            'DataColumnsToDeletAndReImport',{{}},...
            'DataColumnsToUpdate',{{}});

            if isa(newValues,'timeseries')

                [newValues,newTimeVector]=this.extractTimeSeriesValues(varName,newValues);
                if isempty(newValues)

                    this.deleteSignalAndChildren(sigStruct);
                    updateStruct.DeleteSignalAndReImport=true;
                    return;
                end
            end


            newDataStruct=getComplexityAndDimensionsOfNewData(this,varName,newValues);

            if isempty(newDataStruct.DataColumnNames)
                this.deleteSignalAndChildren(sigStruct);
                updateStruct.DeleteSignalAndReImport=true;
                return;
            end





            deleteFlag=false;
            if strcmp(sigTmMode,'inherentTimetable')

                commonDataCols=intersect(sigStruct.DataColumnNames,newDataStruct.DataColumnNames);
                if isempty(commonDataCols)

                    updateStruct.DeleteSignalAndReImport=true;
                    this.deleteSignalAndChildren(sigStruct);
                    return;
                end



                for idx=1:numel(commonDataCols)
                    dataColName=commonDataCols{idx};
                    oldIdx=strcmp(dataColName,sigStruct.DataColumnNames);
                    newIdx=strcmp(dataColName,newDataStruct.DataColumnNames);

                    deleteFlag=sigStruct.DataColumnSizes{oldIdx}(2)~=newDataStruct.DataColumnSizes{newIdx}(2);
                    if~deleteFlag
                        deleteFlag=~all(sigStruct.DataColumnChannelIsReal{oldIdx}==newDataStruct.DataColumnChannelIsReal{newIdx});

                    end
                    if~deleteFlag&&this.isAppSignalAnalyzer()
                        deleteFlag=~all(sigStruct.IsFinite{oldIdx}==newDataStruct.IsFinite{newIdx});
                    end
                    if deleteFlag
                        updateStruct.DataColumnsToDeletAndReImport{end+1}=dataColName;
                    else
                        updateStruct.DataColumnsToUpdate{end+1}=dataColName;
                    end
                end


                updateStruct.DataColumnsToDelete=setdiff(sigStruct.DataColumnNames,newDataStruct.DataColumnNames);

                updateStruct.DataColumnsToAdd=setdiff(newDataStruct.DataColumnNames,sigStruct.DataColumnNames);

                if~isempty(updateStruct.DataColumnsToDeletAndReImport)&&...
                    isempty(updateStruct.DataColumnsToAdd)&&...
                    isempty(updateStruct.DataColumnsToDelete)&&...
                    isempty(updateStruct.DataColumnsToUpdate)


                    updateStruct.DeleteSignalAndReImport=true;
                    this.deleteSignalAndChildren(sigStruct);
                    return;
                end

            else

                if(strcmp(sigTmMode,'tv')&&~all(sigStruct.DataColumnSizes{1}==newDataStruct.DataColumnSizes{1}))||...
                    (sigStruct.DataColumnSizes{1}(2)~=newDataStruct.DataColumnSizes{1}(2))||...
                    (all(sigStruct.DataColumnChannelIsReal{1})&&sigStruct.HasChildren&&newDataStruct.DataColumnSizes{1}(2)==1)
                    deleteFlag=true;
                end
                if~deleteFlag
                    deleteFlag=~all(sigStruct.DataColumnChannelIsReal{1}==newDataStruct.DataColumnChannelIsReal{1});
                end
                if~deleteFlag&&this.isAppSignalAnalyzer()
                    deleteFlag=~all(sigStruct.IsFinite{1}==newDataStruct.IsFinite{1});
                end

                updateStruct.DeleteSignalAndReImport=deleteFlag;
                if deleteFlag
                    this.deleteSignalAndChildren(sigStruct);
                    return;
                else
                    updateStruct.DataColumnsToUpdate{end+1}=sigStruct.DataColumnNames{1};
                end
            end

            if strcmp(sigTmMode,'inherentTimetable')

                colsToDelete=union(updateStruct.DataColumnsToDelete,updateStruct.DataColumnsToDeletAndReImport);
                for idx=1:numel(colsToDelete)
                    dataColName=colsToDelete{idx};
                    dataColIdx=strcmp(dataColName,updateStruct.DataColumnNames);
                    children=updateStruct.ChildrenForEachDataColumn{dataColIdx};

                    this.deleteSignals(children,sigStruct.ID);
                    if ismember(dataColName,updateStruct.DataColumnsToDelete)
                        updateStruct.DataColumnNames(dataColIdx)=[];
                        updateStruct.ChildrenForEachDataColumn(dataColIdx)=[];
                    end
                end


                for idx=1:numel(updateStruct.DataColumnsToUpdate)
                    dataColName=updateStruct.DataColumnsToUpdate{idx};
                    dataColIdx=strcmp(dataColName,sigStruct.DataColumnNames);
                    newDataColIdx=strcmp(dataColName,newDataStruct.DataColumnNames);
                    inputNewValues.Data=newValues.(dataColName);
                    inputNewValues.Time=seconds(newValues.Properties.RowTimes);
                    setNewDataChildren(this,sigStruct,dataColIdx,inputNewValues,newDataStruct.DataColumnSizes{newDataColIdx});
                end


                dataColsToAdd=union(...
                updateStruct.DataColumnsToAdd,...
                updateStruct.DataColumnsToDeletAndReImport);

                for idx=1:numel(dataColsToAdd)


                    dataColName=dataColsToAdd{idx};
                    dataColIdx=strcmp(dataColName,updateStruct.DataColumnNames);
                    if~any(dataColIdx)
                        dataColIdx=numel(dataColIdx)+1;
                        updateStruct.DataColumnNames{dataColIdx}=dataColName;
                    end
                    varMetadata.AppendLSSNameToMembers=this.isAppSignalAnalyzer();
                    varMetadata.IsNonFiniteSupported=this.isAppSignalAnalyzer();
                    var=struct('VarName',sigStruct.Name,'VarValue',newValues,'TimeSourceRule','siganalyzer','Metadata',varMetadata);
                    wksParser=Simulink.sdi.internal.import.WorkspaceParser();
                    varParser=parseVariables(wksParser,var);
                    if isempty(varParser)
                        continue;
                    end
                    varParserChildren=getChildren(varParser{1});
                    varParserChildrenIdx=cell2mat(cellfun(@(x)strcmp(x.VariableName,[sigStruct.Name,'.',dataColName]),varParserChildren,'UniformOutput',false));
                    varParser=varParserChildren(varParserChildrenIdx);
                    if isempty(varParser)
                        continue;
                    end
                    sigsBefore=signal.analyzer.SignalUtilities.getSignalLeafChildren(this.engine,sigStruct.ID);
                    addToParentSignal(wksParser,this.engine.sigRepository,varParser,sigStruct.ID);
                    sigsAfter=signal.analyzer.SignalUtilities.getSignalLeafChildren(this.engine,sigStruct.ID);
                    newSigs=setdiff(sigsAfter,sigsBefore);
                    updateStruct.ChildrenForEachDataColumn{dataColIdx}=newSigs;
                    for newSigIdx=1:numel(newSigs)

                        currentData=signal.sigappsshared.SignalUtilities.getSignalDataStructure(this.engine,newSigs(newSigIdx),runID);
                        this.updateResampledSignal(newSigs(newSigIdx),currentData);
                    end
                end
            else
                if strcmp({'inherentTimeseries'},sigTmMode)
                    inputNewValues.Data=newValues;
                    inputNewValues.Time=newTimeVector;
                else
                    inputNewValues=newValues;
                end
                dataColIdx=1;
                if sigStruct.HasChildren
                    updatedTmMode=setNewDataChildren(this,sigStruct,dataColIdx,inputNewValues,newDataStruct.DataColumnSizes{1});
                else
                    updatedTmMode=setNewData(this,sigStruct,dataColIdx,inputNewValues,newDataStruct.DataColumnSizes{1},currentData);
                end
                if~strcmp({'inherentTimeseries'},sigTmMode)
                    updateStruct.TmMode=updatedTmMode;
                end
            end

            if this.isAppSignalAnalyzer()

                updateSignalMetaDataFlags(this,sigStruct.ID,newValues,false);
            end
        end


        function updatedTmMode=setNewData(this,sigStruct,dataColIdx,newValues,sizeNewValues,currentData,sigID)

            if nargin>6
                varID=sigID;
            else
                varID=sigStruct.ID;
            end

            varObj=this.engine.getSignalObject(varID);

            tmd=signal.sigappsshared.controllers.TimeMetadataDialog.getController();
            varTmMode=this.engine.getSignalTmMode(varID);


            if isstruct(newValues)
                currentData.Data=double(newValues.Data);
                currentData.Time=double(newValues.Time);
            else
                currentData.Data=double(newValues);
            end

            this.removeAllAuxilarySignals(varID);

            updatedTmMode=sigStruct.TmMode;
            updateTmModeFlag=false;
            if~isempty(this.NewSignalMetaData)
                updatedTmMode=this.NewSignalMetaData.data.tmMode;
                if~any(strcmp(updatedTmMode,this.INHERENTTYPES))
                    varTmMode=updatedTmMode;
                    updateTmModeFlag=true;
                end
            end

            if strcmp(varTmMode,'tv')

                updateStruct.sigDataValues=currentData.Data;
                if updateTmModeFlag
                    currentData.Time=this.NewSignalMetaData.data.timeVector;
                    timeVectorStr='';
                else
                    currentData.Time=this.engine.getSignalDataValues(varID).Time;
                    timeVectorStr=this.engine.getSignalTmTimeVectorStr(varID);
                end
                tmd.setTimeMetadataByTimeVector(varID,currentData.Time,timeVectorStr,updateStruct);
            elseif any(strcmp(varTmMode,this.INHERENTTYPES))
                varObj.Values=currentData;
                this.updateResampledSignal(varID,currentData);
            elseif(sizeNewValues(1)==sigStruct.DataColumnSizes{dataColIdx}(1))&&~updateTmModeFlag

                varObj.Values=currentData;
            else


                updateStruct.sigDataValues=currentData.Data;
                updateStruct.sigLength=sizeNewValues(1);


                switch lower(varTmMode)
                case{'samples','none'}
                    tmd.setTimeMetadataBySamples(varID,updateStruct)
                case 'fs'
                    if updateTmModeFlag
                        [fs,fsUnits]=this.getEngUnits(this.NewSignalMetaData.data.sampleTimeOrRate,false);
                        [startTime,startTimeUnits]=this.getEngUnits(this.NewSignalMetaData.data.startTime,true);
                    else
                        fs=this.engine.getSignalTmSampleRate(varID);
                        fsUnits=this.engine.getSignalTmSampleRateUnits(varID);
                        startTime=this.engine.getSignalTmStartTime(varID);
                        startTimeUnits=this.engine.getSignalTmStartTimeUnits(varID);
                    end
                    tmd.setTimeMetadataByFs(varID,fs,fsUnits,startTime,startTimeUnits,updateStruct);
                case 'ts'
                    if updateTmModeFlag
                        [ts,tsUnits]=this.getEngUnits(this.NewSignalMetaData.data.sampleTimeOrRate,true);
                        [startTime,startTimeUnits]=this.getEngUnits(this.NewSignalMetaData.data.startTime,true);
                    else
                        ts=this.engine.getSignalTmSampleTime(varID);
                        tsUnits=this.engine.getSignalTmSampleTimeUnits(varID);
                        startTime=this.engine.getSignalTmStartTime(varID);
                        startTimeUnits=this.engine.getSignalTmStartTimeUnits(varID);
                    end
                    tmd.setTimeMetadataByTs(varID,ts,tsUnits,startTime,startTimeUnits,updateStruct);
                end
            end
        end


        function updatedTmMode=setNewDataChildren(this,sigStruct,dataColIdx,newValues,sizeNewValues)

            children=sigStruct.ChildrenForEachDataColumn{dataColIdx};
            childrenChannelIndices=sigStruct.DataColumChildrenIndices{dataColIdx};
            runID=this.getRunIDs(this.AppName);
            for idx=1:numel(children)
                varID=children(idx);
                currentData=signal.sigappsshared.SignalUtilities.getSignalDataStructure(this.engine,varID,runID);


                channel=childrenChannelIndices(idx);
                if isstruct(newValues)
                    inputNewValues.Data=newValues.Data(:,channel);
                    inputNewValues.Time=newValues.Time;
                else
                    inputNewValues=newValues(:,channel);
                end
                updatedTmMode=setNewData(this,sigStruct,dataColIdx,inputNewValues,sizeNewValues,currentData,varID);
            end
        end

        function[plotOnCurrentDisplay,updateDisplays]=checkPlotStatus(this,sigID,selectedDisplay,plotFlag)


            checkedPlots=this.engine.getSignalCheckedPlots(sigID);





            plotOnCurrentDisplay=...
            ~ismember(double(selectedDisplay),double(checkedPlots))&&plotFlag;



            updateDisplays=~isempty(checkedPlots);
        end


        function[sigStruct,currentData]=getComplexityAndDimensions(this,sigStruct)

            currentData=[];







            sigStruct=getDataColumnNames(this,sigStruct);



            sigStruct.DataColumChildrenIndices=cell(size(sigStruct.DataColumnNames));
            sigStruct.DataColumnChannelIsReal=cell(size(sigStruct.DataColumnNames));
            sigStruct.DataColumnSizes=cell(size(sigStruct.DataColumnNames));
            sigStruct.IsFinite=cell(size(sigStruct.DataColumnNames));

            if sigStruct.HasChildren
                for dataColIdx=1:numel(sigStruct.DataColumnNames)
                    childrenIDs=sigStruct.ChildrenForEachDataColumn{dataColIdx};
                    numChildren=numel(childrenIDs);
                    sigStruct.DataColumnSizes{dataColIdx}=[0,0];
                    sigStruct.DataColumnChannelIsReal{dataColIdx}=false(1,numChildren);
                    if this.isAppSignalAnalyzer()
                        sigStruct.IsFinite{dataColIdx}=true(1,numChildren);
                    end
                    for idx=1:numChildren
                        sig=this.engine.getSignal(childrenIDs(idx));
                        if isempty(sig.Channel)
                            str=sig.DataSource;
                            idxStart=strfind(str,',');
                            idxEnd=strfind(str,')');
                            if isempty(idxStart)||isempty(idxEnd)
                                colIdx=idx;
                            else
                                colIdx=str2double(str(idxStart(1)+1:idxEnd(1)-1));
                            end
                            sigStruct.DataColumChildrenIndices{dataColIdx}(idx)=colIdx;

                        else
                            if size(sig.SampleDims)==1
                                colIdx=sig.Channel;
                            else
                                colIdx=sig.Channel(1)+sig.SampleDims(1)*(sig.Channel(2)-1);
                            end
                            sigStruct.DataColumChildrenIndices{dataColIdx}(idx)=colIdx;
                        end

                        sigStruct.DataColumnChannelIsReal{dataColIdx}(colIdx)=...
                        ~this.engine.sigRepository.getSignalComplexityAndLeafPath(childrenIDs(idx)).IsComplex;
                        sigStruct.DataColumnSizes{dataColIdx}(2)=sigStruct.DataColumnSizes{dataColIdx}(2)+1;

                    end
                    sigStruct.DataColumnSizes{dataColIdx}(1)=length(sig.DataValues.Data);
                end
            else
                currentData=this.engine.getSignalDataValues(sigStruct.ID);
                sigStruct.DataColumnChannelIsReal{1}=isreal(currentData.Data);
                sigStruct.DataColumnSizes{1}=size(currentData.Data);
                if this.isAppSignalAnalyzer()
                    sigStruct.IsFinite{1}=logical(this.engine.getMetaDataV2(sigStruct.ID,'IsFinite'));
                end
            end
        end


        function sigStruct=getComplexityAndDimensionsOfNewData(this,varName,data)
            sigStruct=struct;
            if isnumeric(data)||islogical(data)
                sz=size(data);
                sigStruct.DataColumnNames{1}=varName;
                sigStruct.DataColumnSizes{1}=sz;
                sigStruct.DataColumnChannelIsReal{1}=false(1,sz(2));
                if this.isAppSignalAnalyzer()
                    sigStruct.IsFinite{1}=true(1,sz(2));
                end
                for idx=1:sz(2)
                    sigStruct.DataColumnChannelIsReal{1}(idx)=isreal(data(:,idx));
                    if this.isAppSignalAnalyzer()
                        sigStruct.IsFinite{1}(idx)=allfinite(data(:,idx));
                    end
                end
            elseif istimetable(data)
                sigStruct.DataColumnNames=data.Properties.VariableNames;
                varMetadata.AppendLSSNameToMembers=this.isAppSignalAnalyzer();
                varMetadata.IsNonFiniteSupported=this.isAppSignalAnalyzer();
                varStruct=struct('VarName',varName,'VarValue',data,'TimeSourceRule','siganalyzer','Metadata',varMetadata);
                [isValid,~,parserChildren]=checkInherentTimeData(this,varStruct);

                if~isValid
                    sigStruct.DataColumnNames={};
                    return;
                end

                removeIdx=[];
                for idx=1:numel(sigStruct.DataColumnNames)
                    name=sigStruct.DataColumnNames{idx};
                    validFlag=any(cell2mat(cellfun(@(x)strcmp(x.VariableName,[varName,'.',name]),parserChildren,'UniformOutput',false)));
                    if validFlag
                        sigStruct.DataColumnSizes{idx}=size(data.(name));
                        for kk=1:sigStruct.DataColumnSizes{idx}(2)
                            sigStruct.DataColumnChannelIsReal{idx}(kk)=isreal(data.(name)(:,kk));
                            if this.isAppSignalAnalyzer()
                                sigStruct.IsFinite{idx}(kk)=allfinite(data.(name)(:,kk));
                            end
                        end
                    else
                        removeIdx=[removeIdx,idx];
                        sigStruct.DataColumnSizes{idx}=[];
                        sigStruct.DataColumnChannelIsReal{idx}=[];
                    end
                end
                sigStruct.DataColumnNames(removeIdx)=[];
                sigStruct.DataColumnSizes(removeIdx)=[];
                sigStruct.DataColumnChannelIsReal(removeIdx)=[];
            end
        end


        function children=getSignalNonLeafChildren(this,varID)


            leafSigs=int32(Simulink.HMI.findAllLeafSigIDsForThisRoot(this.engine.sigRepository,varID));



            children=setdiff(leafSigs,varID);


            removeIdx=false(1,numel(children));
            for idx=1:numel(children)
                removeIdx(idx)=(this.engine.getSignalNumberOfPoints(children(idx))~=0);
            end
            children(removeIdx)=[];
        end


        function[sigNames,sigIdsVect]=getNamesOfPurelyParentSignals(this,runIds)


            cnt=0;
            sigNames={};
            sigIdsVect=[];
            for r=1:numel(runIds)
                sigIds=this.engine.getAllSignalIDs(int32(runIds(r)));
                for k=1:numel(sigIds)
                    if any(strcmp(this.engine.getSignalTmMode(sigIds(k)),{'domainSignal','resampled','none'}))



                        continue;
                    end
                    parent=this.engine.getSignalParent(sigIds(k));
                    if parent==0
                        cnt=cnt+1;
                        sigNames{cnt}=this.engine.getSignalRootSource(sigIds(k));
                        sigIdsVect=[sigIdsVect;sigIds(k)];
                    end
                end
            end


            this.NamesOfPurelyParentSignals=sigNames;
            this.IDsOfPurelyParentSignals=sigIdsVect;
        end


        function sigStruct=getDataColumnNames(this,sigStruct)



            if strcmp(sigStruct.TmMode,'inherentTimetable')
                dataColumnNames=cell(1,numel(sigStruct.ChildrenIDs));
                for idx=1:numel(sigStruct.ChildrenIDs)
                    rootSource=this.engine.getSignalRootSource(sigStruct.ChildrenIDs(idx));
                    idxStart=strfind(rootSource,'.');
                    idxEnd=length(rootSource);
                    dataColumnNames{idx}=rootSource(idxStart+1:idxEnd);
                end
                uniqueDataColumnNames=unique(dataColumnNames);
                childrenForEachColumn=cell(1,numel(uniqueDataColumnNames));
                for idx=1:numel(uniqueDataColumnNames)
                    childrenForEachColumnIdx=strcmp(dataColumnNames,uniqueDataColumnNames{idx});
                    childrenForEachColumn{idx}=sigStruct.ChildrenIDs(childrenForEachColumnIdx);
                end
                sigStruct.ChildrenForEachDataColumn=childrenForEachColumn;
                sigStruct.DataColumnNames=uniqueDataColumnNames;
            else
                sigStruct.DataColumnNames={sigStruct.Name};
                sigStruct.ChildrenForEachDataColumn={sigStruct.ChildrenIDs};
            end

        end

        function[scaledTimeorFrequency,units]=getEngUnits(obj,x,isTime)%#ok<INUSL>




            if isTime
                [scaledTimeorFrequency,scaleFactor,units]=engunits(x,'time');
                if scaleFactor>1e9
                    units='ns';
                    scaledTimeorFrequency=x/1e-9;
                end
                if strcmp(units,'secs')
                    units='s';
                end
                if strcmp(units,'mins')
                    units='minutes';
                end
                if strcmp(units,'hrs')
                    units='hours';
                end
            else

                if x<1
                    units='Hz';
                    scaledTimeorFrequency=x;
                elseif x>1e9
                    units='GHz';
                    scaledTimeorFrequency=x/1e9;
                else
                    [scaledTimeorFrequency,~,units]=engunits(x);
                    units=[units,'Hz'];
                end
            end
        end


        function updateTimeMetaData(this,newParentSigID,newVar,type,isCurrentParentSigIDLSS,parentSigChildrenIDs,recurseAllChildrenIDs)


            isNotifyTableFlag=this.isAppSignalAnalyzer();
            tmd=signal.sigappsshared.controllers.TimeMetadataDialog.getController();
            runID=this.getRunIDs(this.AppName);
            if isCurrentParentSigIDLSS



                signal.sigappsshared.SignalUtilities.setMemberIndexLabeledSignalSet(this.engine,newParentSigID,-1);


                switch newVar.TimeInformation
                case "sampleRate"
                    tmModeLSS='fs';
                case "sampleTime"
                    tmModeLSS='ts';
                case "timeValues"
                    tmModeLSS='tv';
                case "inherent"
                    tmModeLSS='inherentTimetable';
                case "none"
                    tmModeLSS='samples';
                end
                lssParentAndAllChildrenIDs=[newParentSigID;recurseAllChildrenIDs];
                for midx=1:length(lssParentAndAllChildrenIDs)


                    this.engine.setSignalTmMode(lssParentAndAllChildrenIDs(midx),'inherentLabeledSignalSet',isNotifyTableFlag);



                    signal.sigappsshared.SignalUtilities.setTmModeLabeledSignalSet(this.engine,lssParentAndAllChildrenIDs(midx),tmModeLSS);
                end



                updateTmModeFlag=false;
                members=parentSigChildrenIDs;
                for midx=1:length(members)




                    signal.sigappsshared.SignalUtilities.setMemberIndexLabeledSignalSet(this.engine,members(midx),midx);



                    memberLeafNodes=signal.sigappsshared.SignalUtilities.recurseGetAllChildren(this.engine,members(midx));

                    if isempty(memberLeafNodes)

                        memberLeafNodes=members(midx);
                    end

                    for mleafidx=1:length(memberLeafNodes)





                        signal.sigappsshared.SignalUtilities.setMemberIndexLabeledSignalSet(this.engine,memberLeafNodes(mleafidx),midx);



                        if strcmp(tmModeLSS,'samples')
                            tmd.setTimeMetadataBySamples(memberLeafNodes(mleafidx),[],false,updateTmModeFlag,isNotifyTableFlag);

                        elseif strcmp(tmModeLSS,'fs')






                            if~isscalar(newVar.sampleTimeOrRate)
                                [f,uf]=this.getEngUnits(newVar.sampleTimeOrRate(midx),false);
                            else
                                [f,uf]=this.getEngUnits(newVar.sampleTimeOrRate,false);
                            end
                            [t,ut]=this.getEngUnits(0,true);
                            tmd.setTimeMetadataByFs(memberLeafNodes(mleafidx),f,uf,t,ut,[],false,true,updateTmModeFlag,isNotifyTableFlag);

                        elseif strcmp(tmModeLSS,'ts')


                            if~isscalar(newVar.sampleTimeOrRate)
                                [tS,utS]=this.getEngUnits(newVar.sampleTimeOrRate(midx),true);
                            else
                                [tS,utS]=this.getEngUnits(newVar.sampleTimeOrRate,true);
                            end
                            [t,ut]=this.getEngUnits(0,true);
                            tmd.setTimeMetadataByTs(memberLeafNodes(mleafidx),tS,utS,t,ut,[],false,true,updateTmModeFlag,isNotifyTableFlag);

                        elseif strcmp(tmModeLSS,'tv')


                            currentData=signal.sigappsshared.SignalUtilities.getSignalDataStructure(this.engine,memberLeafNodes(mleafidx),runID);
                            if isempty(currentData.Data)


                                this.engine.setSignalTmMode(memberLeafNodes(mleafidx),'tv',isNotifyTableFlag);
                            else
                                updateStruct.sigDataValues=currentData.Data;
                                tv=currentData.Time;


                                tmd.setTimeMetadataByTimeVector(memberLeafNodes(mleafidx),tv,'',updateStruct,updateTmModeFlag,isNotifyTableFlag);
                            end

                        elseif any(strcmp(tmModeLSS,this.INHERENTTYPES))


                            currentData=signal.sigappsshared.SignalUtilities.getSignalDataStructure(this.engine,memberLeafNodes(mleafidx),runID);
                            if~isempty(currentData.Data)
                                tmd.updateResampledSignal(memberLeafNodes(mleafidx),currentData,[],[],isNotifyTableFlag);
                            end
                        end
                    end

                end
            else


                if isa(newVar.VarValue,'timeseries')
                    allTsChildren=signal.sigappsshared.SignalUtilities.recurseGetAllChildren(this.engine,newParentSigID);
                    for tsidx=1:length(allTsChildren)
                        this.engine.setSignalTmMode(allTsChildren(tsidx),'inherentTimeseries',isNotifyTableFlag);
                    end
                end
                leafChildrenIDs=signal.analyzer.SignalUtilities.getSignalLeafChildren(this.engine,newParentSigID);
                sigIDs=[newParentSigID;leafChildrenIDs(:)];

                for i=1:length(sigIDs)

                    if(~isempty(this.NewSignalMetaData)&&strcmp(this.NewSignalMetaData.data.tmMode,'samples'))||...
                        strcmp(type,'samples')
                        tmd.setTimeMetadataBySamples(sigIDs(i),[],false,true,isNotifyTableFlag);

                    elseif(~isempty(this.NewSignalMetaData)&&strcmp(this.NewSignalMetaData.data.tmMode,'fs'))||...
                        strcmp(type,'fs')
                        [f,uf]=this.getEngUnits(this.NewSignalMetaData.data.sampleTimeOrRate,false);
                        [t,ut]=this.getEngUnits(this.NewSignalMetaData.data.startTime,true);
                        tmd.setTimeMetadataByFs(sigIDs(i),f,uf,t,ut,[],false,true,true,isNotifyTableFlag);

                    elseif(~isempty(this.NewSignalMetaData)&&strcmp(this.NewSignalMetaData.data.tmMode,'ts'))||...
                        strcmp(type,'ts')
                        [tS,utS]=this.getEngUnits(this.NewSignalMetaData.data.sampleTimeOrRate,true);
                        [t,ut]=this.getEngUnits(this.NewSignalMetaData.data.startTime,true);
                        tmd.setTimeMetadataByTs(sigIDs(i),tS,utS,t,ut,[],false,true,true,isNotifyTableFlag);

                    elseif(~isempty(this.NewSignalMetaData)&&strcmp(this.NewSignalMetaData.data.tmMode,'tv'))||...
                        strcmp(type,'tv')
                        currentData=signal.sigappsshared.SignalUtilities.getSignalDataStructure(this.engine,sigIDs(i),runID);
                        if isempty(currentData.Data)


                            this.engine.setSignalTmMode(sigIDs(i),'tv',isNotifyTableFlag);
                        else
                            updateStruct.sigDataValues=currentData.Data;
                            tv=currentData.Time;


                            tmd.setTimeMetadataByTimeVector(sigIDs(i),tv,'',updateStruct,true,isNotifyTableFlag);
                        end

                    elseif(~isempty(this.NewSignalMetaData)&&any(strcmp(this.NewSignalMetaData.data.tmMode,this.INHERENTTYPES)))...
                        ||any(strcmp(type,this.INHERENTTYPES))

                        currentData=signal.sigappsshared.SignalUtilities.getSignalDataStructure(this.engine,sigIDs(i),runID);
                        if~isempty(currentData.Data)
                            tmd.updateResampledSignal(sigIDs(i),currentData,[],[],isNotifyTableFlag);
                        end
                    elseif(~isempty(this.NewSignalMetaData)&&any(strcmp(this.NewSignalMetaData.data.tmMode,"file")))...
                        ||any(strcmp(type,"file"))


                        this.engine.setSignalTmMode(sigIDs(i),"file",isNotifyTableFlag);
                    end
                end
            end
        end


        function updateSignalMetaDataFlags(this,newParentSigID,newVar,isTimeIncludedInNewVars,leafChildrenIDs)

            if nargin<5
                leafChildrenIDs=signal.analyzer.SignalUtilities.getSignalLeafChildren(this.engine,newParentSigID);
            end

            allIDs=leafChildrenIDs;
            if isempty(allIDs)
                allIDs=newParentSigID;
            end
            if isTimeIncludedInNewVars
                signal.sigappsshared.SignalUtilities.updateIsFiniteMetaDataFlag(this.engine,allIDs,newVar.VarValue,true);
            else
                signal.sigappsshared.SignalUtilities.updateIsFiniteMetaDataFlag(this.engine,allIDs,newVar,false)
            end
        end


        function newVarNames=getNewSignalNames(this,nSigs)





            if isfinite(this.targetRunID)



                safeTransaction(this.engine,@this.getNamesOfPurelyParentSignals,this.targetRunID);
                AppVarNames=this.NamesOfPurelyParentSignals;

            else
                AppVarNames=[];
            end

            workspaceVarNames=evalin('base','who');
            checkVarNames=[workspaceVarNames;AppVarNames(:)];



            nameNumber=1;
            for i=1:length(checkVarNames)



                if strcmp(regexp(checkVarNames{i},'sig\d+','match'),checkVarNames{i})
                    nameNumber=max([nameNumber,str2double(checkVarNames{i}(4:end))+1]);
                end
            end



            newVarNames=cell(nSigs,1);
            for i=1:nSigs
                newVarNames{i}=['sig',num2str(nameNumber)];
                nameNumber=nameNumber+1;
            end
        end


        function updateResampledSignal(~,sigID,currentData)
            tmd=signal.sigappsshared.controllers.TimeMetadataDialog.getController();
            tmd.updateResampledSignal(sigID,currentData);
        end


        function flag=repeatedVarMetaChanged(this,sigIDs,newSignalMetaData)


            flag=false;
            newTmMode=newSignalMetaData.data.tmMode;

            isOldModeTimeDomain=any(strcmp(newTmMode,{'fs','ts','tv','inherent'}));

            for idx=1:length(sigIDs)
                sigID=sigIDs(idx);
                sigTmMode=getSignalTmMode(this.engine,sigID);
                isNewModeTimeDomain=any(strcmp(sigTmMode,{'fs','ts','tv','inherentTimetable','inherentTimeseries','inherentLabeledSignalSet'}));
                if isOldModeTimeDomain~=isNewModeTimeDomain
                    flag=true;
                    return;
                end
            end
        end


        function deleteSignalAndChildren(this,sigStruct)

            varID=sigStruct.ID;
            signalsToDelete=varID;
            childSigsToDelete=[];
            if sigStruct.HasChildren
                childSigsToDelete=this.getSignalsToDelete(sigStruct.ChildrenIDs,varID);
            end
            if sigStruct.HasNonLeafChildren
                childSigsToDelete=[childSigsToDelete,this.getSignalsToDelete(sigStruct.NonLeafChildrenIDs,varID)];
            end
            signalsToDelete=[signalsToDelete,childSigsToDelete];
            this.engine.deleteRunsAndSignals(signalsToDelete,'SDI');
        end


        function deleteSignals(this,sigIDs,parentID)







            signalsToDelete=getSignalsToDelete(this,sigIDs,parentID);
            this.engine.deleteRunsAndSignals(signalsToDelete,'SDI');
        end


        function signalsToDelete=getSignalsToDelete(this,sigIDs,parentID)



            parents=[];
            signalsToDelete=sigIDs;

            for idx=1:numel(sigIDs)
                parents=[parents,this.engine.getSignalParent(sigIDs(idx))];
                resampledSigID=this.engine.getSignalTmResampledSigID(sigIDs(idx));
                if(resampledSigID~=-1)
                    signalsToDelete=[signalsToDelete,resampledSigID];
                end
            end


            moreParents=[];
            for idx=1:numel(parents)
                pID=parents(idx);
                newPID=this.engine.getSignalParent(pID);
                while(newPID)
                    moreParents=[moreParents,newPID];
                    newPID=this.engine.getSignalParent(newPID);
                end
            end
            parents=[parents,moreParents];


            parents=unique(parents);
            parents(parents==0|parents==parentID)=[];
            signalsToDelete=[signalsToDelete,parents];
        end


        function removeAllAuxilarySignals(this,sigID)
            notifyTable=false;
            if~isempty(this.engine.sigRepository.getSignalSaPreprocessBackupIDs(int32(sigID)))
                notifyTable=true;
            end
            signal.sigappsshared.SignalUtilities.removeAllAuxilarySignals(this.engine,sigID);

            this.engine.setMetaDataV2(sigID,'ActionNameThatCreatedSignal','');
            if notifyTable
                notify(this.engine,'treeSignalPropertyEvent',...
                Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',...
                sigID,this.engine.getSignalTmMode(sigID),'tmMode'));
            end
        end


        function[varValues,varTimes]=extractTimeSeriesValues(this,varName,timeSeriesValue)


            varStruct=struct('VarName',varName,'VarValue',timeSeriesValue,'TimeSourceRule','siganalyzer');
            isValid=checkInherentTimeData(this,varStruct);
            if~isValid
                varValues=[];
                varTimes=[];
                return;
            end
            wksParser=Simulink.sdi.internal.import.WorkspaceParser();
            varParser=parseVariables(wksParser,varStruct);
            varParser=varParser{1};

            dataValues=getDataValues(varParser);
            varTimes=getTimeValues(varParser);
            sampleDims=getSampleDims(varParser);
            numChannels=prod(sampleDims);
            varValues=zeros(numel(varTimes),numChannels,'like',dataValues);
            for channelIdx=1:numChannels
                dimIdx=cell(size(sampleDims));
                [dimIdx{:}]=ind2sub(sampleDims,channelIdx);
                channel=cell2mat(dimIdx);
                numDims=length(channel);
                S.type='()';
                if numDims==1
                    S.subs=[':',dimIdx];
                else
                    S.subs=[dimIdx,':'];
                end
                varValues(:,channelIdx)=squeeze(subsref(dataValues,S));
            end
        end


        function[isValid,totalChannels,parserChildren]=checkInherentTimeData(this,varStruct)
            isValid=true;
            totalChannels=0;
            wksParser=Simulink.sdi.internal.import.WorkspaceParser();
            varParser=parseVariables(wksParser,varStruct);
            parserChildren=[];
            tmd=signal.sigappsshared.controllers.TimeMetadataDialog.getController();




            if isa(varStruct.VarValue,'timetable')

                if isempty(varParser)
                    isValid=false;
                    return;
                end

                if~issorted(varStruct.VarValue)
                    isValid=false;
                    return;
                end

                parserChildren=getChildren(varParser{1});
                if numel(parserChildren)==0
                    isValid=false;
                    return;
                end

                time=getTimeValues(varParser{1});
                [validNonUnifFlag,~]=tmd.validateNonUniformTimeValues(time);
                if~validNonUnifFlag
                    isValid=false;
                    return;
                end

                for chanIdx=1:numel(parserChildren)
                    totalChannels=totalChannels+size(parserChildren{chanIdx}.VariableValue,2);
                end
            elseif isa(varStruct.VarValue,'timeseries')
                if isempty(varParser)
                    isValid=false;
                    return;
                end

                if~isvarname(varStruct.VarValue.Name)
                    isValid=false;
                    return
                end

                if~isa(varStruct.VarValue.DataInfo.Interpolation,'tsdata.interpolation')||...
                    ~strcmp(varStruct.VarValue.DataInfo.Interpolation.Name,'linear')
                    isValid=false;
                    return
                end
                if~strcmp(varStruct.VarValue.TimeInfo.Units,'seconds')
                    isValid=false;
                    return
                end

                time=getTimeValues(varParser{1});
                if~allfinite(time(:))||(length(time)~=length(unique(time)))
                    isValid=false;
                    return
                end
                [validNonUnifFlag,~]=tmd.validateNonUniformTimeValues(time);
                if~validNonUnifFlag
                    isValid=false;
                    return;
                end

                data=getDataValues(varParser{1});
                if(~isnumeric(data)&&~islogical(data))||(~this.isAppSignalAnalyzer()&&~allfinite(data(:)))
                    isValid=false;
                    return
                end
                dataSize=[numel(time),prod(getSampleDims(varParser{1}))];
                totalChannels=dataSize(2);
            elseif isa(varStruct.VarValue,'labeledSignalSet')

                if isempty(varParser)
                    isValid=false;
                    return;
                end

                parserChildren=getChildren(varParser{1});
                if numel(parserChildren)==0
                    isValid=false;
                    return;
                end

                for chanIdx=1:numel(parserChildren)
                    if istimetable(parserChildren{chanIdx}.VariableValue)
                        totalChannels=totalChannels+size(parserChildren{chanIdx}.VariableValue,2);
                    elseif iscell(parserChildren{chanIdx}.VariableValue)
                        for cellIdx=1:length(parserChildren{chanIdx}.VariableValue)
                            if istimetable(parserChildren{chanIdx}.VariableValue{cellIdx})
                                totalChannels=totalChannels+size(parserChildren{chanIdx}.VariableValue{cellIdx},2);
                            else
                                totalChannels=totalChannels+size(parserChildren{chanIdx}.VariableValue{cellIdx},2)-1;
                            end
                        end
                    else
                        totalChannels=totalChannels+size(parserChildren{chanIdx}.VariableValue,2)-1;
                    end
                end
            end
        end



        function addLabeledSignalSetToSavedFile(this,newParentSigID,newVar,isLSSMatFileExists,matFileObj,isFirstSigID,isLSS,parentSigChildrenIDs,recurseAllChildrenIDs)







            if~isLSSMatFileExists



                if isLSS
                    deleteParentAndAllChildrenSignals(this,[newParentSigID;recurseAllChildrenIDs],false);
                else
                    deleteParentAndAllChildrenSignals(this,newParentSigID,true);
                end
                if(isFirstSigID)

                    msgStr=getString(message('SDI:sigAnalyzer:LSSDatabaseMissing'));
                    titleStr=getString(message('SDI:sdi:ImportError'));
                    okStr=getString(message('SDI:sdi:OKShortcut'));

                    Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                    'default',...
                    titleStr,...
                    msgStr,...
                    {okStr},...
                    0,...
                    -1,...
                    []);
                end


                return;
            end


            if isLSS
                lssKey=regexprep(tempname('_'),'_|\\|/','');
                while isprop(matFileObj,lssKey)
                    lssKey=regexprep(tempname('_'),'_|\\|/','');
                end
                allIDs=[newParentSigID;recurseAllChildrenIDs];
                for midx=1:length(allIDs)

                    signal.sigappsshared.SignalUtilities.setKeyLabeledSignalSet(this.engine,allIDs(midx),lssKey);
                end

                try
                    LWLSS=signallabelutils.internal.labeling.LightWeightLabeledSignalSet(string(parentSigChildrenIDs),newVar.VarValue);
                catch ME %#ok<NASGU>

                    deleteParentAndAllChildrenSignals(this,allIDs,false);

                    msgStr=getString(message('SDI:sigAnalyzer:UnsuportedLabelsForSignalAnalyzer'));
                    titleStr=getString(message('SDI:sdi:ImportError'));
                    okStr=getString(message('SDI:sdi:OKShortcut'));

                    Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                    'default',...
                    titleStr,...
                    msgStr,...
                    {okStr},...
                    0,...
                    -1,...
                    []);

                    return;
                end
                LWLSS.Description=newVar.VarValue.Description;
                matFileObj.(lssKey)=LWLSS;
            end
        end

        function deleteParentAndAllChildrenSignals(this,sigIDOrAllIDs,isGetAllChildren)





            allIDs=sigIDOrAllIDs;
            if isGetAllChildren
                allIDs=[allIDs;signal.sigappsshared.SignalUtilities.recurseGetAllChildren(this.engine,sigIDOrAllIDs)];
            end
            for c_idx=1:length(allIDs)
                deleteSignal(this.engine,allIDs(c_idx))
            end
        end

        function removeLabeledSignalSetFromSavedFile(this,sigID)




            matname=signal.sigappsshared.SignalUtilities.getStorageLSSFilename();
            if exist(matname,'file')==2
                m=matfile(matname,'Writable',true);
                lssKey=signal.sigappsshared.SignalUtilities.getKeyLabeledSignalSet(this.engine,sigID);
                if~isempty(lssKey)
                    m.(lssKey)=NaN;
                end
            end
        end

        function flag=isAppSignalAnalyzer(this)
            flag=this.AppName=="SignalAnalyzer";
        end
    end
end



function choice=warnIfFat(varname)
    prefs=getpref('dontshowmeagain');
    if~isfield(prefs,'signalAnalyzerFatMatrix')||~prefs.signalAnalyzerFatMatrix
        str1=getString(message('SDI:sigAnalyzer:sigAnalyzerDlgStr1',varname));
        str2=getString(message('SDI:sigAnalyzer:sigAnalyzerDlgStr2',varname));
        str3=getString(message('SDI:sigAnalyzer:sigAnalyzerDlgStr3'));

        choice=lower(sigAnalyzerDlg({str1,str2,str3},getString(message('SDI:sigAnalyzer:AlwaysImport'))));

        if strcmp(choice,'check')
            choice='yes';
            setpref('dontshowmeagain','signalAnalyzerFatMatrix',true);
        end
    else
        choice='yes';
    end
end

function choice=sigAnalyzerDlg(dlgstrs,dlgcontrolstrs)




    fileNameMode=(length(dlgstrs(:))==5);
    dlg=signal.internal.dontshowassistantdlg;
    dlg.render;
    dlg.setDialogStrings(dlgstrs,fileNameMode)
    dlg.setUicontrolStrings(dlgcontrolstrs)
    set(dlg.Figure,'Visible','on');
    set(dlg.Figure,'Name',getString(message('SDI:sigAnalyzer:ToolName')));
    waitfor(dlg.Figure)
    choice=dlg.DlgChoice;

    hApp=signal.analyzer.Instance.getMainGUI;
    hApp.bringToFront;
end
