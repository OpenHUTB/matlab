function[items,layout]=simrfV2create_Solverparam_pane(this,varargin)




    hBlk=get_param(this,'Handle');
    fromLibrary=strcmpi(get_param(bdroot(hBlk),'BlockDiagramType'),'library');


    lprompt_tac=1;
    rprompt_tac=4;
    ledit_tac=rprompt_tac+1;
    redit_tac=16;
    lunit_tac=redit_tac+1;
    runit_tac=20;
    lbutton_tac=ledit_tac+8;
    rbutton_tac=runit_tac;

    rs_tac=1;
    solvertypeoptionprompt=simrfV2GetLeafWidgetBase('text',...
    'Transient analysis:','SolverTypeOptionprompt',0);
    solvertypeoptionprompt.RowSpan=[rs_tac,rs_tac];
    solvertypeoptionprompt.ColSpan=[lprompt_tac,rprompt_tac];

    solvertypeoption=simrfV2GetLeafWidgetBase('combobox','','SolverType',...
    this,'SolverType');
    solvertypeoption.Entries=set(this,'SolverType')';
    solvertypeoption.RowSpan=[rs_tac,rs_tac];
    solvertypeoption.ColSpan=[ledit_tac,runit_tac];
    solvertypeoption.DialogRefresh=1;


    rs_tac=rs_tac+1;
    smallsignalapprox=simrfV2GetLeafWidgetBase('checkbox',...
    'Approximate transient as small signal',...
    'SmallSignalApprox',this,'SmallSignalApprox');
    smallsignalapprox.RowSpan=[rs_tac,rs_tac];
    smallsignalapprox.ColSpan=[lprompt_tac,runit_tac];
    smallsignalapprox.DialogRefresh=1;


    rs_tac=rs_tac+1;
    allSimFreqsNum='';
    if((nargin>1)&&(~isempty(varargin{1})))
        if~isnan(str2double(varargin{1}))
            allSimFreqsNum=[varargin{1},' '];
        end
    end
    allSimFreqsText=['Use all ',allSimFreqsNum,'steady-state simulation '...
    ,'frequencies for small signal analysis'];
    allsimfreqs=simrfV2GetLeafWidgetBase('checkbox',allSimFreqsText,...
    'AllSimFreqs',this,'AllSimFreqs');
    allsimfreqs.RowSpan=[rs_tac,rs_tac];
    allsimfreqs.ColSpan=[lprompt_tac,runit_tac];
    allsimfreqs.Visible=0;
    allsimfreqs.DialogRefresh=1;

    rs_tac=rs_tac+1;
    simfreqsprompt=simrfV2GetLeafWidgetBase('text',...
    'Small signal frequencies:','SimFreqsprompt',0);
    simfreqsprompt.RowSpan=[rs_tac,rs_tac];
    simfreqsprompt.ColSpan=[lprompt_tac,rprompt_tac];
    simfreqsprompt.Visible=0;

    simfreqs=simrfV2GetLeafWidgetBase('edit','','SimFreqs',this,'SimFreqs');
    simfreqs.RowSpan=[rs_tac,rs_tac];
    simfreqs.ColSpan=[ledit_tac,redit_tac];
    simfreqs.Visible=0;
    simfreqs.DialogRefresh=1;

    simfreqsunit=simrfV2GetLeafWidgetBase('combobox','','SimFreqs_unit',...
    this,'SimFreqs_unit');
    simfreqsunit.Entries=set(this,'SimFreqs_unit')';
    simfreqsunit.RowSpan=[rs_tac,rs_tac];
    simfreqsunit.ColSpan=[lunit_tac,runit_tac];
    simfreqsunit.Visible=0;


    rs_tac=rs_tac+1;
    popfreqsbutton=simrfV2GetLeafWidgetBase('pushbutton',...
    'Populate Frequencies','PopFreqs',this,'PopFreqs');
    popfreqsbutton.RowSpan=[rs_tac,rs_tac];
    popfreqsbutton.ColSpan=[lbutton_tac,rbutton_tac];
    popfreqsbutton.Visible=0;
    popfreqsbutton.ObjectMethod='simrfV2populatefreqs';
    if isempty(allSimFreqsNum)
        popfreqsbutton.Enabled=false;
    else
        popfreqsbutton.Enabled=true;
    end


    slBlkVis_orig=get_param(hBlk,'MaskVisibilities');
    idxMaskNames=simrfV2getblockmaskparamsindex(hBlk);
    slBlkVis=slBlkVis_orig;
    slBlkVis([idxMaskNames.AllSimFreqs])={'off'};
    slBlkVis([idxMaskNames.SimFreqs])={'off'};
    slBlkVis([idxMaskNames.SimFreqs_unit])={'off'};
    if~fromLibrary
        if this.SmallSignalApprox
            allsimfreqs.Visible=1;
            slBlkVis([idxMaskNames.AllSimFreqs])={'on'};






            if~this.AllSimFreqs
                if(strcmp(slBlkVis_orig{idxMaskNames.SimFreqs},'off')&&...
                    strcmp(this.SimFreqs,'[]'))
                    this.SimFreqs=this.Tones;
                    this.SimFreqs_unit=this.Tones_unit;
                end
                simfreqsprompt.Visible=1;
                simfreqs.Visible=1;
                simfreqsunit.Visible=1;
                slBlkVis([idxMaskNames.SimFreqs...
                ,idxMaskNames.SimFreqs_unit])={'on'};
                popfreqsbutton.Visible=1;
            else







                if(strcmp(slBlkVis_orig{idxMaskNames.SimFreqs},'on')&&...
                    strcmp(this.SimFreqs,'[]')&&~strcmp(this.Tones,'[]'))
                    this.SimFreqs='[] ';
                end
            end
        end
        if any(cellfun(@(x)(strcmpi(x,'on')),slBlkVis)~=...
            cellfun(@(x)(strcmpi(x,'on')),slBlkVis_orig))
            set_param(hBlk,'MaskVisibilities',slBlkVis);



        end
    end


    lprompt_nic=1;
    rprompt_nic=4;
    ledit_nic=rprompt_nic+1;
    redit_nic=20;
    lbutton_nic=ledit_nic+9;
    rbutton_nic=redit_nic;


    rs_nic=1;
    reltolprompt=simrfV2GetLeafWidgetBase('text','Relative tolerance:',...
    'RelTolPrompt',0);
    reltolprompt.RowSpan=[rs_nic,rs_nic];
    reltolprompt.ColSpan=[lprompt_nic,rprompt_nic];

    reltol=simrfV2GetLeafWidgetBase('edit','','RelTol',0,'RelTol');
    reltol.RowSpan=[rs_nic,rs_nic];
    reltol.ColSpan=[ledit_nic,redit_nic];


    rs_nic=rs_nic+1;
    abstolprompt=simrfV2GetLeafWidgetBase('text',...
    'Absolute tolerance:','AbsTolPrompt',0);
    abstolprompt.RowSpan=[rs_nic,rs_nic];
    abstolprompt.ColSpan=[lprompt_nic,rprompt_nic];

    abstol=simrfV2GetLeafWidgetBase('edit','','AbsTol',0,...
    'AbsTol');
    abstol.RowSpan=[rs_nic,rs_nic];
    abstol.ColSpan=[ledit_nic,redit_nic];


    rs_nic=rs_nic+1;
    maxiterprompt=simrfV2GetLeafWidgetBase('text','Maximum iterations:',...
    'MaxIterPrompt',0);
    maxiterprompt.RowSpan=[rs_nic,rs_nic];
    maxiterprompt.ColSpan=[lprompt_nic,rprompt_nic];

    maxiter=simrfV2GetLeafWidgetBase('edit','','MaxIter',0,'MaxIter');
    maxiter.RowSpan=[rs_nic,rs_nic];
    maxiter.ColSpan=[ledit_nic,redit_nic];
    maxiter.Mode=1;


    rs_nic=rs_nic+1;
    errorestimationtypeprompt=simrfV2GetLeafWidgetBase('text',...
    'Error estimation:','ErrorEstimationTypeprompt',0);
    errorestimationtypeprompt.RowSpan=[rs_nic,rs_nic];
    errorestimationtypeprompt.ColSpan=[lprompt_nic,redit_nic];

    errorestimationtype=simrfV2GetLeafWidgetBase('combobox','',...
    'ErrorEstimationType',this,'ErrorEstimationType');
    errorestimationtype.Entries=set(this,'ErrorEstimationType')';
    errorestimationtype.RowSpan=[rs_nic,rs_nic];
    errorestimationtype.ColSpan=[ledit_nic,redit_nic];
    errorestimationtype.DialogRefresh=1;


    rs_nic=rs_nic+1;

    restoredefaultbutton=simrfV2GetLeafWidgetBase('pushbutton',...
    'Restore Default Settings','RestoreDefaultButton',this,...
    'RestoreDefaultButton');
    restoredefaultbutton.RowSpan=[rs_nic,rs_nic];
    restoredefaultbutton.ColSpan=[lbutton_nic,rbutton_nic];
    restoredefaultbutton.ObjectMethod='simrfV2restoresolverdefaults';



    rs=1;
    envelopesolverprops.Type='group';
    envelopesolverprops.Name='Envelope Solver';
    envelopesolverprops.LayoutGrid=[rs_tac,redit_tac];
    envelopesolverprops.RowStretch=ones(1,rs_tac);
    envelopesolverprops.ColStretch=ones(1,redit_tac);
    envelopesolverprops.RowSpan=[rs,rs];
    envelopesolverprops.ColSpan=[1,1];
    envelopesolverprops.Items={solvertypeoptionprompt,solvertypeoption,...
    smallsignalapprox,allsimfreqs,simfreqsprompt,simfreqs,...
    simfreqsunit,popfreqsbutton};
    envelopesolverprops.Tag='EnvelopeSolverContainer';


    rs=rs+1;
    newtonsolverprops.Type='group';
    newtonsolverprops.Name='Newton Solver';
    newtonsolverprops.LayoutGrid=[rs_nic,redit_nic];
    newtonsolverprops.RowStretch=ones(1,rs_nic);
    newtonsolverprops.ColStretch=ones(1,redit_nic);
    newtonsolverprops.RowSpan=[rs,rs];
    newtonsolverprops.ColSpan=[1,1];
    newtonsolverprops.Items={reltolprompt,reltol,...
    abstolprompt,abstol,maxiterprompt,maxiter,...
    errorestimationtypeprompt,errorestimationtype,restoredefaultbutton};
    newtonsolverprops.Tag='NewtonSolverContainer';


    rs=rs+1;
    spacerMain=simrfV2GetLeafWidgetBase('text',' ','',0);
    spacerMain.RowSpan=[rs,rs];
    spacerMain.ColSpan=[lprompt_nic,lprompt_nic];


    items={envelopesolverprops,newtonsolverprops};
    layout.LayoutGrid=[rs,1];
    layout.RowSpan=[1,1];
    layout.ColSpan=[1,1];
    layout.RowStretch=[zeros(1,rs-1),1];
    layout.ColStretch=1;
