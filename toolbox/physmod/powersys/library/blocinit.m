function blocinit(block,values)





    block=getfullname(block);
    MaskType=get_param(block,'MaskType');

    switch MaskType

    case{'DC machine','Discrete DC machine'}


        RLa=values{2};
        RLf=values{3};
        Laf=values{4};
        J=values{5};
        Bm=values{6};
        Tf=values{7};
        w0=values{8};

        errorIsempty(RLa,'Armature resistance and inductance',block);
        errorVector(RLa,'Armature resistance and inductance',[1,2],block);
        errorIsempty(RLf,'Field resistance and inductance',block);
        errorVector(RLf,'Field resistance and inductance',[1,2],block);

        errorIsempty(Laf,'Field armature mutual inductance',block);
        errorScalar(Laf,'Field armature mutual inductance',block);
        errorInf(Laf,'Field armature mutual inductance',block);
        errorIsempty(J,'J',block);
        errorScalar(J,'J',block);
        errorInf(J,'J',block);
        errorIsempty(Bm,'Bm',block);
        errorScalar(Bm,'Bm',block);
        errorInf(Bm,'Bm',block);
        errorIsempty(Tf,'Tf',block);
        errorScalar(Tf,'Tf',block);
        errorInf(Tf,'Tf',block);
        errorIsempty(w0,'w0',block);
        errorScalar(w0,'w0',block);
        errorInf(w0,'w0',block);

    case{'Series RLC Branch','Three-Phase Series RLC Branch'}

        R=values{1};
        L=values{2};
        C=values{3};

        errorIsempty(R,'R',block);
        errorIsempty(L,'L',block);
        errorIsempty(C,'C',block);
        errorScalar(R,'R',block);
        errorScalar(L,'L',block);
        errorScalar(C,'C',block);





    case{'Parallel RLC Branch','Three-Phase Parallel RLC Branch'}

        R=values{1};
        L=values{2};
        C=values{3};

        errorIsempty(R,'R',block);
        errorIsempty(L,'L',block);
        errorIsempty(C,'C',block);
        errorScalar(R,'R',block);
        errorScalar(L,'L',block);
        errorScalar(C,'C',block);

        errorNzero(R,'R',block);
        errorNzero(L,'L',block);
        errorInf(C,'C',block);

    case{'Series RLC Load','Three-Phase Series RLC Load'}

        Vn=values{1};
        fn=values{2};
        P=values{3};
        QL=values{4};
        QC=values{5};

        errorIsempty(Vn,'Vn',block);
        errorIsempty(fn,'fn',block);
        errorIsempty(P,'P',block);
        errorIsempty(QL,'QL',block);
        errorIsempty(QC,'QC',block);
        errorScalar(Vn,'Vn',block);
        errorScalar(fn,'fn',block);
        errorScalar(P,'P',block);
        errorScalar(QL,'QL',block);
        errorScalar(QC,'QC',block);
        errorGTzero(Vn,'Vn',block);
        errorGTzero(fn,'fn',block);
        errorPositive(P,'P',block);
        errorPositive(QL,'QL',block);
        errorPositive(QC,'QC',block);
        errorInf(Vn,'Vn',block);
        errorInf(fn,'fn',block);
        errorInf(P,'P',block);
        errorInf(QL,'QL',block);
        errorInf(QC,'QC',block);

        if P==0&&QL==0&&QC==0
            pere=bdroot(block);
            block=strrep(block,newline,' ');
            block=strrep(block,pere,'');
            block=block(2:end);
            message=['In mask of ''',block,''' block:',newline,'A minimum of one of P, QL, or QC parameters must be different from zero.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end

    case{'Parallel RLC Load','Three-Phase Parallel RLC Load'}

        Vn=values{1};
        fn=values{2};
        P=values{3};
        QL=values{4};
        QC=values{5};

        errorIsempty(Vn,'Vn',block);
        errorIsempty(fn,'fn',block);
        errorIsempty(P,'P',block);
        errorIsempty(QL,'QL',block);
        errorIsempty(QC,'QC',block);
        errorScalar(Vn,'Vn',block);
        errorScalar(fn,'fn',block);
        errorScalar(P,'P',block);
        errorScalar(QL,'QL',block);
        errorScalar(QC,'QC',block);
        errorGTzero(Vn,'Vn',block);
        errorGTzero(fn,'fn',block);
        errorPositive(P,'P',block);
        errorPositive(QL,'QL',block);
        errorPositive(QC,'QC',block);
        errorInf(Vn,'Vn',block);
        errorInf(fn,'fn',block);
        errorInf(P,'P',block);
        errorInf(QL,'QL',block);
        errorInf(QC,'QC',block);

        if P==0&&QL==0&&QC==0
            pere=bdroot(block);
            block=strrep(block,newline,' ');
            block=strrep(block,pere,'');
            block=block(2:end);
            message=['In mask of ''',block,''' block:',newline,'A minimum of one of P, QL, or QC parameters must be different from zero.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end

    case 'Linear Transformer'

        NpNf=values{1};
        W1=values{2};
        W2=values{3};
        w3check=values{4};
        W3=values{5};
        Mag=values{6};

        errorIsempty(NpNf,'Nominal power and frequency',block);
        errorIsempty(W1,'Winding no.1',block);
        errorIsempty(W2,'Winding no.2',block);
        errorIsempty(W3,'winding no.3',block);
        errorIsempty(Mag,'[Rm , Xm]',block);
        errorVector(NpNf,'Nominal power and frequency',[1,2],block);
        errorVector(W1,'Winding no.1',[1,3],block);
        errorVector(W2,'Winding no.2',[1,3],block);
        if w3check
            errorVector(W3,'winding 3',[1,3],block);
            V3=W3(1);
            R3=W3(2);
            L3=W3(3);
            errorInf(V3,'V3',block);
            errorInf(R3,'R3',block);
            errorInf(L3,'L3',block);
            errorPositive(V3,'V3',block);
        end
        errorVector(Mag,'[Rm , Xm]',[1,2],block);
        Pn=NpNf(1);
        fn=NpNf(2);
        V1=W1(1);
        R1=W1(2);
        L1=W1(3);
        V2=W2(1);
        R2=W2(2);
        L2=W2(3);
        Rm=Mag(1);
        errorInf(Pn,'Nominal power',block);
        errorInf(fn,'Nominal frequency',block);
        errorInf(V1,'V1',block);
        errorInf(R1,'R1',block);
        errorInf(L1,'L1',block);
        errorInf(V2,'V2',block);
        errorInf(R2,'R2',block);
        errorInf(L2,'L2',block);

        errorPositive(V1,'V1',block);
        errorPositive(V2,'V2',block);
        if w3check
            errorVector(W3,'winding no.3',[1,3],block);
            V3=W3(1);
            R3=W3(2);
            L3=W3(3);
            errorInf(V3,'V3',block);
            errorInf(R3,'R3',block);
            errorInf(L3,'L3',block);
            errorPositive(V3,'V3',block);
        end

        errorL1RmTransfo(L1,Rm,block);

    case 'Mutual Inductance'

        W1=values{1};
        W2=values{2};
        w3check=values{3};
        W3=values{4};
        Mut=values{5};

        errorIsempty(W1,'Winding 1',block);
        errorIsempty(W2,'Winding 2',block);
        errorIsempty(W3,'Winding 3',block);
        errorIsempty(Mut,'Mutual impedance',block);
        errorVector(W1,'Winding 1',[1,2],block);
        errorVector(W2,'Winding 2',[1,2],block);
        errorVector(Mut,'Mutual impedance',[1,2],block);
        R1=W1(1);
        L1=W1(2);
        R2=W2(1);
        L2=W2(2);
        Rm=Mut(1);
        Lm=Mut(2);
        errorInf(R1,'R1',block);
        errorInf(L1,'L1',block);
        errorInf(R2,'R2',block);
        errorInf(L2,'L2',block);
        errorDifferent(R1,Rm,'R1',block);
        errorDifferent(L1,Lm,'L1',block);
        errorDifferent(R2,Rm,'R2',block);
        errorDifferent(L2,Lm,'L2',block);
        if w3check
            errorVector(W3,'Winding 3',[1,2],block);
            R3=W3(1);
            L3=W3(2);
            errorInf(R3,'R3',block);
            errorInf(L3,'L3',block);
            errorDifferent(R3,Rm,'R3',block);
            errorDifferent(L3,Lm,'L3',block);
        end

    case 'Pi Section Line'

        P=values{1};
        f=values{2};
        R=values{3};
        L=values{4};
        C=values{5};
        longeur=values{6};
        sections=values{7};

        errorIsempty(P,'Frequency',block);
        errorIsempty(f,'Frequency',block);
        errorIsempty(R,'Resistance',block);
        errorIsempty(L,'Inductance',block);
        errorIsempty(C,'Capacitance',block);
        errorIsempty(longeur,'Length',block);
        errorIsempty(sections,'Number of pi sections',block);

        errorGTzero(P,'Phases',block);
        errorGTzero(f,'Frequency',block);
        errorGTzero(R,'Resistance',block);
        errorGTzero(L,'Inductance',block);
        errorGTzero(C,'Capacitance',block);
        errorGTzero(longeur,'Length',block);
        errorGTzero(sections,'Number of pi sections',block);

        errorInf(P,'Phases',block);
        errorInf(f,'Frequency',block);
        errorInf(R,'Resistance',block);
        errorInf(L,'Inductance',block);
        errorInf(C,'Capacitance',block);
        errorInf(longeur,'Length',block);
        errorInf(sections,'Number of pi sections',block);

        errorScalar(f,'Frequency',block);
        if P==1
            errorScalar(R,'Resistance',block);
            errorScalar(L,'Inductance',block);
            errorScalar(C,'Capacitance',block);
        else
            errorVector(R,'Resistance',[P,P],block);
            errorVector(L,'Inductance',[P,P],block);
            errorVector(C,'Capacitance',[P,P],block);
        end

        errorScalar(longeur,'Length',block);
        errorScalar(sections,'Number of pi sections',block);

        if sections~=fix(sections)
            pere=bdroot(block);
            block=strrep(block,newline,' ');
            block=strrep(block,pere,'');
            block=block(2:end);
            message=['In mask of ''',block,''' block:',newline,'The number of pi sections must be an integer value.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end


    case 'Three-Phase PI Section Line'

        f=values{1};
        R=values{2};
        L=values{3};
        C=values{4};
        longeur=values{5};

        errorIsempty(f,'Frequency used for R L C specification',block);
        errorIsempty(R,'Positive- and zero-sequence resistances',block);
        errorIsempty(L,'Positive- and zero-sequence inductances',block);
        errorIsempty(C,'Positive- and zero-sequence capacitances',block);
        errorIsempty(longeur,'Line section length',block);

        errorScalar(f,'Frequency used for R L C specification',block);
        errorVector(R,'Positive- and zero-sequence resistances',[1,2],block);
        errorVector(L,'Positive- and zero-sequence inductances',[1,2],block);
        errorVector(C,'Positive- and zero-sequence capacitances',[1,2],block);
        errorScalar(longeur,'Line section length',block);

        errorGTzero(f,'Frequency used for R L C specification',block);
        errorGTzero(L(1),'Positive-sequence inductance',block);
        errorGTzero(C(1),'Positive-sequence capacitance',block);
        errorGTzero(L(2),'Zero-sequence inductance',block);
        errorGTzero(C(2),'Zero-sequence capacitance',block);
        errorGTzero(longeur,'Line section length',block);

    case 'Ideal Switch'

        Ron=values{1};
        Ist=values{4};
        Rs=values{5};
        Cs=values{6};

        errorIsempty(Ron,'Ron',block);
        errorIsempty(Ist,'Initial state',block);
        errorIsempty(Rs,'Rs',block);
        errorIsempty(Cs,'Cs',block);
        errorScalar(Ron,'Ron',block);
        errorScalar(Ist,'Initial state',block);
        errorScalar(Rs,'Rs',block);
        errorScalar(Cs,'Cs',block);
        errorGTzero(Ron,'Ron',block);
        errorInf(Ron,'Ron',block);
        errorBin(Ist,'Initial state',block);
        errorPositive(Rs,'Rs',block);
        errorPositive(Cs,'Cs',block);
        if(Rs==0&&Cs==Inf)
            errorSnubber(block);
        end

    case 'Breaker'

        Ron=values{1};
        Ist=values{2};
        Rs=values{3};
        Cs=values{4};
        Swt=values{5};
        Ts=values{6};
        Exctrl=values{7};

        errorIsempty(Ron,'Ron',block);
        errorIsempty(Ist,'Initial state',block);
        errorIsempty(Rs,'Rs',block);
        errorIsempty(Cs,'Cs',block);
        errorScalar(Ron,'Ron',block);
        errorScalar(Ist,'Initial state',block);
        errorScalar(Rs,'Rs',block);
        errorScalar(Cs,'Cs',block);
        errorInf(Ron,'Ron',block);
        errorBin(Ist,'Initial state',block);
        errorPositive(Rs,'Rs',block);
        errorPositive(Cs,'Cs',block);
        if(Rs==0&&Cs==Inf)
            errorSnubber(block);
        end
        if strcmp(Exctrl,'off')
            errorIsempty(Swt,'Swt',block);
            errorIsempty(Ts,'Ts',block);
            errorScalar(Ts,'Ts',block);
            errorInf(Ts,'Ts',block);
        end

    case 'Diode'

        Ron=values{1};
        Lon=values{2};
        Vf=values{3};
        Ic=values{4};
        Rs=values{5};
        Cs=values{6};

        errorIsempty(Ron,'Ron',block);
        errorIsempty(Lon,'Lon',block);
        errorIsempty(Vf,'Vf',block);
        errorIsempty(Ic,'Ic',block);
        errorIsempty(Rs,'Rs',block);
        errorIsempty(Cs,'Cs',block);
        errorScalar(Ron,'Ron',block);
        errorScalar(Lon,'Lon',block);
        errorScalar(Vf,'Vf',block);
        errorScalar(Ic,'Ic',block);
        errorScalar(Rs,'Rs',block);
        errorScalar(Cs,'Cs',block);
        errorPositive(Ron,'Ron',block);
        errorInf(Ron,'Ron',block);
        errorPositive(Lon,'Lon',block);
        errorInf(Lon,'Lon',block);
        errorPositive(Rs,'Rs',block);
        errorPositive(Cs,'Cs',block);
        if(Rs==0&&Cs==Inf)
            errorSnubber(block);
        end

    case 'Thyristor'

        Ron=values{1};
        Lon=values{2};
        Vf=values{3};
        Ic=values{4};
        Rs=values{5};
        Cs=values{6};

        errorIsempty(Ron,'Ron',block);
        errorIsempty(Lon,'Lon',block);
        errorIsempty(Vf,'Vf',block);
        errorIsempty(Ic,'Ic',block);
        errorIsempty(Rs,'Rs',block);
        errorIsempty(Cs,'Cs',block);
        errorScalar(Ron,'Ron',block);
        errorScalar(Lon,'Lon',block);
        errorScalar(Vf,'Vf',block);
        errorScalar(Ic,'Ic',block);
        errorScalar(Rs,'Rs',block);
        errorScalar(Cs,'Cs',block);
        errorPositive(Ron,'Ron',block);
        errorInf(Ron,'Ron',block);
        errorPositive(Lon,'Lon',block);
        errorInf(Lon,'Lon',block);
        errorPositive(Rs,'Rs',block);
        errorPositive(Cs,'Cs',block);
        if(Rs==0&&Cs==Inf)
            errorSnubber(block);
        end

    case 'Detailed Thyristor'

        Ron=values{1};
        Lon=values{2};
        Vf=values{3};
        Il=values{4};
        Tq=values{5};
        Ic=values{6};
        Rs=values{7};
        Cs=values{8};

        errorIsempty(Ron,'Ron',block);
        errorIsempty(Lon,'Lon',block);
        errorIsempty(Vf,'Vf',block);
        errorIsempty(Il,'Il',block);
        errorIsempty(Tq,'Tq',block);
        errorIsempty(Ic,'Ic',block);
        errorIsempty(Rs,'Rs',block);
        errorIsempty(Cs,'Cs',block);

        errorScalar(Ron,'Ron',block);
        errorScalar(Lon,'Lon',block);
        errorScalar(Vf,'Vf',block);
        errorScalar(Il,'Il',block);
        errorScalar(Tq,'Tq',block);
        errorScalar(Ic,'Ic',block);
        errorScalar(Rs,'Rs',block);
        errorScalar(Cs,'Cs',block);

        errorInf(Ron,'Ron',block);
        errorInf(Lon,'Lon',block);
        errorInf(Vf,'Vf',block);
        errorInf(Il,'Il',block);
        errorInf(Tq,'Tq',block);
        errorInf(Ic,'Ic',block);

        errorPositive(Rs,'Rs',block);
        errorPositive(Cs,'Cs',block);
        if(Rs==0&&Cs==Inf)
            errorSnubber(block);
        end

        if Tq>0.004


            message{1}='The following Detailed Thyristor block have Turn-off time Tq value that appears to be very high:';
            message{2}=' ';
            message2{1}=' ';
            message2{2}='Typical values for Tq are from a few micro-seconds up to maximum value of about 0.004s';
            message=[message';block;message2'];

            warning('SpecializedPowerSystems:block:UnrealisticParameter',message{:});
        end


    case 'Gto'

        Ron=values{1};
        Lon=values{2};
        Vf=values{3};
        Tf=values{4};
        Tt=values{5};
        Ic=values{6};
        Rs=values{7};
        Cs=values{8};

        errorIsempty(Ron,'Ron',block);
        errorIsempty(Lon,'Lon',block);
        errorIsempty(Vf,'Vf',block);
        errorIsempty(Tf,'Tf',block);
        errorIsempty(Tt,'Tt',block);
        errorIsempty(Ic,'Ic',block);
        errorIsempty(Rs,'Rs',block);
        errorIsempty(Cs,'Cs',block);

        errorScalar(Ron,'Ron',block);
        errorScalar(Lon,'Lon',block);
        errorScalar(Vf,'Vf',block);
        errorScalar(Tf,'Tf',block);
        errorScalar(Tt,'Tt',block);
        errorScalar(Ic,'Ic',block);
        errorScalar(Rs,'Rs',block);
        errorScalar(Cs,'Cs',block);

        errorInf(Ron,'Ron',block);
        errorInf(Lon,'Lon',block);
        errorInf(Vf,'Vf',block);
        errorInf(Tf,'Tf',block);
        errorInf(Tt,'Tt',block);
        errorInf(Ic,'Il',block);

        errorPositive(Rs,'Rs',block);
        errorPositive(Cs,'Cs',block);
        if(Rs==0&&Cs==Inf)
            errorSnubber(block);
        end

    case 'Mosfet'

        Ron=values{1};
        Lon=values{2};
        Rd=values{3};
        Ic=values{4};
        Rs=values{5};
        Cs=values{6};

        errorIsempty(Ron,'Ron',block);
        errorIsempty(Lon,'Lon',block);
        errorIsempty(Rd,'Rd',block);
        errorIsempty(Ic,'Ic',block);
        errorIsempty(Rs,'Rs',block);
        errorIsempty(Cs,'Cs',block);

        errorScalar(Ron,'Ron',block);
        errorScalar(Lon,'Lon',block);
        errorScalar(Rd,'Rd',block);
        errorScalar(Ic,'Ic',block);
        errorScalar(Rs,'Rs',block);
        errorScalar(Cs,'Cs',block);

        errorInf(Ron,'Ron',block);
        errorInf(Lon,'Lon',block);
        errorInf(Rd,'Rd',block);
        errorInf(Ic,'Ic',block);

        errorPositive(Rs,'Rs',block);
        errorPositive(Cs,'Cs',block);
        if(Rs==0&&Cs==Inf)
            errorSnubber(block);
        end

    case 'IGBT'

        Ron=values{1};
        Lon=values{2};
        Vf=values{3};
        Tf=values{4};
        Tt=values{5};
        Ic=values{6};
        Rs=values{7};
        Cs=values{8};

        errorIsempty(Ron,'Ron',block);
        errorIsempty(Lon,'Lon',block);
        errorIsempty(Vf,'Vf',block);
        errorIsempty(Tf,'Tf',block);
        errorIsempty(Tt,'Tt',block);
        errorIsempty(Ic,'Ic',block);
        errorIsempty(Rs,'Rs',block);
        errorIsempty(Cs,'Cs',block);

        errorScalar(Ron,'Ron',block);
        errorScalar(Lon,'Lon',block);
        errorScalar(Vf,'Vf',block);
        errorScalar(Tf,'Tf',block);
        errorScalar(Tt,'Tt',block);
        errorScalar(Ic,'Ic',block);
        errorScalar(Rs,'Rs',block);
        errorScalar(Cs,'Cs',block);

        errorInf(Ron,'Ron',block);
        errorInf(Lon,'Lon',block);
        errorInf(Vf,'Vf',block);
        errorInf(Tf,'Tf',block);
        errorInf(Tt,'Tt',block);
        errorInf(Ic,'Il',block);

        errorPositive(Rs,'Rs',block);
        errorPositive(Cs,'Cs',block);
        if(Rs==0&&Cs==Inf)
            errorSnubber(block);
        end

    case 'IGBT/Diode'

        Ron=values{1};
        Rs=values{2};
        Cs=values{3};
        errorIsempty(Ron,'Ron',block);
        errorIsempty(Rs,'Rs',block);
        errorIsempty(Cs,'Cs',block);
        errorScalar(Ron,'Ron',block);
        errorScalar(Rs,'Rs',block);
        errorScalar(Cs,'Cs',block);
        errorInf(Ron,'Ron',block);
        errorPositive(Rs,'Rs',block);
        errorPositive(Cs,'Cs',block);
        if(Rs==0&&Cs==Inf)
            errorSnubber(block);
        end

    case 'Simplified Synchronous Machine'

        Type=values{1};%#ok
        NomParam=values{2};
        Mech=values{3};
        Imped=values{4};
        IC=values{5};

        errorIsempty(NomParam,'Nominal power',block);
        errorIsempty(Mech,'Inertia',block);
        errorIsempty(Imped,'Internal impedance',block);
        errorIsempty(IC,'Initial conditions',block);

        errorVector(NomParam,'Nominal power',[1,3],block);
        errorVector(Mech,'Inertia',[1,3],block);
        errorVector(Imped,'Internal impedance',[1,2],block);
        errorVector(IC,'Initial conditions',[1,8],block);

    case 'Synchronous Machine Std'

        Rotor=values{1};
        Nominal=values{2};
        React2=values{3};
        React1=values{4};
        daxis=values{5};
        qaxis=values{6};
        Tcte1=values{7};
        Tcte2=values{8};
        Tcte3=values{9};
        Tcte4=values{10};
        Tcte5=values{11};
        Tcte6=values{12};
        Tcte7=values{13};
        Tcte8=values{14};
        Stator=values{15};
        Coeff=values{16};
        Init=values{17};%#ok
        Simusat=values{18};%#ok
        Satparam=values{19};%#ok

        errorIsempty(Nominal,'Nominal power ...',block);
        errorVector(Nominal,'Nominal power ..',[1,3],block);

        pere=bdroot(block);
        block=strrep(block,newline,' ');
        block=strrep(block,pere,'');
        block=block(2:end);

        if strcmp(Rotor,'Round')
            premier=2;
            errorIsempty(React2,'Reactances',block);
            errorVector(React2,'Reactances',[1,7],block);
            if~all(gt(React2,0))
                errorGTzero(-1,'Reactances',block);
            end
            xd=React2(1);
            xq=React2(4);
            xqp=React2(5);
            xdp=React2(2);
            xqpp=React2(6);
            xdpp=React2(3);
            xL=React2(7);
            if~(xd>=xq)


            end
            if~(xq>xqp)


            end
            if~(xqp>=xdp)


            end
            if~(xdp>xqpp)


            end
            if~(xqpp>=xdpp)


            end
            if~(xq>xL)


            end

        else
            premier=1;
            errorIsempty(React1,'Reactances',block);
            errorVector(React1,'Reactances',[1,6],block);
            if~all(gt(React1,0))
                errorGTzero(-1,'Reactances',block);
            end
            xd=React1(1);
            xq=React1(4);
            xdp=React1(2);
            xqpp=React1(5);
            xdpp=React1(3);
            xL=React1(6);
            if~(xd>=xq)


            end
            if~(xq>xdp)


            end
            if~(xdp>xqpp)


            end
            if~(xqpp>=xdpp)


            end
            if~(xq>xL)


            end

        end

        if strcmp(daxis,'Open-circuit')
            second=1;
        else
            second=2;
        end
        if strcmp(qaxis,'Open-circuit')
            troisieme=1;
        else
            troisieme=2;
        end

        etat=mat2str([premier,second,troisieme]);
        switch etat
        case '[1 1 1]'

            errorIsempty(Tcte1,'Time constants',block);
            errorVector(Tcte1,'Time constants',[1,3],block);
            if~all(gt(Tcte1,0))
                errorGTzero(-1,'Time constants',block);
            end
            td0p=Tcte1(1);
            td0pp=Tcte1(2);
            if~(td0p>td0pp)


            end

        case '[2 1 1]'

            errorIsempty(Tcte2,'Time constants',block);
            errorVector(Tcte2,'Time constants',[1,4],block);
            if~all(gt(Tcte2,0))
                errorGTzero(-1,'Time constants',block);
            end
            td0p=Tcte2(1);
            td0pp=Tcte2(2);
            if~(td0p>td0pp)


            end
            tq0p=Tcte2(3);
            tq0pp=Tcte2(4);
            if~(tq0p>tq0pp)


            end

        case '[1 1 2]'

            errorIsempty(Tcte3,'Time constants',block);
            errorVector(Tcte3,'Time constants',[1,3],block);
            if~all(gt(Tcte3,0))
                errorGTzero(-1,'Time constants',block);
            end
            td0p=Tcte3(1);
            td0pp=Tcte3(2);
            if~(td0p>td0pp)


            end

        case '[2 1 2]'

            errorIsempty(Tcte4,'Time constants',block);
            errorVector(Tcte4,'Time constants',[1,4],block);
            if~all(gt(Tcte4,0))
                errorGTzero(-1,'Time constants',block);
            end
            td0p=Tcte4(1);
            td0pp=Tcte4(2);
            if~(td0p>td0pp)


            end
            tqp=Tcte4(3);
            tqpp=Tcte4(4);
            if~(tqp>tqpp)


            end

        case '[1 2 1]'

            errorIsempty(Tcte5,'Time constants',block);
            errorVector(Tcte5,'Time constants',[1,3],block);
            if~all(gt(Tcte5,0))
                errorGTzero(-1,'Time constants',block);
            end
            tdp=Tcte5(1);
            tdpp=Tcte5(2);
            if~(tdp>tdpp)


            end

        case '[2 2 1]'

            errorIsempty(Tcte6,'Time constants',block);
            errorVector(Tcte6,'Time constants',[1,4],block);
            if~all(gt(Tcte6,0))
                errorGTzero(-1,'Time constants',block);
            end
            tdp=Tcte6(1);
            tdpp=Tcte6(2);
            if~(tdp>tdpp)


            end
            tq0p=Tcte6(3);
            tq0pp=Tcte6(4);
            if~(tq0p>tq0pp)


            end

        case '[1 2 2]'

            errorIsempty(Tcte7,'Time constants',block);
            errorVector(Tcte7,'Time constants',[1,3],block);
            if~all(gt(Tcte7,0))
                errorGTzero(-1,'Time constants',block);
            end
            tdp=Tcte7(1);
            tdpp=Tcte7(2);
            if~(tdp>tdpp)


            end

        case '[2 2 2]'

            errorIsempty(Tcte8,'Time constants',block);
            errorVector(Tcte8,'Time constants',[1,4],block);
            if~all(gt(Tcte8,0))
                errorGTzero(-1,'Time constants',block);
            end
            tdp=Tcte8(1);
            tdpp=Tcte8(2);
            if~(tdp>tdpp)


            end
            tqp=Tcte8(3);
            tqpp=Tcte8(4);
            if~(tqp>tqpp)


            end

        end

        errorIsempty(Stator,'Stator Resistance',block);
        errorScalar(Stator,'Stator Resistance',block);
        H=Coeff(1);
        F=Coeff(2);%#ok
        P=Coeff(3);
        errorGTzero(H,'Coefficient of inertia H',block);
        errorGTzero(P,'pole pairs p',block);

    case 'Synchronous Machine Fond'

        Rotor=values{1};
        Nominal=values{2};
        Stator=values{3};
        Field=values{4};
        Damper2=values{5};
        Damper1=values{6};
        Coeff=values{7};
        Init=values{8};
        Simusat=values{9};
        Satparam=values{10};

        errorIsempty(Nominal,'Nominal power ...',block);
        errorIsempty(Stator,'Stator',block);
        errorIsempty(Field,'Field',block);






        if mod==0
            errorVector(Nominal,'Nominal power ..',[1,3],block);
        else
            errorVector(Nominal,'Nominal power ..',[1,4],block);
            Fcurr=Nominal(4);
            errorPositive(Fcurr,'Field current',block);
        end







        errorVector(Field,'Field',[1,2],block);
        if strcmp(Rotor,'Round')
            errorIsempty(Damper2,'Dampers',block);
            errorVector(Damper2,'Dampers',[1,6],block);
            Rkd=Damper2(1);
            LIkd=Damper2(2);
            Rkq1=Damper2(3);
            LIkq1=Damper2(4);
            Rkq2=Damper2(5);
            LIkq2=Damper2(6);
            errorGTzero(Rkq2,'Damper Rkq2',block);
            errorGTzero(LIkq2,'Damper LIkq2',block);
        else
            errorIsempty(Damper1,'Dampers',block);
            errorVector(Damper1,'Dampers',[1,4],block);
            Rkd=Damper1(1);
            LIkd=Damper1(2);
            Rkq1=Damper1(3);
            LIkq1=Damper1(4);
        end
        errorIsempty(Coeff,'Inertia ...',block);
        errorIsempty(Init,'Initial conditions',block);
        errorVector(Coeff,'Inertia ...',[1,3],block);
        errorVector(Init,'Initial conditions',[1,9],block);

        pere=bdroot(block);
        block=strrep(block,newline,' ');
        block=strrep(block,pere,'');
        block=block(2:end);

        if strcmp(Simusat,'on')
            errorIsempty(Satparam,'Saturation parameters',block);
            [m,n]=size(Satparam);
            if m~=2
                message=['In mask of ''',block,''' block:',newline,'The saturation parameters matrix must contain two rows.'];
                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                psberror(Erreur);
            end
            if n<2
                message=['In mask of ''',block,''' block:',newline,'The saturation parameters matrix must contain at least two set of points.'];
                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                psberror(Erreur);
            end
        end
        Pn=Nominal(1);
        Vn=Nominal(2);
        Fn=Nominal(3);
        Rs=Stator(1);
        LI=Stator(2);
        Lmd=Stator(3);
        Lmq=Stator(4);
        if length(Stator)==5
            Lc=Stator(5);
        else
            Lc=0;
        end
        Rf=Field(1);
        LIfd=Field(2);
        H=Coeff(1);
        F=Coeff(2);%#ok
        P=Coeff(3);

        errorGTzero(Pn,'Nominal power',block);
        errorGTzero(Vn,'Nominal voltage',block);
        errorGTzero(Fn,'Frequency',block);
        errorGTzero(Rs,'Stator Rs',block);
        errorGTzero(LI,'Stator LI',block);
        errorGTzero(Lmd,'Stator Lmd',block);
        errorGTzero(Lmq,'Stator Lmq',block);
        errorGTzero(Rf,'Field Rf',block);
        errorGTzero(LIfd,'Field LIfd',block);
        errorGTzero(Rkd,'Damper Rkd',block);
        errorGTzero(LIkd,'Damper LIkd',block);
        errorGTzero(Rkq1,'Damper Rkq1',block);
        errorGTzero(LIkq1,'Damper LIkq1',block);
        errorGTzero(H,'Coefficient of inertia H',block);
        errorGTzero(P,'pole pairs p',block);

    case 'Asynchronous Machine'

        RotorType=values{1};%#ok
        Rframe=values{2};%#ok
        Nominal=values{3};
        Stator=values{4};
        Rotor=values{5};
        Mutual=values{6};
        Mech=values{7};
        IC=values{8};

        errorIsempty(Nominal,'Nominal power',block);
        errorIsempty(Stator,'Stator',block);
        errorIsempty(Rotor,'Rotor',block);
        errorIsempty(Mutual,'Mutual inductance',block);
        errorIsempty(Mech,'Inertia',block);
        errorIsempty(IC,'Initial conditions',block);

        errorVector(Nominal,'Nominal power',[1,3],block);
        errorVector(Stator,'Stator',[1,2],block);
        errorVector(Rotor,'Rotor',[1,2],block);
        errorScalar(Mutual,'Mutual inductance',block);
        errorVector(Mech,'Inertia ...',[1,3],block);

        if~all(size(IC)==[1,8])&&~all(size(IC)==[1,14])
            pere=bdroot(block);
            block=strrep(block,newline,' ');
            block=strrep(block,pere,'');
            block=block(2:end);
            message=['In mask of ''',block,''' block:',newline,'Parameter ''','Initial conditions',''' must be a [1-by-8] or [1-by-14] vector.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end

    case 'Permanent Magnet Synchronous Machine'

        FluxDistribution=values{1};
        Rot_type=values{2};
        Ls=values{3};
        Ld=values{4};
        Lq=values{5};
        if length(values)>5
            FluxCst=values{6};
            VoltageCst=values{7};
            TorqueCst=values{8};
            errorInf(FluxCst,'Flux linkage',block);
            errorInf(VoltageCst,'Voltage Constant',block);
            errorInf(TorqueCst,'Torque Constant',block);
            errorNaN(FluxCst,'Flux linkage',block);
            errorNaN(VoltageCst,'Voltage Constant',block);
            errorNaN(TorqueCst,'Torque Constant',block);
            errorScalar(FluxCst,'Flux linkage',block);
            errorScalar(VoltageCst,'Voltage Constant',block);
            errorScalar(TorqueCst,'Torque Constant',block);
        end

        if FluxDistribution==1
            if Rot_type==1
                errorGTzero(Ld,'Ld inductance',block);
                errorGTzero(Lq,'Lq inductance',block);
            end
        else
            errorGTzero(Ls,'Ls inductance',block);
        end


    case 'Surge Arrester'

        PV=values{1};
        Number=values{2};
        Iref=values{3};
        Seg1=values{4};
        Seg2=values{5};
        Seg3=values{6};

        errorIsempty(PV,'Protection voltage',block);
        errorIsempty(Number,'Number of columns',block);
        errorIsempty(Iref,'Reference current',block);
        errorIsempty(Seg1,'Segment 1',block);
        errorIsempty(Seg2,'Segment 2',block);
        errorIsempty(Seg3,'Segment 3',block);

        errorGTzero(PV,'Protection voltage',block);
        errorGTzero(Number,'Number of columns',block);
        errorGTzero(Iref,'Reference current',block);
        errorInf(PV,'Protection voltage',block);
        errorInf(Number,'Number of columns',block);
        errorInf(Iref,'Reference current',block);
        errorVector(Seg1,'Segment 1',[1,2],block);
        errorVector(Seg2,'Segment 2',[1,2],block);
        errorVector(Seg3,'Segment 3',[1,2],block);

    case 'Saturable Transformer'


        NpNf=values{1};
        W1=values{2};
        W2=values{3};
        w3check=strcmp('on',values{4});
        W3=values{5};
        Sat=values{6};
        Core=values{7};

        errorIsempty(NpNf,'Nominal power and frequency',block);
        errorIsempty(W1,'Winding no.1',block);
        errorIsempty(W2,'Winding no.2',block);
        errorIsempty(Sat,'Saturation characteristic',block);
        errorIsempty(Core,'Core losses',block);

        errorVector(NpNf,'Nominal power and frequency',[1,2],block);
        errorVector(W1,'Winding 1',[1,3],block);
        errorVector(W2,'Winding 2',[1,3],block);

        Pn=NpNf(1);
        fn=NpNf(2);
        V1=W1(1);
        R1=W1(2);
        L1=W1(3);
        V2=W2(1);
        R2=W2(2);
        L2=W2(3);
        Rm=Core(1);

        errorInf(Pn,'Nominal power',block);
        errorInf(fn,'Nominal frequency',block);
        errorInf(V1,'V1',block);
        errorInf(R1,'R1',block);
        errorInf(L1,'L1',block);
        errorInf(V2,'V2',block);
        errorInf(R2,'R2',block);
        errorInf(L2,'L2',block);

        errorPositive(V1,'V1',block);
        errorPositive(V2,'V2',block);

        if w3check
            errorIsempty(W3,'winding no.3',block);
            errorVector(W3,'winding 3',[1,3],block);
            V3=W3(1);
            R3=W3(2);
            L3=W3(3);
            errorInf(V3,'V3',block);
            errorInf(R3,'R3',block);
            errorInf(L3,'L3',block);
            errorPositive(V3,'V3',block);
        end

        errorSaturationTransfo(Sat,block);

        errorL1RmTransfo(L1,Rm,block);

    case 'Three-Phase Transformer (Two Windings)'


        Winding1=values{3};
        L1=Winding1(3);
        SetSaturation=values{6};
        Rm=values{7};
        if SetSaturation

            errorL1RmTransfo(L1,Rm,block);
            Saturation=values{9};
            errorSaturationTransfo(Saturation,block);
        end

        errorL1RmTransfo(L1,Rm,block);

    case 'Three-Phase Transformer (Three Windings)'


        Winding1=values{3};
        L1=Winding1(3);
        SetSaturation=values{8};
        Rm=values{9};
        if SetSaturation

            errorL1RmTransfo(L1,Rm,block);
            Saturation=values{11};
            errorSaturationTransfo(Saturation,block);
        end

        errorL1RmTransfo(L1,Rm,block);

    case 'Zigzag Phase-Shifting Transformer'

        pfnom=values{1};
        uprim=values{2};
        uphisec=values{3};
        conex=values{4};%#ok
        rx1=values{5};
        rx2=values{6};
        rx3=values{7};
        satcheck=values{8};
        rxm=values{9};
        rmag=values{10};
        satur=values{11};

        SetSaturation=strcmp(satcheck,'on');

        errorIsempty(pfnom,'Nominal power and frequency',block);
        errorIsempty(uprim,'Primary nominal voltage',block);
        errorIsempty(uphisec,'Secondary nominal voltage and Phi angle',block);
        errorIsempty(rx1,'Winding 1',block);
        errorIsempty(rx2,'Winding 2',block);
        errorIsempty(rx3,'Winding 3',block);
        errorIsempty(rxm,'Magnetizing branch',block);
        errorIsempty(rmag,'Rm',block);
        errorIsempty(satur,'Saturation characteristic',block);

        errorVector(pfnom,'Nominal power and frequency',[1,2],block);
        errorVector(uphisec,'Secondary nominal voltage and Phi angle',[1,2],block);
        errorVector(rx1,'Winding 1',[1,2],block);
        errorVector(rx2,'Winding 2',[1,2],block);
        errorVector(rx3,'Winding 3',[1,2],block);
        errorVector(rxm,'Magnetizing branch',[1,2],block);

        Pn=pfnom(1);
        fn=pfnom(2);
        U1=uprim;
        U3=uphisec(1);
        Phi=uphisec(2);
        R1=rx1(1);
        L1=rx1(2);
        R2=rx2(1);
        L2=rx2(2);
        R3=rx3(1);
        L3=rx3(2);
        if SetSaturation
            Rm=rmag;
            Lm=500;%#ok dummy
        else
            Rm=rxm(1);
            Lm=rxm(2);%#ok
        end

        errorInf(Pn,'Nominal power',block);
        errorInf(fn,'Nominal frequency',block);
        errorInf(U1,'Primary nominal voltage',block);
        errorInf(U3,'Secondary nominal voltage',block);
        errorInf(Phi,'Phi',block);
        errorInf(R1,'R1',block);
        errorInf(L1,'L1',block);
        errorInf(R2,'R2',block);
        errorInf(L2,'L2',block);
        errorInf(R3,'R3',block);
        errorInf(L3,'L3',block);

        errorPositive(Pn,'Nominal power',block);
        errorPositive(fn,'Nominal frequency',block);
        errorPositive(U1,'Primary nominal voltage',block);
        errorPositive(U3,'Secondary nominal voltage',block);
        errorPositive(R1,'R1',block);
        errorPositive(L1,'L1',block);
        errorPositive(R2,'R2',block);
        errorPositive(L2,'L2',block);
        errorPositive(R3,'R3',block);
        errorPositive(L3,'L3',block);


        errorL1RmTransfo(L1,Rm,block);

    case{'Distributed Parameters Line','Decoupling Line (Three-Phase)','Decoupling Line'}

        N=values{1};
        f=values{2};
        R=values{3};
        L=values{4};
        C=values{5};
        long=values{6};

        errorIsempty(N,'Number of phases',block);
        errorIsempty(f,'frequency',block);
        errorIsempty(R,'Resistance',block);
        errorIsempty(L,'Inductance',block);
        errorIsempty(C,'Capacitance',block);
        errorIsempty(long,'Line length',block);
        errorInf(N,'Number of phases',block);
        errorInf(f,'frequency',block);
        errorInf(R,'Resistance',block);
        errorInf(L,'Inductance',block);
        errorInf(C,'Capacitance',block);
        errorInf(long,'Line length',block);
        errorGTzero(N,'Number of phases',block);
        errorGTzero(f,'frequency',block);
        errorGTzero(long,'Line length',block);
        errorScalar(N,'Number of phases',block);
        errorScalar(f,'frequency',block);
        errorScalar(long,'Line length',block);

        pere=bdroot(block);
        block=strrep(block,newline,' ');
        block=strrep(block,pere,'');
        block=block(2:end);

        if N~=fix(N)
            message=['In mask of ''',block,''' block:',newline,'The number of phases parameter must be an integer value.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end

        [nline,ncol]=size(R);
        [nline1,ncol1]=size(L);
        if nline1~=nline||ncol1~=ncol
            message=['In mask of ''',block,''' block:',newline,'R, L and C parameters must be specified with same dimensions.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end
        [nline1,ncol1]=size(C);
        if nline1~=nline||ncol1~=ncol
            message=['In mask of ''',block,''' block:',newline,'R, L and C parameters must be specified with same dimensions.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end

        if nline==1
            if N~=1&&N~=2&&N~=3&&N~=6
                message=['In mask of ''',block,''' block:',newline,'The R, L and C line parameters must be [',num2str(N),' by ',num2str(N),'] matrices.'];
                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                psberror(Erreur);
            end
            if N==1&&ncol~=1
                message=['In mask of ''',block,''' block:',newline,'A scalar is expected for R, L and C parameters.'];
                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                psberror(Erreur);
            end
            if(N==2||N==3)&&ncol~=2
                message=['In mask of ''',block,''' block:',newline,'A [1-by-2] vector containing positive- and zero-sequence components is expected for R, L and C parameters.'];
                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                psberror(Erreur);
            end
            if N==6&&ncol~=3
                message=['In mask of ''',block,''' block:',newline,'A [1-by-3] vector containing positive- , zero- and zero-mutual sequence components is expected for R, L and C parameters.'];
                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                psberror(Erreur);
            end
        elseif nline~=1&&(nline~=N||ncol~=N)
            message=['In mask of ''',block,''' block:',newline,'The R, L, and C line parameters must be specified by [',num2str(N),'-by-',num2str(N),'] matrices, or by sequence components.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end


        for i=1:nline
            for k=i:ncol
                if R(i,k)<0
                    message=['In mask of ''',block,''' block:',newline,'Resistance values must be positive.'];
                    Erreur.message=message;
                    Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                    psberror(Erreur);
                end
                if L(i,k)<0
                    message=['In mask of ''',block,''' block:',newline,'Inductance values must be positive.'];
                    Erreur.message=message;
                    Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                    psberror(Erreur);
                end
                if i==k&&nline>1&&C(i,i)<=0
                    message=['In mask of ''',block,''' block:',newline,'Self capacitance values must be positive.'];
                    Erreur.message=message;
                    Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                    psberror(Erreur);





                elseif k<3&&nline==1&&C(i,k)<=0
                    message=['In mask of ''',block,''' block:',newline,'The positive- and zero-sequence capacitance values must be positive.'];
                    Erreur.message=message;
                    Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                    psberror(Erreur);
                elseif k==3&&nline==1&&C(i,k)>=0
                    message=['In mask of ''',block,''' block:',newline,'The mutual zero-sequence capacitance value must be negative.'];
                    Erreur.message=message;
                    Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                    psberror(Erreur);
                end
                if k==3&&nline==1
                    if abs(C(3))>C(2)
                        message=['In mask of ''',block,''' block:',newline,'The absolute value of the mutual zero-sequence capacitance must be lower than the zero-sequence capacitance of each circuit [ abs(C0m)<C0 ].'];
                        Erreur.message=message;
                        Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                        psberror(Erreur);
                    end
                    if L(3)>=L(2)
                        message=['In mask of ''',block,''' block:',newline,'The mutual zero-sequence inductance must be smaller than the zero-sequence inductance of each circuit [ L0m<L0 ].'];
                        Erreur.message=message;
                        Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                        psberror(Erreur);
                    end
                end
            end
        end

        if nline>1
            if~all(all(R==R'))
                message=['In mask of ''',block,''' block:',newline,'The matrix R must be symmetrical.'];
                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                psberror(Erreur);
            end
            if~all(all(L==L'))
                message=['In mask of ''',block,''' block:',newline,'The matrix L must be symmetrical.'];
                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                psberror(Erreur);
            end
            if~all(all(C==C'))
                message=['In mask of ''',block,''' block:',newline,'The matrix C must be symmetrical.'];
                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                psberror(Erreur);
            end
        end

    case 'Impedance Measurement'


    case 'Three-Phase Dynamic Load'


    case 'DC Voltage Source'

        V=values{1};

        errorIsempty(V,'Amplitude',block);
        errorScalar(V,'Amplitude',block);
        errorInf(V,'Amplitude',block);

    case 'AC Voltage Source'

        V=values{1};
        P=values{2};
        f=values{3};

        errorIsempty(V,'Peak amplitude',block);
        errorIsempty(P,'Phase',block);
        errorIsempty(f,'Frequency',block);
        errorScalar(V,'Peak amplitude',block);
        errorScalar(P,'Phase',block);
        errorScalar(f,'Frequency',block);
        errorInf(V,'Peak amplitude',block);
        errorInf(P,'Phase',block);
        errorInf(f,'Frequency',block);
        errorPositive(f,'Frequency',block);

    case 'AC Current Source'

        V=values{1};
        P=values{2};
        f=values{3};

        errorIsempty(V,'Peak amplitude',block);
        errorIsempty(P,'Phase',block);
        errorIsempty(f,'Frequency',block);
        errorScalar(V,'Peak amplitude',block);
        errorScalar(P,'Phase',block);
        errorScalar(f,'Frequency',block);
        errorInf(V,'Peak amplitude',block);
        errorInf(P,'Phase',block);
        errorInf(f,'Frequency',block);
        errorPositive(f,'Frequency',block);

    case 'Controlled Voltage Source'

        V=values{1};
        P=values{2};
        f=values{3};

        errorIsempty(V,'Initial amplitude',block);
        errorIsempty(P,'Initial phase',block);
        errorIsempty(f,'Initial frequency',block);
        errorScalar(V,'Initial amplitude',block);
        errorScalar(P,'Initial phase',block);
        errorScalar(f,'Initial frequency',block);
        errorInf(V,'Initial amplitude',block);
        errorInf(P,'Initial phase',block);
        errorInf(f,'Initial frequency',block);
        errorPositive(f,'Initial frequency',block);

    case 'Controlled Current Source'

        V=values{1};
        P=values{2};
        f=values{3};

        errorIsempty(V,'Initial amplitude',block);
        errorIsempty(P,'Initial phase',block);
        errorIsempty(f,'Initial frequency',block);
        errorScalar(V,'Initial amplitude',block);
        errorScalar(P,'Initial phase',block);
        errorScalar(f,'Initial frequency',block);
        errorInf(V,'Initial amplitude',block);
        errorInf(P,'Initial phase',block);
        errorInf(f,'Initial frequency',block);
        errorPositive(f,'Initial frequency',block);

    case 'Three-Phase Source'

        ShortCircuitLevel=values{1};
        BaseVoltage=values{2};
        XRratio=values{3};
        RLoff=values{4};

        if strcmp(RLoff,'on')
            errorIsempty(ShortCircuitLevel,'3-phase short-circuit level at base voltage',block);
            errorIsempty(BaseVoltage,'Base voltage',block);
            errorIsempty(XRratio,'X/R ratio',block);
            errorInf(BaseVoltage,'Base voltage',block);
            errorGTzero(ShortCircuitLevel,'3-phase short-circuit level at base voltage',block);
            errorGTzero(BaseVoltage,'Base voltage',block);
            errorGTzero(XRratio,'X/R ratio',block);
        end

    end



    function errorIsempty(parameter,name,block)

        if isempty(parameter)
            pere=bdroot(block);
            block=strrep(block,newline,' ');
            block=strrep(block,pere,'');
            block=block(2:end);
            message=['In mask of ''',block,''' block:',newline,'Parameter ''',name,''' cannot be an empty value.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:blocinit:BlockParameterError';
            psberror(Erreur);
        end

        function errorInf(parameter,name,block)

            if abs(parameter)==inf
                pere=bdroot(block);
                block=strrep(block,newline,' ');
                block=strrep(block,pere,'');
                block=block(2:end);
                message=['In mask of ''',block,''' block:',newline,'Parameter ''',name,''' must have a finite value.'];
                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                psberror(Erreur);
            end
            function errorNaN(parameter,name,block)

                if isnan(parameter)
                    pere=bdroot(block);
                    block=strrep(block,newline,' ');
                    block=strrep(block,pere,'');
                    block=block(2:end);
                    message=['In mask of ''',block,''' block:',newline,'Parameter ''',name,''' must have a finite value.'];
                    Erreur.message=message;
                    Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                    psberror(Erreur);
                end

                function errorNzero(parameter,name,block)

                    if parameter==0
                        pere=bdroot(block);
                        block=strrep(block,newline,' ');
                        block=strrep(block,pere,'');
                        block=block(2:end);
                        message=['In mask of ''',block,''' block:',newline,'Parameter ''',name,''' must be different from zero.'];
                        Erreur.message=message;
                        Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                        psberror(Erreur);
                    end

                    function errorZero(parameter,name,block)%#ok

                        if parameter~=0
                            pere=bdroot(block);
                            block=strrep(block,newline,' ');
                            block=strrep(block,pere,'');
                            block=block(2:end);
                            message=['In mask of ''',block,''' block:',newline,'Parameter ''',name,''' must be set to zero in order to remove the winding 3 from the block.'];
                            Erreur.message=message;
                            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                            psberror(Erreur);
                        end

                        function errorGTzero(parameter,name,block)

                            if parameter<=0
                                pere=bdroot(block);
                                block=strrep(block,newline,' ');
                                block=strrep(block,pere,'');
                                block=block(2:end);
                                message=['In mask of ''',block,''' block:',newline,'Parameter ''',name,''' must be greater that zero.'];
                                Erreur.message=message;
                                Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                                psberror(Erreur);
                            end

                            function errorPositive(parameter,name,block)

                                if parameter<0
                                    pere=bdroot(block);
                                    block=strrep(block,newline,' ');
                                    block=strrep(block,pere,'');
                                    block=block(2:end);
                                    message=['In mask of ''',block,''' block:',newline,'Parameter ''',name,''' must be greater or equal to zero.'];
                                    Erreur.message=message;
                                    Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                                    psberror(Erreur);
                                end

                                function errorDifferent(parameter1,parameter2,name,block)

                                    if(parameter1~=0&&parameter2~=0)
                                        if parameter1==parameter2
                                            pere=bdroot(block);
                                            block=strrep(block,newline,' ');
                                            block=strrep(block,pere,'');
                                            block=block(2:end);
                                            message=['In mask of ''',block,''' block:',newline,'Parameter ''',name,''' self must be different from ',name(1),'m.'];
                                            Erreur.message=message;
                                            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                                            psberror(Erreur);
                                        end
                                    end

                                    function errorBin(parameter,name,block)%#ok

                                        if parameter~=0&&parameter~=1
                                            pere=bdroot(block);
                                            block=strrep(block,newline,' ');
                                            block=strrep(block,pere,'');
                                            block=block(2:end);
                                            message=['In mask of ''',block,''' block:',newline,'Initial Condition parameter must be 0 or 1.'];
                                            Erreur.message=message;
                                            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                                            psberror(Erreur);
                                        end

                                        function errorSnubber(block)

                                            pere=bdroot(block);
                                            block=strrep(block,newline,' ');
                                            block=strrep(block,pere,'');
                                            block=block(2:end);
                                            message=['In mask of ''',block,''' block:',newline,'Snubber parameters not set correctly (short-circuit). Specify  Rs=Inf or Cs=0 to disconnect the snubber.'];
                                            Erreur.message=message;
                                            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                                            psberror(Erreur);

                                            function errorL1RmTransfo(parameter1,parameter2,block)

                                                if parameter1~=0&&parameter2==inf
                                                    pere=bdroot(block);
                                                    block=strrep(block,newline,' ');
                                                    block=strrep(block,pere,'');
                                                    block=block(2:end);
                                                    message=['In mask of ''',block,''' block:',newline,...
                                                    'You have specified a nonzero leakage inductance L1 and no resistive iron losses (Rm is set to inf).',...
                                                    newline,...
                                                    'Due to modeling constraints in Simscape Electrical Specialized Power Systems, you must specify either a finite positive Rm value ',...
                                                    newline,...
                                                    'if you wish to keep a nonzero L1 value, or set L1 to 0 if you wish to keep an infinite value of Rm.'];
                                                    Erreur.message=message;
                                                    Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                                                    psberror(Erreur);
                                                end

                                                function errorSaturationTransfo(Sat,block)

                                                    [m,n]=size(Sat);
                                                    if n~=2||m<2
                                                        message=['In mask of ''',block,''' block:',newline,'Saturation characteristic must be given in pairs (positive values).',...
                                                        newline,'A minimum of two pairs is required.'];
                                                        Erreur.message=message;
                                                        Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                                                        psberror(Erreur);
                                                    end
                                                    if n==2
                                                        if Sat(1,1)~=0||Sat(1,2)~=0
                                                            message=['In mask of ''',block,''' block:',newline,'Saturation characteristic must be given in pairs (positive values) starting with pair [0,0].'];
                                                            Erreur.message=message;
                                                            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                                                            psberror(Erreur);
                                                        end
                                                    end
                                                    if sum(sum(Sat<0))&&1
                                                        message=['In mask of ''',block,''' block:',newline,'Saturation characteristic must be given in pairs (positive values) starting with pair [0,0].'];
                                                        Erreur.message=message;
                                                        Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                                                        psberror(Erreur);
                                                    end
                                                    if Sat(:,2)~=sort(Sat(:,2))
                                                        message=['In mask of ''',block,''' block:',newline,'Flux saturation characteristic (column 2) must be monotonically increasing.'];
                                                        Erreur.message=message;
                                                        Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                                                        psberror(Erreur);
                                                    end
