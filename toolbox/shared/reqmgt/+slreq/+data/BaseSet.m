classdef BaseSet<slreq.data.AttributeOwner&slreq.data.ReqLinkBase&slreq.analysis.BaseRollupAnalysis




    methods(Access=public)
        function addCustomAttribute(this,name,typeEnum,description,defaultValOrEnum)
            mfTypeEnum=typeEnum.toInternalEnum;
            reqData=slreq.data.ReqData.getInstance();
            reqData.addCustomAttributeRegistry(this,name,mfTypeEnum,description,defaultValOrEnum,false);
        end

        function deleteCustomAttribute(this,name,force)
            reqData=slreq.data.ReqData.getInstance();
            attrMap=reqData.getCustomAttributeRegistries(this);
            thisAttr=attrMap.getByKey(name);
            if isempty(thisAttr)
                error(message('Slvnv:slreq:AttrRegistryDoesntExist',name,this.name))
            end
            if~force
                if thisAttr.items.Size>0
                    error(message('Slvnv:slreq:AttrRegistryDeleteUsed',name));
                end
            end
            reqData.removeCustomAttributeRegistry(thisAttr);
        end

        function udpateCustomAttribute(this,name,inputs,usingDefaults)


            reqData=slreq.data.ReqData.getInstance();
            attrMap=reqData.getCustomAttributeRegistries(this);
            thisAttr=attrMap.getByKey(name);
            if isempty(thisAttr)
                error(message('Slvnv:slreq:AttrRegistryDoesntExist',name,this.name))
            end

            if any(contains(usingDefaults,'Description'))


                desc=thisAttr.description;
            else
                desc=inputs.Description;
            end

            defaultValOrEnumList='';
            if~any(contains(usingDefaults,'List'))
                defaultValOrEnumList=inputs.List;
            elseif~any(contains(usingDefaults,'DefaultValue'))
                defaultValOrEnumList=inputs.DefaultValue;
            end

            newName=name;
            if isfield(inputs,'Name')
                newName=inputs.Name;
            end
            reqData.modifyCustomAttributeRegistry(this,...
            name,newName,thisAttr.typeName,desc,defaultValOrEnumList)
        end

        function out=getCustomAttribute(this,name)
            reqData=slreq.data.ReqData.getInstance();
            attrMap=reqData.getCustomAttributeRegistries(this);
            thisAttr=attrMap.getByKey(name);
            if isempty(thisAttr)
                error(message('Slvnv:slreq:AttrRegistryDoesntExist',name,this.name))
            end

            out=struct('name',name,'type',thisAttr.typeName,...
            'description',thisAttr.description);
            switch thisAttr.typeName
            case 'Checkbox'
                out.default=thisAttr.default;
            case 'Combobox'
                out.list=thisAttr.entries.toArray;
            end
        end
    end
end

