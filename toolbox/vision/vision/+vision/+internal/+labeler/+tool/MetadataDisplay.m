


classdef MetadataDisplay<vision.internal.uitools.AppFig

    properties
Table
ColumnNames
CurrentNumLevels
CurrentLevelData
CurrentSizeData
    end

    methods
        function this=MetadataDisplay(hFig)

            this=this@vision.internal.uitools.AppFig(hFig,'Metadata',true);

            this.Fig.SizeChangedFcn=@(~,~)reactToFigureResize(this);
            this.ColumnNames={'Level','Size'};
            this.Table=uitable('Parent',this.Fig,...
            'Position',[10,10,10,10],...
            'ColumnName',this.ColumnNames,...
            'RowName',{},...
            'RowStriping','off',...
            'HandleVisibility','off',...
            'Tag','MetadataTable',...
            'Visible','on');
        end


        function this=updateMetadataProperties(this,resLevelSizes)
            this.CurrentNumLevels=size(resLevelSizes,1);
            this.CurrentLevelData=1:this.CurrentNumLevels;
            this.CurrentSizeData=resLevelSizes;

            updateTableData(this);
        end

        function reactToFigureResize(this)
            figWidth=this.Fig.Position(3);
            figHeight=this.Fig.Position(4);

            this.Table.Position(3)=figWidth-20;
            this.Table.Position(4)=figHeight-20;
            this.Table.ColumnWidth={floor((figWidth-20)/2),floor((figWidth-20)/2)};
            updateTableData(this);
        end

        function updateTableData(this)
            tableData=cell(this.CurrentNumLevels,2);


            for id=1:this.CurrentNumLevels
                levelString=num2str(this.CurrentLevelData(id));

                sizeString=[num2str(this.CurrentSizeData(id,1)),'-by-',num2str(this.CurrentSizeData(id,2))];


                tableData(id,:)={levelString,sizeString};
            end

            this.Table.Data=tableData;
        end

        function reset(this)
            this.CurrentNumLevels=[];
            this.CurrentLevelData=[];
            this.CurrentSizeData=[];
        end

    end
end
