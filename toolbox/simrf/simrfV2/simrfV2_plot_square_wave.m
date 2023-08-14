function simrfV2_plot_square_wave(this)






    hBlk=get_param(this,'Handle');
    objBlk=get_param(this,'Object');
    BlkFullName=objBlk.getFullName;
    idxMaskNames=simrfV2getblockmaskparamsindex(hBlk);
    OpenDialogs=this.getOpenDialogs;
    panelHasChanges=OpenDialogs{1}.hasUnappliedChanges;



    if panelHasChanges
        maskStrings=get_param(this,'MaskValues');
        if~strcmp(OpenDialogs{1}.getWidgetValue('CarrierFreq'),...
            maskStrings(idxMaskNames.CarrierFreq))
            msg=sprintf(['Changes to dialog parameter Carrier frequencies exists. '...
            ,'Press Apply and try again.']);
            errordlg([BlkFullName,': ',msg],...
            'RF Blockset Inport block Error');
            return
        elseif~strcmp(OpenDialogs{1}.getComboBoxText('CarrierFreq_unit'),...
            maskStrings(idxMaskNames.CarrierFreq_unit))
            msg=sprintf(['Changes to the unit of dialog parameter Carrier frequencies exists. '...
            ,'Press Apply and try again.']);
            errordlg([BlkFullName,': ',msg],...
            'RF Blockset Inport block Error');
            return
        elseif~strcmp(OpenDialogs{1}.getWidgetValue('NumCoeff'),...
            maskStrings(idxMaskNames.NumCoeff))
            msg=sprintf(['Changes to dialog parameter Number of Fourier Coefficients exists. '...
            ,'Press Apply and try again.']);
            errordlg([BlkFullName,': ',msg],...
            'RF Blockset Inport block Error');
            return
        elseif~strcmp(OpenDialogs{1}.getWidgetValue('Bias'),...
            maskStrings(idxMaskNames.Bias))
            msg=sprintf(['Changes to dialog parameter DC Bias exists. '...
            ,'Press Apply and try again.']);
            errordlg([BlkFullName,': ',msg],...
            'RF Blockset Inport block Error');
            return
        elseif~strcmp(OpenDialogs{1}.getWidgetValue('DutyCyc'),...
            maskStrings(idxMaskNames.DutyCyc))
            msg=sprintf(['Changes to dialog parameter Duty Cycle (%%) exists. '...
            ,'Press Apply and try again.']);
            errordlg([BlkFullName,': ',msg],...
            'RF Blockset Inport block Error');
            return
        end
    end


    maskWSValues=simrfV2getblockmaskwsvalues(hBlk);
    NumCoef=maskWSValues.NumCoeff;
    DutyCyc=maskWSValues.DutyCyc;
    Bias=maskWSValues.Bias;
    inputfreq=maskWSValues.CarrierFreq;
    inputfreq=simrfV2convert2baseunit(inputfreq,...
    maskWSValues.CarrierFreq_unit);
    validateattributes(NumCoef,{'numeric'},...
    {'nonempty','scalar','>',1,'integer','real','nonnan','finite'},...
    '','Number of Fourier Coefficients for square wave modulation');
    validateattributes(DutyCyc,{'numeric'},...
    {'nonempty','scalar','>',0,'<',100,'real','nonnan','finite'},...
    '','Duty Cycle for square wave modulation');
    inputfreq=simrfV2checkparam(inputfreq,'Carrier frequencies','gtez');
    validateattributes(inputfreq,{'numeric'},...
    {'scalar','nonzero'},...
    '','Carrier frequencies for square wave modulation');
    validateattributes(Bias,{'numeric'},...
    {'nonempty','scalar','real','nonnan','finite'},...
    '','DC Bias for square wave modulation');





    if NumCoef>100000
        error('Parameter Number of Fourier Coefficients is too large for display.')
    end


    A=1;
    n=1:(NumCoef-1);
    a0=A*DutyCyc/100+Bias;
    an=((2*A./(n*pi)).*sin(n*pi*DutyCyc/100))/sqrt(2);
    carrierFreq=inputfreq*n;
    i_need=mod(n*pi*DutyCyc/100,pi)~=0;
    an=an(i_need);
    carrierFreq=[0,carrierFreq(i_need)];
    [carrierFreq_unit,~,Units]=engunits(carrierFreq);


    numPts=1000;
    periodShow=2;
    numErrCoef=1000000;


    t=linspace(-0.5*periodShow/inputfreq,0.5*periodShow/inputfreq,numPts);
    y_ideal=0.5*A+Bias+0.5*A*square(2*pi*(inputfreq*t+0.5*DutyCyc/100),DutyCyc);
    y_est=a0+cos(t'*2*pi*carrierFreq(2:end))*(sqrt(2)*an');


    n_err=(0:(numErrCoef-1))+NumCoef;
    an_err=((2*A./(n_err*pi)).*sin(n_err*pi*DutyCyc/100));
    err=sqrt(0.5*sum(an_err.^2));
    err=round(err,3,'significant');


    Udata=get_param(hBlk,'UserData');
    if~isfield(Udata,'FigHandle')||isempty(Udata.FigHandle)||...
        ~ishghandle(Udata.FigHandle)
        hfig=figure;
        Udata.FigHandle=hfig;
        set_param(hBlk,'UserData',Udata)
    else
        hfig=Udata.FigHandle;
        figure(hfig)
    end
    clf(hfig)


    ax1=subplot(2,1,2,'Parent',hfig);
    [~,t_factor,t_Units]=engunits(t(end));
    plot(ax1,t*t_factor,y_ideal,'LineWidth',0.6)
    hold on
    plot(ax1,t*t_factor,y_est,'LineWidth',0.6)
    xlabel(ax1,['Time [',t_Units,'s]'])
    ylabel(ax1,"Carrier Wave")
    title_1=['Square Wave with ',num2str(NumCoef),' Fourier Coefficients'];
    title_2=['(RMS Error: ',num2str(err),')'];
    title(ax1,[string(title_1),string(title_2)])


    [~,i1]=min(abs(t--0.5*(DutyCyc/100)/inputfreq));
    [~,i2]=min(abs(t-0.5*(DutyCyc/100)/inputfreq));
    plot(ax1,[t(i1),t(i2)]*t_factor,Bias+[0.5*A,0.5*A],'black','LineWidth',1.5)
    plot(ax1,[t(i1),t(i1)]*t_factor,Bias+[0.45*A,0.55*A],'black','LineWidth',1.5)
    plot(ax1,[t(i2),t(i2)]*t_factor,Bias+[0.45*A,0.55*A],'black','LineWidth',1.5)
    text(ax1,0,Bias+0.4*A,['Duty cycle: ',num2str(DutyCyc),'%'],'HorizontalAlignment','center')


    [~,j1]=min(abs(t--0.5/inputfreq));
    [~,j2]=min(abs(t-0.5/inputfreq));
    margin=0.05*(max([y_ideal,y_est'])-min([y_ideal,y_est']));
    bottomLim=min([y_ideal,y_est'])-margin;
    topLim=max([y_ideal,y_est'])+margin;
    plot(ax1,[t(j1),t(j1)]*t_factor,[bottomLim,topLim],'black','LineWidth',0.6,'LineStyle','--')
    plot(ax1,[t(j2),t(j2)]*t_factor,[bottomLim,topLim],'black','LineWidth',0.6,'LineStyle','--');
    ax1.YLim=[bottomLim,topLim];
    ax1.XLim=[t(1),t(end)]*t_factor;


    legend(ax1,'Ideal','Estimate')


    ax2=subplot(2,1,1);
    plot_y=[a0,an*sqrt(2)].*ones(1,length(carrierFreq));
    stem(ax2,carrierFreq_unit,plot_y,'LineWidth',0.6);
    ax2.YLim=[min(plot_y)-0.3,max(plot_y)+0.3];
    ax2.XLim=[carrierFreq_unit(1)-1,carrierFreq_unit(end)+1];
    xlabel(ax2,strcat(Units,'Hz'))
    ylabel(ax2,'Fourier Coefficient Values')
    title('Simulation Frequencies for Square Wave')
end