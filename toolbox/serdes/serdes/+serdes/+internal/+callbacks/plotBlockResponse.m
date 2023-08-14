function plotBlockResponse(block)











    type=serdes.internal.callbacks.getLibraryBlockType(block);


    switch type
    case 'FFE'
        flag=1;

        TapWeights=get_param(block,'TapWeights');
        Normalize=get_param(block,'Normalize');


        sysobj=serdes.FFE('TapWeights',str2num(TapWeights),...
        'Normalize',strcmp(Normalize,'on'));
    case 'SaturatingAmplifier'
        flag=1;

        spec=get_param(block,'Specification');
        Limit=get_param(block,'Limit');
        LinearGain=get_param(block,'LinearGain');
        VinVout=get_param(block,'VinVout');


        sysobj=serdes.SaturatingAmplifier('Specification',spec);
        switch spec
        case 'Limit and Linear Gain'
            sysobj.Limit=str2num(Limit);
            sysobj.LinearGain=str2num(LinearGain);
        case 'VinVout'
            sysobj.VinVout=str2num(VinVout);
        end
    case 'CTLE'
        flag=1;

        mws=get_param(bdroot(block),'ModelWorkspace');
        if isempty(mws)

            wsSymbolTime.Value=100e-12;
        else
            wsSymbolTime=mws.getVariable('SymbolTime');
        end


        spec=get_param(block,'Specification');
        PeakingFrequency=get_param(block,'PeakingFrequency');
        DCGain=get_param(block,'DCGain');
        ACGain=get_param(block,'ACGain');
        PeakingGain=get_param(block,'PeakingGain');
        GPZ=get_param(block,'GPZ');


        sysobj=serdes.CTLE('Specification',spec,'SymbolTime',wsSymbolTime.Value);
        switch spec
        case 'DC Gain and Peaking Gain'
            sysobj.PeakingFrequency=str2num(PeakingFrequency);%#ok<*ST2NM>
            sysobj.DCGain=str2num(DCGain);
            sysobj.PeakingGain=str2num(PeakingGain);
        case 'DC Gain and AC Gain'
            sysobj.PeakingFrequency=str2num(PeakingFrequency);%#ok<*ST2NM>
            sysobj.DCGain=str2num(DCGain);
            sysobj.ACGain=str2num(ACGain);
        case 'AC Gain and Peaking Gain'
            sysobj.PeakingFrequency=str2num(PeakingFrequency);%#ok<*ST2NM>
            sysobj.ACGain=str2num(ACGain);
            sysobj.PeakingGain=str2num(PeakingGain);
        case 'GPZ Matrix'
            sysobj.GPZ=slResolve(GPZ,bdroot(block));
        end

    case 'AnalogChannel'
        flag=2;

        mws=get_param(bdroot(block),'ModelWorkspace');
        wsChannelImpulse=mws.getVariable('ChannelImpulse');
        wsChannelImpulseValue=wsChannelImpulse.Value;
        wsSymbolTime=mws.getVariable('SymbolTime');
        wsSymbolTimeValue=wsSymbolTime.Value;
        wsSampleInterval=mws.getVariable('SampleInterval');
        wsSampleIntervalValue=wsSampleInterval.Value;
        wsAggressors=mws.getVariable('Aggressors');
        wsAggressorsValue=wsAggressors.Value;
        wsRowSize=mws.getVariable('RowSize');
        wsRowSizeValue=wsRowSize.Value;

        channelImpulse=reshape(wsChannelImpulseValue(1:wsRowSizeValue*(1+wsAggressorsValue)),...
        wsRowSizeValue,1+wsAggressorsValue);

        times=(0:length(channelImpulse)-1)*wsSampleIntervalValue;

        SamplesPerSymbol=round(wsSymbolTimeValue/wsSampleIntervalValue);
        channelStep=impulse2step(channelImpulse,wsSampleIntervalValue);
        channelPulse=impulse2pulse(channelImpulse,SamplesPerSymbol,wsSampleIntervalValue);

        xmin=0;
        xmax=length(channelImpulse)*wsSampleIntervalValue;
        IRymin=min(channelImpulse(:))-abs(min(channelImpulse(:))/5);
        IRymax=max(channelImpulse(:))+max(channelImpulse(:))/20;
        SRymin=min(channelStep(:))-abs(min(channelStep(:))/2);
        SRymax=max(channelStep(:))+max(channelStep(:))/20;
        PRymin=min(channelPulse(:))-abs(min(channelPulse(:))/2);
        PRymax=max(channelPulse(:))+max(channelPulse(:))/20;

        if wsAggressorsValue>0
            aggrLegend=cell(wsAggressorsValue+1,1);
            aggrLegend(1,1)={'Primary'};
            for jj=1:wsAggressorsValue
                aggrLegend{jj+1,1}=sprintf('Aggressor%i',jj);
            end
        end

    otherwise
        flag=0;
    end

    switch flag
    case 0


    case 1

        sysobjFigureTag=['plotBlockResponse',block];
        sysobjFigure=findobj(groot,'Tag',sysobjFigureTag);
        if isempty(sysobjFigure)
            sysobjFigure=figure('Units','normalized');
            sysobjFigure.IntegerHandle=false;
            sysobjFigure.Name="Response of "+block;
            sysobjFigure.Tag=sysobjFigureTag;
        end


        plot(sysobj,sysobjFigure)

    case 2
        blockTitle=['Response of ',+block];

        analogChannelFig=findobj(groot,'Tag','figAnalogChannelResponses');
        if isempty(analogChannelFig)
            analogChannelFig=figure('Name',blockTitle,'NumberTitle','off','Tag','figAnalogChannelResponses');
        end

        tabgp=uitabgroup(analogChannelFig);
        tab1=uitab(tabgp,'Title','Impulse Response');
        tab2=uitab(tabgp,'Title','Step Response');
        tab3=uitab(tabgp,'Title','Pulse Response');


        ax1=axes(tab1);
        plot(ax1,times,channelImpulse);
        title(ax1,'Analog Channel Impulse Response');
        xlabel(ax1,'[s]');
        ylabel(ax1,'[V]');
        xlim(ax1,[xmin,xmax]);
        ylim(ax1,[IRymin,IRymax]);

        if wsAggressorsValue>0
            legend(ax1,aggrLegend);
        end


        ax2=axes(tab2);
        plot(ax2,times,channelStep);
        title(ax2,'Analog Channel Step Response');
        xlabel(ax2,'[s]');
        ylabel(ax2,'[V]');
        xlim(ax2,[xmin,xmax]);
        ylim(ax2,[SRymin,SRymax]);

        if wsAggressorsValue>0
            legend(ax2,aggrLegend);
        end


        ax3=axes(tab3);
        plot(ax3,times,channelPulse);
        title(ax3,'Analog Channel Pulse Response');
        xlabel(ax3,'[s]');
        ylabel(ax3,'[V]');
        xlim(ax3,[xmin,xmax]);
        ylim(ax3,[PRymin,PRymax]);

        if wsAggressorsValue>0
            legend(ax3,aggrLegend);
        end
    end
end