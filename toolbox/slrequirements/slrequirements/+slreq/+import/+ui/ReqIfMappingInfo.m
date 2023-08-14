classdef ReqIfMappingInfo<slreq.import.ui.MappingInfo




    properties
        reqIfData;
        attributeMap;
    end

    methods
        function this=ReqIfMappingInfo(reqIfData,attributeMap)
            this@slreq.import.ui.MappingInfo();

            this.reqIfData=reqIfData;
            this.attributeMap=attributeMap;
        end

        function out=doit(this)
            out=[];

            this.initMapping();

            allKeys=this.attributeMap.keys;
            for n=1:length(allKeys)
                key=allKeys{n};

                [attrib,objType]=this.findAttributeDefinition(key);
                if~isempty(attrib)&&~isempty(objType)
                    slreqName=this.attributeMap(key);

                    externalName=this.getExternalName(attrib,objType);
                    externalTypeEnum=this.getExternalTypeEnum(attrib);

                    if slreq.custom.AttributeHandler.isReservedName(slreqName)
                        internalTypeEnum=this.getBuiltInTypeEnum(slreqName);
                        this.mapToBuiltIn(externalName,externalTypeEnum,slreqName,internalTypeEnum);
                    else



                        internalTypeEnum=this.getInternalTypeEnum(externalTypeEnum);

                        this.mapToCustomAttribute(externalName,externalTypeEnum,slreqName,internalTypeEnum,false);
                    end
                end
            end

        end

        function[outAttrib,outType]=findAttributeDefinition(this,id)
            outAttrib=[];
            outType=[];

            specTypes=this.reqIfData.specTypes.values;
            for n=1:length(specTypes)
                specType=specTypes{n};

                if~strcmp(specType.Type,'SPEC-OBJECT-TYPE')
                    continue;
                end
                specAttribs=specType.Attributes;
                if~isempty(specAttribs)&&specAttribs.isKey(id)
                    outType=specType;
                    outAttrib=specAttribs(id);
                    break;
                end
            end
        end


        function out=getExternalName(this,att,objType)

            attribName=att.Name;

            if isempty(attribName)
                attribName=att.ID;
            end
            out=[objType.Name,'::',attribName];
        end


        function type=getExternalTypeEnum(this,att)

            switch(lower(att.BaseType))
            case 'attribute-definition-xhtml'
                type=slreq.datamodel.AttributeTypeEnum.Xhtml;
            case 'attribute-definition-enumeration'
                type=slreq.datamodel.AttributeTypeEnum.Enumeration;
            case 'attribute-definition-boolean'
                type=slreq.datamodel.AttributeTypeEnum.Boolean;
            case 'attribute-definition-date'
                type=slreq.datamodel.AttributeTypeEnum.Date;
            case 'attribute-definition-integer'
                type=slreq.datamodel.AttributeTypeEnum.Integer;
            case 'attribute-definition-real'
                type=slreq.datamodel.AttributeTypeEnum.Real;
            case 'attribute-definition-string'
                type=slreq.datamodel.AttributeTypeEnum.String;
            otherwise
                type=slreq.datamodel.AttributeTypeEnum.Any;
            end
        end




        function type=getInternalTypeEnum(this,att)
            switch(att)
            case slreq.datamodel.AttributeTypeEnum.Xhtml
                type=slreq.datamodel.AttributeTypeEnum.Xhtml;
            case slreq.datamodel.AttributeTypeEnum.Enumeration
                type=slreq.datamodel.AttributeTypeEnum.Enumeration;
            case slreq.datamodel.AttributeTypeEnum.Boolean
                type=slreq.datamodel.AttributeTypeEnum.String;
            case slreq.datamodel.AttributeTypeEnum.Date
                type=slreq.datamodel.AttributeTypeEnum.String;
            case slreq.datamodel.AttributeTypeEnum.Integer
                type=slreq.datamodel.AttributeTypeEnum.String;
            case slreq.datamodel.AttributeTypeEnum.Real
                type=slreq.datamodel.AttributeTypeEnum.String;
            case slreq.datamodel.AttributeTypeEnum.String
                type=slreq.datamodel.AttributeTypeEnum.String;
            otherwise
                type=slreq.datamodel.AttributeTypeEnum.Any;
            end
        end

    end
end

