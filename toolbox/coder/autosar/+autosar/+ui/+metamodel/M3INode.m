




classdef M3INode<handle
    properties
        Name;
        HierarchicalChildren;
        Children;
        Icon;
        ParentM3I;


        IsSharedAUTOSARDictNode(1,1)logical=false;
    end

    properties(Constant,Access=private)
        IsAUTOSARLicensed=autosar.api.Utils.autosarlicensed();
    end

    properties(Dependent)



        M3iObject;
    end

    methods
        function obj=M3INode(name,parent)
            obj.Name=name;
            obj.HierarchicalChildren=[];
            obj.Children=[];
            obj.ParentM3I=parent;
            if autosar.ui.metamodel.PackageString.IconMap.isKey(obj.Name)
                obj.Icon=autosar.ui.metamodel.PackageString.IconMap(obj.Name);
            elseif obj.isDictionaryNode()
                obj.Icon=autosar.ui.metamodel.PackageString.IconMap('Domain');
            else
                obj.Icon=autosar.ui.metamodel.PackageString.IconMap('MatrixValueSpecification');
            end
        end

        function ret=get.M3iObject(obj)
            if obj.isDictionaryNode()
                compM3IModel=obj.ParentM3I.M3iObject;
                assert(Simulink.AutosarDictionary.ModelRegistry.hasReferencedModels(compM3IModel),...
                'Model should reference interface dictionary');
                ret=autosar.dictionary.Utils.getUniqueReferencedModel(compM3IModel);
            else
                ret=[];
            end
        end

        function set.M3iObject(~,~)
            assert(false,'setting property M3iObject is not allowed.');
        end

        function label=getDisplayLabel(obj)
            label=obj.Name;
        end

        function Children=getHierarchicalChildren(obj)
            Children=obj.HierarchicalChildren;
        end

        function Children=getChildren(obj)
            Children=obj.Children;
        end

        function b=isHierarchical(~)
            b=true;
        end

        function b=isHierarchyReadonly(obj)
            b=~obj.IsAUTOSARLicensed;
        end

        function fname=getDisplayIcon(obj)
            fname=obj.Icon;
        end

        function addChild(obj,ch)







            if~isempty(obj.Children)
                obj.Children(end+1)=ch;
            else
                obj.Children=[obj.Children,ch];
            end
        end

        function addChildAtIndex(obj,ch,index)
            len=length(obj.Children);
            validIndex=0;
            for ii=1:len
                if isvalid(obj.Children(ii))
                    validIndex=validIndex+1;
                end
                if index==validIndex
                    break;
                end
            end
            obj.Children=[obj.Children(1:ii-1),ch,obj.Children(ii:len)];
        end

        function addHierarchicalChild(obj,ch)







            if~isempty(obj.HierarchicalChildren)
                obj.HierarchicalChildren(end+1)=ch;
            else
                obj.HierarchicalChildren=[obj.HierarchicalChildren,ch];
            end
        end

        function removeChild(obj,index)
            obj.Children(index).delete;
            obj.Children(index)=[];
        end

        function removeHierarchicalChild(obj,index)
            obj.HierarchicalChildren(index).delete;
            obj.HierarchicalChildren(index)=[];
        end

        function props=getARExplorerProperties(obj)
            props={autosar.ui.metamodel.PackageString.Name};
            if obj.isDictionaryNode()
                props=[];
                return
            end
            if~isempty(obj.Children)
                ch=[];
                for i=1:length(obj.Children)
                    if obj.Children(i).isvalid
                        ch=obj.Children(i);
                        break;
                    end
                end
                if~isempty(ch)
                    props=ch.getChildProperties();
                end
            end
        end

        function propValue=getPropValue(~,~)
            propValue='';
        end

        function propValue=isValidProperty(~,~)
            propValue=true;
        end


        function readOnly=isReadOnly(obj)
            readOnly=false;
            if~isempty(obj.M3iObject)&&obj.M3iObject.isvalid()
                readOnly=autosar.ui.metamodel.M3INode.isUINodeReadOnly(obj.M3iObject);
            elseif~isempty(obj.ParentM3I)

                if isa(obj.ParentM3I,'autosar.ui.metamodel.M3ITerminalNode')
                    readOnly=obj.ParentM3I.isReadOnly();
                elseif isa(obj.ParentM3I,'autosar.ui.metamodel.M3INode')

                    readOnly=obj.ParentM3I.IsSharedAUTOSARDictNode;
                else
                    readOnly=autosar.ui.metamodel.M3INode.isUINodeReadOnly(obj.ParentM3I);
                end
            end
        end

        function propValue=isReadonlyProperty(~,~)
            propValue=false;
        end
        function propValue=isEditableProperty(~,~)
            propValue=false;
        end

        function ret=getM3iObject(obj)
            if obj.isDictionaryNode()
                ret=obj.M3iObject;
            else
                ret=[];
            end
        end
        function dlgstruct=getDialogSchema(obj,~)
            dlgstruct=[];
            if strcmp(obj.Name,autosar.ui.metamodel.PackageString.Preferences)
                assert(obj.ParentM3I.M3iObject.RootPackage.size==1);
                arRoot=obj.ParentM3I.M3iObject.RootPackage.front();
                dlgstruct=autosar.ui.utils.getPreferencesDlg(arRoot);
            elseif obj.isDictionaryNode()
                dictFile=obj.Name;

                browser.Type='textbrowser';
                browser.Tag='browser';
                browser.Text=['<font size="5"><b>'...
                ,'Shared AUTOSAR Dictionary:','</b> '...
                ,dictFile,'<br/><br/><b>'...
                ,'</font>'];
                browser.RowSpan=[1,1];
                browser.ColSpan=[1,25];

                spacer.Type='text';
                spacer.Tag='spacer';
                spacer.Name='';
                spacer.RowSpan=[2,2];
                spacer.ColSpan=[1,25];
                spacer.Visible=1;

                rowIdx=1;
                expandTip.Type='text';
                expandTip.Tag='msgItem1';
                expandTip.Name=DAStudio.message('autosarstandard:ui:uiConfigureSharedDictionaryTip',dictFile);
                expandTip.RowSpan=[rowIdx,rowIdx];
                expandTip.ColSpan=[1,32];

                rowIdx=rowIdx+1;

                openItfDictTipText.Type='text';
                openItfDictTipText.Tag='openItfDictTipText';
                openItfDictTipText.Name=DAStudio.message('autosarstandard:interface_dictionary:openItfDictTip');
                openItfDictTipText.RowSpan=[rowIdx,rowIdx];
                openItfDictTipText.ColSpan=[1,2];

                openItfDictTipLink.Type='hyperlink';
                openItfDictTipLink.Tag='openItfDictTipLink';
                openItfDictTipLink.Name=obj.Name;
                openItfDictTipLink.RowSpan=[rowIdx,rowIdx];
                openItfDictTipLink.ColSpan=[3,3];
                openItfDictTipLink.MatlabMethod='sl.interface.dictionaryApp.StudioApp.open';
                dictFullPath=Simulink.AutosarDictionary.ModelRegistry.getDDFileSpecForM3IModel(obj.M3iObject);
                openItfDictTipLink.MatlabArgs={dictFullPath};

                grpControl.Name=DAStudio.message('RTW:autosar:uiTips');
                grpControl.Type='group';
                grpControl.LayoutGrid=[3,25];
                grpControl.RowSpan=[4,6];
                grpControl.ColSpan=[1,25];
                grpControl.RowStretch=[0,0,1];
                grpControl.ColStretch=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1];
                grpControl.Items={expandTip,openItfDictTipText,openItfDictTipLink};

                dlgstruct.HelpMethod='helpview';
                dlgstruct.HelpArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props'};
                dlgstruct.StandaloneButtonSet={''};
                dlgstruct.EmbeddedButtonSet={'Help'};
                dlgstruct.ExplicitShow=true;
                dlgstruct.DialogTitle='';
                dlgstruct.Items={browser,spacer,grpControl};
                dlgstruct.LayoutGrid=[20,10];
                dlgstruct.RowStretch=[0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];

                dlgstruct.DialogTag='autosar_shared_dictionary_dialog';
            end
        end

        function ret=isDictionaryNode(obj)
            ret=contains(obj.Name,'.sldd');
        end
    end

    methods(Static)
        function isReadOnly=isUINodeReadOnly(m3iObj)
            [isSharedM3iModel,dictFile]=autosar.dictionary.Utils.isSharedM3IModel(m3iObj.rootModel);
            isReadOnly=autosar.api.getAUTOSARProperties.isReadOnly(m3iObj)||...
            (isSharedM3iModel&&...
            ~sl.interface.dict.api.isInterfaceDictionary(dictFile));
        end
    end
end



