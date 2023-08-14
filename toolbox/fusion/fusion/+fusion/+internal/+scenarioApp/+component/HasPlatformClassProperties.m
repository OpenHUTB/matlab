classdef HasPlatformClassProperties<matlabshared.application.UITools



    properties

        ShowDimensions logical=false
        ShowOffset logical=false
        ShowPoseEstimatorAccuracy logical=false
        ShowSignatures logical=false


        RcsState='constant'
    end

    properties(Hidden)

hShowDimensions
hShowPoseEstimatorAccuracy
hShowSignatures
hShowOffset


hDimensionsPanel
hOffsetPanel
hPoseEstimatorAccuracyPanel
hSignaturesPanel


hLength
hWidth
hHeight
hXOffset
hYOffset
hZOffset


hRollAccuracy
hPitchAccuracy
hYawAccuracy
hPositionAccuracy
hVelocityAccuracy


hImportSignature
hConstantSignature
hConstantRCS


DimensionsLayout
OffsetLayout
PoseEstimatorAccuracyLayout
SignaturesLayout

    end


    methods
        function updateSignatureRadio(this)
            if strcmp(this.RcsState,'constant')
                this.hConstantSignature.Value=1;
                this.hConstantRCS.Enable='on';
                this.hImportSignature.Value=0;
            else
                this.hImportSignature.Value=1;
                this.hConstantRCS.Enable='off';
                this.hConstantSignature.Value=0;
            end

        end

    end

    methods(Access=protected)
        function createDimensionPanel(this,fig)
            dimensionsPanel=uipanel(fig,'Visible','Off','BorderType','none');
            cb=this.Application.initCallback(@this.dimensionCallback);

            lengthLabel=createLabelEditPair(this,dimensionsPanel,'Length',cb);
            widthLabel=createLabelEditPair(this,dimensionsPanel,'Width',cb);
            heigthLabel=createLabelEditPair(this,dimensionsPanel,'Height',cb);

            createToggle(this,fig,'ShowOffset');
            offsetPanel=uipanel(dimensionsPanel,'Visible','off','BorderType','none');
            xOffsetLabel=createLabelEditPair(this,offsetPanel,'XOffset',cb);
            yOffsetLabel=createLabelEditPair(this,offsetPanel,'YOffset',cb);
            zOffsetLabel=createLabelEditPair(this,offsetPanel,'ZOffset',cb);

            offsetLayout=matlabshared.application.layout.GridBagLayout(offsetPanel,...
            'VerticalGap',1,'HorizontalGap',3);

            add(offsetLayout,xOffsetLabel,3,1,...
            'Fill','Horizontal')
            add(offsetLayout,yOffsetLabel,3,2,...
            'Fill','Horizontal')
            add(offsetLayout,zOffsetLabel,3,3,...
            'Fill','Horizontal')
            add(offsetLayout,this.hXOffset,4,1,...
            'Fill','Horizontal')
            add(offsetLayout,this.hYOffset,4,2,...
            'Fill','Horizontal')
            add(offsetLayout,this.hZOffset,4,3,...
            'Fill','Horizontal')

            dimensionsLayout=matlabshared.application.layout.GridBagLayout(dimensionsPanel,...
            'VerticalGap',3,'HorizontalGap',3);
            add(dimensionsLayout,lengthLabel,1,1,...
            'Fill','Horizontal')
            add(dimensionsLayout,widthLabel,1,2,...
            'Fill','Horizontal')
            add(dimensionsLayout,heigthLabel,1,3,...
            'Fill','Horizontal')
            add(dimensionsLayout,this.hLength,2,1,...
            'Fill','Horizontal')
            add(dimensionsLayout,this.hWidth,2,2,...
            'Fill','Horizontal')
            add(dimensionsLayout,this.hHeight,2,3,...
            'Fill','Horizontal')
            add(dimensionsLayout,this.hShowOffset,3,[1,3],...
            'Fill','Horizontal')

            this.hOffsetPanel=offsetPanel;
            this.OffsetLayout=offsetLayout;
            this.hDimensionsPanel=dimensionsPanel;
            this.DimensionsLayout=dimensionsLayout;
        end

        function createPoseEstimatorPanel(this,fig)
            poseEstimatorPanel=uipanel(fig,'Visible','Off','BorderType','none');

            orientationcallback=this.Application.initCallback(@this.orientationAccuracyCallback);
            positionVelocityCb=this.Application.initCallback(@this.positionVelocityAccuracyCallback);

            rollAccuracyLabel=createLabelEditPair(this,fig,'RollAccuracy',orientationcallback);
            pitchAccuracyLabel=createLabelEditPair(this,fig,'PitchAccuracy',orientationcallback);
            yawAccuracyLabel=createLabelEditPair(this,fig,'YawAccuracy',orientationcallback);
            positionAccuracyLabel=createLabelEditPair(this,fig,'PositionAccuracy',positionVelocityCb);
            velocityAccuracyLabel=createLabelEditPair(this,fig,'VelocityAccuracy',positionVelocityCb);

            poseEsimatorLayout=matlabshared.application.layout.GridBagLayout(poseEstimatorPanel,...
            'VerticalGap',3,'HorizontalGap',3);
            minH=20;
            add(poseEsimatorLayout,rollAccuracyLabel,1,1,'Fill','Horizontal','MinimumHeight',minH);
            add(poseEsimatorLayout,pitchAccuracyLabel,1,2,'Fill','Horizontal','MinimumHeight',minH);
            add(poseEsimatorLayout,yawAccuracyLabel,1,3,'Fill','Horizontal','MinimumHeight',minH);
            add(poseEsimatorLayout,this.hRollAccuracy,2,1,'Fill','Horizontal','MinimumHeight',minH);
            add(poseEsimatorLayout,this.hYawAccuracy,2,2,'Fill','Horizontal','MinimumHeight',minH);
            add(poseEsimatorLayout,this.hPitchAccuracy,2,3,'Fill','Horizontal','MinimumHeight',minH);
            add(poseEsimatorLayout,positionAccuracyLabel,3,1,'Fill','Horizontal','MinimumHeight',minH);
            add(poseEsimatorLayout,velocityAccuracyLabel,3,2,'Fill','Horizontal','MinimumHeight',minH);
            add(poseEsimatorLayout,this.hPositionAccuracy,4,1,'Fill','Horizontal','MinimumHeight',minH);
            add(poseEsimatorLayout,this.hVelocityAccuracy,4,2,'Fill','Horizontal','MinimumHeight',minH);

            this.hPoseEstimatorAccuracyPanel=poseEstimatorPanel;
            this.PoseEstimatorAccuracyLayout=poseEsimatorLayout;
        end
    end



    methods(Hidden)
        function dimensionCallback(~,~,~)

        end

        function orientationAccuracyCallback(~,~,~)

        end

        function positionVelocityAccuracyCallback(~,~,~)

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
                if~importSignatureCallback(this.Application)

                    this.RcsState='constant';
                    updateSignatureRadio(this);
                    return
                end
            else
                this.RcsState='constant';
                setConstantRCS(this.Application,str2double(this.hConstantRCS.String))
            end
        end
    end

end