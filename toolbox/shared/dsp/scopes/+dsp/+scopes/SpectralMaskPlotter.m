classdef SpectralMaskPlotter<handle






    properties

        MaskVisibility='None';

        MaskPatches=[];
    end

    properties(SetAccess=protected)
        Application;
        SpectrumPlotter;
        MaskSpecificationObject=[];
    end

    properties(Access=protected)
        MaskExtents=[NaN,NaN];
        VisualListeners;
    end

    properties(Constant)
        MaskPatchProperties=struct(...
        'FaceColor',[0.3,0.9,0.3],...
        'FaceAlpha',.4,...
        'EdgeColor','none');
        MaskPatchPassedProperties=struct(...
        'FaceColor',[0,1,0.4]);
        MaskPatchFailedProperties=struct(...
        'FaceColor',[1,0.3,0]);
    end

    methods
        function this=SpectralMaskPlotter(hSpectrumPlotter)

            this.SpectrumPlotter=hSpectrumPlotter;
            this.MaskSpecificationObject=hSpectrumPlotter.MaskSpecificationObject;
            this.Application=hSpectrumPlotter.MaskSpecificationObject.Application;
        end

        function delete(this)

            this.MaskPatches=[];
            deleteVisualListeners(this);
        end

        function set.MaskVisibility(this,value)




            this.MaskVisibility=value;

            if isempty(this.MaskPatches)
                createMasks(this);
            end

            if strcmp(value,'None')
                set(this.MaskPatches,'Visible','off');%#ok<*MCSUP>
                deleteVisualListeners(this);
            else
                createVisualListeners(this);
                if strcmp(value,'Upper')
                    set(this.MaskPatches(1),'Visible','on');
                    set(this.MaskPatches(2),'Visible','off');
                elseif strcmp(value,'Lower')
                    set(this.MaskPatches(1),'Visible','off');
                    set(this.MaskPatches(2),'Visible','on');
                else
                    set(this.MaskPatches,'Visible','on');
                end
            end

            draw(this);
        end

        function yExtents=getMaskYExtents(this)

            yExtents=this.MaskExtents;
        end

        function draw(this)





            hPlotter=this.SpectrumPlotter;
            maskVisibility=this.MaskVisibility;



            if strcmp(maskVisibility,'None')
                this.MaskExtents=[NaN,NaN];
                updateYExtents(hPlotter);
                return;
            end



            currMask=getCurrentMask(this.Application.Visual.MaskTesterObject);

            maskExtents=[NaN,NaN];

            if(strcmp(maskVisibility,'Upper')||strcmp(maskVisibility,'Upper and lower'))&&...
                ~isempty(currMask.UpperMask)
                freqUpper=currMask.UpperMask(:,1);
                powerUpper=currMask.UpperMask(:,2);
                drawMaskPatch(this,'Upper',freqUpper,powerUpper);
                maskExtents=[min(maskExtents(1),min(powerUpper)),...
                max(maskExtents(2),max(powerUpper))];
            end


            if(strcmp(maskVisibility,'Lower')||strcmp(maskVisibility,'Upper and lower'))&&...
                ~isempty(currMask.LowerMask)
                freqLower=currMask.LowerMask(:,1);
                powerLower=currMask.LowerMask(:,2);
                drawMaskPatch(this,'Lower',freqLower,powerLower);
                maskExtents=[min(maskExtents(1),min(powerLower)),...
                max(maskExtents(2),max(powerLower))];
            end


            this.MaskExtents=maskExtents;
            updateYExtents(hPlotter);
        end

        function updateMaskColor(this)

            maskTester=this.Application.Visual.MaskTesterObject;
            if maskTester.IsCurrentlyPassing
                failingMasks='None';
            else
                failingMasks=maskTester.FailingMasks;
            end
            hUpperMask=this.MaskPatches(1);
            hLowerMask=this.MaskPatches(2);
            switch failingMasks
            case 'None'
                set(hUpperMask,this.MaskPatchPassedProperties);
                set(hLowerMask,this.MaskPatchPassedProperties);
            case 'Upper'
                set(hUpperMask,this.MaskPatchFailedProperties);
                set(hLowerMask,this.MaskPatchPassedProperties);
            case 'Lower'
                set(hUpperMask,this.MaskPatchPassedProperties);
                set(hLowerMask,this.MaskPatchFailedProperties);
            case 'Upper and lower'
                set(hUpperMask,this.MaskPatchFailedProperties);
                set(hLowerMask,this.MaskPatchFailedProperties);
            end
        end
    end

    methods(Access=protected)
        function createVisualListeners(this)


            this.VisualListeners={...
            uiservices.addlistener(this.Application,'VisualUpdated',...
            uiservices.makeCallback(@onVisualUpdated,this))...
            ,uiservices.addlistener(this.Application,'VisualLimitsChanged',...
            uiservices.makeCallback(@onVisualLimitsChanged,this))};
        end

        function deleteVisualListeners(this)
            for indx=1:numel(this.VisualListeners)
                delete(this.VisualListeners{indx});
            end
            this.VisualListeners=[];
        end

        function onVisualUpdated(this)

            if~strcmp(this.MaskVisibility,'None')
                if strcmp(this.MaskSpecificationObject.ReferenceLevel,'Spectrum peak')
                    draw(this);
                end
                updateMaskColor(this);
            end
        end

        function onVisualLimitsChanged(this)

            if~strcmp(this.MaskVisibility,'None')
                draw(this);
            end
        end

        function createMasks(this)
            maskPatchProperties=this.MaskPatchProperties;
            cPatch=maskPatchProperties.FaceColor;

            hMaskPatches=this.MaskPatches;
            if isempty(hMaskPatches)||~ishghandle(hMaskPatches)
                hUpperMaskPatch=patch(0,NaN,cPatch,...
                'Parent',this.SpectrumPlotter.Axes(1),...
                'Tag','SpectralMaskPatch_Upper',...
                'DisplayName',getString(message('dspshared:SpectrumAnalyzer:SpectralMaskUpper')));
                set(hUpperMaskPatch,maskPatchProperties);
                hLowerMaskPatch=patch(0,NaN,cPatch,...
                'Parent',this.SpectrumPlotter.Axes(1),...
                'Tag','SpectralMaskPatch_Lower',...
                'DisplayName',getString(message('dspshared:SpectrumAnalyzer:SpectralMaskLower')));
                set(hLowerMaskPatch,maskPatchProperties);
                hMaskPatches=[hUpperMaskPatch,hLowerMaskPatch];
            end
            uistack(hMaskPatches,'bottom');
            this.MaskPatches=hMaskPatches;
        end

        function drawMaskPatch(this,maskType,freqValues,powerValues)


            hPlotter=this.SpectrumPlotter;

            if strcmp(hPlotter.FrequencyScale,'Log')
                freqValues=freqValues(freqValues>=0);
                powerValues=powerValues(freqValues>=0);
                if any(freqValues==0)&&~isempty(hPlotter.XDataStepSize)
                    freqValues(freqValues==0)=hPlotter.XDataStepSize;
                end
            end


            yLim=get(hPlotter.Axes(1),'YLim');
            powerVertices=[freqValues(:),powerValues(:)];
            maskLength=numel(powerValues);
            if strcmp(maskType,'Upper')
                hMaskPatch=this.MaskPatches(1);
                YLimVertices=[freqValues(:),repmat(yLim(2),maskLength,1)];
            else
                hMaskPatch=this.MaskPatches(2);
                YLimVertices=[freqValues(:),repmat(yLim(1),maskLength,1)];
            end
            vertices=[powerVertices;YLimVertices];


            dsig=diff([0;isfinite(powerValues(:));0]);
            startIndex=find(dsig>0);
            endIndex=find(dsig<0)-1;
            numPatches=numel(startIndex);
            faces=zeros(numPatches,2*maskLength);
            maxFaceWidth=0;
            for idx=1:numPatches
                currPatch=startIndex(idx):endIndex(idx);
                currPatchFaces=[currPatch,maskLength+fliplr(currPatch)];
                faceWidth=numel(currPatchFaces);
                maxFaceWidth=max(maxFaceWidth,faceWidth);
                currFacesVector=repmat(currPatchFaces,1,ceil(2*maskLength/faceWidth));
                faces(idx,:)=currFacesVector(1:2*maskLength);
            end
            faces=faces(:,1:maxFaceWidth);
            set(hMaskPatch,'Vertices',vertices,'Faces',faces);
        end
    end
end
