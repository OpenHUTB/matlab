classdef CostReportView<matlab.ui.internal.FigureDocument





    properties(Constant)
        Name char=getString(message('evolutions:ui:CostReport'));
        AppDelay(1,1)double{mustBeNonnegative,mustBeFinite}=2;
        Margin(1,1)double{mustBeNonnegative,mustBeFinite}=30;
    end


    properties

TotalCostView
CostPerBlockView
CostPerSubSystemView
    end

    properties(Constant)
        TotalSummaryViews(1,1)double{mustBePositive,mustBeFinite}=1;
    end

    properties(Access=?evolutions.internal.ui.widget.SummaryView)
        CurrentActiveViews(1,1)double{mustBeNonnegative,mustBeFinite}=0;
    end


    methods
        function this=CostReportView(parent,name)
            parentDocGroup=getDocGroup(parent);
            configuration.Title=strcat(name,'_Cost');
            configuration.DocumentGroupTag=parentDocGroup.Tag;
            configuration.Closable=1;
            this@matlab.ui.internal.FigureDocument(configuration);

            add(getToolGroup(parent),this);
        end

    end

    methods
        function setTitle(this,val)
            if isempty(val)
                set(this.FigureHandle,'Name',this.Name);
            else
                set(this.FigureHandle,'Name',val);
            end
        end
    end

    methods
        function createDocumentComponents(this,data)
            pause(this.AppDelay);



            this.TotalCostView.Label=uilabel(this.Figure,'Position',[20,580,250,30],...
            'Text','Total cost of the design is : ','FontSize',15);
            this.TotalCostView.Text=uitextarea(this.Figure,'Position',[300,580,250,30],...
            'Editable',0,'BackgroundColor',[0.902,0.902,0.902],'FontSize',15,'Value',num2str(data.Totalcost),...
            'HorizontalAlignment','center');
            this.CostPerBlockView=uitable(this.Figure,'Data',...
            data.costPerBlockTable,'Position',[20,360,600,200]);
            this.CostPerSubSystemView=uitable(this.Figure,'Data',...
            data.costPerSubSystemTable,'Position',[20,120,600,200]);
        end

        function layoutDocument(this)
            position=this.Figure.Position;
            position(1)=position(1)+this.Margin;
            position(2)=position(2)+this.Margin;
            position(3)=position(3)-this.Margin;
            position(4)=position(4)-this.Margin;
            this.ReportView.Position=position;
        end

    end
end


