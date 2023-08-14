
















classdef ROILabelSet<vision.internal.labeler.ROILabelSet&lidar.internal.labeler.LabelSet













    events
VoxelLabelRemoved
    end

    methods

        function this=ROILabelSet(varargin)











            this.initializeColorLookup('roi');
            this.voxelColorLookup=lidar.internal.labeler.getColorMap('voxel');


            this.voxelColorLookupGlobal=...
            single(squeeze(lidar.internal.labeler.getColorMap('voxel')));

            this.NumLabels=0;
            this.VoxelLabelID=0;
            this.ColorCounter=0;

            this.DefinitionStruct=struct(...
            'Name',{},...
            'LabelID',[],...
            'Type',{},...
            'Color',[],...
            'VoxelLabelID',[],...
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
                    roiLabel=lidar.internal.labeler.ROILabel(shapes{n},labelNames{n},'',groups{n});
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



            goodRoiType=(isa(shape,'labelType')||isa(shape,'lidarLabelType'))&&shape.isROI;

            assert(goodRoiType,'Invalid ROI shape was specified')
            if shape==lidarLabelType.Voxel
                if iscell(roiLabel.VoxelLabelID)

                    voxelID=roiLabel.VoxelLabelID{1};
                else
                    voxelID=roiLabel.VoxelLabelID;
                end
                assert(voxelID<=255,'The maximum voxel label ID is 255.');
                assert(voxelID>0,'The minimum voxel label ID is 0.');
                colorVal=reshape(this.voxelColorLookup(:,voxelID,:),1,3);

                if~isempty(roiLabel.Color)
                    this.voxelColorLookupGlobal(voxelID,:)=roiLabel.Color;
                end
            else
                voxelID=[];
                this.ColorCounter=this.ColorCounter+1;





                while this.ColorCounter>=this.maxColors
                    this.growColorLookup();
                end
                colorVal=reshape(this.colorLookup(:,this.ColorCounter,:),1,3);
            end

            if~strcmp(class(roiLabel),'vision.internal.labeler.ROILabel')
                roiLabel.VoxelLabelID=voxelID;
            end

            if isempty(roiLabel.Color)
                roiLabel.Color=colorVal;
            end


            if isequal(size(roiLabel.Color),[3,1])
                roiLabel.Color=roiLabel.Color';
            end

            this.NumLabels=this.NumLabels+1;
            definitionStruct=struct('Name',labelName,...
            'LabelID',this.NumLabels,'Type',{shape},...
            'Color',roiLabel.Color,'VoxelLabelID',voxelID,...
            'Group',group,'Description',description,...
            'ROIVisibility',roiVisibility);
            this.DefinitionStruct=[this.DefinitionStruct;definitionStruct];

            assert(this.NumLabels==numel(this.DefinitionStruct),...
            'ROILabelSet: number of labels is inconsistent with DefinitionStruct.');

            labelID=this.NumLabels;
            evtData=this.createEventDataPacket(labelID);
            notify(this,'LabelAdded',evtData);
        end

        function roiLabel=queryLabel(this,labelName)








            labelID=this.labelNameToID(labelName);
            labelDataStruct=this.DefinitionStruct(labelID);

            this.DefinitionStruct(labelID).Description=vision.internal.labeler.retrieveNewLine(this.DefinitionStruct(labelID).Description);

            shape=labelDataStruct.Type;
            name=labelDataStruct.Name;
            descr=labelDataStruct.Description;
            color=labelDataStruct.Color;
            voxelLabelID=labelDataStruct.VoxelLabelID;
            group=labelDataStruct.Group;

            if isfield(labelDataStruct,'ROIVisibility')
                roiVisibility=labelDataStruct.ROIVisibility;
            else
                roiVisibility=true;
            end

            roiLabel=lidar.internal.labeler.ROILabel(shape,name,descr,group);
            roiLabel.Color=color;
            roiLabel.VoxelLabelID=voxelLabelID;
            roiLabel.ROIVisibility=roiVisibility;
        end


        function isVoxLabel=isaVoxelLabel(this,labelName)

            for n=1:this.NumLabels
                if strcmp(this.DefinitionStruct(n).Name,labelName)...
                    &&strcmp(this.DefinitionStruct(n).Type,'Voxel')
                    isVoxLabel=true;
                    return
                end
            end
            isVoxLabel=false;
        end
    end


    methods(Static,Hidden)
        function this=loadobj(that)



            voxelColorLookupGlobal=that.voxelColorLookupGlobal;
            this=lidar.internal.labeler.ROILabelSet;

            if~isempty(voxelColorLookupGlobal)
                this.voxelColorLookupGlobal=voxelColorLookupGlobal;
            end

            this.DefinitionStruct=that.DefinitionStruct;
            this.NumLabels=that.NumLabels;
            this.VoxelLabelID=that.VoxelLabelID;
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
