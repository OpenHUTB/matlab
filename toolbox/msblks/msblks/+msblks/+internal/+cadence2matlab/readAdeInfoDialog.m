classdef readAdeInfoDialog




    properties
Model
DataFig
fig
tree
treeRootInteractive
treeRootOcean
okButton
cancelButton
metricsOnlyCheckbox
    end

    properties(Constant,Hidden)
        runCount=100;
    end

    methods

        function obj=readAdeInfoDialog(model,parentDataFig,dataDB)
            obj.Model=model;
            obj.DataFig=parentDataFig;
            try
                cadence.AdeInfoManager.getInstance();
                adeInfo=evalin('base','adeInfo.loadResult');



                [rdb1,dbTables1]=obj.getAdeInfoStructs('Interactive',cadence.AdeInfoManager.loadResult.adeCurrentResultsPath);

                [rdb2,dbTables2]=obj.getAdeInfoStructs('Ocean',cadence.AdeInfoManager.loadResult.adeCurrentResultsPath);


            catch ex
                if strcmpi(ex.identifier,'MATLAB:undefinedVarOrClass')
                    uialert(obj.DataFig,'Cadence API utilities/tools not available.',ex.identifier);
                else
                    uialert(obj.DataFig,ex.message,ex.identifier);
                end
                return;
            end
            if isempty(dataDB)
                obj.createGUI(rdb1,dbTables1,rdb2,dbTables2);
            else
                obj.createUpdateGUI(rdb1,dbTables1,rdb2,dbTables2,dataDB);
            end
        end
    end

    methods(Access=private)

        function initAdeInfo(obj)

            import cadence.srrdata.*
            import cadence.Query.*
            import cadence.utils.*
            import cadence.simdata.*
            import cadence.srrsata.*
            import cadence.streamCalculator.*
            import cadence.utils.cdsPlot.*





            s1='Interactive';
            s2=5;


            cadence.AdeInfoManager.loadResult();
            adeInfo=cadence.AdeInfoManager.getInstance();


            if adeInfo.adeDataPoint==-1
                adeInfo.loadResult();
                cadence.AdeInfoManager.loadResult();
                cadence.AdeInfoManager.loadResult('history',[s1,'.',s2]);
                adeInfo.loadResult('test',s3,'DataPoint',1);
            end
        end



        function[rdb,dbTables]=getAdeInfoStructs(obj,runType,adeResultPath)

            import cadence.srrdata.*
            import cadence.Query.*
            import cadence.utils.*
            import cadence.simdata.*
            import cadence.srrsata.*
            import cadence.streamCalculator.*
            import cadence.utils.cdsPlot.*






            pathSplit=split(adeResultPath,'psf');
            pathParts=split(pathSplit{1},'/');




            listDir=dir(fullfile('/',pathParts{1:end-2}));

            simCnt=1;

            rdb=[];
            dbTables=[];

            for i=1:length(listDir)
                if(~startsWith(listDir(i).name,'.'))
                    try

                        historyName=listDir(i).name;
                        [~,rdbTemp]=evalc("cadence.AdeInfoManager.loadResult('history',historyName).adeRDB;");
                        if(strcmp(rdbTemp.history,historyName))
                            rdb.no{simCnt}=rdbTemp;
                            dbTables.no{simCnt}=rdb.no{simCnt}.query();
                        end


                    catch ex
                        if strcmpi(ex.identifier,'MATLAB:undefinedVarOrClass')
                            rethrow(ex);
                        end
                        continue;
                    end
                    if(strcmp(rdbTemp.history,historyName))
                        if simCnt>1&&strcmp(rdb.no{simCnt}.history,rdb.no{simCnt-1}.history)||...
                            strcmp(runType,'Ocean')


                            rdb.no(simCnt)=[];
                            dbTables.no(simCnt)=[];
                            break;
                        end


                        if isempty(dbTables.no{simCnt})

                            rdb.no(simCnt)=[];
                            dbTables.no(simCnt)=[];
                        else

                            simCnt=simCnt+1;
                        end
                    end

                end

            end
        end


        function createGUI(obj,rdb1,dbTables1,rdb2,dbTables2)

            obj.fig=uifigure();
            if~isempty(rdb1)&&~isempty(rdb1.no)
                obj.fig.Name=['Open AdeInfo - ',rdb1.no{1}.session];
            elseif~isempty(rdb2)&&~isempty(rdb2.no)
                obj.fig.Name=['Open AdeInfo - ',rdb2.no{1}.session];
            else
                obj.fig.Name='Open AdeInfo';
            end
            figLayout=uigridlayout(...
            'Parent',obj.fig,...
            'RowHeight',{'1x',20},...
            'ColumnWidth',{'1x',60,60},...
            'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'Scrollable','on');
            obj.tree=uitree(figLayout,'checkbox','Tag','tree');
            obj.okButton=uibutton(...
            'Parent',figLayout,...
            'Tag','okButton',...
            'Text',getString(message('msblks:mixedsignalanalyzer:OkText')));
            obj.cancelButton=uibutton(...
            'Parent',figLayout,...
            'Tag','cancelButton',...
            'Text',getString(message('msblks:mixedsignalanalyzer:CancelText')));
            obj.metricsOnlyCheckbox=uicheckbox(...
            'Parent',figLayout,...
            'Tag','metricsOnlyCheckbox',...
            'Text',getString(message('msblks:mixedsignalanalyzer:MetricsOnlyText')),...
            'Value',1);


            obj.tree.Layout.Row=1;
            obj.metricsOnlyCheckbox.Layout.Row=2;
            obj.okButton.Layout.Row=2;
            obj.cancelButton.Layout.Row=2;
            obj.tree.Layout.Column=[1,3];
            obj.metricsOnlyCheckbox.Layout.Column=1;
            obj.okButton.Layout.Column=2;
            obj.cancelButton.Layout.Column=3;


            obj.treeRootInteractive=uitreenode(obj.tree,'Text','Interactive');
            obj.treeRootOcean=uitreenode(obj.tree,'Text','Ocean');


            for i=1:length(rdb1.no)
                tests=obj.getUniqueTests(dbTables1.no{i});
                text=[rdb1.no{i}.history...
                ,' (',num2str(size(rdb1.no{i}.corners,1)),' corners, '...
                ,num2str(size(rdb1.no{i}.params,1)),' params, ',...
                num2str(length(tests)),' test'];
                if length(tests)~=1
                    text=[text,'s'];%#ok<AGROW>
                end
                text=[text,')'];%#ok<AGROW>
                node=uitreenode(obj.treeRootInteractive,'Text',text);
                for j=1:length(tests)
                    uitreenode(node,'Text',tests{j},'UserData',{rdb1.no{i}.history,tests{j}});
                end
            end


            for i=1:length(rdb2.no)
                tests=obj.getUniqueTests(dbTables2.no{i});
                text=[rdb2.no{i}.history...
                ,' (',num2str(size(rdb2.no{i}.corners,1)),' corners, '...
                ,num2str(size(rdb2.no{i}.params,1)),' params, ',...
                num2str(length(tests)),' test'];
                if length(tests)~=1
                    text=[text,'s'];%#ok<AGROW>
                end
                text=[text,')'];%#ok<AGROW>
                node=uitreenode(obj.treeRootOcean,'Text',text,'UserData',[rdb2.no{i}.history]);
                for j=1:length(tests)
                    uitreenode(node,'Text',tests{j},'UserData',{rdb2.no{i}.history,tests{j}});
                end
            end


            collapse(obj.tree);
            expand(obj.tree);



            obj.okButton.ButtonPushedFcn=@obj.applyAndDeleteDialog;
            obj.cancelButton.ButtonPushedFcn=@obj.deleteDialog;
        end
        function createUpdateGUI(obj,rdb1,dbTables1,rdb2,dbTables2,dataDB)
            if isempty(dataDB)
                return;
            end

            obj.fig=uifigure(...
            'Tag','UpdateDialog',...
            'Name',getString(message('msblks:mixedsignalanalyzer:FileBtn_Update')));
            figLayout=uigridlayout(...
            'Parent',obj.fig,...
            'RowHeight',{'1x',20},...
            'ColumnWidth',{'1x',60,60},...
            'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'Scrollable','on');
            mainPanel=uipanel('Parent',figLayout,'Scrollable','on');
            obj.okButton=uibutton(...
            'Parent',figLayout,...
            'Tag','okButton',...
            'Text',getString(message('msblks:mixedsignalanalyzer:RefreshText')));
            obj.cancelButton=uibutton(...
            'Parent',figLayout,...
            'Tag','cancelButton',...
            'Text',getString(message('msblks:mixedsignalanalyzer:CancelText')));
            obj.metricsOnlyCheckbox=uicheckbox(...
            'Parent',figLayout,...
            'Tag','metricsOnlyCheckbox',...
            'Text',getString(message('msblks:mixedsignalanalyzer:MetricsOnlyText')),...
            'Value',1);


            mainPanel.Layout.Row=1;
            obj.metricsOnlyCheckbox.Layout.Row=2;
            obj.okButton.Layout.Row=2;
            obj.cancelButton.Layout.Row=2;
            mainPanel.Layout.Column=[1,3];
            obj.metricsOnlyCheckbox.Layout.Column=1;
            obj.okButton.Layout.Column=2;
            obj.cancelButton.Layout.Column=3;


            count=0;
            count=count+1;
            count=count+1;
            symRunsAndTestsCount=0;
            for i=1:length(dataDB)
                treeDatabaseName=removeTrailingMarkerGDB(dataDB(i).matFileName);
                count=count+1;
                for j=1:length(dataDB(i).SimulationResultsNames)
                    treeSimulationName=dataDB(i).SimulationResultsNames{j};
                    count=count+1;
                    count=count+1;
                    for k=1:length(rdb1.no)
                        updateSimulationName=rdb1.no{k}.history;
                        tests=obj.getUniqueTests(dbTables1.no{k});
                        for m=1:length(tests)
                            if i==1&&j==1
                                symRunsAndTestsCount=symRunsAndTestsCount+1;
                            end
                            updateSimulationNameFull=[updateSimulationName,', ',tests{m}];
                            if~strcmp(treeDatabaseName,'adeInfo')||~strcmp(treeSimulationName,updateSimulationNameFull)
                                count=count+1;
                            end
                        end
                    end
                    count=count+1;
                    for k=1:length(rdb2.no)
                        updateSimulationName=rdb2.no{k}.history;
                        tests=obj.getUniqueTests(dbTables2.no{k});
                        for m=1:length(tests)
                            if i==1&&j==1
                                symRunsAndTestsCount=symRunsAndTestsCount+1;
                            end
                            updateSimulationNameFull=[updateSimulationName,', ',tests{m}];
                            if~strcmp(treeDatabaseName,'adeInfo')||~strcmp(treeSimulationName,updateSimulationNameFull)
                                count=count+1;
                            end
                        end
                    end
                end
            end
            count=max(count,18);


            buttonGroups=[];

            folderIcon_16=[fullfile('+msblks','+internal','+apps','+mixedsignalanalyzer'),filesep,'folder_16.png'];
            indent0=25;
            indent1=30;
            indent2=55;
            indent3=75;
            height=20;
            width=450;
            allButtonGroups={};
            uilabel('Parent',mainPanel,'Position',[5,count*height,width,height],'Text',getString(message('msblks:mixedsignalanalyzer:ReplaceWithText')));
            count=count-1;
            uilabel('Parent',mainPanel,'Position',[5,count*height,width,height],'Text','');
            count=count-1;
            symRunsAndTestsRequest{symRunsAndTestsCount}=[];
            symRunsAndTestsCount=0;
            for i=1:length(dataDB)
                uiimage('Parent',mainPanel,'Position',[5,count*height,16,16],'imagesource',folderIcon_16);
                treeDatabaseName=dataDB(i).matFileName;
                uilabel('Parent',mainPanel,'Position',[indent0,count*height,width,height],'Text',treeDatabaseName);
                treeDatabaseName=removeTrailingMarkerGDB(treeDatabaseName);
                count=count-1;
                for j=1:length(dataDB(i).SimulationResultsNames)
                    treeSimulationName=dataDB(i).SimulationResultsNames{j};
                    checkbox=uicheckbox('Parent',mainPanel,'Position',[indent1,count*height,width,height],'Text',treeSimulationName,'Value',0);
                    existingCornerTablePanelIndex=obj.Model.View.getExistingCornerTablePanelIndex(i,treeSimulationName);
                    count=count-1;

                    uiimage('Parent',mainPanel,'Position',[indent2,count*height,16,16],'imagesource',folderIcon_16);
                    uilabel('Parent',mainPanel,'Position',[indent2+20,height*count,width,height],'Text','adeInfo - Interactive');
                    resultsTotal=length(rdb1.no)+length(rdb2.no);
                    buttonGroup=uibuttongroup('Parent',mainPanel,'Position',[indent3,height*(count-resultsTotal),width,height*resultsTotal],'BorderType','none');
                    buttonGroups{1}=buttonGroup;
                    count=count-1;
                    uiradiobutton('Parent',buttonGroup,'Text','N/A','Visible','off');
                    offset=resultsTotal;
                    for k=1:length(rdb1.no)
                        updateSimulationName=rdb1.no{k}.history;
                        tests=obj.getUniqueTests(dbTables1.no{k});
                        for m=1:length(tests)
                            if i==1&&j==1
                                symRunsAndTestsCount=symRunsAndTestsCount+1;
                                symRunsAndTestsRequest{symRunsAndTestsCount}={updateSimulationName,tests{m}};
                            end
                            updateSimulationNameFull=[updateSimulationName,', ',tests{m}];
                            if~strcmp(treeDatabaseName,'adeInfo')||~strcmp(treeSimulationName,updateSimulationNameFull)

                                radioButton=uiradiobutton('Parent',buttonGroup,'Position',[5,height*(offset-k),width,height],'Text',updateSimulationNameFull);
                                count=count-1;
                                radioButton.UserData={i,j,1,k,existingCornerTablePanelIndex};
                            else
                                offset=offset+1;
                            end
                        end
                    end
                    uiimage('Parent',mainPanel,'Position',[indent2,count*height,16,16],'imagesource',folderIcon_16);
                    uilabel('Parent',mainPanel,'Position',[indent2+20,height*count,width,height],'Text','adeInfo - Ocean');
                    count=count-1;
                    for k=1:length(rdb2.no)
                        updateSimulationName=rdb2.no{k}.history;
                        tests=obj.getUniqueTests(dbTables2.no{k});
                        for m=1:length(tests)
                            if i==1&&j==1
                                symRunsAndTestsCount=symRunsAndTestsCount+1;
                                symRunsAndTestsRequest{symRunsAndTestsCount}={updateSimulationName,tests{m}};
                            end
                            updateSimulationNameFull=[updateSimulationName,', ',tests{m}];
                            if~strcmp(treeDatabaseName,'adeInfo')||~strcmp(treeSimulationName,updateSimulationNameFull)

                                radioButton=uiradiobutton('Parent',buttonGroup,'Position',[5,height*(offset-k),width,height],'Text',updateSimulationNameFull);
                                count=count-1;
                                radioButton.UserData={i,j,2,k,existingCornerTablePanelIndex};
                            else
                                offset=offset+1;
                            end
                        end
                    end
                    checkbox.ValueChangedFcn=@(h,e)enableButtons(buttonGroups,checkbox);
                    initButtonsAndCheckbox(buttonGroups,checkbox);
                    allButtonGroups{end+1}=buttonGroups;%#ok<AGROW>
                end
            end


            obj.okButton.ButtonPushedFcn=@(h,e)obj.applyAndDeleteUpdateDialog(symRunsAndTestsRequest,allButtonGroups);
            obj.cancelButton.ButtonPushedFcn=@obj.deleteDialog;
        end
        function tests=getUniqueTests(obj,dbTable)
            tests={};
            for i=1:length(dbTable.Test)
                if~any(strcmp(tests,dbTable.Test{i}))
                    tests{end+1}=dbTable.Test{i};%#ok<AGROW>
                end
            end
        end


        function deleteDialog(obj,src,event)
            if~isempty(obj.fig)&&isvalid(obj.fig)
                close(obj.fig);
            end
        end
        function applyAndDeleteDialog(obj,src,event)
            symRunsAndTestsRequest=obj.getCheckedSymRunsAndTests();
            isMetricsOnly=obj.metricsOnlyCheckbox.Value;
            obj.deleteDialog(src,event);
            try
                obj.Model.View.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyExtractingCadenceData')));
                ade=evalin('base','adeInfo');
                a=msblks.internal.cadence2matlab.adeInfoDataAccess(ade);
                [dbTables,...
                signalTables,...
                exprTables,...
                totalCorners,...
                wfResults,...
                wfCorners,...
                wfOutput,...
                History,...
                scScalarInfo,...
                scScalarOut,...
                scCorners,...
                waveformDB,...
                simDBS,...
                simDBC,...
                paramTable,...
paramConditionTable...
                ]=a.extractAllAdeInfoHistory(symRunsAndTestsRequest,isMetricsOnly);





                matfile='adeInfo';

                pathname.dbTables=dbTables;
                pathname.signalTables=signalTables;
                pathname.exprTables=exprTables;
                pathname.totalCorners=totalCorners;
                pathname.wfResults=wfResults;
                pathname.wfCorners=wfCorners;
                pathname.wfOutput=wfOutput;
                pathname.History=History;
                pathname.scScalarInfo=scScalarInfo;
                pathname.scScalarOut=scScalarOut;
                pathname.scCorners=scCorners;
                pathname.waveformDB=waveformDB;
                pathname.simDBS=simDBS;
                pathname.simDBC=simDBC;
                pathname.paramTable=paramTable;
                pathname.paramConditionTable=paramConditionTable;
                obj.Model.readCadenceData(matfile,pathname,[]);
            catch ex
                obj.Model.View.MixedSignalAnalyzerTool.setStatus('');
                if strcmpi(ex.identifier,'MATLAB:undefinedVarOrClass')
                    uialert(obj.DataFig,'Cadence API utilities/tools not available.',ex.identifier);
                else
                    uialert(obj.DataFig,ex.message,ex.identifier);
                end
            end
            obj.Model.View.MixedSignalAnalyzerTool.setStatus('');
        end
        function checkedSymRunsAndTests=getCheckedSymRunsAndTests(obj)
            checkedSymRunsAndTests={};
            checkedNodes=obj.tree.CheckedNodes;
            for i=1:length(checkedNodes)
                if~isempty(checkedNodes(i).UserData)
                    checkedSymRunsAndTests{end+1}=checkedNodes(i).UserData;%#ok<AGROW>
                end
            end
        end
        function applyAndDeleteUpdateDialog(obj,symRunsAndTestsRequest,allButtonGroups)
            try
                obj.Model.View.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyUpdatingSource')));

                requests={};
                symRunsAndTestsRequest={};
                for i=1:length(allButtonGroups)
                    buttonGroups=allButtonGroups{i};
                    for j=1:length(buttonGroups)
                        buttonGroup=buttonGroups{j};
                        temp=split(buttonGroup.SelectedObject.Text,', ')';
                        symRunsAndTestsRequest{end+1}=temp;
                        for k=1:length(buttonGroup.Buttons)
                            button=buttonGroup.Buttons(k);
                            if button.Enable&&...
                                button.Visible&&...
                                button.Value&&...
                                ~isempty(button.UserData)
                                requests{end+1}=button.UserData;%#ok<AGROW>
                            end
                        end
                    end
                end
                isMetricsOnly=obj.metricsOnlyCheckbox.Value;
                obj.deleteDialog;
                if~isempty(requests)
                    obj.Model.View.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyExtractingCadenceData')));
                    ade=evalin('base','adeInfo');
                    a=msblks.internal.cadence2matlab.adeInfoDataAccess(ade);

                    [pathname.dbTables,...
                    pathname.signalTables,...
                    pathname.exprTables,...
                    pathname.totalCorners,...
                    pathname.wfResults,...
                    pathname.wfCorners,...
                    pathname.wfOutput,...
                    pathname.History,...
                    pathname.scScalarInfo,...
                    pathname.scScalarOut,...
                    pathname.scCorners,...
                    pathname.waveformDB,...
                    pathname.simDBS,...
                    pathname.simDBC,...
                    pathname.paramTable,...
                    pathname.paramConditionTable...
                    ]=a.extractAllAdeInfoHistory(symRunsAndTestsRequest,isMetricsOnly);


                    matfile='adeInfo';

                    obj.Model.readCadenceData(matfile,pathname,requests);
                end
            catch ex
                obj.Model.View.MixedSignalAnalyzerTool.setStatus('');
                if strcmpi(ex.identifier,'MATLAB:undefinedVarOrClass')
                    uialert(obj.Model.View.DataFig,'Cadence API utilities/tools not available.',ex.identifier);
                else
                    uialert(obj.Model.View.DataFig,ex.message,ex.identifier);
                end
            end
            obj.Model.View.MixedSignalAnalyzerTool.setStatus('');
            if~isempty(obj.fig)
                obj.deleteDialog;
            end
        end

        function tests=getRequestedTests(obj,symRunsAndTests)
            tests={};
            for i=1:length(symRunsAndTests)
                if iscell(symRunsAndTests{i})&&~any(strcmpi(tests,symRunsAndTests{i}{2}))
                    tests{end+1}=symRunsAndTests{i}{2};%#ok<AGROW>
                end
            end
        end

        function isRequested=isRequestedSimRunAndTest(obj,symRun,test,symRunsAndTests)
            isRequested=false;
            for i=1:length(symRunsAndTests)
                if iscell(symRunsAndTests{i})&&...
                    strcmpi(symRunsAndTests{i}{1},symRun)&&...
                    strcmpi(symRunsAndTests{i}{2},test)
                    isRequested=true;
                    return;
                end
            end
        end

    end
end


function initButtonsAndCheckbox(buttonGroups,checkbox)
    if length(buttonGroups{1}.Buttons)>1
        buttonGroups{1}.Buttons(2).Value=1;
    end
    for i=1:length(buttonGroups)
        for j=1:length(buttonGroups{i}.Buttons)

            buttonGroups{i}.Buttons(j).Enable=0;
        end
    end
    checkbox.Value=0;
end
function enableButtons(buttonGroups,checkbox)
    for i=1:length(buttonGroups)
        for j=1:length(buttonGroups{i}.Buttons)

            buttonGroups{i}.Buttons(j).Enable=checkbox.Value;
        end
    end
end
function databaseName=removeTrailingMarkerGDB(databaseName)
    index=strfind(databaseName,' (GDB)');
    if~isempty(index)
        databaseName=extractBefore(databaseName,index(1));
        databaseName=strtrim(databaseName);
    end
end

