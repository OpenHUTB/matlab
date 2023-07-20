function[WantBlockChoice,Ts,sps]=ThreePhaseProgrammableGeneratorInit(varargin)




    block=varargin{1};

    if size(varargin,2)>1

        [Par_Vps,VariationEntity,VariationType,VariationStep,VariationRate,VariationMag,VariationFreq,Par_Timing_Variation,SinglePhase,Yampli,Xtime,HarmonicGeneration,Par_HarmoA,Par_HarmoB,Par_Timing_Harmo,Ts]=varargin{2:end};

    else


        MV=get_param(block,'MaskVisibilities');

        switch get_param(gcb,'VariationType');
        case 'Step'
            MV{4}='on';
            MV{5}='off';
            MV{6}='off';
            MV{7}='off';
            MV{8}='on';
            MV{9}='off';
            MV{10}='off';
            MV{11}='off';
        case 'Ramp'
            MV{4}='off';
            MV{5}='on';
            MV{6}='off';
            MV{7}='off';
            MV{8}='on';
            MV{9}='off';
            MV{10}='off';
            MV{11}='off';
        case 'Modulation'
            MV{4}='off';
            MV{5}='off';
            MV{6}='on';
            MV{7}='on';
            MV{8}='on';
            MV{9}='off';
            MV{10}='off';
            MV{11}='off';
        otherwise
            MV{4}='off';
            MV{5}='off';
            MV{6}='off';
            MV{7}='off';
            MV{8}='off';
            MV{9}='on';
            MV{10}='on';
            MV{11}='on';

        end

        switch get_param(block,'VariationEntity');
        case 'None'
            MV{3}='off';
            MV{4}='off';
            MV{5}='off';
            MV{6}='off';
            MV{7}='off';
            MV{8}='off';
            MV{9}='off';
            MV{10}='off';
            MV{11}='off';
        otherwise
            MV{3}='on';
        end

        switch get_param(block,'HarmonicGeneration')
        case 'on'
            MV{13}='on';
            MV{14}='on';
            MV{15}='on';
        case 'off'
            MV{13}='off';
            MV{14}='off';
            MV{15}='off';
        end

        set_param(gcb,'MaskVisibilities',MV);
        return
    end

    sps=[];

    [WantBlockChoice,Ts,~,Init]=DetermineBlockChoice(block,Ts,0,0);



    if Init

        Erreur.identifier='SpecializedPowerSystems:ProgrammableGeneratorBlock:ParameterError';
        BK=strrep(block,char(10),char(32));

        if length(Par_Vps)~=3
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The number of parameters provided the "Positive-sequence" parameter is incorrect (3 values are expected)',BK);
            psberror(Erreur);
            return
        end

        if length(Par_Timing_Variation)~=2
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The number of parameters provided the "Variation timing" parameter is incorrect (2 values are expected)',BK);
            psberror(Erreur);
            return
        end

        if length(Par_Timing_Harmo)~=2
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The number of parameters provided the "Harmonic timing" parameter is incorrect (2 values are expected)',BK);
            psberror(Erreur);
            return
        end

        if length(Xtime)~=length(Yampli)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The number of values specified in the "Amplitude values" and "Time values" parameters must be the same',BK);
            psberror(Erreur);
            return
        end

        sps.Mag_Vps=Par_Vps(1);
        sps.Phase_Vps=Par_Vps(2);
        sps.Freq_Vps=Par_Vps(3);

        sps.VariationEntity=VariationEntity;
        sps.VariationType=VariationType;
        sps.VariationStep=VariationStep;
        sps.VariationRate=VariationRate;
        sps.VariationMag=VariationMag;
        sps.VariationFreq=VariationFreq;
        sps.Par_Timing_Variation=Par_Timing_Variation;
        sps.SinglePhase=SinglePhase;
        sps.Yampli=Yampli;
        sps.Xtime=Xtime;
        if Xtime(1)~=0,
            sps.Xtime=[0,Xtime];
            sps.Yampli=[0,Yampli];
        end
        sps.HarmonicGeneration=HarmonicGeneration;

        sps.Ton_Variation=Par_Timing_Variation(1);
        sps.Toff_Variation=Par_Timing_Variation(2);

        sps.n_HarmoA=Par_HarmoA(1);
        sps.Mag_HarmoA=Par_HarmoA(2);
        sps.Phase_HarmoA=Par_HarmoA(3);
        sps.Seq_HarmoA=Par_HarmoA(4);
        if sps.n_HarmoA==0
            sps.Phase_HarmoA=90;
            sps.Seq_HarmoA=0;
        end

        sps.n_HarmoB=Par_HarmoB(1);
        sps.Mag_HarmoB=Par_HarmoB(2);
        sps.Phase_HarmoB=Par_HarmoB(3);
        sps.Seq_HarmoB=Par_HarmoB(4);
        if sps.n_HarmoB==0
            sps.Phase_HarmoB=90;
            sps.Seq_HarmoB=0;
        end

        sps.Ton_Harmo=Par_Timing_Harmo(1);
        sps.Toff_Harmo=Par_Timing_Harmo(2);
    end