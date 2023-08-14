function simrfV2_plot_solver_freqs(this)






    hBlk=get_param(this,'Handle');
    objBlk=get_param(this,'Object');
    BlkFullName=objBlk.getFullName;
    idxMaskNames=simrfV2getblockmaskparamsindex(hBlk);
    OpenDialogs=this.getOpenDialogs;
    panelHasChanges=OpenDialogs{1}.hasUnappliedChanges;

    if~this.AutoFreq
        if panelHasChanges
            maskStrings=get_param(this,'MaskValues');

            if~strcmp(OpenDialogs{1}.getWidgetValue('Tones'),...
                maskStrings(idxMaskNames.Tones))
                msg=sprintf(['Changes to dialog parameter Tones exists. '...
                ,'Press Apply and try again.']);
                errordlg([BlkFullName,': ',msg],...
                'RF Blockset Configuration block Error');
                return;
            elseif~strcmp(OpenDialogs{1}.getWidgetValue('Harmonics'),...
                maskStrings(idxMaskNames.Harmonics))
                msg=sprintf(['Changes to dialog parameter Harmonics '...
                ,'exists. Press Apply and try again.']);
                errordlg([BlkFullName,': ',msg],...
                'RF Blockset Configuration block Error');
                return;
            elseif~strcmp(OpenDialogs{1}.getComboBoxText('Tones_unit'),...
                maskStrings(idxMaskNames.Tones_unit))
                msg=sprintf(['Changes to units for the dialog parameter '...
                ,'Tones exists. Press Apply and try again.']);
                errordlg([BlkFullName,': ',msg],...
                'RF Blockset Configuration block Error');
                return;
            end
        end
    end

    Udata=get_param(hBlk,'UserData');

    if~this.AutoFreq
        maskWSValues=simrfV2getblockmaskwsvalues(hBlk);
        tones=maskWSValues.Tones;
        tones=simrfV2convert2baseunit(tones,maskWSValues.Tones_unit);
        if isempty(tones)
            error('Parameter Tones not defined.')
        end
        harmonics=maskWSValues.Harmonics;
        if isempty(harmonics)
            error('Parameter Harmonics not defined.')
        end
        harmonics=simrfV2checkparam(harmonics,'Harmonics','gtz',...
        length(tones));


        if length(tones)>1
            ldcTones=(tones~=0);
            tones=tones(ldcTones);
            harmonics=harmonics(ldcTones);
        end
    else
        if~isempty(Udata.tones)&&~isempty(Udata.harmonics)
            tones=Udata.tones;
            harmonics=Udata.harmonics;
        else




            tones=evalin('base',this.Tones);

            harmonics=evalin('base',this.Harmonics);


            if length(tones)>1
                ldcTones=(tones~=0);
                toneList=tones(ldcTones);
            end

            nTones=length(tones);
            if isscalar(harmonics)&&nTones>1
                harmonics=harmonics(ones(size(toneList)));
            end
        end
    end

    if length(tones)>5||prod(2*harmonics+1)>10000
        msg=sprintf(['Too many simulation frequencies to display. To '...
        ,'view the plot reduce the number of tones and/or harmonics']);
        errordlg([BlkFullName,': ',msg],...
        'RF Blockset Configuration block Error');
        return
    end


    if isempty(Udata.FigHandle)||~ishghandle(Udata.FigHandle)
        Udata.Tones=tones;
        Udata.Harmonics=harmonics;
        [freqs,strTip]=simrfV2_sysfreqs(tones,harmonics);

        hfig=figure;
        blockname=get_param(hBlk,'Name');
        set(hfig,'NumberTitle','off');
        set(hfig,'Name',...
        strcat(blockname,': Explaining simulation frequencies'));
        set(hfig,'Units','Normalized','Position',[0.35,0.5,0.25,0.35]);
        set(hfig,'Resize','off');


        uicontrol('Parent',hfig,'Style','text','Units','Normalized',...
        'Position',[0.05,0.88,0.25,0.08],'String','Tones (Hz)',...
        'Fontsize',8,'BackgroundColor',[0.8,0.8,0.8],'Tag','Ttones');
        hlisttones=uicontrol('Parent',hfig,'Style','listbox',...
        'Min',1,'Max',10,'Units','Normalized','Position',...
        [0.05,0.54,0.25,0.35],'String',tones.','HandleVisibility',...
        'callback','Tag','Ltones');


        uicontrol('Parent',hfig,'Style','text','Units','Normalized',...
        'Position',[0.35,0.88,0.25,0.08],'String',...
        'Simulation frequencies (Hz)','Fontsize',8,'BackgroundColor',...
        [0.8,0.8,0.8],'Tag','Tfreq');
        hlistfreq=uicontrol('Parent',hfig,'Style','listbox','Min',1,...
        'Max',1,'Units','Normalized','Position',[0.35,0.54,0.25,0.35],...
        'String',freqs.','HandleVisibility','callback','Tag','Lfreq');


        htextexp=uicontrol('Parent',hfig,'Style','text',...
        'Units','Normalized','Position',[0.65,0.88,0.30,0.08],...
        'String','Explanation','Fontsize',8,'BackgroundColor',...
        [0.8,0.8,0.8],'Tag','Texp');
        hlistexp=uicontrol('Parent',hfig,'Style','text',...
        'Units','Normalized','Position',[0.65,0.54,0.30,0.35],...
        'String','','Tag','Lexp');


        set(hlisttones,'Callback',{@mytonesfcn,htextexp,hlistexp});
        set(hlistfreq,'Callback',{@myfcn,strTip,htextexp,hlistexp});


        [freqs,~,Units]=engunits(freqs);
        axes1=axes('Parent',hfig,'Position',[0.05,0.15,0.9,0.3]);
        box(axes1,'on');
        stem(axes1,freqs,ones(1,length(freqs)),'HandleVisibility',...
        'callback');
        set(axes1,'XScale','linear','YLim',[0,2]);
        set(axes1,'Ytick',[]);
        xlabel(axes1,strcat(Units,'Hz'));
        title(axes1,'Simulation frequencies');

        datacursormode on;
        dcm_obj=datacursormode(hfig);
        set(dcm_obj,'UpdateFcn',{@myupdatefcn,strTip});
        Udata.FigHandle=hfig;
        Udata.AllHandle=[axes1,hlisttones,hlistfreq,htextexp,hlistexp];
        set_param(hBlk,'UserData',Udata);

    elseif ishghandle(Udata.FigHandle)&&...
        (~isequal(tones,Udata.Tones)||~isequal(harmonics,Udata.Harmonics))
        [freqs,strTip]=simrfV2_sysfreqs(tones,harmonics);
        hfig=Udata.FigHandle;
        axes1=Udata.AllHandle(1);
        hlisttones=Udata.AllHandle(2);
        hlistfreq=Udata.AllHandle(3);
        htextexp=Udata.AllHandle(4);
        hlistexp=Udata.AllHandle(5);



        [~,chosentonesInd]=...
        ismember(Udata.Tones(get(hlisttones,'Value')),tones);
        if isempty(chosentonesInd(chosentonesInd~=0))
            chosentonesInd=1;
        else
            chosentonesInd=chosentonesInd(chosentonesInd~=0);
        end
        set(hlisttones,'String',tones.','Value',chosentonesInd);
        set(hlisttones,'Callback',{@mytonesfcn,htextexp,hlistexp});



        if(any(size(Udata.Tones)~=size(tones))||...
            any(Udata.Tones~=tones))||...
            (any(size(Udata.Harmonics)~=size(harmonics))||...
            any(Udata.Harmonics~=harmonics))


            [freqsPrev,~]=simrfV2_sysfreqs(Udata.Tones,Udata.Harmonics);
            prevFreq=freqsPrev(get(hlistfreq,'Value'));
            [~,chosenfreqsInd]=ismember(prevFreq,freqs);
            if isempty(chosenfreqsInd(chosenfreqsInd~=0))
                chosenfreqsInd=1;
            else
                chosenfreqsInd=chosenfreqsInd(chosenfreqsInd~=0);
            end
            set(hlistfreq,'String',freqs.','Value',chosenfreqsInd);
        else

            set(hlistfreq,'String',freqs.');
        end
        set(hlistfreq,'Callback',{@myfcn,strTip,htextexp,hlistexp});


        if contains(get(htextexp,'String'),'tones')
            mytonesfcn(hlisttones,[],htextexp,hlistexp);
        else
            myfcn(hlistfreq,[],strTip,htextexp,hlistexp);
        end


        [freqs,~,Units]=engunits(freqs);
        stem(axes1,freqs,ones(1,length(freqs)),'HandleVisibility',...
        'callback');
        set(axes1,'XScale','linear','YLim',[0,2]);
        set(axes1,'Ytick',[]);
        xlabel(axes1,strcat(Units,'Hz'));
        title(axes1,'Simulation frequencies');
        datacursormode on;

        dcm_obj=datacursormode(hfig);
        set(dcm_obj,'UpdateFcn',{@myupdatefcn,strTip})
        Udata.Tones=tones;
        Udata.Harmonics=harmonics;
        set_param(hBlk,'UserData',Udata)
    end

end


function datacursorLabel=myupdatefcn(~,event_obj,strTip)


    xdata=get(event_obj.Target,'XData');

    eventposition=event_obj.Position;

    prtStr=strTip(xdata==eventposition(1));

    datacursorLabel=prtStr{:};

end


function myfcn(src,~,strTip,htextexp,hlistexp)


    val=get(src,'Value');
    prtStr=strTip(val);
    dataval=prtStr{:};
    str1=(dataval(3:end)).';
    set(hlistexp,'String',str1);
    set(htextexp,'String','Explanation for simulation frequencies');
end


function mytonesfcn(src,~,htextexp,hlistexp)


    val=get(src,'Value');
    str1=strcat('f',num2str(val.'));
    set(hlistexp,'String',str1);
    set(htextexp,'String','Explanation for tones');
end