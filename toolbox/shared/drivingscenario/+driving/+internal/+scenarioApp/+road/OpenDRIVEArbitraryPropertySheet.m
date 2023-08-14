classdef OpenDRIVEArbitraryPropertySheet<driving.internal.scenarioApp.road.PropertySheet&...
    driving.internal.scenarioApp.road.OpenDRIVELanesWidgets



    properties
        ShowRoadCenters=false
    end

    properties(Hidden)
hTable
hWidth
hShowRoadCenters
hAddRoadCenters
hBankAngle
        MinWidth=0;
    end

    methods
        function this=OpenDRIVEArbitraryPropertySheet(varargin)
            this@driving.internal.scenarioApp.road.PropertySheet(varargin{:});
        end

        function w=getLabelMinimumWidth(this)
            w=this.MinWidth;
        end

        function[id,str]=validateDoubleProperty(this,name,value)
            id=[];
            str='';
            if strcmp(name,'Width')
                if value<=0||isnan(value)
                    id='driving:scenarioApp:BadRoadWidth';
                    str=getString(message(id));
                    return;
                else
                    if this.Dialog.InteractiveMode





                        canvas=this.Dialog.Application.ScenarioView;
                        spec.Centers=canvas.Waypoints;
                        spec.BankAngle=canvas.CurrentRoad.BankAngle;
                    else
                        spec=getSpecification(this);
                    end
                    if isempty(spec.Centers)
                        me=[];
                    else
                        me=driving.internal.scenarioApp.road.OpenDRIVEArbitrary.validateCenters(spec.Centers,value,spec.BankAngle);
                    end
                    if~isempty(me)
                        id=me.identifier;
                        str=me.message;
                        return
                    end
                end
            elseif strcmp(name,'BankAngle')&&~isscalar(value)
                spec=getSpecification(this);
                if numel(value)~=size(spec.Centers,1)
                    id='driving:scenarioApp:BadBankAngleSize';
                    str=getString(message(id));
                    return;
                end
            end
        end

        function updateEditPoints(this)
            canvas=this.Dialog.Application.ScenarioView;

            if strncmp(canvas.InteractionMode,'addRoad',7)
                tableData=getTableData(canvas);
            else
                if this.Dialog.InteractiveMode
                    tableData=getTableData(canvas);
                else
                    road=getSpecification(this);

                    tableData=road.Centers;
                end
            end
            this.hTable.Data=tableData;
        end

        function update(this)



            road=getSpecification(this);
            update@driving.internal.scenarioApp.road.OpenDRIVELanesWidgets(this);

            if isempty(road)
                set(this.hTable,'Data',[],...
                'RowName','numbered');
                set(this.hWidth,...
                'String','',...
                'Enable','off');
                set(this.hBankAngle,...
                'String','',...
                'Enable','off');
                this.hAddRoadCenters.Enable='off';

                return;
            end

            app=this.Dialog.Application;

            canvas=app.ScenarioView;


            mode=canvas.InteractionMode;

            enable=matlabshared.application.logicalToOnOff(this.Dialog.Enabled);
            if strcmp(enable,'on')
                enable=IsEnableLanes(this,road);
                if strcmp(enable,'off')&&strcmp(canvas.PreviousMousePointer,'circle')||strcmp(canvas.PreviousMousePointer,'arrow')
                    canvas.RoadEditPointDragPvPairs=canvas.RoadEditPointCache;
                end
            end

            if strncmp(mode,'addRoad',7)
                nWaypoints=size(canvas.Waypoints,1);
                if strcmp(mode,'addRoad')
                    if nWaypoints>1
                        buttonEnab=enable;
                    else
                        buttonEnab='off';
                    end
                else
                    if nWaypoints==size(road.Centers,1)
                        buttonEnab='off';
                    else
                        buttonEnab='on';
                    end
                end
                icon='confirm16';
                tooltip=getString(message('driving:scenarioApp:AcceptRoadCentersDescription'));
                if nWaypoints==0
                    rowName=' ';
                else
                    rowName=1:nWaypoints;
                end
                tableData=getTableData(canvas);
            else
                buttonEnab=enable;
                rowName='numbered';
                icon='add16';
                tooltip=getString(message('driving:scenarioApp:AddRoadCentersDescription'));
                if this.Dialog.InteractiveMode
                    tableData=getTableData(canvas);
                else
                    tableData=road.Centers;
                end
            end

            set(this.hAddRoadCenters,...
            'CData',getIcon(app,icon),...
            'Enable',buttonEnab,...
            'TooltipString',tooltip);


            set(this.hWidth,...
            'String',road.Width,...
            'Enable',enable);
            set(this.hBankAngle,...
            'String',mat2str(road.BankAngle),...
            'Enable','on');

            set(this.hTable,...
            'Data',tableData,...
            'RowName',rowName,...
            'Enable',enable);
        end

        function enable=IsEnableLanes(~,roadSpec)
            enable='on';
            ls=roadSpec.Lanes;
            if~isempty(ls)
                if numel(ls)>1||ls.IsAsymmetric
                    enable='off';
                else
                    isVariableMarkers=false;
                    for lmndx=1:numel(ls.Marking)
                        if numel(ls.Marking(lmndx).lm)>1
                            isVariableMarkers=true;
                            break;
                        end
                    end
                    if isVariableMarkers
                        enable='off';
                    end
                end
            end
        end

        function onInteractiveMode(this)
            if~this.ShowRoadCenters
                this.ShowRoadCenters=false;
                setToggleValue(this,'ShowRoadCenters',true);
                updateLayout(this);
            end
        end

        function onRoadChanged(this)
            this.SelectedMarking=1;
        end
    end

    methods(Hidden)
        function roadCentersCallback(this,hTable,~)
            hApp=this.Dialog.Application;
            data=hTable.Data;
            spec=getSpecification(this);

            if isempty(spec)
                committedCenters=[];
            else
                committedCenters=spec.Centers;
            end
            if this.Dialog.InteractiveMode
                nCommitted=size(committedCenters,1);
                uncommitted=data(nCommitted+1:end,:);
                data(nCommitted+1:end,:)=[];
                data=cell2mat(data);
            end




            if any(isnan(data(:)))||any(isinf(data(:)))||~isempty(data)&&all(all(diff(data,1)==0))
                update(this);
                str=getErrorMessageString(this,'RoadCenters');
                errorMessage(this,str,'driving:scenarioApp:InvalidRoadCenters');
                return;
            end

            roadCreationStarting(hApp);
            if size(data,1)>1
                me=spec.validateCenters(data);
                if~isempty(me)
                    update(this);
                    errorMessage(this,me.message,me.identifier);
                    roadCreationFinished(hApp,true);
                    return;
                end
            end

            if~isempty(spec)&&~isequal(committedCenters,data)&&size(data,1)>1
                applyEdit(hApp,createEdit(this,'Centers',data));
                setDirty(hApp);
            end
            roadCreationFinished(hApp);
            if this.Dialog.InteractiveMode

                canvas=hApp.ScenarioView;
                waypoints=canvas.Waypoints;
                waypoints(1:nCommitted,:)=data;

                if ischar(uncommitted{end,1})
                    uncommitted{end,1}=str2double(uncommitted{end,1});
                    uncommitted{end,2}=str2double(uncommitted{end,2});
                end

                waypoints=[waypoints(1:nCommitted,:);cell2mat(uncommitted)];



                shouldUpdate=true;
                if any(isinf(waypoints(:)))||any(any(isnan(waypoints(1:end-1,:))))
                    update(this);
                    return;
                end
                if~any(isnan(waypoints(end,:)))&&size(waypoints,1)>1
                    me=driving.internal.scenarioApp.road.OpenDRIVEArbitrary.validateCenters(waypoints);
                    if~isempty(me)
                        hTable.Data=getappdata(hTable,'LastGoodData');
                        errorMessage(this,me.message,me.identifier);
                        return;
                    end
                end
                if isnan(waypoints(end,1))||isnan(waypoints(end,2))
                    shouldUpdate=false;
                    waypoints(end,:)=[];
                end
                setappdata(hTable,'LastGoodData',hTable.Data);
                canvas.Waypoints=waypoints;
                updateWaypointLine(canvas);
                updateCursorLine(canvas,[]);
                if shouldUpdate
                    update(this);
                end
            end
        end

        function addRoadCentersCallback(this,~,~)
            hApp=this.Dialog.Application;
            if this.Dialog.InteractiveMode
                commitWaypoints(hApp.ScenarioView);
            else

                roadAdder=getRoadAdder(hApp);
                roadAdder.addViaWaypoints(this.Dialog.SpecificationIndex);
            end
        end

        function updateLayout(this)
            layout=this.Layout;
            table=this.hTable;
            offset=0;

            vw=[0,0,0,1];
            lanesRow=4;
            tableRow=5;
            updateLayout@driving.internal.scenarioApp.road.OpenDRIVELanesWidgets(this,lanesRow);

            if this.ShowLanes
                vw=[0,vw];
                offset=1;
            end


            if this.ShowRoadCenters
                if~layout.contains(table)
                    layout.insert('row',tableRow+offset);
                    layout.add(table,tableRow+offset,[1,2]);
                end
                table.Visible='on';
                vw=[0,vw];
            else
                table.Visible='off';
                if layout.contains(table)
                    layout.remove(table);
                    layout.clean;
                end
            end
            layout.VerticalWeights=vw;
            matlabshared.application.setToggleCData(this.hShowRoadCenters);
        end
    end

    methods(Access=protected)
        function createWidgets(this)


            p=this.Panel;
            p.Tag='OpenDRIVERoadTab';
            hWidthLabel=createLabelEditPair(this,p,'Width');


            [hBankAngleLabel,this.hBankAngle]=createLabelEditPair(this,p,'BankAngle',...
            'TooltipString',getString(message('driving:scenarioApp:BankAngleDescription')));


            createWidgets@driving.internal.scenarioApp.road.OpenDRIVELanesWidgets(this);

            createToggle(this,p,'ShowRoadCenters');


            icons=getIcon(this.Dialog);


            createPushButton(this,p,'AddRoadCenters',@this.addRoadCentersCallback,...
            'CData',icons.add16,...
            'TooltipString',getString(message('driving:scenarioApp:AddRoadCentersDescription')));


            columnNames={getString(message('driving:scenarioApp:XColumnName')),...
            getString(message('driving:scenarioApp:YColumnName')),...
            getString(message('driving:scenarioApp:ZColumnName'))};

            this.hTable=uitable('Parent',p,...
            'ColumnWidth','auto',...
            'Tag','RoadCentersTable',...
            'Visible','off',...
            'ColumnName',columnNames,...
            'CellEditCallback',@this.roadCentersCallback,...
            'ColumnEditable',true);


            layout=matlabshared.application.layout.GridBagLayout(p,...
            'VerticalWeights',[0,0,0,1],...
            'HorizontalWeights',[0,1],...
            'VerticalGap',3);

            this.Layout=layout;
            labelInset=3;
            labelHeight=20-labelInset;
            rowCount=1;
            labelWidth=layout.getMinimumWidth([hWidthLabel,hBankAngleLabel]);
            this.MinWidth=labelWidth;
            layout.add(hWidthLabel,rowCount,1,...
            'TopInset',labelInset,...
            'Anchor','West',...
            'MinimumHeight',labelHeight,...
            'MinimumWidth',labelWidth);
            layout.add(this.hWidth,rowCount,2,'Fill','Both');
            rowCount=rowCount+1;

            layout.add(hBankAngleLabel,rowCount,1,...
            'TopInset',labelInset,...
            'Anchor','West',...
            'MinimumHeight',labelHeight,...
            'MinimumWidth',labelWidth);
            layout.add(this.hBankAngle,rowCount,2,'Fill','Both');
            rowCount=rowCount+1;


            addLanesWidgetsToLayout(this,rowCount);
            rowCount=rowCount+1;

            layout.add(this.hShowRoadCenters,rowCount,1,...
            'TopInset',labelInset,...
            'Anchor','NorthWest',...
            'Fill','Horizontal',...
            'MinimumWidth',layout.getMinimumWidth(this.hShowRoadCenters)+20);
            layout.add(this.hAddRoadCenters,rowCount,2,...
            'Anchor','NorthEast',...
            'MinimumHeight',21,...
            'MinimumWidth',21);

            setConstraints(layout,this.hTable,...
            'Fill','Both',...
            'MinimumWidth',120,...
            'MinimumHeight',100);
        end
    end
end


