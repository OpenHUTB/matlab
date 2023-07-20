classdef Results<matlabshared.application.Component&...
    matlabshared.application.UITools




    properties
        ShowUplinkTable=true;
        ShowDownlinkTable=true;
    end

    properties(Hidden)
hUplink
hDownlink
hShowUplinkTable
hShowDownlinkTable

        hUplinkTable;
        hDownlinkTable;
    end

    properties(SetAccess=protected,Hidden)
        Layout;
    end

    methods
        function this=Results(varargin)
            this@matlabshared.application.Component(varargin{:});
            update(this);
        end

        function name=getName(~)
            name=getString(message('comm_demos:LinkBudgetApp:Results'));
        end

        function tag=getTag(~)
            tag='results';
        end

        function update(this)
            model=this.Application.DataModel;
            ids=getPropertyNames(model.UplinkResults);
            nIds=numel(ids);
            data=cell(nIds,2);
            for indx=1:nIds
                data(indx,1:2)={getString(message(['comm_demos:LinkBudgetApp:',ids{indx}])),...
                sprintf('%.2f',model.UplinkResults.(ids{indx}))};
            end
            this.hUplinkTable.Data=data;

            ids=getPropertyNames(model.DownlinkResults);
            nIds=numel(ids);
            data=cell(nIds,2);
            for indx=1:nIds
                data(indx,1:2)={getString(message(['comm_demos:LinkBudgetApp:',ids{indx}])),...
                sprintf('%.2f',model.DownlinkResults.(ids{indx}))};
            end
            this.hDownlinkTable.Data=data;
        end
    end

    methods(Access=protected)
        function hFig=createFigure(this,varargin)
            hFig=createFigure@matlabshared.application.Component(this,varargin{:});

            createSegmentPanel(this,hFig,'UplinkTable');
            createSegmentPanel(this,hFig,'DownlinkTable');

            layout=matlabshared.application.layout.ScrollableGridBagLayout(hFig,...
            'VerticalWeights',[0,0,0,1],...
            'VerticalGap',3,...
            'HorizontalGap',3);

            labelProps1={'Fill','Horizontal','TopInset',3,'MinimumHeight',17};
            labelProps2={'LeftInset',10,'RightInset',10,'Fill','Horizontal',...
            'TopInset',3,'MinimumHeight',360,'MinimumWidth',280};
            add(layout,this.hShowUplinkTable,1,1,labelProps1{:});
            add(layout,this.hUplinkTable,2,1,labelProps2{:});
            add(layout,this.hShowDownlinkTable,3,1,labelProps1{:},'Anchor','NorthWest');
            add(layout,this.hDownlinkTable,4,1,labelProps2{:},'Anchor','NorthWest');

            this.Layout=layout;
        end

        function createSegmentPanel(this,hFig,type)
            createToggle(this,hFig,['Show',type]);
            colWidth1=0.8*250;
            colWidth2=0.8*90;
            this.(['h',type])=uitable('Parent',hFig,...
            'tag',lower(type),...
            'ColumnName',{},...
            'ColumnWidth',{colWidth1,colWidth2},...
            'ColumnFormat',{'char','numeric'},...
            'RowName',{});
        end

        function str=getLabelString(~,str)

            if strncmp(str,'UplinkLink',10)
                str=str(11:end);
            elseif strncmp(str,'TxEarth',7)
                str=str(8:end);
            elseif strncmp(str,'RxSatellite',11)
                str=str(12:end);
            elseif strncmp(str,'UplinkPropagation',17)
                str=str(18:end);
            elseif strncmp(str,'Show',4)
                str=str(5:end);
            end
            str=[getString(message(['comm_demos:LinkBudgetApp:',str])),':'];
        end
    end

    methods(Hidden)
        function updateLayout(this)
            layout=this.Layout;
            nextRow=1;
            nextRow=insertPanel(this,layout,'UplinkTable',nextRow+1);
            nextRow=insertPanel(this,layout,'DownlinkTable',nextRow+1);
            layout.VerticalWeights=[zeros(nextRow-2,1);1];
            clean(layout);
        end
    end
end


