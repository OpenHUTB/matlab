function varargout=vehdynblkimu(blk,action)





    if nargin==1
        action='dynamic';
    end

    switch action
    case 'icon'
        set_up_mask(blk);
        set_conversion_factor(blk);
        updatemodel(blk);
        ports=get_labels(blk);
        varargout={ports};
    case 'dynamic'
        set_up_mask(blk);
    case 'updateIcon'

        iconInfo.ImageName='sensorimu.png';
        [iconInfo.image,iconInfo.position]=iconImageUpdate(iconInfo.ImageName,1,15,90,'white');
        varargout{1}=iconInfo;
    otherwise
        error(message('vdynblks:vehdynblkimu:invalidIconAction'));
    end

    return

    function ports=get_labels(blk)

        ports=struct('type',{'','',''},'port',{1},'txt',{''});

        umode=get_param(blk,'units');

        ab_str='A_b ';
        ang_str='{\omega (rad/s)}';
        ang2_str='{d\omega/dt}';
        cg_str='CG ';
        g_str='g ';

        ameas_str='A_{meas} ';
        wmeas_str='\omega_{meas} (rad/s)';


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

        ports(7).type='output';
        ports(7).port=2;
        ports(7).txt=wmeas_str;

        switch umode
        case 'Metric (MKS)'
            ports(1).txt=[ab_str,'(m/s^2)'];
            ports(4).txt=[cg_str,'(m)'];
            ports(5).txt=[g_str,' (m/s^2)'];
            ports(6).txt=[ameas_str,'(m/s^2)'];

        case 'English'
            ports(1).txt=[ab_str,'(ft/s^2)'];
            ports(4).txt=[cg_str,'(ft)'];
            ports(5).txt=[g_str,' (ft/s^2)'];
            ports(6).txt=[ameas_str,'(ft/s^2)'];

        otherwise
            error(message('vdynblks:vehdynblkimu:invalidUnits'));
        end

        return


        function set_conversion_factor(blk)

            umode=get_param(blk,'units');
            unitStr=getunitdata('units',umode);

            unit_mode={'Metric (MKS)'...
            ,'English'};

            k=strncmp(umode,unit_mode,length(umode));
            if isempty(k)
                error(message('vdynblks:vehdynblkimu:invalidUnits'));
            end

            unitBlk={'m','ft';'m/s^2','ft/s^2'};

            aBlk=[blk,'/A_b'];
            cgBlk=[blk,'/CG'];
            gBlk=[blk,'/g'];
            aMeasBlk=[blk,'/A_meas'];
            accelBlk=[blk,'/Acceleration Conversion/acceleration'];

            cgmask=get_param(cgBlk,'Unit');
            convert=~strcmp(cgmask,unitBlk{1,k});

            if convert&&unitStr.u
                blkaccel=[blk,'/Three-axis Accelerometer'];
                set_param(blkaccel,'units',umode);

                set_param(aBlk,'Unit',unitBlk{2,k});
                set_param(gBlk,'Unit',unitBlk{2,k});
                set_param(aMeasBlk,'Unit',unitBlk{2,k});
                set_param(cgBlk,'Unit',unitBlk{1,k});

                set_param(accelBlk,'Unit',unitBlk{2,k});
            end

            return

            function updatemodel(blk)

                rmode=get_param(blk,'i_rand');
                matype=get_param(blk,'dtype_a');
                mgtype=get_param(blk,'dtype_g');

                blkaccel=[blk,'/Three-axis Accelerometer'];
                blkgyro=[blk,'/Three-axis Gyroscope'];

                set_param(blkaccel,'a_rand',rmode);
                set_param(blkgyro,'g_rand',rmode);
                set_param(blkaccel,'dtype_a',matype);
                set_param(blkgyro,'dtype_g',mgtype);

                return

                function set_up_mask(blk)

                    mask_enables=get_param(blk,'maskEnables');

                    matype=get_param(blk,'dtype_a');
                    mgtype=get_param(blk,'dtype_g');
                    rtype=get_param(blk,'i_rand');

                    switch matype
                    case 'on'
                        if~strcmp(mask_enables(6),'on')
                            [mask_enables{5:6}]=deal('on');
                        end
                    case 'off'
                        if~strcmp(mask_enables(6),'off')
                            [mask_enables{5:6}]=deal('off');
                        end
                    otherwise
                        error(message('vdynblks:vehdynblkimu:invalidAccelType'));
                    end

                    switch mgtype
                    case 'on'
                        if~strcmp(mask_enables(11),'on')
                            [mask_enables{11:12}]=deal('on');
                        end
                    case 'off'
                        if~strcmp(mask_enables(11),'off')
                            [mask_enables{11:12}]=deal('off');
                        end
                    otherwise
                        error(message('vdynblks:vehdynblkimu:invalidGyroType'));
                    end

                    switch rtype
                    case 'off'
                        if~strcmp(mask_enables(18),'off')
                            [mask_enables{18:19}]=deal('off');
                        end
                    case 'on'
                        if~strcmp(mask_enables(18),'on')
                            [mask_enables{18:19}]=deal('on');
                        end
                    otherwise
                        error(message('vdynblks:vehdynblkimu:invalidRep'));
                    end

                    set_param(blk,'maskEnables',mask_enables);

                    return



