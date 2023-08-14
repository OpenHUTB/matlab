classdef AlgorithmLabelChecker<handle




    properties

Algorithm


ValidSignalType



ROILabelDefinitions



FrameLabelDefinitions


ValidROILabelNames



InvalidROILabelIndices


ValidFrameLabelNames



InvalidFrameLabelIndices


ValidPixelLabelNames



InvalidPixelLabelNames
    end

    methods





        function this=AlgorithmLabelChecker(algorithm,roiDefs,frameDefs,signalType)

            this.Algorithm=algorithm;
            this.ROILabelDefinitions=toROILabelDefs(this,roiDefs);
            this.FrameLabelDefinitions=toFrameLabelDefs(this,frameDefs);
            discardEmptyAttributes(this);
            checkValidSignalType(this,signalType);
            computeValidLabelDefinitions(this);
        end





        function[validLabels,validIdx]=computeValidROIs(this,labels,currentTime)

            hasTemporalContext=nargin>2;

            validIdx=arrayfun(@(s)any(strcmpi(s.Label,this.ValidROILabelNames)),labels);

            labels=labels(validIdx);

            validLabels=repmat(struct('ID','',...
            'Type',labelType.empty,...
            'Name',[],...
            'Position',[],...
            'Attribute',[],...
            'Time',[]),...
            numel(labels),1);

            for n=1:numel(validLabels)
                validLabels(n).ID=labels(n).ID;
                validLabels(n).Type=labels(n).Shape;
                validLabels(n).Name=labels(n).Label;
                validLabels(n).Position=labels(n).Position;
                validLabels(n).Attribute=[];


                if hasTemporalContext
                    validLabels(n).Time=currentTime;
                end
            end
        end





        function TF=isAlgorithmSelectionConsistent(this)

            TF=~(isempty(this.ValidROILabelNames)&&isempty(this.ValidFrameLabelNames));
        end





        function TF=hasPixelLabels(this)

            types=[this.ROILabelDefinitions.Type];


            validIdx=true(size(types));
            validIdx(this.InvalidROILabelIndices)=0;
            validTypes=types(validIdx);


            TF=any(validTypes==labelType.PixelLabel);
        end





        function TF=onlyPixelLabels(this)

            types=[this.ROILabelDefinitions.Type];


            validIdx=true(size(types));
            validIdx(this.InvalidROILabelIndices)=0;
            validTypes=types(validIdx);

            TF=all(validTypes==labelType.PixelLabel);
        end





        function openCheckLabelDefinition(this)

            algClass=class(this.Algorithm);
            filePath=which(algClass);

            if isempty(filePath)

                edit(algClass);
            else

                matlab.desktop.editor.openAndGoToFunction(filePath,'checkLabelDefinition');
            end
        end





        function TF=allPixelLabels(this)

            TF=isempty(this.InvalidPixelLabelNames);
        end


        function pixelLabelNames=get.ValidPixelLabelNames(this)
            allValidROINames=this.ValidROILabelNames;
            pixelLabelNames=allValidROINames([this.ROILabelDefinitions.Type]==labelType.PixelLabel);
        end


        function invalidPixelLabelNames=get.InvalidPixelLabelNames(this)

            allPixelLabelNames={this.ROILabelDefinitions([this.ROILabelDefinitions.Type]==labelType.PixelLabel).Name};
            validROILabelNames=this.ValidROILabelNames;

            invalidPixelLabelNames=setdiff(allPixelLabelNames,validROILabelNames);
        end
    end

    methods(Access=private)

        function defs=toROILabelDefs(~,roiLabelList)


            hasLabelAttribute=true;

            if hasLabelAttribute
                defs=repmat(struct('Type',[],'Name',[],'Attributes',[]),numel(roiLabelList),1);
            else
                defs=repmat(struct('Type',[],'Name',[]),numel(roiLabelList),1);%#ok<UNRCH>
            end

            for n=1:numel(roiLabelList)
                defs(n).Type=roiLabelList(n).ROI;
                defs(n).Name=roiLabelList(n).Label;

                if hasLabelAttribute
                    defs(n).Attributes=roiLabelList(n).Attributes;
                    if isfield(defs(n).Attributes,'Description')
                        defs(n).Attributes=rmfield(defs(n).Attributes,'Description');
                    end
                end


                if defs(n).Type==labelType.PixelLabel&&~isempty(roiLabelList(n).PixelLabelID)
                    defs(n).PixelLabelID=roiLabelList(n).PixelLabelID;
                end
            end


        end


        function defs=toFrameLabelDefs(~,frameLabelList)


            labType=labelType.Scene;

            hasLabelAttribute=true;

            if hasLabelAttribute


                defs=repmat(struct('Type',[],'Name',[],'Attributes',[]),numel(frameLabelList),1);
            else
                defs=repmat(struct('Type',[],'Name',[]),numel(frameLabelList),1);%#ok<UNRCH>
            end
            for n=1:numel(frameLabelList)
                defs(n).Type=labType;
                defs(n).Name=frameLabelList(n).Label;

            end
        end


        function checkValidSignalType(this,signalType)

            if this.Algorithm.checkSignalType(signalType)
                this.ValidSignalType=signalType;
            else
                switch signalType
                case vision.labeler.loading.SignalType.PointCloud
                    type="point cloud";
                otherwise
                    type=lower(string(signalType));
                end
                error(message('vision:labeler:InvalidSignalType',...
                this.Algorithm.Name,type));
            end

        end


        function computeValidLabelDefinitions(this)



            algorithm=this.Algorithm;

            isValidROILabel=false(size(this.ROILabelDefinitions));
            for n=1:numel(this.ROILabelDefinitions)
                isValidSignalType=false(size(this.ValidSignalType));




                for j=1:size(this.ValidSignalType,1)
                    isValidSignalType(j)=checkLabelDefinition(algorithm,this.ROILabelDefinitions(n))...
                    &&checkSignalTypeSupport(this,this.ROILabelDefinitions(n),this.ValidSignalType(j));
                end
                idx=find(isValidSignalType);
                if(idx)
                    isValidROILabel(n)=true;
                end
            end

            isValidFrameLabel=false(size(this.FrameLabelDefinitions));
            for n=1:numel(this.FrameLabelDefinitions)
                isValidFrameLabel(n)=checkLabelDefinition(algorithm,this.FrameLabelDefinitions(n));
            end

            this.ValidROILabelNames={this.ROILabelDefinitions(isValidROILabel).Name};
            this.ValidFrameLabelNames={this.FrameLabelDefinitions(isValidFrameLabel).Name};

            this.InvalidROILabelIndices=find(~isValidROILabel);
            this.InvalidFrameLabelIndices=find(~isValidFrameLabel);
        end

        function isValid=checkSignalTypeSupport(~,roiDef,validSignalType)

            switch validSignalType

            case vision.labeler.loading.SignalType.Image


                isValid=roiDef.Type~=labelType.Cuboid;

            case vision.labeler.loading.SignalType.PointCloud


                isValid=(roiDef.Type==labelType.Cuboid)||(roiDef.Type==labelType.Line);

            end


        end


        function discardEmptyAttributes(this)

            allLabelAttribsEmpty=true;
            for i=1:numel(this.ROILabelDefinitions)
                if~isempty(this.ROILabelDefinitions(i).Attributes)
                    allLabelAttribsEmpty=false;
                    break;
                end
            end
            if allLabelAttribsEmpty
                this.ROILabelDefinitions=rmfield(this.ROILabelDefinitions,'Attributes');
                this.FrameLabelDefinitions=rmfield(this.FrameLabelDefinitions,'Attributes');
            end
        end
    end

end
