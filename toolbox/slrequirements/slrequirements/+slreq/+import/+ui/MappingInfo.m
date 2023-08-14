classdef MappingInfo<handle





    properties

        options;

        mapRequirement;


        reqData;
    end

    methods
        function this=MappingInfo()
            this.reqData=slreq.data.ReqData.getInstance();
        end

        function initMapping(this)
            this.options=this.reqData.createMapping();


            mappedType=this.options.types.toArray();
            this.mapRequirement=mappedType(1);
        end



        function mapToBuiltIn(this,externalName,externalType,slreqName,slreqType)
            try
                externalItem=this.reqData.createMapToBuiltIn(externalName,externalType,slreqName,slreqType);
                this.mapRequirement.attributes.add(externalItem);
            catch ex



                debug=0;
            end
        end

        function mapToCustomAttribute(this,externalName,externalType,slreqName,slreqType,isAutoMapped)
            try
                externalItem=this.reqData.createMapToCustomAttribute(externalName,externalType,slreqName,slreqType,isAutoMapped);
                this.mapRequirement.attributes.add(externalItem);
            catch ex



                debug=0;
            end
        end



        function type=getBuiltInTypeEnum(this,att)
            switch(lower(att))
            case 'summary'
                type=slreq.datamodel.AttributeTypeEnum.String;
            case 'description'
                type=slreq.datamodel.AttributeTypeEnum.Xhtml;
            case 'customid'
                type=slreq.datamodel.AttributeTypeEnum.String;
            otherwise

                type=slreq.datamodel.AttributeTypeEnum.Any;
            end
        end
    end

end

