function radiationpatternuv(MagE1,theta1,phi1,frequency,plottype,...
    slice,slicestyle,optype)







    if~isempty(get(groot,'CurrentFigure'))
        clf(gcf);
    end
    if strcmpi(plottype,'3D')
        [u,v]=meshgrid(phi1,theta1);
        MagE=nan(size(u));
        index=find(hypot(u,v)<=1);
        MagE(index)=MagE1;%#ok<FNDSB>
        haxRadPat=axes('Parent',gcf,'Position',[0.35,0.2,0.6,0.7]);
        surfHdl=surf(haxRadPat,u,v,MagE,'FaceColor','interp');
        set(surfHdl,'LineStyle','none','FaceAlpha',1.0);
        colormap(jet(256));
        zlabel(em.FieldAnalysisWithFeed.getfieldlabels(optype))
        xlabel('u')
        ylabel('v')
        grid on;
        hold off;
        hfig=ancestor(haxRadPat,'figure');
    elseif strcmpi(plottype,'2D')&&strcmpi(slicestyle,'overlay')
        if isscalar(frequency)
            [u,v]=meshgrid(phi1,theta1);
            if isscalar(phi1)
                xvalnew=v;
                xvallabel='v';
            else
                xvalnew=u;
                xvallabel='u';
            end
            MagE=nan(size(u));
            index=find(hypot(u,v)<=1);
            MagE(index)=MagE1;%#ok<FNDSB>
        else
            [u,v]=meshgrid(phi1,theta1);
            if isscalar(phi1)
                xvalnew=repmat(v,1,numel(frequency));
                xvallabel='v';
            else
                xvalnew=repmat(u,1,numel(frequency));
                xvallabel='u';
            end
            MagE=nan(length(u),length(frequency));
            index=find(hypot(u,v)<=1);
            temp=nan(length(u),1);
            for m=1:length(frequency)
                temp(index)=MagE1(m,:).';%#ok<FNDSB>
                MagE(:,m)=temp;
            end
        end

        numberofdatapoints=size(MagE,1);
        colorvec=colorvector(numberofdatapoints);
        haxRadPat=axes('Parent',gcf,'Position',[0.3,0.1,0.68,0.8]);


        hb=plot(haxRadPat,xvalnew,MagE);
        set(hb,'LineWidth',2,'Color',colorvec(1,:));


        ylabel(em.FieldAnalysisWithFeed.getfieldlabels(optype));
        xlabel(xvallabel);
        grid on;
        hold off;
        hfig=ancestor(hb,{'figure','axes'},'toplevel');
    elseif strcmpi(plottype,'2D')&&strcmpi(slicestyle,'waterfall')
        [u,v]=meshgrid(phi1,theta1);
        if isscalar(phi1)
            xvalnew=v;
            xvallabel='v';
        else
            xvalnew=u;
            xvallabel='u';
        end
        MagE=nan(length(u),length(frequency));
        index=find(hypot(u,v)<=1);
        temp=nan(length(u),1);
        for m=1:length(frequency)
            temp(index)=MagE1(m,:).';%#ok<FNDSB>
            MagE(:,m)=temp;
        end
        haxRadPat=axes('Parent',gcf,'Position',[0.28,0.24,0.7,0.7]);
        hb=waterfall(haxRadPat,xvalnew,frequency,MagE.');
        zlabel(em.FieldAnalysisWithFeed.getfieldlabels(optype));
        xlabel(xvallabel)
        ylabel('Frequency (Hz)')
        grid on;
        hold off;
        hfig=ancestor(hb,{'figure','axes'},'toplevel');
    end

    set(hfig,'NextPlot','replace');
    if antennashared.internal.figureForwardState(hfig)
        shg;
    end
end


function cv=colorvector(num)
    cv=zeros(num,3);
    cv(1,:)=[1,0,0];
    cv(2,:)=[0,0,1];
    cv(3,:)=[0,1,0];
    cv(4,:)=[1,1,0];
    cv(5,:)=[1,0,1];
    cv(6,:)=[0,0,0];
    cv(7,:)=[0,1,1];
    cv(8:num,:)=rand([num-7,3]);
end
