





classdef LayoutSection<vision.internal.uitools.NewToolStripSection

    properties
LayoutButton
DefaultLayout
ShowOverview
    end

    methods
        function this=LayoutSection()
            this.createSection();
            this.layoutSection();
        end
    end

    methods(Access=protected)

        function createSection(this)

            layoutSectionTitle=getString(message('vision:labeler:Layout'));
            layoutSectionTag='sectionLayout';

            this.Section=matlab.ui.internal.toolstrip.Section(layoutSectionTitle);
            this.Section.Tag=layoutSectionTag;
        end

        function layoutSection(this)

            col=this.addColumn();

            icon=matlab.ui.internal.toolstrip.Icon.LAYOUT_24;
            titleID='vision:labeler:Layout';
            tag='btnDefaultLayout';
            this.LayoutButton=this.createSplitButton(icon,titleID,tag);
            this.LayoutButton.Enabled=true;
            toolTipID='vision:labeler:DefaultLayoutToolTip';
            this.setToolTipText(this.LayoutButton,toolTipID);


            defaultTitleID=vision.getMessage('vision:labeler:DefaultLayoutItem');
            defaultIcon=matlab.ui.internal.toolstrip.Icon.LAYOUT_16;
            this.DefaultLayout=matlab.ui.internal.toolstrip.ListItem(defaultTitleID,defaultIcon);
            this.DefaultLayout.Tag='itemDefaultLayout';
            this.DefaultLayout.ShowDescription=false;
            this.DefaultLayout.Enabled=true;


            showOverviewTitleID=vision.getMessage('vision:labeler:OverviewItem');
            this.ShowOverview=matlab.ui.internal.toolstrip.ListItemWithCheckBox(showOverviewTitleID);
            this.ShowOverview.Value=false;
            this.ShowOverview.Tag='itemShowOverview';
            this.ShowOverview.ShowDescription=false;
            this.ShowOverview.Enabled=false;


            layoutPopup=matlab.ui.internal.toolstrip.PopupList();

            layoutPopup.add(this.DefaultLayout);

            showHeader=matlab.ui.internal.toolstrip.PopupListHeader(vision.getMessage('vision:labeler:Show'));
            layoutPopup.add(showHeader);
            layoutPopup.add(this.ShowOverview);

            this.LayoutButton.Popup=layoutPopup;

            col.add(this.LayoutButton);

        end

    end

end