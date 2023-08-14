classdef Type<dds.internal.simulink.ui.internal.dds.datamodel.Element



    properties(Access=protected)
        mSimObject;
mUpdateVisitor
mUsingShortName
mFullNameStr
mShortNameStr
    end

    methods
        function this=Type(mdl,tree,node)
            this@dds.internal.simulink.ui.internal.dds.datamodel.Element(mdl,tree,node);
            this.mUsingShortName=dds.internal.isSystemUsingShortName(mdl);
            this.mFullNameStr=dds.internal.getFullNameForType(node,'::',false);
            this.mShortNameStr=dds.internal.getFullNameForType(node);
            this.mSimObject=dds.internal.simulink.getSimObjectFor(mdl,node,'',false);
            this.mUpdateVisitor=dds.internal.simulink.UpdateSimObjectsVisitor();
        end

        function hasSimObj=hasSimObject(this)%#ok<MANU> 
            hasSimObj=true;
        end

        function putSimObject(this)
            this.mUpdateVisitor.addSimObject(this.mNode,this.mSimObject,true);
            this.mUpdateVisitor.visitModel(this.mMdl);
        end

        function dlgStruct=getDialogSchema(this,arg1)%#ok<INUSD> 
            name=this.mNode.Name;
            dlgStruct=this.mSimObject.getDialogSchema(name);
        end

        function src=getForwardedObject(this)
            src=this.mSimObject;
        end

        function isValid=isValidProperty(this,propName)
            if~isequal(propName,'DDSType')
                isValid=isValidProperty@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName);
                return;
            end
            isValid=true;
        end

        function isReadonly=isReadonlyProperty(this,propName)
            if~isequal(propName,'DDSType')
                isReadonly=isReadonlyProperty@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName);
                return;
            end
            isReadonly=true;
        end

        function propVal=getPropValue(this,propName)
            if~isequal(propName,'DDSType')
                propVal=getPropValue@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName);
                return;
            end
            try
                propVal=this.mNode.getDDSType();
                if~ischar(propVal)
                    name=class(this.mNode);
                    parsed=split(name,'.');
                    propVal=parsed{numel(parsed)};
                end
            catch
                propVal='';
            end
        end

        function setPropValue(this,propName,propVal)
            if~isequal(propName,'Name')
                setPropValue@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName,propVal);
                return;
            end
            origVal=this.getPropValue(propName);
            if~isequal(propVal,origVal)
                filespec=Simulink.DDSDictionary.ModelRegistry.getDDFileSpecForDDSModel(this.mMdl);
                ddConn=Simulink.data.dictionary.open(filespec);
                txn=this.mMdl.beginRevertibleTransaction;
                setPropValue@dds.internal.simulink.ui.internal.dds.datamodel.Element(this,propName,propVal);
                fullname=dds.internal.getFullNameForType(this.mNode);
                if~ddConn.getSection('Design Data').exist(fullname)
                    txn.commit();

                    this.mFullNameStr=dds.internal.getFullNameForType(this.mNode,'::',false);
                    this.mShortNameStr=dds.internal.getFullNameForType(this.mNode);
                else
                    txn.rollBack();
                end
            end
        end

        function addObject(this,type)
            parent=this.mNode.Container;
            switch type
            case 'Const'
                dds.internal.simulink.ui.internal.dds.datamodel.types.Const.create(this.mMdl,this.mTree,parent,'');
            case 'Enum'
                dds.internal.simulink.ui.internal.dds.datamodel.types.Enum.create(this.mMdl,this.mTree,parent,'');
            case 'Struct'
                dds.internal.simulink.ui.internal.dds.datamodel.types.Struct.create(this.mMdl,this.mTree,parent,'');
            end
        end

        function typeObj=duplicate(this)
            parent=this.mNode.Container;
            types=dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.getTypesList(parent);
            txn=this.mMdl.beginTransaction;
            typeObj=dds.internal.simulink.ui.internal.dds.datamodel.Element.duplicateElement(this.mMdl,types,this.mNode,'');
            parent.Elements.add(typeObj);
            dds.internal.simulink.ui.internal.dds.datamodel.types.Type.makeNameUnique(this.mMdl,typeObj);
            dds.internal.simulink.getSimObjectFor(this.mMdl,typeObj);
            txn.commit;
        end

        function typeChain=getTypeChain(this)%#ok<MANU> 
            typeChain={'Type'};
        end

        function dlgStruct=addFullAndShortName(this,dlgStruct,addlItems)
            if nargin<3
                addlItems=[];
            end
            fullNameText.Name=DAStudio.message('dds:ui:TypeFullname');
            fullNameText.RowSpan=[1,1];
            fullNameText.ColSpan=[1,1];
            fullNameText.Type='text';
            fullNameText.Tag='TypeFullName_tag';
            fullNameVal.Name=this.mFullNameStr;
            fullNameVal.RowSpan=[1,1];
            fullNameVal.ColSpan=[2,2];
            fullNameVal.Type='text';
            fullNameVal.Tag='TypeFullNameVal_tag';
            shortNameText.Name=DAStudio.message('dds:ui:TypeShortname');
            shortNameText.RowSpan=[2,2];
            shortNameText.ColSpan=[1,1];
            shortNameText.Type='text';
            shortNameText.Tag='TypeShortName_tag';
            shortNameVal.Name=this.mShortNameStr;
            shortNameVal.RowSpan=[2,2];
            shortNameVal.ColSpan=[2,2];
            shortNameVal.Type='text';
            shortNameVal.Tag='TypeShortNameVal_tag';
            fullShortPanel.Type='panel';
            fullShortPanel.Tag='fullAndShortNamespanel_tag';
            if~isempty(addlItems)
                fullShortPanel.Items=[{fullNameText},{fullNameVal},{shortNameText},{shortNameVal},addlItems(:)'];
                fullShortPanel.LayoutGrid=[addlItems{end}.RowSpan(2),3];
            else
                fullShortPanel.Items={fullNameText,fullNameVal,shortNameText,shortNameVal};
                fullShortPanel.LayoutGrid=[2,3];
            end
            fullShortPanel.RowSpan=[1,1];
            fullShortPanel.ColStretch=[0,0,1];
            curItems=dlgStruct.Items;
            dlgStruct.Items=[{fullShortPanel},curItems(:)'];
        end
    end


    methods(Static,Access=public)

        function typeName=getFullPath(typeRef)
            typeName=dds.internal.simulink.ui.internal.dds.datamodel.types.Type.visitParents(typeRef,'');
        end

        function name=visitParents(elem,name)
            if isprop(elem,'Name')
                if~isempty(name)
                    name=['::',name];
                end
                name=[elem.Name,name];
                if isprop(elem,'Container')
                    parent=elem.Container;
                    name=dds.internal.simulink.ui.internal.dds.datamodel.types.Type.visitParents(parent,name);
                end
            end
        end

        function makeNameUnique(mdl,node)
            filespec=Simulink.DDSDictionary.ModelRegistry.getDDFileSpecForDDSModel(mdl);
            ddConn=Simulink.data.dictionary.open(filespec);

            baseName=node.Name;
            uniqueName=false;
            idx=1;
            while~uniqueName
                fullname=dds.internal.getFullNameForType(node);
                if~ddConn.getSection('Design Data').exist(fullname)
                    uniqueName=true;
                else
                    isExists=true;
                    while isExists
                        newName=[baseName,num2str(idx)];
                        idx=idx+1;
                        try
                            node.Name=newName;
                            isExists=false;
                        catch
                        end
                    end
                end
            end
        end
    end


    methods(Access=private)


    end
end
