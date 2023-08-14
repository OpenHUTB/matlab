




classdef LabelSet<vision.internal.labeler.LabelSet

    properties(GetAccess=public,SetAccess=protected)
VoxelLabelID
    end

    properties
voxelColorLookupGlobal
    end

    properties(Access=protected)
voxelColorLookup
    end


    methods

        function this=LabelSet()
            this=this@vision.internal.labeler.LabelSet();
        end
    end

    methods

        function renameLabel(this,labelName,newName)







            labelID=this.labelNameToID(labelName);



            if~strcmpi(labelName,newName)
                [validLabelName,uniqueLabelName]=this.isUniqueLabelName(newName);
                if~validLabelName
                    invalidNameDialog(this,hFig);
                    return;
                elseif~uniqueLabelName
                    duplicateNameDialog(this,hFig);
                    return;
                end
            end


            oldName=this.labelIDToName(labelID);

            this.DefinitionStruct(labelID).Name=newName;


            evtData=this.createEventDataPacket(labelID);
            evtData.OldLabel=oldName;

            notify(this,'LabelChanged',evtData);
        end


        function changeLabelColor(this,labelName,newLabelColor)

            labelID=this.labelNameToID(labelName);

            this.DefinitionStruct(labelID).Color=newLabelColor;


            if isfield(this.DefinitionStruct(labelID),'Type')
                if(this.DefinitionStruct(labelID).Type==lidarLabelType.Voxel)
                    voxelID=this.DefinitionStruct(labelID).VoxelLabelID;
                    this.voxelColorLookupGlobal(voxelID,:)=newLabelColor;
                end
            end


            evtData=this.createEventDataPacket(labelID);
            evtData.Color=newLabelColor;
            notify(this,'LabelChanged',evtData);
        end


        function changeROIVisibility(this,labelData)

            labelID=this.labelNameToID(labelData.Label);

            this.DefinitionStruct(labelID).ROIVisibility=labelData.ROIVisibility;

        end


        function modifyROIVisibility(this)
            labelCount=this.NumLabels;
            for i=1:labelCount
                if~this.DefinitionStruct(i).ROIVisibility
                    this.DefinitionStruct(i).ROIVisibility=true;
                end
            end
        end


        function removeLabel(this,labelName)







            labelID=this.labelNameToID(labelName);

            if~isfield(this.DefinitionStruct,'Type')||(this.DefinitionStruct(labelID).Type~=labelType.PixelLabel)

                evtData=this.createEventDataPacket(labelID);
                notify(this,'LabelRemoved',evtData);
            end


            this.DefinitionStruct(labelID)=[];


            this.NumLabels=this.NumLabels-1;



            if~hasVoxelLabel(this)
                notify(this,'VoxelLabelRemoved');
            end


            linearIDs=num2cell(1:numel(this.DefinitionStruct));
            [this.DefinitionStruct.LabelID]=deal(linearIDs{:});

        end


        function removeLabelsByLabelType(this,labeltype)

            if~this.hasPixelLabel()
                return
            end

            labelTypes=[this.DefinitionStruct.Type];
            pixLabelIds=find(labelTypes==labeltype);
            for id=flip(pixLabelIds)
                this.removeLabel(id);
            end

        end


        function[isValid,isUnique]=isUniqueLabelName(this,labelName)





            isValid=isvarname(labelName)||(iscellstr(labelName)&&...
            isscalar(labelName)&&isvarname(labelName{1}));
            isUnique=isValid&&(isempty(this.DefinitionStruct)||...
            ~any(strcmpi({this.DefinitionStruct.Name},labelName)));

        end


        function labelSetTable=export2table(this)





            if isempty(this.DefinitionStruct)
                labelSetTable=table({},{},{},{},{},{},'VariableNames',{'Name','Type','LabelColor','VoxelLabelID','Group','Description'});
            else
                labelSetTable=struct2table(this.DefinitionStruct,'AsArray',true);

                labelSetTable.Color=mat2cell(labelSetTable.Color,ones(size(labelSetTable.Color,1),1));


                isLabelIdPresent=any(strcmpi('LabelID',labelSetTable.Properties.VariableNames));
                if isLabelIdPresent
                    labelSetTable.LabelID=[];
                end


                isAttrPresent=any(strcmpi('Attributes',labelSetTable.Properties.VariableNames));
                if isAttrPresent
                    labelSetTable.Attributes=[];
                end


                isROIVisible=any(strcmpi('ROIVisibility',labelSetTable.Properties.VariableNames));
                if isROIVisible
                    labelSetTable.ROIVisibility=[];
                end


                if~iscell(labelSetTable.VoxelLabelID)





                    labelSetTable.VoxelLabelID=num2cell(labelSetTable.VoxelLabelID);
                end





                labelSetTable=movevars(labelSetTable,'Group','After','VoxelLabelID');


                idx=find(strcmpi(labelSetTable.Properties.VariableNames,'Color'));
                labelSetTable.Properties.VariableNames{idx}='LabelColor';
            end
        end


        function name=labelIDToName(this,id)





            if ischar(id)
                name=id;
            else
                name=this.DefinitionStruct(id).Name;
            end
        end


        function TF=isPixelLabel(this,labelID)
            if isfield(this.DefinitionStruct,'Type')
                labelTypes=[this.DefinitionStruct.Type];
                if length(labelTypes)>=labelID
                    TF=(labelTypes(labelID)==labelType.PixelLabel);
                else
                    TF=false;
                end
            else
                TF=false;
            end
        end


        function ID=labelNameToID(this,name)




            if ischar(name)||isstring(name)
                ID=find(strcmpi(name,{this.DefinitionStruct.Name}));

                assert(~isempty(ID),'Invalid Label Name');
            else
                ID=name;
            end
        end


        function TF=hasPixelLabel(this)


            TF=false;
            if~isempty(this)&&isfield(this.DefinitionStruct,'Type')
                for i=1:this.NumLabels
                    if this.DefinitionStruct(i).Type==labelType.PixelLabel
                        TF=true;
                        return;
                    end
                end
            end
        end


        function TF=hasVoxelLabel(this)


            TF=false;
            if~isempty(this)&&isfield(this.DefinitionStruct,'Type')
                for i=1:this.NumLabels
                    if this.DefinitionStruct(i).Type==lidarLabelType.Voxel
                        TF=true;
                        return;
                    end
                end
            end
        end


        function TF=hasLineLabel(this)


            TF=false;
            if~isempty(this)&&isfield(this.DefinitionStruct,'Type')
                for i=1:this.NumLabels
                    if this.DefinitionStruct(i).Type==labelType.Line
                        TF=true;
                        return;
                    end
                end
            end
        end


        function TF=hasPolygonLabel(this)


            if~isempty(this)&&isfield(this.DefinitionStruct,'Type')
                labelTypes=[this.DefinitionStruct.Type];
                TF=any(labelTypes==labelType.Polygon);
            else
                TF=false;
            end
        end


        function TF=hasRectangularLabel(this)


            TF=false;
            if~isempty(this)&&isfield(this.DefinitionStruct,'Type')
                for i=1:this.NumLabels
                    if this.DefinitionStruct(i).Type==labelType.Rectangle
                        TF=true;
                        return;
                    end
                end
            end
        end


        function TF=hasProjCuboidLabel(this)


            if~isempty(this)&&isfield(this.DefinitionStruct,'Type')
                labelTypes=[this.DefinitionStruct.Type];
                TF=any(labelTypes==labelType.ProjectedCuboid);
            else
                TF=false;
            end
        end


        function N=getNumROIByType(this,type)
            N=0;
            for i=1:this.NumLabels
                if this.DefinitionStruct(i).Type==type
                    N=N+1;
                end
            end
        end


        function id=getNextVoxelLabel(this)


            if isfield(this.DefinitionStruct,'VoxelLabelID')
                possibleIDs=1:255;
                currentIDs=[this.DefinitionStruct.VoxelLabelID];
                possibleIDs(currentIDs)=[];
                id=min(possibleIDs);
            end
        end


        function tf=validateLabelName(this,labelName,hFig)

            tf=true;



            [validLabelName,uniqueLabelName]=this.isUniqueLabelName(labelName);
            if~validLabelName
                invalidNameDialog(this,hFig);
                tf=false;
            elseif~uniqueLabelName
                duplicateNameDialog(this,hFig);
                tf=false;
            end
        end


        function tf=validateLabelColor(this,labelColor,hFig)

            tf=true;

            validLabelColor=~isequal(labelColor,[1,1,0]);
            if~validLabelColor
                invalidColorDialog(this,hFig);
                tf=false;
            end
        end


        function color=queryLabelColor(this,labelID)


            if~isnumeric(labelID)
                labelID=this.labelNameToID(labelID);
            end
            color=this.DefinitionStruct(labelID).Color;
        end


        function updateLabelGroup(this,labelID,group)


            if~isnumeric(labelID)
                labelID=this.labelNameToID(labelID);
            end
            this.DefinitionStruct(labelID).Group=group;
        end


        function updateLabelDescription(this,labelID,descr)


            if~isnumeric(labelID)
                labelID=this.labelNameToID(labelID);
            end
            this.DefinitionStruct(labelID).Description=descr;
        end


        function updateGroups(this,oldGroup,newGroup)

            oldGroupIds=find(strcmp({this.DefinitionStruct.Group},oldGroup));
            for id=oldGroupIds
                this.DefinitionStruct(id).Group=newGroup;
            end
        end


        function reorderLabelDefinitions(this,labelNames)

            [~,idx]=ismember(labelNames,{this.DefinitionStruct.Name});
            this.DefinitionStruct=this.DefinitionStruct(idx);
        end
    end

    methods(Access=protected)

        function initializeColorLookup(this,displaySource)
            this.colorLookup=lidar.internal.labeler.getColorMap(displaySource);


            this.maxColors=size(this.colorLookup,2);
        end


        function growColorLookup(this)




            growLength=8;
            newColors=unique(rand(growLength,3),'rows');



            [~,~,idxNew]=intersect(squeeze(this.colorLookup),newColors,'rows');
            newColors(idxNew,:)=[];

            actualGrowLength=size(newColors,1);
            this.colorLookup=[this.colorLookup,reshape(newColors,[1,actualGrowLength,3])];
            this.maxColors=this.maxColors+actualGrowLength;
        end


        function evtData=createEventDataPacket(this,labelID)
            label=this.labelIDToName(labelID);
            evtData=vision.internal.labeler.LabelSetUpdateEvent(label);
        end


        function invalidNameDialog(~,hFig)
            msg=vision.getMessage('vision:uitools:invalidCategoryVariable');
            title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
            vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,title);
        end


        function invalidColorDialog(~,hFig)
            msg=vision.getMessage('vision:uitools:YellowColorSelectionWarning');
            title=getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle'));
            vision.internal.labeler.handleAlert(hFig,'error',msg,title);
        end


        function duplicateNameDialog(~,hFig)
            msg=vision.getMessage('vision:uitools:DuplicateLabelName');
            title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
            vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,title);
        end
    end
end
