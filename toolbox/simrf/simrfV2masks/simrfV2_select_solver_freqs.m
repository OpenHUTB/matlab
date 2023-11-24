function simrfV2_select_solver_freqs(this,IPOPfreqsChanged)

    if isa(this,'simrfV2dialog.Solver')
        hBlk=get_param(this,'Handle');
        objBlk=get_param(this,'Object');
        BlkFullName=objBlk.getFullName;
        hBlkParent=get_param(this,'Handle');
        idxMaskNames=simrfV2getblockmaskparamsindex(hBlk);
        OpenDialogs=this.getOpenDialogs;
        panelHasChanges=OpenDialogs{1}.hasUnappliedChanges;

        if panelHasChanges
            maskStrings=get_param(this,'MaskValues');
            if(OpenDialogs{1}.getWidgetValue('AutoFreq')~=...
                strcmp(maskStrings(idxMaskNames.AutoFreq),'on'))
                msg=sprintf(['Changes to dialog parameter AutoFreq '...
                ,'exists. Press Apply and try again.']);
                errordlg([BlkFullName,': ',msg],...
                'RF Blockset Configuration block Error');
                return;
            end
        end
        if~this.AutoFreq
            if panelHasChanges
                maskStrings=get_param(this,'MaskValues');

                if~strcmp(OpenDialogs{1}.getWidgetValue('Tones'),...
                    maskStrings(idxMaskNames.Tones))
                    msg=sprintf(['Changes to dialog parameter Tones '...
                    ,'exists. Press Apply and try again.']);
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
                    msg=sprintf(['Changes to units for the dialog '...
                    ,'parameter Tones exists. Press Apply and try again.']);
                    errordlg([BlkFullName,': ',msg],...
                    'RF Blockset Configuration block Error');
                    return;
                end
            end
        end

        if~this.AllSimFreqs
            if panelHasChanges
                maskStrings=get_param(this,'MaskValues');

                if~strcmp(OpenDialogs{1}.getWidgetValue('SimFreqs'),...
                    maskStrings(idxMaskNames.SimFreqs))
                    msg=sprintf(['Changes to dialog parameter SimFreqs '...
                    ,'exists. Press Apply and try again.']);
                    errordlg([BlkFullName,': ',msg],...
                    'RF Blockset Configuration block Error');
                    return;
                elseif~strcmp(OpenDialogs{1}.getComboBoxText(...
                    'SimFreqs_unit'),...
                    maskStrings(idxMaskNames.SimFreqs_unit))
                    msg=sprintf(['Changes to units for the dialog '...
                    ,'parameter SimFreqs exists. Press Apply and try '...
                    ,'again.']);
                    errordlg([BlkFullName,': ',msg],...
                    'RF Blockset Configuration block Error');
                    return;
                end
            end
        end

        Udata=get_param(hBlk,'UserData');

        maskWSValues=simrfV2getblockmaskwsvalues(hBlk);
        specifiedFreqs=maskWSValues.SimFreqs;
        specifiedFreqs=simrfV2convert2baseunit(specifiedFreqs,...
        maskWSValues.SimFreqs_unit);

        if~this.AutoFreq
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
        else
            if~isempty(Udata.tones)&&~isempty(Udata.harmonics)
                tones=Udata.tones;
                harmonics=Udata.harmonics;
                if~isempty(Udata.IPfreq)&&~isempty(Udata.OPfreq)
                    if any(freqIsEq(Udata.IPfreq,0,1e-8))||...
                        any(freqIsEq(Udata.OPfreq,0,1e-8))
                        tones=[0,tones];
                        harmonics=[1,harmonics];
                    end
                end
            else
                tones=evalin('base',this.Tones);
                tones=simrfV2convert2baseunit(tones,this.Tones_unit);
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
    else
        hBlkParent=get_param(this,'Handle');
        idxMaskNames=simrfV2getblockmaskparamsindex(hBlkParent);

        if strcmp(get(hBlkParent,'classname'),'tbsparam')
            hBlk=get_param([get_param(hBlkParent,'Parent'),'/'...
            ,get_param(hBlkParent,'Name'),'/Configuration'],'Handle');
            objBlk=get_param(this,'Object');
            BlkFullName=objBlk.getFullName;
        else
            return
        end
        OpenDialogs=this.getOpenDialogs;
        panelHasChanges=OpenDialogs{1}.hasUnappliedChanges;

        if panelHasChanges
            maskStrings=get_param(hBlkParent,'MaskValues');

            if~strcmp(OpenDialogs{1}.getWidgetValue(...
                'Input frequency (Hz):'),maskStrings(idxMaskNames.Fin))
                msg=sprintf(['Changes to dialog parameter Fin exists. '...
                ,'Press Apply and try again.']);
                errordlg([BlkFullName,': ',msg],...
                'RF Blockset Configuration block Error');
                return;
            elseif~strcmp(OpenDialogs{1}.getWidgetValue(...
                'Output frequency (Hz):'),...
                maskStrings(idxMaskNames.FoutInput))
                msg=sprintf(['Changes to dialog parameter FoutInput '...
                ,'exists. Press Apply and try again.']);
                errordlg([BlkFullName,': ',msg],...
                'RF Blockset Configuration block Error');
                return;
            end
        end

        if strcmp(this.get_param('AllSimFreqs'),'off')
            if panelHasChanges
                maskStrings=get_param(hBlkParent,'MaskValues');

                if~strcmp(OpenDialogs{1}.getWidgetValue(...
                    '       Small signal frequencies:'),...
                    maskStrings(idxMaskNames.SimFreqs))
                    msg=sprintf(['Changes to dialog parameter SimFreqs '...
                    ,'exists. Press Apply and try again.']);
                    errordlg([BlkFullName,': ',msg],...
                    'RF Blockset Configuration block Error');
                    return;
                end
            end
        end

        Udata=get_param(hBlk,'UserData');

        maskWSValues=simrfV2getblockmaskwsvalues(hBlkParent);
        specifiedFreqs=maskWSValues.SimFreqs;
        if~isempty(Udata.tones)&&~isempty(Udata.harmonics)
            tones=Udata.tones;
            harmonics=Udata.harmonics;
            if~isempty(Udata.IPfreq)&&~isempty(Udata.OPfreq)
                if any(freqIsEq(Udata.IPfreq,0,1e-8))||...
                    any(freqIsEq(Udata.OPfreq,0,1e-8))
                    tones=[0,tones];
                    harmonics=[1,harmonics];
                end
            end
        else
            idxMaskNames=simrfV2getblockmaskparamsindex(hBlk);
            maskStrings=get_param(hBlk,'MaskValues');

            tones=evalin('base',maskStrings{idxMaskNames.Tones});
            tones=simrfV2convert2baseunit(tones,...
            maskStrings{idxMaskNames.Tones_unit});
            harmonics=evalin('base',maskStrings{idxMaskNames.Harmonics});

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
        objBlkParent=get_param(hBlkParent,'Object');
        errordlg([objBlkParent.getFullName,': ',msg],...
        'RF Blockset Configuration block Error');
        return
    end
    IPOPfreqsChanged=nargin~=1&&IPOPfreqsChanged;

    if isempty(Udata.FigHandlePop)||~ishghandle(Udata.FigHandlePop)

        Udata.TonesPop=tones;
        Udata.HarmonicsPop=harmonics;
        [freqs,strTip,harmUsed]=simrfV2_sysfreqs(tones,harmonics);

        hfig=figure;
        blockname=get_param(hBlkParent,'Name');
        set(hfig,'NumberTitle','off');
        set(hfig,'Name',...
        strcat(blockname,': Selecting small signal frequencies'));
        set(hfig,'Units','Normalized','Position',[0.35,0.5,0.25,0.35]);
        set(hfig,'Resize','off');

        hpan=uipanel(hfig,'Position',[0.035,0.52,0.51,0.445]);

        uicontrol('Parent',hpan,'Style','text','Units','Normalized',...
        'Position',[0.05,0.89,0.82,0.1],'String',...
        'Small signal selection panel','Fontsize',8,'Tag','Ttones');
        uicontrol('Parent',hfig,'Style','text','Units','Normalized',...
        'Position',[0.05,0.86,0.22,0.05],'String','Tones (Hz)',...
        'Fontsize',8,'BackgroundColor',[0.8,0.8,0.8],'Tag','Ttones');
        hlisttones=uicontrol('Parent',hfig,'Style','listbox',...
        'Min',1,'Max',max(length(tones),3),'Units','Normalized',...
        'Position',[0.05,0.573,0.22,0.297],'String',tones.',...
        'HandleVisibility','callback','Tag','Ltones');
        hlisttones.Value=1:length(tones);


        uicontrol('Parent',hfig,'Style','text','Units','Normalized',...
        'Position',[0.3,0.86,0.22,0.05],'String','Harmonic order',...
        'Fontsize',8,'BackgroundColor',[0.8,0.8,0.8],'Tag','Tharms');
        harmStr=arrayfun(@(x)['Up to order ',num2str(x)],...
        1:max(harmonics),'UniformOutput',false);
        harmStr=['Tones only',harmStr];
        hlistharm=uicontrol('Parent',hfig,'Style','listbox',...
        'Min',1,'Max',1,'Units','Normalized',...
        'Position',[0.3,0.573,0.22,0.297],'String',harmStr,...
        'HandleVisibility','callback','Tag','Lharms');
        hlistharm.Value=1;


        hchkbox=uicontrol('Parent',hfig,'Style','Checkbox','Units',...
        'Normalized','Position',[0.05,0.525,0.45,0.05],'String',...
        'Include all input and output frequencies','HandleVisibility',...
        'callback','Tag','Chkbx');
        hchkbox.Value=true;
        if strcmp(get_param(hBlk,'AutoFreq'),'on')
            hchkbox.Visible='on';
            hlisttones.Position=[0.05,0.573,0.22,0.297];
            hlistharm.Position=[0.3,0.573,0.22,0.297];
        else
            hchkbox.Visible='off';
            hlisttones.Position=[0.05,0.54,0.22,0.33];
            hlistharm.Position=[0.3,0.54,0.22,0.33];
        end
        uicontrol('Parent',hfig,'Style','text','Units','Normalized',...
        'Position',[0.73,0.88,0.22,0.08],'String',...
        'Simulation frequencies (Hz)','Fontsize',8,'BackgroundColor',...
        [0.8,0.8,0.8],'Tag','Tfreq');
        hlistfreq=uicontrol('Parent',hfig,'Style','listbox','Min',1,...
        'Max',max(length(freqs),3),'Units','Normalized','Position',...
        [0.73,0.52,0.22,0.37],'String',freqs.','HandleVisibility',...
        'callback','Tag','Lfreq');
        [~,chosenFreqsInd]=freqIsMember(specifiedFreqs,freqs,1e-8);
        if isempty(chosenFreqsInd(chosenFreqsInd~=0))
            chosenFreqsInd=1;
        else
            chosenFreqsInd=chosenFreqsInd(chosenFreqsInd~=0);
        end
        hlistfreq.Value=chosenFreqsInd;
        [freqsNoUnits,~,Units]=engunits(freqs);
        axes1=axes('Parent',hfig,'Position',[0.05,0.15,0.9,0.3]);
        box(axes1,'on');
        stem(axes1,freqsNoUnits,ones(1,length(freqsNoUnits)),...
        'HandleVisibility','callback');
        hold(axes1,'on');
        ChosenFreqs=freqsNoUnits(chosenFreqsInd);
        hStem=stem(axes1,ChosenFreqs,ones(1,length(ChosenFreqs)),...
        'HandleVisibility','callback','Color','none','LineStyle',...
        'none','Marker','o','MarkerFaceColor','r','Tag','SmallSig');
        hold(axes1,'off');
        set(axes1,'XScale','linear','YLim',[0,2]);
        set(axes1,'Ytick',[]);
        xlabel(axes1,strcat(Units,'Hz'));
        title(axes1,'Simulation frequencies');
        legend(hStem,['Small signal frequencies (total of '...
        ,num2str(length(ChosenFreqs)),')'],'FontSize',9);

        datacursormode on;
        dcm_obj=datacursormode(hfig);
        set(dcm_obj,'UpdateFcn',{@myupdatefcn,strTip});
        Udata.FigHandlePop=hfig;

        hbutsel=uicontrol('Parent',hfig,'Style','pushbutton',...
        'Units','Normalized','Position',[0.56,0.715,0.15,0.05],...
        'String','-> Select ->','Fontsize',8,'BackgroundColor',...
        [0.8,0.8,0.8],'Tag','TbutSel');
        set(hbutsel,'Callback',...
        {@mybutselfcn,freqsNoUnits,harmUsed,hlisttones,hlistharm,...
        hchkbox,hlistfreq,axes1,hBlk});
        hbutpop=uicontrol('Parent',hfig,'Style','pushbutton',...
        'Units','Normalized','Position',[0.79,0.005,0.20,0.06],...
        'String','Populate Mask','Fontsize',9,'BackgroundColor',...
        [0.8,0.8,0.8],'Tag','TbutPop');
        set(hbutpop,'Callback',...
        {@mybutpopfcn,freqs,hlistfreq,hBlkParent,hfig});
       hbutcan=uicontrol('Parent',hfig,'Style','pushbutton',...
        'Units','Normalized','Position',[0.63,0.005,0.15,0.06],...
        'String','Cancel','Fontsize',9,'BackgroundColor',...
        [0.8,0.8,0.8],'Tag','TbutCan');
        set(hbutcan,'Callback',{@mybutcanfcn,hfig});
        wrnData=imread(fullfile(matlabroot,'toolbox','simrf',...
        'simrfV2masks','warning.png'),'BackgroundColor',axes1.Parent.Color);
        set(hlistfreq,'Callback',{@myselectfcn,freqsNoUnits,axes1});

        showWrn='off';
        if strcmp(get_param(hBlk,'AutoFreq'),'on')
            BlkObj=get_param(hBlk,'Object');
            [IPfreq,OPfreq]=...
            simrfV2_find_solverIPOPfreqs(BlkObj.getFullName);
            if any(size(IPfreq)~=size(Udata.IPfreq))||...
                any(~freqIsEq(IPfreq,Udata.IPfreq,1e-8))||...
                any(size(OPfreq)~=size(Udata.OPfreq))||...
                any(~freqIsEq(OPfreq,Udata.OPfreq,1e-8))
                showWrn='on';
            end
        end
        himgwrn=uicontrol('Parent',axes1.Parent,'Style','checkbox',...
        'Units','Normalized','cdata',wrnData,'Visible',showWrn,...
        'Position',[0.015,0.008,0.125,0.05]);
        htxtwrn=uicontrol('Parent',axes1.Parent,'Style','text','Units',...
        'Normalized','HorizontalAlignment','left','Position',...
        [0.055,0,0.5,0.05],'String',...
        'Changes in model detected - update diagram.',...
        'Fontsize',8,'Tag','TWarn','Visible',showWrn);
        Udata.AllHandlePop=[axes1,hlisttones,hlistharm,hchkbox,...
        hlistfreq,hbutsel,hbutpop,himgwrn,htxtwrn];

        set_param(hBlk,'UserData',Udata);

    elseif ishghandle(Udata.FigHandlePop)&&...
        ((~isequal(tones,Udata.TonesPop)||...
        ~isequal(harmonics,Udata.HarmonicsPop))||...
        ((any(size(Udata.AllHandlePop(5).Value)~=...
        size(specifiedFreqs)))||(any(specifiedFreqs~=...
        str2num(Udata.AllHandlePop(5).String(...
        Udata.AllHandlePop(5).Value,:)).')))||...
        (~strcmp(Udata.AllHandlePop(4).Visible,...
        get_param(hBlk,'AutoFreq')))||...
        (strcmp(get_param(hBlk,'AutoFreq'),'on')...
        &&IPOPfreqsChanged))%#ok<ST2NM> % See E4 

        Udata.TonesPop=tones;
        Udata.HarmonicsPop=harmonics;
        [freqs,strTip,harmUsed]=simrfV2_sysfreqs(tones,harmonics);
        hfig=Udata.FigHandlePop;
        axes1=Udata.AllHandlePop(1);
        hlisttones=Udata.AllHandlePop(2);
        hlistharm=Udata.AllHandlePop(3);
        hchkbox=Udata.AllHandlePop(4);
        hlistfreq=Udata.AllHandlePop(5);
        hbutsel=Udata.AllHandlePop(6);
        hbutpop=Udata.AllHandlePop(7);
        himgwrn=Udata.AllHandlePop(8);
        htxtwrn=Udata.AllHandlePop(9);
        set(hlisttones,'String',tones.','Max',max(length(tones),3),...
        'Value',1:length(tones));


        harmStr=arrayfun(@(x)['Up to order ',num2str(x)],...
        1:max(harmonics),'UniformOutput',false);
        harmStr=['Tones only',harmStr];
        set(hlistharm,'String',harmStr,'Max',1,'Value',1);
        [~,chosenFreqsInd]=freqIsMember(specifiedFreqs,freqs,1e-8);
        if isempty(chosenFreqsInd(chosenFreqsInd~=0))
            chosenFreqsInd=1;
        else
            chosenFreqsInd=chosenFreqsInd(chosenFreqsInd~=0);
        end
        set(hlistfreq,'String',freqs.','Max',max(length(freqs),3),...
        'Value',chosenFreqsInd);

        [freqsNoUnits,~,Units]=engunits(freqs);
        set(hlistfreq,'Callback',{@myselectfcn,freqsNoUnits,axes1});
        if strcmp(get_param(hBlk,'AutoFreq'),'on')
            hchkbox.Visible='on';
            hlisttones.Position=[0.05,0.573,0.22,0.297];
            hlistharm.Position=[0.3,0.573,0.22,0.297];
        else
            hchkbox.Visible='off';
            hlisttones.Position=[0.05,0.54,0.22,0.33];
            hlistharm.Position=[0.3,0.54,0.22,0.33];
        end
        set(hbutsel,'Callback',...
        {@mybutselfcn,freqsNoUnits,harmUsed,hlisttones,hlistharm,...
        hchkbox,hlistfreq,axes1,hBlk});
        set(hbutpop,'Callback',...
        {@mybutpopfcn,freqs,hlistfreq,hBlkParent,hfig});

        ChosenFreqs=freqsNoUnits(chosenFreqsInd);
        stem(axes1,freqsNoUnits,ones(1,length(freqsNoUnits)),...
        'HandleVisibility','callback');
        hold(axes1,'on');
        hStem=stem(axes1,ChosenFreqs,ones(1,length(ChosenFreqs)),...
        'HandleVisibility','callback','Color','none','LineStyle',...
        'none','Marker','o','MarkerFaceColor','r','Tag','SmallSig');
        hold(axes1,'off');
        set(axes1,'XScale','linear','YLim',[0,2]);
        set(axes1,'Ytick',[]);
        xlabel(axes1,strcat(Units,'Hz'));
        title(axes1,'Simulation frequencies');
        legend(hStem,['Small signal frequencies (total of '...
        ,num2str(length(ChosenFreqs)),')'],'FontSize',9);
        datacursormode on;

        dcm_obj=datacursormode(hfig);
        set(dcm_obj,'UpdateFcn',{@myupdatefcn,strTip})

        if strcmp(get_param(hBlk,'AutoFreq'),'off')
            himgwrn.Visible='off';
            htxtwrn.Visible='off';
        else
            BlkObj=get_param(hBlk,'Object');
            if~IPOPfreqsChanged

                UdataTemp=Udata;
                UdataTemp.FigHandlePop=[];
                set_param(hBlk,'UserData',UdataTemp);
                [IPfreq,OPfreq]=...
                simrfV2_find_solverIPOPfreqs(BlkObj.getFullName);
                showWrn='off';
                if any(size(IPfreq)~=size(Udata.IPfreq))||...
                    any(~freqIsEq(IPfreq,Udata.IPfreq,1e-8))||...
                    any(size(OPfreq)~=size(Udata.OPfreq))||...
                    any(~freqIsEq(OPfreq,Udata.OPfreq,1e-8))
                    showWrn='on';
                end
            else
                showWrn='off';
            end
            himgwrn.Visible=showWrn;
            htxtwrn.Visible=showWrn;
        end
        set_param(hBlk,'UserData',Udata)
    end

end

function mybutselfcn(~,~,freqsNoUnits,harmUsed,hlisttones,hlistharm,...
    hchkbox,hlistfreq,axes1,hBlk)

    hasDC=str2double(hlisttones.String(1,:))==0;
    chosenTonesInd=get(hlisttones,'Value');
    chosenHarmOrd=get(hlistharm,'Value')-1;
    if chosenHarmOrd==0

        toSelect=freqIsMember(str2num(hlistfreq.String).',...
        str2num(hlisttones.String(chosenTonesInd,:)),1e-8);%#ok<ST2NM>
    else
        unchosenTonesInd=setdiff(1+hasDC:size(hlisttones.String,1),...
        chosenTonesInd);
        harmUsedElim=cellfun(@(x)eliminateUnchosenTones(x),harmUsed,...
        'UniformOutput',false);
        toSelect=cellfun(@(x)any(max(abs(x))<=(hlistharm.Value-1)),...
        harmUsedElim);
    end
    function x1=eliminateUnchosenTones(x)
        x1=x;
        x1(unchosenTonesInd-hasDC,x(unchosenTonesInd-hasDC,:)~=0)=...
        hlistharm.Value;
    end

    if chosenHarmOrd<=1&&~(hasDC&&chosenTonesInd(1)==1)
        toSelect(1)=false;
    end

    if strcmp(hchkbox.Visible,'on')&&hchkbox.Value
        Udata=get_param(hBlk,'UserData');
        inOutFreqs=freqUnique([Udata.IPfreq,Udata.OPfreq],1e-8);
        toSelectInOut=...
        freqIsMember(str2num(hlistfreq.String).',inOutFreqs,1e-8);%#ok<ST2NM>
        toSelect=toSelect|toSelectInOut;
    end
    ChosenFreqs=freqsNoUnits(toSelect);
    set(hlistfreq,'Value',find(toSelect));
    Stems=get(axes1,'Children');
    selStem=Stems(arrayfun(@(x)strcmp(x.Tag,'SmallSig'),Stems));
    if~isempty(selStem)
        delete(selStem);
    end
    hold(axes1,'on');
    hStem=stem(axes1,ChosenFreqs,ones(1,length(ChosenFreqs)),...
    'HandleVisibility','callback','Color','none','LineStyle',...
    'none','Marker','o','MarkerFaceColor','r','Tag','SmallSig');
    set(axes1,'YLim',[0,2]);
    hold(axes1,'off');
    legend(hStem,['Small signal frequencies (total of '...
    ,num2str(length(ChosenFreqs)),')'],'FontSize',9);
end

function mybutpopfcn(~,~,freqs,hlistfreq,hBlk,hFig)

    chosenFreqsInd=get(hlistfreq,'Value');
    ChosenFreqs=freqs(chosenFreqsInd);
    if max(ChosenFreqs)<1
        Y=ChosenFreqs;
        U='';
    else
        [Y,e,U]=engunits(ChosenFreqs);
        switch U
        case 'T'
            Y=Y*1e3;
            U='G';
        case 'P'
            Y=Y*1e6;
            U='G';
        case 'E'
            Y=Y*1e9;
            U='G';
        end
    end

    try
        get_param(hBlk,'Handle');
    catch ME %#ok<NASGU>
        return
    end

    if isfield(simrfV2getblockmaskparamsindex(hBlk),'SimFreqs_unit')
        set_param(hBlk,'SimFreqs_unit',strcat(U,'Hz'));
        set_param(hBlk,'SimFreqs',strcat('[',num2str(Y),']'));
    else
        SimFreqsStr=cell2mat(arrayfun(@(x)...
        [num2str(x),'e',num2str(round(log10(1/e))),' '],...
        Y.','UniformOutput',false).');
        set_param(hBlk,'SimFreqs',strcat('[',SimFreqsStr(1:end-1),']'));
    end

    close(hFig);
end

function mybutcanfcn(~,~,hFig)
    close(hFig);
end


function datacursorLabel=myupdatefcn(~,event_obj,strTip)


    xdata=get(event_obj.Target,'XData');

    eventposition=event_obj.Position;

    prtStr=strTip(xdata==eventposition(1));

    datacursorLabel=prtStr{:};

end


function myselectfcn(src,~,freqsNoUnits,axes1)

    chosenFreqsInd=get(src,'Value');
    Stems=get(axes1,'Children');
    selStem=Stems(arrayfun(@(x)strcmp(x.Tag,'SmallSig'),Stems));
    if~isempty(selStem)
        delete(selStem);
    end
    if~isempty(chosenFreqsInd)
        hold(axes1,'on');
        hStem=stem(axes1,freqsNoUnits(chosenFreqsInd),...
        ones(1,length(freqsNoUnits(chosenFreqsInd))),...
        'HandleVisibility','callback','Color','none','LineStyle',...
        'none','Marker','o','MarkerFaceColor','r','Tag','SmallSig');
        set(axes1,'YLim',[0,2]);
        hold(axes1,'off');
        legend(hStem,['Small signal frequencies (total of '...
        ,num2str(length(freqsNoUnits(chosenFreqsInd))),')'],'FontSize',9);
    else
        legend('off');
    end
end


function res=freqIsEq(A,B,relTol,absTol)
    if nargin==3
        res=abs(A-B)<relTol*max(abs(A),abs(B))+relTol;
    else
        res=abs(A-B)<relTol*max(abs(A),abs(B))+absTol;
    end
end
function[isMem,memInd]=freqIsMember(A,B,varargin)
    memInd=arrayfun(@(Ael)find(freqIsEq(Ael,[B(:);Ael],...
    varargin{:}),1),A);
    memInd(memInd>length(B))=0;
    isMem=logical(memInd);
end
function res=freqUnique(A,varargin)
    [~,memInd]=freqIsMember(A,A,varargin{:});
    res=A(unique(memInd));
end