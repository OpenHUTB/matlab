function[items,layout]=simrfV2create_RFparam_pane(this,varargin)





    lprompt_spec=1;
    rprompt_spec=4;
    ledit_spec=rprompt_spec+1;
    redit_spec=16;
    lunit_spec=redit_spec+1;
    runit_spec=20;

    hBlk=get_param(this,'Handle');
    fromLibrary=strcmpi(get_param(bdroot(hBlk),'BlockDiagramType'),'library');


    rs_spec=1;
    autofreq=simrfV2GetLeafWidgetBase(...
    'checkbox',...
    'Automatically select fundamental tones and harmonic order',...
    'AutoFreq',this,'AutoFreq');
    autofreq.RowSpan=[rs_spec,rs_spec];
    autofreq.ColSpan=[lprompt_spec,redit_spec];
    autofreq.DialogRefresh=1;


    rs_spec=rs_spec+1;
    tonesprompt=simrfV2GetLeafWidgetBase('text','Fundamental tones:',...
    'Tonesprompt',0);
    tonesprompt.RowSpan=[rs_spec,rs_spec];
    tonesprompt.ColSpan=[lprompt_spec,rprompt_spec];

    tones=simrfV2GetLeafWidgetBase('edit','','Tones',this,'Tones');
    tones.RowSpan=[rs_spec,rs_spec];
    tones.ColSpan=[ledit_spec,redit_spec];
    tones.Enabled=0;





    tones.Visible=1;
    tones.DialogRefresh=1;

    tonesunit=simrfV2GetLeafWidgetBase('combobox','','Tones_unit',this,...
    'Tones_unit');
    tonesunit.Entries=set(this,'Tones_unit')';
    tonesunit.RowSpan=[rs_spec,rs_spec];
    tonesunit.ColSpan=[lunit_spec,runit_spec];
    tonesunit.Enabled=0;

    toneErr='';
    findTonesAtCompile=false;
    if~fromLibrary&&~this.AutoFreq
        [toneList,isResolved]=slResolve(this.Tones,hBlk);
        if~isResolved
            try


                toneList=evalin('base',this.Tones);
            catch me
                if strcmpi(me.identifier,'MATLAB:UndefinedFunction')
                    findTonesAtCompile=true;
                elseif strcmpi(me.identifier,'MATLAB:m_missing_operator')||...
                    strcmpi(me.identifier,'MATLAB:m_incomplete_statement')
                    toneErr='simrf:simrfV2solver:TonesBadSyntax';
                end
                toneList=[];
                lasterr('')%#ok<LERR>
            end
        end

        if findTonesAtCompile==false
            if~isempty(toneErr)

            elseif isempty(toneList)
                toneErr='simrf:simrfV2solver:TonesUndefined';
            elseif~isvector(toneList)
                toneErr='simrf:simrfV2solver:TonesNotVector';
            elseif~all(isfinite(toneList))
                toneErr='simrf:simrfV2solver:TonesNotFinite';
            elseif~all(toneList>=0)
                toneErr='simrf:simrfV2solver:TonesNegative';
            elseif length(toneList)~=length(unique(toneList))
                toneErr='simrf:simrfV2solver:TonesNotUnique';
            end
        end
    end


    rs_spec=rs_spec+1;
    harmonicsprompt=simrfV2GetLeafWidgetBase('text','Harmonic order:',...
    'Harmonicsprompt',0);
    harmonicsprompt.RowSpan=[rs_spec,rs_spec];
    harmonicsprompt.ColSpan=[lprompt_spec,rprompt_spec];

    harmonics=simrfV2GetLeafWidgetBase('edit','','Harmonics',this,...
    'Harmonics');
    harmonics.RowSpan=[rs_spec,rs_spec];
    harmonics.ColSpan=[ledit_spec,runit_spec];
    harmonics.Enabled=0;






    harmonics.Visible=1;
    harmonics.DialogRefresh=1;

    harmErr='';
    findHarmsAtCompile=false;
    if~fromLibrary&&~this.AutoFreq
        [harmList,isResolved]=slResolve(this.Harmonics,hBlk);
        if~isResolved
            try
                harmList=evalin('base',this.Harmonics);
            catch me
                if strcmpi(me.identifier,'MATLAB:UndefinedFunction')
                    findHarmsAtCompile=true;
                elseif strcmpi(me.identifier,'MATLAB:m_missing_operator')||...
                    strcmpi(me.identifier,'MATLAB:m_incomplete_statement')
                    harmErr='simrf:simrfV2solver:HarmsBadSyntax';
                end
                lasterr('')%#ok<LERR>
                harmList=[];
            end
        end

        if findHarmsAtCompile==false
            if~isempty(harmErr)

            elseif isempty(harmList)
                harmErr='simrf:simrfV2solver:HarmsUndefined';
            elseif~isvector(harmList)
                harmErr='simrf:simrfV2solver:HarmsNotVector';
            elseif~all(isfinite(harmList))
                harmErr='simrf:simrfV2solver:HarmsNotFinite';
            elseif~all(harmList>0)
                harmErr='simrf:simrfV2solver:HarmsNotPositive';
            elseif~all((round(harmList)-harmList)==0)
                harmErr='simrf:simrfV2solver:HarmsNotInteger';
            elseif~isempty(toneList)&&~isscalar(harmList)&&...
                any((size(toneList)~=size(harmList)))
                harmErr='simrf:simrfV2solver:HarmsTonesUnequal';
            end
        end
    end


    rs_spec=rs_spec+1;
    freqsprompt=simrfV2GetLeafWidgetBase('text',...
    'Total simulation frequencies:','Freqsprompt',0);
    freqsprompt.RowSpan=[rs_spec,rs_spec];
    freqsprompt.ColSpan=[lprompt_spec,rprompt_spec];


    totalfreqs=simrfV2GetLeafWidgetBase('text','N/A','Totalfreqs',0);
    totalfreqs.RowSpan=[rs_spec,rs_spec];
    totalfreqs.ColSpan=[ledit_spec,redit_spec];


    errmsgid=simrfV2GetLeafWidgetBase('text','N/A','ErrMsgId',0);
    errmsgid.RowSpan=[rs_spec,rs_spec];
    errmsgid.ColSpan=[ledit_spec,redit_spec];
    errmsgid.Enabled=false;
    errmsgid.Visible=false;


    plotbutton=...
    simrfV2GetLeafWidgetBase('pushbutton','View','PlotButton',this);
    plotbutton.RowSpan=[rs_spec,rs_spec];
    plotbutton.ColSpan=[lunit_spec,runit_spec];

    plotbutton.MatlabMethod='simrfV2_plot_solver_freqs';
    plotbutton.MatlabArgs={'%source'};
    plotbutton.Enabled=false;


    if~fromLibrary
        if this.AutoFreq
            if isfield(this.Block.UserData,'tones')&&...
                ~isempty(this.Block.UserData.tones)
                toneVals=this.Block.UserData.tones;
                if max(toneVals)<1
                    Y=toneVals;
                    U='';
                else
                    [Y,~,U]=engunits(toneVals);
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
                this.Tones=strcat('[',num2str(Y),']');
                this.Tones_unit=strcat(U,'Hz');
                this.Harmonics=...
                strcat('[',num2str(this.Block.UserData.harmonics),']');
                toneList=str2num(this.Tones);%#ok<ST2NM>
                harmList=str2num(this.Harmonics);%#ok<ST2NM>
                plotbutton.Enabled=true;
            else
                findTonesAtCompile=true;
            end
        else
            tones.Enabled=1;
            tonesunit.Enabled=1;
            harmonics.Enabled=1;
        end
        if~strcmp(toneErr,'')
            totalfreqs.Name=getString(message(toneErr));
            errmsgid.Name=toneErr;
        elseif~strcmp(harmErr,'')
            totalfreqs.Name=getString(message(harmErr));
            errmsgid.Name=harmErr;
        elseif findTonesAtCompile==true||findHarmsAtCompile==true
            totalfreqs.Name=...
            getString(message('simrf:simrfV2solver:SimTime'));
        else
            if isscalar(harmList)
                harmList=ones(size(toneList))*harmList;
            end

            if length(toneList)>1
                nonZeroTones_idx=(toneList~=0);
                toneList=toneList(nonZeroTones_idx);
                harmList=harmList(nonZeroTones_idx);
            end
            if length(toneList)==1&&toneList==0

                totalfreqs.Name='1';
            else
                totalfreqs.Name=num2str((prod(2*harmList+1)+1)/2,'%g');
            end
            plotbutton.Enabled=true;
        end
    end


    rs_spec=rs_spec+1;
    stepsizeprompt=simrfV2GetLeafWidgetBase('text','Step size:',...
    'StepSizeprompt',0);
    stepsizeprompt.RowSpan=[rs_spec,rs_spec];
    stepsizeprompt.ColSpan=[lprompt_spec,rprompt_spec];

    stepsize=simrfV2GetLeafWidgetBase('edit','','StepSize',this,'StepSize');
    stepsize.RowSpan=[rs_spec,rs_spec];
    stepsize.ColSpan=[ledit_spec,redit_spec];
    stepsize.DialogRefresh=1;

    stepsizeunit=simrfV2GetLeafWidgetBase('combobox','','StepSize_unit',...
    this,'StepSize_unit');
    stepsizeunit.Entries=set(this,'StepSize_unit')';
    stepsizeunit.RowSpan=[rs_spec,rs_spec];
    stepsizeunit.ColSpan=[lunit_spec,runit_spec];
    stepsizeunit.DialogRefresh=1;

    StepSizeErr='';
    findStepSizeAtCompile=false;
    if~fromLibrary
        [evaluatedStepSize,isResolved]=slResolve(this.StepSize,hBlk);
        if~isResolved
            try
                evaluatedStepSize=evalin('base',this.StepSize);
            catch me
                if strcmpi(me.identifier,'MATLAB:UndefinedFunction')
                    findStepSizeAtCompile=true;
                elseif strcmpi(me.identifier,'MATLAB:m_missing_operator')||...
                    strcmpi(me.identifier,'MATLAB:m_incomplete_statement')
                    StepSizeErr='simrf:simrfV2solver:StepSizeBadSyntax';
                end
                evaluatedStepSize=[];
                lasterr('')%#ok<LERR>
            end
        end

        if findStepSizeAtCompile==false
            if~isempty(StepSizeErr)

            elseif isempty(evaluatedStepSize)
                StepSizeErr='simrf:simrfV2solver:StepSizeUndefined';
            elseif~isscalar(evaluatedStepSize)
                StepSizeErr='simrf:simrfV2solver:StepSizeNotScalar';
            elseif~isfinite(evaluatedStepSize)
                StepSizeErr='simrf:simrfV2solver:StepSizeNotFinite';
            elseif evaluatedStepSize<0
                StepSizeErr='simrf:simrfV2solver:StepSizeNonPositive';
            end
        end
    end


    rs_spec=rs_spec+1;
    envbwprompt=simrfV2GetLeafWidgetBase('text',...
    'Envelope bandwidth:','EnvBWprompt',0);
    envbwprompt.RowSpan=[rs_spec,rs_spec];
    envbwprompt.ColSpan=[lprompt_spec,rprompt_spec];


    envbw=simrfV2GetLeafWidgetBase('text','N/A','EnvBW',0);
    envbw.RowSpan=[rs_spec,rs_spec];
    envbw.ColSpan=[ledit_spec,redit_spec];


    errmsgidenvbw=simrfV2GetLeafWidgetBase('text','N/A','ErrMsgIdEnvBW',0);
    errmsgidenvbw.RowSpan=[rs_spec,rs_spec];
    errmsgidenvbw.ColSpan=[ledit_spec,redit_spec];
    errmsgidenvbw.Enabled=false;
    errmsgidenvbw.Visible=false;


    if~fromLibrary
        if~strcmp(StepSizeErr,'')
            envbw.Name=getString(message(StepSizeErr));
            errmsgidenvbw.Name=StepSizeErr;
        elseif findStepSizeAtCompile==true
            envbw.Name=...
            getString(message('simrf:simrfV2solver:SimTime'));
        else
            evaluatedStepSizeWithUnits=simrfV2convert2baseunit(...
            evaluatedStepSize,this.StepSize_unit);
            if evaluatedStepSizeWithUnits>1
                evaluatedBW=1/evaluatedStepSizeWithUnits;
                evaluatedBW_units='';
            else
                [evaluatedBW,evaluatedBW_exp,evaluatedBW_units]=...
                engunits(1/evaluatedStepSizeWithUnits);
                if(evaluatedBW_exp<1e-9)
                    evaluatedBW=evaluatedBW*(1/(evaluatedBW_exp))*1e-9;
                    evaluatedBW_units='G';
                end
            end
            envbw.Name=num2str(evaluatedBW,['%g ',evaluatedBW_units,'Hz']);
        end
    end


    lprompt_noise=1;
    rprompt_noise=3;
    ledit_noise=rprompt_noise+1;
    redit_noise=14;
    lunit_noise=redit_noise+1;
    runit_noise=20;


    rs_noise=1;
    addnoise=simrfV2GetLeafWidgetBase('checkbox','Simulate noise',...
    'AddNoise',this,'AddNoise');
    addnoise.RowSpan=[rs_noise,rs_noise];
    addnoise.ColSpan=[lprompt_noise,redit_noise];
    addnoise.DialogRefresh=1;


    spacerNoise=simrfV2GetLeafWidgetBase('text','                  ','',0);
    spacerNoise.RowSpan=[rs_noise,rs_noise];
    spacerNoise.ColSpan=[lunit_noise,runit_noise];


    rs_noise=rs_noise+1;
    defaultRNG=simrfV2GetLeafWidgetBase(...
    'checkbox','Use default random number generator',...
    'defaultRNG',this,'defaultRNG');
    defaultRNG.RowSpan=[rs_noise,rs_noise];
    defaultRNG.ColSpan=[lprompt_noise,redit_noise];
    defaultRNG.Visible=1;
    defaultRNG.DialogRefresh=1;

    rs_noise=rs_noise+1;
    seedprompt=simrfV2GetLeafWidgetBase('text','Noise seed:',...
    'Seedprompt',0);
    seedprompt.RowSpan=[rs_noise,rs_noise];
    seedprompt.ColSpan=[lprompt_noise,rprompt_noise];
    seedprompt.Visible=0;

    seed=simrfV2GetLeafWidgetBase('edit','','Seed',this,'Seed');
    seed.RowSpan=[rs_noise,rs_noise];
    seed.ColSpan=[ledit_noise,runit_noise];
    seed.Visible=0;


    slBlkVis_orig=get_param(hBlk,'MaskVisibilities');
    idxMaskNames=simrfV2getblockmaskparamsindex(hBlk);
    slBlkVis=slBlkVis_orig;
    slBlkVis([idxMaskNames.defaultRNG])={'on'};
    slBlkVis([idxMaskNames.Seed])={'off'};
    if~fromLibrary
        if(~this.AddNoise)
            defaultRNG.Visible=0;
            seedprompt.Visible=0;
            seed.Visible=0;
            slBlkVis([idxMaskNames.defaultRNG,idxMaskNames.Seed])={'off'};
        elseif(~this.defaultRNG)
            seedprompt.Visible=1;
            seed.Visible=1;
            slBlkVis([idxMaskNames.Seed])={'on'};
        end


        if any(cellfun(@(x)(strcmpi(x,'on')),slBlkVis)~=...
            cellfun(@(x)(strcmpi(x,'on')),slBlkVis_orig))



            set_param(hBlk,'MaskVisibilities',slBlkVis);









            tr=DAStudio.ToolRoot;
            dlgs=tr.getOpenDialogs;
            if~isempty(dlgs)
                dlgIndx=arrayfun(...
                @(x)(isa(x.getDialogSource,'simrfV2dialog.Solver')&&...
                (x.getDialogSource.get_param('handle')==hBlk)),dlgs);
                if any(dlgIndx)
                    dlgs(dlgIndx).setVisible('Tones',1);
                    dlgs(dlgIndx).setVisible('Harmonics',1);
                end
            end
        end
    end


    rs_noise=rs_noise+1;
    tempprompt=simrfV2GetLeafWidgetBase('text','Temperature:',...
    'TemperaturePrompt',0);
    tempprompt.RowSpan=[rs_noise,rs_noise];
    tempprompt.ColSpan=[lprompt_noise,rprompt_noise];

    temp=simrfV2GetLeafWidgetBase('edit','','Temperature',0,'Temperature');
    temp.RowSpan=[rs_noise,rs_noise];
    temp.ColSpan=[ledit_noise,redit_noise];

    tempunit=simrfV2GetLeafWidgetBase('combobox','','Temperature_unit',0,...
    'Temperature_unit');
    tempunit.Entries=set(this,'Temperature_unit')';
    tempunit.RowSpan=[rs_noise,rs_noise];
    tempunit.ColSpan=[lunit_noise,runit_noise];


    lprompt_nzc=1;
    rprompt_nzc=20;


    rs_nzc=1;
    spfprompt=simrfV2GetLeafWidgetBase('text','Samples per frame:',...
    'Spfprompt',0);
    spfprompt.RowSpan=[rs_nzc,rs_nzc];
    spfprompt.ColSpan=[lprompt_spec,rprompt_spec];

    spf=simrfV2GetLeafWidgetBase('edit','','SamplesPerFrame',this,...
    'SamplesPerFrame');
    spf.RowSpan=[rs_nzc,rs_nzc];
    spf.ColSpan=[ledit_spec,runit_spec];


    rs_nzc=rs_nzc+1;
    normalize_carrier_power=simrfV2GetLeafWidgetBase(...
    'checkbox','Normalize carrier power','NormalizeCarrierPower',this,...
    'NormalizeCarrierPower');
    normalize_carrier_power.RowSpan=[rs_nzc,rs_nzc];
    normalize_carrier_power.ColSpan=[lprompt_nzc,rprompt_nzc];
    normalize_carrier_power.DialogRefresh=1;


    rs_nzc=rs_nzc+1;
    enableInterpFilter=simrfV2GetLeafWidgetBase(...
    'checkbox','Enable input interpolation filter',...
    'EnableInterpFilter',this,'EnableInterpFilter');
    enableInterpFilter.RowSpan=[rs_nzc,rs_nzc];
    enableInterpFilter.ColSpan=[lprompt_nzc,rprompt_nzc];
    enableInterpFilter.DialogRefresh=1;

    rs_nzc=rs_nzc+1;
    delayMsgPrefix='Filter delay (in samples): ';
    delayMsg=...
    [delayMsgPrefix,getString(message('simrf:simrfV2solver:SimTime'))];
    if this.EnableInterpFilter
        ud=get_param(hBlk,'UserData');
        if isfield(ud,'FilterDelay')
            if(ud.FilterDelay~=0)
                delayMsg=[delayMsgPrefix,num2str(ud.FilterDelay)];
            else
                delayMsg=...
                getString(message('simrf:simrfV2solver:NoFilterNeeded'));
            end
        end
    end
    filterDelayMsg=simrfV2GetLeafWidgetBase('text',...
    delayMsg,'filterDelayMsg',0);
    filterDelayMsg.Visible=this.EnableInterpFilter;
    filterDelayMsg.RowSpan=[rs_nzc,rs_nzc];
    filterDelayMsg.ColSpan=[lprompt_nzc,rprompt_nzc];



    rs=1;
    spectrumprops.Type='group';
    spectrumprops.Name='Spectrum';
    spectrumprops.LayoutGrid=[rs_spec,runit_spec];
    spectrumprops.RowStretch=ones(1,rs_spec);
    spectrumprops.ColStretch=[ones(1,redit_spec)...
    ,zeros(1,runit_spec-redit_spec)];
    spectrumprops.ColSpan=[rs,rs];
    spectrumprops.RowStretch=[1,1];
    spectrumprops.Items={autofreq,tonesprompt,tones,tonesunit,...
    harmonicsprompt,harmonics,freqsprompt,totalfreqs,errmsgid,...
    plotbutton,stepsizeprompt,stepsize,stepsizeunit,...
    envbwprompt,envbw,errmsgidenvbw};
    spectrumprops.Tag='SpectrumContainer';


    rs=rs+1;
    noiseprops.Type='group';
    noiseprops.Name='Noise';
    noiseprops.LayoutGrid=[rs_noise,runit_noise];
    noiseprops.RowStretch=ones(1,rs_noise);
    noiseprops.ColStretch=[ones(1,redit_noise)...
    ,zeros(1,runit_noise-redit_noise)];
    noiseprops.ColSpan=[rs,rs];
    noiseprops.RowStretch=[1,1];
    noiseprops.Items={addnoise,spacerNoise,defaultRNG,seedprompt,seed,...
    tempprompt,temp,tempunit};
    noiseprops.Tag='NoiseContainer';


    rs=rs+1;
    iosignal.Type='group';
    iosignal.Name='Input/Output Signals';
    iosignal.LayoutGrid=[rs_nzc,rprompt_nzc];
    iosignal.RowStretch=ones(1,rs_nzc);
    iosignal.ColStretch=ones(1,rprompt_nzc);
    iosignal.RowSpan=[rs,rs];
    iosignal.ColSpan=[1,1];
    iosignal.Items={spfprompt,spf,normalize_carrier_power,...
    enableInterpFilter,filterDelayMsg};
    iosignal.Tag='IOSignalContainer';


    rs=rs+1;
    spacerMain=simrfV2GetLeafWidgetBase('text',' ','',0);
    spacerMain.RowSpan=[rs,rs];
    spacerMain.ColSpan=[lprompt_noise,rprompt_noise];


    items={spectrumprops,noiseprops,iosignal};
    layout.LayoutGrid=[rs,1];
    layout.RowSpan=[1,1];
    layout.ColSpan=[1,1];
    layout.RowStretch=[zeros(1,rs-1),1];
    layout.ColStretch=1;
