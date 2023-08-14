classdef ArbitraryPropertySheet<driving.internal.scenarioApp.road.PropertySheet&...
    driving.internal.scenarioApp.road.LanesWidgets

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
hBankAngleLabel
    end

    methods
        function this=ArbitraryPropertySheet(varargin)
            this@driving.internal.scenarioApp.road.PropertySheet(varargin{:});
        end

        function w=getLabelMinimumWidth(this)
            w=this.MinWidth;
        end

        function[id,str]=validateDoubleProperty(this,name,value)
            id=[];
            str='';
            if strcmp(name,'Width')
                if numel(value)~=1||value<=0||isnan(value)
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
                        me=driving.internal.scenarioApp.road.Arbitrary.validateCenters(spec.Centers,value,spec.BankAngle);
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

        function zValue=getAddRoadCentersZValue(this)
            data=this.hTable.Data;
            if iscell(data)
                zValue=data{end,3};
            else
                zValue=data(end,3);
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
            update@driving.internal.scenarioApp.road.LanesWidgets(this);

            if isempty(road)
                this.MultiLaneSpecs=false;
                this.MultipleChecked=false;
                set(this.hTable,'Data',[],...
                'RowName','numbered');
                set([this.hWidth,this.hBankAngle],...
                'String','','Enable','off');
                this.hAddRoadCenters.Enable='off';
                return;
            end

            app=this.Dialog.Application;
            canvas=app.ScenarioView;
            mode=canvas.InteractionMode;

            enable=matlabshared.application.logicalToOnOff(this.Dialog.Enabled);
            if strncmp(mode,'addRoad',7)
                setDefaultProperties(this);
                nWaypoints=size(canvas.Waypoints,1);
                if strcmp(mode,'addRoad')
                    updateLayout(this);
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
                    if~isempty(road.pHeading)
                        if size(road.pHeading,1)==size(tableData,1)
                            heading=road.pHeading;
                            tableData=[tableData,heading];
                        end
                    end
                end
            end
            set(this.hAddRoadCenters,...
            'CData',getIcon(app,icon),...
            'Enable',buttonEnab,...
            'TooltipString',tooltip);



            widthEnable=enable;
            if~isempty(road.Lanes)
                widthEnable='off';
            end
            set(this.hWidth,...
            'String',road.Width(1),...
            'Enable',widthEnable);
            set(this.hBankAngle,...
            'String',mat2str(road.BankAngle),...
            'Enable',enable);
            set(this.hTable,...
            'Data',tableData,...
            'RowName',rowName,...
            'Enable',enable);
            if~this.ShowRoadCenters
                this.hBankAngle.Visible='off';
                this.hBankAngleLabel.Visible='off';
            end
        end

        function onInteractiveMode(this)
            if~this.ShowRoadCenters
                this.ShowRoadCenters=true;
                setToggleValue(this,'ShowRoadCenters',true);
                updateLayout(this);
            end
        end

        function onRoadChanged(this)
            this.SelectedMarking=1;
            this.SelectedType=1;
            this.MultipleChecked=false;
            this.SelectedLane=1;
            this.MultiIndex=1;
            this.SelectedMultiMarking=1;
            this.SelectedRoadSegment=1;
            this.SelectedConnector=1;
            updateLayout(this);
        end
    end

    methods(Hidden)
        function roadCentersCallback(this,hTable,~)
            hApp=this.Dialog.Application;
            data=hTable.Data;
            spec=getSpecification(this);

            if isempty(spec)
                committedCenters=[];
                committedpHeading=[];
            else
                committedCenters=spec.Centers;
                if isempty(spec.pHeading)
                    committedpHeading=nan(size(committedCenters,1),1);
                else
                    committedpHeading=spec.pHeading;
                end
            end
            if this.Dialog.InteractiveMode
                nCommitted=size(committedCenters,1);
                uncommitted=data(nCommitted+1:end,:);
                data(nCommitted+1:end,:)=[];
                data=cell2mat(data);
            end

            if~isreal(data)
                update(this);
                id='driving:scenarioApp:ImagRoadCentersError';
                errorMessage(this,getString(message(id)),id);
                return;
            end




            if~isempty(data)
                roadCenters=data(:,1:3);
            else
                roadCenters=[];
            end

            if any(isnan(roadCenters(:)))||any(isinf(roadCenters(:)))||~isempty(roadCenters)&&all(all(diff(roadCenters,1)==0))
                update(this);
                str=getErrorMessageString(this,'RoadCenters');
                errorMessage(this,str,'driving:scenarioApp:InvalidRoadCenters');
                return;
            end
            if size(data,2)==4
                heading=data(:,4);
                if any(isinf(heading))
                    update(this);
                    str=getErrorMessageString(this,'Heading');
                    errorMessage(this,str,'driving:scenarioApp:BadHeading');
                    return;
                end
            end

            roadCreationStarting(hApp);
            if size(roadCenters,1)>1
                me=spec.validateCenters(roadCenters);
                if~isempty(me)
                    update(this);
                    errorMessage(this,me.message,me.identifier);
                    roadCreationFinished(hApp,true);
                    return;
                end
            end
            if~isempty(spec)&&~isequal(committedCenters,roadCenters)&&size(roadCenters,1)>1
                applyEdit(hApp,createEdit(this,'Centers',roadCenters));
                setDirty(hApp);
            end

            if size(data,2)==4
                if~isempty(spec)&&~isequal(committedpHeading,data(:,4))
                    committedHeading=spec.Heading;
                    if isempty(committedHeading)
                        committedHeading=nan(size(roadCenters,1),1);
                    end
                    diff1=abs(committedpHeading-data(:,4))>1e-4;
                    diff2=isnan(abs(committedpHeading-data(:,4)));
                    idxModified=diff1|diff2;
                    committedHeading(idxModified,:)=data(idxModified,4);
                    if size(roadCenters,1)>1
                        roadWidth=spec.Width;
                        bankAngle=spec.BankAngle;
                        me=spec.validateCenters(roadCenters,roadWidth,bankAngle,committedHeading);
                        if~isempty(me)
                            update(this);
                            errorMessage(this,me.message,me.identifier);
                            roadCreationFinished(hApp,true);
                            return;
                        end
                    end
                    applyEdit(hApp,createEdit(this,'Heading',committedHeading));
                    setDirty(hApp);
                end
            end

            roadCreationFinished(hApp);
            if this.Dialog.InteractiveMode

                canvas=hApp.ScenarioView;
                waypoints=canvas.Waypoints;
                waypoints(1:nCommitted,:)=roadCenters;

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
                    me=driving.internal.scenarioApp.road.Arbitrary.validateCenters(waypoints);
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

        function clearMLSPanels(this)
            layout=this.Layout;
            segmentPanel=this.hSegmentsPanel;
            connectorPanel=this.hConnectorPanel;
            for i=1:size(connectorPanel.Children,1)
                connectorPanel.Children(i).Visible='off';
                connectorPanel.Children(i).Enable='off';
            end
            for i=1:size(segmentPanel.Children,1)
                segmentPanel.Children(i).Visible='off';
                segmentPanel.Children(i).Enable='off';
            end
            segmentPanel.Enable='off';
            segmentPanel.Visible='off';
            connectorPanel.Visible='off';
            connectorPanel.Enable='off';
            layout.remove(segmentPanel);
            layout.remove(connectorPanel);
            this.hRoadSegmentRange.Visible='off';
            this.hRoadSegments.Visible='off';
            this.hShowLaneConnector.Visible='off';
            this.hSelectedConnector.Visible='off';
            this.hSelectedConnector.Enable='off';
            layout.remove(this.hShowLaneConnector);
            layout.remove(this.hSelectedConnector);
            layout.clean;
            this.MultiLaneSpecs=false;
        end

        function updateLayout(this)
            layout=this.Layout;
            table=this.hTable;
            offset=0;

            vw=[0,0,0,0,1];
            lanesRow=4;
            tableRow=6;

            segmentPanel=this.hSegmentsPanel;
            connectorPanel=this.hConnectorPanel;

            if this.MultiLaneSpecs

                if~layout.contains(segmentPanel)
                    insert(layout,'row',3);
                    [~,h]=getMinimumSize(this.SegmentsLayout);
                    layout.add(segmentPanel,3,[1,3],...
                    'Fill','Horizontal',...
                    'TopInset',-3,...
                    'MinimumHeight',h);
                    segmentPanel.Visible='on';
                    segmentPanel.Enable='on';
                    for i=1:size(segmentPanel.Children,1)
                        segmentPanel.Children(i).Visible='on';
                        segmentPanel.Children(i).Enable='on';
                    end
                end
                if this.ShowLanes
                    lanesRow=5;
                end
                toggleConnectorRowCount=lanesRow+1;

                if~layout.contains(this.hShowLaneConnector)
                    insert(layout,'row',toggleConnectorRowCount);
                    layout.add(this.hShowLaneConnector,toggleConnectorRowCount,1,...
                    'Fill','Horizontal');
                    layout.add(this.hSelectedConnector,toggleConnectorRowCount,[2,3],'Fill',...
                    'Horizontal');
                end
                set([this.hShowLaneConnector,this.hSelectedConnector],'Visible','on','Enable','on');
                vw=[0,0,vw];
                laneConnectivityRow=toggleConnectorRowCount;

                if this.ShowLaneConnector
                    if~layout.contains(connectorPanel)
                        laneConnectivityRow=toggleConnectorRowCount+1;
                        insert(layout,'row',laneConnectivityRow);

                        layout.add(connectorPanel,laneConnectivityRow,[1,3],...
                        'TopInset',-1,...
                        'LeftInset',5);
                        connectorPanel.Visible='on';
                        connectorPanel.Enable='on';
                        for i=1:size(connectorPanel.Children,1)
                            connectorPanel.Children(i).Visible='on';
                            connectorPanel.Children(i).Enable='on';
                        end
                    end
                elseif layout.contains(connectorPanel)
                    connectorPanel.Visible='off';
                    layout.remove(connectorPanel);
                    layout.clean;
                end
                tableRow=laneConnectivityRow;
                if this.ShowRoadCenters
                    if this.ShowLanes&&this.ShowLaneConnector
                        vw=[0,vw];
                        tableRow=laneConnectivityRow+3;
                    elseif~this.ShowLanes&&this.ShowLaneConnector
                        vw=[0,vw];
                        tableRow=laneConnectivityRow+4;
                    elseif this.ShowLanes&&~this.ShowLaneConnector
                        tableRow=laneConnectivityRow+2;
                    elseif~this.ShowLanes&&~this.ShowLaneConnector
                        tableRow=laneConnectivityRow+3;
                    end
                else
                    if(this.ShowLanes&&this.ShowLaneConnector)||(~this.ShowLanes&&this.ShowLaneConnector)
                        vw=[0,vw];
                    end
                end
            else
                clearMLSPanels(this);
            end
            updateLayout@driving.internal.scenarioApp.road.LanesWidgets(this,lanesRow);
            if this.ShowLanes
                vw=[0,vw];
                offset=1;
            end

            if this.ShowRoadCenters
                this.hBankAngleLabel.Visible='on';
                this.hBankAngle.Visible='on';
                if~layout.contains(table)
                    layout.insert('row',tableRow+offset);
                    layout.add(table,tableRow+offset,[1,3]);
                end
                table.Visible='on';
                vw=[0,vw];
            else
                this.hBankAngle.Visible='off';
                this.hBankAngleLabel.Visible='off';
                table.Visible='off';
                if layout.contains(table)
                    layout.remove(table);
                    layout.clean;
                end
            end
            layout.VerticalWeights=vw;
            matlabshared.application.setToggleCData(this.hShowRoadCenters);
            matlabshared.application.setToggleCData(this.hShowLaneConnector);
        end
    end

    methods(Access=protected)
        function createWidgets(this)

            p=this.Panel;
            hWidthLabel=createLabelEditPair(this,p,'Width');


            this.hBankAngleLabel=createLabelEditPair(this,p,'BankAngle',...
            'TooltipString',getString(message('driving:scenarioApp:BankAngleDescription')));

            hNumRoadSegmentsLabel=createLabelEditPair(this,p,'NumRoadSegments',@this.numRoadSegmentsCallback);

            createWidgets@driving.internal.scenarioApp.road.LanesWidgets(this);

            createToggle(this,p,'ShowLaneConnector');

            createEditbox(this,p,'SelectedConnector',@this.SelectedConnectorCallback,'popupmenu',...
            'TooltipString',getString(message('driving:scenarioApp:ConnectorPositionDescription')));
            createToggle(this,p,'ShowRoadCenters');


            icons=getIcon(this.Dialog);


            createPushButton(this,p,'AddRoadCenters',@this.addRoadCentersCallback,...
            'CData',icons.add16,...
            'TooltipString',getString(message('driving:scenarioApp:AddRoadCentersDescription')));


            columnNames={getString(message('driving:scenarioApp:XColumnName')),...
            getString(message('driving:scenarioApp:YColumnName')),...
            getString(message('driving:scenarioApp:ZColumnName')),...
            getString(message('driving:scenarioApp:HeadingColumnName'))};

            this.hTable=uitable('Parent',p,...
            'ColumnWidth','auto',...
            'Tag','RoadCentersTable',...
            'Visible','off',...
            'ColumnName',columnNames,...
            'CellEditCallback',@this.roadCentersCallback,...
            'ColumnEditable',true);

            segmentsPanel=uipanel(p,...
            'Visible','off',...
            'AutoResizeChildren','off',...
            'Tag','segmentsPanel',...
            'BorderType','none');
            this.hSegmentsPanel=segmentsPanel;
            hRoadSegmentsLabel=createLabel(this,segmentsPanel,'RoadSegments');
            createEditbox(this,segmentsPanel,'RoadSegments',...
            @this.roadSegmentsCallback,'popupmenu');
            hRoadSegmentRangeLabel=createLabelEditPair(this,segmentsPanel,...
            'RoadSegmentRange',@this.roadSegmentRangeCallback);

            connectorPanel=uipanel(p,...
            'Visible','off',...
            'AutoResizeChildren','off',...
            'Tag','connectorPanel',...
            'BorderType','none');
            this.hConnectorPanel=connectorPanel;

            hConnectorPositionLabel=createLabel(this,p,'ConnectorPosition');
            createEditbox(this,connectorPanel,'ConnectorPosition',...
            @this.taperPositionCallback,'popupmenu');
            hConnectorShapeLabel=createLabel(this,p,'ConnectorShape');
            createEditbox(this,connectorPanel,'ConnectorShape',@this.taperShapeCallback,'popupmenu');
            hConnectorLengthLabel=createLabelEditPair(this,p,...
            'ConnectorLength',@this.taperLengthCallback,...
            'TooltipString',getString(message('driving:scenarioApp:ConnectorLengthDescription')));

            segmentsLayout=matlabshared.application.layout.GridBagLayout(segmentsPanel,...
            'HorizontalWeights',[0,1],...
            'VerticalGap',3);
            connectorLayout=matlabshared.application.layout.GridBagLayout(connectorPanel,...
            'VerticalGap',4,...
            'HorizontalGap',2);

            layout=matlabshared.application.layout.GridBagLayout(p,...
            'VerticalWeights',[0,0,0,1],...
            'HorizontalWeights',[0,1],...
            'VerticalGap',3);
            labelLeftInset=10;
            this.Layout=layout;
            labelInset=5;
            labelHeight=20-labelInset;
            controlHeight=labelHeight+6;
            labelBankAngleWidth=layout.getMinimumWidth(this.hBankAngleLabel);

            labelWidth=labelBankAngleWidth+30;
            segmentsLayout.add(hRoadSegmentRangeLabel,1,1,...
            'TopInset',labelInset,...
            'Anchor','West',...
            'MinimumHeight',labelHeight,...
            'MinimumWidth',labelWidth);
            segmentsLayout.add(this.hRoadSegmentRange,1,[2,3],...
            'MinimumHeight',controlHeight,...
            'Fill','Horizontal');

            segmentsLayout.add(hRoadSegmentsLabel,2,1,...
            'TopInset',labelInset,...
            'Anchor','West',...
            'MinimumHeight',labelHeight,...
            'MinimumWidth',labelWidth);
            segmentsLayout.add(this.hRoadSegments,2,[2,3],...
            'TopInset',labelInset,...
            'Fill','Horizontal');
            this.SegmentsLayout=segmentsLayout;




            connectorLayout.add(hConnectorShapeLabel,1,1,...
            'TopInset',2,...
            'Anchor','West',...
            'MinimumHeight',labelHeight,...
            'MinimumWidth',labelWidth,...
            'Fill','Horizontal');

            connectorLayout.add(hConnectorLengthLabel,1,2,...
            'TopInset',2,...
            'Anchor','West',...
            'MinimumHeight',labelHeight,...
            'MinimumWidth',labelWidth,...
            'Fill','Horizontal');

            connectorLayout.add(hConnectorPositionLabel,1,3,...
            'TopInset',2,...
            'Anchor','West',...
            'MinimumHeight',labelHeight,...
            'MinimumWidth',labelWidth,...
            'Fill','Horizontal');


            connectorLayout.add(this.hConnectorShape,2,1,'Fill','Horizontal');

            connectorLayout.add(this.hConnectorLength,2,2,'MinimumHeight',labelHeight+7,'Fill','Horizontal');

            connectorLayout.add(this.hConnectorPosition,2,3,'Fill','Horizontal');

            this.hConnectorPanel=connectorPanel;
            this.ConnectorLayout=connectorLayout;
            [~,h]=getMinimumSize(this.ConnectorLayout);
            layout.setConstraints(connectorPanel,...
            'RightInset',-5,...
            'Fill','Horizontal',...
            'Anchor','NorthWest',...
            'MinimumHeight',h);
            rowCount=1;
            this.MinWidth=labelWidth;
            layout.add(hWidthLabel,rowCount,1,...
            'TopInset',labelInset,...
            'Anchor','West',...
            'MinimumHeight',labelHeight,...
            'MinimumWidth',labelWidth);
            layout.add(this.hWidth,rowCount,[2,3],...
            'Fill','Horizontal');
            rowCount=rowCount+1;

            layout.add(hNumRoadSegmentsLabel,rowCount,1,...
            'TopInset',labelInset,...
            'Anchor','West',...
            'MinimumHeight',labelHeight+17,...
            'MinimumWidth',labelWidth);
            layout.add(this.hNumRoadSegments,rowCount,[2,3],...
            'Fill','Horizontal');
            rowCount=rowCount+1;

            addLanesWidgetsToLayout(this,rowCount);
            rowCount=rowCount+1;
            layout.add(this.hShowRoadCenters,rowCount,[1,2],...
            'TopInset',labelInset,...
            'Anchor','NorthWest',...
            'Fill','Horizontal',...
            'MinimumWidth',labelWidth);
            layout.add(this.hAddRoadCenters,rowCount,3,...
            'TopInset',labelInset,...
            'Anchor','NorthEast',...
            'MinimumHeight',21,...
            'MinimumWidth',21);
            rowCount=rowCount+1;
            layout.add(this.hBankAngleLabel,rowCount,1,...
            'LeftInset',labelLeftInset,...
            'TopInset',labelInset,...
            'Anchor','West',...
            'MinimumHeight',labelHeight,...
            'MinimumWidth',labelWidth-labelLeftInset);
            layout.add(this.hBankAngle,rowCount,[2,3],'Fill','Horizontal');
            setConstraints(layout,this.hTable,...
            'Fill','Both',...
            'MinimumWidth',120,...
            'MinimumHeight',100);
        end
    end
end


