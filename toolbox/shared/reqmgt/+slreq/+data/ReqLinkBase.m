classdef ReqLinkBase<slreq.data.DataModelObj





    properties(Dependent,GetAccess=public,SetAccess=private)
createdOn
createdBy
modifiedOn
modifiedBy
revision
    end

    properties(Access=public)





        filterState;
    end

    methods
        function tf=isUnMarked(this)
            tf=isempty(this.filterState);
        end

        function tf=isFilteredIn(this)
            tf=(isempty(this.filterState)||strcmp(this.filterState,'in'));
        end

        function tf=isFilteredParent(this)
            tf=strcmp(this.filterState,'parent');
        end

        function value=get.createdOn(this)
            value=slreq.utils.getDateTime(this.modelObject.createdOn,'Read');
        end

        function value=get.createdBy(this)
            value=this.modelObject.createdBy;
        end

        function value=get.modifiedOn(this)
            value=slreq.utils.getDateTime(this.modelObject.modifiedOn,'Read');
        end

        function value=get.modifiedBy(this)
            value=this.modelObject.modifiedBy;
        end

        function value=get.revision(this)
            value=this.modelObject.revision;




            if value==0
                value=value+1;
            end
        end

        function idx=indexOf(this,dataObj)

            if isa(this.modelObject,'slreq.datamodel.RequirementSet')
                idx=this.modelObject.rootItems.indexOf(dataObj.modelObject);
            elseif isa(this.modelObject,'slreq.datamodel.RequirementItem')
                idx=this.modelObject.children.indexOf(dataObj.modelObject);
            else
                error('Slvnv:slreq:InvalidObjectForIndexOf','Internal Error: indexOf is not supported for type: %s',class(this))
            end
        end

        function setStereotypeAttr(this,propName,propValue)
            reqData=slreq.data.ReqData.getInstance();
            reqData.setStereotypeAttribute(this,propName,propValue);
            this.notifyObservers();
        end

        function setAttributeByChar(this,thisPropName,propValue)



            if~ischar(propValue)
                error(message('Slvnv:slreq:NeedValidString'));
            end
            attrReg=this.getAttributeRegistry(thisPropName);
            switch class(attrReg)
            case 'slreq.datamodel.DateTimeAttrReg'


                propValue=slreq.utils.getDateTime(datetime(propValue),'Write');
            case 'slreq.datamodel.StrAttrReg'

            case 'slreq.datamodel.BoolAttrReg'


                propValue=logical(str2double(propValue));
            case 'slreq.datamodel.IntAttrReg'
                propValue=str2double(propValue);
            case 'slreq.datamodel.EnumAttrReg'


            end

            reqData=slreq.data.ReqData.getInstance;
            mfObj=this.modelObject;
            if isa(mfObj,'slreq.datamodel.RequirementItem')
                mfSet=mfObj.requirementSet;
            else
                mfSet=mfObj.linkSet;
            end
            reqData.setCustomAttribute(mfObj,mfSet,thisPropName,propValue);
            this.setDirty(true);
        end

        function setAttributeWithTypeCheck(this,thisPropName,propValue)




            propValue=this.validateAttributeForType(thisPropName,propValue);

            reqData=slreq.data.ReqData.getInstance;
            mfObj=this.modelObject;
            if isa(mfObj,'slreq.datamodel.RequirementItem')
                mfSet=mfObj.requirementSet;
            else
                mfSet=mfObj.linkSet;
            end
            reqData.setCustomAttribute(mfObj,mfSet,thisPropName,propValue);
            this.setDirty(true);
        end

        function propValue=validateAttributeForType(this,thisPropName,propValue)


            attrReg=this.getAttributeRegistry(thisPropName);
            switch class(attrReg)
            case 'slreq.datamodel.StrAttrReg'
                if~(ischar(propValue)||(isstring(propValue)&&isscalar(propValue)))
                    error(message('Slvnv:slreq:InvalidTypeEdit',thisPropName));
                end
            case 'slreq.datamodel.BoolAttrReg'
                if~islogical(propValue)
                    error(message('Slvnv:slreq:InvalidTypeCheckbox',thisPropName));
                end
            case 'slreq.datamodel.IntAttrReg'
                if~isnumeric(propValue)
                    error(message('Slvnv:slreq:InvalidTypeCheckbox',thisPropName));
                end
            case 'slreq.datamodel.EnumAttrReg'
                if~(ischar(propValue)||(isstring(propValue)&&isscalar(propValue)))

                    error(message('Slvnv:slreq:InvalidTypeCombobox',thisPropName));
                end
                enumList=attrReg.entries.toArray;
                index=find(strcmp(propValue,enumList),1);
                if isempty(index)
                    error(message('Slvnv:slreq:InvalidNameCombobox',thisPropName,propValue));
                end
            case 'slreq.datamodel.DateTimeAttrReg'

                propValue=datetime(propValue,'Locale','system');
            end

        end

        function propValue=getStereotypeAttr(this,propName,isAPImode)
            propValue='';
            rdata=slreq.data.ReqData.getInstance;
            attrs=rdata.getStereotypeAttributes(this);
            attr=attrs.getByKey(propName);
            if~isempty(attr)
                if isa(attr,'slreq.datamodel.EnumCustAttrItem')
                    type=slreq.internal.ProfileReqType.getStereotypeAttrType(propName);
                    enumValues=enumeration(type);
                    for i=1:numel(enumValues)
                        vTemp=int32(enumValues(i));
                        if vTemp==attr.index
                            propValue=enumValues(i);
                            break;
                        end
                    end
                else
                    propValue=attr.value;
                end
            else



                [prfName,stType,~]=slreq.internal.ProfileTypeBase.getProfileStereotype(propName);
                typeToShow=[prfName,'.',stType];
                if(isa(this,'slreq.data.Requirement')&&~strcmp(typeToShow,this.typeName))||...
                    (isa(this,'slreq.data.Link')&&~strcmp(typeToShow,this.type))
                    propValue='';
                else


                    propValue=slreq.internal.ProfileReqType.getStereotypeDefaultValue(propName);
                end
            end
        end

        function propValue=getAttribute(this,propName,isAPImode)
            propValue='';
            rdata=slreq.data.ReqData.getInstance;
            attrItems=rdata.getCustomAttributeItems(this);

            attrItem=attrItems.getByKey(propName);
            if~isempty(attrItem)
                attrReg=attrItem.registry;
                switch attrReg.typeName
                case slreq.datamodel.AttributeRegType.Edit
                    propValue=attrItem.value;
                case slreq.datamodel.AttributeRegType.Checkbox
                    if isAPImode
                        propValue=attrItem.value;
                    else
                        propValue=num2str(attrItem.value);
                    end
                case slreq.datamodel.AttributeRegType.Combobox
                    propValue=attrReg.entries.at(attrItem.index);
                case slreq.datamodel.AttributeRegType.DateTime



                    propValue=slreq.utils.getDateTime(attrItem.value,'Read');
                end
            else

                if this.hasStereotypeAttribute(propName)
                    propValue=this.getStereotypeAttr(propName,true);
                else
                    reqLinkSet=this.getSet();
                    attrRegistries=rdata.getCustomAttributeRegistries(reqLinkSet);
                    attrReg=attrRegistries.getByKey(propName);
                    if~isempty(attrReg)
                        switch attrReg.typeName
                        case slreq.datamodel.AttributeRegType.Edit
                            propValue='';
                        case slreq.datamodel.AttributeRegType.Checkbox
                            if isAPImode
                                propValue=attrReg.default;
                            else
                                propValue=num2str(attrReg.default);
                            end
                        case slreq.datamodel.AttributeRegType.Combobox
                            entries=attrReg.entries.toArray();
                            if~isempty(entries)


                                propValue=entries{1};
                            else


                                propValue='';
                            end

                        otherwise

                            propValue='';
                        end
                    end
                end
            end
        end

        function hasThisAttribute=hasRegisteredAttribute(this,propName)
            hasThisAttribute=false;
            attrReg=this.getAttributeRegistry(propName);
            if~isempty(attrReg)
                hasThisAttribute=true;
            end
        end

        function hasThisAttribute=hasStereotypeAttribute(this,propName)
            hasThisAttribute=false;
            reqLinkSet=[];
            if isa(this,'slreq.data.Requirement')
                reqLinkSet=this.getReqSet();
            elseif isa(this,'slreq.data.Link')
                reqLinkSet=this.getLinkSet();
            end
            if~isempty(reqLinkSet)
                if slreq.internal.ProfileTypeBase.isProfileStereotype(reqLinkSet,propName)
                    hasThisAttribute=true;
                end
            end
        end
    end

    methods(Access={?slreq.data.LinkSet,?slreq.data.RequirementSet,?slreq.data.Link,?slreq.data.Requirement})


        function updateModificationInfo(this)




            slreq.data.ReqData.updateModificationInfo(this.modelObject);
        end


        function updateRevisionInfo(this,owner)


            changedInfo.propName='revision';
            changedInfo.oldValue=this.modelObject.revision;
            changedInfo.newValue=owner.revision;
            this.modelObject.revision=owner.revision;
            this.notifyObservers(changedInfo)
        end
    end

    methods(Access=protected)
        function attrReg=getAttributeRegistry(this,attrName)
            reqData=slreq.data.ReqData.getInstance();
            reqLinkSet=this.getSet();
            attrRegistries=reqData.getCustomAttributeRegistries(reqLinkSet);
            attrReg=attrRegistries.getByKey(attrName);
        end
    end
end

