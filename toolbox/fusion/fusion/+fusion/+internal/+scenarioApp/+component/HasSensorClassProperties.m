classdef HasSensorClassProperties<matlabshared.application.UITools




    properties
        ShowDetectionParameters logical=false
        ShowAdvancedParameters logical=false
        ShowAccuracyAndNoiseSettings logical=false
        ShowScanningFOVParameters logical=false
    end

    properties(Hidden)


hDetectionParametersPanel
hShowDetectionParameters
hDetectionProbability
hFalseAlarmRate
hFOVAzimuth
hFOVElevation
hMaxUnambiguousRange
hHasRangeAmbiguities
hHasRangeRate
hMaxUnambiguousRadialSpeed
hHasRangeRateAmbiguities
hHasElevation
hHasOcclusion


hScanningFOVParametersPanel
hShowScanningFOVParameters
hScanModePanel
hScanMode
hElectronicScanMinAz
hElectronicScanMaxAz
hElectronicScanMinEl
hElectronicScanMaxEl
hMaxMechanicalScanRateAz
hMaxMechanicalScanRateEl
hMechanicalScanMinAz
hMechanicalScanMaxAz
hMechanicalScanMinEl
hMechanicalScanMaxEl
hElecScanLabel
hMechScanLabel
hMaxScanRate


hShowAdvancedParameters
hAdvancedParametersPanel
hReferenceRange
hReferenceRCS
hHasLimitNumDetections
hMaxNumDetections
hDetectionCoordinates


hShowAccuracyAndNoiseSettings
hAccuracyAndNoiseSettingsPanel
hAzimuthResolution
hAzimuthBias
hElevationResolution
hElevationBias
hRangeResolution
hRangeBias
hRangeRateResolution
hRangeRateBias
hHasNoise
hHasFalseAlarms


DetectionParametersLayout
AdvancedParametersLayout
AccuracyAndNoiseSettingsLayout
ScanningFOVParametersLayout
ScanModeLayout

    end


    methods(Access=protected)
        function next=insertScanningPanel(this,layout,row)
            updateScanModeLayout(this);
            next=this.insertPanel(layout,'ScanningFOVParameters',row);
        end

        function next=insertDetectionParameters(this,layout,row)
            detectionLayout=this.DetectionParametersLayout;
            next=this.insertPanel(layout,'DetectionParameters',row);
            inrow=this.insertPanel(detectionLayout,'AdvancedParameters',6);
            this.insertPanel(detectionLayout,'AccuracyAndNoiseSettings',inrow+1);

            if this.ShowDetectionParameters
                [~,h]=getMinimumSize(detectionLayout);
                layout.setConstraints(size(layout.Grid,1),1,'MinimumHeight',h);
                detectionLayout.VerticalWeights=[zeros(1,size(detectionLayout.Grid,1)-1),1];
            end
        end

        function updateScanModeLayout(this)

            layout=this.ScanningFOVParametersLayout;
            options={'Fill','Horizontal'};

            row=5;
            minComps=(row-1)*size(layout.Grid,2);

            numComp=numel(layout.Grid);
            while numComp>minComps
                f=layout.Grid';
                g=f(:);
                if~isnan(g(numComp))
                    set(g(numComp),'Visible','off');
                    remove(layout,g(numComp));
                end
                numComp=numComp-1;
            end


            scanMode=this.hScanMode.String{this.hScanMode.Value};
            width=layout.getMinimumWidth(this.hMechScanLabel);
            switch scanMode

            case 'Mechanical'


                add(layout,this.hMechScanLabel,row,1,options{:},...
                'MinimumWidth',width);
                add(layout,this.hMechanicalScanMinAz,row,2,options{:});
                add(layout,this.hMechanicalScanMaxAz,row,3,options{:});
                add(layout,this.hMechanicalScanMinEl,row,5,options{:});
                add(layout,this.hMechanicalScanMaxEl,row,6,options{:});

                row=row+1;

                add(layout,this.hMaxScanRate,row,1,options{:});
                add(layout,this.hMaxMechanicalScanRateAz,row,[2,3],...
                options{:});
                add(layout,this.hMaxMechanicalScanRateEl,row,[5,6],...
                options{:});

                set([this.hMechScanLabel,this.hMechanicalScanMinAz,...
                this.hMechanicalScanMaxAz,this.hMechanicalScanMinEl,...
                this.hMechanicalScanMaxEl,this.hMaxScanRate,...
                this.hMaxMechanicalScanRateAz,this.hMaxMechanicalScanRateEl],...
                'Visible','on');

            case 'Electronic'
                add(layout,this.hElecScanLabel,row,1,options{:});
                add(layout,this.hElectronicScanMinAz,row,2,options{:});
                add(layout,this.hElectronicScanMaxAz,row,3,options{:});
                add(layout,this.hElectronicScanMinEl,row,5,options{:});
                add(layout,this.hElectronicScanMaxEl,row,6,options{:});

                set([this.hElecScanLabel,this.hElectronicScanMinAz...
                ,this.hElectronicScanMaxAz,this.hElectronicScanMinEl...
                ,this.hElectronicScanMaxEl],'Visible','on');

            case 'Mechanical and electronic'
                add(layout,this.hElecScanLabel,row,1,options{:});
                add(layout,this.hElectronicScanMinAz,row,2,options{:});
                add(layout,this.hElectronicScanMaxAz,row,3,options{:});
                add(layout,this.hElectronicScanMinEl,row,5,options{:});
                add(layout,this.hElectronicScanMaxEl,row,6,options{:});
                row=row+1;

                add(layout,this.hMechScanLabel,row,1,options{:},...
                'MinimumWidth',width);
                add(layout,this.hMechanicalScanMinAz,row,2,options{:});
                add(layout,this.hMechanicalScanMaxAz,row,3,options{:});
                add(layout,this.hMechanicalScanMinEl,row,5,options{:});
                add(layout,this.hMechanicalScanMaxEl,row,6,options{:});

                row=row+1;

                add(layout,this.hMaxScanRate,row,1,options{:});
                add(layout,this.hMaxMechanicalScanRateAz,row,[2,3],...
                options{:});
                add(layout,this.hMaxMechanicalScanRateEl,row,[5,6],...
                options{:});

                set([this.hMechScanLabel,this.hMechanicalScanMinAz,...
                this.hMechanicalScanMaxAz,this.hMechanicalScanMinEl,...
                this.hMechanicalScanMaxEl,this.hMaxScanRate,...
                this.hMaxMechanicalScanRateAz,this.hMaxMechanicalScanRateEl],...
                'Visible','on');
                set([this.hElecScanLabel,this.hElectronicScanMinAz...
                ,this.hElectronicScanMaxAz,this.hElectronicScanMinEl...
                ,this.hElectronicScanMaxEl],'Visible','on');

            otherwise
                clean(layout);
            end
            this.ScanningFOVParametersLayout=layout;
        end

        function updateScanningPanel(this,sensor,enable)


            set(this.hScanMode,'Enable',enable',...
            'String',{'No scanning','Mechanical','Electronic','Mechanical and electronic'});
            set(this.hScanMode,...
            'Value',find(cellfun(@(s)strcmp(s,sensor.ScanMode),this.hScanMode.String)));

            set(this.hFOVAzimuth,'Enable',enable,'String',sensor.FieldOfView(1));
            set(this.hFOVElevation,'Enable',enable,'String',sensor.FieldOfView(2));

            set(this.hMechanicalScanMinAz,'Enable',enable','String',sensor.MechanicalScanLimits(1,1));
            set(this.hMechanicalScanMaxAz,'Enable',enable','String',sensor.MechanicalScanLimits(1,2));
            if sensor.HasElevation
                set(this.hMechanicalScanMinEl,'Enable',enable','String',sensor.MechanicalScanLimits(2,1));
                set(this.hMechanicalScanMaxEl,'Enable',enable','String',sensor.MechanicalScanLimits(2,2));
                set(this.hElectronicScanMinEl,'Enable',enable','String',sensor.ElectronicScanLimits(2,1));
                set(this.hElectronicScanMaxEl,'Enable',enable','String',sensor.ElectronicScanLimits(2,2));
                set(this.hMaxMechanicalScanRateEl,'Enable',enable,'String',sensor.MaxMechanicalScanRate(2));
                set(this.hElevationBias,'Enable',enable,'String',sensor.ElevationBias(1));
                set(this.hElevationResolution,'Enable',enable,'String',sensor.ElevationResolution(1));
            else
                set([this.hMechanicalScanMinEl,this.hMechanicalScanMaxEl,this.hElectronicScanMinEl...
                ,this.hElectronicScanMaxEl,this.hMaxMechanicalScanRateEl...
                ,this.hElevationBias,this.hElevationResolution],'Enable','off','String','');
            end

            set(this.hElectronicScanMinAz,'Enable',enable','String',sensor.ElectronicScanLimits(1,1));
            set(this.hElectronicScanMaxAz,'Enable',enable','String',sensor.ElectronicScanLimits(1,2));

            set(this.hMaxMechanicalScanRateAz,'Enable',enable,'String',sensor.MaxMechanicalScanRate(1));
        end

        function updateDetectionPanel(this,sensor,enable)

            simpleProps={...
            'DetectionProbability','FalseAlarmRate','MaxUnambiguousRange',...
            'MaxUnambiguousRadialSpeed','HasRangeRate','HasRangeAmbiguities',...
            'HasNoise','HasFalseAlarms','HasOcclusion','MaxNumDetections',...
            'ReferenceRange','ReferenceRCS',...
            'AzimuthResolution','AzimuthBias',...
            'RangeResolution','RangeBias','RangeRateResolution','RangeRateBias',...
            'UpdateRate','HasElevation',...
            };
            setupWidgets(this,sensor,simpleProps,enable);


            hasRangeRate=matlabshared.application.logicalToOnOff(sensor.HasRangeRate);
            set([this.hHasRangeRateAmbiguities...
            ,this.hRangeRateBias...
            ,this.hRangeRateResolution],'Enable',hasRangeRate);

            enableRRAmb=matlabshared.application.logicalToOnOff(sensor.HasRangeRate&&...
            (sensor.HasFalseAlarms||sensor.HasRangeRateAmbiguities));
            set(this.hMaxUnambiguousRadialSpeed,'Enable',enableRRAmb);

            enableRAmb=matlabshared.application.logicalToOnOff(...
            (sensor.HasFalseAlarms||sensor.HasRangeAmbiguities));
            set(this.hMaxUnambiguousRange,'Enable',enableRAmb);

        end
    end

    methods(Access=protected)

        function createScanningFOVParametersPanel(this,fig)
            panel=uipanel(fig,'Tag','ScanningFOVPanel','BorderType','none');

            scanModeLabel=createLabelEditPair(this,fig,'ScanMode',...
            this.Application.initCallback(@this.defaultPopupCallback),'popup',...
            'Tooltip',msgString(this,'ScanModeTooltip'));

            azLabel=createLabel(this,panel,'AzimuthScan');
            elLabel=createLabel(this,panel,'ElevationScan');
            haspropertycallback=this.Application.initCallback(@this.hasPropertyCallback);
            createCheckbox(this,panel,'HasElevation',haspropertycallback,'Tooltip',msgString(this,'HasElevationTooltip'));
            fovLabel=this.createLabel(panel,'FOV');

            fovcallback=this.Application.initCallback(@this.fovCallback);
            this.createEditbox(panel,'FOVAzimuth',fovcallback,'Tooltip',msgString(this,'FOVTooltip'));
            this.createEditbox(panel,'FOVElevation',fovcallback,'Tooltip',msgString(this,'FOVTooltip'));

            scanlimcallback=this.Application.initCallback(@this.scanLimitsCallback);
            scanratecallback=this.Application.initCallback(@this.scanRateCallback);
            this.hElecScanLabel=createLabel(this,panel,'ElecScan');
            this.hMechScanLabel=createLabel(this,panel,'MechScan');
            createEditbox(this,panel,'MechanicalScanMinEl',scanlimcallback);
            createEditbox(this,panel,'MechanicalScanMaxAz',scanlimcallback);
            createEditbox(this,panel,'MechanicalScanMaxEl',scanlimcallback);
            createEditbox(this,panel,'MechanicalScanMinAz',scanlimcallback);
            createEditbox(this,panel,'ElectronicScanMinEl',scanlimcallback);
            createEditbox(this,panel,'ElectronicScanMaxAz',scanlimcallback);
            createEditbox(this,panel,'ElectronicScanMaxEl',scanlimcallback);
            createEditbox(this,panel,'ElectronicScanMinAz',scanlimcallback);
            this.hMaxScanRate=createLabel(this,panel,'MaxScanRate');
            createEditbox(this,panel,'MaxMechanicalScanRateAz',scanratecallback);
            createEditbox(this,panel,'MaxMechanicalScanRateEl',scanratecallback);



            layout=matlabshared.application.layout.ScrollableGridBagLayout(panel,...
            'HorizontalGap',3,...
            'VerticalGap',3);
            options={'Fill','Horizontal'};

            row=1;
            add(layout,this.hHasElevation,row,[1,6],options{:});
            row=row+1;
            add(layout,scanModeLabel,row,1,...
            options{:},'TopInset',5);
            add(layout,this.hScanMode,row,[2,6],...
            options{:},'TopInset',5,'Anchor','North');

            row=row+1;
            add(layout,azLabel,row,[2,3],options{:},'TopInset',7,'Anchor','South');
            add(layout,elLabel,row,[5,6],options{:},'TopInset',7,'Anchor','South');

            row=row+1;
            width=layout.getMinimumWidth(this.hMechScanLabel);
            add(layout,fovLabel,row,1,options{:},...
            'MinimumWidth',width);
            add(layout,this.hFOVAzimuth,row,[2,3],options{:});
            add(layout,this.hFOVElevation,row,[5,6],options{:});



            this.hScanningFOVParametersPanel=panel;
            this.ScanningFOVParametersLayout=layout;

        end

        function createDetectionParametersPanel(this,fig)

            panel=uipanel(fig,'Visible','Off','BorderType','none');

            detectionProbabilityLabel=...
            this.createLabelEditPair(panel,'DetectionProbability',...
            this.Application.initCallback(@this.detectionProbabilityCallback),...
            'Tooltip',msgString(this,'DetectionProbabilityTooltip'));

            falseAlarmRateLabel=...
            this.createLabelEditPair(panel,'FalseAlarmRate',...
            this.Application.initCallback(@this.farCallback),...
            'Tooltip',msgString(this,'FalseAlarmRateTooltip'));

            referenceRangeLabel=createLabelEditPair(...
            this,panel,'ReferenceRange',...
            this.Application.initCallback(@this.defaultEditboxCallback),...
            'Tooltip',msgString(this,'ReferenceRangeTooltip'));

            referenceRCSLabel=createLabelEditPair(...
            this,panel,'ReferenceRCS',...
            this.Application.initCallback(@this.defaultScalarRealCallback),...
            'Tooltip',msgString(this,'ReferenceRCSTooltip'));


            createToggle(this,panel,'ShowAdvancedParameters');
            createAdvancedParameters(this,panel);

            createToggle(this,panel,'ShowAccuracyAndNoiseSettings');
            createAccuracyPanel(this,panel);


            layout=matlabshared.application.layout.ScrollableGridBagLayout(panel,...
            'HorizontalGap',3,...
            'VerticalGap',3,...
            'HorizontalWeights',[0,0]);

            minW=layout.getMinimumWidth([detectionProbabilityLabel,...
            falseAlarmRateLabel,referenceRangeLabel,referenceRCSLabel]);
            labelProps={'Fill','Horizontal','MinimumWidth',minW};


            this.addrow(layout,detectionProbabilityLabel,1,1,...
            labelProps{:});

            row=this.addrow(layout,this.hDetectionProbability,1,2,...
            labelProps{:});

            this.addrow(layout,falseAlarmRateLabel,row,1,...
            labelProps{:});

            row=this.addrow(layout,this.hFalseAlarmRate,row,2,...
            labelProps{:});

            this.addrow(layout,referenceRangeLabel,row,1,labelProps{:});
            row=this.addrow(layout,this.hReferenceRange,row,2,labelProps{:});
            this.addrow(layout,referenceRCSLabel,row,1,labelProps{:});
            row=this.addrow(layout,this.hReferenceRCS,row,2,labelProps{:});


            row=this.addrow(layout,this.hShowAdvancedParameters,row,[1,2],...
            'Fill','Horizontal');

            this.addrow(layout,this.hShowAccuracyAndNoiseSettings,row,[1,2],...
            'Fill','Horizontal','Anchor','North');

            this.hDetectionParametersPanel=panel;
            this.DetectionParametersLayout=layout;
        end

        function createAdvancedParameters(this,fig)
            panel=uipanel(fig,...
            'Tag','advancedpanel',...
            'BorderType','none');

            haspropertycallback=this.Application.initCallback(@this.hasPropertyCallback);

            MaxNumDetLabel=createLabelEditPair(this,panel,'MaxNumDetections',...
            this.Application.initCallback(@this.maxNumDetCallback),'Tooltip',msgString(this,'MaxNumDetectionsTooltip'));

            maxUnambRangeLabel=...
            this.createLabelEditPair(panel,'MaxUnambiguousRange',...
            this.Application.initCallback(@this.defaultEditboxCallback),...
            'Tooltip',msgString(this,'MaxUnambiguousRangeTooltip'));

            createCheckbox(this,panel,'HasFalseAlarms',haspropertycallback,...
            'Tooltip',msgString(this,'HasFalseAlarmsTooltip'));

            createCheckbox(this,panel,'HasRangeRate',haspropertycallback,...
            'Tooltip',msgString(this,'HasRangeRateTooltip'));

            this.hHasRangeRateAmbiguities=createCheckbox(this,panel,...
            'HasRangeRateAmbiguities',haspropertycallback,...
            'Tooltip',msgString(this,'HasRangeRateAmbiguitiesTooltip'));

            maxUnambRadSpeedLabel=...
            this.createLabelEditPair(panel,'MaxUnambiguousRadialSpeed',...
            this.Application.initCallback(@this.defaultEditboxCallback),...
            'Tooltip',msgString(this,'MaxUnambiguousRadialSpeedTooltip'));

            createCheckbox(this,panel,'HasOcclusion',haspropertycallback,...
            'Tooltip',msgString(this,'HasOcclusionTooltip'));

            createCheckbox(this,panel,...
            'HasRangeAmbiguities',haspropertycallback,...
            'Tooltip',msgString(this,'HasRangeAmbiguitiesTooltip'));


            layout=matlabshared.application.layout.GridBagLayout(panel,...
            'VerticalGap',3,'HorizontalGap',3);
            labelProps={'Fill','Horizontal'};

            row=1;
            this.addrow(layout,MaxNumDetLabel,row,1,labelProps{:});
            row=this.addrow(layout,this.hMaxNumDetections,row,2,labelProps{:});
            row=this.addrow(layout,this.hHasFalseAlarms,row,1,labelProps{:});
            row=this.addrow(layout,this.hHasRangeRate,row,1,labelProps{:});
            row=this.addrow(layout,this.hHasOcclusion,row,1,labelProps{:});


            row=this.addrow(layout,this.hHasRangeAmbiguities,row,1,labelProps{:});
            row=this.addrow(layout,this.hHasRangeRateAmbiguities,row,1,labelProps{:});

            this.addrow(layout,maxUnambRangeLabel,row,1,...
            'MinimumWidth',layout.getMinimumWidth(maxUnambRangeLabel),...
            'Fill','Horizontal');
            row=this.addrow(layout,this.hMaxUnambiguousRange,row,2,...
            'Fill','Horizontal','MinimumWidth',35);

            this.addrow(layout,maxUnambRadSpeedLabel,row,1,...
            'MinimumWidth',layout.getMinimumWidth(maxUnambRadSpeedLabel),...
            'Fill','Horizontal');
            this.addrow(layout,this.hMaxUnambiguousRadialSpeed,row,2,...
            'Fill','Horizontal');

            this.hAdvancedParametersPanel=panel;
            this.AdvancedParametersLayout=layout;
        end

        function createAccuracyPanel(this,fig)
            defaulteditcb=this.Application.initCallback(@this.defaultEditboxCallback);
            panel=uipanel(fig,'Visible','off','BorderType','none');

            resolutionLabel=createLabel(this,panel,'Resolution');
            biasLabel=createLabel(this,panel,'BiasFraction');
            azLabel=createLabel(this,panel,'AzimuthLabel');
            elLabel=createLabel(this,panel,'ElevationLabel');
            rangeLabel=createLabel(this,panel,'RangeLabel');
            rangeRateLabel=createLabel(this,panel,'RangeRateLabel');
            createEditbox(this,panel,'AzimuthResolution',defaulteditcb,'Tooltip',msgString(this,'AzimuthAccuracyTooltip'));
            createEditbox(this,panel,'ElevationResolution',defaulteditcb,'Tooltip',msgString(this,'ElevationAccuracyTooltip'));
            createEditbox(this,panel,'RangeResolution',defaulteditcb,'Tooltip',msgString(this,'RangeAccuracyTooltip'));
            createEditbox(this,panel,'RangeRateResolution',defaulteditcb,'Tooltip',msgString(this,'RangeRateAccuracyTooltip'));
            createEditbox(this,panel,'ElevationBias',defaulteditcb,'Tooltip',msgString(this,'ElevationBiasTooltip'));
            createEditbox(this,panel,'AzimuthBias',defaulteditcb,'Tooltip',msgString(this,'AzimuthBiasTooltip'));
            createEditbox(this,panel,'RangeBias',defaulteditcb,'Tooltip',msgString(this,'RangeBiasTooltip'));
            createEditbox(this,panel,'RangeRateBias',defaulteditcb,'Tooltip',msgString(this,'RangeRateBiasTooltip'));

            cb=this.Application.initCallback(@this.hasPropertyCallback);
            createCheckbox(this,panel,'HasNoise',cb,...
            'Tooltip',msgString(this,'HasNoiseTooltip'));

            layout=matlabshared.application.layout.GridBagLayout(panel,...
            'VerticalGap',3,'HorizontalGap',3,'VerticalWeights',[0,0,0,0,0,1]);
            labelProps={'Fill','Horizontal'};

            add(layout,resolutionLabel,1,2,labelProps{:});
            add(layout,biasLabel,1,3,labelProps{:});
            add(layout,azLabel,2,1,labelProps{:});
            add(layout,this.hAzimuthResolution,2,2,labelProps{:});
            add(layout,this.hAzimuthBias,2,3,labelProps{:});
            add(layout,this.hElevationResolution,3,2,labelProps{:});
            add(layout,elLabel,3,1,labelProps{:});
            add(layout,this.hElevationBias,3,3,labelProps{:});
            add(layout,rangeLabel,4,1,labelProps{:});
            add(layout,this.hRangeResolution,4,2,labelProps{:});
            add(layout,this.hRangeBias,4,3,labelProps{:});
            add(layout,rangeRateLabel,5,1,labelProps{:},...
            'MinimumWidth',layout.getMinimumWidth(rangeRateLabel));
            add(layout,this.hRangeRateResolution,5,2,labelProps{:});
            add(layout,this.hRangeRateBias,5,3,labelProps{:});
            add(layout,this.hHasNoise,6,[1,3],labelProps{:},'Anchor','north');

            this.hAccuracyAndNoiseSettingsPanel=panel;
            this.AccuracyAndNoiseSettingsLayout=layout;
        end

    end


    methods(Hidden)




    end
end