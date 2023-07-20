function reszok=autoblkssiengresize(varargin)





    reszok=false;
    block=varargin{1};
    maskMode=varargin{2};
    vvc=endsWith(maskMode,'vvc');
    nomsk=endsWith(maskMode,'nomsk');
    if vvc
        maskMode=erase(maskMode,'vvc');
    end
    if nomsk
        maskMode=erase(maskMode,'nomsk');
        vvc=true;
    end
    if autoblkschecksimstopped(block)
        switch maskMode
        case 'open'
            initializemaskvars(block,vvc);
        case 'resizebasis'
            resizebasiscallback(block);
        case 'resize'
            reszok=resizeengine(block,vvc,nomsk);

        case 'defTrq'
            resizeLite(block,'trq',vvc);
        case 'defSpd'
            resizeLite(block,'spd',vvc);
        case 'updateEng'
            updateEngConfig(block,vvc);
        end
    end
end

function reszok=resizeengine(block,vvc,nomsk)

    maskObj=get_param(block,'MaskObject');

    sizetype=maskObj.getParameter('EngReszSpecType').Value;




    trqReq=maskObj.getParameter('EngReszDesMaxTq').Value;
    spdReq=maskObj.getParameter('EngReszReqMaxTqSpd').Value;




    hwseparent=setEngVar(maskObj,vvc);


    if vvc
        [ddataobjs,~,~,~,~,~,~,~,~,~,~,~]=loaddictionaries({'SiEngineCore.sldd'});
        hwse=ddataobjs{1};
        cps=getDdData(hwse,'PlntEngCps');
    else
        [hwse,~,~,~,~,~,~,~,~,~,~,~]=loaddictionaries(block);
        cps=getmdldata(hwse,'Cps');
    end



    egrBlk=[hwseparent,'/LP EGR'];
    if strcmp(maskObj.getParameter('EngReszEgr').Value,'on')
        set_param(egrBlk,'LabelModeActiveChoice','LpEGR');
    else
        set_param(egrBlk,'LabelModeActiveChoice','NoEGR');
    end

    if vvc
        BrakeTq=getDdData(ddataobjs{1},'PlntEngInTrqMap')...
        -getDdData(ddataobjs{1},'PlntEngTqFric')...
        -getDdData(ddataobjs{1},'PlntEngTqPump');
        tqspeedbp=getDdData(ddataobjs{1},'PlntEngInTrqSpdBpt');
        CurrDisp=round(1000.*getDdData(ddataobjs{1},'PlntEngVd'),2);
        CurrNumCyl=getDdData(ddataobjs{1},'PlntEngNCyl');
    else
        BrakeTq=getmdldata(hwse,'f_tq_inr')...
        -getmdldata(hwse,'f_tq_fric')...
        -getmdldata(hwse,'f_tq_pump');
        tqspeedbp=getmdldata(hwse,'f_tq_inr_n_bpt');
        CurrDisp=round(1000.*getmdldata(hwse,'Vd'),2);
        CurrNumCyl=getmdldata(hwse,'NCyl');
    end
    maxtqvsspeed=max(BrakeTq);
    [MaxPwr,~]=max(maxtqvsspeed.*tqspeedbp*pi/30/1000.);
    DispTarget=str2double(maskObj.getParameter('EngReszDispDesIn').Value);
    NewNumCyl=round(str2double(maskObj.getParameter('EngReszNumCylDes').Value));
    CurrMaxPwrVal=MaxPwr;
    [MaxTq,i]=max(maxtqvsspeed);
    CurrMaxTrqSp=round(tqspeedbp(i),0);
    CurrMaxTrq=round(MaxTq,1);
    CurrMaxMep=2*pi*cps*CurrMaxTrq/CurrDisp/100;

    maxTrq=0;
    nMaxTrq=0;
    PowerScaleRatio=1;
    EngSpdRatioRatio=1;
    mepNvar=1;


    dsplRezs=strcmp(sizetype,'Displacement');
    trqSpec=strcmp(maskObj.getParameter('TrqSpec').Value,'on');
    trqSpdSpec=strcmp(maskObj.getParameter('TrqSpdSpec').Value,'on');
    if dsplRezs&&trqSpec
        maxTrq=str2double(maskObj.getParameter('EngReszDesMaxTq').Value);
    end
    if dsplRezs&&trqSpdSpec
        nMaxTrq=str2double(maskObj.getParameter('EngReszReqMaxTqSpd').Value);
    end
    spdOk=false;
    [~,~,~,~,~,~,nLow,nHigh,~,~]=setParamLimit(block,hwse,vvc);
    if nMaxTrq~=0
        spdParm=nMaxTrq/CurrMaxTrqSp;
        if nMaxTrq>=nLow&&nMaxTrq<=nHigh
            spdOk=true;
        end

        nObs=[0.836639439906651,0.894593543368339,0.948658109684948,1,1.04900816802800,1.09568261376896,1.14041229093738,1.18358615324776,1.22481524698561,1.26526643329444];
        SRR=[0.7,0.8,0.9,1,1.1,1.2,1.3,1.4,1.5,1.6];

        EngSpdRatioRatio=interp1(nObs,SRR,spdParm,'pchip','extrap');

        mepSp=[0.836513443191674,0.894189071986123,0.948395490026019,1,1.04856895056375,1.09540329575022,1.14006938421509,1.18300086730269,1.22463139635733,1.26452732003469];
        mepNvar=interp1(nObs,mepSp,spdParm,'pchip','extrap');
    end
    if strcmp(hwseparent,'SiEngineCoreNA')||strcmp(hwseparent,'SiEngineCoreVNA')
        tqCorr=1.151;
    else
        tqCorr=1.011;
    end
    trqOk=false;
    [~,~,~,~,~,~,~,~,mepLow,mepHigh]=setParamLimit(block,hwse,vvc);
    if maxTrq~=0
        maxMep=2*pi*cps*maxTrq/DispTarget/100;
        mepParm=maxMep/CurrMaxMep;
        if maxMep>=mepLow&&maxMep<=mepHigh
            trqOk=true;
        end

        PowerScaleRatio=mepParm/mepNvar*tqCorr;
    end
    trqSpdOk=(PowerScaleRatio==1&&EngSpdRatioRatio==1)||(PowerScaleRatio==1&&spdOk)||(trqOk&&EngSpdRatioRatio==1)||(trqOk&&spdOk);


    switch sizetype
    case 'Power'
        set_param(block,'EngReszMaxPwrDes',num2str(eval(get_param(block,'EngReszMaxPwrDesIn'))));
        PowerTarget=eval(get_param(block,'EngReszMaxPwrDesIn'));
        DispScaleFactor=DispScaleFactorByPower(CurrMaxPwrVal,PowerTarget,CurrNumCyl,NewNumCyl);
        set_param(block,'EngReszDispDesIn',num2str(DispScaleFactor*CurrDisp));
    case 'Displacement'

        PowerScaleFactor=PowerScaleFactorByDisp(CurrDisp,DispTarget,CurrNumCyl,NewNumCyl,EngSpdRatioRatio,PowerScaleRatio);
        set_param(block,'EngReszMaxPwrDes',num2str(PowerScaleFactor*CurrMaxPwrVal));
        set_param(block,'EngReszMaxPwrDesIn',num2str(PowerScaleFactor*CurrMaxPwrVal));
    end

    NewMaxPwrVal=eval(get_param(block,'EngReszMaxPwrDes'));


    if(round(CurrMaxPwrVal,2)~=round(NewMaxPwrVal,2)||CurrNumCyl~=NewNumCyl)&&~isempty(NewMaxPwrVal)&&~isempty(NewNumCyl)


        if vvc
            [ddataobjs,~,ddobjs,~,~,~,~,~,~,~,~,~]=...
            loaddictionaries({'SiEngineCore.sldd';...
            'SiEngineController.sldd';...
            'SiEngine.sldd';...
            'Environment.sldd';...
            'SiMappedEngine.sldd';...
            'SimpleEngine.sldd';...
            'SiDynoReferenceApplication.sldd'});
            hwse=ddataobjs{1};
        else
            [hwse,~,hwsc,~,hwsd,~,hwset,~,hwsme,~,hwsse,~]=loaddictionaries(block);
            ddobjs=[];
        end


        ParamValues=get_param(block,'MaskValues');

        close_system(block);
        set_param(block,'MaskValues',ParamValues)

        if vvc
            ParamList=setParamList(block,hwse,vvc);
        end

        if nomsk
            try
                autoblkscheckparams(block,ParamList);
            catch errmsg
                errordlg(errmsg.message,...
                getString(message('autoblks:autoblkDynoMask:msgBxCfTle')),'replace');
                return
            end
        elseif vvc
            open_system(block,'Mask');
            autoblkscheckparams(block,ParamList);
        else
            open_system(block,'Mask');
        end

        hwseparent=setEngVar(maskObj,vvc);

        [minPwr,maxPwr,minDspl,maxDspl,minNCyls,maxNCyls,~,~,~,~]=setParamLimit(block,hwse,vvc);
        pwrOk=strcmp(sizetype,'Power')&&...
        (eval(get_param(block,'EngReszMaxPwrDes'))>=minPwr)&&...
        (eval(get_param(block,'EngReszMaxPwrDes'))<=maxPwr);
        dispOk=strcmp(sizetype,'Displacement')&&...
        (eval(get_param(block,'EngReszDispDesIn'))>=minDspl)&&...
        (eval(get_param(block,'EngReszDispDesIn'))<=maxDspl);
        if(eval(get_param(block,'EngReszNumCylDes'))>=minNCyls)&&...
            (eval(get_param(block,'EngReszNumCylDes'))<=maxNCyls)&&...
            (pwrOk||dispOk)&&trqSpdOk

            if~nomsk
                hwb=waitbar(0,getString(message('autoblks:autoblkDynoMask:waitBMsg')));
                waitbar(0.1,hwb);
            end


            if vvc
                updatedependentresizeparms(ddataobjs,hwseparent,ddobjs,block,vvc);
            else
                updatedependentresizeparms(hwse,hwseparent,hwsc,block,vvc);
            end

            if~nomsk
                waitbar(0.2,hwb);
            end


            EngPwrRatio=NewMaxPwrVal/CurrMaxPwrVal;
            EngCylNumRatio=NewNumCyl/CurrNumCyl;
            DispRatio=DispTarget/CurrDisp;

            if EngSpdRatioRatio~=1
                spdPwr=(DispRatio/EngCylNumRatio)^(1/3);
            else
                spdPwr=1;
            end
            EngSpdRatio=sqrt(EngCylNumRatio/EngPwrRatio)*...
            EngSpdRatioRatio*PowerScaleRatio^0.5*spdPwr;
            EngTrqRatio=EngPwrRatio/EngSpdRatio*spdPwr;
            if vvc
                vdispl=getDdData(ddataobjs{1},'PlntEngVd');
            else
                vdispl=getmdldata(hwse,'Vd');
            end
            EngDispDes=vdispl*EngTrqRatio/EngSpdRatioRatio^0.5/PowerScaleRatio;
            EngDispRatio=EngTrqRatio/EngSpdRatioRatio^0.5/PowerScaleRatio;
            EngCylVolDes=EngDispDes/NewNumCyl;
            EngCylVol=vdispl/CurrNumCyl;
            EngCylVolRatio=EngCylVolDes/EngCylVol;

            if vvc

                setDdData(ddataobjs{1},'PlntEngNCyl',NewNumCyl);

                setDdData(ddataobjs{1},'PlntEngVd',EngDispDes);
                setDdData(ddataobjs{1},'PlntEngVexh',...
                getDdData(ddataobjs{1},'PlntEngVexh')*EngDispRatio);
                setDdData(ddataobjs{1},'PlntEngVint',...
                getDdData(ddataobjs{1},'PlntEngVint')*EngDispRatio);
                setDdData(ddataobjs{1},'PlntEngIntkVol',...
                getDdData(ddataobjs{1},'PlntEngIntkVol')*EngDispRatio);
                setDdData(ddataobjs{1},'PlntEngExhSysVol',...
                getDdData(ddataobjs{1},'PlntEngExhSysVol')*EngDispRatio);
                setDdData(ddataobjs{1},'PlntEngCmpVolOut',...
                getDdData(ddataobjs{1},'PlntEngCmpVolOut')*EngDispRatio);
                setDdData(ddataobjs{1},'PlntEngVivc',...
                getDdData(ddataobjs{1},'PlntEngVivc')*EngCylVolRatio);

                egrArea=getDdData(ddataobjs{1},'PlntEngEgrArea');
                setDdData(ddataobjs{1},'PlntEngEgrArea',egrArea*EngPwrRatio);

                setDdData(ddataobjs{2},'CtrlEcuEgrCmdNBpt',...
                getDdData(ddataobjs{2},'CtrlEcuEgrCmdNBpt')*EngSpdRatio);
                setDdData(ddataobjs{2},'CtrlEcuEgrMaxStdFlw',...
                getDdData(ddataobjs{2},'CtrlEcuEgrMaxStdFlw')*EngPwrRatio);
                setDdData(ddataobjs{2},'CtrlEcuEgrTau',...
                getDdData(ddataobjs{2},'CtrlEcuEgrTau')*EngDispRatio);
                setDdData(ddataobjs{2},'CtrlEcuInkStdFlwBpt',...
                getDdData(ddataobjs{2},'CtrlEcuInkStdFlwBpt')*EngPwrRatio);
                setDdData(ddataobjs{2},'CtrlEcuEgrStdFlw',...
                getDdData(ddataobjs{2},'CtrlEcuEgrStdFlw')*EngPwrRatio);

                setDdData(ddataobjs{1},'PlntEngThrDia',...
                sqrt(EngPwrRatio*getDdData(ddataobjs{1},'PlntEngThrDia')^2));

                setDdData(ddataobjs{1},'PlntEngTrbWgArea',...
                EngPwrRatio*getDdData(ddataobjs{1},'PlntEngTrbWgArea'));

                setDdData(ddataobjs{1},'PlntEngAFArea',...
                getDdData(ddataobjs{1},'PlntEngAFArea')*EngPwrRatio);
                setDdData(ddataobjs{1},'PlntEngExhSysArea',...
                getDdData(ddataobjs{1},'PlntEngExhSysArea')*EngPwrRatio);

                setDdData(ddataobjs{1},'PlntEngSinj',...
                EngCylVolRatio*getDdData(ddataobjs{1},'PlntEngSinj'));


                setDdData(ddataobjs{1},'PlntEngMdotTrpdBpt',...
                getDdData(ddataobjs{1},'PlntEngMdotTrpdBpt')*EngPwrRatio);
                setDdData(ddataobjs{1},'PlntEngMdotIntk',...
                getDdData(ddataobjs{1},'PlntEngMdotIntk')*EngPwrRatio);

                setDdData(ddataobjs{1},'PlntEngCmpMAF',...
                getDdData(ddataobjs{1},'PlntEngCmpMAF')*EngPwrRatio);
                setDdData(ddataobjs{1},'PlntEngTrbMFR',...
                getDdData(ddataobjs{1},'PlntEngTrbMFR')*EngPwrRatio);

                setDdData(ddataobjs{1},'PlntEngTrbSpdBpt',...
                getDdData(ddataobjs{1},'PlntEngTrbSpdBpt')/sqrt(EngPwrRatio));
                setDdData(ddataobjs{1},'PlntEngCmpSpdBpt',...
                getDdData(ddataobjs{1},'PlntEngCmpSpdBpt')/sqrt(EngPwrRatio));

                setDdData(ddataobjs{1},'PlntEngTurboInert',...
                getDdData(ddataobjs{1},'PlntEngTurboInert')*EngPwrRatio);

            else

                setmdldata(hwse,'NCyl',NewNumCyl);
                setmdldata(hwsme,'NCyl',NewNumCyl);
                setmdldata(hwsc,'NCyl',NewNumCyl);

                setmdldata(hwse,'Vd',EngDispDes);
                setmdldata(hwsme,'Vd',EngDispDes);
                setmdldata(hwse,'Vexh',getmdldata(hwse,'Vexh')*EngDispRatio);
                setmdldata(hwse,'Vint',getmdldata(hwse,'Vint')*EngDispRatio);
                setmdldata(hwse,'AirIntakeVol',...
                getmdldata(hwse,'AirIntakeVol')*EngDispRatio);
                setmdldata(hwse,'ExhSysVol',...
                getmdldata(hwse,'ExhSysVol')*EngDispRatio);
                setmdldata(hwse,'VolCompOut',...
                getmdldata(hwse,'VolCompOut')*EngDispRatio);
                setmdldata(hwse,'f_vivc',getmdldata(hwse,'f_vivc')*EngCylVolRatio);

                setmdldata(hwsc,'Vd',EngDispDes);
                setmdldata(hwsc,'f_vivc',getmdldata(hwsc,'f_vivc')*EngCylVolRatio);

                egrArea=getmdldata(hwse,'EgrArea');
                setmdldata(hwse,'EgrArea',egrArea*EngPwrRatio);

                setmdldata(hwsc,'f_egrpct_n_bpt',...
                getmdldata(hwsc,'f_egrpct_n_bpt')*EngSpdRatio);
                setmdldata(hwsc,'f_egr_max_stdflow',...
                getmdldata(hwsc,'f_egr_max_stdflow')*EngPwrRatio);
                setmdldata(hwsc,'tau_egr',...
                getmdldata(hwsc,'tau_egr')*EngDispRatio);
                setmdldata(hwsc,'f_intksys_stdflow_bpt',...
                getmdldata(hwsc,'f_intksys_stdflow_bpt')*EngPwrRatio);
                setmdldata(hwsc,'f_egr_stdflow',...
                getmdldata(hwsc,'f_egr_stdflow')*EngPwrRatio);

                setmdldata(hwse,'ThrDiam',...
                sqrt(EngPwrRatio*getmdldata(hwse,'ThrDiam')^2));

                setmdldata(hwse,'WgArea',EngPwrRatio*getmdldata(hwse,'WgArea'));

                setmdldata(hwse,'AirFilterArea',...
                getmdldata(hwse,'AirFilterArea')*EngPwrRatio);
                setmdldata(hwse,'ExhSysArea',...
                getmdldata(hwse,'ExhSysArea')*EngPwrRatio);

                setmdldata(hwse,'Sinj',EngCylVolRatio*getmdldata(hwse,'Sinj'));

                setmdldata(hwsc,'Sinj',EngCylVolRatio*getmdldata(hwsc,'Sinj'));

                setmdldata(hwse,'f_mdot_trpd_bpt',...
                getmdldata(hwse,'f_mdot_trpd_bpt')*EngPwrRatio);
                setmdldata(hwse,'f_mdot_intk',...
                getmdldata(hwse,'f_mdot_intk')*EngPwrRatio);

                setmdldata(hwsc,'f_mdot_trpd_bpt',...
                getmdldata(hwsc,'f_mdot_trpd_bpt')*EngPwrRatio);
                setmdldata(hwsc,'f_mdot_intk',...
                getmdldata(hwsc,'f_mdot_intk')*EngPwrRatio);

                setmdldata(hwse,'CompMassFlwRate',...
                getmdldata(hwse,'CompMassFlwRate')*EngPwrRatio);
                setmdldata(hwse,'TurbMassFlwRate',...
                getmdldata(hwse,'TurbMassFlwRate')*EngPwrRatio);

                setmdldata(hwse,'TurbSpdBreakPoints',...
                getmdldata(hwse,'TurbSpdBreakPoints')/sqrt(EngPwrRatio));
                setmdldata(hwse,'CompSpdBreakPoints',...
                getmdldata(hwse,'CompSpdBreakPoints')/sqrt(EngPwrRatio));

                setmdldata(hwse,'TurboInertia',...
                getmdldata(hwse,'TurboInertia')*EngPwrRatio);
            end

            if~nomsk
                waitbar(0.3,hwb);
            end



            if vvc
                PlantSpeedUpdateList={...
                'PlntEngExhFracNBpt',...
                'PlntEngMdotAirCorrNBpt',...
                'PlntEngNvSpdBpt',...
                'PlntEngTexhNBpt',...
                'PlntEngTmCorrNBpt',...
                'PlntEngInTrqSpdBpt',...
                'PlntEngTqTblNBpt',...
                'PlntEngCrkNBpt'};
                rescaleparameters(PlantSpeedUpdateList,ddataobjs{1},EngSpdRatio,vvc);
            else
                PlantSpeedUpdateList={...
                'f_exhfrac_n_bpt',...
                'f_mdot_air_n_bpt',...
                'f_nv_n_bpt',...
                'f_t_exh_n_bpt',...
                'f_tm_corr_n_bpt',...
                'f_tq_inr_n_bpt',...
                'f_tq_nl_n_bpt',...
                'f_crk_n_bpt'};
                rescaleparameters(PlantSpeedUpdateList,hwse,EngSpdRatio,vvc);
            end

            if~nomsk
                waitbar(0.5,hwb);
            end




            if vvc
                ControllerSpeedUpdateList={...
                'CtrlEcuLCmdSpdBpt',...
                'CtrlEcuTapNBpt',...
                'CtrlEcuWapNBpt',...
                'CtrlEcuCpNBpt',...
                'CtrlEcuLamCmdNBpt',...
                'CtrlEcuSaNBpt',...
                'CtrlEcuNidle'};
                rescaleparameters(ControllerSpeedUpdateList,ddataobjs{2},EngSpdRatio,vvc);
            else
                ControllerSpeedUpdateList={...
                'f_lcmd_n_bpt',...
                'f_tap_n_bpt',...
                'f_wap_n_bpt',...
                'f_cp_n_bpt',...
                'f_lamcmd_n_bpt',...
                'f_sa_n_bpt',...
                'N_idle',...
                'f_tm_corr_n_bpt',...
                'f_mdot_air_n_bpt',...
                'f_tq_inr_n_bpt',...
                'f_t_exh_n_bpt',...
                'f_tq_nl_n_bpt',...
                'f_nv_n_bpt'};
                rescaleparameters(ControllerSpeedUpdateList,hwsc,EngSpdRatio,vvc);
            end

            if~nomsk
                waitbar(0.7,hwb);
            end

            if NewNumCyl==4
                f_crk_tdc_ang=[0,540,180,360];
            else
                f_crk_tdc_ang=(0:NewNumCyl-1)*720/NewNumCyl;
            end
            if vvc

                setDdData(ddataobjs{1},'PlntEngInTrqMap',...
                getDdData(ddataobjs{1},'PlntEngInTrqMap')*EngTrqRatio);
                setDdData(ddataobjs{1},'PlntEngTqFric',...
                getDdData(ddataobjs{1},'PlntEngTqFric')*EngTrqRatio);
                setDdData(ddataobjs{1},'PlntEngTqPump',...
                getDdData(ddataobjs{1},'PlntEngTqPump')*EngTrqRatio);
                setDdData(ddataobjs{1},'PlntEngTqTbl',...
                getDdData(ddataobjs{1},'PlntEngTqTbl')*EngTrqRatio);
                setDdData(ddataobjs{1},'PlntEngCrkBtq',...
                getDdData(ddataobjs{1},'PlntEngCrkBtq')*EngTrqRatio);

                setDdData(ddataobjs{1},'PlntEngCrkTdcAng',f_crk_tdc_ang);

                setDdData(ddataobjs{1},'PlntEngExhFracTqBpt',...
                getDdData(ddataobjs{1},'PlntEngExhFracTqBpt')*EngTrqRatio);

                setDdData(ddataobjs{2},'CtrlEcuLCmdTqBpt',...
                getDdData(ddataobjs{2},'CtrlEcuLCmdTqBpt')*EngTrqRatio);
            else

                setmdldata(hwse,'f_tq_inr',...
                getmdldata(hwse,'f_tq_inr')*EngTrqRatio);
                setmdldata(hwse,'f_tq_fric',...
                getmdldata(hwse,'f_tq_fric')*EngTrqRatio);
                setmdldata(hwse,'f_tq_pump',...
                getmdldata(hwse,'f_tq_pump')*EngTrqRatio);
                setmdldata(hwse,'f_tq_nl',...
                getmdldata(hwse,'f_tq_nl')*EngTrqRatio);
                setmdldata(hwse,'f_crk_btq',...
                getmdldata(hwse,'f_crk_btq')*EngTrqRatio);

                setmdldata(hwse,'f_crk_tdc_ang',f_crk_tdc_ang);

                setmdldata(hwsc,'f_tq_inr',...
                getmdldata(hwsc,'f_tq_inr')*EngTrqRatio);
                setmdldata(hwsc,'f_tq_fric',...
                getmdldata(hwsc,'f_tq_fric')*EngTrqRatio);
                setmdldata(hwsc,'f_tq_pump',...
                getmdldata(hwsc,'f_tq_pump')*EngTrqRatio);
                setmdldata(hwsc,'f_tq_nl',...
                getmdldata(hwsc,'f_tq_nl')*EngTrqRatio);

                setmdldata(hwse,'f_exhfrac_trq_bpt',...
                getmdldata(hwse,'f_exhfrac_trq_bpt')*EngTrqRatio);

                setmdldata(hwsc,'f_lcmd_tq_bpt',...
                getmdldata(hwsc,'f_lcmd_tq_bpt')*EngTrqRatio);
            end

            if~nomsk
                waitbar(0.7,hwb);
            end




            if vvc
                SteadyEngSpdCmdPts=getDdData(ddataobjs{7},'SiDynoSSSpdCmd')*EngSpdRatio;
                setDdData(ddataobjs{7},'SiDynoSSSpdCmd',SteadyEngSpdCmdPts);
                SteadyTrqCmdPts=getDdData(ddataobjs{7},'SiDynoSSTrqCmd')*EngTrqRatio;
                setDdData(ddataobjs{7},'SiDynoSSTrqCmd',SteadyTrqCmdPts);

                setDdData(ddataobjs{5},'PlntEngBrkTrqBpt',...
                getDdData(ddataobjs{5},'PlntEngBrkTrqBpt')*EngTrqRatio);
                setDdData(ddataobjs{5},'PlntEngBrkTrqSpdBpt',...
                getDdData(ddataobjs{5},'PlntEngBrkTrqSpdBpt')*EngSpdRatio);

                setDdData(ddataobjs{6},'PlntEngTqMax',...
                getDdData(ddataobjs{6},'PlntEngTqMax')*EngTrqRatio);
                setDdData(ddataobjs{6},'PlntEngTqMaxBpt',...
                getDdData(ddataobjs{6},'PlntEngTqMaxBpt')*EngSpdRatio);

                setDdData(ddataobjs{3},'PlntEngAccSpdBpt',...
                getDdData(ddataobjs{3},'PlntEngAccSpdBpt')*EngSpdRatio);
                setDdData(ddataobjs{3},'PlntEngAccPwrTbl',...
                getDdData(ddataobjs{3},'PlntEngAccPwrTbl')*EngSpdRatio);
            else
                SteadyEngSpdCmdPts=getmdldata(hwsd,'SteadyEngSpdCmdPts')*EngSpdRatio;
                setmdldata(hwsd,'SteadyEngSpdCmdPts',SteadyEngSpdCmdPts);
                SteadyTrqCmdPts=getmdldata(hwsd,'SteadyTrqCmdPts')*EngTrqRatio;
                setmdldata(hwsd,'SteadyTrqCmdPts',SteadyTrqCmdPts);

                setmdldata(hwsme,'f_tbrake_t_bpt',getmdldata(hwsme,'f_tbrake_t_bpt')*EngTrqRatio);
                setmdldata(hwsme,'f_tbrake_n_bpt',getmdldata(hwsme,'f_tbrake_n_bpt')*EngSpdRatio);

                setmdldata(hwsse,'f_tqmax',getmdldata(hwsse,'f_tqmax')*EngTrqRatio);
                setmdldata(hwsse,'f_tqmax_n_bpt',getmdldata(hwsse,'f_tqmax_n_bpt')*EngSpdRatio);

                setmdldata(hwset,'AccSpdBpts',getmdldata(hwset,'AccSpdBpts')*EngSpdRatio);
                setmdldata(hwset,'AccPwrTbl',getmdldata(hwset,'AccPwrTbl')*EngPwrRatio);
                setmdldata(hwsme,'AccSpdBpts',getmdldata(hwsme,'AccSpdBpts')*EngSpdRatio);
                setmdldata(hwsme,'AccPwrTbl',getmdldata(hwsme,'AccPwrTbl')*EngPwrRatio);
                setmdldata(hwsse,'AccSpdBpts',getmdldata(hwsse,'AccSpdBpts')*EngSpdRatio);
                setmdldata(hwsse,'AccPwrTbl',getmdldata(hwsse,'AccPwrTbl')*EngPwrRatio);
            end

            if~nomsk
                waitbar(0.9,hwb);
            end


            saveDD(block,ddobjs);

            if~nomsk
                close(hwb);
            end


            close_system(block);


            load_system(block);
            maskObj.getParameter('EngReszDesMaxTq').set('Value',trqReq);
            maskObj.getParameter('EngReszReqMaxTqSpd').set('Value',spdReq);

            if vvc
                updatedependentresizeparms(ddataobjs,hwseparent,ddobjs,block,vvc);
            else
                updatedependentresizeparms(hwse,hwseparent,hwsc,block,vvc);
            end


            if nomsk
                RecalibrateSIController('SiDynoReferenceApplication/Subsystem3','OpenFcnNoMsk');
            else
                RecalibrateSIController('SiDynoReferenceApplication/Subsystem3','OpenFcn');
                open_system(block,'Mask');
            end
        end
        reszok=true;
    else
        msgbox(getString(message('autoblks:autoblkDynoMask:msgBxMsg')),...
        getString(message('autoblks:autoblkDynoMask:msgBxTitle')));
        reszok=false;
    end

end

function initializemaskvars(block,vvc)
    if vvc


        [ddataobjs,hwseparent,hwsc,~,~,~,~,~,~,~,~,~]=...
        loaddictionaries({'SiEngineCore.sldd';...
        'SiEngineController.sldd';...
        'SiEngine.sldd';...
        'Environment.sldd'});
    else

        set_param(block,'UserData',[]);

        [ddataobjs,hwseparent,hwsc,~,~,~,~,~,~,~,~,~]=loaddictionaries(block);
    end

    updatedependentresizeparms(ddataobjs,hwseparent,hwsc,block,vvc);

    restoreEngConfig(block,hwseparent,vvc)
end

function updatedependentresizeparms(ddataobjs,hwseparent,hwsc,block,vvc)
    if vvc
        BrakeTq=getDdData(ddataobjs{1},'PlntEngInTrqMap')...
        -getDdData(ddataobjs{1},'PlntEngTqFric')...
        -getDdData(ddataobjs{1},'PlntEngTqPump');
        tqspeedbp=getDdData(ddataobjs{1},'PlntEngInTrqSpdBpt');
        set_param(block,'EngReszDisp',...
        num2str(round(1000.*getDdData(ddataobjs{1},'PlntEngVd'),2)));
        set_param(block,'EngReszNumCyl',...
        num2str(getDdData(ddataobjs{1},'PlntEngNCyl')));
    else
        BrakeTq=getmdldata(ddataobjs,'f_tq_inr')-getmdldata(ddataobjs,'f_tq_fric')...
        -getmdldata(ddataobjs,'f_tq_pump');
        tqspeedbp=getmdldata(ddataobjs,'f_tq_inr_n_bpt');
        set_param(block,'EngReszDisp',...
        num2str(round(1000.*getmdldata(ddataobjs,'Vd'),2)));
        set_param(block,'EngReszNumCyl',num2str(getmdldata(ddataobjs,'NCyl')));
    end
    maxtqvsspeed=max(BrakeTq);
    [MaxPwr,i]=max(maxtqvsspeed.*tqspeedbp*pi/30/1000.);
    set_param(block,'EngReszMaxPwr',num2str(MaxPwr));
    set_param(block,'EngReszSpdMaxPwr',num2str(round(tqspeedbp(i),0)));
    set_param(block,'EngReszTqMaxPwr',num2str(round(maxtqvsspeed(i),1)));


    if vvc
        tqloadbp=getDdData(ddataobjs{1},'PlntEngInTrqLdBpt');
        NCyl=getDdData(ddataobjs{1},'PlntEngNCyl');
        Cps=getDdData(ddataobjs{1},'PlntEngCps');
        APCNom=getDdData(ddataobjs{4},'EnvAbsPrs')...
        *(getDdData(ddataobjs{1},'PlntEngVd')/NCyl)...
        /(287.*getDdData(ddataobjs{4},'EnvAirTemp'));
    else
        tqloadbp=getmdldata(ddataobjs,'f_tq_inr_l_bpt');
        NCyl=getmdldata(ddataobjs,'NCyl');
        Cps=getmdldata(ddataobjs,'Cps');
        APCNom=getmdldata(ddataobjs,'Pstd')...
        *(getmdldata(ddataobjs,'Vd')/NCyl)...
        /(287.*getmdldata(ddataobjs,'Tstd'));
    end
    Loadbp=repmat(tqloadbp(:),1,length(tqspeedbp));
    Speedbp=repmat(tqspeedbp,length(tqloadbp),1);
    AirFlowbp=APCNom*Loadbp.*Speedbp*NCyl/(Cps*60.);


    X2=Loadbp;
    Y2=Speedbp;
    if vvc
        X=getDdData(ddataobjs{2},'CtrlEcuLamCmdLBpt');
        Y=getDdData(ddataobjs{2},'CtrlEcuLamCmdNBpt');
        LAM_Table=getDdData(ddataobjs{2},'CtrlEcuLamCmd');
    else
        X=getmdldata(hwsc,'f_lamcmd_ld_bpt');
        Y=getmdldata(hwsc,'f_lamcmd_n_bpt');
        LAM_Table=getmdldata(hwsc,'f_lamcmd');
    end
    X2(X2>max(max(X)))=max(max(X));
    X2(X2<min(min(X)))=min(min(X));
    Y2(Y2>max(max(Y)))=max(max(Y));
    Y2(Y2<min(min(Y)))=min(min(Y));
    Lambda=interp2(Y,X,LAM_Table,Y2,X2);


    if vvc
        AFRStoich=getDdData(ddataobjs{3},'PlntEngAfrStoich');
    else
        AFRStoich=getmdldata(ddataobjs,'afr_stoich');
    end
    FuelFlow=1000.*3600.*AirFlowbp./(AFRStoich.*Lambda);
    EngPwr=BrakeTq.*Speedbp*pi/30./1000.;
    BSFC=FuelFlow./EngPwr;
    BSFC(isnan(BSFC))=Inf;
    BSFC(BSFC<=0)=Inf;
    bsfcpos=BSFC(Speedbp>0);
    [~,i]=min(bsfcpos);
    engpwrpos=EngPwr(Speedbp>0);
    speedbppos=Speedbp(Speedbp>0);
    braketqpos=BrakeTq(Speedbp>0);

    set_param(block,'EngReszBestFuelPwr',num2str(round(engpwrpos(i),1)));
    set_param(block,'EngReszBestFuelSpd',num2str(round(speedbppos(i),0)));
    set_param(block,'EngReszBestFuelTq',num2str(round(braketqpos(i),1)));
    set_param(block,'EngReszBestFuelBSFC',num2str(round(bsfcpos(i),1)));
    set_param(block,'EngReszIdleSpd',num2str(round(tqspeedbp(2),0)));
    if vvc
        set_param(block,'EngReszDisp',...
        num2str(round(1000.*getDdData(ddataobjs{1},'PlntEngVd'),2)));
    else
        set_param(block,'EngReszDisp',...
        num2str(round(1000.*getmdldata(ddataobjs,'Vd'),2)));
    end
    if strcmp(hwseparent,'SiEngineCoreNA')||...
        strcmp(hwseparent,'SiEngineCoreVNA')
        tqBias=0.856;
        spBias=2;
    else
        tqBias=0.989;
        spBias=0;
    end
    [MaxTq,i]=max(maxtqvsspeed);
    set_param(block,'EngReszMaxTqSpd',num2str(round(tqspeedbp(i+spBias),0)));
    set_param(block,'EngReszMaxTq',num2str(round(MaxTq*tqBias,1)));
    if vvc
        set_param(block,'EngReszThrDiam',...
        num2str(round(getDdData(ddataobjs{1},'PlntEngThrDia'),1)));
        set_param(block,'EngReszIntkManVol',...
        num2str(round(1000.*getDdData(ddataobjs{1},'PlntEngVint'),2)));
        set_param(block,'EngReszExhManVol',...
        num2str(round(1000.*getDdData(ddataobjs{1},'PlntEngVexh'),2)));
        set_param(block,'EngReszCompOutVol',...
        num2str(round(1000.*getDdData(ddataobjs{1},'PlntEngCmpVolOut'),2)));
        set_param(block,'EngReszMaxTurboSpd',...
        num2str(round(30.*max(getDdData(ddataobjs{1},'PlntEngCmpSpdBpt'))/pi,2)));
        set_param(block,'EngReszTurboRotInert',...
        num2str(round(1000.*getDdData(ddataobjs{1},'PlntEngTurboInert'),3)));
        set_param(block,'EngReszInjSlp',...
        num2str(round(getDdData(ddataobjs{1},'PlntEngSinj'),2)));
    else
        set_param(block,'EngReszThrDiam',...
        num2str(round(getmdldata(ddataobjs,'ThrDiam'),1)));
        set_param(block,'EngReszIntkManVol',...
        num2str(round(1000.*getmdldata(ddataobjs,'Vint'),2)));
        set_param(block,'EngReszExhManVol',...
        num2str(round(1000.*getmdldata(ddataobjs,'Vexh'),2)));
        set_param(block,'EngReszCompOutVol',...
        num2str(round(1000.*getmdldata(ddataobjs,'VolCompOut'),2)));
        set_param(block,'EngReszMaxTurboSpd',...
        num2str(round(30.*max(getmdldata(ddataobjs,'CompSpdBreakPoints'))/pi,2)));
        set_param(block,'EngReszTurboRotInert',...
        num2str(round(1000.*getmdldata(ddataobjs,'TurboInertia'),3)));
        set_param(block,'EngReszInjSlp',...
        num2str(round(getmdldata(ddataobjs,'Sinj'),2)));
    end
end

function[hwse,hwseparent,hwsc,hwscparent,hwsd,hwsdparent,hwset,hwsetparent,hwsme,hwsmeparent,hwsse,hwsseparent]=loaddictionaries(block)
    if iscell(block)
        nobjs=numel(block);
        hwse=cell(nobjs,1);
        hwsc=cell(nobjs,1);
        for i=1:nobjs
            ddobj=Simulink.data.dictionary.open(block{i});
            hwse{i}=getSection(ddobj,'Design Data');
            hwsc{i}=ddobj;
        end
        siengblk='SiDynoReferenceApplication/Engine System/Engine Plant/Engine/SI Engine';
        hwseparent=get_param([siengblk,'/Dynamic SI Engine'],'ActiveVariant');
        hwscparent=[];
        hwsd=[];
        hwsdparent=[];
        hwset=[];
        hwsetparent=[];
        hwsme=[];
        hwsmeparent=[];
        hwsse=[];
        hwsseparent=[];
    else

        hwsetparent='SiEngine';
        load_system(hwsetparent);
        hwseparent=get_param('SiEngine/Dynamic SI Engine','ActiveVariant');
        load_system(hwseparent);
        hwse=get_param(hwseparent,'modelworkspace');

        if isempty(get_param(block,'UserData'))
            hwset=get_param(hwsetparent,'modelworkspace');
            hwscparent='SiEngineController';
            load_system(hwscparent);
            hwsc=get_param(hwscparent,'modelworkspace');
            hwsdparent='SiDynoReferenceApplication';
            load_system(hwsdparent);
            hwsd=get_param(hwsdparent,'modelworkspace');
            hwsmeparent='SiMappedEngine';
            load_system(hwsmeparent);
            hwsme=get_param(hwsmeparent,'modelworkspace');
            hwsseparent='SimpleEngine';
            load_system(hwsseparent);
            hwsse=get_param(hwsseparent,'modelworkspace');
            dictionaryhandles={hwse,hwseparent,hwsc,hwscparent,hwsd,hwsdparent,hwset,hwsetparent,hwsme,hwsmeparent,hwsse,hwsseparent};
            set_param(block,'UserData',dictionaryhandles);
        else
            dictionaryhandles=get_param(block,'UserData');

            hwseparent=dictionaryhandles{2};
            hwsc=dictionaryhandles{3};
            hwscparent=dictionaryhandles{4};
            hwsd=dictionaryhandles{5};
            hwsdparent=dictionaryhandles{6};
            hwset=dictionaryhandles{7};
            hwsetparent=dictionaryhandles{8};
            hwsme=dictionaryhandles{9};
            hwsmeparent=dictionaryhandles{10};
            hwsse=dictionaryhandles{11};
            hwsseparent=dictionaryhandles{12};
        end
    end
end


function entryval=getDdData(ddataobj,dataname)
    ddentry=getEntry(ddataobj,dataname);
    entryval=getValue(ddentry);
    if isa(entryval,'Simulink.Parameter')
        entryval=entryval.Value;
    end
end


function prmval=getmdldata(mdlws,prmname)
    prmval=getVariable(mdlws,prmname);
    if isa(prmval,'Simulink.Parameter')
        prmval=prmval.Value;
    end
end


function setDdData(ddataobj,dataname,dataval)
    ddentry=getEntry(ddataobj,dataname);
    entryval=getValue(ddentry);
    if isa(entryval,'Simulink.Parameter')
        entryval.Value=dataval;
    else
        entryval=dataval;
    end
    setValue(ddentry,entryval);
end


function setmdldata(mdlws,prmname,dataval)
    try
        parm=getVariable(mdlws,prmname);
    catch
        parm=dataval;
    end
    if isa(parm,'Simulink.Parameter')
        parm.Value=dataval;
    else
        parm=dataval;
    end
    mdlws.assignin(prmname,parm);
end


function saveDD(block,ddobjs)
    if~isempty(ddobjs)
        for i=1:numel(ddobjs)
            saveChanges(ddobjs{i})
        end
        save_system('SiEngine','SaveDirtyReferencedModels',true);
    else
        [~,hwseparent,~,hwscparent,~,~,~,hwsetparent,~,hwsmeparent,~,hwsseparent]=loaddictionaries(block);
        save_system(hwseparent,which(hwseparent),'SaveDirtyReferencedModels',true,'SaveModelWorkspace',true);
        save_system(hwscparent,which(hwscparent),'SaveDirtyReferencedModels',true,'SaveModelWorkspace',true);
        save_system(hwsetparent,which(hwsetparent),'SaveDirtyReferencedModels',true,'SaveModelWorkspace',true);
        save_system(hwsmeparent,which(hwsmeparent),'SaveDirtyReferencedModels',true,'SaveModelWorkspace',true);
        save_system(hwsseparent,which(hwsseparent),'SaveDirtyReferencedModels',true,'SaveModelWorkspace',true);
    end
end



function rescaleparameters(ParameterList,DDHandle,RescaleMult,vvc)
    for i=1:length(ParameterList(:))
        if vvc
            setDdData(DDHandle,ParameterList{i},...
            getDdData(DDHandle,ParameterList{i})*RescaleMult);
        else
            setmdldata(DDHandle,ParameterList{i},...
            getmdldata(DDHandle,ParameterList{i})*RescaleMult);
        end
    end
end


function resizebasiscallback(block)

    sizetype=get_param(block,'EngReszSpecType');

    switch sizetype
    case 'Displacement'
        autoblksenableparameters(block,[],[],{'EngReszDispDesIn'},{'EngReszMaxPwrDesIn'});
    case 'Power'
        autoblksenableparameters(block,[],[],{'EngReszMaxPwrDesIn'},{'EngReszDispDesIn'});
    end

end


function PowerScaleFactor=PowerScaleFactorByDisp(DispInit,DispTarget,NCylInit,NCylTarget,EngSpdRatioRatio,PowerScaleRatio)

    PowerScaleFactor=EngSpdRatioRatio*PowerScaleRatio*(sqrt(NCylTarget/NCylInit)*(DispTarget/DispInit))^(2/3);

end


function DispScaleFactor=DispScaleFactorByPower(PowerInit,PowerTarget,NCylInit,NCylTarget)

    DispScaleFactor=((PowerTarget/PowerInit)^(3/2))/sqrt((NCylTarget/NCylInit));

end



function resizeLite(block,trqOrSpd,vvc)


    maskObj=Simulink.Mask.get(block);

    if vvc
        engBlk='SiDynoReferenceApplication/Engine System/Engine Plant/Engine/SI Engine/Dynamic SI Engine';
    else
        engBlk='SiEngine/Dynamic SI Engine';
    end
    engVar=get_param(engBlk,'ActiveVariant');
    hwseparent=setEngVar(maskObj,vvc);
    if vvc
        [ddataobjs,~,~,~,~,~,~,~,~,~,~,~]=loaddictionaries({'SiEngineCore.sldd'});
        BrakeTq=getDdData(ddataobjs{1},'PlntEngInTrqMap')...
        -getDdData(ddataobjs{1},'PlntEngTqFric')...
        -getDdData(ddataobjs{1},'PlntEngTqPump');
        tqspeedbp=getDdData(ddataobjs{1},'PlntEngInTrqSpdBpt');
        CurrDisp=round(1000.*getDdData(ddataobjs{1},'PlntEngVd'),2);
        CurrNumCyl=getDdData(ddataobjs{1},'PlntEngNCyl');
    else
        [hwse,~,~,~,~,~,~,~,~,~,~,~]=loaddictionaries(block);
        BrakeTq=getmdldata(hwse,'f_tq_inr')-getmdldata(hwse,'f_tq_fric')...
        -getmdldata(hwse,'f_tq_pump');
        tqspeedbp=getmdldata(hwse,'f_tq_inr_n_bpt');
        CurrDisp=round(1000.*getmdldata(hwse,'Vd'),2);
        CurrNumCyl=getmdldata(hwse,'NCyl');
    end
    maxtqvsspeed=max(BrakeTq);
    [MaxPwr,~]=max(maxtqvsspeed.*tqspeedbp*pi/30/1000.);
    DispTarget=str2double(maskObj.getParameter('EngReszDispDesIn').Value);
    NewNumCyl=round(str2double(maskObj.getParameter('EngReszNumCylDes').Value));
    CurrMaxPwrVal=MaxPwr;
    if strcmp(hwseparent,'SiEngineCoreNA')||...
        strcmp(hwseparent,'SiEngineCoreVNA')
        tqBias=0.856;
        spBias=2;
    else
        tqBias=0.989;
        spBias=0;
    end
    [MaxTq,i]=max(maxtqvsspeed);
    CurrMaxTrqSp=tqspeedbp(i+spBias);
    CurrMaxTrq=MaxTq*tqBias;
    PowerScaleFactor=PowerScaleFactorByDisp(CurrDisp,DispTarget,CurrNumCyl,NewNumCyl,1,1);
    NewMaxPwrVal=PowerScaleFactor*CurrMaxPwrVal;

    EngPwrRatio=NewMaxPwrVal/CurrMaxPwrVal;
    EngCylNumRatio=NewNumCyl/CurrNumCyl;
    EngSpdRatio=sqrt(EngCylNumRatio/EngPwrRatio);
    EngTrqRatio=EngPwrRatio/EngSpdRatio;
    NewMaxTrq=round(EngTrqRatio*CurrMaxTrq,1);
    NewMaxTrqSpd=round(EngSpdRatio*CurrMaxTrqSp,0);

    switch trqOrSpd
    case 'trq'
        set_param(block,'EngReszDesMaxTq',num2str(NewMaxTrq));
    case 'spd'
        set_param(block,'EngReszReqMaxTqSpd',num2str(NewMaxTrqSpd));
    end
    set_param(engBlk,'LabelModeActiveChoice',engVar);
end

function hwseparent=setEngVar(maskObj,vvc)

    if~vvc
        load_system('SiEngine');
    end
    engBlk='SiEngine/Dynamic SI Engine';
    engV=strcmp(maskObj.getParameter('EngReszArchEngine').Value,'V');
    natAspirated=strcmp(maskObj.getParameter('EngReszTurb').Value,'off');
    thr2=engV&&strcmp(maskObj.getParameter('Thr2').Value,'on')&&~natAspirated;
    if thr2
        hwseparent='SiEngineCoreVThr2';
    elseif engV&&natAspirated
        hwseparent='SiEngineCoreVNA';
    elseif engV
        hwseparent='SiEngineCoreV';
    elseif natAspirated
        hwseparent='SiEngineCoreNA';
    else
        hwseparent='SiEngineCore';
    end
    set_param(engBlk,'LabelModeActiveChoice',hwseparent);
end

function[minPwr,maxPwr,minDspl,maxDspl,minNCyls,maxNCyls,nLow,nHigh,mepLow,mepHigh]=setParamLimit(block,hwse,vvc)

    maskObj=get_param(block,'MaskObject');

    mepLow=10;
    mepHigh=30;
    nLow=1000;
    nHigh=6000;
    MinIVCVolLimit=0.1;
    maxPwr=1500;
    minNCyls=1;
    maxNCyls=20;
    maxDspl=100;

    if vvc
        BrakeTq=getDdData(hwse,'PlntEngInTrqMap')...
        -getDdData(hwse,'PlntEngTqFric')...
        -getDdData(hwse,'PlntEngTqPump');
        tqspeedbp=getDdData(hwse,'PlntEngInTrqSpdBpt');
        CurrDisp=round(1000.*getDdData(hwse,'PlntEngVd'),2);
        CurrNumCyl=getDdData(hwse,'PlntEngNCyl');
    else
        BrakeTq=getmdldata(hwse,'f_tq_inr')-getmdldata(hwse,'f_tq_fric')...
        -getmdldata(hwse,'f_tq_pump');
        tqspeedbp=getmdldata(hwse,'f_tq_inr_n_bpt');
        CurrDisp=round(1000.*getmdldata(hwse,'Vd'),2);
        CurrNumCyl=getmdldata(hwse,'NCyl');
    end
    maxtqvsspeed=max(BrakeTq);
    [CurrMaxPwrVal,~]=max(maxtqvsspeed.*tqspeedbp*pi/30/1000.);
    NewNumCyl=round(str2double(maskObj.getParameter('EngReszNumCylDes').Value));

    minVd=MinIVCVolLimit*NewNumCyl;
    minDspl=max(minVd,0.01);

    MinPR=(sqrt(NewNumCyl/CurrNumCyl)*(minVd/CurrDisp))^(2/3);
    minPwr=max(round(MinPR*CurrMaxPwrVal,2),0.1);
end

function ParamList=setParamList(block,hwse,vvc)

    maskObj=get_param(block,'MaskObject');
    sizetype=maskObj.getParameter('EngReszSpecType').Value;

    [minPwr,maxPwr,minDspl,maxDspl,minNCyls,maxNCyls,nLow,nHigh,mepLow,mepHigh]=...
    setParamLimit(block,hwse,vvc);
    if vvc
        cps=getDdData(hwse,'PlntEngCps');
    else
        cps=getmdldata(hwse,'Cps');
    end
    DispTarget=str2double(maskObj.getParameter('EngReszDispDesIn').Value);

    trqLow=mepLow*DispTarget*100/2/pi/cps;
    trqHigh=mepHigh*DispTarget*100/2/pi/cps;

    nCyl=str2double(maskObj.getParameter('EngReszNumCylDes').Value);
    nCylOK=nCyl>=minNCyls&&nCyl<=maxNCyls;
    sizeDisp=strcmp(sizetype,'Displacement');
    ParamList={'EngReszNumCylDes',[1,1],{'gte',minNCyls;'int',0;'lte',maxNCyls}};
    if nCylOK&&sizeDisp
        ParamList=[ParamList;...
        {'EngReszDispDesIn',[1,1],{'gte',minDspl;'lte',maxDspl}}];
    elseif nCylOK
        ParamList=[ParamList;...
        {'EngReszMaxPwrDes',[1,1],{'gte',minPwr;'lte',maxPwr}};...
        {'EngReszMaxPwrDesIn',[1,1],{'gte',minPwr;'lte',maxPwr}}];
    end
    if nCylOK&&sizeDisp&&strcmp(maskObj.getParameter('TrqSpec').Value,'on')
        ParamList=[ParamList;...
        {'EngReszDesMaxTq',[1,1],{'gte',trqLow;'lte',trqHigh}}];
    end
    if nCylOK&&sizeDisp&&strcmp(maskObj.getParameter('TrqSpdSpec').Value,'on')
        ParamList=[ParamList;...
        {'EngReszReqMaxTqSpd',[1,1],{'gte',nLow;'lte',nHigh}}];
    end
end

function updateEngConfig(block,vvc)
    maskObj=get_param(block,'MaskObject');
    if vvc
        [ddataobjs,~,~,~,~,~,~,~,~,~,~,~]=...
        loaddictionaries({'SiDynoReferenceApplication.sldd';...
        'SiEngineCore.sldd'});
        engConf=getDdData(ddataobjs{1},'SiDynoEngConf');
    else
        topws=get_param(bdroot,'ModelWorkspace');
        engConf=getmdldata(topws,'engConf');
    end
    newEngArch=maskObj.getParameter('EngReszArchEngine').Value;
    newEngTurb=maskObj.getParameter('EngReszTurb').Value;
    newEngEgr=maskObj.getParameter('EngReszEgr').Value;
    newEngThr2=maskObj.getParameter('Thr2').Value;
    updateArch=~strcmp(engConf.arch,newEngArch);
    updateTurb=~strcmp(engConf.turb,newEngTurb);
    updateEgr=~strcmp(engConf.egr,newEngEgr);
    updateThr2=~strcmp(engConf.thr2,newEngThr2);
    engConf.arch=newEngArch;
    engConf.turb=newEngTurb;
    engConf.egr=newEngEgr;
    engConf.thr2=newEngThr2;
    if strcmp(newEngEgr,'on')
        egrVar='LpEGR';
    else
        egrVar='NoEGR';
    end
    if updateArch||updateTurb||...
        updateEgr||updateThr2
        hwseparent=setEngVar(maskObj,vvc);
        set_param([hwseparent,'/LP EGR'],'LabelModeActiveChoice',egrVar);
        if vvc
            setDdData(ddataobjs{1},'SiDynoEngConf',engConf)
        else
            setmdldata(topws,'engConf',engConf)

            msgbox(getString(message('autoblks:autoblkDynoMask:msgBxCfMsg')),...
            getString(message('autoblks:autoblkDynoMask:msgBxCfTle')),'replace');
        end
    end

    if~vvc
        load_system('SiEngine');
        hwseparent=get_param('SiEngine/Dynamic SI Engine','ActiveVariant');
        load_system(hwseparent);
        hwse=get_param(hwseparent,'ModelWorkspace');
        ParamList=setParamList(block,hwse,vvc);
        autoblkscheckparams(block,ParamList);
    end
end

function restoreEngConfig(block,hwseparent,vvc)
    maskObj=get_param(block,'MaskObject');
    if vvc
        [ddataobjs,~,~,~,~,~,~,~,~,~,~,~]=...
        loaddictionaries({'SiDynoReferenceApplication.sldd'});
        engConf=getDdData(ddataobjs{1},'SiDynoEngConf');
    else
        topws=get_param(bdroot(block),'ModelWorkspace');
        engConf=getmdldata(topws,'engConf');
    end
    EngArch=maskObj.getParameter('EngReszArchEngine').Value;
    EngTurb=maskObj.getParameter('EngReszTurb').Value;
    EngEgr=maskObj.getParameter('EngReszEgr').Value;
    EngThr2=maskObj.getParameter('Thr2').Value;
    engV=strcmp(hwseparent,'SiEngineCoreV')||strcmp(hwseparent,'SiEngineCoreVNA')...
    ||strcmp(hwseparent,'SiEngineCoreVThr2');
    natAsp=strcmp(hwseparent,'SiEngineCoreNA')||strcmp(hwseparent,'SiEngineCoreVNA');
    thr2=strcmp(hwseparent,'SiEngineCoreVThr2');
    lpEgr=strcmp(get_param([hwseparent,'/LP EGR'],'ActiveVariant'),'LpEGR');
    if engV&&~strcmp(EngArch,'V')
        set_param(block,'EngReszArchEngine','V');
    elseif~engV&&~strcmp(EngArch,'Line')
        set_param(block,'EngReszArchEngine','Line');
    end
    if engV&&~strcmp(engConf.arch,'V')
        engConf.arch='V';
    elseif~engV&&~strcmp(engConf.arch,'Line')
        engConf.arch='Line';
    end
    if natAsp&&~strcmp(EngTurb,'off')
        set_param(block,'EngReszTurb','off');
    elseif~natAsp&&~strcmp(EngTurb,'on')
        set_param(block,'EngReszTurb','on');
    end
    if natAsp&&~strcmp(engConf.turb,'off')
        engConf.turb='off';
    elseif~natAsp&&~strcmp(engConf.turb,'on')
        engConf.turb='on';
    end
    if thr2&&~strcmp(EngThr2,'on')
        set_param(block,'Thr2','on');
    elseif~thr2&&~strcmp(EngThr2,'off')
        set_param(block,'Thr2','off');
    end
    if thr2&&~strcmp(engConf.thr2,'on')
        engConf.thr2='on';
    elseif~thr2&&~strcmp(engConf.thr2,'off')
        engConf.thr2='off';
    end
    if lpEgr&&~strcmp(EngEgr,'on')
        set_param(block,'EngReszEgr','on');
    elseif~lpEgr&&~strcmp(EngEgr,'off')
        set_param(block,'EngReszEgr','off');
    end
    if lpEgr&&~strcmp(engConf.egr,'on')
        engConf.egr='on';
    elseif~lpEgr&&~strcmp(engConf.egr,'off')
        engConf.egr='off';
    end
    if vvc
        setDdData(ddataobjs{1},'SiDynoEngConf',engConf)
    else
        setmdldata(topws,'engConf',engConf)
    end
end

