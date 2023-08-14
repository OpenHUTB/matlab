classdef SignalAndParameterTableSelector<matlab.apps.AppBase






    properties(Access=public)
        UIFigure matlab.ui.Figure
        GridMain matlab.ui.container.GridLayout
        Tree matlab.ui.container.Tree
        Add matlab.ui.control.Button
        Remove matlab.ui.control.Button
        SelectionTable matlab.ui.control.Table
        AddFromModel matlab.ui.control.Button
        HighlightTable matlab.ui.control.StateButton
        Image matlab.ui.control.Image
        Search matlab.ui.control.EditField
        Delete matlab.ui.control.Button
    end

    properties(Access=private)
SLRTApp

Table
IsSignalTable
TableProp

CachedTableBackgroundColor

ProgressDialog
    end

    properties(Access=private,Constant)
        Error_msg=getString(message('slrealtime:appdesigner:Error'))
        SignalTableSel_msg=getString(message('slrealtime:appdesigner:SignalTableSelector'))
        ParameterTableSel_msg=getString(message('slrealtime:appdesigner:ParameterTableSelector'))
        Signal_msg=getString(message('slrealtime:appdesigner:SigsSignal'))
        BlockPath_msg=getString(message('slrealtime:appdesigner:ParamsPath'))
        Parameter_msg=getString(message('slrealtime:appdesigner:ParamsName'))
        HighlightTable_msg=getString(message('slrealtime:appdesigner:TableSelectorHighlight'))
        BindMode_msg=getString(message('slrealtime:appdesigner:BindMode'))
        SelectBindings_msg=getString(message('slrealtime:appdesigner:SelectBindings'))
        AddFromModel_msg=strrep(getString(message('slrealtime:appdesigner:AddFromModel')),newline,' ')
        UpdatingTitle_msg=getString(message('slrealtime:appdesigner:UpdatingTableTitle'));
        UpdatingMessage_msg=getString(message('slrealtime:appdesigner:UpdatingTableMessage'));
    end

    events


Closing
    end





    methods(Static,Access=private)




        function signalData=formatSignalForList(blockPath,portIndex)
            if portIndex==-1

                signalData={blockPath};
            else

                signalData={[slrealtime.internal.SLRTComponent.blockPathToDisplay(blockPath),':',num2str(portIndex)]};
            end
        end
        function[blockPath,portIndex]=parseSignalFromList(signal)
            tokens=split(signal,':');
            if numel(tokens)>1
                blockPath=join(tokens(1:end-1),':');
                portIndex=str2double(tokens{end});
            else
                blockPath=tokens{1};
                portIndex=-1;
            end
        end






        function parameterData=formatParameterForList(blockPath,paramName)
            parameterData={slrealtime.internal.SLRTComponent.blockPathToDisplay(blockPath),paramName};
        end




        function signalStr=formatSignalForDisplay(blockPath,portIndex)
            args=slrealtime.internal.SignalAndParameterTableSelector.formatSignalForList(blockPath,portIndex);
            signalStr=args{1};
        end




        function parameterStr=formatParameterForDisplay(blockPath,paramName)
            args=slrealtime.internal.SignalAndParameterTableSelector.formatParameterForList(blockPath,paramName);
            parameterStr=[args{1},':',args{2}];
        end
    end

    methods(Access=private)
        function slrtApp=getLoadedSLRTApplicationFromTarget(app,tg)
            slrtApp=[];

            if~isempty(tg)&&isa(tg,'slrealtime.Target')



                try
                    [~,loadedApp]=tg.isLoaded();
                    if~isempty(loadedApp)
                        appFile=tg.getApplicationFile(loadedApp);
                        slrtApp=slrealtime.Application(appFile);
                    end
                catch
                    slrtApp=[];
                end
                if isempty(slrtApp)



                    msg=getString(message("slrealtime:appdesigner:TableSelectorNoAppLoaded",tg.TargetSettings.name));
                    uialert(app.UIFigure,msg,app.Error_msg,'CloseFcn',@(o,e)delete(app));
                    return;
                end
            else



                msg=getString(message("slrealtime:appdesigner:TableSelectorInvalidTarget",tg.TargetSettings.name));
                uialert(app.UIFigure,msg,app.Error_msg,'CloseFcn',@(o,e)delete(app));
                return;
            end
        end

        function syncSelectionTableWithTableComponent(app)






            nEls=numel(app.Table.(app.TableProp));
            if app.IsSignalTable
                data=cell(nEls,1);
            else
                data=cell(nEls,2);
            end


            for nEl=1:nEls
                blockPath=app.Table.(app.TableProp)(nEl).BlockPath;
                if app.IsSignalTable
                    data(nEl,:)=app.formatSignalForList(blockPath,app.Table.(app.TableProp)(nEl).PortIndex);
                else
                    data(nEl,:)=app.formatParameterForList(blockPath,app.Table.(app.TableProp)(nEl).ParameterName);
                end
            end
            app.SelectionTable.Data=data;
        end

        function startupFcn(app,tg,table,sourceFile)



            app.Image.ImageSource=fullfile(matlabroot,'toolbox','slrealtime','slrealtime','+slrealtime','+icons','Search_16.png');
            app.Delete.Icon=fullfile(matlabroot,'toolbox','slrealtime','slrealtime','+slrealtime','+icons','remove_16.png');
            app.Add.Icon=fullfile(matlabroot,'toolbox','slrealtime','slrealtime','+slrealtime','+icons','add_row_16.gif');
            app.Remove.Icon=fullfile(matlabroot,'toolbox','slrealtime','slrealtime','+slrealtime','+icons','remove_row_16.png');
            app.AddFromModel.Icon=fullfile(matlabroot,'toolbox','slrealtime','slrealtime','+slrealtime','+icons','mdlFile_24.png');
            app.HighlightTable.Icon=fullfile(matlabroot,'toolbox','slrealtime','slrealtime','+slrealtime','+icons','highlight_table_24.png');



            app.Table=table;
            app.IsSignalTable=isa(app.Table,'slrealtime.ui.control.SignalTable');
            if app.IsSignalTable
                app.TableProp='Signals';
                app.UIFigure.Name=app.SignalTableSel_msg;



                app.SelectionTable.ColumnName={app.Signal_msg};
                app.SelectionTable.RowName={};
                app.SelectionTable.ColumnSortable=false;
                app.SelectionTable.ColumnEditable=false;
                app.SelectionTable.ColumnWidth={'auto'};
            else
                app.TableProp='Parameters';
                app.UIFigure.Name=app.ParameterTableSel_msg;





                app.SelectionTable.ColumnName={app.BlockPath_msg,app.Parameter_msg};
                app.SelectionTable.RowName={};
                app.SelectionTable.ColumnSortable=[false,false];
                app.SelectionTable.ColumnEditable=[false,true];
                app.SelectionTable.ColumnWidth={'auto'};
            end



            if~isempty(sourceFile)

                try
                    app.SLRTApp=slrealtime.Application(sourceFile);
                catch ME
                    uialert(app.UIFigure,ME.message,app.Error_msg);
                    return;
                end
            else

                app.SLRTApp=app.getLoadedSLRTApplicationFromTarget(tg);
            end
            if isempty(app.SLRTApp),return;end



            slrealtime.internal.ApplicationTree.populate(app.Tree,app.SLRTApp,'Signals',app.IsSignalTable,'Parameters',~app.IsSignalTable);
            app.TreeSelectionChanged([]);




            app.syncSelectionTableWithTableComponent();
            app.SelectionTableChangedCB([]);
        end

        function UIFigureCloseRequest(app,event)%#ok

            if~isempty(app.CachedTableBackgroundColor)
                app.Table.TableBackgroundColor=app.CachedTableBackgroundColor;
            end


            notify(app,'Closing');


            delete(app);
        end

        function AddSignalToTableComponent(app,blockPath,portIndex)
            sigStruct=struct('BlockPath',{blockPath},'PortIndex',{portIndex});
            try
                if isempty(app.Table.(app.TableProp))
                    app.Table.(app.TableProp)=sigStruct;
                else
                    app.Table.(app.TableProp)(end+1)=sigStruct;
                end
            catch ME
                msg=getString(message('slrealtime:appdesigner:TableSelectorErrorAddingEntry',app.formatSignalForDisplay(blockPath,portIndex),ME.message));
                uialert(app.UIFigure,msg,app.Error_msg);
                return;
            end
        end

        function AddParameterToTableComponent(app,blockPath,paramName)
            paramStruct=struct('BlockPath',{blockPath},'ParameterName',{paramName});
            try
                if isempty(app.Table.(app.TableProp))
                    app.Table.(app.TableProp)=paramStruct;
                else
                    app.Table.(app.TableProp)(end+1)=paramStruct;
                end
            catch ME
                msg=getString(message('slrealtime:appdesigner:TableSelectorErrorAddingEntry',app.formatParameterForDisplay(blockPath,paramName),ME.message));
                uialert(app.UIFigure,msg,app.Error_msg);
                return;
            end
        end

        function AddButtonPushed(app,event)%#ok



            app.ProgressDialog=uiprogressdlg(...
            app.UIFigure,...
            'Indeterminate','on',...
            'Message',app.UpdatingMessage_msg,...
            'Title',app.UpdatingTitle_msg);
            c=onCleanup(@()delete(app.ProgressDialog));



            for i=1:numel(app.Tree.SelectedNodes)



                node=app.Tree.SelectedNodes(i);
                if isempty(node)||isempty(node.NodeData)||...
                    isfield(node.NodeData,'path')
                    continue;
                end

                if app.IsSignalTable



                    if isempty(node.NodeData.SignalLabel)
                        blockPath=node.NodeData.BlockPath;
                        portIndex=node.NodeData.PortIndex;
                    else
                        blockPath=node.NodeData.SignalLabel;
                        portIndex=-1;
                    end

                    app.AddSignalToTableComponent(blockPath,portIndex);
                else



                    blockPath=node.NodeData.BlockPath;
                    paramName=node.NodeData.BlockParameterName;

                    app.AddParameterToTableComponent(blockPath,paramName);
                end
            end

            app.syncSelectionTableWithTableComponent();
        end

        function RemoveButtonPushed(app,event)%#ok



            app.ProgressDialog=uiprogressdlg(...
            app.UIFigure,...
            'Indeterminate','on',...
            'Message',app.UpdatingMessage_msg,...
            'Title',app.UpdatingTitle_msg);
            c=onCleanup(@()delete(app.ProgressDialog));

            [numElements,~]=size(app.SelectionTable.Data);
            idxsToKeep=setdiff(1:numElements,app.SelectionTable.Selection);
            app.Table.(app.TableProp)=app.Table.(app.TableProp)(idxsToKeep);
            app.syncSelectionTableWithTableComponent();
            app.SelectionTableChangedCB([]);
        end

        function AddFromModelPushed(app,event)%#ok

            model=app.SLRTApp.ModelName;





            app.ProgressDialog=uiprogressdlg(...
            app.UIFigure,...
            'Indeterminate','on',...
            'Message',getString(message('slrealtime:appdesigner:OpeningModel',model)),...
            'Title',app.BindMode_msg);



            try
                open_system(model);
            catch ME
                delete(app.ProgressDialog);
                uialert(app.UIFigure,getString(message('slrealtime:appdesigner:OpenModelError',ME.message)),app.Error_msg);
                return;
            end




            app.ProgressDialog.Message=app.SelectBindings_msg;



            if app.IsSignalTable
                mode=slrealtime.internal.SLRTBindModeSourceData.SIGNALS;
            else
                mode=slrealtime.internal.SLRTBindModeSourceData.PARAMETERS;
            end
            bindObj=slrealtime.internal.SLRTBindModeSourceData(...
            model,...
            mode,...
            @(d)bindModeFinishedCB(app,d));
            BindMode.BindMode.enableBindMode(bindObj);
        end

        function HighlightTableValueChanged(app,event)%#ok
            if app.HighlightTable.Value
                app.CachedTableBackgroundColor=app.Table.TableBackgroundColor;
                app.Table.TableBackgroundColor=[1,1,0;1,1,0];
            else
                app.Table.TableBackgroundColor=app.CachedTableBackgroundColor;
            end
        end

        function SelectionTableChangedCB(app,event)%#ok
            app.Remove.Enable=~isempty(app.SelectionTable.Selection);
        end

        function SelectionTableCellCB(app,event)
            c=onCleanup(@()app.syncSelectionTableWithTableComponent());
            try
                app.Table.(app.TableProp)(event.Indices(1)).ParameterName=event.NewData;
            catch ME
                msg=getString(message('slrealtime:appdesigner:TableSelectorErrorModifyingEntry',event.NewData,ME.message));
                uialert(app.UIFigure,msg,app.Error_msg);
                return;
            end
        end

        function TreeSelectionChanged(app,event)%#ok
            app.Add.Enable=any(arrayfun(@(x)isempty(x.Children),app.Tree.SelectedNodes));
        end

        function SearchValueChanged(app,event)%#ok
            try
                slrealtime.internal.ApplicationTree.populate(app.Tree,app.SLRTApp,...
                'Signals',app.IsSignalTable,'Parameters',~app.IsSignalTable,'Search',app.Search.Value);
                app.TreeSelectionChanged([]);
            catch
                app.Search.Value='';
            end
        end

        function DeleteButtonPushed(app,event)%#ok
            refresh=~isempty(app.Search.Value);
            app.Search.Value='';
            if refresh
                app.SearchValueChanged([]);
            end
        end
    end

    methods(Access=private)
        function createComponents(app)

            app.UIFigure=uifigure('Visible','off');
            app.UIFigure.Position=[100,100,775,300];
            app.UIFigure.CloseRequestFcn=createCallbackFcn(app,@UIFigureCloseRequest,true);


            app.GridMain=uigridlayout(app.UIFigure);
            app.GridMain.ColumnWidth={20,'2x',20,25,40,'1x','1x'};
            app.GridMain.RowHeight={20,'1x',25,'1x',25,'1x',20,25};
            app.GridMain.ColumnSpacing=2;
            app.GridMain.RowSpacing=2;
            app.GridMain.Padding=[5,5,5,5];


            app.Tree=uitree(app.GridMain);
            app.Tree.Multiselect='on';
            app.Tree.SelectionChangedFcn=createCallbackFcn(app,@TreeSelectionChanged,true);
            app.Tree.Layout.Row=[2,7];
            app.Tree.Layout.Column=[1,3];


            app.Remove=uibutton(app.GridMain,'push');
            app.Remove.ButtonPushedFcn=createCallbackFcn(app,@RemoveButtonPushed,true);
            app.Remove.Layout.Row=5;
            app.Remove.Layout.Column=4;
            app.Remove.Text='';


            app.Add=uibutton(app.GridMain,'push');
            app.Add.ButtonPushedFcn=createCallbackFcn(app,@AddButtonPushed,true);
            app.Add.Layout.Row=3;
            app.Add.Layout.Column=4;
            app.Add.Text='';


            app.SelectionTable=uitable(app.GridMain);
            app.SelectionTable.Layout.Row=[1,7];
            app.SelectionTable.Layout.Column=[5,8];
            app.SelectionTable.RowStriping='off';
            app.SelectionTable.SelectionChangedFcn=@(o,e)app.SelectionTableChangedCB();
            app.SelectionTable.CellEditCallback=@(o,e)app.SelectionTableCellCB(e);
            app.SelectionTable.SelectionType='row';
            app.SelectionTable.Data={};


            app.AddFromModel=uibutton(app.GridMain);
            app.AddFromModel.ButtonPushedFcn=createCallbackFcn(app,@AddFromModelPushed,true);
            app.AddFromModel.Text=app.AddFromModel_msg;
            app.AddFromModel.Layout.Row=8;
            app.AddFromModel.Layout.Column=2;


            app.HighlightTable=uibutton(app.GridMain,'state');
            app.HighlightTable.ValueChangedFcn=createCallbackFcn(app,@HighlightTableValueChanged,true);
            app.HighlightTable.Text=app.HighlightTable_msg;
            app.HighlightTable.Layout.Row=8;
            app.HighlightTable.Layout.Column=8;


            app.Image=uiimage(app.GridMain);
            app.Image.Layout.Row=1;
            app.Image.Layout.Column=1;


            app.Search=uieditfield(app.GridMain,'text');
            app.Search.ValueChangedFcn=createCallbackFcn(app,@SearchValueChanged,true);
            app.Search.Layout.Row=1;
            app.Search.Layout.Column=2;


            app.Delete=uibutton(app.GridMain,'push');
            app.Delete.ButtonPushedFcn=createCallbackFcn(app,@DeleteButtonPushed,true);
            app.Delete.Layout.Row=1;
            app.Delete.Layout.Column=3;
            app.Delete.Text='';


            app.UIFigure.Visible='on';
        end
    end




    methods(Access=public)
        function app=SignalAndParameterTableSelector(varargin)
            createComponents(app)
            registerApp(app,app.UIFigure)
            runStartupFcn(app,@(app)startupFcn(app,varargin{:}))
            if nargout==0
                clear app
            end
        end

        function delete(app)
            delete(app.UIFigure)
        end
    end
end

function bindModeFinishedCB(app,dataMap)


    c=onCleanup(@()delete(app.ProgressDialog));

    data=[];
    if~isempty(dataMap)
        data=dataMap.values;
    end



    figure(app.UIFigure);



    for i=1:length(data)

        blockPath=strrep(data{i}.hierarchicalPathArr(2:end),newline,' ');
        if length(blockPath)==1
            blockPath=blockPath{1};
        end

        if app.IsSignalTable



            portIndex=data{i}.outputPortNumber;
            signalLabel=data{i}.signalLabel;

            if~isempty(signalLabel)
                blockPath=signalLabel;
                portIndex=-1;
            end

            app.AddSignalToTableComponent(blockPath,portIndex);
        else



            paramName=strrep(data{i}.name,newline,' ');

            app.AddParameterToTableComponent(blockPath,paramName);
        end
    end

    app.syncSelectionTableWithTableComponent();
end
