





classdef LayoutSection<vision.internal.uitools.NewToolStripSection

    properties
LayoutRepo

LayoutButton
DefaultLayoutItem
SavedLayoutItem
OrganizeLayoutItem
VisualSummaryDockItem
LayoutItems


SignalListDropDownButton
SignalList
SignalPopupList
        SignalListModified=false
    end

    properties(Access=private)
ShippedLayoutsDir
SavedLayoutsDir
IsRefreshed
LayoutPopup
SavedLayouts
IsVideoLabeler


ContainerObj
    end

    properties
MultisignalButton
MultisignalGrid
    end

    properties(SetAccess=private,Dependent)
VisualSumItemVisibility
    end

    properties(Constant)
        IconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons');
    end

    methods
        function this=LayoutSection(tool)

            this.createSection();

            this.IsVideoLabeler=tool.IsVideoLabeler;

            this.SignalList=struct('signalName',{},...
            'isVisible',{});

            this.createMultisignalLayout();

            this.ContainerObj=tool.Tool;
        end

        function popup=getLayoutPopup(this)
            popup=this.LayoutPopup;
        end

        function refreshLayoutPopup(this)

            import matlab.ui.internal.toolstrip.Icon.*;
            import matlab.ui.internal.toolstrip.*;
            popup=PopupList();

            this.LayoutItems={};
            this.LayoutRepo=[];
            this.SavedLayouts=[];

            selectLayoutHeader=PopupListHeader(vision.getMessage('vision:labeler:SelectLayout'));
            popup.add(selectLayoutHeader);


            text=vision.getMessage('vision:labeler:DefaultLayoutItem');
            tag='itemDefaultLayout';
            icon=LAYOUT_16;

            this.DefaultLayoutItem=ListItem(text,icon);
            this.DefaultLayoutItem.Tag=tag;
            this.DefaultLayoutItem.ShowDescription=false;
            popup.add(this.DefaultLayoutItem);


            this.ShippedLayoutsDir=fullfile(matlabroot,'toolbox','driving',...
            'driving','+driving','+internal','+videoLabeler','+tool','+layouts');
            addLayoutsFromDir(this,this.ShippedLayoutsDir,popup);


            if this.IsVideoLabeler
                this.SavedLayoutsDir=fullfile(prefdir,'vl','layouts');
            else
                this.SavedLayoutsDir=fullfile(prefdir,'gtl','layouts');
            end
            addLayoutsFromDir(this,this.SavedLayoutsDir,popup);


            text=vision.getMessage('vision:labeler:SaveLayout');
            tag='itemSaveLayout';
            this.SavedLayoutItem=ListItem(text);
            this.SavedLayoutItem.Tag=tag;
            this.SavedLayoutItem.ShowDescription=false;
            popup.add(this.SavedLayoutItem);


            text=vision.getMessage('vision:labeler:OrganizeLayout');
            tag='itemOrgLayout';
            this.OrganizeLayoutItem=ListItem(text);
            this.OrganizeLayoutItem.Tag=tag;
            this.OrganizeLayoutItem.ShowDescription=false;
            this.OrganizeLayoutItem.Enabled=~isempty(this.SavedLayouts);
            this.OrganizeLayoutItem.ItemPushedFcn=@(es,ed)organizeLayout(this);
            popup.add(this.OrganizeLayoutItem);


            dockSectionHeader=PopupListHeader(vision.getMessage('vision:labeler:Dock'));
            popup.add(dockSectionHeader);


            text=vision.getMessage('vision:labeler:DockVisualSummary');
            tag='itemDockVisualSummary';
            visibility=this.VisualSumItemVisibility;
            this.VisualSummaryDockItem=ListItemWithCheckBox(text);
            this.VisualSummaryDockItem.Tag=tag;
            this.VisualSummaryDockItem.ShowDescription=false;
            this.VisualSummaryDockItem.Value=false;
            this.VisualSummaryDockItem.Enabled=visibility;
            popup.add(this.VisualSummaryDockItem);

            this.LayoutPopup=popup;
            setIsRefreshed(this,true);
        end

        function TF=isPopupRefreshed(this)
            TF=this.IsRefreshed;
        end

        function setIsRefreshed(this,flag)
            this.IsRefreshed=flag;
        end

        function visibility=get.VisualSumItemVisibility(this)
            if~isempty(this.VisualSummaryDockItem)
                visibility=this.VisualSummaryDockItem.Enabled;
            else
                visibility=false;
            end
        end

        function disableMultisignalButton(this)
            this.MultisignalButton.Enabled=false;
        end

        function enableMultisignalButton(this)
            this.MultisignalButton.Enabled=true;
        end

        function enableSignalViewDropDownMenu(this,isEnabled)
            this.SignalListDropDownButton.Enabled=isEnabled;
        end
    end

    methods(Access=protected)

        function addLayoutButton(this)

            import matlab.ui.internal.toolstrip.Icon.*;

            icon=LAYOUT_16;
            titleID='vision:labeler:Layout';
            tag='splitBtnLayout';
            this.LayoutButton=this.createSplitButton(icon,titleID,tag);

            this.LayoutButton.Enabled=true;
            toolTipID='vision:labeler:LayoutToolTip';
            this.setToolTipText(this.LayoutButton,toolTipID);
        end

        function addSignalListDropDownButton(this)
            import matlab.ui.internal.toolstrip.Icon.*;

            icon=fullfile(this.IconPath,'ViewSignals_16px_091319.png');
            titleId='vision:labeler:SignalViewList';
            tag='SignalListDropDownButton';
            this.SignalListDropDownButton=this.createDropDownButton(icon,titleId,tag);

            this.SignalListDropDownButton.Enabled=false;
            toolTipID='vision:labeler:SignalViewListToolTip';
            this.setToolTipText(this.SignalListDropDownButton,toolTipID);
        end

        function createSection(this)

            layoutSectionTitle=getString(message('vision:labeler:LayoutSection'));
            layoutSectionTag='sectionLayout';

            this.Section=matlab.ui.internal.toolstrip.Section(layoutSectionTitle);
            this.Section.Tag=layoutSectionTag;
        end

        function createLayout(~)


        end
    end

    methods(Access=protected)
        function createMultisignalLayout(this)
            if~this.IsVideoLabeler
                addMultiSignalGridButton(this);
                addSignalListDropDownButton(this);
                addLayoutButton(this);
                layoutCol=this.addColumn();
                layoutCol.add(this.LayoutButton);
                layoutCol.add(this.MultisignalButton);
                layoutCol.add(this.SignalListDropDownButton);

            else
                layoutCol=this.addColumn();
                addLayoutButton(this);
                layoutCol.add(this.LayoutButton);
            end
            refreshLayoutPopup(this);
        end

        function addLayoutsFromDir(this,dirName,popup)
            if useAppContainer()
                fileExt='json';
            else
                fileExt='xml';
            end
            wildCard=['*.',fileExt];

            folderList=dir(fullfile(dirName,wildCard));

            import matlab.ui.internal.toolstrip.Icon.*;
            import matlab.ui.internal.toolstrip.*;
            icon=LAYOUT_16;

            if~isempty(folderList)
                fileNames={folderList.name}';

                nonHiddenFiles=cellfun(@(x)~strcmp(x(1),'.'),fileNames);
                layoutFileNames=fileNames(nonHiddenFiles);

                for i=1:numel(layoutFileNames)
                    [~,layoutFileName,~]=fileparts(layoutFileNames{i});
                    item=ListItem(layoutFileName,icon);
                    item.Tag=layoutFileName;
                    item.ShowDescription=false;
                    this.LayoutItems{end+1}=item;
                    popup.add(this.LayoutItems{end});
                end

                fullFileName=fullfile(dirName,layoutFileNames);
                this.LayoutRepo=[this.LayoutRepo;fullFileName];

                if strcmpi(dirName,this.SavedLayoutsDir)
                    this.SavedLayouts=[this.SavedLayouts;fullFileName];
                end
            end
        end

        function organizeLayout(this)

            if~isempty(this.SavedLayouts)
                dlg=vision.internal.videoLabeler.tool.OrganizeLayoutDlg(this.ContainerObj,this.SavedLayouts);
                wait(dlg);
                if getRefreshFlag(dlg)
                    refreshLayoutPopup(this);
                    setRefreshFlag(dlg,false);
                end
            end
        end

        function addMultiSignalGridButton(this)

            icon=fullfile(this.IconPath,'SignalGrid_16.png');
            titleID='vision:labeler:MultisignalGridSelection';
            tag='btnMultiSignal';
            toolTipID='vision:labeler:MultisignalGridSelectionToolTip';
            if~useAppContainer()
                this.MultisignalButton=this.createButton(icon,titleID,tag);
                this.MultisignalButton.Enabled=false;
                this.setToolTipText(this.MultisignalButton,toolTipID);
            else
                this.MultisignalButton=matlab.ui.internal.toolstrip.GridPickerButton(...
                vision.getMessage(titleID),icon,3,3);
                this.MultisignalButton.Text=vision.getMessage(titleID);
                this.MultisignalButton.Description=vision.getMessage(toolTipID);
                this.MultisignalButton.Icon=icon;
                this.MultisignalButton.Tag=tag;
            end

        end
    end

end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('useAppContainer');
end
