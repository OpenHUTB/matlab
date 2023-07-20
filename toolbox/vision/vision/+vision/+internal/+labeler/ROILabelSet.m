
















classdef ROILabelSet<vision.internal.labeler.LabelSet













    methods

        function this=ROILabelSet(varargin)











            this.initializeColorLookup('roi');
            this.pixelColorLookup=vision.internal.labeler.getColorMap('pixel');


            this.pixelColorLookupGlobal=...
            single(squeeze(vision.internal.labeler.getColorMap('pixel')));

            this.NumLabels=0;
            this.PixelLabelID=0;
            this.ColorCounter=0;

            this.DefinitionStruct=struct(...
            'Name',{},...
            'LabelID',[],...
            'Type',labelType.empty,...
            'Color',[],...
            'PixelLabelID',[],...
            'Group','',...
            'Description','',...
            'ROIVisibility','');

            if nargin>=2
                labelNames=cellstr(varargin{1});
                shapes=varargin{2};

                if nargin==3
                    groups=cellstr(varargin{3});
                else
                    numLabels=numel(labelNames);
                    groups=cell(1,numLabels);
                    groups(:)={'None'};
                end

                for n=1:numel(labelNames)
                    roiLabel=vision.internal.labeler.ROILabel(shapes(n),labelNames{n},'',groups{n});
                    this.addLabel(roiLabel);
                end
            end
        end


        function roiLabel=addLabel(this,roiLabel,hFig)


            labelName=roiLabel.Label;
            shape=roiLabel.ROI;

            description=roiLabel.Description;
            group=roiLabel.Group;
            roiVisibility=roiLabel.ROIVisibility;



            [validLabelName,uniqueLabelName]=this.isUniqueLabelName(labelName);
            if~validLabelName
                invalidNameDialog(this,hFig);
                return;
            elseif~uniqueLabelName
                duplicateNameDialog(this,hFig);
                return;
            end



            goodRoiType=isa(shape,'labelType')&&shape.isROI;

            assert(goodRoiType,'Invalid ROI shape was specified')
            if shape==labelType.PixelLabel
                pixelID=roiLabel.PixelLabelID;
                assert(pixelID<=255,'The maximum pixel label ID is 255.');
                assert(pixelID>0,'The minimum pixel label ID is 0.');
                colorVal=reshape(this.pixelColorLookup(:,pixelID,:),1,3);

                if~isempty(roiLabel.Color)
                    this.pixelColorLookupGlobal(pixelID,:)=roiLabel.Color;
                end
            else
                pixelID=[];
                this.ColorCounter=this.ColorCounter+1;





                while this.ColorCounter>=this.maxColors
                    this.growColorLookup();
                end
                colorVal=reshape(this.colorLookup(:,this.ColorCounter,:),1,3);
            end

            roiLabel.PixelLabelID=pixelID;

            if isempty(roiLabel.Color)
                roiLabel.Color=colorVal;
            end


            if isequal(size(roiLabel.Color),[3,1])
                roiLabel.Color=roiLabel.Color';
            end

            this.NumLabels=this.NumLabels+1;
            definitionStruct=struct('Name',labelName,...
            'LabelID',this.NumLabels,'Type',shape,...
            'Color',roiLabel.Color,'PixelLabelID',pixelID,...
            'Group',group,'Description',description,...
            'ROIVisibility',roiVisibility);
            this.DefinitionStruct=[this.DefinitionStruct;definitionStruct];

            assert(this.NumLabels==numel(this.DefinitionStruct),...
            'ROILabelSet: number of labels is inconsistent with DefinitionStruct.');

            labelID=this.NumLabels;
            evtData=this.createEventDataPacket(labelID);
            notify(this,'LabelAdded',evtData);
        end


        function isPixLabel=isaPixelLabel(this,labelName)

            for n=1:this.NumLabels
                if strcmp(this.DefinitionStruct(n).Name,labelName)...
                    &&strcmp(this.DefinitionStruct(n).Type,'PixelLabel')
                    isPixLabel=true;
                    return
                end
            end
            isPixLabel=false;
        end


        function roiLabel=queryLabel(this,labelName)








            labelID=this.labelNameToID(labelName);
            labelDataStruct=this.DefinitionStruct(labelID);

            this.DefinitionStruct(labelID).Description=vision.internal.labeler.retrieveNewLine(this.DefinitionStruct(labelID).Description);

            shape=labelDataStruct.Type;
            name=labelDataStruct.Name;
            descr=labelDataStruct.Description;
            color=labelDataStruct.Color;
            pixelLabelID=labelDataStruct.PixelLabelID;
            group=labelDataStruct.Group;

            if isfield(labelDataStruct,'ROIVisibility')
                roiVisibility=labelDataStruct.ROIVisibility;
            else
                roiVisibility=true;
            end

            roiLabel=vision.internal.labeler.ROILabel(shape,name,descr,group);
            roiLabel.Color=color;
            roiLabel.PixelLabelID=pixelLabelID;
            roiLabel.ROIVisibility=roiVisibility;
        end



        function shape=queryLabelShape(this,labelID)


            shape=this.DefinitionStruct(labelID).Type;
        end


        function isROIVisible=queryROIVisible(this,labelID)

            if isfield(this.DefinitionStruct(labelID),'ROIVisibility')
                isROIVisible=this.DefinitionStruct(labelID).ROIVisibility;
            else
                isROIVisible=true;
            end
        end
    end


    methods(Static,Hidden)
        function this=loadobj(that)



            pixelColorLookupGlobal=that.pixelColorLookupGlobal;
            this=vision.internal.labeler.ROILabelSet;

            if~isempty(pixelColorLookupGlobal)
                this.pixelColorLookupGlobal=pixelColorLookupGlobal;
            end

            definitionStruct=that.DefinitionStruct;

            if isfield(definitionStruct,'Attributes')
                definitionStruct=rmfield(definitionStruct,'Attributes');
            end



            if~isfield(definitionStruct,'Group')
                labelNames={definitionStruct.Name};
                numLabels=numel(labelNames);
                groups=cell(1,numLabels);
                if numLabels>0
                    groups(:)={'None'};
                else
                    groups(:)={''};
                end
                [definitionStruct.Group]=groups{:};
            end



            if~isfield(definitionStruct,'ROIVisibility')
                labelNames={definitionStruct.Name};
                numLabels=numel(labelNames);
                roiVisible=cell(1,numLabels);
                if numLabels>0
                    roiVisible(:)={true};
                else
                    roiVisible(:)={''};
                end
                [definitionStruct.ROIVisibility]=roiVisible{:};
            end

            this.DefinitionStruct=definitionStruct;
            this.NumLabels=that.NumLabels;
            this.PixelLabelID=that.PixelLabelID;
            if isempty(that.ColorCounter)
                this.ColorCounter=0;
            else
                this.ColorCounter=that.ColorCounter;
            end


            this.colorLookup=that.colorLookup;
            this.maxColors=that.maxColors;



            while this.ColorCounter>=this.maxColors
                this.growColorLookup();
            end
        end
    end
end