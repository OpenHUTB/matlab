classdef DoorsMappingInfo<slreq.import.ui.MappingInfo




    properties
attributeMap
    end

    methods
        function this=DoorsMappingInfo(attributeMap)
            this@slreq.import.ui.MappingInfo();
            this.attributeMap=attributeMap;
        end

        function out=doit(this)
            out=[];

            this.initMapping();



            this.options.description='NOT-FOR-EXPORT';


            intType=slreq.datamodel.AttributeTypeEnum.Integer;

            stringType=slreq.datamodel.AttributeTypeEnum.String;

            xhtmlType=slreq.datamodel.AttributeTypeEnum.Xhtml;

            dateType=slreq.datamodel.AttributeTypeEnum.Date;


            this.mapToBuiltIn('Absolute Number',intType,'customId',stringType);
            this.mapToBuiltIn('Heading',stringType,'summary',stringType);
            this.mapToBuiltIn('Object Text',xhtmlType,'description',xhtmlType);
            this.mapToBuiltIn('Created By',stringType,'createdBy',stringType);
            this.mapToBuiltIn('Modified By',stringType,'modifiedBy',stringType);
            this.mapToBuiltIn('Created On',dateType,'createdOn',dateType);
            this.mapToBuiltIn('Modified On',dateType,'modifiedOn',dateType);


            if~isempty(this.attributeMap)


                isAutoMapped=false;
                keys=this.attributeMap.keys();
                for idx=1:length(keys)
                    externalName=keys{idx};
                    slreqName=this.attributeMap(externalName);
                    if strcmp(slreqName,getString(message('Slvnv:slreq:Keywords')))


                        this.mapToBuiltIn(externalName,stringType,'keywords',stringType);
                    else
                        this.mapToCustomAttribute(externalName,stringType,slreqName,stringType,isAutoMapped);
                    end
                end
            end
        end

    end
end

