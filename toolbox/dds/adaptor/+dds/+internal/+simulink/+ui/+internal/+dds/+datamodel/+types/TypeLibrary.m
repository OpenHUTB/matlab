classdef TypeLibrary<dds.internal.simulink.ui.internal.dds.datamodel.Element



    properties(Access=private)
        mData;
        mModuleSource;
        mTypesSource;
        mGetListFunc;
        mGetObjFunc;
    end

    methods
        function this=TypeLibrary(mdl,tree,node)
            this@dds.internal.simulink.ui.internal.dds.datamodel.Element(mdl,tree,node);
        end

        function refresh(this)
            this.mRefreshChildren=true;
        end

        function setGetChildrenFunc(this,getListFunc,getObjFunc)
            this.mGetListFunc=getListFunc;
            this.mGetObjFunc=getObjFunc;
        end

        function dlgstruct=getDialogSchema(this,arg)

            row=1;

            modules.Type='spreadsheet';
            modules.SelectionChangedCallback=@(tag,sels,dlg)dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.onSelectionChanged(tag,sels,dlg);
            modules.Tag='ssModule';
            modules.Columns={' ','Name'};
            if isempty(this.mModuleSource)
                this.mModuleSource=dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary(this.mMdl,this.mTree,this.mNode);
                this.mModuleSource.setGetChildrenFunc('dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.getModuleList',...
                'dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.getModuleObj');
            else
                this.mModuleSource.refresh();
            end
            modules.Source=this.mModuleSource;


            if this.getShowActions()
                addBtn.Type='pushbutton';
                addBtn.Tag='AddBtn';
                addBtn.FilePath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin','resources','icons','Module_16.png');
                addBtn.ToolTip=message('dds:ui:AddModuleTooltip').getString;
                addBtn.RowSpan=[row,row];
                addBtn.ColSpan=[1,1];
                addBtn.MatlabMethod='dds.internal.simulink.ui.internal.dds.datamodel.types.Module.create';
                addBtn.MatlabArgs={this.mMdl,this.mTree,this.mNode,''};

                dupBtn.Type='pushbutton';
                dupBtn.Tag='DupBtn';
                dupBtn.FilePath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin','resources','icons','copy_16.png');
                dupBtn.ToolTip=message('dds:ui:DupModuleTooltip').getString;
                dupBtn.RowSpan=[row,row];
                dupBtn.ColSpan=[2,2];
                dupBtn.MatlabMethod='dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.duplicateWidgetRow';
                dupBtn.MatlabArgs={'%dialog',modules.Tag,this.mMdl};
                dupBtn.Enabled=false;

                delBtn.Type='pushbutton';
                delBtn.Tag='DelBtn';
                delBtn.FilePath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin','resources','icons','delete2_16.png');
                delBtn.ToolTip=message('dds:ui:DelModuleTooltip').getString;
                delBtn.RowSpan=[row,row];
                delBtn.ColSpan=[4,4];
                delBtn.MatlabMethod='dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.removeWidgetRow';
                delBtn.MatlabArgs={'%dialog',modules.Tag,this.mMdl};
                delBtn.Enabled=false;

                row=row+1;
            end


            modules.RowSpan=[row,3];
            modules.ColSpan=[1,5];

            moduleGrp.Type='group';
            moduleGrp.Flat=0;
            moduleGrp.Name=message('dds:ui:ModulesGroup').getString;
            moduleGrp.RowStretch=[0,0,1];
            moduleGrp.ColStretch=[0,0,0,0,1];
            moduleGrp.LayoutGrid=[3,5];
            moduleGrp.ColSpan=[1,5];
            moduleGrp.RowSpan=[1,2];
            if this.getShowActions()
                moduleGrp.Items={addBtn,dupBtn,delBtn,modules};
            else
                moduleGrp.Items={modules};
            end

            row=1;

            types.Type='spreadsheet';
            types.SelectionChangedCallback=@(tag,sels,dlg)dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.onSelectionChanged(tag,sels,dlg);
            types.Tag='ssTypes';
            types.Columns={' ','Name','DDSType'};
            if isempty(this.mTypesSource)
                this.mTypesSource=dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary(this.mMdl,this.mTree,this.mNode);
                this.mTypesSource.setGetChildrenFunc('dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.getTypesList',...
                'dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.getTypeObj');
            else
                this.mTypesSource.refresh();
            end
            types.Source=this.mTypesSource;


            if this.getShowActions()
                addConstBtn.Type='pushbutton';
                addConstBtn.Tag='AddConstBtn';
                addConstBtn.ToolTip=message('dds:ui:AddConstTooltip').getString;
                addConstBtn.FilePath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin','resources','icons','Const_16.png');
                addConstBtn.RowSpan=[row,row];
                addConstBtn.ColSpan=[1,1];
                addConstBtn.MatlabMethod='dds.internal.simulink.ui.internal.dds.datamodel.types.Const.create';
                addConstBtn.MatlabArgs={this.mMdl,this.mTree,this.mNode,''};

                addEnumBtn.Type='pushbutton';
                addEnumBtn.Tag='AddEnumBtn';
                addEnumBtn.ToolTip=message('dds:ui:AddEnumTooltip').getString;
                addEnumBtn.FilePath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin','resources','icons','Enum_16.png');
                addEnumBtn.RowSpan=[row,row];
                addEnumBtn.ColSpan=[2,2];
                addEnumBtn.MatlabMethod='dds.internal.simulink.ui.internal.dds.datamodel.types.Enum.create';
                addEnumBtn.MatlabArgs={this.mMdl,this.mTree,this.mNode,''};

                addStructBtn.Type='pushbutton';
                addStructBtn.Tag='AddStructBtn';
                addStructBtn.ToolTip=message('dds:ui:AddStructTooltip').getString;
                addStructBtn.FilePath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin','resources','icons','Struct_16.png');
                addStructBtn.RowSpan=[row,row];
                addStructBtn.ColSpan=[3,3];
                addStructBtn.MatlabMethod='dds.internal.simulink.ui.internal.dds.datamodel.types.Struct.create';
                addStructBtn.MatlabArgs={this.mMdl,this.mTree,this.mNode,''};

                duplicateBtn.Type='pushbutton';
                duplicateBtn.Tag='DuplicateTypeBtn';
                duplicateBtn.FilePath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin','resources','icons','copy_16.png');
                duplicateBtn.ToolTip=message('dds:ui:DuplicateRowsTooltip').getString;
                duplicateBtn.RowSpan=[row,row];
                duplicateBtn.ColSpan=[4,4];
                duplicateBtn.MatlabMethod='dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.duplicateWidgetRow';
                duplicateBtn.MatlabArgs={'%dialog',types.Tag,this.mMdl};
                duplicateBtn.Enabled=false;

                removeBtn.Type='pushbutton';
                removeBtn.Tag='RemoveTypeBtn';
                removeBtn.FilePath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin','resources','icons','delete2_16.png');
                removeBtn.ToolTip=message('dds:ui:DeleteTypeTooltip').getString;
                removeBtn.RowSpan=[row,row];
                removeBtn.ColSpan=[6,6];
                removeBtn.MatlabMethod='dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.removeWidgetRow';
                removeBtn.MatlabArgs={'%dialog',types.Tag,this.mMdl};
                removeBtn.Enabled=false;

                row=row+1;
            end


            types.RowSpan=[row,3];
            types.ColSpan=[1,7];

            typesGrp.Type='group';
            typesGrp.Flat=0;
            typesGrp.Name=message('dds:ui:TypesGroup').getString;
            typesGrp.RowStretch=[0,0,1];
            typesGrp.ColStretch=[0,0,0,0,0,0,1];
            typesGrp.LayoutGrid=[3,7];
            typesGrp.RowSpan=[3,5];
            typesGrp.ColSpan=[1,3];
            if this.getShowActions()
                typesGrp.Items={addConstBtn,addEnumBtn,addStructBtn,removeBtn,duplicateBtn,types};
            else
                typesGrp.Items={types};
            end

            panel.Type='panel';
            panel.LayoutGrid=[5,3];
            panel.RowStretch=[0,1,0,0,2];
            panel.ColStretch=[0,0,1];
            panel.Items={moduleGrp,typesGrp};

            dlgstruct.Items={panel};
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.EmbeddedButtonSet={''};
            dlgstruct.DialogMode='Slim';
            dlgstruct.LayoutGrid=[2,1];
            dlgstruct.DialogTitle='';
            dlgstruct.DialogTag=this.getDialogTag();
            dlgstruct.DialogTitle=this.getDialogTitle();
        end

        function children=getChildren(this)
            if isempty(this.mData)||this.mRefreshChildren
                this.mRefreshChildren=false;
                this.mData=this.generateChildren();
            end
            children=this.mData;
        end

        function children=generateChildren(this)
            children=[];
            childList=feval(this.mGetListFunc,this.mNode);
            if isempty(childList)
                return;
            end

            childObj=feval(this.mGetObjFunc,this.mNode,childList{1});
            dataClass=['dds.internal.simulink.ui.internal.',class(childObj)];
            children=feval(dataClass,this.mMdl,this.mTree,childObj);
            for i=2:numel(childList)
                childObj=feval(this.mGetObjFunc,this.mNode,childList{i});
                children(i)=feval(dataClass,this.mMdl,this.mTree,childObj);
            end
        end

        function isReadonly=isReadonlyProperty(this,propName)
            isReadonly=true;
        end

        function addSection(this)
            dds.internal.simulink.ui.internal.dds.datamodel.types.Module.create(this.mMdl,this.mTree,this.mNode,'');
        end

        function addObject(this,type)
            switch type
            case 'Const'
                dds.internal.simulink.ui.internal.dds.datamodel.types.Const.create(this.mMdl,this.mTree,this.mNode,'');
            case 'Enum'
                dds.internal.simulink.ui.internal.dds.datamodel.types.Enum.create(this.mMdl,this.mTree,this.mNode,'');
            case 'Struct'
                dds.internal.simulink.ui.internal.dds.datamodel.types.Struct.create(this.mMdl,this.mTree,this.mNode,'');
            end
        end

        function typeChain=getTypeChain(this)
            typeChain={this.getClassName()};
        end
    end


    methods(Static,Access=public)
        function r=onSelectionChanged(tag,sels,dlg)
            if isequal(tag,'ssModule')
                delBtn='DelBtn';
                dupBtn='DupBtn';
            else
                delBtn='RemoveTypeBtn';
                dupBtn='DuplicateTypeBtn';
            end
            if~isempty(delBtn)
                dlg.setEnabled(delBtn,~isempty(sels));
            end
            if~isempty(dupBtn)
                dlg.setEnabled(dupBtn,~isempty(sels));
            end
        end

        function typeLibObj=create(ddsMdl,ddsTree,~,name)



            typeLibs=dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.getTypeLibraries(ddsTree);
            txn=ddsMdl.beginTransaction;
            typeLibObj=dds.internal.simulink.ui.internal.dds.datamodel.Element.create(ddsMdl,typeLibs,'dds.datamodel.types.TypeLibrary',name);
            systemInModel=dds.internal.getSystemInModel(ddsMdl);
            systemInModel.TypeLibraries.add(typeLibObj);
            txn.commit;
        end

        function removeWidgetRow(dlg,wTag,ddsMdl)
            ssWidget=dlg.getWidgetInterface(wTag);
            selection=ssWidget.getSelection;
            dds.internal.simulink.ui.internal.DDSLibraryUI.deleteSelection(ddsMdl,selection);
        end

        function duplicateWidgetRow(dlg,wTag,ddsMdl)
            ssWidget=dlg.getWidgetInterface(wTag);
            selection=ssWidget.getSelection;
            for i=1:numel(selection)
                selection{i}.duplicate();
            end
        end

        function typeLibs=getTypeLibraries(ddsTree)
            typeLibs={};
            for i=1:ddsTree.System.TypeLibraries.Size()
                try
                    typeLibs{end+1}=ddsTree.System.TypeLibraries(i).Name;
                catch
                    typeLibs{end+1}='TypeLibrary';
                end
            end
        end

        function modules=getModuleList(typeLibNode)
            modules={};
            keys=typeLibNode.Elements.keys;
            for i=1:typeLibNode.Elements.Size
                elem=typeLibNode.Elements{keys{i}};
                if(isprop(elem,'Elements'))
                    modules{end+1}=elem.Name;
                end
            end
        end

        function moduleObj=getModuleObj(typeLibNode,moduleName)
            moduleObj=[];
            keys=typeLibNode.Elements.keys;
            for i=1:typeLibNode.Elements.Size
                elem=typeLibNode.Elements{keys{i}};
                if isequal(elem.Name,moduleName)
                    moduleObj=elem;
                    break;
                end
            end
        end

        function types=getTypesList_Full(ddsTree)
            map=containers.Map;
            dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.parseTypes(ddsTree.System.TypeLibraries,map,true,false,'','::');
            types=map.keys();
            if isempty(types)
                types={};
            end
        end

        function types=getTypesList_ByType(ddsTree,type)
            map=containers.Map;
            dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.parseTypes(ddsTree.System.TypeLibraries,map,true,false,type,'_');
            types=map.keys();
            if isempty(types)
                types={};
            end
        end

        function types=getTypesList(typeLibNode)
            map=containers.Map;
            dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.parseTypes(typeLibNode,map,false,false,'','::');
            types=map.keys();
            if isempty(types)
                types={};
            end
        end

        function typeObj=getTypeObj_Full(ddsTree,typeName)
            map=containers.Map;
            dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.parseTypes(ddsTree.System.TypeLibraries,map,true,false,'','::');
            typeObj=map(typeName);
        end

        function typeObj=getTypeObj(typeLibNode,typeName)
            map=containers.Map;
            dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.parseTypes(typeLibNode,map,false,false,'','::');
            typeObj=map(typeName);
        end

        function objList=getObjListFromTypes(typeLibNode)
            map=containers.Map;
            dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.parseTypes(typeLibNode,map,true,true,'','::');
            objList=map.values;
        end


        function parseTypes(typeLibNode,map,recurse,inclMods,matchType,delim)
            prefix='';
            if isprop(typeLibNode,'Elements')
                dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.visitElementsIn(typeLibNode,map,prefix,recurse,inclMods,matchType,delim);
            else
                for i=1:typeLibNode.Size
                    elem=typeLibNode(i);
                    dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.visitElementsIn(elem,map,prefix,recurse,inclMods,matchType,delim);
                end
            end
        end


        function visitElementsIn(typeLib,map,prefix,recurse,inclMods,matchType,delim)
            keys=typeLib.Elements.keys;
            for i=1:typeLib.Elements.Size
                elem=typeLib.Elements{keys{i}};
                if isprop(elem,'Elements')
                    if recurse
                        if inclMods
                            map([prefix,elem.Name])=elem;
                        end
                        dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.visitElementsIn(elem,map,[prefix,elem.Name,delim],recurse,inclMods,matchType,delim);
                    end
                else
                    if isempty(matchType)||isequal(matchType,class(elem))
                        map([prefix,elem.Name])=elem;
                    end
                end
            end
        end

    end



    methods(Access=private)


    end
end
