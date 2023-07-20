function varargout=spsDrivesInverterThreePhaseInit(block)





    driveType=get_param(block,'driveType');

    switch driveType

    case 'Field-oriented control'
        Stator_im=getSPSmaskvalues(block,{'Stator_im'});
        Rotor=getSPSmaskvalues(block,{'Rotor'});
        Lm=getSPSmaskvalues(block,{'Lm'});
        SourceFrequency=getSPSmaskvalues(block,{'SourceFrequency'});

        Rs=Stator_im(1);
        Lls=Stator_im(2);
        Rr=Rotor(1);
        Llr=Rotor(2);
        Fcs=6*SourceFrequency/10;
        Lr=Llr+Lm;
        Ls=Lls+Lm;

        ReferenceFrame=get_param(block,'ReferenceFrame');
        switch ReferenceFrame
        case 'Rotor'
            Sel=1;
        case 'Stationary'
            Sel=2;
        case 'Synchronous'
            Sel=3;
        end

        varargout={Rs,Rr,Fcs,Lr,Ls,Sel};

    case 'Space vector modulation'

        varargout={};

    case 'WFSM vector control'
        Stator_sm=getSPSmaskvalues(block,{'Stator_sm'});
        SourceFrequency=getSPSmaskvalues(block,{'SourceFrequency'});
        ForwardVoltages=getSPSmaskvalues(block,{'ForwardVoltages'});

        Rs=Stator_sm(1);
        Ll=Stator_sm(2);
        Fcs=6*SourceFrequency/10;
        Vf=ForwardVoltages(1);
        Vfd=ForwardVoltages(2);

        varargout={Rs,Ll,Fcs,Vf,Vfd};

    case 'PMSM vector control'
        dqInductances=getSPSmaskvalues(block,{'dqInductances'});
        SourceFrequency=getSPSmaskvalues(block,{'SourceFrequency'});

        Ld=dqInductances(1);
        Lq=dqInductances(2);
        Fcs=6*SourceFrequency/10;

        varargout={Ld,Lq,Fcs};

    case 'Brushless DC'
        varargout={};

    otherwise
        error(message('physmod:powersys:common:InvalidParameter',block,driveType,'Drive type'));

    end