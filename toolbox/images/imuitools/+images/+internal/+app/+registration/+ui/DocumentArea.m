classdef DocumentArea<handle



    properties(Access={?uitest.factory.Tester,...
        ?images.internal.app.registration.Controller,...
        ?images.internal.app.registration.ui.View,...
        ?images.internal.app.registration.ImageRegistration})

hScrollPanel
hDataBrowser

hfeaturePanel
hphaseCorrelationPanel
hcoarseAlignmentPanel
hmonomodalPanel
hmultimodalPanel
hnonrigidPanel
hnonrigidOnlyPanel
hKAZEPanel
hORBPanel
    end


    properties(Access={
        ?images.internal.app.registration.Controller,...
        ?images.internal.app.registration.ui.View,...
        ?images.internal.app.registration.ImageRegistration})

hRegisteredFig
HitObject

hGroup
hRightPanel
hLeftPanel
    end

    events
addedChildAlignment
updatedCurrentAlignment
figureDeleted
    end

    methods
        function tool=DocumentArea(app)

            import images.internal.app.registration.ui.*;

            tool.hGroup=matlab.ui.internal.FigureDocumentGroup();
            tool.hGroup.Title="Figures";
            app.add(tool.hGroup);


            figOptions.Title=getMessageString('imageOverlay');
            figOptions.DocumentGroupTag=tool.hGroup.Tag;

            hDocument=matlab.ui.internal.FigureDocument(figOptions);
            app.add(hDocument);
            tool.hRegisteredFig=hDocument.Figure;
            hDocument.Closable=false;

            set(tool.hRegisteredFig,'NumberTitle','off',...
            'Units','pixels',...
            'IntegerHandle','off',...
            'HandleVisibility','off',...
            'AutoResizeChildren','off');


            panelOptions.Title=getMessageString('parameters');
            panelOptions.Tag="Parameter Panel";
            panelOptions.Region="right";
            tool.hRightPanel=matlab.ui.internal.FigurePanel(panelOptions);
            set(tool.hRightPanel.Figure,...
            'Units','pixels',...
            'HandleVisibility','off',...
            'AutoResizeChildren','off',...
            'Color','white');
            app.add(tool.hRightPanel);
            app.RightCollapsed=false;


            tool.hScrollPanel=images.internal.app.registration.ui.TwoImageScrollPanel(tool.hRegisteredFig);


            panelOptions.Title=getMessageString('registrations');
            panelOptions.Tag="Registration Panel";
            panelOptions.Region="left";
            tool.hLeftPanel=matlab.ui.internal.FigurePanel(panelOptions);
            app.add(tool.hLeftPanel);
            app.LeftCollapsed=false;
            app.LeftWidth=0.3;

            tool.hDataBrowser=images.internal.app.registration.ui.DataBrowser(tool.hLeftPanel.Figure);

            wireUpScrollListeners(tool,tool.hRegisteredFig,tool.hRightPanel.Figure,tool.hLeftPanel.Figure);

        end

        function wireUpSizeChangedCallback(tool)
            set(tool.hRightPanel.Figure,...
            'SizeChangedFcn',@(~,~)controlPanelSizeChange(tool));
            set(tool.hRegisteredFig,...
            'SizeChangedFcn',@(~,~)controlPanelSizeChange(tool));
        end

        function[]=showImagePair(tool,val,fixed,moving,fixedRefObj,movingRefObj,featureData)
            if tool.hDataBrowser.SelectedEntryDraft
                tool.hScrollPanel.updateScrollPanel(val,fixed,moving,fixedRefObj,movingRefObj,featureData);
            else

                featureData=struct(...
                'fixed',[NaN,NaN],...
                'moving',[NaN,NaN]);
                tool.hScrollPanel.updateScrollPanel(val,fixed,moving,fixedRefObj,movingRefObj,featureData);
            end
        end

        function wireUpScrollListeners(tool,hfig,rightpanel,leftpanel)

            addlistener(hfig,'WindowScrollWheel',@(src,evt)scrollCallback(tool,evt));
            addlistener(rightpanel,'WindowScrollWheel',@(src,evt)scrollCallback(tool,evt));
            addlistener(leftpanel,'WindowScrollWheel',@(src,evt)scrollCallback(tool,evt));
            addlistener(hfig,'WindowMouseMotion',@(src,evt)motionCallback(tool,src,evt));
            addlistener(rightpanel,'WindowMouseMotion',@(src,evt)motionCallback(tool,src,evt));
            addlistener(leftpanel,'WindowMouseMotion',@(src,evt)motionCallback(tool,src,evt));

        end

        function scrollCallback(tool,evt)

            if tool.HitObject==tool.hRegisteredFig
                scroll(tool.hScrollPanel,evt.VerticalScrollCount);
            end

        end

        function motionCallback(tool,src,evt)


            tool.HitObject=ancestor(evt.HitObject,'figure');

            if tool.HitObject==tool.hRegisteredFig
                if wasClickOnAxesToolbar(tool,evt)
                    images.roi.setBackgroundPointer(src,'arrow');
                elseif isa(evt.HitObject,'matlab.graphics.primitive.Image')
                    if isprop(evt.HitObject,'InteractionMode')
                        switch evt.HitObject.InteractionMode
                        case ''
                            images.roi.setBackgroundPointer(src,'arrow');
                        case 'pan'
                            images.roi.setBackgroundPointer(src,'custom',matlab.graphics.interaction.internal.getPointerCData('pan_both'),[16,16]);
                        case 'zoomin'
                            images.roi.setBackgroundPointer(src,'custom',matlab.graphics.interaction.internal.getPointerCData('zoomin_unconstrained'),[16,16]);
                        case 'zoomout'
                            images.roi.setBackgroundPointer(src,'custom',matlab.graphics.interaction.internal.getPointerCData('zoomout_both'),[16,16]);
                        end
                    else
                        images.roi.setBackgroundPointer(src,'arrow');
                    end
                else
                    images.roi.setBackgroundPointer(src,'arrow');
                end
            else
                images.roi.setBackgroundPointer(src,'arrow');
            end

        end

        function TF=wasClickOnAxesToolbar(~,evt)



            TF=~isempty(ancestor(evt.HitObject,'matlab.graphics.controls.AxesToolbar'));
        end

        function updateParameters(tool)

            alignmentType=tool.hDataBrowser.getModelName();



            if~tool.hDataBrowser.SelectedEntryDraft

                cardData.modelNumber=tool.hDataBrowser.getChildModelNumber();
                cardData.modelName=alignmentType;
                evtData=images.internal.app.registration.model.customEventData(cardData);
                notify(tool,'addedChildAlignment',evtData);
            else
                tool.hDataBrowser.SelectedEntryStatus=true;
            end


            switch alignmentType
            case{'SURF','FAST','MSER','BRISK','Harris','MinEigen'}
                paramData=tool.packageFeatureData();
            case 'KAZE'
                paramData=tool.packageKAZEData();
            case 'ORB'
                paramData=tool.packageORBData();
            case 'Monomodal'
                paramData=tool.packageMonomodalData();
            case 'Multimodal'
                paramData=tool.packageMultimodalData();
            case 'Phase Correlation'
                paramData=tool.packagePhaseCorrelationData();
            case 'Nonrigid'
                paramData=tool.packageNonrigidOnlyData();
            end

            evtData=images.internal.app.registration.model.customEventData(paramData);


            notify(tool,'updatedCurrentAlignment',evtData)

        end

        function updateSettingsPanel(tool,~,evtData)


            if strcmp(tool.hDataBrowser.getModelName(),'Nonrigid')
                tool.hnonrigidOnlyPanel.NonrigidSelected=evtData.data.nonrigid.NonrigidSelected;
                tool.hnonrigidOnlyPanel.Iterations=evtData.data.nonrigid.Iterations;
                tool.hnonrigidOnlyPanel.PyramidLevels=evtData.data.nonrigid.PyramidLevels;
                tool.hnonrigidOnlyPanel.Smoothing=evtData.data.nonrigid.Smoothing;
            else
                tool.hnonrigidPanel.NonrigidSelected=evtData.data.nonrigid.NonrigidSelected;
                tool.hnonrigidPanel.Iterations=evtData.data.nonrigid.Iterations;
                tool.hnonrigidPanel.PyramidLevels=evtData.data.nonrigid.PyramidLevels;
                tool.hnonrigidPanel.Smoothing=evtData.data.nonrigid.Smoothing;
            end

            switch tool.hDataBrowser.getModelName()
            case{'SURF','FAST','MSER','BRISK','Harris','MinEigen'}
                tool.hfeaturePanel.Tform=evtData.data.Tform;
                tool.hfeaturePanel.HasRotation=~evtData.data.Upright;
                tool.hfeaturePanel.hFeatureNumberSlider.Value=1-evtData.data.FeatureNumber;
                tool.hfeaturePanel.hFeatureQualitySlider.Value=evtData.data.FeatureQuality;
            case 'ORB'
                tool.hORBPanel.Tform=evtData.data.Tform;
                tool.hORBPanel.NumLevels=evtData.data.NumLevels;
                tool.hORBPanel.ScaleFactor=evtData.data.ScaleFactor;
                tool.hORBPanel.hFeatureQualitySlider.Value=evtData.data.FeatureQuality;
            case 'KAZE'
                tool.hKAZEPanel.Tform=evtData.data.Tform;
                tool.hKAZEPanel.HasRotation=~evtData.data.Upright;
                tool.hKAZEPanel.hFeatureNumberSlider.Value=1-evtData.data.FeatureNumber;
                tool.hKAZEPanel.hFeatureQualitySlider.Value=evtData.data.FeatureQuality;
                tool.hKAZEPanel.Diffusion=evtData.data.Diffusion;
            case 'Monomodal'
                tool.hmonomodalPanel.Tform=evtData.data.Tform;
                tool.hcoarseAlignmentPanel.Normalize=evtData.data.Normalize;
                tool.hcoarseAlignmentPanel.ApplyBlur=evtData.data.ApplyBlur;
                tool.hcoarseAlignmentPanel.hBlurSlider.Value=evtData.data.BlurValue;
                tool.hcoarseAlignmentPanel.AlignCenters=evtData.data.AlignCenters;
                tool.hmonomodalPanel.GradMagTol=evtData.data.GradMagTol;
                tool.hmonomodalPanel.MinStepLength=evtData.data.MinStepLength;
                tool.hmonomodalPanel.MaxStepLength=evtData.data.MaxStepLength;
                tool.hmonomodalPanel.MaxIterations=evtData.data.MaxIterations;
                tool.hmonomodalPanel.RelaxFactor=evtData.data.RelaxFactor;
                tool.hmonomodalPanel.PyramidLevels=evtData.data.PyramidLevels;
            case 'Multimodal'
                tool.hmultimodalPanel.Tform=evtData.data.Tform;
                tool.hcoarseAlignmentPanel.Normalize=evtData.data.Normalize;
                tool.hcoarseAlignmentPanel.ApplyBlur=evtData.data.ApplyBlur;
                tool.hcoarseAlignmentPanel.hBlurSlider.Value=evtData.data.BlurValue;
                tool.hcoarseAlignmentPanel.AlignCenters=evtData.data.AlignCenters;
                tool.hmultimodalPanel.NumSamples=evtData.data.NumSamples;
                tool.hmultimodalPanel.NumBins=evtData.data.NumBins;
                tool.hmultimodalPanel.UseAllPixels=evtData.data.UseAllPixels;
                tool.hmultimodalPanel.GrowthFactor=evtData.data.GrowthFactor;
                tool.hmultimodalPanel.Epsilon=evtData.data.Epsilon;
                tool.hmultimodalPanel.InitialRadius=evtData.data.InitialRadius;
                tool.hmultimodalPanel.MaxIterations=evtData.data.MaxIterations;
                tool.hmultimodalPanel.PyramidLevels=evtData.data.PyramidLevels;
            case 'Phase Correlation'
                tool.hphaseCorrelationPanel.Tform=evtData.data.Tform;
                tool.hphaseCorrelationPanel.Window=evtData.data.Window;
            end

            tool.setParameterViewState();
            tool.updateControlPanel();

        end

        function clear(tool)


            tool.hfeaturePanel.hidePanel();
            tool.hnonrigidPanel.hidePanel();
            tool.hphaseCorrelationPanel.hidePanel();
            tool.hcoarseAlignmentPanel.hidePanel();
            tool.hmonomodalPanel.hidePanel();
            tool.hmultimodalPanel.hidePanel();
            tool.hnonrigidOnlyPanel.hidePanel();
            tool.hKAZEPanel.hidePanel();
            tool.hORBPanel.hidePanel();

            clear(tool.hScrollPanel);

        end

        function controlPanelSizeChange(tool)


            pos=tool.hRegisteredFig.Position;
            set(tool.hScrollPanel.imPanel,'Position',pos);
            resize(tool.hScrollPanel);

            tool.updateControlPanel();

        end

        function paramData=packageMonomodalData(tool)
            paramData.Tform=tool.hmonomodalPanel.Tform;
            paramData.GradMagTol=tool.hmonomodalPanel.GradMagTol;
            paramData.MinStepLength=tool.hmonomodalPanel.MinStepLength;
            paramData.MaxStepLength=tool.hmonomodalPanel.MaxStepLength;
            paramData.MaxIterations=tool.hmonomodalPanel.MaxIterations;
            paramData.RelaxFactor=tool.hmonomodalPanel.RelaxFactor;
            paramData.PyramidLevels=tool.hmonomodalPanel.PyramidLevels;

            paramData=tool.packageCoarseAlignmentData(paramData);
            paramData=tool.packageNonrigidData(paramData);
        end

        function paramData=packageMultimodalData(tool)
            paramData.Tform=tool.hmultimodalPanel.Tform;
            paramData.NumSamples=tool.hmultimodalPanel.NumSamples;
            paramData.NumBins=tool.hmultimodalPanel.NumBins;
            paramData.UseAllPixels=tool.hmultimodalPanel.UseAllPixels;
            paramData.GrowthFactor=tool.hmultimodalPanel.GrowthFactor;
            paramData.Epsilon=tool.hmultimodalPanel.Epsilon;
            paramData.InitialRadius=tool.hmultimodalPanel.InitialRadius;
            paramData.MaxIterations=tool.hmultimodalPanel.MaxIterations;
            paramData.PyramidLevels=tool.hmultimodalPanel.PyramidLevels;

            paramData=tool.packageCoarseAlignmentData(paramData);
            paramData=tool.packageNonrigidData(paramData);
        end

        function paramData=packageCoarseAlignmentData(tool,paramData)
            paramData.Normalize=tool.hcoarseAlignmentPanel.Normalize;
            paramData.ApplyBlur=tool.hcoarseAlignmentPanel.ApplyBlur;
            paramData.BlurValue=tool.hcoarseAlignmentPanel.hBlurSlider.Value;
            paramData.AlignCenters=tool.hcoarseAlignmentPanel.AlignCenters;
        end

        function paramData=packagePhaseCorrelationData(tool)
            paramData.Tform=tool.hphaseCorrelationPanel.Tform;
            paramData.Window=tool.hphaseCorrelationPanel.Window;
            paramData=tool.packageNonrigidData(paramData);
        end

        function paramData=packageFeatureData(tool)
            paramData.Tform=tool.hfeaturePanel.Tform;
            paramData.Upright=~tool.hfeaturePanel.HasRotation;
            paramData.FeatureNumber=1-tool.hfeaturePanel.hFeatureNumberSlider.Value;
            paramData.FeatureQuality=tool.hfeaturePanel.hFeatureQualitySlider.Value;
            paramData=tool.packageNonrigidData(paramData);
        end

        function paramData=packageKAZEData(tool)
            paramData.Tform=tool.hKAZEPanel.Tform;
            paramData.Upright=~tool.hKAZEPanel.HasRotation;
            paramData.FeatureNumber=1-tool.hKAZEPanel.hFeatureNumberSlider.Value;
            paramData.FeatureQuality=tool.hKAZEPanel.hFeatureQualitySlider.Value;
            paramData.Diffusion=tool.hKAZEPanel.Diffusion;
            paramData=tool.packageNonrigidData(paramData);
        end

        function paramData=packageORBData(tool)
            paramData.Tform=tool.hORBPanel.Tform;
            paramData.NumLevels=tool.hORBPanel.NumLevels;
            paramData.ScaleFactor=tool.hORBPanel.ScaleFactor;
            paramData.FeatureQuality=tool.hORBPanel.hFeatureQualitySlider.Value;
            paramData=tool.packageNonrigidData(paramData);
        end

        function paramData=packageNonrigidData(tool,paramData)
            paramData.nonrigid.NonrigidSelected=tool.hnonrigidPanel.NonrigidSelected;
            paramData.nonrigid.Iterations=tool.hnonrigidPanel.Iterations;
            paramData.nonrigid.PyramidLevels=tool.hnonrigidPanel.PyramidLevels;
            paramData.nonrigid.Smoothing=tool.hnonrigidPanel.Smoothing;
        end

        function paramData=packageNonrigidOnlyData(tool)
            paramData.nonrigid.NonrigidSelected=tool.hnonrigidOnlyPanel.NonrigidSelected;
            paramData.nonrigid.Iterations=tool.hnonrigidOnlyPanel.Iterations;
            paramData.nonrigid.PyramidLevels=tool.hnonrigidOnlyPanel.PyramidLevels;
            paramData.nonrigid.Smoothing=tool.hnonrigidOnlyPanel.Smoothing;
        end

        function updateControlPanel(tool)

            pos=tool.hRightPanel.Figure.Position;

            containerWidth=pos(3);
            containerHeight=pos(4)+1;
            border=3;
            headerHeight=30;

            heightBuffer=0;

            switch tool.hDataBrowser.getModelName()
            case{'SURF','FAST','MSER','BRISK','Harris','MinEigen'}

                tool.hfeaturePanel.HeaderPosition=[0,containerHeight-headerHeight,containerWidth,headerHeight];
                if tool.hfeaturePanel.PanelSelected
                    heightBuffer=heightBuffer+tool.hfeaturePanel.PanelHeight;
                    tool.hfeaturePanel.BodyPosition=[0,containerHeight-headerHeight-heightBuffer,containerWidth,tool.hfeaturePanel.PanelHeight];
                end

                tool.hnonrigidPanel.HeaderPosition=[0,containerHeight-((2*headerHeight)+border)-heightBuffer,containerWidth,headerHeight];
                if tool.hnonrigidPanel.PanelSelected
                    heightBuffer=heightBuffer+tool.hnonrigidPanel.PanelHeight;
                    tool.hnonrigidPanel.BodyPosition=[0,containerHeight-((2*headerHeight)+border)-heightBuffer,containerWidth,tool.hnonrigidPanel.PanelHeight];
                end
            case 'KAZE'
                tool.hKAZEPanel.HeaderPosition=[0,containerHeight-headerHeight,containerWidth,headerHeight];
                if tool.hKAZEPanel.PanelSelected
                    heightBuffer=heightBuffer+tool.hKAZEPanel.PanelHeight;
                    tool.hKAZEPanel.BodyPosition=[0,containerHeight-headerHeight-heightBuffer,containerWidth,tool.hKAZEPanel.PanelHeight];
                end

                tool.hnonrigidPanel.HeaderPosition=[0,containerHeight-((2*headerHeight)+border)-heightBuffer,containerWidth,headerHeight];
                if tool.hnonrigidPanel.PanelSelected
                    heightBuffer=heightBuffer+tool.hnonrigidPanel.PanelHeight;
                    tool.hnonrigidPanel.BodyPosition=[0,containerHeight-((2*headerHeight)+border)-heightBuffer,containerWidth,tool.hnonrigidPanel.PanelHeight];
                end
            case 'ORB'
                tool.hORBPanel.HeaderPosition=[0,containerHeight-headerHeight,containerWidth,headerHeight];
                if tool.hORBPanel.PanelSelected
                    heightBuffer=heightBuffer+tool.hORBPanel.PanelHeight;
                    tool.hORBPanel.BodyPosition=[0,containerHeight-headerHeight-heightBuffer,containerWidth,tool.hORBPanel.PanelHeight];
                end

                tool.hnonrigidPanel.HeaderPosition=[0,containerHeight-((2*headerHeight)+border)-heightBuffer,containerWidth,headerHeight];
                if tool.hnonrigidPanel.PanelSelected
                    heightBuffer=heightBuffer+tool.hnonrigidPanel.PanelHeight;
                    tool.hnonrigidPanel.BodyPosition=[0,containerHeight-((2*headerHeight)+border)-heightBuffer,containerWidth,tool.hnonrigidPanel.PanelHeight];
                end
            case 'Monomodal'

                tool.hcoarseAlignmentPanel.HeaderPosition=[0,containerHeight-headerHeight,containerWidth,headerHeight];
                if tool.hcoarseAlignmentPanel.PanelSelected
                    heightBuffer=heightBuffer+tool.hcoarseAlignmentPanel.PanelHeight;
                    tool.hcoarseAlignmentPanel.BodyPosition=[0,containerHeight-headerHeight-heightBuffer,containerWidth,tool.hcoarseAlignmentPanel.PanelHeight];
                end

                tool.hmonomodalPanel.HeaderPosition=[0,containerHeight-((2*headerHeight)+border)-heightBuffer,containerWidth,headerHeight];
                if tool.hmonomodalPanel.PanelSelected
                    heightBuffer=heightBuffer+tool.hmonomodalPanel.PanelHeight;
                    tool.hmonomodalPanel.BodyPosition=[0,containerHeight-((2*headerHeight)+border)-heightBuffer,containerWidth,tool.hmonomodalPanel.PanelHeight];
                    pos=[tool.hmonomodalPanel.BodyPosition(3)-18,3,16,16];
                    set(tool.hmonomodalPanel.HelpPanel,'Position',pos);
                end

                tool.hnonrigidPanel.HeaderPosition=[0,containerHeight-((3*headerHeight)+(2*border))-heightBuffer,containerWidth,headerHeight];
                if tool.hnonrigidPanel.PanelSelected
                    heightBuffer=heightBuffer+tool.hnonrigidPanel.PanelHeight;
                    tool.hnonrigidPanel.BodyPosition=[0,containerHeight-((3*headerHeight)+(2*border))-heightBuffer,containerWidth,tool.hnonrigidPanel.PanelHeight];
                end
            case 'Multimodal'

                tool.hcoarseAlignmentPanel.HeaderPosition=[0,containerHeight-headerHeight,containerWidth,headerHeight];
                if tool.hcoarseAlignmentPanel.PanelSelected
                    heightBuffer=heightBuffer+tool.hcoarseAlignmentPanel.PanelHeight;
                    tool.hcoarseAlignmentPanel.BodyPosition=[0,containerHeight-headerHeight-heightBuffer,containerWidth,tool.hcoarseAlignmentPanel.PanelHeight];
                end

                tool.hmultimodalPanel.HeaderPosition=[0,containerHeight-((2*headerHeight)+border)-heightBuffer,containerWidth,headerHeight];
                if tool.hmultimodalPanel.PanelSelected
                    heightBuffer=heightBuffer+tool.hmultimodalPanel.PanelHeight;
                    tool.hmultimodalPanel.BodyPosition=[0,containerHeight-((2*headerHeight)+border)-heightBuffer,containerWidth,tool.hmultimodalPanel.PanelHeight];
                    pos=[tool.hmultimodalPanel.BodyPosition(3)-18,3,16,16];
                    set(tool.hmultimodalPanel.HelpPanel,'Position',pos);
                end

                tool.hnonrigidPanel.HeaderPosition=[0,containerHeight-((3*headerHeight)+(2*border))-heightBuffer,containerWidth,headerHeight];
                if tool.hnonrigidPanel.PanelSelected
                    heightBuffer=heightBuffer+tool.hnonrigidPanel.PanelHeight;
                    tool.hnonrigidPanel.BodyPosition=[0,containerHeight-((3*headerHeight)+(2*border))-heightBuffer,containerWidth,tool.hnonrigidPanel.PanelHeight];
                end
            case 'Phase Correlation'

                tool.hphaseCorrelationPanel.HeaderPosition=[0,containerHeight-headerHeight,containerWidth,headerHeight];
                if tool.hphaseCorrelationPanel.PanelSelected
                    heightBuffer=heightBuffer+tool.hphaseCorrelationPanel.PanelHeight;
                    tool.hphaseCorrelationPanel.BodyPosition=[0,containerHeight-headerHeight-heightBuffer,containerWidth,tool.hphaseCorrelationPanel.PanelHeight];
                end

                tool.hnonrigidPanel.HeaderPosition=[0,containerHeight-((2*headerHeight)+border)-heightBuffer,containerWidth,headerHeight];
                if tool.hnonrigidPanel.PanelSelected
                    heightBuffer=heightBuffer+tool.hnonrigidPanel.PanelHeight;
                    tool.hnonrigidPanel.BodyPosition=[0,containerHeight-((2*headerHeight)+border)-heightBuffer,containerWidth,tool.hnonrigidPanel.PanelHeight];
                end
            case 'Nonrigid'

                tool.hnonrigidOnlyPanel.HeaderPosition=[0,containerHeight-headerHeight,containerWidth,headerHeight];
                if tool.hnonrigidOnlyPanel.PanelSelected
                    heightBuffer=heightBuffer+tool.hnonrigidOnlyPanel.PanelHeight;
                    tool.hnonrigidOnlyPanel.BodyPosition=[0,containerHeight-headerHeight-heightBuffer,containerWidth,tool.hnonrigidOnlyPanel.PanelHeight];
                end
            end
        end

        function setParameterViewState(tool)
            switch tool.hDataBrowser.getModelName()
            case{'SURF','FAST','MSER','BRISK','Harris','MinEigen'}

                tool.hfeaturePanel.showPanel();
                tool.hnonrigidPanel.showPanel();

                tool.hphaseCorrelationPanel.hidePanel();
                tool.hcoarseAlignmentPanel.hidePanel();
                tool.hmonomodalPanel.hidePanel();
                tool.hmultimodalPanel.hidePanel();
                tool.hnonrigidOnlyPanel.hidePanel();
                tool.hKAZEPanel.hidePanel();
                tool.hORBPanel.hidePanel();
            case 'KAZE'

                tool.hKAZEPanel.showPanel();
                tool.hnonrigidPanel.showPanel();

                tool.hfeaturePanel.hidePanel();
                tool.hphaseCorrelationPanel.hidePanel();
                tool.hcoarseAlignmentPanel.hidePanel();
                tool.hmonomodalPanel.hidePanel();
                tool.hmultimodalPanel.hidePanel();
                tool.hnonrigidOnlyPanel.hidePanel();
                tool.hORBPanel.hidePanel();
            case 'ORB'

                tool.hORBPanel.showPanel();
                tool.hnonrigidPanel.showPanel();

                tool.hfeaturePanel.hidePanel();
                tool.hphaseCorrelationPanel.hidePanel();
                tool.hcoarseAlignmentPanel.hidePanel();
                tool.hmonomodalPanel.hidePanel();
                tool.hmultimodalPanel.hidePanel();
                tool.hnonrigidOnlyPanel.hidePanel();
                tool.hKAZEPanel.hidePanel();
            case 'Monomodal'

                tool.hcoarseAlignmentPanel.showPanel();
                tool.hmonomodalPanel.showPanel();
                tool.hnonrigidPanel.showPanel();

                tool.hfeaturePanel.hidePanel();
                tool.hphaseCorrelationPanel.hidePanel();
                tool.hmultimodalPanel.hidePanel();
                tool.hnonrigidOnlyPanel.hidePanel();
                tool.hKAZEPanel.hidePanel();
                tool.hORBPanel.hidePanel();
            case 'Multimodal'

                tool.hcoarseAlignmentPanel.showPanel();
                tool.hmultimodalPanel.showPanel();
                tool.hnonrigidPanel.showPanel();

                tool.hfeaturePanel.hidePanel();
                tool.hphaseCorrelationPanel.hidePanel();
                tool.hmonomodalPanel.hidePanel();
                tool.hnonrigidOnlyPanel.hidePanel();
                tool.hKAZEPanel.hidePanel();
                tool.hORBPanel.hidePanel();
            case 'Phase Correlation'

                tool.hphaseCorrelationPanel.showPanel();
                tool.hnonrigidPanel.showPanel();

                tool.hfeaturePanel.hidePanel();
                tool.hcoarseAlignmentPanel.hidePanel();
                tool.hmonomodalPanel.hidePanel();
                tool.hmultimodalPanel.hidePanel();
                tool.hnonrigidOnlyPanel.hidePanel();
                tool.hKAZEPanel.hidePanel();
                tool.hORBPanel.hidePanel();
            case 'Nonrigid'

                tool.hnonrigidOnlyPanel.showPanel();

                tool.hnonrigidPanel.hidePanel();
                tool.hfeaturePanel.hidePanel();
                tool.hphaseCorrelationPanel.hidePanel();
                tool.hcoarseAlignmentPanel.hidePanel();
                tool.hmonomodalPanel.hidePanel();
                tool.hmultimodalPanel.hidePanel();
                tool.hKAZEPanel.hidePanel();
                tool.hORBPanel.hidePanel();
            end
        end

        function setupControlPanel(tool)

            import images.internal.app.registration.ui.*;


            drawnow;

            tool.hfeaturePanel=images.internal.app.registration.ui.FeatureParameterPanel(tool.hRightPanel.Figure);
            tool.hKAZEPanel=images.internal.app.registration.ui.KAZEParameterPanel(tool.hRightPanel.Figure);
            tool.hORBPanel=images.internal.app.registration.ui.ORBParameterPanel(tool.hRightPanel.Figure);
            tool.hphaseCorrelationPanel=images.internal.app.registration.ui.PhaseParameterPanel(tool.hRightPanel.Figure);
            tool.hcoarseAlignmentPanel=images.internal.app.registration.ui.CoarseParameterPanel(tool.hRightPanel.Figure);
            tool.hmonomodalPanel=images.internal.app.registration.ui.MonomodalParameterPanel(tool.hRightPanel.Figure);
            tool.hmultimodalPanel=images.internal.app.registration.ui.MultimodalParameterPanel(tool.hRightPanel.Figure);
            tool.hnonrigidPanel=images.internal.app.registration.ui.NonrigidParameterPanel(tool.hRightPanel.Figure,true);
            tool.hnonrigidOnlyPanel=images.internal.app.registration.ui.NonrigidParameterPanel(tool.hRightPanel.Figure,false);

            addlistener(tool.hfeaturePanel,'ExpandedDropDown',...
            @(~,~)tool.updateControlPanel());
            addlistener(tool.hKAZEPanel,'ExpandedDropDown',...
            @(~,~)tool.updateControlPanel());
            addlistener(tool.hORBPanel,'ExpandedDropDown',...
            @(~,~)tool.updateControlPanel());
            addlistener(tool.hphaseCorrelationPanel,'ExpandedDropDown',...
            @(~,~)tool.updateControlPanel());
            addlistener(tool.hcoarseAlignmentPanel,'ExpandedDropDown',...
            @(~,~)tool.updateControlPanel());
            addlistener(tool.hmonomodalPanel,'ExpandedDropDown',...
            @(~,~)tool.updateControlPanel());
            addlistener(tool.hmultimodalPanel,'ExpandedDropDown',...
            @(~,~)tool.updateControlPanel());
            addlistener(tool.hnonrigidPanel,'ExpandedDropDown',...
            @(~,~)tool.updateControlPanel());
            addlistener(tool.hnonrigidOnlyPanel,'ExpandedDropDown',...
            @(~,~)tool.updateControlPanel());

            addlistener(tool.hfeaturePanel,'UpdatedSettings',...
            @(~,~)tool.updateParameters());
            addlistener(tool.hKAZEPanel,'UpdatedSettings',...
            @(~,~)tool.updateParameters());
            addlistener(tool.hORBPanel,'UpdatedSettings',...
            @(~,~)tool.updateParameters());
            addlistener(tool.hphaseCorrelationPanel,'UpdatedSettings',...
            @(~,~)tool.updateParameters());
            addlistener(tool.hcoarseAlignmentPanel,'UpdatedSettings',...
            @(~,~)tool.updateParameters());
            addlistener(tool.hmonomodalPanel,'UpdatedSettings',...
            @(~,~)tool.updateParameters());
            addlistener(tool.hmultimodalPanel,'UpdatedSettings',...
            @(~,~)tool.updateParameters());
            addlistener(tool.hnonrigidPanel,'UpdatedSettings',...
            @(~,~)tool.updateParameters());
            addlistener(tool.hnonrigidOnlyPanel,'UpdatedSettings',...
            @(~,~)tool.updateParameters());
        end

    end

end
