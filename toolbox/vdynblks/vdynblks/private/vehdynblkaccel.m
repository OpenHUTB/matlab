function varargout=vehdynblkaccel(blkn,action,par)





    if nargin==1
        action='dynamic';
    end

    blk=get_param(blkn,'Handle');

    switch action
    case 'icon'
        set_up_mask(blk);
        set_conversion_factor(blkn);
        updatemodel(blk,blkn,par);
        ports=get_labels(blk,blkn);
        varargout={ports};
    case 'dynamic'
        set_up_mask(blk);
    otherwise
        error(message('vdynblks:vehdynblkaccel:invalidIconAction'));
    end

    return

    function ports=get_labels(blk,blkn)

        ports=struct('type',{'','',''},'port',{1},'txt',{''});

        umode=get_param(blk,'units');

        ab_str='A_b ';
        ang_str='{\omega (rad/s)}';
        ang2_str='{d\omega/dt}';
        cg_str='CG ';

        ameas_str='A_{meas} ';


        ports(1).type='input';
        ports(1).port=1;

        ports(2).type='input';
        ports(2).port=2;
        ports(2).txt=ang_str;

        ports(3).type='input';
        ports(3).port=3;
        ports(3).txt=ang2_str;

        ports(4).type='input';
        ports(4).port=4;

        ports(5).type='input';
        ports(5).port=5;



        ports(6).type='output';
        ports(6).port=1;

        unit_mode={'Metric (MKS)'...
        ,'English'};

        k=strncmp(umode,unit_mode,length(umode));
        if isempty(k)
            error(message('vdynblks:vehdynblkaccel:invalidUnits'));
        end

        units={' (m)',' (ft)';...
        ' (m/s^2)',' (ft/s^2)'};

        unitBlk={'m/s^2','ft/s^2'};


        gtype=get_param(blk,'gtype');

        blk5=[blkn,'/g'];

        switch gtype
        case 'off'
            ports(5).port=1;
            str5='';
            Aero.internal.maskutilities.replaceblock(blk5,"Ground","simulink/Sources");
        case 'on'
            Aero.internal.maskutilities.addport(blk5,'Inport','5','OutUnit',unitBlk{k});
            ports(5).port=5;
            str5='g ';
        otherwise
            error(message('vdynblks:vehdynblkaccel:invalidGravityType'));
        end

        ports(1).txt=[ab_str,units{2,k}];
        ports(4).txt=[cg_str,units{1,k}];
        ports(6).txt=[ameas_str,units{2,k}];

        if(strcmp(str5,'g '))
            ports(5).txt=[str5,' ',units{2,k}];
        else
            ports(5).txt=str5;
        end

        return


        function set_conversion_factor(blk)

            umode=get_param(blk,'units');

            unit_mode={'Metric (MKS)'...
            ,'English'};

            unitStr=getunitdata('units',umode);

            k=strncmp(umode,unit_mode,length(umode));
            if isempty(k)
                error(message('vdynblks:vehdynblkaccel:invalidUnits'));
            end

            unitBlk={'m','ft';'m/s^2','ft/s^2'};

            aBlk=[blk,'/Ab'];
            cgBlk=[blk,'/CG'];
            aMeasBlk=[blk,'/Ameas'];

            cgmask=get_param(cgBlk,'Unit');
            convert=~strcmp(cgmask,unitBlk{1,k});

            if convert&&unitStr.u
                set_param(aBlk,'Unit',unitBlk{2,k});
                set_param(aMeasBlk,'Unit',unitBlk{2,k});
                set_param(cgBlk,'Unit',unitBlk{1,k});
            end

            return


            function updatemodel(blk,blkn,par)

                rmode=get_param(blk,'a_rand');
                dmode=get_param(blk,'dtype_a');
                Ts=par;

                blkrand=[blkn,'/Random bias'];
                blkzoh=sprintf([blkn,'/Zero-Order\nHold']);
                blkzoh1=sprintf([blkn,'/Zero-Order\nHold1']);
                blkzoh2=sprintf([blkn,'/Zero-Order\nHold2']);
                blkzoh3=sprintf([blkn,'/Zero-Order\nHold3']);
                blkzoh4=sprintf([blkn,'/Zero-Order\nHold4']);
                blktf=[blkn,'/Dynamics/Second-order Dynamics'];
                switch rmode
                case 'on'
                    if(Ts==0)
                        if(~strcmp(get_param(blkrand,'maskType'),'TunableWhiteNoise')||~strcmp(get_param(blkrand,'Ts'),'0.1'))

                            Aero.internal.maskutilities.replaceblock(blkrand,'Tunable White Noise','vehdynlibsenscommon');
                            set_param(blkrand,'pwr','a_pow','Ts','0.1','seed','a_seeds');
                        end
                    else
                        if(~strcmp(get_param(blkrand,'maskType'),'TunableWhiteNoise')||~strcmp(get_param(blkrand,'Ts'),'a_Ts'))

                            Aero.internal.maskutilities.replaceblock(blkrand,'Tunable White Noise','vehdynlibsenscommon');
                            set_param(blkrand,'pwr','a_pow','Ts','a_Ts','seed','a_seeds');
                        end
                    end

                case 'off'
                    Aero.internal.maskutilities.replaceblock(blkrand,"Ground","simulink/Sources");

                otherwise
                    error(message('vdynblks:vehdynblkaccel:invalidBiasType'));
                end

                if(Ts==0)
                    if(strcmp(get_param(blktf,'maskType'),'DiscreteFilter'))
                        Aero.internal.maskutilities.replaceblock(blkzoh,"Gain","simulink/Math Operations");
                        Aero.internal.maskutilities.replaceblock(blkzoh1,"Gain","simulink/Math Operations");
                        Aero.internal.maskutilities.replaceblock(blkzoh2,"Gain","simulink/Math Operations");
                        Aero.internal.maskutilities.replaceblock(blkzoh3,"Gain","simulink/Math Operations");
                        Aero.internal.maskutilities.replaceblock(blkzoh4,"Gain","simulink/Math Operations");
                        if strcmp(dmode,'on')
                            Aero.internal.maskutilities.replaceblock(blktf,'Transfer Fcn (C)','vehdynlibsenscommon');
                            set_param(blktf,'wn','w_a','zn','z_a');
                        end
                    end
                else
                    if~(strcmp(get_param(blktf,'maskType'),'DiscreteFilter'))
                        Aero.internal.maskutilities.replaceblock(blkzoh,"Zero-Order\nHold","simulink/Discrete");
                        set_param(blkzoh,'sampleTime','a_Ts');
                        Aero.internal.maskutilities.replaceblock(blkzoh1,"Zero-Order\nHold","simulink/Discrete");
                        set_param(blkzoh1,'sampleTime','a_Ts');
                        Aero.internal.maskutilities.replaceblock(blkzoh2,"Zero-Order\nHold","simulink/Discrete");
                        set_param(blkzoh2,'sampleTime','a_Ts');
                        Aero.internal.maskutilities.replaceblock(blkzoh3,"Zero-Order\nHold","simulink/Discrete");
                        set_param(blkzoh3,'sampleTime','a_Ts');
                        Aero.internal.maskutilities.replaceblock(blkzoh4,"Zero-Order\nHold","simulink/Discrete");
                        set_param(blkzoh4,'sampleTime','a_Ts');
                        if strcmp(dmode,'on')
                            Aero.internal.maskutilities.replaceblock(blktf,'Transfer Fcn (D)','vehdynlibsenscommon');
                            set_param(blktf,'wn','w_a','ts','a_Ts','zn','z_a');
                        end
                    end
                end

                return

                function set_up_mask(blk)

                    mask_enables=get_param(blk,'maskEnables');

                    mtype=get_param(blk,'dtype_a');
                    rtype=get_param(blk,'a_rand');

                    switch mtype
                    case 'on'
                        if~strcmp(mask_enables(5),'on')
                            [mask_enables{5:6}]=deal('on');
                        end
                    case 'off'
                        if~strcmp(mask_enables(5),'off')
                            [mask_enables{5:6}]=deal('off');
                        end
                    otherwise
                        error(message('vdynblks:vehdynblkaccel:invalidType'));
                    end
                    switch rtype
                    case 'off'
                        if~strcmp(mask_enables(11),'off')
                            [mask_enables{11:12}]=deal('off');
                        end
                    case 'on'
                        if~strcmp(mask_enables(11),'on')
                            [mask_enables{11:12}]=deal('on');
                        end
                    otherwise
                        error(message('vdynblks:vehdynblkaccel:invalidRep'));
                    end

                    set_param(blk,'maskEnables',mask_enables);

                    return



