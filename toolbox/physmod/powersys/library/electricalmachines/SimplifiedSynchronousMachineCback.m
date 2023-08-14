function SimplifiedSynchronousMachineCback(block,P)





    if~exist('P','var')
        P=0;
    end

    aMaskObj=Simulink.Mask.get(block);
    AdvancedTab=aMaskObj.getDialogControl('Advanced');

    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    if PowerguiInfo.Continuous||PowerguiInfo.Phasor||PowerguiInfo.DiscretePhasor
        switch get_param(block,'Tsblock')
        case '-1'
            AdvancedTab.Visible='off';
        otherwise
            AdvancedTab.Visible='on';
        end
    else
        if PowerguiInfo.AutomaticDiscreteSolvers
            AdvancedTab.Visible='off';
        else
            AdvancedTab.Visible='on';
        end
    end

    conType=get_param(block,'ConnectionType');
    ports=get_param(block,'ports');

    MaskEnables=get_param(block,'MaskEnables');
    set_param(block,'MaskEnables',MaskEnables);

    switch get_param([block,'/Mechanical model'],'ReferenceBlock');

    case 'spsSimpleSynchronousMachineModel/Shaft input'
        if strcmp(conType,'4-wire Y')&&ports(6)==1&&P==1

            add_block('built-in/PMIOPort',[block,'/N']);
            set_param([block,'/N'],'Position',[90,440,110,460],'side','Left','orientation','right');

            SSMPortHandles=get_param([block,'/SSM'],'PortHandles');
            NPortHandle=get_param([block,'/N'],'PortHandles');

            add_line(block,SSMPortHandles.LConn,NPortHandle.RConn)

        elseif strcmp(conType,'3-wire Y')&&ports(6)==2&&P==1

            PortHandles=get_param([block,'/SSM'],'PortHandles');
            ligne1=get_param(PortHandles.LConn(1),'line');
            delete_line(ligne1);
            delete_block([block,'/N']);
        end

    otherwise
        if strcmp(conType,'4-wire Y')&&ports(6)==0&&P==1

            add_block('built-in/PMIOPort',[block,'/N']);
            set_param([block,'/N'],'Position',[90,440,110,460],'side','Left','orientation','right');

            SSMPortHandles=get_param([block,'/SSM'],'PortHandles');
            NPortHandle=get_param([block,'/N'],'PortHandles');

            add_line(block,SSMPortHandles.LConn,NPortHandle.RConn)

        elseif strcmp(conType,'3-wire Y')&&ports(6)==1&&P==1

            PortHandles=get_param([block,'/SSM'],'PortHandles');
            ligne1=get_param(PortHandles.LConn(1),'line');
            delete_line(ligne1);
            delete_block([block,'/N']);
        end
    end



    MaskVisibilities=get_param(block,'MaskVisibilities');

    switch get_param(block,'BusType')
    case 'swing'
        MaskVisibilities{end-2}='off';
        MaskVisibilities{end-3}='off';
        MaskVisibilities{end-4}='off';
        MaskVisibilities{end-5}='off';
    case 'PV'
        MaskVisibilities{end-2}='on';
        MaskVisibilities{end-3}='on';
        MaskVisibilities{end-4}='off';
        MaskVisibilities{end-5}='on';
    case 'PQ'
        MaskVisibilities{end-2}='off';
        MaskVisibilities{end-3}='off';
        MaskVisibilities{end-4}='on';
        MaskVisibilities{end-5}='on';
    end

    set_param(block,'Maskvisibilities',MaskVisibilities);
