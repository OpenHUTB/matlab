



classdef ROISublabelSet<vision.internal.labeler.SublabelSet












    methods

        function this=ROISublabelSet(varargin)




            this.NumSublabels=0;
            this.PixelSublabelID=0;

            this.DefinitionStruct=struct(...
            'LabelName',[],...
            'Name',{},...
            'SublabelID',[],...
            'Type',labelType.empty,...
            'Color',[],...
            'PixelSublabelID',[],...
            'Description','',...
            'ROIVisibility','');
        end


        function tf=validateSublabelName(this,sublabelName,labelName,hFig)

            tf=true;



            [validSublabelName,uniqueSublabelName]=this.isUniqueSublabelName(labelName,sublabelName);

            if~validSublabelName
                invalidNameDialog(this,hFig);
                tf=false;
            elseif~uniqueSublabelName
                duplicateNameDialog(this,hFig);
                tf=false;
            end
        end


        function tf=validateSublabelColor(this,sublabelColor,hFig)


            tf=true;

            validSublabelColor=~isequal(sublabelColor,[1,1,0]);

            if~validSublabelColor
                invalidColorDialog(this,hFig);
                tf=false;
            end
        end


        function roiSublabel=addSublabel(this,roiSublabel)


            labelName=roiSublabel.LabelName;
            sublabelName=roiSublabel.Sublabel;
            shape=roiSublabel.ROI;
            description=roiSublabel.Description;
            color=roiSublabel.Color;
            roiVisibility=roiSublabel.ROIVisibility;



            [validSublabelName,uniqueSublabelName]=this.isUniqueSublabelName(labelName,sublabelName);
            if~validSublabelName
                invalidNameDialog(this);
                return;
            elseif~uniqueSublabelName
                duplicateNameDialog(this);
                return;
            end



            goodRoiType=isa(shape,'labelType')&&shape.isROI;

            assert(goodRoiType,'Invalid ROI shape was specified')

            this.NumSublabels=this.NumSublabels+1;

            if shape==labelType.PixelLabel
                pixelID=roiSublabel.PixelSublabelID;
                assert(pixelID<=255,'The maximum pixel sublabel ID is 255.');
                assert(pixelID>0,'The minimum pixel sublabel ID is 0.');
            else
                pixelID=[];
            end

            roiSublabel.PixelSublabelID=pixelID;

            definitionStruct=struct('LabelName',labelName,...
            'Name',sublabelName,...
            'SublabelID',this.NumSublabels,...
            'Type',shape,...
            'Color',color,...
            'PixelSublabelID',pixelID,...
            'Description',description,...
            'ROIVisibility',roiVisibility);
            this.DefinitionStruct=[this.DefinitionStruct;definitionStruct];
            sublabelID=this.NumSublabels;
            evtData=this.createEventDataPacket(sublabelID);
            notify(this,'SublabelAdded',evtData);
        end


        function roiSublabels=querySublabelFamily(this,labelName)
            sublabelNames=querySublabelNames(this,labelName);
            numSublabels=numel(sublabelNames);
            if numSublabels==0
                roiSublabels={};
                return;
            end
            for i=1:numSublabels
                roiSublabels{i}=querySublabel(this,labelName,sublabelNames{i});%#ok<AGROW>
            end
        end


        function roiSublabel=querySublabel(this,labelName,sublabelName)








            sublabelID=this.sublabelNameToID(labelName,sublabelName);
            sublabelDataStruct=this.DefinitionStruct(sublabelID);

            this.DefinitionStruct(sublabelID).Description=vision.internal.labeler.retrieveNewLine(this.DefinitionStruct(sublabelID).Description);

            name=sublabelDataStruct.Name;
            shape=sublabelDataStruct.Type;

            descr=sublabelDataStruct.Description;
            pixelSublabelID=sublabelDataStruct.PixelSublabelID;

            if isfield(sublabelDataStruct,'ROIVisibility')
                roiVisibility=sublabelDataStruct.ROIVisibility;
            else
                roiVisibility=true;
            end
            roiSublabel=vision.internal.labeler.ROISublabel(labelName,shape,name,descr);
            roiSublabel.Color=sublabelDataStruct.Color;
            roiSublabel.PixelSublabelID=pixelSublabelID;
            roiSublabel.ROIVisibility=roiVisibility;
        end

        function TF=hasSublabels(this)
            TF=~isempty(this.DefinitionStruct);
        end

        function color=querySublabelColor(this,sublabelID)

            color=this.DefinitionStruct(sublabelID).Color;
        end


        function shape=querySublabelShape(this,sublabelID)


            shape=this.DefinitionStruct(sublabelID).Type;
        end


        function isROIVisible=querySublabelROIVisible(this,sublabelID)


            if isfield(this.DefinitionStruct(sublabelID),'ROIVisibility')
                isROIVisible=this.DefinitionStruct(sublabelID).ROIVisibility;
            else
                isROIVisible=true;
            end
        end


        function oldDescr=updateSublabelDescription(this,sublabelID,descr)


            oldDescr=this.DefinitionStruct(sublabelID).Description;
            this.DefinitionStruct(sublabelID).Description=descr;
        end


        function oldDescr=updateSublabelDescriptionFromName(this,labelName,sublabelName,descr)
            sublabelID=this.sublabelNameToID(labelName,sublabelName);
            oldDescr=updateSublabelDescription(this,sublabelID,descr);
        end
    end

end