




classdef(Abstract)SublabelSet<handle

    properties(GetAccess=public,SetAccess=protected)




DefinitionStruct
NumSublabels
PixelSublabelID
    end

    events
SublabelAdded
SublabelRemoved
SublabelChanged
    end

    methods

        function renameSublabel(this,labelName,sublabelName,newSublabelName)







            sublabelID=this.sublabelNameToID(labelName,sublabelName);




            if~strcmpi(sublabelName,newSublabelName)
                [validSublabelName,uniqueSublabelName]=this.isUniqueSublabelName(labelName,newSublabelName);
                if~validSublabelName
                    invalidNameDialog(this,hFig);
                    return;
                elseif~uniqueSublabelName
                    duplicateNameDialog(this,hFig);
                    return;
                end
            end


            oldName=this.sublabelIDToName(sublabelID);
            this.DefinitionStruct(sublabelID).Name=newSublabelName;




            evtData=this.createEventDataPacket(sublabelID);
            evtData.OldSublabelName=oldName;
            notify(this,'SublabelChanged',evtData);
        end


        function changeColorSublabel(this,labelName,subLabelName,newSublabelColor)

            sublabelID=this.sublabelNameToID(labelName,subLabelName);

            this.DefinitionStruct(sublabelID).Color=newSublabelColor;

            evtData=this.createEventDataPacket(sublabelID);
            notify(this,'SublabelChanged',evtData);
        end


        function changeSubLabelROIVisibility(this,labelData)
            labelName=labelData.LabelName;
            subLabelName=labelData.Sublabel;
            sublabelID=this.sublabelNameToID(labelName,subLabelName);

            this.DefinitionStruct(sublabelID).ROIVisibility=labelData.ROIVisibility;

        end

        function renameLabelForSublabel(this,oldLabelName,newLabelName,sublabelName)




            sublabelID=this.sublabelNameToID(oldLabelName,sublabelName);
            this.DefinitionStruct(sublabelID).LabelName=newLabelName;
        end


        function removeSublabel(this,labelName,sublabelName)




            sublabelID=this.sublabelNameToID(labelName,sublabelName);

            if~isfield(this.DefinitionStruct,'Type')||(this.DefinitionStruct(sublabelID).Type~=labelType.PixelLabel)

                evtData=this.createEventDataPacket(sublabelID);
                notify(this,'SublabelRemoved',evtData);
            end


            this.DefinitionStruct(sublabelID)=[];




            linearIDs=num2cell(1:numel(this.DefinitionStruct));
            [this.DefinitionStruct.SublabelID]=deal(linearIDs{:});


            this.NumSublabels=this.NumSublabels-1;
        end



        function gotMatch=hasMatchingName(~,array,name)
            gotMatch=false;
            for i=1:length(array)
                if strcmpi(array(i).Name,name)
                    gotMatch=true;
                    return;
                end
            end
        end


        function[isValid,isUnique]=isUniqueSublabelName(this,labelName,sublabelName)




            isValid=isvarname(sublabelName)||(iscellstr(sublabelName)&&isscalar(sublabelName)&&isvarname(sublabelName{1}));%#ok<ISCLSTR>
            if isValid
                if isempty(this.DefinitionStruct)
                    isUnique=true;
                else
                    currROILabelNames={this.DefinitionStruct.LabelName};

                    idxList=strcmp(currROILabelNames,labelName);
                    thisSublabelStructs=this.DefinitionStruct(idxList);
                    isUnique=~hasMatchingName(this,thisSublabelStructs,sublabelName);
                end
            else
                isUnique=false;
            end
        end


        function sublabelDefStruct=exportDef2struct(this,labelName)





            if isempty(this.DefinitionStruct)
                sublabelDefStruct=[];
            else
                currROILabelNames={this.DefinitionStruct.LabelName};
                lblIdxList=strcmpi(labelName,currROILabelNames);
                sublabelDefStruct=this.DefinitionStruct(lblIdxList);

                if isempty(sublabelDefStruct)
                    sublabelDefStruct=[];
                else


                    if isfield(sublabelDefStruct,'LabelName')
                        sublabelDefStruct=rmfield(sublabelDefStruct,'LabelName');
                    end
                    if isfield(sublabelDefStruct,'SublabelID')
                        sublabelDefStruct=rmfield(sublabelDefStruct,'SublabelID');
                    end
                    if isfield(sublabelDefStruct,'PixelSublabelID')
                        sublabelDefStruct=rmfield(sublabelDefStruct,'PixelSublabelID');
                    end
                end
            end
        end


        function name=sublabelIDToName(this,id)





            if ischar(id)
                name=id;
            else
                name=this.DefinitionStruct(id).Name;
            end
        end


        function color=sublabelIDToColor(this,id)


            color=this.DefinitionStruct(id).Color;
        end


        function name=sublabelIDToLabelName(this,id)





            name='';
            if~ischar(id)
                name=this.DefinitionStruct(id).LabelName;
            end
        end


        function[sublabelIDs,sublabelNames]=queryChildSublabelIDNames(this,labelName)
            sublabelIDs=strcmpi(labelName,{this.DefinitionStruct.LabelName});
            if isempty(sublabelIDs)
                sublabelNames='';
            else
                sublabelNames={this.DefinitionStruct(sublabelIDs).Name};
            end
            if~iscellstr(sublabelNames)%#ok<ISCLSTR>
                sublabelNames=cellstr(sublabelNames);
            end
        end


        function sublabelNames=querySublabelNames(this,labelName)

            sublabelNames={};
            if(ischar(labelName)||isstring(labelName))

                currROILabelNames={this.DefinitionStruct.LabelName};
                lblIdxList=strcmpi(labelName,currROILabelNames);
                sublabelNames={this.DefinitionStruct(lblIdxList).Name};
            end
            if~iscellstr(sublabelNames)
                sublabelNames=cellstr(sublabelNames);
            end
        end


        function ID=sublabelNameToID(this,labelName,sublabelName)




            if(ischar(sublabelName)||isstring(sublabelName))&&...
                (ischar(labelName)||isstring(labelName))

                currROILabelNames={this.DefinitionStruct.LabelName};
                lblIdxList=strcmpi(labelName,currROILabelNames);

                currROISublabelNames={this.DefinitionStruct.Name};

                sublblIdxList=strcmpi(sublabelName,currROISublabelNames);

                idxList=lblIdxList&sublblIdxList;

                ID=find(idxList,1);



                if isempty(ID)
                    assert(~isempty(ID),'Invalid Sublabel Name');
                end
            else
                error('Unhandled case');
            end
        end


        function N=getNumROIByType(this,type)

            labelTypes=[this.DefinitionStruct.Type];
            N=sum(labelTypes==type);
        end


        function id=getNextPixelSublabel(this)


            if isfield(this.DefinitionStruct,'PixelSublabelID')
                possibleIDs=1:255;
                currentIDs=[this.DefinitionStruct.PixelSublabelID];
                possibleIDs(currentIDs)=[];
                id=min(possibleIDs);
            end
        end
    end

    methods(Access=protected)

        function evtData=createEventDataPacket(this,sublabelID)
            sublabelName=this.sublabelIDToName(sublabelID);
            labelName=this.sublabelIDToLabelName(sublabelID);
            evtData=vision.internal.labeler.SublabelSetUpdateEvent(labelName,sublabelName);
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