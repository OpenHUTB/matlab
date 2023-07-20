function varargout=vehdynblkgyro(blkn,action,par)




    if nargin==1
        action='dynamic';
    end



    blk=get_param(blkn,'Handle');

    switch action
    case 'icon'
        set_up_mask(blk);
        updatemodel(blk,blkn,par);
        ports=get_labels;
        varargout={ports};
    case 'dynamic'
        set_up_mask(blk);

    otherwise
        error(message('vdynblks:vehdynblkgyro:invalidIconAction'));
    end

    return

    function ports=get_labels

        ports=struct('type',{'','',''},'port',{1},'txt',{''});

        ang_str='{\omega (rad/s)}';
        g_str='G''s';

        wmeas_str='\omega_{meas}(rad/s)';


        ports(1).type='input';
        ports(1).port=1;
        ports(1).txt=ang_str;

        ports(2).type='input';
        ports(2).port=2;
        ports(2).txt=g_str;



        ports(3).type='output';
        ports(3).port=1;
        ports(3).txt=wmeas_str;

        return


        function updatemodel(blk,blkn,par)

            rmode=get_param(blk,'g_rand');
            dmode=get_param(blk,'dtype_g');
            Ts=par;

            blkrand=[blkn,'/Random bias'];
            blkzoh=sprintf([blkn,'/Zero-Order\nHold']);
            blkzoh1=sprintf([blkn,'/Zero-Order\nHold1']);
            blktf=[blkn,'/Dynamics/Second-order Dynamics'];

            switch rmode
            case 'on'
                if(Ts==0)
                    if(~strcmp(get_param(blkrand,'maskType'),'TunableWhiteNoise')||~strcmp(get_param(blkrand,'Ts'),'0.1'))
                        Aero.internal.maskutilities.replaceblock(blkrand,'Tunable White Noise','vehdynlibsenscommon');
                        set_param(blkrand,'pwr','g_pow','Ts','0.1','seed','g_seeds');
                    end
                else
                    if(~strcmp(get_param(blkrand,'maskType'),'TunableWhiteNoise')||~strcmp(get_param(blkrand,'Ts'),'g_Ts'))
                        Aero.internal.maskutilities.replaceblock(blkrand,'Tunable White Noise','vehdynlibsenscommon');
                        set_param(blkrand,'pwr','g_pow','Ts','g_Ts','seed','g_seeds');
                    end
                end

            case 'off'
                Aero.internal.maskutilities.replaceblock(blkrand,"Ground","simulink/Sources");

            otherwise
                error(message('vdynblks:vehdynblkgyro:invalidBiasType'));
            end

            if(Ts==0)
                if(strcmp(get_param(blktf,'maskType'),'DiscreteFilter'))
                    Aero.internal.maskutilities.replaceblock(blkzoh,"Gain","simulink/Math Operations");
                    Aero.internal.maskutilities.replaceblock(blkzoh1,"Gain","simulink/Math Operations");
                    if strcmp(dmode,'on')
                        Aero.internal.maskutilities.replaceblock(blktf,'Transfer Fcn (C)','vehdynlibsenscommon');
                        set_param(blktf,'wn','w_g','zn','z_g');
                    end
                end
            else
                if~(strcmp(get_param(blktf,'maskType'),'DiscreteFilter'))
                    Aero.internal.maskutilities.replaceblock(blkzoh,"Zero-Order\nHold","simulink/Discrete");
                    set_param(blkzoh,'sampleTime','g_Ts');
                    Aero.internal.maskutilities.replaceblock(blkzoh1,"Zero-Order\nHold","simulink/Discrete");
                    set_param(blkzoh1,'sampleTime','g_Ts');
                    if strcmp(dmode,'on')
                        Aero.internal.maskutilities.replaceblock(blktf,'Transfer Fcn (D)','vehdynlibsenscommon');
                        set_param(blktf,'wn','w_g','ts','g_Ts','zn','z_g');
                    end
                end
            end

            return

            function set_up_mask(blk)

                mask_enables=get_param(blk,'maskEnables');

                mtype=get_param(blk,'dtype_g');
                rtype=get_param(blk,'g_rand');

                switch mtype
                case 'on'
                    if~strcmp(mask_enables(2),'on')
                        [mask_enables{2:3}]=deal('on');
                    end
                case 'off'
                    if~strcmp(mask_enables(2),'off')
                        [mask_enables{2:3}]=deal('off');
                    end
                otherwise
                    error(message('vdynblks:vehdynblkgyro:invalidType'));
                end
                switch rtype
                case 'off'
                    if~strcmp(mask_enables(9),'off')
                        [mask_enables{9:10}]=deal('off');
                    end
                case 'on'
                    if~strcmp(mask_enables(9),'on')
                        [mask_enables{9:10}]=deal('on');
                    end
                otherwise
                    error(message('vdynblks:vehdynblkgyro:invalidRep'));
                end

                set_param(blk,'maskEnables',mask_enables);

                return



