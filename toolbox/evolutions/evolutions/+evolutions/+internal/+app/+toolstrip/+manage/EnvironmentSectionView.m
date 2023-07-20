classdef EnvironmentSectionView<evolutions.internal.ui.tools.ToolstripSection







    properties(Constant)
        Title=getString(message('evolutions:ui:EnvironmentSection'));
        Name='EnvironmentViewSection';
    end

    properties(SetAccess=protected)

LayoutButton
LayoutPopupList
LayoutIcon
DefaultLayoutItem
OrganizeLayoutItem
SaveLayoutItem
        LayoutUpToDate=false;
    end


    events(NotifyAccess=?protected,ListenAccess=?evolutions.internal.app.toolstrip.manage...
        .EnvironmentSectionController)


ChangeLayoutButtonClick
SaveLayoutButtonClick
DefaultLayoutButtonClick
OrganizeLayoutButtonClick
    end


    methods
        function this=EnvironmentSectionView(parent)
            this@evolutions.internal.ui.tools.ToolstripSection(parent);
        end

        function enableWidget(this,~,widgetName)

            assert(strcmp(widgetName,'Layout'));
            this.LayoutButton.Enabled=1;
        end

        function popup=updateLayoutPopup(this,layoutList)
            import matlab.ui.internal.toolstrip.*
            import matlab.ui.internal.toolstrip.Icon.*;

            icon=LAYOUT_16;
            if~this.LayoutUpToDate
                popup=PopupList();
                header=PopupListHeader(getString(message('evolutions:ui:SelectLayoutHeader')));
                popup.add(header);


                text=getString(message('evolutions:ui:DefaultLayoutItem'));
                tag='itemDefaultLayout';

                obj.DefaultLayoutItem=ListItem(text,icon);
                obj.DefaultLayoutItem.Tag=tag;
                obj.DefaultLayoutItem.ItemPushedFcn=@(~,~)notify(this,'DefaultLayoutButtonClick');
                popup.add(obj.DefaultLayoutItem);

                for idx=1:numel(layoutList)
                    [~,itemName]=fileparts(layoutList{idx});
                    listItem=ListItem(itemName,icon);
                    listItem.Description=layoutList{idx};
                    listItem.ShowDescription=false;
                    listItem.ItemPushedFcn=@this.changeLayoutAction;
                    popup.add(listItem);
                end

                header=PopupListHeader(getString(message('evolutions:ui:ManageLayoutHeader')));
                popup.add(header);
                text=getString(message('evolutions:ui:SaveLayoutPopupButton'));
                tag='itemSaveLayout';
                this.SaveLayoutItem=ListItem(text);
                this.SaveLayoutItem.Tag=tag;
                this.SaveLayoutItem.ItemPushedFcn=@(~,~)notify(this,'SaveLayoutButtonClick');
                popup.add(this.SaveLayoutItem);

                text=getString(message('evolutions:ui:OrganizeLayoutPopupButton'));
                tag='itemOrgLayout';
                this.OrganizeLayoutItem=ListItem(text);
                this.OrganizeLayoutItem.Tag=tag;
                this.OrganizeLayoutItem.ItemPushedFcn=@(~,~)notify(this,'OrganizeLayoutButtonClick');
                this.OrganizeLayoutItem.Enabled=~isempty(layoutList);
                popup.add(this.OrganizeLayoutItem);

                this.LayoutPopupList=popup;
                this.LayoutUpToDate=true;
            else
                popup=this.LayoutPopupList;
            end
        end


        function setLayoutOutOfDate(this)
            this.LayoutUpToDate=false;
        end
    end

    methods(Access=protected)
        function createSectionComponents(this)
            createLayoutButtonGroup(this);
        end

        function layoutSection(this)
            add(this.Section.addColumn(),this.LayoutButton);
        end

        function createLayoutButtonGroup(this)
            import matlab.ui.internal.toolstrip.Icon.*;

            this.LayoutIcon=LAYOUT_24;
            this.LayoutButton=this.createSplitButton(...
            getString(message('evolutions:ui:LayoutButton')),...
            this.LayoutIcon,createChildTag(this,'Layout'),...
            getString(message('evolutions:ui:LayoutButtonToolTip')));
        end

        function changeLayoutAction(this,src,~)
            Data.Name=src.Description;
            notify(this,'ChangeLayoutButtonClick',...
            evolutions.internal.ui.GenericEventData(Data));
        end
    end
end
