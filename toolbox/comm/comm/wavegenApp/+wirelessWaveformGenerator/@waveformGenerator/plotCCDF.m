






function plotCCDF(ax,ccdf,holdAxesLimits)

    persistent axesLimits;


    markers=[".","o","*","x","_","|","s","+"];


    if ccdf.BurstMode
        modeResults=ccdf.Burst;
    else
        modeResults=ccdf.Waveform;
    end

    plotGaussianCCDF(ax);

    if~isempty(modeResults.CCDFx)
        x=modeResults.CCDFx;
        y=modeResults.CCDFy;
        avg=modeResults.AveragePower;


        numColumns=size(x,2);
        hold(ax,"on");
        deltaMarkerdB=3;
        for p=1:numColumns
            numPoints=ceil((x(end,p)-x(1,p))/deltaMarkerdB);
            markerInd=unique(floor(logspace(0,log10(length(x(:,p))),numPoints)));
            semilogy(ax,x(:,p),y(:,p),'Marker',markers(1+mod(p-1,length(markers))),...
            'MarkerIndices',markerInd);
        end
        hold(ax,"off");


        legRef=getString(message('comm:waveformGenerator:CCDFLegendGaussianReference'));
        legSig=string(ccdf.LegendChannelName)+" "+(1:numColumns)';
        if numColumns>1
            legSig=legSig+" Avg:"+num2str(avg,'%4.1f')+" dBm.";
        end

        leg=[legRef;legSig];
        legend(ax,leg);
    end


    if nargin==2
        holdAxesLimits=false;
    end


    if~holdAxesLimits||isempty(axesLimits)
        axesLimits=[0,max([modeResults.CCDFx(:);15])+5,10^-4,100];
    end
    axis(ax,axesLimits);

end

function plotGaussianCCDF(ax)

    persistent ccdfxGauss ccdfyGauss;


    if isempty(ccdfyGauss)
        ccdfxGauss=linspace(-15,15);
        ccdfyGauss=100*exp(-10.^(ccdfxGauss/10));
    end

    semilogy(ax,ccdfxGauss,ccdfyGauss,'color',0.5*ones(1,3),'LineStyle','--');


    xlabel(ax,getString(message('comm:waveformGenerator:CCDFXLabel')));
    ylabel(ax,getString(message('comm:waveformGenerator:CCDFYLabel')));


    ax.YTick=10.^(floor(log10(eps)):2);
    ax.YTickLabel=string(ax.YTick);

    title(ax,getString(message('comm:waveformGenerator:CCDFPlotTitle')));

    legRef=getString(message('comm:waveformGenerator:CCDFLegendGaussianReference'));

    legend(ax,legRef);

    grid(ax,'on');

end