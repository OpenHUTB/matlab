classdef ClassEditor<matlabshared.application.Component&...
    matlabshared.application.ComponentBanner&...
    driving.internal.scenarioApp.UITools




    properties
        ShowRCSProperties=false;
        SetAsPreference=true;
        CurrentEntry=1;
        NewMode=false;
    end

    properties(SetAccess=protected,Hidden)
        ClassInfo;
Layout
PanelLayout
OldSetAsPreference
    end

    properties(Hidden)
hClassList
hDelete
hName
hID
hLength
hLengthLabel
hWidth
hHeight
hIsVehicle
hIsMovable
hBarrierType
hActorType
hActorTypeLabel
hSpeed
hSpeedLabel
hShowRCSProperties
hRCSElevationAnglesLabel
hRCSElevationAngles
hRCSAzimuthAnglesLabel
hRCSAzimuthAngles
hRCSPatternLabel
hPatternImport
hRCSPattern
hAdd
hCopy
hSetAsPreference
hRestoreFactory
hOk
hUseColorOrder
hSetDefaultColor
hColorPatch
hAssetType
hAssetTypeLabel
hMesh
hMeshLabel
        updatePanel=false
    end

    methods
        function this=ClassEditor(varargin)
            this@matlabshared.application.Component(varargin{:});
            refresh(this);
        end

        function b=isDocked(~)
            b=false;
        end

        function refresh(this)
            updateClassInfoFromMap(this,this.Application.ClassSpecifications.Map);
        end

        function open(this)
            fig=this.Figure;
            this.updatePanel=true;
            updateLayout(this);
            update(this.Layout,'force');
            update(this);
            this.OldSetAsPreference=this.SetAsPreference;
            fig.Visible=true;
            fig.Position=getCenterPosition(this.Application,fig.Position(3:4));
            figure(fig);
        end

        function close(this,isCancel)
            if nargin<2
                isCancel=true;
            end
            fig=this.Figure;
            if ishghandle(fig)
                fig.Visible='off';
            end
            refresh(this);
            if isCancel
                this.SetAsPreference=this.OldSetAsPreference;
            end
        end

        function update(this)

            clearAllMessages(this);

            allInfo=this.ClassInfo;
            list=cell(1,numel(allInfo));
            for indx=1:numel(allInfo)
                id=allInfo(indx).id;
                name=allInfo(indx).name;
                if isempty(id)
                    list{indx}=sprintf('<html><font color="red"><b>!!</b></font>: %s</html>',name);
                else
                    list{indx}=sprintf('%d: %s',id,name);
                end
            end

            entry=this.CurrentEntry;
            if entry>numel(allInfo)
                entry=numel(allInfo);
                this.CurrentEntry=entry;
            end

            app=this.Application;
            actorSpecs=app.ActorSpecifications;
            barrierSpecs=app.BarrierSpecifications;
            usedIDs=[actorSpecs.ClassID,barrierSpecs.ClassID];
            buffer=app.CopyPasteBuffer;
            if isa(buffer,'driving.internal.scenarioApp.ActorSpecification')||...
                isa(buffer,'driving.internal.scenarioApp.BarrierSpecification')
                usedIDs=[usedIDs,buffer.ClassID];
            end
            info=allInfo(entry);
            if any(usedIDs==info.id)
                enable='off';
            else
                enable='on';
            end

            set(this.hClassList,...
            'String',list,...
            'Value',entry);

            if strcmp(info.BarrierType,'None')


                set([this.hName,this.hID,this.hLength,this.hWidth,this.hHeight...
                ,this.hActorType,this.hIsMovable,this.hPatternImport,this.hUseColorOrder...
                ,this.hSpeed,this.hSpeedLabel,this.hSetDefaultColor,this.hAssetType,this.hMesh],'Visible','on','Enable',enable);

                assetTypes=driving.scenario.internal.GamingEngineScenarioAnimator.getAssetTypes(info.isVehicle);
                setupPopup(this,'AssetType',assetTypes{:});
                setPopupValue(this,'AssetType',info.AssetType);
                this.hAssetTypeLabel.String=getString(message('driving:scenarioApp:AssetTypeLabel'));
            else

                set([this.hIsMovable,this.hSpeed,this.hSpeedLabel,this.hUseColorOrder],'Enable','off');

                set([this.hName,this.hID,this.hWidth,this.hHeight,this.hAssetType,this.hBarrierType...
                ,this.hActorType,this.hPatternImport,this.hSetDefaultColor],'Enable',enable);

                barrierTypes=driving.internal.scenarioApp.BarrierSpecification.getBarrierTypes();
                setupPopup(this,'BarrierType',barrierTypes{:});
                setPopupValue(this,'BarrierType',regexprep(info.BarrierType,'\W',''));
                this.hAssetTypeLabel.String=getString(message('driving:scenarioApp:BarrierTypeLabel'));
            end

            setappdata(this.hColorPatch,'Enable',enable);


            actorTypes=driving.internal.scenarioApp.ClassEditor.getActorTypes();
            setupPopup(this,'ActorType',actorTypes{:});
            if info.isVehicle
                actorType=actorTypes{1};
            elseif~strcmp(info.BarrierType,'None')
                actorType=actorTypes{2};
            else
                actorType=actorTypes{3};
            end
            setPopupValue(this,'ActorType',actorType);
            set(this.hActorType,'Enable',enable);

            if this.NewMode
                deleteEnable='off';
                newEnable='off';
            else
                newEnable='on';


                if info.isVehicle&&numel(find([allInfo.isVehicle]))<2||numel(allInfo)==1
                    deleteEnable='off';
                else
                    deleteEnable=enable;
                end
            end

            if isempty(actorSpecs)&&~isa(buffer,'driving.internal.scenarioApp.ActorSpecification')
                restoreEnable=newEnable;
            else
                restoreEnable='off';
            end
            this.hRestoreFactory.Enable=restoreEnable;


            this.hSetAsPreference.Value=this.SetAsPreference;
            this.hName.String=info.name;
            this.hID.String=info.id;
            this.hLength.String=info.Length;
            this.hWidth.String=info.Width;
            this.hHeight.String=info.Height;
            this.hIsVehicle.Value=info.isVehicle;
            this.hIsMovable.Value=info.isMovable;

            useColorOrder=isempty(info.PlotColor);
            this.hUseColorOrder.Value=useColorOrder;
            this.hSetDefaultColor.Value=~useColorOrder;
            if useColorOrder
                color=info.LastColor;



            else
                color=info.PlotColor;
            end
            this.hColorPatch.BackgroundColor=color;


            meshTypes=driving.internal.scenarioApp.ClassEditor.getMeshTypes(info.isVehicle,info.BarrierType);
            setupPopup(this,'Mesh',meshTypes{:});
            mesh=info.Mesh;
            if isempty(mesh)
                setPopupValue(this,'Mesh','Cuboid');
            else
                dims=struct('Length',info.Length,'Width',info.Width,...
                'Height',info.Height,'RearOverhang',1);
                meshStr=driving.internal.scenarioApp.ClassEditor.getMeshExpression(mesh,info.isVehicle,dims);
                switch meshStr
                case ""
                    setPopupValue(this,'Mesh','Cuboid');
                case 'driving.scenario.carMesh'
                    setPopupValue(this,'Mesh','Car');
                case 'driving.scenario.truckMesh'
                    setPopupValue(this,'Mesh','Truck');
                case 'driving.scenario.bicycleMesh'
                    setPopupValue(this,'Mesh','Bicycle');
                case 'driving.scenario.pedestrianMesh'
                    setPopupValue(this,'Mesh','Pedestrian');
                case 'driving.scenario.jerseyBarrierMesh'
                    setPopupValue(this,'Mesh','JerseyBarrier');
                case 'driving.scenario.guardrailMesh'
                    setPopupValue(this,'Mesh','Guardrail');
                end
            end

            if info.isMovable
                speed=info.Speed;
                enab=enable;
            else
                speed='';
                enab='off';
            end
            set(this.hSpeed,'Enable',enab,'String',speed);


            this.hOk.Enable=matlabshared.application.logicalToOnOff(validate(this));


            driving.internal.scenarioApp.RCSHelper.updateWidgets(...
            this.hRCSAzimuthAngles,this.hRCSElevationAngles,this.hRCSPattern,info,enable);



            set(this.hDelete,'Enable',deleteEnable);
            set([this.hAdd,this.hCopy,this.hClassList],'Enable',newEnable);
        end

        function b=validate(this)
            info=this.ClassInfo;
            b=~any(arrayfun(@(c)isempty(c.id),info));
        end

        function tag=getTag(~)
            tag='ClassSpecificationEditor';
        end

        function name=getName(~)
            name=getString(message('driving:scenarioApp:ClassSpecificationEditorName'));
        end

        function addNew(this,info)
            allInfo=this.ClassInfo;
            maxId=-inf;
            for indx=1:numel(allInfo)
                maxId=max(allInfo(indx).id,maxId);
            end

            if nargin<2
                info=driving.internal.scenarioApp.ClassSpecifications.getNewSpecification(...
                'name',getString(message('driving:scenarioApp:UserDefinedText')));
            end
            color=info.PlotColor;
            if isempty(color)
                color=lines(1);
            end
            info.LastAssetType='';
            info.LastColor=color;
            info.id=maxId+1;

            allInfo(end+1)=info;
            this.CurrentEntry=numel(allInfo);
            this.ClassInfo=allInfo;
        end
    end

    methods(Hidden)
        function onKeyPress(this,~,ev)
            if strcmp(ev.Key,'escape')
                close(this,true);
            end
        end

        function updateLayout(this)
            panelLayout=this.PanelLayout;

            if this.updatePanel
                row=find(panelLayout.Grid(:,1)==this.hAssetTypeLabel);
                if strcmp(this.ClassInfo(this.CurrentEntry).BarrierType,'None')&&...
                    contains(panelLayout,this.hBarrierType)
                    insert(panelLayout,'row',row+1);
                    add(panelLayout,this.hMeshLabel,row+1,1);
                    add(panelLayout,this.hMesh,row+1,[2,3]);
                    insert(panelLayout,'row',row+2);
                    add(panelLayout,this.hSpeedLabel,row+2,1);
                    add(panelLayout,this.hSpeed,row+2,[2,3]);
                    insert(panelLayout,'row',row+3);
                    add(panelLayout,this.hLengthLabel,row+3,1);
                    add(panelLayout,this.hLength,row+3,[2,3]);
                    insert(panelLayout,'row',row+7);
                    add(panelLayout,this.hUseColorOrder,row+7,[1,2]);
                    remove(panelLayout,row,2);
                    add(panelLayout,this.hAssetType,row,[2,3]);
                    insert(panelLayout,'row',row);
                    add(panelLayout,this.hIsMovable,row,1);
                    set(this.hBarrierType,'Visible','off');
                    set([this.hIsMovable,this.hAssetType,this.hLength,this.hLengthLabel,this.hMesh,this.hMeshLabel,this.hSpeed,this.hSpeedLabel],'Visible','on');
                elseif~strcmp(this.ClassInfo(this.CurrentEntry).BarrierType,'None')&&...
                    ~contains(panelLayout,this.hBarrierType)
                    remove(panelLayout,row+7,1);
                    remove(panelLayout,row+3,1);
                    remove(panelLayout,row+3,2);
                    remove(panelLayout,row+2,1);
                    remove(panelLayout,row+2,2);
                    remove(panelLayout,row+1,1);
                    remove(panelLayout,row+1,2);
                    remove(panelLayout,row-1,1);
                    remove(panelLayout,row,2);
                    add(panelLayout,this.hBarrierType,row,[2,3],'Fill','Horizontal');
                    set(this.hBarrierType,'Visible','on');
                    set([this.hIsMovable,this.hUseColorOrder,this.hAssetType,this.hLength,this.hLengthLabel,this.hMesh,this.hMeshLabel,this.hSpeed,this.hSpeedLabel],'Visible','off');
                    panelLayout.clean();
                    panelLayout.VerticalWeights(end)=1;
                end
            end


            azimLabel=this.hRCSAzimuthAnglesLabel;
            row=find(panelLayout.Grid(:,1)==this.hShowRCSProperties)+1;
            if this.ShowRCSProperties
                if~contains(panelLayout,azimLabel)
                    insert(panelLayout,'row',row);
                    add(panelLayout,azimLabel,row,1);
                    add(panelLayout,this.hRCSAzimuthAngles,row,[2,3]);
                    insert(panelLayout,'row',row+1);
                    add(panelLayout,this.hRCSElevationAnglesLabel,row+1,1);
                    add(panelLayout,this.hRCSElevationAngles,row+1,[2,3]);
                    insert(panelLayout,'row',row+2);
                    add(panelLayout,this.hRCSPatternLabel,row+2,1);
                    insert(panelLayout,'row',row+3);
                    add(panelLayout,this.hRCSPattern,row+3,[1,3]);
                    set([azimLabel,this.hRCSAzimuthAngles,this.hRCSElevationAnglesLabel,this.hRCSElevationAngles,this.hRCSPatternLabel,this.hRCSPattern],'Visible','on');
                end
                setConstraints(this.PanelLayout,row+3,1,...
                'MinimumHeight',20*(size(this.ClassInfo(this.CurrentEntry).RCSPattern,1)+1));
            elseif contains(panelLayout,azimLabel)
                remove(panelLayout,row,1);
                remove(panelLayout,row,2);
                remove(panelLayout,row+1,1);
                remove(panelLayout,row+1,2);
                remove(panelLayout,row+2,1);
                remove(panelLayout,row+3,1);
                set([azimLabel,this.hRCSAzimuthAngles,this.hRCSElevationAnglesLabel,this.hRCSElevationAngles,this.hRCSPatternLabel,this.hRCSPattern],'Visible','off');
                panelLayout.clean();
                panelLayout.VerticalWeights(end)=1;
            end
        end
    end

    methods(Access=protected)
        function fig=createFigure(this)
            fig=createFigure@matlabshared.application.Component(this,...
            'Tag','ClassEditor',...
            'CloseRequestFcn',@this.closeRequestFcn,...
            'Position',getCenterPosition(this.Application,[410,440]));


            app=this.Application;
            icons=getIcon(app);

            panel=uipanel(fig,'Tag','PropertyPanel','BusyAction','cancel');

            addButton=createPushButton(this,fig,'classAdd',@this.addCallback,...
            'CData',icons.add16);
            restoreButton=createPushButton(this,fig,'classRestore',@this.restoreToFactoryCallback,...
            'String',getString(message('driving:scenarioApp:RestoreToFactoryLabel')));

            list=createEditbox(this,fig,'classActorList',@this.listCallback,...
            'listbox','String',{' '});

            nameLabel=createLabelEditPair(this,panel,'Name',@this.nameCallback);
            idLabel=createLabelEditPair(this,panel,'ID',@this.idCallback);

            this.hActorTypeLabel=createLabelEditPair(this,panel,'ActorType',@this.actorTypeCallback,...
            'popupmenu','TooltipString','Specify actor type');

            createCheckbox(this,panel,'IsVehicle',@this.isVehicleCallback,...
            'TooltipString',getString(message('driving:scenarioApp:IsVehicleDescription')));
            createCheckbox(this,panel,'IsMovable',@this.isMovableCallback,...
            'TooltipString',getString(message('driving:scenarioApp:IsMovableDescription')));

            this.hAssetTypeLabel=createLabelEditPair(this,panel,'AssetType',@this.assetTypeCallback,'popupmenu',...
            'TooltipString',getString(message('driving:scenarioApp:AssetTypeDescription')));

            barrierLabel=createLabelEditPair(this,panel,'BarrierType',@this.barrierTypeCallback,'popupmenu',...
            'TooltipString',getString(message('driving:scenarioApp:BarrierTypeDescription')));

            this.hMeshLabel=createLabelEditPair(this,panel,'Mesh',@this.meshCallback,'popupmenu',...
            'TooltipString',getString(message('driving:scenarioApp:MeshDescription')));
            meshTypes=driving.internal.scenarioApp.ClassEditor.getMeshTypes(true);
            setupPopup(this,'Mesh',meshTypes{:});
            setPopupValue(this,'Mesh','Cuboid');

            this.hSpeedLabel=createLabelEditPair(this,panel,'Speed',@this.speedCallback,...
            'TooltipString',getString(message('driving:scenarioApp:DefaultSpeedDescription')));

            this.hLengthLabel=createLabelEditPair(this,panel,'Length',@this.lengthCallback);
            widthLabel=createLabelEditPair(this,panel,'Width',@this.widthCallback);
            heightLabel=createLabelEditPair(this,panel,'Height',@this.heightCallback);

            colorLabel=createLabel(this,panel,'ColorTitle');

            createEditbox(this,panel,'UseColorOrder',@this.colorOrderCallback,'radio');
            setDefaultPanel=uipanel(panel,...
            'BorderType','none',...
            'BusyAction','cancel');

            createEditbox(this,setDefaultPanel,'SetDefaultColor',@this.defaultColorCallback,'radio');
            hDefaultColor=this.hSetDefaultColor;
            w=hDefaultColor.Extent(3)+20;
            h=20;
            set(hDefaultColor,'Position',[0,0,w,h]);

            this.hColorPatch=uipanel(setDefaultPanel,'Tag','ColorPatch',...
            'ButtonDownFcn',@this.colorPickerCallback,...
            'Units','Pixels',...
            'BorderType','line',...
            'HighlightColor',[0,0,0],...
            'BusyAction','cancel',...
            'Interruptible','off',...
            'Position',[w,1,h-1,h-1]);

            createToggle(this,panel,'ShowRCSProperties');

            createPushButton(this,panel,'PatternImport',@this.importRCSCallback,...
            'String',getString(message('driving:scenarioApp:ImportRCSPattern')),...
            'TooltipString',getString(message('driving:scenarioApp:ImportRCSPatternDescription')));
            createLabelEditPair(this,panel,'RCSAzimuthAngles',@this.azimuthCallback,...
            'TooltipString',getString(message('driving:scenarioApp:RCSAzimuthAnglesDescription')));
            createLabelEditPair(this,panel,'RCSElevationAngles',@this.elevationCallback,...
            'TooltipString',getString(message('driving:scenarioApp:RCSElevationAnglesDescription')));
            createLabelEditPair(this,panel,'RCSPattern',@this.patternCallback,'table','Visible','off','Tag','ClassEditor.RCSPattern');

            buttonPanel=uipanel(panel,'BusyAction','cancel',...
            'BorderType','none','Tag','ButtonPanel');

            buttonSize=22;

            deleteButton=createPushButton(this,buttonPanel,'classDeleteBtn',@this.deleteCallback,...
            'CData',icons.delete16,...
            'Position',[1,1,buttonSize,buttonSize],...
            'TooltipString',getString(message('driving:scenarioApp:DeleteActorClass')));
            copyButton=createPushButton(this,buttonPanel,'classCopyBtn',@this.copyCallback,...
            'CData',icons.copy16,...
            'Position',[buttonSize+5,1,buttonSize,buttonSize],...
            'TooltipString',getString(message('driving:scenarioApp:CopyActorClass')));

            createCheckbox(this,panel,'SetAsPreference');

            okButton=createPushButton(this,panel,'classOkBtn',@this.okCallback,...
            'Style','pushbutton',...
            'String',getString(message('MATLAB:uistring:popupdialogs:OK')));

            cancelButton=createPushButton(this,panel,'classCancelBtn',@this.cancelCallback,...
            'Style','pushbutton',...
            'String',getString(message('Spcuilib:application:Cancel')));

            figureLayout=matlabshared.application.layout.GridBagLayout(fig,...
            'HorizontalGap',3,...
            'VerticalGap',3,...
            'HorizontalWeights',[0,0,1,2,0,0],...
            'VerticalWeights',[0,1,0]);

            buttonWidth=figureLayout.getMinimumWidth([okButton,cancelButton])+figureLayout.ButtonPadding;

            add(figureLayout,addButton,1,[1,3],...
            'Anchor','West');
            add(figureLayout,restoreButton,1,[4,6],...
            'Anchor','East',...
            'MinimumWidth',figureLayout.getMinimumWidth(restoreButton)+figureLayout.ButtonPadding);
            add(figureLayout,list,2,[1,3],...
            'Fill','Both',...
            'MinimumWidth',100);
            add(figureLayout,panel,2,[4,6],...
            'LeftInset',-5,...
            'BottomInset',-1,...
            'Fill','Both');
            add(figureLayout,this.hSetAsPreference,3,[1,4],...
            'Fill','Horizontal',...
            'Anchor','West');
            add(figureLayout,okButton,3,5,...
            'MinimumWidth',buttonWidth);
            add(figureLayout,cancelButton,3,6,...
            'MinimumWidth',buttonWidth);

            panelLayout=matlabshared.application.layout.ScrollableGridBagLayout(panel,...
            'HorizontalGap',3,...
            'VerticalGap',3,...
            'HorizontalWeights',[0,1,0],...
            'VerticalWeights',[zeros(1,15),1,0]);

            labelConstraints={...
            'TopInset',panelLayout.LabelOffset,...
            'Anchor','West',...
            'MinimumWidth',panelLayout.getMinimumWidth([nameLabel,idLabel,this.hActorTypeLabel,this.hAssetTypeLabel,this.hMeshLabel,this.hLengthLabel,widthLabel,heightLabel,this.hRCSElevationAnglesLabel,this.hRCSAzimuthAnglesLabel]),...
            'MinimumHeight',20-panelLayout.LabelOffset};
            row=1;
            add(panelLayout,nameLabel,row,1,...
            labelConstraints{:});
            add(panelLayout,this.hName,row,[2,3],...
            'Fill','Horizontal',...
            'TopInset',1);
            row=row+1;
            add(panelLayout,idLabel,row,1,...
            labelConstraints{:});
            add(panelLayout,this.hID,row,[2,3],...
            'Fill','Horizontal');
            row=row+1;
            add(panelLayout,this.hActorTypeLabel,row,1,...
            labelConstraints{:});
            add(panelLayout,this.hActorType,row,[2,3],...
            'Fill','Horizontal');
            row=row+1;
            add(panelLayout,this.hIsMovable,row,1,...
            'Fill','Horizontal');

            row=row+1;
            add(panelLayout,this.hAssetTypeLabel,row,1,...
            labelConstraints{:});
            add(panelLayout,this.hAssetType,row,[2,3],...
            'Fill','Horizontal');

            row=row+1;
            add(panelLayout,this.hMeshLabel,row,1,...
            labelConstraints{:});
            add(panelLayout,this.hMesh,row,[2,3],...
            'Fill','Horizontal');

            row=row+1;
            add(panelLayout,this.hSpeedLabel,row,1,...
            labelConstraints{:});
            add(panelLayout,this.hSpeed,row,[2,3],...
            'Fill','Horizontal');
            row=row+1;
            add(panelLayout,this.hLengthLabel,row,1,...
            labelConstraints{:});
            add(panelLayout,this.hLength,row,[2,3],...
            'Fill','Horizontal');
            row=row+1;
            add(panelLayout,widthLabel,row,1,...
            labelConstraints{:});
            add(panelLayout,this.hWidth,row,[2,3],...
            'Fill','Horizontal');
            row=row+1;
            add(panelLayout,heightLabel,row,1,...
            labelConstraints{:});
            add(panelLayout,this.hHeight,row,[2,3],...
            'Fill','Horizontal');

            row=row+1;
            add(panelLayout,colorLabel,row,[1,3],...
            labelConstraints{:},...
            'Fill','Horizontal');

            row=row+1;
            add(panelLayout,this.hUseColorOrder,row,[1,3],...
            'LeftInset',5,...
            'TopInset',-4,...
            'Fill','Horizontal');

            row=row+1;
            add(panelLayout,setDefaultPanel,row,[1,3],...
            'LeftInset',5,...
            'BottomInset',1,...
            'Fill','Horizontal');

            row=row+1;
            add(panelLayout,this.hShowRCSProperties,row,[1,2],...
            'Fill','Horizontal',...
            'MinimumWidth',panelLayout.getMinimumWidth(this.hShowRCSProperties)+20);
            add(panelLayout,this.hPatternImport,row,3,...
            'MinimumWidth',panelLayout.getMinimumWidth(this.hPatternImport)+20,...
            'Anchor','East');
            row=row+1;
            add(panelLayout,this.hRCSAzimuthAnglesLabel,row,1,...
            labelConstraints{:});
            add(panelLayout,this.hRCSAzimuthAngles,row,[2,3],...
            'Fill','Horizontal');
            row=row+1;
            add(panelLayout,this.hRCSElevationAnglesLabel,row,1,...
            labelConstraints{:});
            add(panelLayout,this.hRCSElevationAngles,row,[2,3],...
            'Fill','Horizontal');
            row=row+1;
            add(panelLayout,this.hRCSPatternLabel,row,[1,3],...
            labelConstraints{:},...
            'Fill','Horizontal');
            row=row+1;
            add(panelLayout,this.hRCSPattern,row,[1,3],...
            'MinimumHeight',100,...
            'TopInset',-6,...
            'Fill','Both');

            row=row+1;
            add(panelLayout,buttonPanel,row,[1,2],...
            'Anchor','SouthWest',...
            'MinimumHeight',buttonSize,...
            'Fill','Horizontal');

            panelLayout.VerticalWeights=[zeros(1,row-2),1,0];

            this.Layout=figureLayout;
            this.PanelLayout=panelLayout;
            this.hClassList=list;
            this.hDelete=deleteButton;
            this.hCopy=copyButton;
            this.hAdd=addButton;
            this.hRestoreFactory=restoreButton;
            this.hOk=okButton;
            update(panelLayout,true);
        end

        function varargout=updateClassInfoFromMap(this,map)
            ids=keys(map);
            for indx=1:numel(ids)
                idInfo=map(ids{indx});
                idInfo.id=ids{indx};
                color=idInfo.PlotColor;
                if isempty(color)
                    color=lines(1);
                end
                idInfo.LastColor=color;
                idInfo.LastAssetType='';
                info(indx)=idInfo;
            end

            if nargout==0
                this.ClassInfo=info;
            else
                varargout={info};
            end
        end

        function closeRequestFcn(this,~,~)
            close(this,true);
        end

        function addCallback(this,~,~)
            addNew(this);

            update(this);
        end

        function colorOrderCallback(this,~,~)
            this.hSetDefaultColor.Value=0;
            info=this.ClassInfo;
            index=this.CurrentEntry;
            if~isempty(info(index).PlotColor)
                info(index).LastColor=info(index).PlotColor;
            end
            info(index).PlotColor=[];
            this.ClassInfo=info;
            update(this);
        end

        function defaultColorCallback(this,~,~)
            this.hUseColorOrder.Value=0;
            drawnow;
            info=this.ClassInfo;
            index=this.CurrentEntry;
            if isempty(info(index).PlotColor)
                info(index).PlotColor=info(index).LastColor;
                this.ClassInfo=info;
                update(this);
            end
        end

        function colorPickerCallback(this,h,~)
            if strcmp(getappdata(h,'Enable'),'off')
                return;
            end
            this.hUseColorOrder.Value=0;
            this.hSetDefaultColor.Value=0;
            info=this.ClassInfo;
            index=this.CurrentEntry;
            color=info(index).PlotColor;
            if isempty(color)
                color=info(index).LastColor;
            end
            if isempty(color)
                inputs={};
            else
                inputs={color};
            end
            c=uisetcolor(inputs{:});

            if~isequal(c,0)
                info(index).PlotColor=c;
                this.ClassInfo=info;
            end
            update(this);
        end

        function restoreToFactoryCallback(this,~,~)
            updateClassInfoFromMap(this,driving.internal.scenarioApp.ClassSpecifications.getFactoryClassMap);
            update(this);
        end

        function deleteCallback(this,~,~)
            this.ClassInfo(this.CurrentEntry)=[];
            update(this);
        end

        function copyCallback(this,~,~)
            info=this.ClassInfo(this.CurrentEntry);
            info.name=getString(message('driving:scenarioApp:CopyOfTarget',info.name));
            addNew(this,info);
            this.CurrentEntry=numel(this.ClassInfo);
            update(this);
        end

        function listCallback(this,~,~)
            oldBarrierType=this.ClassInfo(this.CurrentEntry).BarrierType;
            this.CurrentEntry=this.hClassList.Value;
            newBarrierType=this.ClassInfo(this.CurrentEntry).BarrierType;

            this.updatePanel=sum(strcmp('None',{oldBarrierType,newBarrierType})==1)==1;
            update(this);
            updateLayout(this);
        end

        function nameCallback(this,hName,~)
            newName=hName.String;
            if isempty(newName)
                update(this);
                id='driving:scenarioApp:InvalidName';
                errorMessage(this,getString(message(id)),id);
                return;
            end
            this.ClassInfo(this.CurrentEntry).name=newName;

            update(this);
        end

        function idCallback(this,hID,~)
            info=this.ClassInfo;
            newId=str2double(hID.String);
            msg=[];
            if isnan(newId)||isinf(newId)||isempty(newId)||fix(newId)~=newId
                msg=message('driving:scenarioApp:BadInteger','ClassID');
            end

            actorSpecs=this.Application.ActorSpecifications;
            usedIDs=[actorSpecs.ClassID];




            foundIndex=find(cellfun(@(c)isequal(c,newId),{info.id}),1,'first');
            if this.NewMode&&~isempty(foundIndex)&&foundIndex~=this.CurrentEntry
                msg=message('driving:scenarioApp:ClassIDAlreadyUsed',info(foundIndex).name);
            end

            if any(usedIDs==newId)
                msg=message('driving:scenarioApp:ClassIDAlreadyUsedByActor');
            end
            if~isempty(msg)
                update(this);
                errorMessage(this,getString(msg),msg.Identifier);
                return
            end

            if~isempty(foundIndex)
                info(foundIndex).id=[];
            end
            info(this.CurrentEntry).id=newId;

            this.ClassInfo=info;


            update(this);
        end

        function speedCallback(this,hSpeed,~)
            newSpeed=str2double(hSpeed.String);
            if isnan(newSpeed)||isinf(newSpeed)||newSpeed<=0||~isreal(newSpeed)
                id='driving:scenarioApp:BadSingleSpeed';
                update(this);
                errorMessage(this,getString(message(id)),id);
                return
            end
            this.ClassInfo(this.CurrentEntry).Speed=newSpeed;
            update(this);
        end

        function lengthCallback(this,hLength,~)
            newLength=str2double(hLength.String);
            spec=driving.internal.scenarioApp.ActorSpecification;
            [id,str]=spec.validateLength(newLength,this.ClassInfo(this.CurrentEntry).isVehicle);
            if~isempty(str)
                update(this);
                errorMessage(this,str,id);
                return
            end
            this.ClassInfo(this.CurrentEntry).Length=newLength;
            update(this);
        end

        function widthCallback(this,hWidth,~)
            newWidth=str2double(hWidth.String);
            if strcmp(this.ClassInfo(this.CurrentEntry).BarrierType,'None')
                spec=driving.internal.scenarioApp.ActorSpecification;
                [id,str]=spec.validateWidth(newWidth,this.ClassInfo(this.CurrentEntry).isVehicle);
            else
                spec=driving.internal.scenarioApp.BarrierSpecification;
                [id,str]=spec.validateWidth(newWidth);
            end
            if~isempty(str)
                update(this);
                errorMessage(this,str,id);
                return
            end
            this.ClassInfo(this.CurrentEntry).Width=newWidth;
            update(this);
        end

        function heightCallback(this,hHeight,~)
            newHeight=str2double(hHeight.String);
            if strcmp(this.ClassInfo(this.CurrentEntry).BarrierType,'None')
                spec=driving.internal.scenarioApp.ActorSpecification;
                [id,str]=spec.validateHeight(newHeight,this.ClassInfo(this.CurrentEntry).isVehicle);
            else
                spec=driving.internal.scenarioApp.BarrierSpecification;
                [id,str]=spec.validateHeight(newHeight);
            end
            if~isempty(str)
                update(this);
                errorMessage(this,str,id);
                return
            end
            this.ClassInfo(this.CurrentEntry).Height=newHeight;
            update(this);
        end

        function segmentGapCallback(this,hSegmentGap,~)
            newSegmentGap=str2double(hSegmentGap.String);
            this.ClassInfo(this.CurrentEntry).SegmentGap=newSegmentGap;
            update(this);
        end

        function patternCallback(this,hPattern,~)
            newPattern=hPattern.Data;
            if any(isnan(newPattern(:)))||any(isinf(newPattern(:)))
                id='driving:scenarioApp:BadRCSPattern';
                update(this);
                errorMessage(this,getString(message(id)),id);
                return;
            end
            this.ClassInfo(this.CurrentEntry).RCSPattern=hPattern.Data;
        end

        function elevationCallback(this,hElevation,~)
            info=this.ClassInfo(this.CurrentEntry);
            try
                [info.RCSElevationAngles,info.RCSPattern]=...
                driving.internal.scenarioApp.RCSHelper.parseElevation(...
                hElevation.String,info.RCSPattern);
            catch me
                update(this);
                errorMessage(this,me.message,me.identifier);
                return;
            end
            this.ClassInfo(this.CurrentEntry)=info;
            update(this);
            updateLayout(this);
        end

        function azimuthCallback(this,hAzimuth,~)
            info=this.ClassInfo(this.CurrentEntry);
            try
                [info.RCSAzimuthAngles,info.RCSPattern]=...
                driving.internal.scenarioApp.RCSHelper.parseAzimuth(...
                hAzimuth.String,info.RCSPattern);
            catch me
                update(this);
                errorMessage(this,me.message,me.identifier);
                return;
            end
            this.ClassInfo(this.CurrentEntry)=info;
            update(this);
            updateLayout(this);
        end

        function importRCSCallback(this,~,~)
            info=this.ClassInfo(this.CurrentEntry);

            [az,el,pattern]=driving.internal.scenarioApp.RCSHelper.import(...
            numel(info.RCSAzimuthAngles),numel(info.RCSElevationAngles),this.Figure);
            if~isempty(az)
                info.RCSAzimuthAngles=az;
            end
            if~isempty(el)
                info.RCSElevationAngles=el;
            end
            if~isempty(pattern)
                info.RCSPattern=pattern;
            end

            this.ClassInfo(this.CurrentEntry)=info;
            update(this);
        end

        function isVehicleCallback(this,hIsVehicle,~)
            info=this.ClassInfo(this.CurrentEntry);
            info.isVehicle=hIsVehicle;
            info.BarrierType='None';
            assets=driving.scenario.internal.GamingEngineScenarioAnimator.getAssetTypes(info.isVehicle);
            if~any(strcmp(info.AssetType,assets))
                if any(strcmp(info.LastAssetType,assets))
                    info.AssetType=info.LastAssetType;
                else
                    info.LastAssetType=info.AssetType;
                    info.AssetType=assets{1};
                end
            end
            this.ClassInfo(this.CurrentEntry)=info;
            update(this);
        end

        function assetTypeCallback(this,~,~)
            this.ClassInfo(this.CurrentEntry).AssetType=getPopupValue(this,'AssetType');
        end

        function isMovableCallback(this,hIsMovable,~)
            this.ClassInfo(this.CurrentEntry).isMovable=hIsMovable.Value;
            update(this);
        end

        function actorTypeCallback(this,~,~)
            oldBarrierType=this.ClassInfo(this.CurrentEntry).BarrierType;
            val=getPopupValue(this,'ActorType');
            switch val
            case 'Vehicle'
                this.ClassInfo(this.CurrentEntry).Mesh=driving.scenario.carMesh;
                isVehicleCallback(this,true);
            case 'Other'
                this.ClassInfo(this.CurrentEntry).Mesh=driving.scenario.bicycleMesh;
                isVehicleCallback(this,false);
            case 'Barrier'
                info=this.ClassInfo(this.CurrentEntry);
                info.AssetType='Barrier';
                info.Mesh=driving.scenario.jerseyBarrierMesh;
                info.isVehicle=false;
                info.isMovable=false;
                info.BarrierType='Jersey Barrier';
                info=driving.internal.scenarioApp.BarrierSpecification.setDefaultBarrierProperties(info);
                this.ClassInfo(this.CurrentEntry)=info;
                update(this);
            end
            newBarrierType=this.ClassInfo(this.CurrentEntry).BarrierType;

            this.updatePanel=sum(strcmp('None',{oldBarrierType,newBarrierType})==1)==1;
            updateLayout(this);
        end

        function barrierTypeCallback(this,~,~)
            val=getPopupValue(this,'BarrierType');
            info=this.ClassInfo(this.CurrentEntry);
            info.isVehicle=false;
            info.isMovable=false;
            info.Length=5;
            switch val
            case 'JerseyBarrier'
                info.BarrierType='Jersey Barrier';
            case 'Guardrail'
                info.BarrierType='Guardrail';
            end
            info=driving.internal.scenarioApp.BarrierSpecification.setDefaultBarrierProperties(info);
            this.ClassInfo(this.CurrentEntry)=info;
            update(this);
        end

        function okCallback(this,~,~)
            if validate(this)
                msg=getCurrentMessage(this);

                if~isempty(msg)&&strcmp(msg.type,'error')
                    if this.CurrentObjectAtError==this.hOk
                        this.CurrentObjectAtError=-1;
                        return
                    end
                end
                hApp=this.Application;
                info=this.ClassInfo;
                if~isequal(info,updateClassInfoFromMap(this,hApp.ClassSpecifications.Map))
                    info=rmfield(this.ClassInfo,{'LastColor','LastAssetType'});
                    updateClassSpecifications(hApp,info);
                end
                if this.SetAsPreference
                    saveAsPreference(hApp.ClassSpecifications);
                end
                close(this,false);
            end
        end

        function cancelCallback(this,~,~)
            close(this,true);
        end

        function meshCallback(this,~,~)
            val=getPopupValue(this,'Mesh');
            info=this.ClassInfo(this.CurrentEntry);
            switch val
            case 'Cuboid'
                info.Mesh=extendedObjectMesh('cuboid');
            case 'Car'
                info.Mesh=driving.scenario.carMesh;
            case 'Truck'
                info.Mesh=driving.scenario.truckMesh;
            case 'Bicycle'
                info.Mesh=driving.scenario.bicycleMesh;
            case 'Pedestrian'
                info.Mesh=driving.scenario.pedestrianMesh;
            end
            this.ClassInfo(this.CurrentEntry)=info;
            update(this);
        end
    end

    methods(Static)
        function meshTypes=getMeshTypes(isVehicle,barrierType)
            if nargin<2
                barrierType='None';
            end
            if isVehicle
                meshTypes={'Cuboid','Car','Truck'};
            elseif~strcmp(barrierType,'None')
                meshTypes={'JerseyBarrier','Guardrail'};
            else
                meshTypes={'Cuboid','Bicycle','Pedestrian'};
            end
        end

        function meshStr=getMeshExpression(mesh,isVehicle,dims)


            if~isempty(mesh)&&any(strcmp(mesh.ID,["driving.scenario.carMesh",...
                "driving.scenario.truckMesh","driving.scenario.bicycleMesh",...
                "driving.scenario.pedestrianMesh","driving.scenario.jerseyBarrierMesh",...
                "driving.scenario.guardrailMesh"]))


                meshStr=char(mesh.ID);
            else


                if isempty(mesh)||isMeshEqual(mesh,extendedObjectMesh('cuboid'))||isMeshEqual(mesh,getScaledMesh(dims,extendedObjectMesh('cuboid'),isVehicle))
                    meshStr='';
                elseif isMeshEqual(mesh,driving.scenario.carMesh)||isMeshEqual(mesh,getScaledMesh(dims,driving.scenario.carMesh,isVehicle))
                    meshStr='driving.scenario.carMesh';
                elseif isMeshEqual(mesh,driving.scenario.truckMesh)||isMeshEqual(mesh,getScaledMesh(dims,driving.scenario.truckMesh,isVehicle))
                    meshStr='driving.scenario.truckMesh';
                elseif isMeshEqual(mesh,driving.scenario.bicycleMesh)||isMeshEqual(mesh,getScaledMesh(dims,driving.scenario.bicycleMesh,isVehicle))
                    meshStr='driving.scenario.bicycleMesh';
                elseif isMeshEqual(mesh,driving.scenario.pedestrianMesh)||isMeshEqual(mesh,getScaledMesh(dims,driving.scenario.pedestrianMesh,isVehicle))
                    meshStr='driving.scenario.pedestrianMesh';
                elseif isMeshEqual(mesh,driving.scenario.jerseyBarrierMesh)||isMeshEqual(mesh,getScaledMesh(dims,driving.scenario.jerseyBarrierMesh,isVehicle))
                    meshStr='driving.scenario.jerseyBarrierMesh';
                elseif isMeshEqual(mesh,driving.scenario.guardrailMesh)||isMeshEqual(mesh,getScaledMesh(dims,driving.scenario.guardrailMesh,isVehicle))
                    meshStr='driving.scenario.guardrailMesh';
                else
                    meshStr='';
                end
            end
        end

        function actorTypes=getActorTypes()

            actorTypes={'Vehicle','Barrier','Other'};
        end
    end
end

function mesh=getScaledMesh(dims,prebuiltMesh,isVehicle)
    if isVehicle
        originOffset=[dims.RearOverhang-dims.Length/2,0,0]+[0,0,-dims.Height/2];
    else
        originOffset=[0,0,-dims.Height/2];
    end
    mesh=scaleToFit(prebuiltMesh,struct('Length',dims.Length,...
    'Height',dims.Height,...
    'Width',dims.Width,...
    'OriginOffset',originOffset));
end

function b=isMeshEqual(aMesh,bMesh)

    b=true;
    if~isequal(aMesh.Faces,bMesh.Faces)
        b=false;
        return;
    end
    aMeshVert=aMesh.Vertices;
    bMeshVert=bMesh.Vertices;
    if size(aMeshVert)~=size(bMeshVert)
        b=false;
        return;
    end
    if any(abs(aMeshVert-bMeshVert)>1e-4)
        b=false;
        return;
    end

end


