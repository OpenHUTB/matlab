classdef Struct<dds.internal.simulink.ui.internal.dds.datamodel.types.Type



    properties(Access=private)
    end

    properties(Access=public)
        UserData;
        BaseRef;
        Entries;
        Value;
    end

    methods
        function this=Struct(mdl,tree,node)
            this@dds.internal.simulink.ui.internal.dds.datamodel.types.Type(mdl,tree,node);
            this.UserData=[];
            this.setBaseRefAndDeps();
        end

        function setBaseRefAndDeps(this)
            if~isempty(this.mNode.BaseRef)
                this.BaseRef=dds.internal.getFullNameForType(this.mNode.BaseRef,'::',false);
            else
                this.BaseRef=DAStudio.message('dds:ui:TypeStructBasenameNone');
            end
            visitor=dds.internal.GetFullNamesVisitor('::');
            visitor.visitModel(this.mMdl);
            names=visitor.StructsMap.keys;
            removedNames=names(~strcmp(names,this.mFullNameStr));
            this.Entries=[DAStudio.message('dds:ui:TypeStructBasenameNone'),removedNames];
            this.Value=find(strcmp(this.Entries,this.BaseRef),1)-1;
        end

        function setEntryValue(this,newValue)
            this.mSimObject=newValue;
        end

        function userData=getUserData(this)
            userData=this.UserData;
        end

        function setUserData(this,userData)
            this.UserData=userData;
        end


        function putSimObject(this)

            txn=this.mMdl.beginRevertibleTransaction;
            try
                if this.Value~=0
                    baseClassStr=this.Entries{this.Value+1};
                    if~isequal(baseClassStr,this.BaseRef)
                        theBaseObj=dds.internal.getTypeBasedOnFullName(baseClassStr,this.mMdl,false,'::');
                        if isempty(theBaseObj)
                            dds.internal.simulink.Util.warningNoBacktrace(message('dds:io:TypeNotDefined',baseClassStr));
                        else
                            this.mNode.BaseRef=theBaseObj;
                            this.BaseRef=baseClassStr;
                        end
                    end
                else
                    if~isempty(this.mNode.BaseRef)
                        this.mNode.BaseRef=dds.datamodel.types.Struct.empty();
                    end
                end
                putSimObject@dds.internal.simulink.ui.internal.dds.datamodel.types.Type(this);
                txn.commit();
            catch ex
                txn.rollBack();
                this.mSimObject=dds.internal.simulink.getSimObjectFor(this.mMdl,this.mNode,'',false);

                this.setBaseRefAndDeps()
                rethrow(ex);
            end
        end

        function dlgStruct=getDialogSchema(this,arg1)%#ok<INUSD> 
            name=this.mNode.Name;
            slprivate('slUpdateDataTypeListSource','set',this);
            dlgStruct=this.mSimObject.getDialogSchema(name);

            baseNameText.Name=DAStudio.message('dds:ui:TypeStructBasename');
            baseNameText.RowSpan=[3,3];
            baseNameText.ColSpan=[1,1];
            baseNameText.Type='text';
            baseNameText.Tag='baseNameStruct_tag';
            baseNameVal.Entries=this.Entries;
            baseNameVal.Value=this.Value;
            baseNameVal.RowSpan=[3,3];
            baseNameVal.ColSpan=[2,2];
            baseNameVal.Type='combobox';
            baseNameVal.MatlabMethod='changeEntryValue';
            baseNameVal.MatlabArgs={'%source','%value','%tag','Value'};
            baseNameVal.Tag='baseNameStructVal_tag';

            addlItems=[{baseNameText},{baseNameVal}];
            dlgStruct=this.addFullAndShortName(dlgStruct,addlItems);




            for i=1:numel(dlgStruct.Items)
                curItem=dlgStruct.Items{i};
                if isfield(curItem,'Tag')&&strcmp(curItem.Tag,'editorBtnPnl_tag')
                    dlgStruct.Items{i}.Enabled=0;
                    break;
                end
            end
            slprivate('slUpdateDataTypeListSource','clear');
        end

        function rtn=useBusEditor(~)
            rtn=false;
        end


        function rtn=hasSLDDAPISupport(~)
            rtn=true;
        end

        function types=getEntriesWithClass(this,scope,class)%#ok<INUSD> 
            types={};
            switch(class)
            case 'Simulink.Bus'
                type='dds.datamodel.types.Struct';
            otherwise
                type='';
            end
            if~isempty(type)
                types=dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.getTypesList_ByType(this.mTree,type);
            end
        end

        function rtn=isOpen(~)
            rtn=true;
        end

        function rtn=HasAccessToBaseWorkspace(~)
            rtn=false;
        end
    end


    methods(Static,Access=public)

        function typeObj=create(ddsMdl,~,typeLibNode,name)
            types=dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.getTypesList(typeLibNode);
            txn=ddsMdl.beginTransaction;
            typeObj=dds.internal.simulink.ui.internal.dds.datamodel.Element.create(ddsMdl,types,'dds.datamodel.types.Struct',name);
            element=dds.datamodel.types.StructMember(ddsMdl);
            element.Name='Element1';
            element.Id=0;
            element.Index=1;
            element.Key=1;
            element.Type=dds.datamodel.types.Integer(ddsMdl);
            typeObj.Members.add(element);
            element=dds.datamodel.types.StructMember(ddsMdl);
            element.Name='Element2';
            element.Id=1;
            element.Index=2;
            element.Key=0;
            element.Type=dds.datamodel.types.Integer(ddsMdl);
            typeObj.Members.add(element);
            typeLibNode.Elements.add(typeObj);
            dds.internal.simulink.ui.internal.dds.datamodel.types.Type.makeNameUnique(ddsMdl,typeObj);
            dds.internal.simulink.getSimObjectFor(ddsMdl,typeObj);
            txn.commit;
        end

    end



    methods(Access=private)


    end
end
