classdef PlatformClassEditor<fusion.internal.scenarioApp.component.ClassEditor&...
    fusion.internal.scenarioApp.component.HasPlatformClassProperties

    properties(Hidden)
hClassName
hID
hCategory
hDefaultSpeed
PanelLayout
    end

    methods
        function this=PlatformClassEditor(varargin)
            this@fusion.internal.scenarioApp.component.ClassEditor(varargin{:});
            refresh(this);
        end

        function tag=getTag(~)
            tag='PlatformClassEditor';
        end

        function name=getName(this)
            name=getString(message(strcat(this.ResourceCatalog,this.getTag)));
        end

        function str=msgString(this,key,varargin)
            str=getString(message(strcat(this.ResourceCatalog,'PlatformProperty',key),varargin{:}));
        end
    end

    methods

        function refresh(this)
            classSpecs=this.Application.getPlatformClassSpecifications();
            updateClassInfoFromMap(this,classSpecs.Map);
        end

        function update(this)
            app=this.Application;


            clearAllMessages(this);


            updateClassList(this);


            allInfo=this.ClassInfo;
            platformSpecs=app.getPlatforms;
            usedIDs=[platformSpecs.ClassID];
            buffer=app.CopyPasteBuffer;
            isBufferPlatform=isa(buffer,'fusion.internal.scenarioApp.dataModel.PlatformSpecification');
            if isBufferPlatform
                usedIDs=[usedIDs,buffer.ClassID];
            end
            info=allInfo(this.CurrentEntry);
            if any(usedIDs==info.id)
                enable='off';
            else
                enable='on';
            end

            set([this.hClassName,this.hID,this.hLength,this.hWidth...
            ,this.hHeight,this.hCategory,this.hXOffset,this.hYOffset...
            ,this.hZOffset,this.hRollAccuracy,this.hPitchAccuracy...
            ,this.hYawAccuracy,this.hPositionAccuracy,this.hVelocityAccuracy...
            ,this.hImportSignature,this.hConstantSignature,this.hConstantRCS],...
            'Enable',enable);


            this.hDelete.Enable=matlabshared.application.logicalToOnOff(...
            ~any(usedIDs==info.id)&&numel(allInfo)>1);


            this.hRestoreFactory.Enable=matlabshared.application.logicalToOnOff(...
            isempty(platformSpecs)&&~isBufferPlatform);


            this.hOk.Enable=matlabshared.application.logicalToOnOff(validate(this));


            updatePropertyPanel(this,info,enable);

        end

    end

    methods(Access=protected)

        function updatePropertyPanel(this,info,enable)

            setToggleValue(this,'SetAsPreference',this.SetAsPreference)
            setToggleValue(this,'ShowDimensions',this.ShowDimensions)
            setToggleValue(this,'ShowOffset',this.ShowOffset)
            setToggleValue(this,'ShowPoseEstimatorAccuracy',this.ShowPoseEstimatorAccuracy)
            setToggleValue(this,'ShowSignatures',this.ShowSignatures)

            if isempty(info)
                resetPropertyPanel(this);
                updateLayout(this);
                return
            end



            this.hClassName.String=info.name;
            this.hID.String=info.id;
            categoryEnable=matlabshared.application.logicalToOnOff(...
            ~any(strcmp(info.name,{'Plane','Boat','Car','Tower'})));
            set(this.hCategory,'Enable',categoryEnable,...
            'String',{'Air','Ground','Maritime'});
            set(this.hCategory,...
            'Value',find(cellfun(@(s)strcmpi(s,info.Category),this.hCategory.String)));

            set(this.hDefaultSpeed,'String',info.DefaultSpeed);

            dimension=[info.Length,info.Width,info.Height,info.XOffset,info.YOffset,info.ZOffset];
            orientationAccuracy=info.OrientationAccuracy;
            positionAccuracy=info.PositionAccuracy;
            velocityAccuracy=info.VelocityAccuracy;

            set(this.hLength,'String',dimension(1));
            set(this.hWidth,'String',dimension(2));
            set(this.hHeight,'String',dimension(3));
            set(this.hXOffset,'String',dimension(4));
            set(this.hYOffset,'String',dimension(5));
            set(this.hZOffset,'String',dimension(6));
            set(this.hRollAccuracy,'String',orientationAccuracy(1));
            set(this.hPitchAccuracy,'String',orientationAccuracy(2));
            set(this.hYawAccuracy,'String',orientationAccuracy(3));
            set(this.hPositionAccuracy,'String',positionAccuracy);
            set(this.hVelocityAccuracy,'String',velocityAccuracy);


            updateSignaturePanel(this,info.RCSSignature,enable);


            updateLayout(this);
        end

        function updateSignaturePanel(this,signature,enable)

            updateSignatureRadio(this)

            this.hConstantRCS.Enable=matlabshared.application.logicalToOnOff(...
            this.hConstantSignature.Value&&matlab.lang.OnOffSwitchState(enable));
            if this.hConstantSignature.Value==1
                this.hConstantRCS.String=signature.Pattern(1);
            end
        end


        function updatePropertyPanelLayout(this)
            layout=this.PanelLayout;
            nextRow=insertDimensionPanel(this,6);
            nextRow=this.insertPanel(layout,'PoseEstimatorAccuracy',nextRow+1);
            this.insertPanel(layout,'Signatures',nextRow+1);
            layout.VerticalWeights=[zeros(1,size(layout.Grid,1)-1),1];
            setAllToggleCData(this);
        end

        function nextRow=insertDimensionPanel(this,row)
            layout=this.PanelLayout;
            dimensionLayout=this.DimensionsLayout;
            nextRow=this.insertPanel(layout,'Dimensions',row);
            this.insertPanel(dimensionLayout,'Offset',4);
            [~,h]=getMinimumSize(dimensionLayout);
            if this.ShowDimensions
                layout.setConstraints(row,1,'MinimumHeight',h);
            end

        end

    end


    methods(Hidden)

        function addCallback(this,~,~)
            addNewPlatformClass(this.Application);
        end

        function restoreToFactoryCallback(this,~,~)
            updateClassInfoFromMap(this,fusion.internal.scenarioApp.dataModel.PlatformClassSpecifications.getFactoryClassMap);
            update(this);
        end

        function deleteCallback(this,~,~)
            this.Application.deleteClassInfo(this.CurrentEntry);
        end

        function copyCallback(this,~,~)
            info=this.ClassInfo(this.CurrentEntry);
            info.name=getString(message(strcat(this.ResourceCatalog,'EditorDefaultCopiedClassName'),info.name));
            addNewPlatformClass(this.Application,info);
        end

        function categoryCallback(this,h,~)
            cat=h.String{h.Value};
            this.ClassInfo(this.CurrentEntry).Category=cat;
        end

        function idCallback(this,hID,~)
            info=this.ClassInfo;
            newId=str2double(hID.String);
            msg=[];
            if isnan(newId)||isinf(newId)||isempty(newId)||fix(newId)~=newId
                msg=message(strcat(this.ResourceCatalog,'PlatformProperty','BadID'),'ClassID');
            end

            allSpecs=this.Application.getPlatforms;
            usedIDs=[allSpecs.ClassID];
            foundIndex=find(cellfun(@(c)isequal(c,newId),{info.id}),1,'first');
            if~isempty(foundIndex)&&foundIndex~=this.CurrentEntry
                msg=message(strcat(this.ResourceCatalog,'PlatformProperty','AlreadyUsedID'),info(foundIndex).name);
            end

            if any(usedIDs==newId)
                msg=message(strcat(this.ResourceCatalog,'PlatformProperty','ClassIDAlreadyUsedByActor'));
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
            this.ClassInfo(this.CurrentEntry).DefaultSpeed=newSpeed;
        end

        function dimensionCallback(this,h,~)
            newDimension=getVectorFromWidgets(this,'hLength','hWidth','hHeight',...
            'hXOffset','hYOffset','hZOffset');
            info=this.ClassInfo(this.CurrentEntry);
            oldDimension=[info.Length,info.Width,info.Height];
            if isequal(newDimension,oldDimension)

                return
            end

            newValue=str2double(h.String);
            if any(strcmp(h.Tag(1),{'X','Y','Z'}))

                fail=validateNumericProperty(this,newValue);
                if fail
                    [str,id]=errorString(this,'BadNumericInput',msgString(this,h.Tag));
                    this.Application.updatePlatformClassEditor;
                    errorMessage(this,str,id);
                    return;
                end
            else

                fail=validateNonNegativeProperty(this,newValue);
                if fail
                    [str,id]=errorString(this,'BadNonNegInput',msgString(this,h.Tag));
                    this.Application.updatePlatformClassEditor;
                    errorMessage(this,str,id);
                    return;
                end
            end
            info.(h.Tag)=newValue;
            this.ClassInfo(this.CurrentEntry)=info;
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
                classSpecs=hApp.getPlatformClassSpecifications();
                if~isequal(this.ClassInfo,updateClassInfoFromMap(this,classSpecs.Map))
                    updatePlatformClassSpecifications(hApp,this.ClassInfo);
                end
                if this.SetAsPreference
                    saveAsPreference(hApp.getPlatformClassSpecifications);
                end
                close(this,false);
            end
        end

        function copyCurrentToClass(this,~,~)
            info=this.Application.currentPlatformToClassInfo(this.ClassInfo(this.CurrentEntry));
            if isempty(info)
                id=strcat(this.ResourceCatalog,'EditorNoCurrentAvailable');
                str=getString(message(id,'platform'));
                warningMessage(this,str,id);
            end
        end

        function constantrcsCallback(this,h,~)
            newValue=str2double(h.String);
            try
                newSig=rcsSignature('Pattern',newValue);

                newSig=toStruct(newSig);
            catch ME
                id=ME.identifier;
                str=ME.message;
                this.Application.updatePlatformClassEditor;
                errorMessage(this,str,id);
                return
            end
            info=this.ClassInfo(this.CurrentEntry);
            oldSig=info.RCSSignature;
            if isequal(newSig,oldSig)
                return
            end
            this.ClassInfo(this.CurrentEntry).RCSSignature=newSig;

        end

        function signatureRadioCallback(this,h,~)
            oldState=this.RcsState;
            if strcmp(h.Tag,'ConstantSignature')
                newState='constant';
            else
                newState='import';
            end

            if strcmp(oldState,newState)
                updateSignatureRadio(this);
                return
            end

            if strcmp(newState,'import')
                this.RcsState='import';
                updateSignatureRadio(this);
                sig=fusion.internal.scenarioApp.component.SignatureImport.import();
                if isempty(sig)

                    this.RcsState='constant';
                else
                    this.ClassInfo(this.CurrentEntry).RCSSignature=toStruct(sig);
                end
            else
                this.RcsState='constant';
                this.ClassInfo(this.CurrentEntry).RCSSignature=toStruct(rcsSignature('Pattern',str2double(this.hConstantRCS.String)));
            end
            updateSignatureRadio(this);
        end
    end



    methods(Access=protected)

        function propertyPanel=createPropertyPanel(this,fig)
            hApp=this.Application;

            propertyPanel=uipanel(fig,'Tag','PropertyPanel');
            copyCurrent=createLabel(this,propertyPanel,'CopyCurrentToClass');
            copyCurrent.Tooltip=msgString(this,'CopyCurrentToClassTooltip');
            nameLabel=createLabelEditPair(this,propertyPanel,'ClassName',hApp.initCallback(@this.nameCallback));
            idLabel=createLabelEditPair(this,propertyPanel,'ID',hApp.initCallback(@this.idCallback));
            catlabel=createLabelEditPair(this,propertyPanel,'Category',hApp.initCallback(@this.categoryCallback),...
            'popup','String',{'Air','Ground','Maritime'});
            speedLabel=createLabelEditPair(this,propertyPanel,'DefaultSpeed',hApp.initCallback(@this.speedCallback),...
            'TooltipString',this.msgString('DefaultSpeedDescription'));


            createToggle(this,propertyPanel,'ShowDimensions','Value',0);
            createDimensionPanel(this,propertyPanel);


            createToggle(this,propertyPanel,'ShowPoseEstimatorAccuracy');
            createPoseEstimatorPanel(this,propertyPanel);


            createToggle(this,propertyPanel,'ShowSignatures');
            createSignaturePanel(this,propertyPanel);


            icons=this.Application.getIcon;
            copyCurrentValues=uicontrol(propertyPanel,...
            'Tag','copyPlatformToClass',...
            'style','pushbutton',...
            'CData',icons.copy_current_16,...
            'Callback',@this.copyCurrentToClass);


            panelLayout=matlabshared.application.layout.ScrollableGridBagLayout(propertyPanel,...
            'HorizontalGap',3,...
            'VerticalGap',3,...
            'HorizontalWeights',[0,0,0,0]);

            labelConstraints={...
            'TopInset',panelLayout.LabelOffset,...
            'Anchor','West',...
            'MinimumWidth',panelLayout.getMinimumWidth([nameLabel,idLabel,catlabel,speedLabel]),...
            'MinimumHeight',20-panelLayout.LabelOffset};

            row=1;
            add(panelLayout,copyCurrent,row,[1,3],'TopInset',panelLayout.LabelOffset,...
            'Anchor','West',...
            'MinimumWidth',panelLayout.getMinimumWidth(copyCurrent),...
            'MinimumHeight',20-panelLayout.LabelOffset);
            row=this.addrow(panelLayout,copyCurrentValues,row,4,'MinimumHeight',22);

            add(panelLayout,nameLabel,row,1,...
            labelConstraints{:});
            add(panelLayout,this.hClassName,row,[2,4],...
            'Fill','Horizontal',...
            'TopInset',1);

            row=row+1;
            add(panelLayout,idLabel,row,1,...
            labelConstraints{:});
            add(panelLayout,this.hID,row,[2,4],...
            'Fill','Horizontal');

            row=row+1;
            add(panelLayout,catlabel,row,1,...
            labelConstraints{:});
            add(panelLayout,this.hCategory,row,[2,4],...
            'Fill','Horizontal');

            row=row+1;
            add(panelLayout,this.hShowDimensions,row,[1,4],'Fill','Horizontal');

            row=row+1;
            add(panelLayout,this.hShowPoseEstimatorAccuracy,row,[1,4],'Fill','Horizontal');

            row=row+1;
            add(panelLayout,this.hShowSignatures,row,[1,4],'Fill','Horizontal');

            row=row+1;
            add(panelLayout,speedLabel,row,1,...
            labelConstraints{:},'Anchor','NorthWest');
            add(panelLayout,this.hDefaultSpeed,row,[2,4],...
            'Fill','Horizontal','Anchor','NorthWest');


            panelLayout.VerticalWeights=[zeros(1,row-1),1];
            this.PanelLayout=panelLayout;

        end

        function createSignaturePanel(this,fig)
            signaturePanel=uipanel(fig,'Visible','Off','BorderType','none');

            radioCb=this.Application.initCallback(@this.signatureRadioCallback);
            createEditbox(this,fig,'ConstantSignature',radioCb,'radio','Tooltip',msgString(this,'SignatureConstantRCSTooltip'));
            createEditbox(this,fig,...
            'ConstantRCS',this.Application.initCallback(@this.constantrcsCallback));

            createEditbox(this,fig,'ImportSignature',radioCb,'radio','Tooltip',msgString(this,'SignatureImportRCSTooltip'));

            signatureLayout=matlabshared.application.layout.GridBagLayout(signaturePanel,...
            'VerticalGap',3,'HorizontalGap',3);

            minHEditBox=50;

            add(signatureLayout,this.hConstantSignature,1,1,'Anchor','West','MinimumWidth',160);
            add(signatureLayout,this.hConstantRCS,1,2,'Anchor','West','MinimumWidth',minHEditBox);
            add(signatureLayout,this.hImportSignature,2,1,'Anchor','West','MinimumWidth',120);
            this.SignaturesLayout=signatureLayout;
            this.hSignaturesPanel=signaturePanel;
        end

    end
end