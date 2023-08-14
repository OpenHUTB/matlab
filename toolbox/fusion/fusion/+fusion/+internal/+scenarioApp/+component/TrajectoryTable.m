classdef TrajectoryTable<fusion.internal.scenarioApp.component.BaseComponent
    properties
        TableCellSelectionCallback=''
        TableCellEditCallback=''
    end

    properties(SetAccess=private)
MainPanel
TablePanel
Table
    end

    properties(Constant,Hidden)
        HighlightColor=[0.3010,0.7450,0.9330];
    end

    methods
        function this=TrajectoryTable(varargin)
            this@fusion.internal.scenarioApp.component.BaseComponent(varargin{:});
            createTable(this);
            createCallbacks(this);
            update(this,[],0);

            this.TableCellSelectionCallback=this.Application.initCallback(@this.onTableCellSelection);
            this.TableCellEditCallback=this.Application.initCallback(@this.onTableCellEdit);
        end

        function setVisibility(this,state)
            this.Figure.Visible=state;
            this.Table.Visible=state;
        end

        function update(this,traj,state,currentWaypoint)
            if~isempty(traj)
                tableData=horzcat(traj.TimeOfArrival,...
                traj.Position.*[1,1,-1],...
                traj.Course,...
                traj.GroundSpeed,...
                traj.ClimbRate,...
                traj.Roll,...
                traj.Pitch,...
                traj.Yaw);

                tableData=[round(tableData(:,1),3),round(tableData(:,2:end),2)];
                if state
                    tableColumnEditable=horzcat(...
                    ~traj.AutoTime,...
                    true(1,3),...
                    ~[traj.AutoCourse,traj.AutoGroundSpeed,traj.AutoClimbRate],...
                    ~traj.AutoBank&~traj.AutoPitch,...
                    ~traj.AutoBank&~traj.AutoPitch,...
                    ~traj.AutoBank&~traj.AutoPitch);
                else
                    tableColumnEditable=false(1,10);
                end
                n=length(traj.TimeOfArrival);
                tableBackgroundColors=ones(n,3);
                if currentWaypoint>0&&currentWaypoint<=n
                    tableBackgroundColors(currentWaypoint,:)=this.HighlightColor;
                end
            else
                tableData=nan(0,10);
                tableColumnEditable=false(1,10);
                tableBackgroundColors=[1,1,1];
            end



            if~isequal(this.Table.Data,tableData)
                this.Table.Data=tableData;
            end
            this.Table.ColumnEditable=tableColumnEditable;
            this.Table.BackgroundColor=tableBackgroundColors;
        end

        function tag=getTag(~)
            tag='TrajectoryTable';
        end
    end

    methods(Access=protected)
        function fig=createFigure(this,varargin)
            fig=createFigure@fusion.internal.scenarioApp.component.BaseComponent(this,varargin{:});
        end
    end

    methods(Access=private)
        function createTable(this)
            columnNames=cellfun(@(entry)msgString(this,entry),...
            {'Time','X','Y','Z','Course','GroundSpeed','ClimbRate','Roll','Pitch','Yaw'},...
            'UniformOutput',false);

            this.Table=uitable(this.Figure,...
            'Data',nan(0,10),...
            'ColumnName',columnNames,...
            'Units','normalized',...
            'OuterPosition',[0,0,1,1],...
            'Tag','scenariocanvas.table',...
            'Visible','off');
        end

        function createCallbacks(this)
            this.Table.CellEditCallback=@(src,evt)onTableCellEditCallback(this,src,evt);
            this.Table.CellSelectionCallback=@(src,evt)onTableCellSelectionCallback(this,src,evt);
        end
    end

    methods
        function onTableCellSelection(this,~,evt)
            currentPlatform=getCurrentPlatform(this.Application);
            if~isempty(currentPlatform)&&~isempty(evt.Indices)
                traj=currentPlatform.TrajectorySpecification;
                idx=evt.Indices(1);
                if idx<=numel(traj.TimeOfArrival)
                    setCurrentWaypoint(this.Application,idx);
                end
            end
        end

        function onTableCellEdit(this,~,evt)
            currentPlatform=getCurrentPlatform(this.Application);
            if~isempty(currentPlatform)
                traj=copy(currentPlatform.TrajectorySpecification);
                idx=evt.Indices(1);
                col=evt.Indices(2);
                value=evt.NewData;
                legalEdit=false;
                newIdx=idx;
                if isfinite(value)
                    if col==1&&value>=0
                        newIdx=reassignTimeIndex(traj,idx,value);
                        legalEdit=true;
                    elseif 2<=col&&col<4
                        traj.Position(idx,col-1)=value;
                        autoAdjust(traj);
                        legalEdit=true;
                    elseif col==4
                        traj.Position(idx,col-1)=-value;
                        autoAdjust(traj);
                        legalEdit=true;
                    elseif col==5
                        traj.Course(idx)=value;
                        autoAdjust(traj);
                        legalEdit=true;
                    elseif col==6&&value>=0
                        traj.GroundSpeed(idx)=value;
                        if hasValidGroundSpeed(traj)
                            autoAdjust(traj);
                            legalEdit=true;
                        end
                    elseif col==7
                        traj.ClimbRate(idx)=value;
                        autoAdjust(traj);
                        legalEdit=true;
                    elseif col==8
                        traj.Roll(idx)=value;
                        legalEdit=true;
                    elseif col==9
                        traj.Pitch(idx)=value;
                        legalEdit=true;
                    elseif col==10
                        traj.Yaw(idx)=value;
                        legalEdit=true;
                    end
                end

                if legalEdit
                    changeTrajectory(this.Application,newIdx,traj,idx,currentPlatform.TrajectorySpecification);
                else
                    currentWaypoint=getCurrentWaypoint(this.Application);
                    update(this,currentPlatform.TrajectorySpecification,this.Application.TableEnable,currentWaypoint);
                end
            end
        end

        function onTableCellEditCallback(this,src,evt)
            this.TableCellEditCallback(src,evt);
        end

        function onTableCellSelectionCallback(this,src,evt)
            this.TableCellSelectionCallback(src,evt);
        end
    end
end