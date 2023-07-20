classdef LinkedPlotDialog<handle





    properties(Constant)
        EMPTY_DATA_SOURCE=string(getString(message('MATLAB:datamanager:linkedplot:Empty')));
    end

    properties(Access={?tlinkdata,?tLinkedPlotDialog,?tAllMigratedApps_CPT})
        LinkedPlotUIFigure matlab.ui.Figure
        DataSourceTable matlab.ui.control.Table

        ImmediateApplyCheckBox matlab.ui.control.CheckBox
        CancelButton matlab.ui.control.Button
        ErrorLabels matlab.ui.control.Label
        FigureDataManager datamanager.FigureDataManager
        TableLabel matlab.ui.control.Label
        OKButton matlab.ui.control.Button
        ErrorGridLayout matlab.ui.container.GridLayout
        ErrorIcons matlab.ui.control.Image

ParentFigure
ErrorMsgMatrix

LinkedObjects
    end

    properties(Access=?tLinkedPlotDialog,Constant)
        DIALOG_WIDTH=444
        DIALOG_HEIGHT=205
        ICON_HEIGHT=16
    end

    properties(Transient)

        ParentFigureDestroyedListener=event.listener.empty

        LinkedObjectsPropListeners=event.listener.empty
        PostUpdateListener=event.listener.empty
    end


    methods(Access=public)


        function this=LinkedPlotDialog(parentFigure)

            if isprop(parentFigure,'LinkedPlotApp')&&...
                ~isempty(parentFigure.LinkedPlotApp)&&...
                isvalid(parentFigure.LinkedPlotApp)
                this=parentFigure.LinkedPlotApp;
                this.bringToFront();
            else
                this.ParentFigure=parentFigure;
                this.FigureDataManager=datamanager.FigureDataManager.getInstance();

                this.createLinkedPlotDialog();


                this.ParentFigureDestroyedListener=event.listener(this.ParentFigure,'ObjectBeingDestroyed',@(e,d)this.delete());




                propName=addprop(parentFigure,'LinkedPlotApp');
                propName.Hidden=true;
                propName.Transient=true;
                parentFigure.LinkedPlotApp=this;
            end
        end


        function close(this)

            this.restoreCachedLineWidth();

            if numel(this.ErrorIcons)>0&&strcmpi(this.ErrorIcons(1).Visible,'on')
                this.delete();
            else
                this.PostUpdateListener.Enabled=false;
                set(this.LinkedPlotUIFigure,'Visible','off');
            end
        end

        function delete(this)
            if isvalid(this.ParentFigure)&&isprop(this.ParentFigure,'LinkedPlotApp')
                delete(findprop(this.ParentFigure,'LinkedPlotApp'));
            end


            this.restoreCachedLineWidth();


            delete(this.LinkedObjectsPropListeners);
            delete(this.ParentFigureDestroyedListener);
            delete(this.PostUpdateListener);


            delete(this.LinkedPlotUIFigure);
        end

        function bringToFront(this)


            set(this.LinkedPlotUIFigure,'Visible','on','Position',this.getDialogPosition());
            this.updateTableData();
            figure(this.LinkedPlotUIFigure);
            this.PostUpdateListener.Enabled=true;
        end
    end

    methods(Access=?tLinkedPlotDialog)

        function dialogPos=getDialogPosition(this)
            figPos=getpixelposition(this.ParentFigure);
            dialogPos=[figPos(1)+figPos(3)+5,figPos(2),this.DIALOG_WIDTH,this.DIALOG_HEIGHT];
            screenSize=get(0,'ScreenSize');
            if strcmpi(this.ParentFigure.WindowState,'maximized')


                dialogPos(1)=figPos(1)+figPos(3)-dialogPos(3);
                dialogPos(2)=figPos(2);
            elseif strcmpi(this.ParentFigure.WindowStyle,'docked')


                dialogPos(1)=screenSize(3)/3;
                dialogPos(2)=screenSize(4)/3;
            else
                xPos=abs(dialogPos(1));

                if xPos>screenSize(3)
                    xPos=xPos-screenSize(3);
                end


                if(xPos+dialogPos(3))>screenSize(3)
                    dialogPos(1)=figPos(1)-dialogPos(3)-5;
                    dialogPos(2)=figPos(2);
                end
            end
        end


        function createLinkedPlotDialog(this)

            this.LinkedPlotUIFigure=this.FigureDataManager.getWarmedUpFigure();
            set(this.LinkedPlotUIFigure,...
            'Position',this.getDialogPosition(),...
            'CloseRequestFcn',@(e,d)this.close(),...
            'AutoResizeChildren','on');


            dialogName=getString(message('MATLAB:datamanager:linkedplot:DialogTitle'));
            figureNum=this.ParentFigure.Number;
            if isempty(figureNum)
                figureNum="";
            end
            if~isempty(this.ParentFigure.Name)
                this.LinkedPlotUIFigure.Name="Figure "+figureNum+" "+this.ParentFigure.Name+": "+dialogName;
            else
                this.LinkedPlotUIFigure.Name="Figure "+figureNum+": "+dialogName;
            end


            mainGridLayout=uigridlayout(this.LinkedPlotUIFigure,'Scrollable',true);
            mainGridLayout.ColumnWidth={'1x'};
            mainGridLayout.RowHeight={'fit',100,'fit','fit'};


            this.TableLabel=uilabel(mainGridLayout,...
            'Internal',true,...
            'Text',getString(message('MATLAB:datamanager:linkedplot:SpecifyDataSource')));
            this.TableLabel.Layout.Row=1;
            this.TableLabel.Layout.Column=1;


            this.DataSourceTable=uitable('Parent',mainGridLayout,...
            'RowStriping','off',...
            'ColumnName',{getString(message('MATLAB:datamanager:linkedplot:DisplayNameLabel'));'X';'Y';'Z'},...
            'ColumnEditable',true,...
            'RowName',{},...
            'Internal',true,...
            'BackgroundColor',[1,1,1],...
            'CellEditCallback',@(e,d)this.tableCellEditCallback(d),...
            'CellSelectionCallback',@(e,d)this.tableCellSelectCallback(d));
            this.DataSourceTable.Layout.Row=2;
            this.DataSourceTable.Layout.Column=1;

            this.ErrorGridLayout=uigridlayout(mainGridLayout,'Padding',[0,0,0,0],...
            'RowSpacing',5,'ColumnSpacing',5);
            this.ErrorGridLayout.ColumnWidth={this.ICON_HEIGHT,'1x'};
            this.ErrorGridLayout.RowHeight={this.ICON_HEIGHT};
            this.ErrorGridLayout.Layout.Row=3;
            this.ErrorGridLayout.Layout.Column=1;



            this.createErrorLabels();
            this.createErrorIcons();

            bottomGridLayout=uigridlayout(mainGridLayout,'Padding',[0,0,0,0]);
            bottomGridLayout.ColumnWidth={'fit','1x',80,80};
            bottomGridLayout.RowHeight={'fit'};
            bottomGridLayout.Layout.Row=4;
            bottomGridLayout.Layout.Column=1;


            this.ImmediateApplyCheckBox=uicheckbox(bottomGridLayout,...
            'Text',getString(message('MATLAB:datamanager:linkedplot:ImmediateApplyLabel')),...
            'Value',1,...
            'Internal',true,...
            'ValueChangedFcn',@(e,d)this.applyCheckBoxValueChanged());
            this.ImmediateApplyCheckBox.Layout.Row=1;
            this.ImmediateApplyCheckBox.Layout.Column=1;


            this.OKButton=uibutton(bottomGridLayout,'push',...
            'Text',getString(message('MATLAB:datamanager:linkedplot:OKLabel')),...
            'Internal',true,...
            'ButtonPushedFcn',@(e,d)this.okBtnPushedCallback());
            this.OKButton.Layout.Row=1;
            this.OKButton.Layout.Column=3;


            this.CancelButton=uibutton(bottomGridLayout,'push',...
            'Text',getString(message('MATLAB:datamanager:linkedplot:CancelLabel')),...
            'Internal',true,...
            'ButtonPushedFcn',@(e,d)this.cancelButtonPressed());
            this.CancelButton.Layout.Row=1;
            this.CancelButton.Layout.Column=4;


            this.updateTableData();


            this.PostUpdateListener=event.listener(this.ParentFigure.getCanvas(),'PostUpdate',@(e,d)this.refreshTableDataIfNeeded());


            set(this.LinkedPlotUIFigure,'Visible','on','Position',this.getDialogPosition());

            internal.matlab.datatoolsservices.executeCmd('datamanager.FigureDataManager.warmUpFigure()');
        end

        function createErrorLabels(this)
            this.ErrorLabels(end+1)=uilabel(this.ErrorGridLayout,...
            'FontColor',[.886,.239,.176],...
            'FontWeight','bold',...
            'FontSize',12,...
            'Text',"",...
            'Internal',true,...
            'BackgroundColor',[0.9412,0.9412,0.9412],...
            'Visible','off');
            this.ErrorLabels(end).Layout.Column=2;
            this.ErrorLabels(end).Layout.Row=numel(this.ErrorLabels);
        end

        function createErrorIcons(this)
            this.ErrorIcons(end+1)=uiimage(this.ErrorGridLayout,...
            'Internal',true,...
            'ImageSource',fullfile(...
            'toolbox','matlab','datamanager','+datamanager','LinkedPlotDialog','error_12.png'),...
            'Visible','off');

            this.ErrorIcons(end).Layout.Column=1;
            this.ErrorIcons(end).Layout.Row=numel(this.ErrorIcons);
        end



        function tableData=updateTableData(this)

            delete(this.LinkedObjectsPropListeners);
            [this.LinkedObjects,tableSupportUsed]=this.findLinkedObjects();

            tableData=[];



            for row=1:length(this.LinkedObjects)
                linkedObj=this.LinkedObjects(row);
                xDS='';
                yDS='';
                zDS='';



                if~isempty(hggetbehavior(linkedObj,'linked','-peek'))
                    linkBehavior=hggetbehavior(linkedObj,'linked');
                    if linkBehavior.UsesXDataSource
                        xDS=linkBehavior.XDataSource;
                    end
                    if linkBehavior.UsesYDataSource
                        yDS=linkBehavior.YDataSource;
                    end
                    if linkBehavior.UsesZDataSource
                        zDS=linkBehavior.ZDataSource;
                    end
                else
                    if isprop(linkedObj,'XDataSource')
                        xDS=linkedObj.XDataSource;
                        XSrcs=getappdata(double(linkedObj),'XDataSourceOptions');
                        if isempty(xDS)
                            if~isempty(XSrcs)
                                xDS=XSrcs{1};
                            end
                        end
                    end
                    if isprop(linkedObj,'YDataSource')
                        yDS=linkedObj.YDataSource;
                        YSrcs=getappdata(double(linkedObj),'YDataSourceOptions');
                        if isempty(yDS)
                            if~isempty(YSrcs)
                                yDS=YSrcs{1};
                            end
                        end
                    end
                    if isprop(linkedObj,'ZDataSource')
                        zDS=linkedObj.ZDataSource;
                        ZSrcs=getappdata(double(linkedObj),'ZDataSourceOptions');
                        if isempty(zDS)
                            if~isempty(ZSrcs)
                                zDS=ZSrcs{1};
                            end
                        end
                    end

                end


                displayName=this.constructDisplayName(linkedObj,zDS,yDS,xDS);
                if strcmpi(linkedObj.DisplayNameMode,'auto')&&...
                    isempty(linkedObj.DisplayName_I)




                    this.updateDisplayNameCellStyle(row,true);
                elseif~isempty(displayName)


                    linkedObj.DisplayName_I=displayName;
                end



                if strlength(xDS)==0
                    xDS=this.EMPTY_DATA_SOURCE;
                end
                if strlength(yDS)==0
                    yDS=this.EMPTY_DATA_SOURCE;;
                end
                if strlength(zDS)==0
                    zDS=this.EMPTY_DATA_SOURCE;;
                end



                [varList2D,varList3D]=this.getVariablesFromWorkspace();
                displayNameTable=array2table(string(displayName),'VariableNames',string(getString(message('MATLAB:datamanager:linkedplot:DisplayNameLabel'))));
                if ishghandle(linkedObj,'surface')||ishghandle(linkedObj,'contour')
                    dataSourcesTable=array2table([...
                    categorical(string(xDS),unique([string(xDS),varList2D]))...
                    ,categorical(string(yDS),unique([string(yDS),varList2D]))...
                    ,categorical(string(zDS),unique([string(zDS),varList3D]))],...
                    'VariableNames',["X","Y","Z"]);
                else
                    dataSourcesTable=array2table([...
                    categorical(string(xDS),unique([string(xDS),varList2D]))...
                    ,categorical(string(yDS),unique([string(yDS),varList2D]))...
                    ,categorical(string(zDS),unique([string(zDS),varList2D]))],...
                    'VariableNames',["X","Y","Z"]);
                end

                if isempty(tableData)
                    tableData=[displayNameTable,dataSourcesTable];
                else
                    tableData=[tableData;displayNameTable,dataSourcesTable];
                end




                this.LinkedObjectsPropListeners(row,:)=[event.proplistener(linkedObj,findprop(linkedObj,'DisplayName'),'PostSet',@(e,d)this.updateLinkedObjectInTable(d)),...
                event.proplistener(linkedObj,findprop(linkedObj,'XDataSource'),'PostSet',@(e,d)this.updateLinkedObjectInTable(d)),...
                event.proplistener(linkedObj,findprop(linkedObj,'YDataSource'),'PostSet',@(e,d)this.updateLinkedObjectInTable(d)),...
                event.proplistener(linkedObj,findprop(linkedObj,'ZDataSource'),'PostSet',@(e,d)this.updateLinkedObjectInTable(d))];
            end

            this.DataSourceTable.Data=tableData;
            for row=1:size(tableData,1)
                for col=2:size(tableData,2)
                    if tableData{row,col}==this.EMPTY_DATA_SOURCE;
                        this.DataSourceTable.addStyle(uistyle('FontAngle','italic'),'cell',[row,col]);
                    else
                        this.DataSourceTable.addStyle(uistyle('FontAngle','normal'),'cell',[row,col]);
                    end
                end
            end






            if tableSupportUsed&&isempty(this.LinkedObjects)
                if~isempty(tableData)
                    this.evaluateTableData();
                end
                this.ErrorLabels(1).Text={getString(message('MATLAB:datamanager:linkedplot:CannotLinkTableData'))};
                set(this.ErrorLabels,'Visible','on');
                set(this.ErrorIcons,'Visible','on');
            elseif isempty(tableData)
                this.ErrorLabels(1).Text={getString(message('MATLAB:datamanager:linkedplot:CannotLinkData'))};
                set(this.ErrorLabels,'Visible','on');
                set(this.ErrorIcons,'Visible','on');
            else
                this.ErrorLabels(1).Text='';
                set(this.ErrorLabels,'Visible','off');
                set(this.ErrorIcons,'Visible','off');
                this.evaluateTableData();
            end
        end




        function tableCellEditCallback(this,d)
            prevValue=d.PreviousData;
            userInput=strtrim(string(d.NewData));



            if~strcmp(prevValue,userInput)&&this.ImmediateApplyCheckBox.Value
                rowInd=d.Indices(1);
                colInd=d.Indices(2);




                if colInd==1
                    this.LinkedObjects(rowInd).DisplayName=userInput;


                    this.updateDisplayNameCellStyle(rowInd,false);
                else


                    this.validateUserInput(userInput,colInd);


                    this.evaluateDataSourceValues(rowInd);
                end
            end
        end


        function updateDisplayNameCellStyle(this,rowInd,isWaterMark)
            if isWaterMark

                cellStyle=uistyle('FontAngle','italic','FontColor','#808080');
                this.DataSourceTable.addStyle(cellStyle,'cell',[rowInd,1]);
            else

                cellStyle=uistyle('FontAngle','normal','FontColor','black');
                this.DataSourceTable.addStyle(cellStyle,'cell',[rowInd,1]);
            end
        end


        function updateErrorLabel(this)


            set(this.ErrorLabels,'Visible','off');
            set(this.ErrorIcons,'Visible','off');
            this.ErrorGridLayout.RowHeight={this.ICON_HEIGHT};
            delete(this.ErrorIcons(2:end));
            this.ErrorIcons(2:end)=[];
            delete(this.ErrorLabels(2:end));
            this.ErrorLabels(2:end)=[];
            if~isempty(this.ErrorMsgMatrix)
                numErrors=0;
                for i=1:numel(this.ErrorMsgMatrix)
                    error=this.ErrorMsgMatrix{i};
                    if~isempty(error)
                        numErrors=numErrors+1;
                        error=regexprep(error{1},'\n+','');
                        if numErrors>numel(this.ErrorLabels)
                            this.ErrorGridLayout.RowHeight{end+1}=this.ICON_HEIGHT;
                            this.createErrorLabels();
                            this.createErrorIcons();
                        end
                        this.ErrorLabels(numErrors).Text={error};
                    end
                end
                if numErrors>0
                    set(this.ErrorLabels,'Visible','on');
                    set(this.ErrorIcons,'Visible','on');
                end
            end
        end



        function[linkedObjects,tableSupportUsed]=findLinkedObjects(this)
            [linkedObjectList,linkedCustomObjects,tableSupportUsed]=datamanager.findLinkedGraphics(this.ParentFigure);

            if isempty(linkedCustomObjects)
                linkedObjects=handle(linkedObjectList(:));
            elseif isempty(linkedObjectList)
                linkedObjects=handle(linkedCustomObjects(:));
            else
                linkedObjects=handle([linkedCustomObjects(:);linkedObjectList(:)]);
            end
        end




        function updateLinkedObjectInTable(this,d)
            rowInd=find(this.LinkedObjects==d.AffectedObject);
            propNames={'DisplayName','XDataSource','YDataSource','ZDataSource'};
            colInd=find(strcmpi(propNames,d.Source.Name));
            if strcmpi(d.Source.Name,'DisplayName')
                this.updateDisplayNameCellStyle(rowInd,false);
            end

            prevVal=this.DataSourceTable.Data(rowInd,colInd);
            newVal={d.AffectedObject.(d.Source.Name)};





            this.DataSourceTable.Data(rowInd,colInd)=newVal;



            this.tableCellEditCallback(struct('PreviousData',prevVal,'NewData',newVal,'Indices',[rowInd,colInd]));
        end




        function okBtnPushedCallback(this)
            hasError=false;
            if~this.ImmediateApplyCheckBox.Value



                hasError=this.evaluateTableData();
            end

            if~hasError
                this.close();
            end
        end




        function applyCheckBoxValueChanged(this)
            if this.ImmediateApplyCheckBox.Value
                this.evaluateTableData();
            end
        end


        function hasError=evaluateTableData(this)
            tableData=this.DataSourceTable.Data;
            hasError=false;


            for rowInd=1:size(tableData,1)
                linkedObj=this.LinkedObjects(rowInd);
                if~isempty(linkedObj.DisplayName_I)
                    linkedObj.DisplayName_I=tableData{rowInd,1};
                end

                hasError=evaluateDataSourceValues(this,rowInd);
            end
        end

        function updateErrorMatrix(this,errorMsg,rowInd,colInd)


            this.DataSourceTable.addStyle(uistyle('BackgroundColor','#ffcfd1'),'cell',[rowInd,colInd]);
            colName='X';
            if colInd==3
                colName='Y';
            elseif colInd==4
                colName='Z';
            end
            this.ErrorMsgMatrix{rowInd,colInd-1}={['Cell ',colName,num2str(rowInd),': ',errorMsg]};
        end



        function hasError=evaluateDataSourceValues(this,rowInd)
            evaluatedRow={'','',''};
            hasError=false;
            rowData=this.DataSourceTable.Data(rowInd,:);
            linkedObj=this.LinkedObjects(rowInd);
            if~isempty(this.ErrorMsgMatrix)&&size(this.ErrorMsgMatrix,1)>=rowInd&&~isempty(this.ErrorMsgMatrix(rowInd,:))
                this.ErrorMsgMatrix(rowInd,:)={[]};
            end
            ind=1;
            this.DataSourceTable.addStyle(uistyle('BackgroundColor','white','FontAngle','normal'),'row',rowInd);
            for colInd=2:4
                if isundefined(rowData{1,colInd})||strtrim(string(rowData{1,colInd}))==""||...
                    isequal(rowData{1,colInd},this.EMPTY_DATA_SOURCE)
                    evaluatedRow{ind}=[];

                    rowData{1,colInd}=this.EMPTY_DATA_SOURCE;
                    this.DataSourceTable.Data{rowInd,colInd}=this.EMPTY_DATA_SOURCE;
                    this.DataSourceTable.addStyle(uistyle('FontAngle','italic'),'cell',[rowInd,colInd]);
                elseif~isequal(strtrim(string(rowData{1,colInd})),this.EMPTY_DATA_SOURCE)
                    colValue=strtrim(string(rowData{1,colInd}));

                    try
                        evaluatedRow{ind}=evalin('base',colValue);
                    catch ex
                        hasError=true;
                        this.updateErrorMatrix(ex.message,rowInd,colInd);
                    end
                    if~hasError
                        if isempty(evaluatedRow{ind})||isequal(evaluatedRow{ind},"")


                            rowData{1,colInd}=this.EMPTY_DATA_SOURCE;
                            this.DataSourceTable.Data{rowInd,colInd}=this.EMPTY_DATA_SOURCE;
                            this.DataSourceTable.addStyle(uistyle('FontAngle','italic'),'cell',[rowInd,colInd]);
                        else
                            this.DataSourceTable.addStyle(uistyle('FontAngle','normal'),'cell',[rowInd,colInd]);
                        end
                    end
                end

                ind=ind+1;
            end




            hasError=hasError||this.validateSizeMismatch(rowInd,evaluatedRow{1},evaluatedRow{2},evaluatedRow{3});



            if~hasError
                displayName={this.constructDisplayName(linkedObj,string(rowData{1,4}),string(rowData{1,3}),string(rowData{1,2}))};
                if strcmpi(linkedObj.DisplayNameMode,'auto')&&...
                    ~strcmpi(displayName,localGetDefaultDisplayName(linkedObj))
                    this.updateDisplayNameCellStyle(rowInd,false);
                    this.DataSourceTable.Data(rowInd,1)=displayName;
                    linkedObj.DisplayName_I=displayName{:};
                end



                this.DataSourceTable.addStyle(uistyle('BackgroundColor','white'),'row',rowInd);
                if~isempty(this.ErrorMsgMatrix)&&size(this.ErrorMsgMatrix,1)>=rowInd&&~isempty(this.ErrorMsgMatrix(rowInd,:))
                    this.ErrorMsgMatrix(rowInd,:)={[]};
                end
                this.updateErrorLabel();
                this.updatedLinkedPlots(linkedObj,rowData);
            else

                this.updateErrorLabel();
            end
        end


        function hasSizeMismatch=validateSizeMismatch(this,rowInd,xVal,yVal,zVal)
            linkedObj=this.LinkedObjects(rowInd);
            ax=ancestor(linkedObj,'matlab.graphics.axis.AbstractAxes');
            hasSizeMismatch=false;
            if~isempty(ax)

                if~isempty(xVal)&&~isempty(yVal)&&numel(xVal)~=numel(yVal)
                    this.DataSourceTable.addStyle(uistyle('BackgroundColor','#ffcfd1'),'row',rowInd);
                    this.ErrorMsgMatrix{rowInd,end+1}={['Row ',num2str(rowInd),': ',getString(message('MATLAB:datamanager:linkedplot:DifferentXYZSize','X','Y'))]};
                    hasSizeMismatch=true;
                elseif~is2D(ax)&&~isempty(zVal)&&...
                    ((~isempty(xVal)&&numel(zVal)~=numel(xVal))||...
                    (~isempty(yVal)&&numel(zVal)~=numel(yVal)))
                    this.DataSourceTable.addStyle(uistyle('BackgroundColor','#ffcfd1'),'row',rowInd);
                    this.ErrorMsgMatrix{rowInd,end+1}={['Row ',num2str(rowInd),': ',getString(message('MATLAB:datamanager:linkedplot:DifferentXYZSize','X,Y','Z'))]};
                    hasSizeMismatch=true;
                end
            end
        end

        function restoreCachedLineWidth(this)


            for k=1:length(this.LinkedObjects)
                linkedObj=this.LinkedObjects(k);
                if isvalid(linkedObj)&&isappdata(linkedObj,'CacheWidth')
                    cacheWidth=getappdata(linkedObj,'CacheWidth');
                    if~isempty(cacheWidth)
                        set(linkedObj,'LineWidth',cacheWidth);
                    end
                end
            end
        end






        function tableCellSelectCallback(this,d)
            if isempty(d.Indices)
                return;
            end
            selectedRow=d.Indices(1);
            selectedCol=d.Indices(2);

            linkedObj=this.LinkedObjects(selectedRow);






            for i=1:numel(this.LinkedObjects)
                obj=this.LinkedObjects(i);
                if i==selectedRow&&...
                    selectedCol==1&&...
                    strcmpi(obj.DisplayNameMode,'auto')
                    displayName=this.DataSourceTable.Data{selectedRow,1};
                    if strcmpi(displayName,obj.Type)&&...
                        isempty(obj.DisplayName)&&...
                        ~strcmpi(displayName,obj.DisplayName)
                        this.DataSourceTable.Data(selectedRow,selectedCol)={''};
                    end
                elseif strcmpi(obj.DisplayNameMode,'auto')&&...
                    isempty(obj.DisplayName_I)
                    this.DataSourceTable.Data(i,1)={localGetDefaultDisplayName(obj)};
                end
            end




            this.restoreCachedLineWidth();
            if isprop(linkedObj,'LineWidth')
                lw=get(linkedObj,'LineWidth');
                setappdata(linkedObj,'CacheWidth',lw);
                set(linkedObj,'LineWidth',lw*3);
            end
        end



        function updatedLinkedPlots(this,linkedObj,rowData)
            allProps={'XDataSource','YDataSource','ZDataSource'};
            datasrcVals=[string(rowData{1,2}),string(rowData{1,3}),string(rowData{1,4})];
            Iprops=false(size(datasrcVals));
            for j=1:length(allProps)
                Iprops(j)=~isempty(linkedObj.findprop(allProps{j}));
            end
            I=cellfun('isclass',datasrcVals,'char')&Iprops;
            for k=1:3
                if isempty(datasrcVals(k))||isequal(datasrcVals(k),this.EMPTY_DATA_SOURCE);
                    datasrcVals(k)="";
                end
            end

            if isempty(hggetbehavior(linkedObj,'linked','-peek'))
                set(linkedObj,allProps(I),cellstr(strtrim(datasrcVals(1,I))));
            else
                linkBehavior=hggetbehavior(linkedObj,'linked');
                datalen=sum([linkBehavior.UsesXDataSource,linkBehavior.UsesYDataSource,linkBehavior.UsesZDataSource]);
                data=cell(1,datalen);
                count=1;
                if linkBehavior.UsesXDataSource
                    try %#ok<TRYNC>
                        data{count}=evalin('base',rowData{2});
                    end
                    set(linkBehavior,'XDataSource',strtrim(rowData{2}));
                    count=count+1;
                end
                if linkBehavior.UsesYDataSource
                    try %#ok<TRYNC>
                        data{count}=evalin('base',rowData{3});
                    end
                    set(linkBehavior,'YDataSource',strtrim(rowData{3}));
                    count=count+1;
                end
                if linkBehavior.UsesZDataSource
                    try %#ok<TRYNC>
                        data{count}=evalin('base',rowData{4});
                    end
                    set(linkBehavior,'ZDataSource',strtrim(rowData{4}));
                end

                try %#ok<TRYNC>
                    feval(linkBehavior.DataSourceFcn{1},linkedObj,...
                    data,linkBehavior.DataSourceFcn{2:end});
                end
            end


            hFig=this.ParentFigure;
            if~isempty(hFig.findprop('LinkPlot'))&&hFig.LinkPlot
                linkmgr=datamanager.LinkplotManager.getInstance();
                linkmgr.updateLinkedGraphics(hFig);
                linkmgr.LinkListener.postRefresh({hFig,'retainUndo',false,'redrawBrushing',true});
            end
        end



        function refreshTableDataIfNeeded(this)
            linkedObjects=this.findLinkedObjects();


            if numel(this.LinkedObjects)~=numel(linkedObjects)||...
                any(this.LinkedObjects~=linkedObjects)
                this.updateTableData();
            end
        end



        function cancelButtonPressed(this)
            this.delete();
        end
    end

    methods(Static)
        function[varList1D,varList2D]=getVariablesFromWorkspace()

            baseWSVarContent=evalin('base','whos');
            classOfInput=["single","double","int8","int16","int32","int64","uint8","uint16","uint32","uint64","categorical","datetime","duration","calendarduration"];
            varList1D=datamanager.LinkedPlotDialog.EMPTY_DATA_SOURCE;;
            varList2D=datamanager.LinkedPlotDialog.EMPTY_DATA_SOURCE;
            varClass1DList="";
            varClass2DList="";
            count=1;
            for ind=1:length(baseWSVarContent)
                varContent=baseWSVarContent(ind);
                if ismember(varContent.class,classOfInput)&&...
                    prod(varContent.size)>1&&...
                    length(varContent.size)==2
                    if min(varContent.size)==1
                        varList1D=[varList1D;string(varContent.name)];%#ok<*AGROW>
                        varClass1DList=[varClass1DList;string(varContent.class)];
                        count=count+1;
                    else
                        varList1D=[varList1D;...
                        sprintf('%s(:,1)',string(varContent.name));...
                        sprintf('%s(:,end)',string(varContent.name));...
                        sprintf('%s(1,:)',string(varContent.name));...
                        sprintf('%s(end,:)',string(varContent.name))];
                        varClass1DList=[varClass1DList;repmat(string(varContent.class),[4,1])];
                        varList2D=[varList2D;string(varContent.name)];
                        varClass2DList=[varClass2DList;string(varContent.class)];
                        count=count+5;
                    end
                end



                if count>100
                    break
                end
            end

            if isempty(varList1D)
                varList1D=[];
            else
                varList1D=varList1D';
            end

            if isempty(varList2D)
                varList2D=[];
            else
                varList2D=varList2D';
            end
        end

        function displayName=constructDisplayName(obj,zDS,yDS,xDS)

            if strcmpi(obj.DisplayNameMode,'manual')
                displayName=obj.DisplayName;
                return;
            end
            if~isequal(zDS,datamanager.LinkedPlotDialog.EMPTY_DATA_SOURCE)
                displayName=string(zDS);
            else
                displayName="";
            end
            if displayName~=""&&~isequal(yDS,datamanager.LinkedPlotDialog.EMPTY_DATA_SOURCE)&&strlength(yDS)>0
                displayName=strcat(displayName," ",getString(message('MATLAB:datamanager:linkedplot:Vs'))," ",yDS);
            elseif displayName==""&&~isequal(yDS,datamanager.LinkedPlotDialog.EMPTY_DATA_SOURCE)
                displayName=yDS;
            end
            if displayName~=""&&~isequal(xDS,datamanager.LinkedPlotDialog.EMPTY_DATA_SOURCE)&&strlength(xDS)>0
                displayName=strcat(displayName," ",getString(message('MATLAB:datamanager:linkedplot:Vs'))," ",xDS);
            elseif displayName==""&&~isequal(xDS,datamanager.LinkedPlotDialog.EMPTY_DATA_SOURCE)
                displayName=xDS;
            end

            if displayName==""
                displayName=localGetDefaultDisplayName(obj);
            end
        end

        function validateUserInput(userInput,colInd)


            if strlength(userInput)>0&&~isequal(userInput,datamanager.LinkedPlotDialog.EMPTY_DATA_SOURCE)
                try


                    evaluatedVal=evalin('base',userInput);



                    isValidValue=isnumeric(evaluatedVal)||...
                    any(strcmp(class(evaluatedVal),{'datetime','calendarduration','duration','categorical'}));

                    if colInd>1&&((~isValidValue)||~ismatrix(evaluatedVal))
                        return;
                    end
                catch
                end
            end
        end
    end
end


function displayName=localGetDefaultDisplayName(obj)
    displayName=obj.DisplayName_I;
    if strcmpi(obj.DisplayNameMode,'auto')&&isempty(displayName)
        displayName=obj.Type;
        displayName(1)=upper(displayName(1));
    end
end