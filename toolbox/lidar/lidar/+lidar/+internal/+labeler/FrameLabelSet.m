



classdef FrameLabelSet<lidar.internal.labeler.LabelSet












    methods

        function this=FrameLabelSet(varargin)







            if nargin>0
                [varargin{:}]=convertStringsToChars(varargin{:});
            end
            this.initializeColorLookup('scene');

            this.NumLabels=0;
            this.ColorCounter=0;

            this.DefinitionStruct=struct(...
            'Name',{},...
            'LabelID',[],...
            'Color',[],...
            'VoxelLabelID',[],...
            'Group','',...
            'Description','');

            if nargin>0
                labelNames=cellstr(varargin{1});

                for n=1:numel(labelNames)
                    this.addLabel(labelNames{n});
                end
            end
        end


        function tf=validateLabelName(this,labelName,figHandle)

            tf=true;



            [validLabelName,uniqueLabelName]=this.isUniqueLabelName(labelName);
            if~validLabelName
                invalidNameDialog(this,figHandle);
                tf=false;
            elseif~uniqueLabelName
                duplicateNameDialog(this,figHandle);
                tf=false;
            end
        end


        function frameLabel=addLabel(this,frameLabel)


            labelName=frameLabel.Label;
            description=frameLabel.Description;
            group=frameLabel.Group;



            [validLabelName,uniqueLabelName]=this.isUniqueLabelName(labelName);
            if~validLabelName
                invalidNameDialog(this);
                return;
            elseif~uniqueLabelName
                duplicateNameDialog(this);
                return;
            end

            if isempty(this.ColorCounter)
                this.ColorCounter=0;
            end

            this.NumLabels=this.NumLabels+1;
            this.ColorCounter=this.ColorCounter+1;





            while this.ColorCounter>=this.maxColors
                this.growColorLookup();
            end
            colorVal=reshape(this.colorLookup(:,this.ColorCounter,:),1,3);

            if(isempty(frameLabel.Color))
                frameLabel.Color=colorVal;
            end



            if isequal(size(frameLabel.Color),[3,1])
                frameLabel.Color=frameLabel.Color';
            end

            definitionStruct=struct('Name',labelName,...
            'LabelID',this.NumLabels,'Color',frameLabel.Color,...
            'VoxelLabelID','','Group',group,...
            'Description',description);

            this.DefinitionStruct=[this.DefinitionStruct;definitionStruct];

            labelID=this.NumLabels;
            evtData=this.createEventDataPacket(labelID);
            notify(this,'LabelAdded',evtData);
        end


        function frameLabel=queryLabel(this,labelID)








            labelID=this.labelNameToID(labelID);
            labelDataStruct=this.DefinitionStruct(labelID);

            this.DefinitionStruct(labelID).Description=vision.internal.labeler.retrieveNewLine(this.DefinitionStruct(labelID).Description);

            name=labelDataStruct.Name;
            descr=labelDataStruct.Description;
            color=labelDataStruct.Color;
            group=labelDataStruct.Group;

            frameLabel=vision.internal.labeler.FrameLabel(name,descr,group);
            frameLabel.Color=color;
        end


        function labelSetTable=export2table(this)





            labelSetTable=export2table@vision.internal.labeler.LabelSet(this);

            labelSetTable.Type=repmat(labelType.Scene,height(labelSetTable),1);

            labelSetTable=labelSetTable(:,{'Name','Type','LabelColor','VoxelLabelID','Group','Description'});
        end


        function TF=hasSceneLabel(this)


            TF=this.NumLabels>0;
        end

    end

    methods(Static,Hidden)
        function this=loadobj(that)

            this=vision.internal.labeler.FrameLabelSet;
            definitionStruct=that.DefinitionStruct;



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

            this.DefinitionStruct=definitionStruct;
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
