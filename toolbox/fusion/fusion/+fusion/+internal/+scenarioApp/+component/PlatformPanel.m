classdef PlatformPanel<fusion.internal.scenarioApp.component.PropertyPanel&...
    fusion.internal.scenarioApp.component.HasPlatformClassProperties

    properties

        ShowInitialPose logical=false


ElevationCutValue
FrequencyCutValue
    end

    properties(Hidden)

hSelector
hName
hClassID


hShowInitialPose


hInitialPosePanel


hPoseX
hPoseY
hPoseZ
hPoseRoll
hPosePitch
hPoseYaw


hSignatureViewPanel
hElevationCut
hFrequencyCut


InitialPoseLayout


SignaturePlotter
    end


    properties(SetAccess=protected)
SelectedIndex
    end

    methods
        function index=get.SelectedIndex(this)
            [~,index]=getCurrentPlatform(this.Application);
        end

        function set.SelectedIndex(this,index)
            selectPlatformByIndex(this.Application,index);
        end
    end


    methods
        function this=PlatformPanel(varargin)
            this@fusion.internal.scenarioApp.component.PropertyPanel(varargin{:});
            resetPropertyPanel(this);
        end

        function update(this,platform,popupitems)

            clearAllMessages(this);


            this.resetToggleValue('ShowDimensions',this.ShowDimensions);
            this.resetToggleValue('ShowInitialPose',this.ShowInitialPose);
            this.resetToggleValue('ShowOffset',this.ShowOffset);
            this.resetToggleValue('ShowPoseEstimatorAccuracy',this.ShowPoseEstimatorAccuracy);
            this.resetToggleValue('ShowSignatures',this.ShowSignatures);

            if isempty(platform)
                resetPropertyPanel(this);
                updateLayout(this);
                return
            end

            enable=matlabshared.application.logicalToOnOff(this.Enabled);


            position=platform.Position.*[1,1,-1];
            dimension=platform.Dimension;
            orientation=platform.Orientation;
            orientationAccuracy=platform.OrientationAccuracy;
            positionAccuracy=platform.PositionAccuracy;
            velocityAccuracy=platform.VelocityAccuracy;


            set(this.hSelector,'Enable',enable,...
            'String',popupitems,'Value',this.SelectedIndex);
            set(this.hName,'Enable',enable,'String',platform.Name);
            classSpecs=this.Application.getPlatformClassSpecifications;
            classSpec=classSpecs.getSpecification(platform.ClassID);
            set(this.hClassID,'Enable',enable,'String',classSpec.name);


            set(this.hLength,'Enable',enable,'String',dimension(1));
            set(this.hWidth,'Enable',enable,'String',dimension(2));
            set(this.hHeight,'Enable',enable,'String',dimension(3));
            set(this.hXOffset,'Enable',enable,'String',dimension(4));
            set(this.hYOffset,'Enable',enable,'String',dimension(5));
            set(this.hZOffset,'Enable',enable,'String',dimension(6));


            set(this.hPoseX,'Enable',enable,'String',num2str(position(1)));
            set(this.hPoseY,'Enable',enable,'String',num2str(position(2)));
            set(this.hPoseZ,'Enable',enable,'String',num2str(position(3)));
            set(this.hPoseRoll,'Enable',enable,'String',orientation(1));
            set(this.hPosePitch,'Enable',enable,'String',orientation(2));
            set(this.hPoseYaw,'Enable',enable,'String',orientation(3));


            set(this.hRollAccuracy,'Enable',enable,'String',orientationAccuracy(1));
            set(this.hPitchAccuracy,'Enable',enable,'String',orientationAccuracy(2));
            set(this.hYawAccuracy,'Enable',enable,'String',orientationAccuracy(3));
            set(this.hPositionAccuracy,'Enable',enable,'String',positionAccuracy);
            set(this.hVelocityAccuracy,'Enable',enable,'String',velocityAccuracy);


            if platform.HasConstantRCS
                this.RcsState='constant';
            else
                this.RcsState='import';
            end
            updateSignaturePanel(this,platform.RCSSignature);


            updateLayout(this);
        end

        function resetPropertyPanel(this)

            set([this.hName,this.hLength,this.hWidth,this.hHeight...
            ,this.hXOffset,this.hYOffset,this.hZOffset...
            ,this.hPoseX,this.hPoseY,this.hPoseZ,this.hPoseRoll,this.hPosePitch,this.hPoseYaw...
            ,this.hRollAccuracy,this.hPitchAccuracy,this.hYawAccuracy...
            ,this.hPositionAccuracy,this.hVelocityAccuracy...
            ,this.hClassID,this.hConstantRCS,this.hElevationCut...
            ,this.hFrequencyCut...
            ],'Enable','off','String','');


            set([this.hImportSignature,this.hConstantSignature,this.hSelector],'Enable','off');


            set(this.hSelector,'Enable','off',...
            'String',getString(message('fusion:trackingScenarioApp:Toolstrip:EmptyPlatformSelectorText')),...
            'Value',1);


            clear(this.SignaturePlotter);
        end

        function tag=getTag(~)
            tag='PlatformPanel';
        end

        function str=msgString(this,key,varargin)
            str=getString(message(strcat(this.ResourceCatalog,'PlatformProperty',key),varargin{:}));
        end

    end

    methods(Hidden)
        function updateLayout(this)
            layout=this.Layout;

            nextRow=insertDimensionPanel(this,5);
            nextRow=this.insertPanel(layout','InitialPose',nextRow+1);
            nextRow=this.insertPanel(layout,'PoseEstimatorAccuracy',nextRow+1);
            this.insertPanel(layout,'Signatures',nextRow+1);

            layout.VerticalWeights=[zeros(1,size(layout.Grid,1)-1),1];
            setAllToggleCData(this);

        end

        function updateSignaturePanel(this,signature)

            enable=matlabshared.application.logicalToOnOff(this.Enabled);
            set([this.hConstantSignature,this.hElevationCut...
            ,this.hFrequencyCut,this.hImportSignature],'Enable',enable);


            updateSignatureRadio(this)



            this.hConstantRCS.Enable=matlabshared.application.logicalToOnOff(...
            this.hConstantSignature.Value);
            if this.hConstantSignature.Value==1
                this.hConstantRCS.String=signature.Pattern(1);
            end


            el0=this.ElevationCutValue;
            f0=this.FrequencyCutValue;
            this.hElevationCut.String=el0;
            this.hFrequencyCut.String=f0;
            updateSignaturePlot(this,signature,el0,f0);
        end

        function updateSignaturePlot(this,signature,el0,f0)
            plt=this.SignaturePlotter;
            plt.plotSignature(signature,el0,f0);
        end

        function onPlatformAdded(this)



            if all(~[this.ShowDimensions,this.ShowInitialPose,this.ShowPoseEstimatorAccuracy,this.ShowSignatures])
                this.ShowDimensions=true;
                this.ShowInitialPose=true;
            end
        end
    end


    methods(Access=protected)
        function sig=getSignature(this)
            sig=this.Application.getCurrentPlatform.RCSSignature;
        end
    end


    methods(Hidden)
        function selectorCallback(this,h,~)
            str=h.String{h.Value};
            this.SelectedIndex=str2double(str(1));
        end

        function nameCallback(this,h,~)
            newName=h.String;
            setPlatformProperty(this.Application,'Name',newName)
        end

        function positionCallback(this,h,~)

            newPosition=getVectorFromWidgets(this,'hPoseX','hPoseY','hPoseZ').*[1,1,-1];
            oldPosition=this.Application.getCurrentPlatform.Position;
            if isequal(newPosition,oldPosition)

                return
            end


            newValue=str2double(h.String);
            fail=validateNumericProperty(this,newValue);
            if fail
                [str,id]=errorString(this,'BadNumericInput',h.Tag);
                this.Application.updatePlatformPanel();
                errorMessage(this,str,id);
                return;
            end
            setPlatformProperty(this.Application,'Position',newPosition)
        end

        function orientationCallback(this,h,~)

            newOrientation=getVectorFromWidgets(this,'hPoseRoll','hPosePitch','hPoseYaw');
            oldOrientation=this.Application.getCurrentPlatform.Orientation;
            if isequal(newOrientation,oldOrientation)

                return
            end


            newValue=str2double(h.String);
            fail=validateNumericProperty(this,newValue);
            if fail
                [str,id]=errorString(this,'BadNumericInput',h.Tag);
                this.Application.updatePlatformPanel();
                errorMessage(this,str,id);
                return;
            end
            setPlatformProperty(this.Application,'Orientation',newOrientation)
        end

        function dimensionCallback(this,h,~)
            newDimension=getVectorFromWidgets(this,'hLength','hWidth','hHeight',...
            'hXOffset','hYOffset','hZOffset');
            oldDimension=this.Application.getCurrentPlatform.Dimension;
            if isequal(newDimension,oldDimension)

                return
            end


            newValue=str2double(h.String);
            if any(strcmp(h.Tag(1),{'X','Y','Z'}))

                fail=validateNumericProperty(this,newValue);
                if fail
                    [str,id]=errorString(this,'BadNumericInput',msgString(this,h.Tag));
                    this.Application.updatePlatformPanel();
                    errorMessage(this,str,id);
                    return;
                end
            else

                fail=validateNonNegativeProperty(this,newValue);
                if fail
                    [str,id]=this.errorString('BadNonNegInput',msgString(this,h.Tag));
                    this.Application.updatePlatformPanel();
                    errorMessage(this,str,id);
                    return;
                end
            end
            setPlatformProperty(this.Application,'Dimension',newDimension)

        end

        function orientationAccuracyCallback(this,h,~)
            newOrientAcc=getVectorFromWidgets(this,'hRollAccuracy','hPitchAccuracy','hYawAccuracy');
            oldOrientAcc=this.Application.getCurrentPlatform.OrientationAccuracy;
            if isequal(newOrientAcc,oldOrientAcc)

                return
            end
            newValue=str2double(h.String);
            fail=validateNonNegativeProperty(this,newValue);
            if fail
                [str,id]=this.errorString('BadNonNegInput',msgString(this,h.Tag));
                this.Application.updatePlatformPanel();
                errorMessage(this,str,id);
                return;
            end
            setPlatformProperty(this.Application,'OrientationAccuracy',newOrientAcc);
        end

        function positionVelocityAccuracyCallback(this,h,~)
            newValue=str2double(h.String);
            oldValue=this.Application.getCurrentPlatform.(h.Tag);
            if isequal(newValue,oldValue)

                return
            end
            fail=validateNonNegativeProperty(this,newValue);
            if fail
                [str,id]=this.errorString('BadNonNegInput',msgString(this,h.Tag));
                this.Application.updatePlatformPanel();
                errorMessage(this,str,id);
                return;
            end
            setPlatformProperty(this.Application,h.Tag,newValue);
        end

        function constantrcsCallback(this,h,~)
            try
                this.Application.setConstantRCS(str2double(h.String));
            catch ME
                id=ME.identifier;
                str=ME.message;
                this.Application.updatePlatformPanel();
                errorMessage(this,str,id);
            end

        end

        function elevationcutCallback(this,h,~)
            el=str2double(h.String);
            freq=str2double(this.hFrequencyCut.String);
            setRCSviewerCuts(this,el,freq);
            updateSignaturePlot(this,this.getSignature,el,freq)
        end

        function frequencycutCallback(this,h,~)
            el=str2double(this.hElevationCut.String);
            freq=str2double(h.String);
            setRCSviewerCuts(this,el,freq);
            updateSignaturePlot(this,this.getSignature,el,freq)
        end

        function setRCSviewerCuts(this,el,freq)
            if nargin==1
                signature=this.Application.getCurrentPlatform.RCSSignature;

                preferredFreq=300e6;
                preferredEl=0;
                if min(signature.Elevation)<=preferredEl...
                    &&max(signature.Elevation)>=preferredEl
                    el=preferredEl;
                else
                    el=mean(signature.Elevation);
                end
                if min(signature.Frequency)<=preferredFreq&&...
                    max(signature.Frequency)>=preferredFreq
                    freq=preferredFreq;
                else
                    freq=mean(signature.Frequency);
                end
            end
            this.ElevationCutValue=el;
            this.FrequencyCutValue=freq;
        end
    end



    methods(Access=protected)
        function nextRow=insertDimensionPanel(this,row)
            layout=this.Layout;
            dimensionLayout=this.DimensionsLayout;
            nextRow=this.insertPanel(layout,'Dimensions',row);
            this.insertPanel(dimensionLayout,'Offset',4);
            [~,h]=getMinimumSize(dimensionLayout);
            if this.ShowDimensions
                layout.setConstraints(5,1,'MinimumHeight',h);
            end

        end

        function createInitialPosePanel(this,fig)
            initialPosePanel=uipanel(fig,'Visible','Off','BorderType','none');
            cb=this.Application.initCallback(@this.positionCallback);
            xlabel=createLabelEditPair(this,initialPosePanel,'PoseX',cb);
            ylabel=createLabelEditPair(this,initialPosePanel,'PoseY',cb);
            zlabel=createLabelEditPair(this,initialPosePanel,'PoseZ',cb);

            cb=this.Application.initCallback(@this.orientationCallback);
            rolllabel=createLabelEditPair(this,initialPosePanel,'PoseRoll',cb);
            pitchlabel=createLabelEditPair(this,initialPosePanel,'PosePitch',cb);
            yawlabel=createLabelEditPair(this,initialPosePanel,'PoseYaw',cb);

            initialPoseLayout=matlabshared.application.layout.GridBagLayout(initialPosePanel,...
            'VerticalGap',3,'HorizontalGap',3);

            add(initialPoseLayout,xlabel,1,1,'Fill','Horizontal');
            add(initialPoseLayout,ylabel,1,2,'Fill','Horizontal');
            add(initialPoseLayout,zlabel,1,3,'Fill','Horizontal');
            add(initialPoseLayout,this.hPoseX,2,1,'Fill','Horizontal');
            add(initialPoseLayout,this.hPoseY,2,2,'Fill','Horizontal');
            add(initialPoseLayout,this.hPoseZ,2,3,'Fill','Horizontal');
            add(initialPoseLayout,rolllabel,3,1,'Fill','Horizontal');
            add(initialPoseLayout,pitchlabel,3,2,'Fill','Horizontal');
            add(initialPoseLayout,yawlabel,3,3,'Fill','Horizontal');
            add(initialPoseLayout,this.hPoseRoll,4,1,'Fill','Horizontal');
            add(initialPoseLayout,this.hPosePitch,4,2,'Fill','Horizontal');
            add(initialPoseLayout,this.hPoseYaw,4,3,'Fill','Horizontal');

            this.hInitialPosePanel=initialPosePanel;
            this.InitialPoseLayout=initialPoseLayout;

        end

        function createSignaturePanel(this,fig)
            signaturePanel=uipanel(fig,'Visible','Off','BorderType','none');

            radioCb=this.Application.initCallback(@this.signatureRadioCallback);
            createEditbox(this,fig,'ConstantSignature',radioCb,'radio','Tooltip',msgString(this,'SignatureConstantRCSTooltip'));
            createEditbox(this,fig,...
            'ConstantRCS',this.Application.initCallback(@this.constantrcsCallback));

            createEditbox(this,fig,'ImportSignature',radioCb,'radio','Tooltip',msgString(this,'SignatureImportRCSTooltip'));
            viewerLabel=createLabel(this,fig,'SignatureViewer');

            ElevationCutLabel=createLabelEditPair(this,fig,...
            'ElevationCut',this.Application.initCallback(@this.elevationcutCallback),...
            'Tooltip',msgString(this,'SignatureElevationTooltip'));

            FrequencyCutLabel=createLabelEditPair(this,fig,...
            'FrequencyCut',this.Application.initCallback(@this.frequencycutCallback),...
            'Tooltip',msgString(this,'SignatureFrequencyTooltip'));



            this.hSignatureViewPanel=uipanel(signaturePanel,'BorderType','none','BackgroundColor','white');
            createSignaturePlot(this);

            signatureLayout=matlabshared.application.layout.GridBagLayout(signaturePanel,...
            'VerticalGap',3,'HorizontalGap',3,...
            'VerticalWeights',[0,0,0,0,0,1]);


            minHEditBox=50;

            add(signatureLayout,this.hConstantSignature,1,1,'Anchor','West','MinimumWidth',20+signatureLayout.getMinimumWidth(this.hConstantSignature));
            add(signatureLayout,this.hConstantRCS,1,2,'Anchor','West','MinimumWidth',minHEditBox);
            add(signatureLayout,this.hImportSignature,2,1,'Anchor','West','MinimumWidth',120);


            add(signatureLayout,viewerLabel,3,[1,2],'TopInset',5,'Fill','Horizontal');
            add(signatureLayout,ElevationCutLabel,4,1,'LeftInset',15,'MinimumWidth',signatureLayout.getMinimumWidth(ElevationCutLabel),'Fill','Horizontal');
            add(signatureLayout,this.hElevationCut,4,2,'Anchor','West','MinimumWidth',minHEditBox);
            add(signatureLayout,FrequencyCutLabel,5,1,'LeftInset',15,'MinimumWidth',signatureLayout.getMinimumWidth(FrequencyCutLabel),'Fill','Horizontal');
            add(signatureLayout,this.hFrequencyCut,5,2,'Anchor','West','MinimumWidth',minHEditBox);

            add(signatureLayout,this.hSignatureViewPanel,6,[1,2],'Fill','Both',...
            'MinimumHeight',200);

            this.SignaturesLayout=signatureLayout;
            this.hSignaturesPanel=signaturePanel;
        end

        function createSignaturePlot(this)
            p=this.hSignatureViewPanel;
            pax=polaraxes(p);
            plt=fusion.internal.scenarioApp.plotter.SignaturePlotter(pax);
            this.SignaturePlotter=plt;
        end

        function fig=createFigure(this,varargin)
            fig=createFigure@matlabshared.application.Component(this,varargin{:});
            set(fig,'Tag','PlatformPanel');

            selectorLabel=createLabelEditPair(this,fig,'Selector',this.Application.initCallback(@this.selectorCallback),'popupmenu');
            nameLabel=createLabelEditPair(this,fig,'Name',this.Application.initCallback(@this.nameCallback));

            classIDLabel=createLabel(this,fig,'ClassID');
            this.hClassID=createLabel(this,fig,'');


            createToggle(this,fig,'ShowDimensions','Value',0);
            createDimensionPanel(this,fig);


            createToggle(this,fig,'ShowInitialPose');
            createInitialPosePanel(this,fig);


            createToggle(this,fig,'ShowPoseEstimatorAccuracy');
            createPoseEstimatorPanel(this,fig);



            createToggle(this,fig,'ShowSignatures');
            createSignaturePanel(this,fig);



            layout=matlabshared.application.layout.ScrollableGridBagLayout(fig,...
            'VerticalGap',3,'HorizontalGap',3,...
            'HorizontalWeights',[0.2,0.5]);

            rowInd=1;

            add(layout,selectorLabel,rowInd,1,...
            'TopInset',5,...
            'Anchor','SouthWest',...
            'MinimumWidth',layout.getMinimumWidth(selectorLabel));
            add(layout,this.hSelector,rowInd,2,...
            'Fill','Horizontal','Anchor','NorthWest');

            rowInd=rowInd+1;
            add(layout,nameLabel,rowInd,1,...
            'TopInset',5,...
            'Anchor','SouthWest',...
            'MinimumWidth',layout.getMinimumWidth(nameLabel));

            add(layout,this.hName,rowInd,2,...
            'Fill','Horizontal');

            rowInd=rowInd+1;
            add(layout,classIDLabel,rowInd,1,...
            'TopInset',5,...
            'Anchor','SouthWest',...
            'MinimumWidth',layout.getMinimumWidth(classIDLabel))

            add(layout,this.hClassID,rowInd,2,...
            'TopInset',5,...
            'MinimumWidth',layout.getMinimumWidth(this.hClassID),...
            'Fill','Horizontal');

            rowInd=rowInd+1;
            add(layout,this.hShowDimensions,rowInd,[1,2],...
            'Anchor','West',...
            'Fill','Horizontal',...
            'MinimumWidth',layout.getMinimumWidth(this.hShowDimensions)+20);

            rowInd=rowInd+1;
            add(layout,this.hShowInitialPose,rowInd,[1,2],...
            'Anchor','West',...
            'Fill','Horizontal',...
            'MinimumWidth',layout.getMinimumWidth(this.hShowInitialPose)+20);

            rowInd=rowInd+1;
            add(layout,this.hShowPoseEstimatorAccuracy,rowInd,[1,2],...
            'Anchor','West',...
            'Fill','Horizontal',...
            'MinimumWidth',layout.getMinimumWidth(this.hShowPoseEstimatorAccuracy)+20);

            rowInd=rowInd+1;
            add(layout,this.hShowSignatures,rowInd,[1,2],...
            'Anchor','NorthWest',...
            'Fill','Horizontal',...
            'MinimumWidth',layout.getMinimumWidth(this.hShowSignatures)+20);

            layout.VerticalWeights=[zeros(1,rowInd-1),1];
            this.Layout=layout;
        end
    end

end