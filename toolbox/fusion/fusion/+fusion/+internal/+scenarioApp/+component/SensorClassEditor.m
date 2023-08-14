classdef SensorClassEditor<fusion.internal.scenarioApp.component.ClassEditor&...
    fusion.internal.scenarioApp.component.HasSensorClassProperties


    properties(Hidden)
hClassName
hID
hUpdateRate
hCopyCurrent
PanelLayout
    end

    methods
        function this=SensorClassEditor(varargin)
            this@fusion.internal.scenarioApp.component.ClassEditor(varargin{:});
            refresh(this);
        end

        function tag=getTag(~)
            tag='SensorClassEditor';
        end

        function name=getName(this)
            name=getString(message(strcat(this.ResourceCatalog,this.getTag)));
        end

        function[str,id]=msgString(this,key,varargin)
            id=strcat(this.ResourceCatalog,'SensorProperty',key);
            str=getString(message(id,varargin{:}));
        end
    end

    methods

        function refresh(this)
            classSpecs=this.Application.getSensorClassSpecifications();
            updateClassInfoFromMap(this,classSpecs.Map);
        end

        function update(this)
            app=this.Application;


            clearAllMessages(this);


            updateClassList(this);


            allInfo=this.ClassInfo;
            specs=app.getAllSensors;
            usedIDs=[specs.ClassID];
            buffer=app.CopyPasteBuffer;
            isBufferSensor=isa(buffer,'fusion.internal.scenarioApp.dataModel.SensorSpecification');
            if isBufferSensor
                usedIDs=[usedIDs,buffer.ClassID];
            end
            info=allInfo(this.CurrentEntry);
            if any(usedIDs==info.id)
                enable='off';
            else
                enable='on';
            end


            this.hDelete.Enable=matlabshared.application.logicalToOnOff(...
            ~any(usedIDs==info.id)&&numel(allInfo)>1);


            this.hRestoreFactory.Enable=matlabshared.application.logicalToOnOff(...
            isempty(specs)&&~isBufferSensor);


            this.hOk.Enable=matlabshared.application.logicalToOnOff(validate(this));


            this.hSetAsPreference.Value=this.SetAsPreference;


            updatePropertyPanel(this,info,enable);


            updateLayout(this);

        end

    end

    methods(Access=protected)

        function updatePropertyPanel(this,info,enable)
            this.hClassName.String=info.name;
            this.hID.String=info.id;
            set([this.hClassName],'Enable',enable);


            updateScanningPanel(this,info,enable);


            updateDetectionPanel(this,info,enable);
        end


        function updatePropertyPanelLayout(this)
            layout=this.PanelLayout;
            clean(layout);

            nextRow=this.insertScanningPanel(layout,5);
            this.insertDetectionParameters(layout,nextRow+1);

            layout.VerticalWeights=[zeros(1,size(layout.Grid,1)-1),1];
            setAllToggleCData(this);
        end
    end


    methods(Hidden)

        function addCallback(this,~,~)
            addNewSensorClass(this.Application);
        end

        function restoreToFactoryCallback(this,~,~)
            updateClassInfoFromMap(this,fusion.internal.scenarioApp.dataModel.SensorClassSpecifications.getFactoryClassMap);
            update(this);
        end

        function deleteCallback(this,~,~)
            this.Application.deleteSensorClassInfo(this.CurrentEntry);
        end

        function copyCallback(this,~,~)
            info=this.ClassInfo(this.CurrentEntry);
            info.name=getString(message(strcat(this.ResourceCatalog,'EditorDefaultCopiedClassName'),info.name));
            addNewSensorClass(this.Application,info);
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
                classSpecs=hApp.getSensorClassSpecifications;
                if~isequal(this.ClassInfo,updateClassInfoFromMap(this,classSpecs.Map))
                    updateSensorClassSpecifications(hApp,this.ClassInfo);
                end
                if this.SetAsPreference
                    saveAsPreference(hApp.getSensorClassSpecifications);
                end
                close(this,false);
            end
        end

        function copyCurrentToClass(this,~,~)
            info=this.Application.currentSensorToClassInfo(this.ClassInfo(this.CurrentEntry));
            if isempty(info)
                id=strcat(this.ResourceCatalog,'EditorNoCurrentAvailable');
                str=getString(message(id,'sensor'));
                warningMessage(this,str,id);
            end
        end


        function defaultEditboxCallback(this,h,~)

            newValue=str2double(h.String);
            curInfo=this.ClassInfo(this.CurrentEntry);
            oldValue=curInfo.(h.Tag);
            if isequal(newValue,oldValue)
                return
            end

            fail=validateNonNegativeProperty(this,newValue);
            if fail
                [str,id]=errorString(this,'BadNonNegInput',msgString(this,h.Tag));
                this.Application.updateSensorClassEditor;
                errorMessage(this,str,id);
                return;
            end
            curInfo.(h.Tag)=newValue;
            this.ClassInfo(this.CurrentEntry)=curInfo;
            this.Application.updateSensorClassEditor;
        end

        function defaultScalarRealCallback(this,h,~)

            newValue=str2double(h.String);
            curInfo=this.ClassInfo(this.CurrentEntry);
            oldValue=curInfo.(h.Tag);
            if isequal(newValue,oldValue)
                return
            end

            fail=validateNumericProperty(this,newValue);
            if fail
                [str,id]=errorString(this,'BadNumericInput',msgString(this,h.Tag));
                this.Application.updateSensorClassEditor;
                errorMessage(this,str,id);
                return;
            end
            curInfo.(h.Tag)=newValue;
            this.ClassInfo(this.CurrentEntry)=curInfo;
            this.Application.updateSensorClassEditor;
        end

        function detectionProbabilityCallback(this,h,~)
            newValue=str2double(h.String);
            curInfo=this.ClassInfo(this.CurrentEntry);
            oldValue=curInfo.DetectionProbability;
            if isequal(newValue,oldValue)
                return
            end

            fail=validateProbability(this,newValue);
            if fail
                [str,id]=this.errorString('BadProbabilityInput',msgString(this,'DetectionProbability'));
                this.Application.updateSensorClassEditor;
                errorMessage(this,str,id);
                return
            end
            curInfo.DetectionProbability=newValue;
            this.ClassInfo(this.CurrentEntry)=curInfo;
            this.Application.updateSensorClassEditor;
        end

        function farCallback(this,h,~)
            newValue=str2double(h.String);
            curInfo=this.ClassInfo(this.CurrentEntry);
            oldValue=curInfo.FalseAlarmRate;
            if isequal(newValue,oldValue)
                return
            end

            fail=validateFAR(this,newValue);
            if fail
                [str,id]=this.errorString('BadFARInput',msgString(this,'FalseAlarmRate'));
                this.Application.updateSensorClassEditor;
                errorMessage(this,str,id);
                return
            end

            curInfo.FalseAlarmRate=newValue;
            this.ClassInfo(this.CurrentEntry)=curInfo;
            this.Application.updateSensorClassEditor;
        end

        function hasPropertyCallback(this,h,~)
            if startsWith(h.Tag,'Has')
                this.ClassInfo(this.CurrentEntry).(h.Tag)=logical(h.Value);
                this.Application.updateSensorClassEditor;
            end
        end

        function maxNumDetCallback(this,h,~)

            newValue=str2double(h.String);
            try
                validateattributes(newValue,{'double'},{'nonnegative','scalar','real','nonnan'});
            catch
                [str,id]=errorString(this,'BadInfNumericInput',msgString(this,h.Tag));
                this.Application.updateSensorClassEditor;
                errorMessage(this,str,id);
                return;
            end
            curInfo=this.ClassInfo(this.CurrentEntry);
            curInfo.MaxNumDetections=newValue;
            this.ClassInfo(this.CurrentEntry)=curInfo;
            this.Application.updateSensorClassEditor;
        end

        function fovCallback(this,~,~)
            fov=getVectorFromWidgets(this,'hFOVAzimuth','hFOVElevation')';
            curInfo=this.ClassInfo(this.CurrentEntry);
            oldfov=curInfo.FieldOfView;
            if isequal(fov(:),oldfov(:))

                return
            end

            if fov(2)<=0||fov(2)>180
                this.Application.updateSensorClassEditor;
                msgID='shared_radarfusion:RemoteSensors:invalidElFOV';
                msgStr=getString(message(msgID));
                errorMessage(this,msgStr,msgID);
                return
            end

            try
                fusionRadarSensor('SensorIndex',1,'FieldOfView',fov);
            catch ME
                this.Application.updateSensorClassEditor;
                errorMessage(this,ME.message,ME.identifier);
                return
            end
            curInfo.FieldOfView=fov;
            this.ClassInfo(this.CurrentEntry)=curInfo;
            this.Application.updateSensorClassEditor;
        end

        function defaultPopupCallback(this,h,~)
            this.ClassInfo(this.CurrentEntry).(h.Tag)=h.String{h.Value};
            this.Application.updateSensorClassEditor;
        end

        function scanRateCallback(this,h,~)
            property='MaxMechanicalScanRate';
            fail=validateNumericProperty(this,str2double(h.String));
            if fail
                [str,id]=this.errorString('BadNumericInput',property);
                this.Application.updateSensorClassEditor;
                errorMessage(this,str,id);
                return
            end
            newValue=this.getVectorFromWidgets('hMaxMechanicalScanRateAz','hMaxMechanicalScanRateEl');


            curInfo=this.ClassInfo(this.CurrentEntry);
            oldValue=curInfo.(property);

            newValue(isnan(newValue))=oldValue(isnan(newValue));
            if isequal(oldValue,newValue)
                return
            end

            if endsWith(h.Tag,'Az')
                testProperty='MaxAzimuthScanRate';
                testValue=newValue(1);
            elseif endsWith(h.Tag,'El')
                testProperty='MaxElevationScanRate';
                testValue=newValue(2);
            end

            try
                fusionRadarSensor('SensorIndex',1,'HasElevation',true,'ScanMode',curInfo.ScanMode,...
                testProperty,testValue);
            catch ME
                this.Application.updateSensorClassEditor;
                errorMessage(this,ME.message,ME.identifier);
                return
            end

            curInfo.(property)=newValue;
            this.ClassInfo(this.CurrentEntry)=curInfo;
            this.Application.updateSensorClassEditor;
        end

        function scanLimitsCallback(this,h,~)
            if startsWith(h.Tag,'MechanicalScan')
                property='MechanicalScanLimits';
                newValue=reshape(this.getVectorFromWidgets(...
                'hMechanicalScanMinAz','hMechanicalScanMaxAz','hMechanicalScanMinEl','hMechanicalScanMaxEl'),...
                2,2)';
            elseif startsWith(h.Tag,'ElectronicScan')
                property='ElectronicScanLimits';
                newValue=reshape(this.getVectorFromWidgets(...
                'hElectronicScanMinAz','hElectronicScanMaxAz','hElectronicScanMinEl','hElectronicScanMaxEl'),...
                2,2)';
            end

            curInfo=this.ClassInfo(this.CurrentEntry);
            oldValue=curInfo.(property);

            fail=validateNumericProperty(this,str2double(h.String));
            if fail
                [str,id]=this.errorString('BadNumericInput',property);
                this.Application.updateSensorClassEditor;
                errorMessage(this,str,id);
                return
            end


            newValue(isnan(newValue))=oldValue(isnan(newValue));
            if isequal(oldValue,newValue)
                return
            end

            if startsWith(h.Tag,'MechanicalScan')&&endsWith(h.Tag,'Az')
                testProperty='MechanicalAzimuthLimits';
                testValue=newValue(1,:);
            elseif startsWith(h.Tag,'MechanicalScan')&&endsWith(h.Tag,'El')
                testProperty='MechanicalElevationLimits';
                testValue=newValue(2,:);
            elseif startsWith(h.Tag,'ElectronicScan')&&endsWith(h.Tag,'Az')
                testProperty='ElectronicAzimuthLimits';
                testValue=newValue(1,:);
            elseif startsWith(h.Tag,'ElectronicScan')&&endsWith(h.Tag,'El')
                testProperty='ElectronicElevationLimits';
                testValue=newValue(2,:);
            end

            if testValue(1)>=testValue(2)
                this.Application.updateSensorClassEditor;
                msgID='shared_radarfusion:RemoteSensors:limitsNondecreasingOrder';
                msgStr=getString(message(msgID,testProperty));
                errorMessage(this,msgStr,msgID);
                return
            end

            try
                fusionRadarSensor('SensorIndex',1,'HasElevation',true,'ScanMode',curInfo.ScanMode,...
                testProperty,testValue);
            catch ME
                this.Application.updateSensorClassEditor;
                errorMessage(this,ME.message,ME.identifier);
                return
            end

            curInfo.(property)=newValue;
            this.ClassInfo(this.CurrentEntry)=curInfo;
            this.Application.updateSensorClassEditor;
        end

    end



    methods(Access=protected)

        function propertyPanel=createPropertyPanel(this,fig)
            hApp=this.Application;
            propertyPanel=uipanel(fig,'Tag','PropertyPanel');


            copyCurrent=createLabel(this,propertyPanel,'CopyCurrentToClass');
            copyCurrent.Tooltip=msgString(this,'CopyCurrentToClassTooltip');
            nameLabel=createLabelEditPair(this,propertyPanel,'ClassName',hApp.initCallback(@this.nameCallback));
            updateLabel=createLabelEditPair(this,propertyPanel,'UpdateRate',hApp.initCallback(@this.defaultEditboxCallback));


            createToggle(this,propertyPanel,'ShowScanningFOVParameters');
            createScanningFOVParametersPanel(this,propertyPanel);

            createToggle(this,propertyPanel,'ShowDetectionParameters');
            createDetectionParametersPanel(this,propertyPanel);


            icons=this.Application.getIcon;
            copyCurrentValues=uicontrol(propertyPanel,...
            'Tag','copySensorToClass',...
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
            'MinimumWidth',panelLayout.getMinimumWidth([nameLabel,updateLabel]),...
            'MinimumHeight',20-panelLayout.LabelOffset};

            row=1;
            add(panelLayout,copyCurrent,row,[1,3],'TopInset',panelLayout.LabelOffset,...
            'Anchor','West',...
            'MinimumWidth',panelLayout.getMinimumWidth(copyCurrent),...
            'MinimumHeight',20-panelLayout.LabelOffset);

            row=this.addrow(panelLayout,copyCurrentValues,row,4,'MinimumHeight',22);
            add(panelLayout,nameLabel,row,1,...
            labelConstraints{:});
            row=this.addrow(panelLayout,this.hClassName,row,[2,4],...
            'Fill','Horizontal',...
            'TopInset',1);

            add(panelLayout,updateLabel,row,1,...
            labelConstraints{:});
            row=this.addrow(panelLayout,this.hUpdateRate,row,[2,4],...
            'Fill','Horizontal');

            row=this.addrow(panelLayout,this.hShowScanningFOVParameters,row,[1,4],'Fill','Horizontal');

            this.addrow(panelLayout,this.hShowDetectionParameters,row,[1,4],'Fill','Horizontal','Anchor','NorthWest');

            panelLayout.VerticalWeights=[zeros(1,row-1),1];
            this.PanelLayout=panelLayout;

        end

    end
end