function hClockNet=getClockModuleDCMNetwork(topNet,pirInstance,networkName,...
    fpgaFamily,isDiff,dcmFXMul,dcmFXDiv,dcmClkInPeriod,skipDCM)




    if nargin<9
        skipDCM=false;
    end

    if nargin<8
        dcmClkInPeriod=0;
    end

    if nargin<7
        dcmFXDiv=0;
    end

    if nargin<6
        dcmFXMul=0;
    end

    if nargin<5
        isDiff=false;
    end

    switch fpgaFamily
    case 'Spartan2'
        dcmName='CLKDLL';

    case{'Virtex2','Virtex2P','Spartan3'}
        dcmName='DCM';

    case{'Spartan-3A DSP','Spartan3A and Spartan3AN','Spartan3E','Spartan6','Spartan6 Lower Power'}
        dcmName='DCM_SP';

    case{'Virtex4','Virtex5'}
        dcmName='DCM_BASE';

    case{'Virtex6','Virtex7','Kintex7','Artix7','Zynq'}
        dcmName='MMCM_BASE';

    otherwise
        error(message('hdlcommon:workflow:UnsupportedCMFamily',fpgaFamily));
    end

    ufix1Type=pir_ufixpt_t(1,0);

    if isDiff

        hClockNet=pirelab.createNewNetwork(...
        'PirInstance',pirInstance,...
        'Network',topNet,...
        'Name',networkName,...
        'InportNames',{'clkin_p','clkin_n','resetin'},...
        'InportTypes',[ufix1Type,ufix1Type,ufix1Type],...
        'OutportNames',{'sysclk','sysreset'},...
        'OutportTypes',[ufix1Type,ufix1Type]);


        clkin_p=hClockNet.PirInputSignals(1);
        clkin_n=hClockNet.PirInputSignals(2);
        resetin=hClockNet.PirInputSignals(3);
        hInSignals=[clkin_p,clkin_n];

    else

        hClockNet=pirelab.createNewNetwork(...
        'PirInstance',pirInstance,...
        'Network',topNet,...
        'Name',networkName,...
        'InportNames',{'clkin','resetin'},...
        'InportTypes',[ufix1Type,ufix1Type],...
        'OutportNames',{'sysclk','sysreset'},...
        'OutportTypes',[ufix1Type,ufix1Type]);


        clkin=hClockNet.PirInputSignals(1);
        resetin=hClockNet.PirInputSignals(2);
        hInSignals=clkin;
    end


    hClockNet.addCustomLibraryPackage('UNISIM','vcomponents');


    sysclk=hClockNet.PirOutputSignals(1);
    sysreset=hClockNet.PirOutputSignals(2);


    ibufg_out=hClockNet.addSignal(ufix1Type,'ibufg_out');
    if isDiff
        pirtarget.getIBUFGDSComp(hClockNet,hInSignals,ibufg_out);
    else
        pirtarget.getIBUFGComp(hClockNet,hInSignals,ibufg_out);
    end


    if skipDCM
        pirtarget.getBUFGComp(hClockNet,ibufg_out,sysclk);
        pirelab.getWireComp(hClockNet,resetin,sysreset);
        return;
    end


    dcm_out=hClockNet.addSignal(ufix1Type,'dcm_out');
    locked=hClockNet.addSignal(ufix1Type,'locked');

    if dcmFXMul>0&&dcmFXDiv>0&&dcmClkInPeriod>0


        bufg_out=hClockNet.addSignal(ufix1Type,'bufg_out');
        dcmfx_out=hClockNet.addSignal(ufix1Type,'dcmfx_out');
        if strcmp(dcmName,'DCM_SP')

            psen=hClockNet.addSignal(ufix1Type,'psen');
            const_0=hClockNet.addSignal(ufix1Type,'const_0');
            pirelab.getConstComp(hClockNet,const_0,0);
            pirelab.getWireComp(hClockNet,const_0,psen);
            hInSignals=[ibufg_out,bufg_out,resetin,psen];
            hOutSignals=[dcm_out,dcmfx_out,locked];
        elseif strcmp(dcmName,'MMCM_BASE')
            pwrdwn=hClockNet.addSignal(ufix1Type,'PWRDWN');
            const_0=hClockNet.addSignal(ufix1Type,'const_0');
            pirelab.getConstComp(hClockNet,const_0,0);
            pirelab.getWireComp(hClockNet,const_0,pwrdwn);
            hInSignals=[ibufg_out,bufg_out,resetin,pwrdwn];
            hOutSignals=[dcm_out,dcmfx_out,locked];
        else
            hInSignals=[ibufg_out,bufg_out,resetin];
            hOutSignals=[dcm_out,dcmfx_out,locked];
        end
        pirtarget.getDCMComp(hClockNet,hInSignals,hOutSignals,dcmName,dcmFXMul,dcmFXDiv,dcmClkInPeriod);


        pirtarget.getBUFGComp(hClockNet,dcm_out,bufg_out);


        pirtarget.getBUFGComp(hClockNet,dcmfx_out,sysclk);

    else

        if strcmp(dcmName,'DCM_SP')

            psen=hClockNet.addSignal(ufix1Type,'psen');
            const_0=hClockNet.addSignal(ufix1Type,'const_0');
            pirelab.getConstComp(hClockNet,const_0,0);
            pirelab.getWireComp(hClockNet,const_0,psen);
            hInSignals=[ibufg_out,sysclk,resetin,psen];
            hOutSignals=[dcm_out,locked];
        elseif strcmp(dcmName,'MMCM_BASE')
            pwrdwn=hClockNet.addSignal(ufix1Type,'PWRDWN');
            const_0=hClockNet.addSignal(ufix1Type,'const_0');
            pirelab.getConstComp(hClockNet,const_0,0);
            pirelab.getWireComp(hClockNet,const_0,pwrdwn);
            hInSignals=[ibufg_out,sysclk,resetin,pwrdwn];
            hOutSignals=[dcm_out,locked];
        else
            hInSignals=[ibufg_out,sysclk,resetin];
            hOutSignals=[dcm_out,locked];
        end
        pirtarget.getDCMComp(hClockNet,hInSignals,hOutSignals,dcmName);


        pirtarget.getBUFGComp(hClockNet,dcm_out,sysclk);

    end


    pirelab.getBitwiseOpComp(hClockNet,locked,sysreset,'NOT');



