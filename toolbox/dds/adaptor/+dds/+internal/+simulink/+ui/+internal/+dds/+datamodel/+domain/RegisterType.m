classdef RegisterType<dds.internal.simulink.ui.internal.dds.datamodel.Element



    properties(Access=private)
    end

    methods
        function this=RegisterType(mdl,tree,node)
            this@dds.internal.simulink.ui.internal.dds.datamodel.Element(mdl,tree,node);
        end

        function isValid=isValidProperty(this,propName)
            isValid=isValidProperty@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName);
        end

        function isReadonly=isReadonlyProperty(this,propName)
            isReadonly=isReadonlyProperty@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName);
        end

        function dataType=getPropDataType(this,propName)
            if isequal(propName,'TypeRef')
                dataType='enum';
            else
                dataType=getPropDataType@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName);
            end
        end

        function values=getPropAllowedValues(this,propName)
            if isequal(propName,'TypeRef')
                values=dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.getTypesList_Full(this.mTree);


                propVal=this.getPropValue(propName);
                if~any(ismember(values,propVal))
                    values{end+1}=this.getPropValue(propName);
                end
            else
                values=getPropAllowedValues@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName);
                return;
            end
        end

        function propVal=getPropValue(this,propName)
            if isequal(propName,'TypeRef')
                propVal=this.getTypeNamePath();
            else
                propVal=getPropValue@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName);
                return;
            end
        end

        function setPropValue(this,propName,propVal)
            if isequal(propName,'TypeRef')
                typeObj=this.getTypeObj(propVal);
                setPropValue@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName,typeObj);
            else
                setPropValue@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName,propVal);
                return;
            end
        end

        function regTypeObj=duplicate(this)
            domainNode=this.mNode.Container;
            regTypes=dds.internal.simulink.ui.internal.dds.datamodel.domain.Domain.getRegisteredNames(domainNode);
            txn=this.mMdl.beginTransaction;
            regTypeObj=dds.internal.simulink.ui.internal.dds.datamodel.Element.duplicateElement(this.mMdl,regTypes,this.mNode,'');
            domainNode.RegisterTypes.add(regTypeObj);
            txn.commit;
        end

    end



    methods(Access=private)

        function regNameObj=getRegisteredNameObj(this,regName)
            regNameObj=[];
            domain=this.mNode.Container;
            domainClass='dds.datamodel.domain.Domain';
            dataClass=['dds.internal.simulink.ui.internal.',domainClass];
            regNameObj=feval([dataClass,'.getRegisteredNameObj'],domain,regName);
        end

        function typeObj=getTypeObj(this,typeName)
            typeObj=[];
            typeLib='dds.datamodel.types.TypeLibrary';
            dataClass=['dds.internal.simulink.ui.internal.',typeLib];
            typeObj=feval([dataClass,'.getTypeObj_Full'],this.mTree,typeName);
        end

        function typeName=getTypeNamePath(this)
            try
                regTypeRef=this.mNode;
                typeRef=regTypeRef.TypeRef;

                typeObj='dds.datamodel.types.Type';
                dataClass=['dds.internal.simulink.ui.internal.',typeObj];
                typeName=feval([dataClass,'.getFullPath'],typeRef);
            catch
                typeName='';
            end
        end
    end


    methods(Static,Access=public)

        function regTypeObj=create(ddsMdl,ddsTree,domainNode,name)
            regTypeObj=[];
            types=dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.getTypesList_Full(ddsTree);
            if~isempty(types)
                regTypes=dds.internal.simulink.ui.internal.dds.datamodel.domain.Domain.getRegisteredNames(domainNode);
                txn=ddsMdl.beginTransaction;
                regTypeObj=dds.internal.simulink.ui.internal.dds.datamodel.Element.create(ddsMdl,regTypes,'dds.datamodel.domain.RegisterType',name);
                typeObj=dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.getTypeObj_Full(ddsTree,types{1});
                regTypeObj.TypeRef=typeObj;
                domainNode.RegisterTypes.add(regTypeObj);
                txn.commit;
            else
                errordlg(message('dds:ui:NoTypes').getString,message('dds:ui:AddRegType').getString);
            end
        end

    end

end
