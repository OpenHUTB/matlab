classdef Module<dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary



    properties(Access=private)
        mData;
    end

    methods
        function this=Module(mdl,tree,node)
            this@dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary(mdl,tree,node);
        end

        function isReadonly=isReadonlyProperty(this,propName)
            isReadonly=isReadonlyProperty@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName);
        end

        function setPropValue(this,propName,propVal)
            if~isequal(propName,'Name')
                setPropValue@dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary(this,propName,propVal);
                return;
            end
            origVal=this.getPropValue(propName);
            if~isequal(propVal,origVal)
                filespec=Simulink.DDSDictionary.ModelRegistry.getDDFileSpecForDDSModel(this.mMdl);
                ddConn=Simulink.data.dictionary.open(filespec);
                txn=this.mMdl.beginRevertibleTransaction;
                setPropValue@dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary(this,propName,propVal);
                objList=dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.getObjListFromTypes(this.mNode);
                uniqueNames=true;
                for i=1:numel(objList)
                    fullname=dds.internal.getFullNameForType(objList{i});
                    if ddConn.getSection('Design Data').exist(fullname)
                        uniqueNames=false;
                        break;
                    end
                end
                if uniqueNames
                    txn.commit();
                else
                    txn.rollBack();
                end
            end
        end

        function typeObj=duplicate(this)
            parent=this.mNode.Container;
            modules=dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.getModuleList(parent);
            txn=this.mMdl.beginTransaction;
            typeObj=dds.internal.simulink.ui.internal.dds.datamodel.Element.duplicateElement(this.mMdl,modules,this.mNode,'');
            parent.Elements.add(typeObj);

            dds.internal.simulink.ui.internal.dds.datamodel.types.Type.makeNameUnique(this.mMdl,typeObj);
            dds.internal.simulink.getSimObjectFor(this.mMdl,typeObj);
            objList=dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.getObjListFromTypes(typeObj);
            for i=1:numel(objList)
                dds.internal.simulink.ui.internal.dds.datamodel.types.Type.makeNameUnique(this.mMdl,objList{i});
                dds.internal.simulink.getSimObjectFor(this.mMdl,objList{i});
            end
            txn.commit;
        end

        function typeChain=getTypeChain(this)
            typeChain={this.getClassName()};
        end
    end


    methods(Static,Access=public)

        function moduleObj=create(ddsMdl,~,typeLibNode,name)
            modules=dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.getModuleList(typeLibNode);
            txn=ddsMdl.beginTransaction;
            moduleObj=dds.internal.simulink.ui.internal.dds.datamodel.Element.create(ddsMdl,modules,'dds.datamodel.types.Module',name);
            typeLibNode.Elements.add(moduleObj);
            dds.internal.simulink.getSimObjectFor(ddsMdl,moduleObj);
            txn.commit;
        end

    end



    methods(Access=private)


    end
end
