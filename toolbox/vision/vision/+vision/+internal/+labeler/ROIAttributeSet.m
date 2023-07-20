



classdef ROIAttributeSet<vision.internal.labeler.AttributeSet











    methods

        function this=ROIAttributeSet(varargin)




            this.NumAttributes=0;

            this.DefinitionStruct=struct(...
            'LabelName','',...
            'SublabelName','',...
            'Name',{},...
            'AttributeID',[],...
            'Type',attributeType.empty,...
            'Value',[],...
            'Description','');
        end


        function tf=validateAttributeName(this,labelName,sublabelName,attributeName,hFig)

            tf=true;



            [validAttributeName,uniqueAttributeName]=this.isUniqueAttributeName(labelName,sublabelName,attributeName);
            if~validAttributeName
                invalidNameDialog(this,hFig);
                tf=false;
            elseif~uniqueAttributeName
                duplicateNameDialog(this,hFig);
                tf=false;
            end
        end


        function roiAttribute=addAttribute(this,roiAttribute,hFig)


            labelName=roiAttribute.LabelName;
            sublabelName=roiAttribute.SublabelName;
            attributeName=roiAttribute.Name;
            type=roiAttribute.Type;
            value=roiAttribute.Value;

            description=roiAttribute.Description;



            [validAttributeName,uniqueAttributeName]=this.isUniqueAttributeName(labelName,sublabelName,attributeName);
            if~validAttributeName
                invalidNameDialog(this,hFig);
                return;
            elseif~uniqueAttributeName
                duplicateNameDialog(this,hFig);
                return;
            end



            goodAttributeType=isa(type,'attributeType');

            assert(goodAttributeType,'Invalid Attribute type was specified')

            this.NumAttributes=this.NumAttributes+1;



            if iscell(value)
                value={value};
            end

            definitionStruct=struct('LabelName',labelName,...
            'SublabelName',sublabelName,...
            'Name',attributeName,...
            'AttributeID',this.NumAttributes,...
            'Type',type,...
            'Value',value,...
            'Description',description);
            this.DefinitionStruct=[this.DefinitionStruct;definitionStruct];

            attributeID=this.NumAttributes;
            evtData=this.createEventDataPacket(attributeID);
            notify(this,'AttributeAdded',evtData);
        end


        function roiAttribute=queryAttribute(this,labelName,sublabelName,attributeName)








            attributeID=this.attributeNameToID(labelName,sublabelName,attributeName);
            attributeDataStruct=this.DefinitionStruct(attributeID);

            this.DefinitionStruct(attributeID).Description=vision.internal.labeler.retrieveNewLine(this.DefinitionStruct(attributeID).Description);

            labelName=attributeDataStruct.LabelName;
            sublabelName=attributeDataStruct.SublabelName;

            type=attributeDataStruct.Type;
            name=attributeDataStruct.Name;
            descr=attributeDataStruct.Description;
            value=attributeDataStruct.Value;

            roiAttribute=vision.internal.labeler.ROIAttribute(labelName,sublabelName,...
            name,type,value,descr);
        end


        function roiAttributeFamily=queryAttributeFamily(this,labelName,sublabelName)








            attributeIDs=this.attributeParentNameToIDs(labelName,sublabelName);
            attributeDataStructs=this.DefinitionStruct(attributeIDs);

            len=length(attributeDataStructs);
            roiAttributeFamily=cell(1,len);

            for i=1:len
                labelName=attributeDataStructs(i).LabelName;
                sublabelName=attributeDataStructs(i).SublabelName;

                this.DefinitionStruct(attributeIDs(i)).Description=vision.internal.labeler.retrieveNewLine(this.DefinitionStruct(attributeIDs(i)).Description);

                type=attributeDataStructs(i).Type;
                name=attributeDataStructs(i).Name;
                descr=attributeDataStructs(i).Description;
                value=attributeDataStructs(i).Value;

                roiAttribute=vision.internal.labeler.ROIAttribute(labelName,sublabelName,...
                name,type,value,descr);
                roiAttributeFamily{i}=roiAttribute;
            end
        end


        function type=queryAttributeShape(this,attributeID)


            type=this.DefinitionStruct(attributeID).Type;
        end


        function oldDescr=updateAttributeDescription(this,attributeID,descr)


            oldDescr=this.DefinitionStruct(attributeID).Description;
            this.DefinitionStruct(attributeID).Description=descr;
        end

    end
end