classdef RoadProperties<driving.internal.scenarioApp.Properties&driving.internal.scenarioApp.HasPropertySheets

    properties(Hidden)

hName
    end


    properties(Access=protected)
RoadChangedListener
    end


    methods
        function this=RoadProperties(varargin)
            this@driving.internal.scenarioApp.Properties(varargin{:});
            update(this);
        end


        function icon=getIcon(this,varargin)
            icon=getIcon(this.Application,varargin{:});
        end


        function name=getName(~)
            name=getString(message('driving:scenarioApp:RoadPropertiesTitle'));
        end


        function tag=getTag(~)
            tag='RoadProperties';
        end


        function zValue=getAddRoadCentersZValue(this)
            zValue=getAddRoadCentersZValue(this.CurrentPropertySheet);
        end


        function updateProperty(this,property)
            switch property
            case 'Centers'
                updateEditPoints(this);
            end
        end


        function updateEditPoints(this)
            sheet=this.CurrentPropertySheet;
            if~isempty(sheet)
                updateEditPoints(sheet);
            end
        end


        function update(this)
            clearAllMessages(this);
            designer=this.Application;
            allRoadSpecs=designer.RoadSpecifications;

            deleteEnab='on';
            if strcmp(designer.ScenarioView.InteractionMode,'addRoad')
                currentRoad=this.Application.ScenarioView.CurrentRoad;
                set(this.hSpecificationIndex,...
                'Enable','off',...
                'String',getString(message('driving:scenarioApp:AddRoadSpecificationIndex')),'Value',1);
            elseif isempty(allRoadSpecs)
                currentRoad=[];
                set(this.hSpecificationIndex,...
                'Enable','off',...
                'String',{''},...
                'Value',1);
                this.hName.String='';
                deleteEnab='off';
            else
                nRoads=numel(allRoadSpecs);
                allNames=cell(nRoads,1);
                for indx=1:numel(allRoadSpecs)
                    name=allRoadSpecs(indx).Name;
                    if isempty(name)
                        allNames{indx}=sprintf('%d',indx);
                    else
                        allNames{indx}=sprintf('%d: %s',indx,name);
                    end
                end
                index=this.SpecificationIndex;

                if isempty(index)
                    index=1;
                elseif index>nRoads
                    this.SpecificationIndex=nRoads;
                    index=nRoads;

                end
                set(this.hSpecificationIndex,...
                'String',allNames,...
                'Value',index,...
                'Enable',matlabshared.application.logicalToOnOff(~this.InteractiveMode));
                currentRoad=allRoadSpecs(index);
            end
            set(this.hDelete,'Enable',deleteEnab);
            update@driving.internal.scenarioApp.HasPropertySheets(this,currentRoad);
            if usingWebFigure(this)&&strcmp(this.Figure.Visible,'off')
                update(this.Layout,'force');
                update(this.CurrentPropertySheet.Layout,'force');
            end
        end


        function c=getDefaultPropertySheet(~)
            c='driving.internal.scenarioApp.road.ArbitraryPropertySheet';
        end


        function row=getPropertySheetRow(~)
            row=3;
        end


        function spec=getCurrentSpecification(this)
            canvas=this.Application.ScenarioView;
            if strcmp(canvas.InteractionMode,'addRoad')
                spec=canvas.CurrentRoad;
                return;
            end
            index=this.SpecificationIndex;
            allSpecs=this.Application.RoadSpecifications;
            if index>numel(allSpecs)
                spec=[];
            else
                spec=allSpecs(index);
            end
        end
    end


    methods(Hidden)
        function row=getLastLabelRow(~)
            row=2;
        end


        function onSheetHeightChanged(this,~,~)
            this.Layout.setConstraints(3,1,'MinimumHeight',getMinimumHeight(this.CurrentPropertySheet));
        end


        function onKeyPress(this,~,ev)
            if this.InteractiveMode
                if strcmp(ev.Key,'escape')
                    exitInteractionMode(this.Application.ScenarioView);
                end
            elseif strcmp(ev.Key,'delete')
                removeCallback(this);
            end
        end


        function onFocus(this)
            app=this.Application;
            spec=getCurrentSpecification(this);
            if~isempty(spec)
                app.ScenarioView.CurrentSpecification=spec;
            end
        end


        function removeCallback(this,~,~)
            hApp=this.Application;
            index=this.SpecificationIndex;
            if isempty(index)
                hApp.ScenarioView.exitInteractionMode;
                return;
            end
            if index>numel(hApp.RoadSpecifications)
                return;
            end
            transaction=driving.internal.scenarioApp.undoredo.DeleteRoad(hApp,index);
            hApp.applyEdit(transaction);
            this.SpecificationIndex=1;
            update(this);
        end


        function roadChanged(this)
            onRoadChanged(this.CurrentPropertySheet);
        end


        function edit=createEdit(this,names,varargin)
            hApp=this.Application;
            hSpec=getCurrentSpecification(this);
            if iscell(names)
                edit=driving.internal.scenarioApp.undoredo.SetMultipleRoadProperties(...
                hApp,hSpec,names,varargin{:});
            else
                edit=driving.internal.scenarioApp.undoredo.SetRoadProperty(...
                hApp,hSpec,names,varargin{:});
            end
        end
    end


    methods(Access=protected)

        function onNewInteractiveMode(this)
            if this.InteractiveMode
                update(this);
                onInteractiveMode(this.CurrentPropertySheet);
            end
        end


        function event=getIndexEventName(~)
            event='CurrentRoadChanged';
        end
        function[id,str]=validateDoubleProperty(this,name,value)
            [id,str]=validateDoubleProperty(this.CurrentPropertySheet,name,value);
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
            this.RoadChangedListener=event.listener(app,...
            'CurrentRoadChanged',@(~,~)roadChanged(this));
            hListLabel=createLabel(this,p,'RoadList');
            createEditbox(this,p,'SpecificationIndex',[],'popupmenu');
            hNameLabel=createLabelEditPair(this,p,'Name',@this.nameCallback);
            vw=[0,0,1,0];
            createPushButton(this,p,'Delete',@this.removeCallback,...
            'CData',getIcon(app,'delete16'),...
            'TooltipString',getString(message('driving:scenarioApp:DeleteRoadDescription')));
            layout=matlabshared.application.layout.ScrollableGridBagLayout(p,...
            'HorizontalGap',3,...
            'VerticalGap',3,...
            'HorizontalWeights',[0,1,0],...
            'VerticalWeights',vw);

            labelInset=5;
            labelHeight=20-labelInset;
            labelWidth=layout.getMinimumWidth([hListLabel,hNameLabel]);
            this.LabelWidth=labelWidth;

            layout.add(hListLabel,1,1,...
            'TopInset',3+labelInset,...
            'Anchor','West',...
            'MinimumHeight',labelHeight,...
            'MinimumWidth',labelWidth);
            layout.add(this.hSpecificationIndex,1,2,'TopInset',3,'Fill','Both');

            layout.add(hNameLabel,2,1,...
            'TopInset',labelInset,...
            'Anchor','West',...
            'MinimumHeight',labelHeight,...
            'MinimumWidth',labelWidth);
            layout.add(this.hName,2,2,'Fill','Both');

            layout.add(this.hDelete,4,2,...
            'Anchor','SouthEast',...
            'MinimumHeight',21,...
            'MinimumWidth',21);

            this.Layout=layout;

            if useAppContainer(app)
                update(layout,'force');
            end
        end


        function setPropertyForInteractiveMode(this,prop,value)
            canvas=this.Application.ScenarioView;
            if strcmp(canvas.InteractionMode,'addRoad')
                road=canvas.CurrentRoad;
                if iscell(prop)
                    for indx=1:numel(prop)
                        road.(prop{indx})=value{indx};
                    end
                else
                    road.(prop)=value;
                end
            else
                setPropertyForNonInteractiveMode(this,prop,value);
            end
        end
    end
end



