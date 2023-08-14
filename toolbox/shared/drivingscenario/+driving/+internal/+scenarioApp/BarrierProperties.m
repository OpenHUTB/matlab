classdef BarrierProperties<driving.internal.scenarioApp.Properties
    % 障碍物属性
    properties
        ShowBarrierProperties = false;
        ShowBarrierCenters=false
        ShowRCSProperties=false;
        ShowPathProperties=false;
    end


    properties(Hidden)
        hTable

        hName
        hClassID
        hBankAngle
        hSegmentLength
        hRoadEdgeOffset
        hWidth
        hHeight
        hSegmentGap
        hColorPatch
        hBarrierType
        hImportRCS;
        hRCSElevationAngles;
        hRCSAzimuthAngles;
        hRCSPattern;

        hShowBarrierProperties
        hShowRCSProperties
        hShowBarrierCenters
        hAddBarrierCenters

        hBarrierPanel
        hRCSPanel
        hRoadOffsetPanel

        AllIDsCache
        BarrierPropertiesLayout
        RCSPropertiesLayout
        RoadOffsetPropertyLayout
        UpdateTableColumnWidthsOnOpen=false;
    end


    methods

        function this=BarrierProperties(varargin)
            this@driving.internal.scenarioApp.Properties(varargin{:});
            update(this);
        end


        function name=getName(~)
            name=getString(message('driving:scenarioApp:BarrierPropertiesTitle'));
        end


        function tag=getTag(~)
            tag='BarrierProperties';
        end


        function update(this)
            clearAllMessages(this);
            designer=this.Application;

            if isempty(designer.ScenarioView)
                return;
            end

            isAdd=false;
            allBarrierSpecs=designer.BarrierSpecifications;
            deleteEnab='on';
            if strcmp(designer.ScenarioView.InteractionMode,'addBarrier')
                barrier=this.Application.ScenarioView.CurrentBarrier;
                set(this.hSpecificationIndex,...
                    'Enable','off',...
                    'String',getString(message('driving:scenarioApp:AddBarrierSpecificationIndex')),'Value',1);
                isAdd=true;
            elseif isempty(allBarrierSpecs)
                barrier=[];
                set(this.hSpecificationIndex,...
                    'Enable','off',...
                    'String',{''},...
                    'Value',1);
                this.hName.String='';
                deleteEnab='off';
            else
                nBarriers=numel(allBarrierSpecs);
                allNames=cell(nBarriers,1);
                for indx=1:numel(allBarrierSpecs)
                    name=allBarrierSpecs(indx).Name;
                    if isempty(name)
                        allNames{indx}=sprintf('%d',indx);
                    else
                        allNames{indx}=sprintf('%d: %s',indx,name);
                    end
                end
                index=this.SpecificationIndex;

                if isempty(index)
                    index=1;
                elseif index>nBarriers
                    this.SpecificationIndex=nBarriers;
                    index=nBarriers;

                end
                set(this.hSpecificationIndex,...
                    'String',allNames,...
                    'Value',index,...
                    'Enable',matlabshared.application.logicalToOnOff(~this.InteractiveMode));
                barrier=allBarrierSpecs(index);
            end

            set(this.hDelete,'Enable',deleteEnab);

            if isempty(barrier)
                set(this.hTable,'Data',[],...
                    'RowName','numbered');
                set(this.hRoadEdgeOffset,...
                    'String','',...
                    'Enable','off');
                set(this.hBankAngle,...
                    'String','',...
                    'Enable','off');
                this.hAddBarrierCenters.Enable='off';
                set([this.hSpecificationIndex,this.hClassID,this.hBarrierType],...
                    'String',{' '},...
                    'Value',1,...
                    'Enable','off');
                set([this.hName,this.hSegmentLength,this.hWidth,this.hSegmentGap...
                    ,this.hHeight,this.hRCSElevationAngles,this.hRCSAzimuthAngles],...
                    'String','',...
                    'Enable','off');
                set(this.hColorPatch,'BackgroundColor',get(0,'DefaultUIControlBackgroundColor'));
                set([this.hImportRCS],'Enable','off');
                set(this.hRCSPattern,'Enable','off','RowName',[],'ColumnName',[],'Data',[]);
                return;
            end

            app=this.Application;
            canvas=app.ScenarioView;
            mode=canvas.InteractionMode;

            enable=matlabshared.application.logicalToOnOff(this.Enabled);
            if strncmp(mode,'addBarrier',7)
                nWaypoints=size(canvas.Waypoints,1);
                if strcmp(mode,'addBarrier')
                    isAdd=true;
                    updateLayout(this);
                    if nWaypoints>1
                        buttonEnab=enable;
                    else
                        buttonEnab='off';
                    end
                else
                    if nWaypoints==size(barrier.BarrierCenters,1)
                        buttonEnab='off';
                    else
                        buttonEnab='on';
                    end
                end
                icon='confirm16';
                tooltip=getString(message('driving:scenarioApp:AcceptBarrierCentersDescription'));
                if nWaypoints==0
                    rowName=' ';
                else
                    rowName=1:nWaypoints;
                end
                tableData=getTableData(app.ScenarioView);
            else
                buttonEnab=enable;
                rowName='numbered';
                icon='add16';
                tooltip=getString(message('driving:scenarioApp:AddBarrierCentersDescription'));
                if this.InteractiveMode&&~strcmp(mode,'addMultipleBarriers')
                    tableData=getTableData(app.ScenarioView);
                else
                    tableData=barrier.BarrierCenters;
                end
            end
            set(this.hAddBarrierCenters,...
                'CData',getIcon(app,icon),...
                'Enable',buttonEnab,...
                'TooltipString',tooltip);

            widthEnable=enable;
            set(this.hWidth,...
                'String',barrier.Width,...
                'Enable',widthEnable);

            if~isempty(barrier.Road)

                if~isscalar(barrier.RoadEdgeOffset)
                    set(this.hRoadEdgeOffset,'String','','Enable',enable);
                else
                    set(this.hRoadEdgeOffset,...
                        'String',mat2str(barrier.RoadEdgeOffset),...
                        'Enable',enable);
                end
                roadID=barrier.Road.RoadID;
                roadName=this.Application.RoadSpecifications(roadID).Name;
                set(this.hRoadEdgeOffset,'TooltipString',...
                    getString(message('driving:scenarioApp:RoadEdgeOffsetDescription',barrier.RoadEdge,roadName)));
                set(this.hBankAngle,...
                    'String',mat2str(barrier.BankAngle),...
                    'Enable','off');
                this.hTable.ColumnName{4}=getString(message('driving:scenarioApp:OffsetColumnName'));
                this.hTable.ColumnWidth={65};
                this.hTable.ColumnEditable=[true,true,true,true];
                if~isa(tableData,'cell')
                    if isscalar(barrier.RoadEdgeOffset)
                        tableData(:,4)=repmat(barrier.RoadEdgeOffset,size(tableData,1),1);
                    else
                        tableData(:,4)=barrier.RoadEdgeOffset;
                    end
                end
            else
                set(this.hRoadEdgeOffset,...
                    'String','',...
                    'Enable','off');
                set(this.hBankAngle,...
                    'String',mat2str(barrier.BankAngle),...
                    'Enable',enable);
                this.hTable.ColumnName{4}=[];
                this.hTable.ColumnWidth='auto';
            end
            set(this.hTable,...
                'Data',tableData,...
                'RowName',rowName,...
                'Enable',enable);

            if isAdd
                color=barrier.PlotColor;
                set(this.hColorPatch,'BackgroundColor',color);
            else
                nBarriers=numel(allBarrierSpecs);
                allNames=cell(nBarriers,1);
                for indx=1:nBarriers
                    name=allBarrierSpecs(indx).Name;
                    allNames{indx}=sprintf('%d: %s',indx,name);
                end
                set(this.hSpecificationIndex,...
                    'String',allNames,...
                    'Value',this.SpecificationIndex,...
                    'Enable','on');
                set(this.hColorPatch,'BackgroundColor',barrier.PlotColor);
            end
            enable=matlabshared.application.logicalToOnOff(this.Enabled);
            set(this.hName,...
                'String',barrier.Name,...
                'Enable',enable);

            barrierTypes=driving.internal.scenarioApp.BarrierSpecification.getBarrierTypes();
            setupPopup(this,'BarrierType',barrierTypes{:});
            if isempty(barrier.BarrierType)
                classSpec=this.Application.ClassSpecifications.getSpecification(barrier.ClassID);
                barrier.BarrierType=classSpec.BarrierType;
            end
            switch barrier.BarrierType
                case 'Jersey Barrier'
                    barrierType=barrierTypes{1};
                case 'Guardrail'
                    barrierType=barrierTypes{2};
            end
            setPopupValue(this,'BarrierType',barrierType);
            set(this.hBarrierType,'Enable',enable);

            if this.Application.Use3dSimDimensions
                staticDims=driving.scenario.internal.GamingEngineScenarioAnimator.getAssetDimensions(barrier.AssetType);
            else
                staticDims=struct;
            end

            setDimensionWidget(this,'SegmentLength',barrier,staticDims,enable);
            setDimensionWidget(this,'SegmentGap',barrier,staticDims,enable);
            setDimensionWidget(this,'Width',barrier,staticDims,enable);
            setDimensionWidget(this,'Height',barrier,staticDims,enable);

            barrierLayout=this.BarrierPropertiesLayout;
            if this.ShowBarrierProperties
                [~,h]=getMinimumSize(barrierLayout);
                h=sum(h)+barrierLayout.VerticalGap*(numel(h)+1);
                setConstraints(this.Layout,this.hBarrierPanel,...
                    'MinimumHeight',h);
                update(this.Layout,'force');
            end

            hAzim=this.hRCSAzimuthAngles;
            hElev=this.hRCSElevationAngles;
            hPatt=this.hRCSPattern;
            driving.internal.scenarioApp.RCSHelper.updateWidgets(...
                hAzim,hElev,hPatt,barrier,enable)
            this.hImportRCS.Enable=enable;
        end


        function spec=getCurrentSpecification(this)
            hApp=this.Application;
            if this.InteractiveMode&&strcmp(hApp.ScenarioView.InteractionMode,'addBarrier')
                spec=hApp.ScenarioView.CurrentBarrier;
            else
                allSpecs=hApp.BarrierSpecifications;
                index=this.SpecificationIndex;
                if numel(allSpecs)<index
                    spec=[];
                else
                    spec=allSpecs(index);
                end
            end
        end
    end


    methods(Hidden)
        function onKeyPress(this,~,ev)
            if this.InteractiveMode&&strcmp(ev.Key,'escape')
                exitInteractionMode(this.Application.ScenarioView);
            end
        end


        function onFocus(this)
            app=this.Application;
            spec=getCurrentSpecification(this);
            if~isempty(spec)
                app.ScenarioView.CurrentSpecification=spec;
            end
        end


        function removeBarrierCallback(this,~,~)
            hApp=this.Application;
            index=this.SpecificationIndex;
            if isempty(index)
                hApp.ScenarioView.exitInteractionMode;
                return;
            end
            if index>numel(hApp.BarrierSpecifications)
                return;
            end
            transaction=driving.internal.scenarioApp.undoredo.DeleteBarrier(hApp,index);
            hApp.applyEdit(transaction);
            this.SpecificationIndex=1;
            update(this);
        end


        function updateLayout(this)
            layout=this.Layout;
            barrierPanel=this.hBarrierPanel;
            rcsPanel=this.hRCSPanel;
            roadOffsetPanel=this.hRoadOffsetPanel;
            offset=1;
            verticalWeights=[0,0,0,0];
            hasNoWeight=true;
            topInset=-4;
            rightInset=-5;
            if this.ShowBarrierProperties
                verticalWeights=[verticalWeights,0,0];
                if~layout.contains(barrierPanel)
                    insert(layout,'row',5+offset);
                    [~,h]=getMinimumSize(this.BarrierPropertiesLayout);
                    add(layout,barrierPanel,5+offset,[1,6],...
                        'RightInset',rightInset,...
                        'TopInset',topInset,...
                        'Fill','Both',...
                        'MinimumHeight',h);
                end
                barrierPanel.Visible='on';
                offset=offset+1;
            else
                verticalWeights=[verticalWeights,0];
                if layout.contains(barrierPanel)
                    barrierPanel.Visible='off';
                    remove(layout,barrierPanel);
                    clean(layout);
                end
            end

            if this.ShowRCSProperties
                verticalWeights=[verticalWeights,0,1];
                hasNoWeight=false;
                if~layout.contains(rcsPanel)
                    set(this.hImportRCS,'Visible','on');
                    insert(layout,'row',6+offset)
                    [~,h]=getMinimumSize(this.RCSPropertiesLayout);
                    add(layout,rcsPanel,6+offset,[1,6],...
                        'RightInset',rightInset,...
                        'TopInset',topInset,...
                        'Fill','Both',...
                        'MinimumHeight',h);
                end
                rcsPanel.Visible='on';
            else
                verticalWeights=[verticalWeights,0];
                if layout.contains(rcsPanel)
                    set(this.hImportRCS,'Visible','off');
                    rcsPanel.Visible='off';
                    remove(layout,rcsPanel);
                    clean(layout);
                end
            end

            row=7;
            table=this.hTable;
            if this.ShowBarrierCenters
                if~layout.contains(roadOffsetPanel)
                    insert(layout,'row',row+offset)
                    [~,h]=getMinimumSize(this.RoadOffsetPropertyLayout);
                    add(layout,roadOffsetPanel,row+offset,[1,6],...
                        'RightInset',rightInset,...
                        'TopInset',topInset,...
                        'Fill','Both',...
                        'MinimumHeight',h);
                end
                row=row+1;
                roadOffsetPanel.Visible='on';
                if~layout.contains(table)
                    layout.insert('row',row+offset);
                    layout.add(table,row+offset,[1,6]);
                end
                table.Visible='on';
                verticalWeights=[verticalWeights,0,0,1];
            else
                if layout.contains(roadOffsetPanel)
                    roadOffsetPanel.Visible='off';
                    remove(layout,roadOffsetPanel);
                    clean(layout);
                end
                table.Visible='off';
                if layout.contains(table)
                    layout.remove(table);
                    layout.clean;
                end
                verticalWeights=[verticalWeights,0];
            end

            if hasNoWeight
                verticalWeights=[verticalWeights,1];
            else
                verticalWeights=[verticalWeights,0];
            end

            layout.VerticalWeights=verticalWeights;
            matlabshared.application.setToggleCData(this.hShowRCSProperties);
            matlabshared.application.setToggleCData(this.hShowBarrierCenters);
            matlabshared.application.setToggleCData(this.hShowBarrierProperties);
        end


        function updateTableColumnWidths(this)
            if~this.ShowPathProperties
                this.UpdateTableColumnWidthsOnOpen=true;
                return;
            end
            this.UpdateTableColumnWidthsOnOpen=false;

            maxWidth=80;
            minWidth=49;
            nCols=3;
            t=this.hTable;
            t.ColumnWidth=repmat({maxWidth},1,nCols);
            e=t.Extent;
            p=getpixelposition(t);
            w=e(3)-p(3)+4;
            if w>0
                w=maxWidth-ceil(w/nCols);
            else
                w=maxWidth;
            end
            if w<minWidth
                w=minWidth;
            end

            t.ColumnWidth=repmat({floor(w)},1,5);
        end


        function updateProperty(this,property)
            switch property
                case 'Centers'
                    updateEditPoints(this);
            end
        end


        function updateEditPoints(this)
            canvas=this.Application.ScenarioView;
            if strncmp(canvas.InteractionMode,'addBarrier',7)
                tableData=getTableData(canvas);
            else
                if this.InteractiveMode
                    tableData=getTableData(canvas);
                else
                    barrier=getCurrentSpecification(this);
                    tableData=barrier.BarrierCenters;
                end
            end
            this.hTable.Data=tableData;
        end


        function edit=createEdit(this,varargin)
            hApp=this.Application;
            hSpec=hApp.BarrierSpecifications(this.SpecificationIndex);
            edit=driving.internal.scenarioApp.undoredo.SetBarrierProperty(...
                hApp,hSpec,varargin{:});
        end


        function roadEdgeOffsetEditboxCallback(this,hSrc,~)
            propName=getPropertyFromTag(this,hSrc.Tag);
            str=get(hSrc,'String');
            newValue=str2double(str);
            if isnan(newValue)
                newValue=this.strToNum(str);
            end
            id='';
            str='';

            if isa(newValue,'double')
                [id,str]=validateDoubleProperty(this,propName,newValue);
            end
            if~isempty(id)
                update(this);
                errorMessage(this,str,id);
                return;
            end

            if this.InteractiveMode
                setPropertyForInteractiveMode(this,propName,newValue)
            else
                setPropertyForNonInteractiveMode(this,propName,newValue);
            end
        end
    end


    methods(Access='protected')

        function setDimensionWidget(this,prop,spec,staticDims,enable)
            if isfield(staticDims,prop)
                value=staticDims.(prop);
                enable='off';
            else
                value=spec.(prop);
            end
            set(this.(['h',prop]),...
                'String',value,...
                'Enable',enable);
        end


        function onNewInteractiveMode(this)
            if~this.ShowBarrierCenters
                this.ShowBarrierCenters=true;
                setToggleValue(this,'ShowBarrierCenters',true);
                updateLayout(this);
            end
        end


        function event=getIndexEventName(~)
            event='CurrentBarrierChanged';
        end


        function[id,str]=validateDoubleProperty(this,name,value)
            spec=getCurrentSpecification(this);
            if isstruct(spec)
                pvPairs=matlabshared.application.structToPVPairs(spec);
                spec=driving.internal.scenarioApp.BarrierSpecification(pvPairs{:});
            end
            id='';
            str='';
            if strcmp(name,'SegmentLength')
                [id,str]=spec.validateSegmentLength(value);
            elseif strcmp(name,'SegmentGap')
                [id,str]=spec.validateSegmentGap(value);
            elseif strcmp(name,'Width')
                [id,str]=spec.validateWidth(value,this.InteractiveMode,this.Application.ScenarioView);
            elseif strcmp(name,'Height')
                [id,str]=spec.validateHeight(value);
            elseif strcmp(name,'RoadEdgeOffset')
                [id,str]=spec.validateRoadEdgeOffset(value);
            elseif strcmp(name,'BankAngle')&&~isscalar(value)
                if numel(value)~=size(spec.BarrierCenters,1)
                    id='driving:scenarioApp:BadBankAngleSize';
                    str=getString(message(id));
                    return;
                end
            end
            if isempty(id)
                [id,str]=validateDoubleProperty@driving.internal.scenarioApp.Properties(this,name,value);
            end
        end


        function updateScenario(this)
            generateNewScenarioFromSpecifications(this.Application);
        end


        function p=createFigure(this,varargin)
            p=createFigure@matlabshared.application.Component(this,varargin{:});

            app=this.Application;
            icons=getIcon(app);

            createEditbox(this,p,'SpecificationIndex',[],'popup');

            this.hColorPatch=uipanel('Parent',p,...
                'BorderType','none',...
                'Tag','ColorPatch',...
                'BackgroundColor',[0.5,0.5,0.5],...
                'AutoResizeChildren','off',...
                'Interruptible','off',...
                'ButtonDownFcn',@this.colorCallback);

            hNameLabel=createLabelEditPair(this,p,...
                'Name',@this.nameCallback);

            [hBankAngleLabel,this.hBankAngle]=createLabelEditPair(this,p,'BankAngle',...
                'TooltipString',getString(message('driving:scenarioApp:BankAngleDescription')));

            hBarrierTypeLabel=createLabelEditPair(this,p,'BarrierType',...
                @this.barrierTypeCallback,'popupmenu',...
                'TooltipString',getString(message('driving:scenarioApp:BarrierTypeDescription')));

            createToggle(this,p,'ShowBarrierProperties');

            barrierPanel=uipanel(p,...
                'Tag','BarrierPropertiesPanel',...
                'AutoResizeChildren','off',...
                'Units','pixels',...
                'Visible','off',...
                'BorderType','none');

            hSegmentLengthLabel=createLabelEditPair(this,barrierPanel,'SegmentLength');
            hWidthLabel=createLabelEditPair(this,barrierPanel,'Width');
            hHeightLabel=createLabelEditPair(this,barrierPanel,'Height');
            hSegmentGapLabel=createLabelEditPair(this,barrierPanel,'SegmentGap');

            this.hBarrierPanel=barrierPanel;

            spacing=3;
            labelInset=3;
            labelHeight=20-labelInset;
            barrierLayout=matlabshared.application.layout.GridBagLayout(barrierPanel,...
                'VerticalGap',spacing,...
                'HorizontalGap',spacing);
            labelWidth=barrierLayout.getMinimumWidth([hSegmentLengthLabel...
                ,hWidthLabel,hHeightLabel,hSegmentGapLabel]);

            labelInset=-spacing;
            add(barrierLayout,hWidthLabel,1,1,...
                'MinimumHeight',labelHeight-2,...
                'MinimumWidth',labelWidth,...
                'BottomInset',labelInset,...
                'Fill','Horizontal')
            add(barrierLayout,hHeightLabel,1,2,...
                'MinimumHeight',labelHeight-2,...
                'MinimumWidth',labelWidth,...
                'BottomInset',labelInset,...
                'Fill','Horizontal')
            add(barrierLayout,this.hWidth,2,1,...
                'Fill','Horizontal')
            add(barrierLayout,this.hHeight,2,2,...
                'Fill','Horizontal')

            add(barrierLayout,hSegmentLengthLabel,3,1,...
                'MinimumHeight',labelHeight-2,...
                'MinimumWidth',labelWidth,...
                'BottomInset',labelInset,...
                'Fill','Horizontal')
            add(barrierLayout,this.hSegmentLength,4,1,...
                'Fill','Horizontal')
            add(barrierLayout,hSegmentGapLabel,3,2,...
                'MinimumHeight',labelHeight-2,...
                'MinimumWidth',labelWidth,...
                'BottomInset',labelInset,...
                'Fill','Horizontal')
            add(barrierLayout,this.hSegmentGap,4,2,...
                'Fill','Horizontal')

            this.hBarrierPanel=barrierPanel;
            this.BarrierPropertiesLayout=barrierLayout;

            createToggle(this,p,'ShowRCSProperties');

            rcsPanel=uipanel(p,...
                'Visible','off',...
                'AutoResizeChildren','off',...
                'Units','pixels',...
                'Tag','BarrierProperties.rcsPanel',...
                'BorderType','none');

            hAzimLabel=createLabelEditPair(this,rcsPanel,'RCSAzimuthAngles',@this.azimuthAnglesCallback,...
                'TooltipString',getString(message('driving:scenarioApp:RCSAzimuthAnglesDescription')));
            hElevLabel=createLabelEditPair(this,rcsPanel,'RCSElevationAngles',@this.elevationAnglesCallback,...
                'TooltipString',getString(message('driving:scenarioApp:RCSElevationAnglesDescription')));
            hPattLabel=createLabelEditPair(this,rcsPanel,'RCSPattern',@this.patternCallback,'table','Tag','BarrierProperties.RCSTable');

            createPushButton(this,p,'ImportRCS',@this.importRcsCallback,...
                'Visible','off',...
                'String',getString(message('driving:scenarioApp:ImportRCSPattern')),...
                'TooltipString',getString(message('driving:scenarioApp:ImportRCSPatternDescription')));

            rcsLayout=matlabshared.application.layout.GridBagLayout(rcsPanel,...
                'VerticalGap',spacing,...
                'HorizontalGap',spacing,...
                'HorizontalWeights',[0,1],...
                'VerticalWeights',[0,0,0,1]);

            labelConstraints={...
                'MinimumWidth',rcsLayout.getMinimumWidth([hAzimLabel,hElevLabel,hPattLabel]),...
                'Anchor','SouthWest',...
                'TopInset',labelInset,...
                'MinimumHeight',labelHeight};

            add(rcsLayout,hAzimLabel,1,1,labelConstraints{:});
            add(rcsLayout,hElevLabel,2,1,labelConstraints{:});
            add(rcsLayout,hPattLabel,3,1,labelConstraints{:},'TopInset',3);

            add(rcsLayout,this.hRCSAzimuthAngles,1,2,'Fill','Horizontal');
            add(rcsLayout,this.hRCSElevationAngles,2,2,'Fill','Horizontal');
            add(rcsLayout,this.hRCSPattern,4,[1,2],'Fill','Both',...
                'BottomInset',-spacing,...
                'MinimumHeight',80);

            this.RCSPropertiesLayout=rcsLayout;
            this.hRCSPanel=rcsPanel;

            createToggle(this,p,'ShowBarrierCenters');

            roadOffsetPanel=uipanel(p,...
                'Visible','off',...
                'AutoResizeChildren','off',...
                'Units','pixels',...
                'Tag','roadOffsetPanel',...
                'BorderType','none');

            [hRoadEdgeOffsetLabel,this.hRoadEdgeOffset]=createLabelEditPair(this,...
                roadOffsetPanel,'RoadEdgeOffset');
            this.hRoadEdgeOffset.Callback=@this.roadEdgeOffsetEditboxCallback;

            roadOffsetLayout=matlabshared.application.layout.GridBagLayout(roadOffsetPanel,...
                'HorizontalGap',spacing,'VerticalGap',spacing,'HorizontalWeights',[0,1]);

            add(roadOffsetLayout,hRoadEdgeOffsetLabel,1,1,...
                'MinimumHeight',labelHeight,...
                'MinimumWidth',roadOffsetLayout.getMinimumWidth(hRoadEdgeOffsetLabel),...
                'BottomInset',labelInset,...
                'Fill','Horizontal')
            add(roadOffsetLayout,this.hRoadEdgeOffset,1,2,...
                'Fill','Horizontal')
            this.RoadOffsetPropertyLayout=roadOffsetLayout;
            this.hRoadOffsetPanel=roadOffsetPanel;

            createPushButton(this,p,'AddBarrierCenters',@this.addBarrierCentersCallback,...
                'CData',icons.add16,...
                'TooltipString',getString(message('driving:scenarioApp:AddBarrierCentersDescription')));

            columnNames={getString(message('driving:scenarioApp:XColumnName')),...
                getString(message('driving:scenarioApp:YColumnName')),...
                getString(message('driving:scenarioApp:ZColumnName')),...
                getString(message('driving:scenarioApp:OffsetColumnName'))};

            this.hTable=uitable('Parent',p,...
                'ColumnWidth','auto',...
                'Tag','BarrierCentersTable',...
                'Visible','off',...
                'ColumnName',columnNames,...
                'CellEditCallback',@this.cellEditCallback,...
                'ColumnEditable',true);

            createPushButton(this,p,'Delete',@this.removeBarrierCallback,...
                'Interruptible','off',...
                'BusyAction','cancel',...
                'CData',icons.delete16,...
                'TooltipString',getString(message('driving:scenarioApp:DeleteBarrierDescription')));

            layout=matlabshared.application.layout.ScrollableGridBagLayout(p,...
                'HorizontalGap',spacing,...
                'VerticalGap',spacing,...
                'HorizontalWeights',[0,1],...
                'VerticalWeights',[0,0,0,0,0,0,0,1]);

            row=1;
            layout.add(this.hSpecificationIndex,row,[1,5],...
                'Fill','Horizontal');

            layout.add(this.hColorPatch,row,6,...
                'Fill','Both');

            labelProps={'TopInset',labelInset+6,...
                'Anchor','West',...
                'MinimumHeight',labelHeight};

            row=row+1;
            width=layout.getMinimumWidth([hNameLabel,hBankAngleLabel]);
            layout.add(hNameLabel,row,1,labelProps{:},...
                'MinimumWidth',width);
            layout.add(this.hName,row,[2,6],'Fill','Horizontal');

            row=row+1;
            layout.add(hBankAngleLabel,row,1,labelProps{:},...
                'MinimumWidth',width);
            layout.add(this.hBankAngle,row,[2,6],'Fill','Horizontal',...
                'MinimumWidth',50);

            row=row+1;
            layout.add(hBarrierTypeLabel,row,1,labelProps{:},...
                'MinimumWidth',width);
            layout.add(this.hBarrierType,row,[2,6],'Fill','Horizontal',...
                'MinimumWidth',50);

            row=row+1;
            layout.add(this.hShowBarrierProperties,row,[1,2],...
                'Anchor','West',...
                'Fill','Horizontal',...
                'MinimumHeight',labelHeight,...
                'MinimumWidth',layout.getMinimumWidth(this.hShowBarrierProperties)+20);

            layout.setConstraints(barrierPanel,'BottomInset',-3);

            row=row+1;
            layout.add(this.hShowRCSProperties,row,[1,2],...
                'Anchor','West',...
                'Fill','Horizontal',...
                'MinimumHeight',labelHeight,...
                'MinimumWidth',layout.getMinimumWidth(this.hShowRCSProperties)+20);
            add(layout,this.hImportRCS,row,[3,6],'Anchor','East',...
                'MinimumWidth',layout.getMinimumWidth(this.hImportRCS)+20);

            row=row+1;
            layout.add(this.hShowBarrierCenters,row,[1,2],...
                'TopInset',labelInset,...
                'Anchor','NorthWest',...
                'Fill','Horizontal',...
                'MinimumWidth',layout.getMinimumWidth(this.hShowBarrierCenters)+20);
            layout.add(this.hAddBarrierCenters,row,[3,6],...
                'Anchor','NorthEast',...
                'MinimumHeight',21,...
                'MinimumWidth',21);

            row=row+2;
            layout.add(this.hDelete,row,[2,6],...
                'Anchor','SouthEast',...
                'MinimumHeight',21,...
                'MinimumWidth',21);

            setConstraints(layout,this.hTable,...
                'Fill','Both',...
                'MinimumWidth',120,...
                'MinimumHeight',100);

            this.Layout=layout;
            if usingWebFigure(this)
                update(layout,'force');
            end
        end


        function setPropertyForInteractiveMode(this,propName,newValue)
            canvas=this.Application.ScenarioView;
            if strcmp(canvas.InteractionMode,'addBarrier')
                canvas.CurrentBarrier.(propName)=newValue;
            else
                setPropertyForNonInteractiveMode(this,propName,newValue);
            end
        end
    end


    methods

        function azimuthAnglesCallback(this,hAzimuth,~)
            current=getCurrentSpecification(this);
            try
                [newAzim,newPattern]=driving.internal.scenarioApp.RCSHelper.parseAzimuth(...
                    hAzimuth.String,current.RCSPattern);
            catch ME
                update(this);
                errorMessage(this,ME.message,ME.identifier);
                return
            end
            hApp=this.Application;
            edit=driving.internal.scenarioApp.undoredo.SetMultipleBarrierProperties(...
                hApp,current,{'RCSAzimuthAngles','RCSPattern'},{newAzim,newPattern});
            try
                applyEdit(hApp,edit);
            catch ME
                update(this);
                errorMessage(this,getErrorMessageString(this,'RCSAzimuthAngles'),ME.identifier);
                return;
            end
            update(this);
        end


        function elevationAnglesCallback(this,hElevation,~)
            current=getCurrentSpecification(this);
            try
                [newElev,newPattern]=driving.internal.scenarioApp.RCSHelper.parseElevation(...
                    hElevation.String,current.RCSPattern);
            catch ME
                update(this);
                errorMessage(this,ME.message,ME.identifier);
                return
            end
            hApp=this.Application;
            edit=driving.internal.scenarioApp.undoredo.SetMultipleBarrierProperties(...
                hApp,current,{'RCSElevationAngles','RCSPattern'},{newElev,newPattern});
            try
                applyEdit(hApp,edit);
            catch ME
                update(this);
                errorMessage(this,getErrorMessageString(this,'RCSElevationAngles'),ME.identifier);
                return;
            end
            update(this);
        end


        function patternCallback(this,src,~)
            data=src.Data;
            if any(isnan(data(:)))
                update(this);
                return;
            end
            setProperty(this,'RCSPattern',data);
        end


        function barrierTypeCallback(this,~,~)
            value=getPopupValue(this,'BarrierType');
            switch value
                case 'JerseyBarrier'
                    barrierType='Jersey Barrier';
                case 'Guardrail'
                    barrierType='Guardrail';
            end
            setPropertyForInteractiveMode(this,'BarrierType',barrierType);
        end


        function importRcsCallback(this,~,~)
            spec=getCurrentSpecification(this);
            app=this.Application;
            if useAppContainer(app)
                app=app.Window.AppContainer;
            else
                app=getToolGroupName(app);
            end
            [az,el,pattern]=driving.internal.scenarioApp.RCSHelper.import(...
                numel(spec.RCSAzimuthAngles),numel(spec.RCSElevationAngles),app);
            props={};
            values={};
            if isempty(el)
                el=spec.RCSElevationAngles;
            else
                props={'RCSElevationAngles'};
                values={el};
            end
            if isempty(az)
                az=spec.RCSAzimuthAngles;
            else
                props=[props,{'RCSAzimuthAngles'}];
                values=[values,{az}];
            end
            if isempty(pattern)
                [pattern,wasResized]=driving.internal.scenarioApp.RCSHelper.resizePattern(spec.RCSPattern,numel(el),numel(az));
                if wasResized
                    props=[props,{'RCSPattern'}];
                    values=[values,{pattern}];
                end
            else
                props=[props,{'RCSPattern'}];
                values=[values,{pattern}];
            end
            if isempty(props)
                return;
            end

            hApp=this.Application;

            if numel(props)==1
                edit=driving.internal.scenarioApp.undoredo.SetBarrierProperty(...
                    hApp,spec,props{1},values{1});
            else
                edit=driving.internal.scenarioApp.undoredo.SetMultipleBarrierProperties(...
                    hApp,spec,props,values);
            end

            try
                applyEdit(hApp,edit);
            catch ME
                update(this);
                errorMessage(this,getErrorMessageString(this,'RCSAzimuthAngles'),ME.identifier);
                return
            end
            update(this);
        end


        function colorCallback(this,h,~)
            c=uisetcolor(h.BackgroundColor);
            if isequal(c,h.BackgroundColor)
                return;
            end
            h.BackgroundColor=c;
            setPropertyForInteractiveMode(this,'PlotColor',c);
        end


        function cellEditCallback(this,hTable,~)
            hApp=this.Application;
            data=hTable.Data;
            spec=getCurrentSpecification(this);

            if isempty(spec)
                committedCenters=[];
            else
                committedCenters=spec.BarrierCenters;
            end
            if this.InteractiveMode
                nCommitted=size(committedCenters,1);
                uncommitted=data(nCommitted+1:end,:);
                data(nCommitted+1:end,:)=[];
                data=cell2mat(data);
            end

            if any(isnan(data(:)))||any(isinf(data(:)))||~isempty(data)&&all(all(diff(data,1)==0))
                update(this);
                str=getErrorMessageString(this,'BarrierCenters');
                errorMessage(this,str,'driving:scenarioApp:InvalidBarrierCenters');
                return;
            end

            if size(data,2)>3
                roadEdgeOffset=data(:,4);
                barrierCenters=data(:,1:3);
                [id,str]=validateDoubleProperty(this,'RoadEdgeOffset',roadEdgeOffset);
                if~isempty(id)
                    update(this);
                    errorMessage(this,str,id);
                    barrierCreationFinished(hApp,true);
                    return;
                end

                if length(unique(roadEdgeOffset))==1
                    roadEdgeOffset=roadEdgeOffset(1);
                end
            else
                barrierCenters=data;
                roadEdgeOffset=[];
            end

            if size(data,1)>1
                me=spec.validateCenters(barrierCenters);
                if~isempty(me)
                    update(this);
                    errorMessage(this,me.message,me.identifier);
                    barrierCreationFinished(hApp,true);
                    return;
                end
            end

            if~isempty(spec)&&~isequal(committedCenters,data)&&size(data,1)>1
                applyEdit(hApp,createEdit(this,'BarrierCenters',barrierCenters));
                if~isempty(roadEdgeOffset)
                    applyEdit(hApp,createEdit(this,'RoadEdgeOffset',roadEdgeOffset));
                end
                setDirty(hApp);
            end

            if this.InteractiveMode

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
                    me=driving.internal.scenarioApp.BarrierSpecification.validateCenters(waypoints);
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

            if~isscalar(spec.RoadEdgeOffset)
                set(this.hRoadEdgeOffset,'String','');
            end
        end


        function addBarrierCentersCallback(this,~,~)
            hApp=this.Application;
            if this.InteractiveMode
                commitWaypoints(hApp.ScenarioView);
            else
                barrierAdder=getBarrierAdder(hApp);
                barrierAdder.addViaWaypoints(this.SpecificationIndex);
            end
        end
    end
end


function v=lcl_str2double(v)

if ischar(v)
    v=str2double(v);
end
end


