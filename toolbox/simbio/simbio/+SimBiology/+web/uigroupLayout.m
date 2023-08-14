










classdef uigroupLayout<matlab.mixin.SetGet
    properties
        gap=[4,4];
        insets=[10,10,10,10];
        gtitle='';
        gxlabel='';
        gylabel='';
        glegendLabels={};
        glegendEntries=[];


        displayLegend=true;

    end

    properties(Dependent=true,SetAccess=private)
        gridDimensions;
    end

    properties(SetAccess=public)
        ax=[];
        f=[];
        labelAxes=[];
    end

    methods
        function this=uigroupLayout(f,ax,gax)
            this.f=f;
            this.labelAxes=gax;
            this.ax=ax;
        end

        function val=get.gridDimensions(obj)
            val=[size(obj.ax,1),size(obj.ax,2)];
        end

        function layout(this)
            if~isempty(this.labelAxes)
                set(this.labelAxes.Title,'String',this.gtitle,'Interpreter','none','Visible','on','Units','pixels');
                set(this.labelAxes.XLabel,'String',this.gxlabel,'Interpreter','none','Visible','on','Units','pixels');
                set(this.labelAxes.YLabel,'String',this.gylabel,'Interpreter','none','Visible','on','Units','pixels');
            end

            if~SimBiology.internal.plotting.sbioplot.SBioPlotObject.isFigureInApp(this.f)
                this.updateLegend();
            end
            layout(this.f,this.ax,this.labelAxes,this.insets,this.gap,this.gridDimensions);


        end


        function updateLegend(this)
            if this.displayLegend&&~isempty(this.glegendEntries)
                l=legend(this.labelAxes,this.glegendEntries,this.glegendLabels,'Location','NorthEastOutside','Interpreter','none','AutoUpdate','off','Units','pixels','Visible','on','TextColor',[0,0,0]);


                legPos=l.Position;
                figWidth=this.f.Position(3);
                figHeight=this.f.Position(4);


                innerpos=round(get(this.ax(1,1),'InnerPosition'));
                pos=get(this.ax(1,1),'OuterPosition');
                yAxesDecWidth=innerpos(1)-pos(1);

                legPos=[(figWidth-legPos(3)-this.insets(3)),legPos(2:4)];

                l.Position=legPos;
            end
        end
    end
end


function layout(f,ax,gax,insets,gap,gridDimensions)

    if(all(isgraphics(ax(:)))&&all(isgraphics(gax)))


        set(ax,'Units','pixels','Visible','on');
        set(gax,'Units','pixels','Visible','on');

        rows=gridDimensions(1);
        cols=gridDimensions(2);

        if(rows==1)&&(size(ax,1)~=1)
            ax=ax';
        end



        figPos=f.Position;
        estWidth=(figPos(3)-(insets(1)+insets(3)+gap(1)*cols))/cols;
        estHeight=(figPos(4)-(insets(2)+insets(4)+gap(2)*rows))/rows;
        for i=1:numel(ax)
            if(ax(i)~=0)
                axPos=ax(i).Position;
                outerpos=[axPos(1:2),estWidth,estHeight];

                for k=1:numel(outerpos)
                    if outerpos(k)<=0
                        outerpos(k)=1;
                    end
                end
                ax(i).OuterPosition=outerpos;
            end
        end



        topDec=zeros(size(ax));
        leftDec=zeros(size(ax));
        bottomDec=zeros(size(ax));
        rightDec=zeros(size(ax));

        for i=1:cols
            for j=1:rows
                if ax(j,i)~=0
                    innerpos=round(get(ax(j,i),'InnerPosition'));
                    pos=get(ax(j,i),'OuterPosition');

                    leftDec(j,i)=innerpos(1)-pos(1);
                    rightDec(j,i)=(pos(1)+pos(3))-(innerpos(1)+innerpos(3));
                    bottomDec(j,i)=innerpos(2)-pos(2);
                    topDec(j,i)=(pos(2)+pos(4))-(innerpos(2)+innerpos(4));
                end
            end
        end

        topDec=round(topDec);
        leftDec=round(leftDec);
        bottomDec=round(bottomDec);
        rightDec=round(rightDec);


        leftDecMax=max(leftDec,[],1);
        rightDecMax=max(rightDec,[],1);
        rowDec=sum(leftDecMax)+sum(rightDecMax)+gap(1)*(cols-1);


        bottomDecMax=max(bottomDec,[],2);
        topDecMax=max(topDec,[],2);
        colDec=sum(bottomDecMax)+sum(topDecMax)+gap(2)*(rows-1);



        [rectToFill,g]=getRectToFill(f,gax,insets);


        if~isempty(gax)
            set(gax,'Visible','on','OuterPosition',g);
            set(gax,'Visible','off');
        end


        width=floor((rectToFill(3)-rowDec)/cols);
        height=floor((rectToFill(4)-colDec)/rows);

        x=leftDecMax(1)+rectToFill(1);
        for i=1:cols
            y=rectToFill(2)+rectToFill(4)-topDecMax(1);
            for j=1:rows
                if ax(j,i)~=0
                    innerpos=[x,y-height,width,height];

                    for k=1:numel(innerpos)
                        if innerpos(k)<=0
                            innerpos(k)=1;
                        end
                    end
                    set(ax(j,i),'InnerPosition',innerpos);
                end

                if(j~=rows)
                    y=y-height-bottomDecMax(j)-gap(2)-topDecMax(j+1);
                end

                if ax(j,i)~=0
                    set(ax(j,i),'Visible','on');
                end
            end

            if(i~=cols)
                x=x+width+rightDecMax(i)+gap(1)+leftDecMax(i+1);
            end
        end

        if~isempty(gax)&&~isempty(gax.Legend)
            l=gax.Legend.Position;
            gax.Legend.Position=[l(1),handle(ax(1,1)).InnerPosition(2)+handle(ax(1,1)).InnerPosition(4)-l(4),l(3:4)];
        end
    end
end


function[p,g]=getRectToFill(f,gax,insets)

    fp=get(f,'position');
    fp=[0,0,fp(3),fp(4)];

    if~isempty(gax)&&~isempty(gax.Legend)
        l=gax.Legend.Position;
        l(3)=l(3)+insets(3);
    else
        l=[0,0,0,0];
    end

    g=fp+[insets(1),insets(2),-(l(3)+insets(1)+insets(3)),-(insets(2)+insets(4))];
    p=g;


    if~isempty(gax)
        p(4)=p(4)-gax.Title.Extent(4);
        p(2)=p(2)+gax.XLabel.Extent(4);
        p(4)=p(4)-gax.XLabel.Extent(4);
        p(1)=p(1)+gax.YLabel.Extent(3);
        p(3)=p(3)-gax.YLabel.Extent(3);
    end

end

