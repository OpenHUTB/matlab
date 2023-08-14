function plottype=radiationpatternrect(MagE1,theta1,phi1,frequency,plottype,...
    slice,slicestyle,optype)







    if~isempty(get(groot,'CurrentFigure'))
        clf(gcf);
    end
    if strcmpi(plottype,'3D')
        [theta,phi]=meshgrid(theta1,phi1);
        MagE=reshape(MagE1,length(phi1),length(theta1));
        X=90-theta;
        antennashared.internal.RectangularPlot3D(X,phi,MagE);
        zlabel(em.FieldAnalysisWithFeed.getfieldlabels(optype))
        xlabel('Elevation (degree)')
        ylabel('Azimuth (degree)')
        hfig=gcf;
    elseif strcmpi(plottype,'2D')&&isscalar(theta1)&&isscalar(phi1)&&~isscalar(frequency)
        freq=unique(frequency,'stable');
        [freqval,~,U]=engunits(freq);
        haxRadPat=axes('Parent',gcf,'Position',[0.32,0.1,0.66,0.8]);
        plot(haxRadPat,freqval,MagE1,'b','LineWidth',2);
        grid on;
        [label,units]=em.FieldAnalysisWithFeed.getfieldlabels(optype);
        ylabel([label,'(',units,')']);
        xlabel(['Frequency (',U,'Hz)']);
        hfig=gcf;
        plottype='';
    elseif strcmpi(plottype,'2D')&&strcmpi(slicestyle,'overlay')

        [MagEnew,xvalnew,str]=antennashared.internal.radpattern2Ddata(MagE1,...
        phi1,theta1,frequency,slice);

        numberofdatapoints=size(MagEnew,2);
        colorvec=colorvector(numberofdatapoints);
        haxRadPat=axes('Parent',gcf,'Position',[0.32,0.1,0.66,0.8]);

        for m=1:numberofdatapoints
            hb=plot(haxRadPat,xvalnew(:,m),MagEnew(:,m));
            set(hb,'LineWidth',2,'Color',colorvec(m,:));
            hold on;
        end
        if numberofdatapoints>1
            legend(str);legend('Location','Best');
        end
        ylabel(em.FieldAnalysisWithFeed.getfieldlabels(optype))
        xlabel('Angle (degree)')
        grid on;
        hold off;
        hfig=ancestor(hb,{'figure','axes'},'toplevel');

    elseif strcmpi(plottype,'2D')&&strcmpi(slicestyle,'waterfall')
        if strcmpi(slice,'frequency')
            if isscalar(theta1)
                [freq,angle]=meshgrid(frequency,phi1);
                anglabel='Azimuth (degrees)';
            else
                [freq,angle]=meshgrid(frequency,90-theta1);
                anglabel='Elevation (degrees)';
            end
            MagE=MagE1.';
            haxRadPat=axes('Parent',gcf,'Position',[0.35,0.2,0.6,0.7]);
            [freqval,~,U]=engunits(freq);
            hb=waterfall(haxRadPat,angle.',freqval.',MagE.');
            zlabel(em.FieldAnalysisWithFeed.getfieldlabels(optype))
            xlabel(anglabel)
            ylabel(['Frequency (',U,'Hz)']);
            grid on;
            hold off;
            hfig=ancestor(hb,{'figure','axes'},'toplevel');
        else
            [theta,phi]=meshgrid(theta1,phi1);
            MagE=reshape(MagE1,length(phi1),length(theta1));
            haxRadPat=axes('Parent',gcf,'Position',[0.35,0.2,0.6,0.7]);
            hb=waterfall(haxRadPat,90-theta.',phi.',MagE.');
            zlabel(em.FieldAnalysisWithFeed.getfieldlabels(optype))
            xlabel('Elevation (degree)')
            ylabel('Azimuth (degree)')
            grid on;
            hold off;
            hfig=ancestor(hb,{'figure','axes'},'toplevel');
        end
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
