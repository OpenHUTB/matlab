





classdef PackageTree<handle
    properties(SetObservable=true)
        m3iObj;
        parentDlg;
        itemTag;
        modelName;
        CloseListener;
    end

    methods
        function obj=PackageTree(mObj,pDlg,tag)
            obj.m3iObj=mObj;
            obj.parentDlg=pDlg;
            obj.itemTag=tag;


            obj.modelName=autosar.mm.observer.ObserversDispatcher.findModelFromMetaModel(mObj.modelM3I);
            assert(~isempty(obj.modelName),'Could not find a loaded Simulink model using m3iModel!');


            modelH=get_param(obj.modelName,'Handle');
            obj.CloseListener=Simulink.listener(modelH,'CloseEvent',...
            @CloseForBrowserCB);
        end

        function varType=getPropDataType(~,~)
            varType='ustring';
        end

        function rootid=createPackageTree(obj,traversedRoot,...
            curRootTreeNode,rootid)
            for ii=1:length(traversedRoot.HierarchicalChildren)
                rootid=rootid+1;
                m3iObjPkg=traversedRoot.HierarchicalChildren(ii).M3iObject;
                if~isempty(m3iObjPkg)&&autosar.mm.arxml.Exporter.isExternalReference(m3iObjPkg)
                    icon=autosar.ui.metamodel.PackageString.IconMap('References');
                else
                    icon=[];
                end

                node=autosar.ui.metamodel.PackageTreeNode(...
                traversedRoot.HierarchicalChildren(ii).Name,rootid,icon);
                curRootTreeNode.Children{end+1}=node;
                rootid=obj.createPackageTree(traversedRoot.HierarchicalChildren(ii),...
                node,rootid);
            end
        end


        function[status,msg]=hApplyCB(obj,dlg)
            status=false;
            msg='';

            pkgValue=dlg.getWidgetValue('Package_Viewer');
            pkgValue=pkgValue(9:end);

            if isempty(pkgValue)

                return;
            end
            if strcmp(obj.parentDlg.dialogTag,'autosar_xmloptions_dialog')

                modelM3I=obj.m3iObj.modelM3I;
                assert(modelM3I.RootPackage.size==1);
                m3iPkg=autosar.mm.Model.findChildByName(modelM3I,pkgValue);
                assert(m3iPkg.isvalid());

                t=M3I.Transaction(modelM3I);
                m3iPkg.packagedElement.append(obj.m3iObj)
                t.commit();
            else

                obj.parentDlg.setWidgetValue(obj.itemTag,pkgValue);

                sourceNode=obj.parentDlg.getWidgetSource(obj.itemTag);
                autosar.ui.utils.applyPackageChange(sourceNode.M3iObject,...
                obj.parentDlg,obj.itemTag);
            end
            status=true;
        end


        function hAddCB(obj,dlg)
            pkgValue=dlg.getWidgetValue('Package_Viewer');
            pkgValue=[pkgValue(9:end),'/',autosar.ui.wizard.PackageString.NewName];

            modelM3I=obj.m3iObj.modelM3I;
            assert(modelM3I.RootPackage.size==1);

            m3iPkg=autosar.mm.Model.findChildByName(modelM3I,pkgValue);
            if isempty(m3iPkg)
                m3iPkg=autosar.mm.Model.getOrAddARPackage(modelM3I,pkgValue);
                assert(m3iPkg.isvalid());
            else
                pkgObjs=autosar.mm.Model.findChildByTypeName(m3iPkg.containerM3I,...
                'Simulink.metamodel.arplatform.common.Package');
                protectedNames={};
                for ii=1:length(pkgObjs)
                    protectedNames=[protectedNames,{pkgObjs{ii}.Name}];%#ok<AGROW>
                end
                newName=genvarname(autosar.ui.wizard.PackageString.NewName,...
                protectedNames);
                [pkgValue,~]=fileparts(pkgValue);
                m3iPkg=autosar.mm.Model.getOrAddARPackage(modelM3I,[pkgValue,'/',newName]);
                assert(m3iPkg.isvalid());
            end

            dlg.refresh;
        end


        function hRemoveCB(obj,dlg)
            pkgValue=dlg.getWidgetValue('Package_Viewer');
            pkgValue=['AUTOSAR',pkgValue(9:end)];

            modelM3I=obj.m3iObj.modelM3I;
            assert(modelM3I.RootPackage.size==1);
            m3iPkg=autosar.mm.Model.findChildByName(modelM3I,pkgValue);
            assert(m3iPkg.isvalid());

            if(m3iPkg.isvalid&&m3iPkg.packagedElement.size()==0)
                t=M3I.Transaction(modelM3I);
                m3iPkg.destroy();
                t.commit();
                obj.m3iObj=modelM3I.RootPackage.front();
                dlg.refresh;
            else

            end
        end


        function dlg=getDialogSchema(obj)

            modelM3I=obj.m3iObj.modelM3I;
            assert(modelM3I.RootPackage.size==1);
            traversedRoot=autosar.ui.utils.viewAUTOSAR(modelM3I,...
            'UIViewType',autosar.ui.utils.UIViewType.Package);
            icon=[];
            root=autosar.ui.metamodel.PackageTreeNode(...
            autosar.ui.metamodel.PackageString.packagesNode,1,icon);
            lastid=obj.createPackageTree(traversedRoot,root,1);
            deleteTree(traversedRoot);


            buttonVisible=ecoderinstalled();
            addPushButton.Type='pushbutton';
            addPushButton.Tag='AddButton';
            addPushButton.MatlabMethod='hAddCB';
            addPushButton.MatlabArgs={obj,'%dialog'};
            addPushButton.RowSpan=[2,2];
            addPushButton.ColSpan=[1,1];
            addPushButton.FilePath=autosar.ui.metamodel.PackageString.AddIcon;
            addPushButton.Visible=buttonVisible;

            deletePushButton.Type='pushbutton';
            deletePushButton.Tag='DeleteButton';
            deletePushButton.MatlabMethod='hRemoveCB';
            deletePushButton.MatlabArgs={obj,'%dialog'};
            deletePushButton.RowSpan=[2,2];
            deletePushButton.ColSpan=[3,3];
            deletePushButton.FilePath=autosar.ui.metamodel.PackageString.DeleteIcon;
            deletePushButton.Visible=buttonVisible;

            ar_tip_panelWithButtons.Type='panel';
            ar_tip_panelWithButtons.Tag='ar_tip_panelWithButtons';
            ar_tip_panelWithButtons.LayoutGrid=[1,6];
            ar_tip_panelWithButtons.ColStretch=[0,0,0,0,1,0];
            ar_tip_panelWithButtons.Items={addPushButton,deletePushButton};

            tree.Name=autosar.ui.metamodel.PackageString.packageTreeLabel;
            tree.Tag='Package_Viewer';
            tree.Type='tree';
            tree.RowSpan=[2,4];
            tree.ColSpan=[1,4];
            tree.Mode=1;
            tree.TreeModel={root};
            tree.Enabled=buttonVisible;


            objPath=autosar.api.Utils.getQualifiedName(obj.m3iObj);
            if~isa(obj.m3iObj,autosar.ui.metamodel.PackageString.packageClass)
                [objPath,~,~]=fileparts(objPath);
            end
            objPath=[autosar.ui.metamodel.PackageString.packagesNode,objPath];
            tree.TreeMultiSelect=false;
            tree.TreeSelectItems={objPath};


            tree.TreeExpandItems={};
            for ii=1:lastid
                tree.TreeExpandItems{end+1}=ii;
            end


            tree.TreeEditCallback=@hLocTreeEditCallback;
            tree.TreeValueChangedCallback=@hLocTreeValueChangedCallback;




            dlg.DialogTitle=autosar.ui.metamodel.PackageString.packageDlgTitle;
            dlg.Items={ar_tip_panelWithButtons,tree};
            dlg.Sticky=true;
            dlg.StandaloneButtonSet={'Help','Apply'};
            dlg.PreApplyCallback='hApplyCB';
            dlg.PreApplyArgs={obj,'%dialog'};
            dlg.Source=obj;
            dlg.DialogTag='PackageBrowser';
            dlg.HelpMethod='helpview';
            dlg.HelpArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_pkg_browser_dlg'};
        end
    end
end


function[isEditable,editString]=hLocTreeEditCallback(dlg,tree_tag,item,path)%#ok<INUSL>
    editString='';
    if item==1
        isEditable=false;
    else
        isEditable=true;
        [~,editString,~]=fileparts(path);
    end
end


function[isValueChanged,editString]=hLocTreeValueChangedCallback(dlg,tree_tag,item,path,newValue)%#ok<INUSL>
    isValueChanged=false;
    editString='';
    if item==1
        editString=autosar.ui.metamodel.PackageString.packagesNode;
    else
        pkgTreeObj=dlg.getDialogSource;
        modelM3I=pkgTreeObj.m3iObj.modelM3I;
        assert(modelM3I.RootPackage.size==1);
        modelName=pkgTreeObj.modelName;


        maxShortNameLength=autosar.ui.utils.getAutosarMaxShortNameLength(modelM3I);
        msg=autosar.ui.utils.isValidARIdentifier(newValue,'shortName',maxShortNameLength);
        if~isempty(msg)
            errordlg(msg,autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
            return;
        end


        pkgValue=path(9:end);
        m3iPkg=autosar.mm.Model.findChildByName(modelM3I,pkgValue);
        assert(m3iPkg.isvalid());
        if strcmp(newValue,m3iPkg.Name)
            return;
        end
        isValid=autosar.ui.utils.checkDuplicateInSequence(m3iPkg.containerM3I.containeeM3I,newValue);
        if~isValid
            errordlg(DAStudio.message('RTW:autosar:shortNameClash',newValue),...
            autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
            return;
        end


        qOldPkgName=autosar.api.Utils.getQualifiedName(m3iPkg);
        m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
        assert(m3iComp.isvalid());


        t=M3I.Transaction(modelM3I);
        m3iPkg.Name=newValue;
        t.commit();



        modelMapping=autosar.api.Utils.modelMapping(modelName);
        modelMapping.MappedTo.UUID=m3iComp.qualifiedName;


        qPkgName=autosar.api.Utils.getQualifiedName(m3iPkg);
        if strfind(modelM3I.RootPackage.front.DataTypePackage,qOldPkgName)==1
            t=M3I.Transaction(modelM3I);
            modelM3I.RootPackage.front.DataTypePackage=...
            regexprep(modelM3I.RootPackage.front.DataTypePackage,['^',qOldPkgName],qPkgName);
            t.commit();
        end


        if strfind(modelM3I.RootPackage.front.InterfacePackage,qOldPkgName)==1
            t=M3I.Transaction(modelM3I);
            modelM3I.RootPackage.front.InterfacePackage=...
            regexprep(modelM3I.RootPackage.front.InterfacePackage,['^',qOldPkgName],qPkgName);
            t.commit();
        end


        if~strcmp(pkgTreeObj.parentDlg.dialogTag,'autosar_xmloptions_dialog')
            pkgTreeObj.parentDlg.refresh;
        end

        isValueChanged=true;
        editString=newValue;
    end
end


function CloseForBrowserCB(eventSrc,~)
    root=DAStudio.ToolRoot;
    arDialog=root.getOpenDialogs.find('dialogTag','PackageBrowser');
    for i=1:length(arDialog)
        dlgSrc=arDialog.getDialogSource();
        modelH=get_param(dlgSrc.modelName,'Handle');
        if modelH==eventSrc.Handle
            dlgSrc.delete;
            break;
        end
    end
end


function deleteTree(root)
    if isvalid(root)
        hChildren=root.getHierarchicalChildren();
        nhChildren=root.getChildren();
        for i=length(nhChildren):-1:1
            deleteTree(nhChildren(i));
        end
        for i=length(hChildren):-1:1
            deleteTree(hChildren(i));
        end
        root.delete;
    end
end



