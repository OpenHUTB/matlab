





classdef ConstraintsPanel<handle



    properties(Access=public)
        gridOverall(1,1)matlab.ui.container.GridLayout
        EvalparamTable(1,1)matlab.ui.control.Table
selectedCircuits
        Figure matlab.ui.Figure

        GreyLabel(1,1)matlab.ui.control.Label
    end

    properties(Access=protected,Constant)
        CIRC_PERF_IDX=8
        STATIC_TABLE_HEADERS={'abs(Parameter)','Condition',...
        sprintf('Goal\n(dB)'),sprintf('Min Frequency\n(GHz)'),...
        sprintf('Max Frequency\n(GHz)'),'Weight','Active'}
        DEFAULT_EVALPARAM_LINE={'S21','>',-3,1,1.125,0,false}
    end

    properties(Constant)

        FREQUENCY_SCALAR=1e9
    end

    events
EvalparamAdded
EvalparamEdited
EvalparamDeleted

CircuitDataRequested
    end

    methods(Access=public)
        function this=ConstraintsPanel(parent)
            this.Figure=parent;
            this.initializeUI();
        end
    end


    methods(Access=public)

        function updatePerformanceData(this,evtdata)
            if isempty(this.EvalparamTable.Data)
                return
            end

            this.gridOverall.Visible=matlab.lang.OnOffSwitchState.off;
            if(length(this.EvalparamTable.Data(1,:))>=this.CIRC_PERF_IDX)
                this.EvalparamTable.Data(:,this.CIRC_PERF_IDX:end)=[];
            end

            circuitNames=evtdata.data.CircuitNames;


            if isempty(circuitNames)
                this.gridOverall.Visible=matlab.lang.OnOffSwitchState.on;
                return
            end

            for j=1:length(this.selectedCircuits)
                idx=find(strcmp(this.selectedCircuits{j},circuitNames),1);
                if(isempty(idx))
                    continue
                end
                activecol=this.EvalparamTable.Data(:,7);
                perfTestsFailed=evtdata.data.CircuitFailedPerformanceTests{idx};
                tempcol=ones(length(this.EvalparamTable.Data(:,1)),1);
                if~isempty(perfTestsFailed)&&any(cell2mat(activecol))
                    tempcol(arrayfun(@(x)max(find(cell2mat(activecol),x)),perfTestsFailed))=0;
                end
                colflag=cell(size(tempcol));
                for k=1:numel(tempcol)
                    if~activecol{k}
                        colflag(k)={'-'};
                    else
                        if tempcol(k)
                            colflag(k)={getString(message('rf:matchingnetworkgenerator:ConstraintsPass'))};
                        else
                            colflag(k)={getString(message('rf:matchingnetworkgenerator:ConstraintsFail'))};
                        end
                    end
                end
                this.EvalparamTable.Data(:,this.CIRC_PERF_IDX+j-1)=colflag;
            end
            this.gridOverall.Visible=matlab.lang.OnOffSwitchState.on;
        end


        function newCircuitsSelected(this,evtdata)

            this.selectedCircuits=evtdata.data.CircuitNames;
            cktnames=reshape(evtdata.data.CircuitNames,1,[]);
            this.EvalparamTable.ColumnName=[this.STATIC_TABLE_HEADERS,cktnames];
            data.RequestedCircuits=this.selectedCircuits;
            this.notify('CircuitDataRequested',rf.internal.apps.matchnet.ArbitraryEventData(data));
        end

        function CBK_ConstraintsPanel(this,e)
            this.EvalparamTable.Data=e.data;
            this.EvalparamTable.Visible=matlab.lang.OnOffSwitchState.on;
            this.GreyLabel.Visible=matlab.lang.OnOffSwitchState.off;
        end







        function destroyTable(this)
            this.EvalparamTable.Data={};
        end
    end

    methods(Access=protected)
        function initializeUI(this)



            this.gridOverall=uigridlayout(this.Figure,[1,1],...
            'RowSpacing',0,'Visible',0);

            this.initializeTable();
        end

        function initializeTable(this)
            ParameterSelections={'S11','S21','S12','S22'};
            ComparisonSelections={'<','>'};
            this.EvalparamTable=uitable(this.gridOverall,...
            'ColumnName',this.STATIC_TABLE_HEADERS,...
            'RowName',{},...
            'ColumnFormat',...
            {ParameterSelections,ComparisonSelections,'numeric',...
            'numeric','numeric','numeric','logical','char','numeric','numeric'},...
            'Data',cell(0,this.CIRC_PERF_IDX-1),...
            'Visible',matlab.lang.OnOffSwitchState.off);
            this.EvalparamTable.Layout.Column=1;
            this.EvalparamTable.Layout.Row=1;

            this.GreyLabel=uilabel(this.gridOverall,'Text',...
            getString(message('rf:matchingnetworkgenerator:ConstraintsBannerPanel')),...
            'FontSize',20,'WordWrap','on','FontColor',[0.5,0.5,0.5],...
            'HorizontalAlignment','center');
            this.GreyLabel.Layout.Column=1;
            this.GreyLabel.Layout.Row=1;
        end
    end


    methods(Access=public)
        function delete(this)

            delete(this.EvalparamTable);
        end
    end
end
