function[solverfreq,solverblock,AddNoise,envtempK,...
    NormalizeCarrierPower,StepSize,SamplesPerFrame,Tones]=...
    simrfV2_find_solverparams(sys,block,onlynoiseinfo,forceCheck)

    if nargin<2
        block=[];
        onlynoiseinfo=false;
        forceCheck=false;
    end

    if nargin<3
        onlynoiseinfo=false;
        forceCheck=false;
    end

    if nargin<4
        forceCheck=false;
    end

    solverfreq=[];
    solverblock=[];
    envtempK=[];
    AddNoise=false;
    NormalizeCarrierPower=true;
    StepSize=1e-6;
    SamplesPerFrame=1;
    RFSolve=find_system(sys,'LookUnderMasks','all','FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'BlockType','SubSystem','classname','solver_simrf');

    if isempty(RFSolve)
        if strcmpi(get_param(sys,'SimulationStatus'),'updating')||...
            strcmpi(get_param(sys,'SimulationStatus'),'initializing')
            error(message('simrf:simrfV2errors:nosolverblock'));
        else
            return
        end
    end

    RFSolve=find_nearest(RFSolve,block,forceCheck);


    if isempty(RFSolve)
        return;
    end

    if iscell(RFSolve)
        solverblock=char(RFSolve{1});
    else
        solverblock=RFSolve;
    end

    idxMaskNames=simrfV2getblockmaskparamsindex(solverblock);
    MaskWSValues=simrfV2getblockmaskwsvalues(solverblock);
    MaskVals=get_param(solverblock,'MaskValues');

    AddNoise=MaskWSValues.AddNoise;
    NormalizeCarrierPower=MaskWSValues.NormalizeCarrierPower;
    SamplesPerFrame=MaskWSValues.SamplesPerFrame;

    if regexpi(get_param(sys,'SimulationStatus'),...
        '^(updating|initializing)$')
        solverBlkParent=get_param(solverblock,'Parent');
        if~contains(block,solverBlkParent)
            if strcmpi(get_param(solverBlkParent,'Type'),'block')
                srcLib=fileparts(get_param(solverBlkParent,'ReferenceBlock'));
                if regexpi(srcLib,'^(simrfV2testbenches|rfTestbenches_lib)$')
                    simNoise=get_param(solverBlkParent,'SimNoise');
                    try
                        set_param(solverBlkParent,'SimNoise',simNoise);
                    catch me %#ok<NASGU>

                    end
                end
            end
        end
    end

    try
        StepSize=simrfV2convert2baseunit(...
        slResolve(MaskVals{idxMaskNames.StepSize},solverblock),...
        MaskWSValues.StepSize_unit);
    catch me %#ok<NASGU>
        StepSize=simrfV2convert2baseunit(MaskWSValues.StepSize,...
        MaskWSValues.StepSize_unit);
    end

    try
        envtempK=convert2K(...
        slResolve(MaskVals{idxMaskNames.Temperature},solverblock),...
        MaskWSValues.Temperature_unit);
    catch me %#ok<NASGU>
        envtempK=convert2K(MaskWSValues.Temperature,...
        MaskWSValues.Temperature_unit);
    end

    if isempty(SamplesPerFrame)
        try
            SamplesPerFrame=slResolve(MaskVals{idxMaskNames.SamplesPerFrame},block);
        catch me %#ok<NASGU>
            SamplesPerFrame=MaskWSValues.SamplesPerFrame;
        end
    end

    if(onlynoiseinfo)
        return;
    end

    if MaskWSValues.AutoFreq
        [IPfreq,OPfreq]=simrfV2_find_solverIPOPfreqs(solverblock);

        Udata=get_param(solverblock,'UserData');
        if~isequal(Udata.IPfreq,IPfreq)||~isequal(Udata.OPfreq,OPfreq)
            [Tones,Harmonics]=simrfV2_fundamental_tones(IPfreq,OPfreq);
            Udata.tones=Tones;
            Udata.harmonics=Harmonics;
            Udata.IPfreq=IPfreq;
            Udata.OPfreq=OPfreq;
            set_param(solverblock,'UserData',Udata);
        else
            Tones=Udata.tones;
            Harmonics=Udata.harmonics;
        end

    else
        try
            Tones=slResolve(MaskVals{idxMaskNames.Tones},solverblock);
        catch me %#ok<NASGU> % specified value
            Tones=MaskWSValues.Tones;
        end
        Tones=simrfV2convert2baseunit(Tones,...
        MaskVals{idxMaskNames.Tones_unit});


        if length(Tones)>1
            ldcTones=(Tones~=0);
            Tones=Tones(ldcTones);
        end

        try
            Harmonics=slResolve(MaskVals{idxMaskNames.Harmonics},...
            solverblock);
        catch me %#ok<NASGU>
            Harmonics=MaskWSValues.Harmonics;
        end


        if isscalar(Harmonics)&&length(Tones)>1
            Harmonics=Harmonics(ones(size(Tones)));
        end

    end


    if length(Tones)>5||prod(2*Harmonics+1)>10000


        solverfreq=Tones;

        solverfreq(end+1)=0;
        solverfreq=unique(solverfreq);
    else
        [solverfreq,~]=simrfV2_sysfreqs(Tones,Harmonics,0);
    end

end

function x=convert2K(x,funit)

    switch upper(funit)
    case 'C'
        x=x+273.15;
    case 'FH'
        x=5/9*(x-32)+273.15;
    end

end

function output=find_nearest(RFEnv,block,forceCheck)

    output=RFEnv;
    if isempty(block)||(numel(RFEnv)==1&&~forceCheck)
        return;
    end

    output=simrfV2_findConnected(block,'simrfV2util1/Configuration');

end
