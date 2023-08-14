




classdef(Abstract)AttributeSet<handle

    properties(GetAccess=public,SetAccess=protected)




DefinitionStruct
NumAttributes
    end

    events
AttributeAdded
AttributeRemoved
AttributeChanged
    end

    methods

        function removeAttribute(this,labelName,sublabelName,attributeName)




            attributeID=this.attributeNameToID(labelName,sublabelName,attributeName);


            evtData=this.createEventDataPacket(attributeID);
            notify(this,'AttributeRemoved',evtData);


            this.DefinitionStruct(attributeID)=[];


            linearIDs=num2cell(1:numel(this.DefinitionStruct));
            [this.DefinitionStruct.AttributeID]=deal(linearIDs{:});


            this.NumAttributes=this.NumAttributes-1;
        end


        function modifyNameOfAttribute(this,labelName,sublabelName,oldAttribName,newAttribName)


            attributeID=this.attributeNameToID(labelName,sublabelName,oldAttribName);


            this.DefinitionStruct(attributeID).Name=newAttribName;


            evtData=this.createEventDataPacket(attributeID);
            evtData.OldAttributeName=oldAttribName;
            notify(this,'AttributeChanged',evtData);
        end


        function modifyLabelNameInAttribute(this,oldLabelName,newLabelName)

            sublabelName='';
            [attribIDs,~]=queryChildAttributeIDNames(this,oldLabelName,sublabelName);

            for i=1:numel(attribIDs)
                this.DefinitionStruct(attribIDs(i)).LabelName=newLabelName;
            end
        end


        function modifySublabelNameInAttribute(this,labelName,oldSublabelName,newSublabelName)

            [attribIDs,~]=queryChildAttributeIDNames(this,labelName,oldSublabelName);

            for i=1:numel(attribIDs)
                this.DefinitionStruct(attribIDs(i)).SublabelName=newSublabelName;
            end
        end


        function modifyAttributeDescription(this,labelName,sublabelName,attributeName,newDesc)

            attributeID=this.attributeNameToID(labelName,sublabelName,attributeName);
            this.DefinitionStruct(attributeID).Description=newDesc;
        end


        function modifyValueOfAttributeList(this,labelName,sublabelName,attributeName,val)


            attributeID=this.attributeNameToID(labelName,sublabelName,attributeName);
            this.DefinitionStruct(attributeID).Value=val;
        end


        function[attribIDs,attribNames]=queryChildAttributeIDNames(this,labelName,sublabelName)

            currROILabelNames={this.DefinitionStruct.LabelName};
            lblIdxList=strcmpi(labelName,currROILabelNames);
            if isempty(sublabelName)
                if isempty(lblIdxList)
                    attribNames='';
                else
                    attribNames={this.DefinitionStruct(lblIdxList).Name};
                end
                attribIDs=find(lblIdxList);
            else
                currROISublabelNames={this.DefinitionStruct.SublabelName};
                sublblIdxList=strcmpi(sublabelName,currROISublabelNames);
                idxList=lblIdxList&sublblIdxList;

                IDs=find(idxList);
                if isempty(IDs)
                    attribNames='';
                else
                    attribNames={this.DefinitionStruct(idxList).Name};
                end
                attribIDs=IDs;
            end
            if~iscellstr(attribNames)%#ok<ISCLSTR>
                attribNames=cellstr(attribNames);
            end
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

        function[isValid,isUnique]=isUniqueAttributeName(this,labelName,sublabelName,attributeName)





            isValid=isvarname(attributeName)||...
            (iscellstr(attributeName)&&isscalar(attributeName)&&isvarname(attributeName{1}));%#ok<ISCLSTR>
            if isValid
                if isempty(this.DefinitionStruct)
                    isUnique=true;
                else

                    currROILabelNames={this.DefinitionStruct.LabelName};
                    lblIdxList=strcmp(labelName,currROILabelNames);

                    currROISublabelNames={this.DefinitionStruct.SublabelName};
                    sublblIdxList=strcmp(sublabelName,currROISublabelNames);
                    idxList=lblIdxList&sublblIdxList;
                    thisAttributeStructs=this.DefinitionStruct(idxList);

                    isUnique=~hasMatchingName(this,thisAttributeStructs,attributeName);

                end
            else
                isUnique=false;
            end

        end


        function attribDefStruct=exportDef2struct(this,labelName,sublabelName)






            if isempty(this.DefinitionStruct)
                attribDefStruct=[];
            else
                currROILabelNames={this.DefinitionStruct.LabelName};
                lblIdxList=strcmpi(labelName,currROILabelNames);




                currROISublabelNames={this.DefinitionStruct.SublabelName};
                sublblIdxList=strcmpi(sublabelName,currROISublabelNames);

                idxList=lblIdxList&sublblIdxList;

                attribDefStruct=this.DefinitionStruct(idxList);
                if isempty(attribDefStruct)
                    attribDefStruct=[];
                else


                    if isfield(attribDefStruct,'LabelName')
                        attribDefStruct=rmfield(attribDefStruct,'LabelName');
                    end
                    if isfield(attribDefStruct,'SublabelName')
                        attribDefStruct=rmfield(attribDefStruct,'SublabelName');
                    end
                    if isfield(attribDefStruct,'AttributeID')
                        attribDefStruct=rmfield(attribDefStruct,'AttributeID');
                    end
                end
            end
        end


        function name=attributeIDToName(this,attributeID)





            if ischar(attributeID)
                name=attributeID;
            else
                name=this.DefinitionStruct(attributeID).Name;
            end
        end

        function[labelName,sublabelName]=attributeIDToLabelSublabelName(this,attributeID)
            labelStruct=this.DefinitionStruct(attributeID);
            labelName=labelStruct.LabelName;
            sublabelName=labelStruct.SublabelName;
        end

        function TF=hasAttributeDefined(this,labelName)
            roiLabelNames={this.DefinitionStruct.LabelName};
            validLabelIDs=strcmpi(labelName,roiLabelNames);
            TF=~isempty(validLabelIDs);
        end


        function ID=attributeNameToID(this,labelName,sublabelName,attributeName)


            if(ischar(attributeName)||isstring(attributeName))&&...
                (ischar(sublabelName)||isstring(sublabelName))&&...
                (ischar(labelName)||isstring(labelName))

                roiLabelNames={this.DefinitionStruct.LabelName};
                validLabelIDs=strcmpi(labelName,roiLabelNames);
                if~isempty(sublabelName)
                    roiSublabelNames={this.DefinitionStruct.SublabelName};
                    validSublabelIDs=strcmpi(sublabelName,roiSublabelNames);
                    validIDs=validLabelIDs&validSublabelIDs;
                else
                    validIDs=validLabelIDs;
                end

                roiAttribNames={this.DefinitionStruct.Name};
                validAttribIDs=strcmpi(attributeName,roiAttribNames);

                validIDs=validAttribIDs&validIDs;
                ID=find(validIDs,1);
            else

                ID=attributeName;
            end
        end


        function IDs=attributeParentNameToIDs(this,labelName,sublabelName)


            if(ischar(sublabelName)||isstring(sublabelName))&&...
                (ischar(labelName)||isstring(labelName))

                roiLabelNames={this.DefinitionStruct.LabelName};
                validLabelIDs=strcmpi(labelName,roiLabelNames);
                if~isempty(sublabelName)
                    roiSublabelNames={this.DefinitionStruct.SublabelName};
                    validSublabelIDs=strcmpi(sublabelName,roiSublabelNames);
                    validIDs=validLabelIDs&validSublabelIDs;
                else

                    roiSublabelNames={this.DefinitionStruct.SublabelName};
                    validSublabelIDs=strcmpi('',roiSublabelNames);

                    validIDs=validLabelIDs&validSublabelIDs;
                end

                IDs=find(validIDs);
            else

                IDs=-1;
            end
        end


        function N=getNumROIByType(this,type)

            labelTypes=[this.DefinitionStruct.Type];
            N=sum(labelTypes==type);
        end


        function id=getNextPixelAttribute(this)


            if isfield(this.DefinitionStruct,'PixelAttributeID')
                possibleIDs=1:255;
                currentIDs=[this.DefinitionStruct.PixelAttributeID];
                possibleIDs(currentIDs)=[];
                id=min(possibleIDs);
            end
        end
    end

    methods(Access=protected)

        function evtData=createEventDataPacket(this,attributeID)
            attributeName=this.attributeIDToName(attributeID);
            [labelName,sublabelName]=this.attributeIDToLabelSublabelName(attributeID);
            evtData=vision.internal.labeler.AttributeSetUpdateEvent(labelName,sublabelName,attributeName);
        end


        function invalidNameDialog(~,hFig)
            msg=vision.getMessage('vision:uitools:invalidCategoryVariable');
            title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
            vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,title);
        end


        function duplicateNameDialog(~,hFig)
            msg=vision.getMessage('vision:uitools:DuplicateAttributeName');
            title=vision.getMessage('vision:labeler:LabelNameInvalidDlgName');
            vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,title);
        end
    end
end
