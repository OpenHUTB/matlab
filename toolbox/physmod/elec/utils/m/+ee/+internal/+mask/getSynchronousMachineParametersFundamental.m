function f=getSynchronousMachineParametersFundamental(blockName)





    import ee.internal.mask.getValue;

    componentPath=get_param(blockName,'ComponentPath');
    switch componentPath
    case{'ee.electromech.sync.round_rotor.abc',...
        'ee.electromech.sync.round_rotor.abc_thermal',...
        'ee.electromech.sync.salient_pole.abc',...
        'ee.electromech.sync.salient_pole.abc_thermal',...
        'ee.electromech.sync.model_2_1.abc',...
        'ee.electromech.sync.model_2_1.abc_thermal'}
        param_option=getValue(blockName,'param_option','1');
        if param_option==int32(ee.enum.sm.parameterization.fundamental)
            f=ee.internal.machines.createEmptySynchronousFundamental();


            f.Lad=getValue(blockName,'Ladu','1');
            f.Laq=getValue(blockName,'Laqu','1');
            if~contains(componentPath,'model_2_1')&&getValue(blockName,'zero_sequence','1')==int32(ee.enum.park.zerosequence.include)
                f.L0=getValue(blockName,'L0','1');
            end
            f.Ll=getValue(blockName,'Ll','1');
            f.Ra=getValue(blockName,'Ra','1');
            f.Lfd=getValue(blockName,'Lfd','1');
            f.Rfd=getValue(blockName,'Rfd','1');

            f.L1d=getValue(blockName,'L1d','1');
            f.R1d=getValue(blockName,'R1d','1');

            f.num_q_dampers=getValue(blockName,'num_q_dampers','1');
            f.L1q=getValue(blockName,'L1q','1');
            f.R1q=getValue(blockName,'R1q','1');
            if f.num_q_dampers==2
                f.L2q=getValue(blockName,'L2q','1');
                f.R2q=getValue(blockName,'R2q','1');
            end


            f.Ld=f.Lad+f.Ll;
            f.Lq=f.Laq+f.Ll;


            f.Lffd=f.Lad+f.Lfd;
            f.Lf1d=f.Lffd-f.Lfd;
            f.L11d=f.L1d+f.Lf1d;
            f.L11q=f.L1q+f.Laq;
            if f.num_q_dampers==2
                f.L22q=f.L2q+f.Laq;
            end


            f.axes_param=getValue(blockName,'axes_param','1');


            if~contains(componentPath,'model_2_1')
                f.saturation_option=getValue(blockName,'saturation_option','1');
                if f.saturation_option==ee.enum.saturation.include
                    f.saturation.original.ifd=getValue(blockName,'saturation_ifd','1');
                    f.saturation.original.Vag=getValue(blockName,'saturation_Vag','1');
                end
            else
                f.saturation_option=0;
            end

            f=ee.internal.machines.updateSynchronousFundamental(f);
        else
            s=ee.internal.machines.createEmptySynchronousStandard();


            s.Ra=getValue(blockName,'Ra','1');
            s.Xl=getValue(blockName,'Xl','1');
            s.Xd=getValue(blockName,'Xd','1');
            s.Xq=getValue(blockName,'Xq','1');

            if~contains(componentPath,'model_2_1')&&getValue(blockName,'zero_sequence','1')==int32(ee.enum.park.zerosequence.include)
                s.X0=getValue(blockName,'X0','1');
            end
            s.Xdd=getValue(blockName,'Xdd','1');
            s.num_q_dampers=getValue(blockName,'num_q_dampers','1');
            if s.num_q_dampers==2
                s.Xqd=getValue(blockName,'Xqd','1');
            end
            s.Xddd=getValue(blockName,'Xddd','1');
            s.Xqdd=getValue(blockName,'Xqdd','1');


            s.d_option=getValue(blockName,'d_option','1');
            switch s.d_option
            case 1
                s.Td0d=getValue(blockName,'Td0d','s');
                s.Td0dd=getValue(blockName,'Td0dd','s');
            case 2
                s.Tdd=getValue(blockName,'Tdd','s');
                s.Tddd=getValue(blockName,'Tddd','s');
            otherwise

            end


            s.q_option=getValue(blockName,'q_option','1');
            switch s.num_q_dampers
            case 1
                switch s.q_option
                case 1
                    s.Tq0dd=getValue(blockName,'Tq0dd','s');
                case 2
                    s.Tqdd=getValue(blockName,'Tqdd','s');
                otherwise

                end
            case 2
                switch s.q_option
                case 1
                    s.Tq0dd=getValue(blockName,'Tq0dd','s');
                    s.Tq0d=getValue(blockName,'Tq0d','s');
                case 2
                    s.Tqdd=getValue(blockName,'Tqdd','s');
                    s.Tqd=getValue(blockName,'Tqd','s');
                otherwise

                end
            otherwise

            end


            s.axes_param=getValue(blockName,'axes_param','1');


            if~contains(componentPath,'model_2_1')
                s.saturation_option=getValue(blockName,'saturation_option','1');
                if s.saturation_option==ee.enum.saturation.include
                    s.saturation.original.ifd=getValue(blockName,'saturation_ifd','1');
                    s.saturation.original.Vag=getValue(blockName,'saturation_Vag','1');
                end
            else
                s.saturation_option=0;
            end

            wElectrical=2*pi*getValue(blockName,'FRated','Hz');

            [f,DeltaLessThanZero]=ee.internal.machines.convertSynchronousStandard2Fundamental_Perfect(s,wElectrical);

            if DeltaLessThanZero==1
                pm_error('physmod:ee:library:RelatedMaskParameters','Tq0'', Tq0'''', Xq, Xq'', Xq''''');
            end
        end
    otherwise
        pm_error('physmod:ee:library:UnknownMachineType',componentPath);
    end

