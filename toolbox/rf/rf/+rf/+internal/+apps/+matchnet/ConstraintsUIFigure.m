





classdef ConstraintsUIFigure<handle



    properties(Access=public)
        gridOverall(1,1)matlab.ui.container.GridLayout
        gridButtons(1,1)matlab.ui.container.GridLayout
        EvalparamTable(1,1)matlab.ui.control.Table
        AddParameterButton(1,1)matlab.ui.control.Button
        DeleteParameterButton(1,1)matlab.ui.control.Button

SelectedRows
selectedCircuits

        Figure matlab.ui.Figure
        ResponsePanelOK(1,1)matlab.ui.control.Button

        ResponsePanelCancel(1,1)matlab.ui.control.Button
        ResponsePanel(1,1)matlab.ui.container.GridLayout

RawTable
        TotalRows(1,1)double{mustBeNonnegative}=0

        GreyLabel(1,1)matlab.ui.control.Label
    end

    properties(Access=protected,Constant)
        CIRC_PERF_IDX=8
        STATIC_TABLE_HEADERS={'abs(Parameter)','Condition',...
        sprintf('Goal\n(dB)'),sprintf('Min Frequency\n(GHz)'),...
        sprintf('Max Frequency\n(GHz)'),'Weight','Active'}
        DEFAULT_EVALPARAM_LINE={'S21','>',-3,1.4,1.6,1,true}


        FREQUENCY_SCALAR=1e9
    end

    events
EvalparamEditedUI
EvalparamDeletedUI

CircuitDataRequestedUI
EvalparamView
    end

    methods(Access=public)
        function this=ConstraintsUIFigure(inputdata,state)
            this.Figure=uifigure(...
            'Visible',matlab.lang.OnOffSwitchState.off,...
            'Name',...
            getString(message('rf:matchingnetworkgenerator:ConstraintsUIFigureTitle')),...
            'WindowStyle','modal');
            this.initializeUI();
            if nargin&&~isempty(inputdata)
                this.DeleteParameterButton.Enable='on';
                this.EvalparamTable.Data=inputdata;
                this.RawTable=inputdata;
                this.TotalRows=size(inputdata,1);

                this.EvalparamTable.Visible=matlab.lang.OnOffSwitchState.on;
                this.GreyLabel.Visible=matlab.lang.OnOffSwitchState.off;
            end
            if nargin>1
                this.Figure.Visible=state;
            else
                this.Figure.Visible=matlab.lang.OnOffSwitchState.on;
            end
        end
    end


    methods(Access=public)


        function newEvalparamLine(this)
            this.gridOverall.Visible=matlab.lang.OnOffSwitchState.off;


            this.EvalparamTable.Data(end+1,1:7)=this.DEFAULT_EVALPARAM_LINE;
            this.DeleteParameterButton.Enable='on';

            this.GreyLabel.Visible=matlab.lang.OnOffSwitchState.off;
            this.EvalparamTable.Visible=matlab.lang.OnOffSwitchState.on;

            this.gridOverall.Visible=matlab.lang.OnOffSwitchState.on;
        end


        function deleteEvalparamLine(this)



            this.gridOverall.Visible=matlab.lang.OnOffSwitchState.off;
            try
                this.EvalparamTable.Data(this.SelectedRows,:)=[];

            catch
            end
            if isempty(this.EvalparamTable.Data)
                this.DeleteParameterButton.Enable='off';
            end
            this.gridOverall.Visible=matlab.lang.OnOffSwitchState.on;
        end


        function updateSelectedCell(this,evtdata)
            indices=evtdata.Indices;
            this.SelectedRows=unique(indices(:,1));
        end

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
    end

    methods(Access=protected)
        function initializeUI(this)



            this.gridOverall=uigridlayout(this.Figure,...
            'RowHeight',{50,'1x',50},'ColumnWidth',{'1x'},...
            'RowSpacing',0,'Visible',matlab.lang.OnOffSwitchState.off);

            this.gridButtons=uigridlayout(this.gridOverall,...
            'RowHeight',{'1x'},'ColumnWidth',{'1x',50,20,50,'1x'});
            this.gridButtons.Layout.Row=1;

            this.AddParameterButton=uibutton(this.gridButtons,...
            'Text','','Icon',...
            fullfile(matlabroot,'toolbox','shared','controllib',...
            'general','resources','toolstrip_icons','Add_24.png'),...
            'ButtonPushedFcn',@(~,~)this.newEvalparamLine());
            this.AddParameterButton.Tooltip=getString(message('rf:matchingnetworkgenerator:AddConstraint'));
            this.AddParameterButton.Layout.Column=2;

            this.DeleteParameterButton=uibutton(this.gridButtons,...
            'Text','','Enable','off','Icon',...
            fullfile(matlabroot,'toolbox','shared','controllib',...
            'general','resources','toolstrip_icons','Delete_24.png'),...
            'ButtonPushedFcn',@(~,~)this.deleteEvalparamLine());
            this.DeleteParameterButton.Tooltip=getString(message('rf:matchingnetworkgenerator:DelConstraint'));
            this.DeleteParameterButton.Layout.Column=4;

            this.initializeTable();

            this.ResponsePanel=uigridlayout(this.gridOverall,...
            'RowHeight',{'1x'},'ColumnWidth',{'1x',85,85,85});
            this.ResponsePanel.Layout.Row=3;

            this.ResponsePanelOK=uibutton(this.ResponsePanel,...
            'ButtonPushedFcn',@(h,e)setConstraints(this),...
            'Text','OK');
            this.ResponsePanelOK.Layout.Row=1;
            this.ResponsePanelOK.Layout.Column=3;







            this.ResponsePanelCancel=uibutton(this.ResponsePanel,...
            'ButtonPushedFcn',@(~,~)closeNewSession(this),...
            'Text','Cancel');
            this.ResponsePanelCancel.Layout.Row=1;
            this.ResponsePanelCancel.Layout.Column=4;

            this.gridOverall.Visible=matlab.lang.OnOffSwitchState.on;
        end

        function isvalid=checkPanel(this,skip)
            s=uistyle('BackgroundColor','w');
            addStyle(this.EvalparamTable,s)
            checkWeight=cell2mat(this.EvalparamTable.Data(:,6))==0;
            checkActive=cell2mat(this.EvalparamTable.Data(:,7))==true;
            check=checkWeight&checkActive;

            if any(check)
                s=uistyle('BackgroundColor','red');
                row=find(check);
                col=6*ones(size(row));
                addStyle(this.EvalparamTable,s,'cell',vertcat([row,col]));
            end

            checkWeight=cell2mat(this.EvalparamTable.Data(:,6))<0;
            if any(checkWeight)
                s=uistyle('BackgroundColor','red');
                row=find(checkWeight);
                col=6*ones(size(row));
                addStyle(this.EvalparamTable,s,'cell',vertcat([row,col]));
            end

            checkGoal=cell2mat(this.EvalparamTable.Data(:,3))>0;
            if any(checkGoal)
                s=uistyle('BackgroundColor','red');
                row=find(checkGoal);
                col=3*ones(size(row));
                addStyle(this.EvalparamTable,s,'cell',vertcat([row,col]));
            end

            checkF1positive=cell2mat(this.EvalparamTable.Data(:,4))<0;
            if any(checkF1positive)
                s=uistyle('BackgroundColor','red');
                row=find(checkF1positive);
                col=4*ones(size(row));
                addStyle(this.EvalparamTable,s,'cell',vertcat([row,col]));
            end

            checkF2positive=cell2mat(this.EvalparamTable.Data(:,5))<0;
            if any(checkF2positive)
                s=uistyle('BackgroundColor','red');
                row=find(checkF2positive);
                col=5*ones(size(row));
                addStyle(this.EvalparamTable,s,'cell',vertcat([row,col]));
            end

            checkNaN=isnan(cell2mat(this.EvalparamTable.Data(:,3:6)));
            if any(checkNaN(:))
                s=uistyle('BackgroundColor','red');
                [row,col]=find(checkNaN);
                col=col+2;
                addStyle(this.EvalparamTable,s,'cell',vertcat([row,col]));
            end

            if skip
                checkF=cell2mat(this.EvalparamTable.Data(:,4))>...
                cell2mat(this.EvalparamTable.Data(:,5));
                if any(checkF)
                    s=uistyle('BackgroundColor','red');
                    row=[find(checkF);find(checkF)];
                    col=[4*ones(size(find(checkF)));5*ones(size(find(checkF)))];
                    addStyle(this.EvalparamTable,s,'cell',vertcat([row,col]));
                end

                if any(check)||any(checkWeight)||any(checkGoal)||...
                    any(checkF)||any(checkF1positive)||...
                    any(checkF2positive)||any(checkNaN(:))
                    isvalid=false;
                else
                    isvalid=true;

                end
            end
        end

        function initializeTable(this)
            ParameterSelections={'S11','S21','S12','S22'};
            ComparisonSelections={'<','>'};
            this.EvalparamTable=uitable(this.gridOverall,...
            'ColumnName',this.STATIC_TABLE_HEADERS,...
            'RowName',{},...
            'ColumnEditable',...
            [true,true,true,true,true,true,true,false,false,false],...
            'ColumnFormat',...
            {ParameterSelections,ComparisonSelections,'numeric',...
            'numeric','numeric','numeric','logical','char','numeric','numeric'},...
            'CellEditCallback',@(h,e)this.checkPanel(false),...
            'CellSelectionCallback',@(h,e)this.updateSelectedCell(e),...
            'Data',cell(0,this.CIRC_PERF_IDX-1),...
            'Visible',matlab.lang.OnOffSwitchState.off);
            this.EvalparamTable.Layout.Column=1;
            this.EvalparamTable.Layout.Row=2;

            this.GreyLabel=uilabel(this.gridOverall,'Text',...
            getString(message('rf:matchingnetworkgenerator:ConstraintsBannerUIFigure')),...
            'FontSize',20,'WordWrap','on','FontColor',[0.5,0.5,0.5],...
            'HorizontalAlignment','center');
            this.GreyLabel.Layout.Column=1;
            this.GreyLabel.Layout.Row=2;
        end
    end


    methods(Access=public)
        function delete(this)
            delete(this.EvalparamTable);
        end

        function closeNewSession(this)
            this.Figure.WindowStyle='normal';
            delete(this.Figure);
        end

        function setConstraints(this)

            isvalid=checkPanel(this,true);



            if isvalid
                this.RawTable=this.EvalparamTable.Data;
                dataT=this.EvalparamTable.Data;
                this.notify('EvalparamView',rf.internal.apps.matchnet.ArbitraryEventData(dataT));
                closeNewSession(this)

                for editedRowIndex=1:size(dataT,1)
                    if dataT{editedRowIndex,7}==false
                        data2.EvalparamIndex=1;
                        this.notify('EvalparamDeletedUI',rf.internal.apps.matchnet.ArbitraryEventData(data2));
                    end
                end
                counter=0;
                for editedRowIndex=1:size(dataT,1)
                    if dataT{editedRowIndex,7}==true
                        freqband={this.FREQUENCY_SCALAR*[dataT{editedRowIndex,4:5}]};
                        evpm=[dataT(editedRowIndex,1:3),freqband,dataT(editedRowIndex,6:7)];
                        counter=counter+1;
                        data.EvalparamIndex=counter;
                        data.NewEvalparam=evpm;
                        this.notify('EvalparamEditedUI',rf.internal.apps.matchnet.ArbitraryEventData(data));
                    end
                end

                for editedRowIndex=size(dataT,1)+1:this.TotalRows
                    data1.EvalparamIndex=editedRowIndex;
                    this.notify('EvalparamDeletedUI',rf.internal.apps.matchnet.ArbitraryEventData(data1));
                end
            end
        end
    end
end
