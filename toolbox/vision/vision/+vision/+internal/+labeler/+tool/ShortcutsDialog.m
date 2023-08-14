classdef ShortcutsDialog<images.internal.app.utilities.CloseDialog




    properties
ToolType
ShortcutsTable
MainPanel
    end

    properties(Constant)
        ItemHeight=22;
        TitleColumnHeight=30;
        SectionTitleHeight=35;
    end

    properties(Dependent)
ShortcutsList
    end

    methods



        function this=ShortcutsDialog(loc,toolType,closeFcn)

            dlgTitle=vision.getMessage('vision:labeler:ViewShortcutsTitle');
            this@images.internal.app.utilities.CloseDialog(loc,dlgTitle);

            this.Size=[680,400];
            create(this);

            this.ToolType=toolType;
            this.FigureHandle.DeleteFcn=closeFcn;
            this.FigureHandle.Visible='on';

            addShortcutsPanel(this);
            addShortcuts(this);

        end




        function addShortcutsPanel(this)

            panelPos=[this.ButtonSpace,this.ButtonSize(2)+(2*this.ButtonSpace),...
            this.Size(1)-(2*this.ButtonSpace),this.Size(2)-(3*this.ButtonSpace)-this.ButtonSize(2)];
            this.MainPanel=uipanel('Parent',this.FigureHandle,...
            'Position',panelPos,...
            'FontSize',12,...
            'BorderType','none');
            this.MainPanel.Scrollable='on';

        end




        function addShortcuts(this)

            list=this.ShortcutsList;
            numSections=length(list);
            numEntries=arrayfun(@(x)size(x.data,1),list);

            for idx=1:numSections


                currentTableHeight=numEntries(numSections-idx+1)*this.ItemHeight+this.TitleColumnHeight;
                tableHeights=(idx~=1)*(sum(numEntries(numSections-idx+2:end))*this.ItemHeight+...
                (idx-1)*this.TitleColumnHeight);


                if ismac
                    componentWidth=this.MainPanel.Position(3)-(2*this.ButtonSpace);
                else
                    componentWidth=this.MainPanel.Position(3)-(2.5*this.ButtonSpace);
                end


                tablePos=[1,tableHeights+(idx-1)*this.SectionTitleHeight...
                ,componentWidth,currentTableHeight];
                addTable(this,list(end-idx+1).data,tablePos);


                tableHeights=tableHeights+currentTableHeight;
                sectionTitlePos=[5,tableHeights+(idx-1)*this.SectionTitleHeight,...
                componentWidth,this.SectionTitleHeight];
                addSectionTitle(this,list(end-idx+1).sectionTitle,sectionTitlePos);

            end


            scroll(this.MainPanel,'top');
        end


        function addSectionTitle(this,title,pos)
            uilabel('Parent',this.MainPanel,...
            'Position',pos,...
            'HorizontalAlignment','left',...
            'Text',title,...
            'FontSize',12,...
            'FontWeight','bold');
        end


        function addTable(this,data,pos)
            columnNames={getString(message('vision:labeler:Task')),...
            getString(message('vision:labeler:Action'))};
            uitable('Parent',this.MainPanel,...
            'Position',pos,...
            'FontSize',12,...
            'ColumnName',columnNames,...
            'ColumnFormat',{'char','char'},...
            'RowName',{},...
            'SelectionType','row',...
            'Data',data,...
            'ColumnWidth',{pos(3)*0.55,pos(3)*0.45-2});
        end


        function list=get.ShortcutsList(this)

            listObj=vision.internal.labeler.tool.ShortcutsList();
            list=listObj.commonShortcuts(this.ToolType);

            switch this.ToolType

            case vision.internal.toolType.ImageLabeler
                list=[list,listObj.getImageLabelerShortcuts()];


            case vision.internal.toolType.VideoLabeler
                list=[list,listObj.getVideoLabelerShortcuts()];


            case vision.internal.toolType.GroundTruthLabeler
                list=[list,listObj.getGroundTruthLabelerShortcuts()];


            case vision.internal.toolType.LidarLabeler
                list=[list,listObj.getLidarLabelerShortcuts()];
            end

        end

    end

    methods(Access=protected)

        function keyPress(this,evt)
            switch(evt.Key)
            case{'return','escape'}
                closeClicked(this);
            end
        end
    end

end