function ST=GroundingTransformerInit(varargin)










    power_initmask();



    ST.Pnom=100e6;
    ST.Fnom=60;
    ST.Vnom=1e3;
    ST.R=.01;
    ST.L=.01;
    ST.Rm=500;
    ST.Lm=500;


    block=varargin{1};
    VerifyBlockWorkSpace=1;

    if nargin>1


        NominalPower=varargin{2};
        NominalVoltage=varargin{3};
        ZeroSequenceImpedance_pu=varargin{4};
        MagnetizationBranch_pu=varargin{5};
        ZeroSequenceImpedance_SI=varargin{6};
        MagnetizationBranch_SI=varargin{7};
        UNITS=varargin{8};

    else






        [NominalPower,WSStatus]=getSPSmaskvalues(block,{'NominalPower'},VerifyBlockWorkSpace);
        if WSStatus==0


            return
        end


        NominalVoltage=getSPSmaskvalues(block,{'NominalVoltage'});
        ZeroSequenceImpedance_pu=getSPSmaskvalues(block,{'ZeroSequenceImpedance_pu'});
        MagnetizationBranch_pu=getSPSmaskvalues(block,{'MagnetizationBranch_pu'});
        ZeroSequenceImpedance_SI=getSPSmaskvalues(block,{'ZeroSequenceImpedance_SI'});
        MagnetizationBranch_SI=getSPSmaskvalues(block,{'MagnetizationBranch_SI'});

        if isequal('SI',get_param(block,'UNITS'));
            UNITS=1;
        else
            UNITS=2;
        end

    end



    BaseResistance=NominalVoltage^2/NominalPower(1);




    WantSIunits=UNITS==1;
    WantPUunits=~WantSIunits;


    MaskVisibilities=get_param(block,'MaskVisibilities');
    if isequal('on',MaskVisibilities{4})

        HavePUunits=1;
        HaveSIunits=0;
    else
        HaveSIunits=1;
        HavePUunits=0;
    end

    if WantPUunits&&HaveSIunits


        R_pu=ZeroSequenceImpedance_SI(1)/BaseResistance;
        L_pu=ZeroSequenceImpedance_SI(2)/BaseResistance;
        Rm_pu=MagnetizationBranch_SI(1)/BaseResistance;
        Lm_pu=MagnetizationBranch_SI(2)/BaseResistance;


        set_param(block,'MaskVisibilities',{'on','on','on','on','on','off','off','on'})


        set_param(block,'ZeroSequenceImpedance_pu',mat2str([R_pu,L_pu],5));
        set_param(block,'MagnetizationBranch_pu',mat2str([Rm_pu,Lm_pu],5));

    elseif WantPUunits&&HavePUunits


        R_pu=ZeroSequenceImpedance_pu(1);
        L_pu=ZeroSequenceImpedance_pu(2);
        Rm_pu=MagnetizationBranch_pu(1);
        Lm_pu=MagnetizationBranch_pu(2);

    elseif WantSIunits&&HavePUunits


        R_pu=ZeroSequenceImpedance_pu(1);
        L_pu=ZeroSequenceImpedance_pu(2);
        Rm_pu=MagnetizationBranch_pu(1);
        Lm_pu=MagnetizationBranch_pu(2);


        R_SI=R_pu*BaseResistance;
        L_SI=L_pu*BaseResistance;
        Rm_SI=Rm_pu*BaseResistance;
        Lm_SI=Lm_pu*BaseResistance;


        set_param(block,'MaskVisibilities',{'on','on','on','off','off','on','on','on'})


        set_param(block,'ZeroSequenceImpedance_SI',mat2str([R_SI,L_SI],5));
        set_param(block,'MagnetizationBranch_SI',mat2str([Rm_SI,Lm_SI],5));

    elseif WantSIunits&&HaveSIunits


        R_pu=ZeroSequenceImpedance_SI(1)/BaseResistance;
        L_pu=ZeroSequenceImpedance_SI(2)/BaseResistance;
        Rm_pu=MagnetizationBranch_SI(1)/BaseResistance;
        Lm_pu=MagnetizationBranch_SI(2)/BaseResistance;

    end




    ST.Pnom=NominalPower(1)/3;
    ST.Fnom=NominalPower(2);

    ST.Vnom=NominalVoltage/sqrt(3)/sqrt(3);
    ST.R=R_pu*3/2;
    ST.L=L_pu*3/2;
    ST.Rm=Rm_pu;
    ST.Lm=Lm_pu;