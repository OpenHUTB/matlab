function reszok=autoblksciengresize(varargin)





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
        end
    end
end

function reszok=resizeengine(block,vvc,nomsk)

    CurrMaxPwrVal=eval(get_param(block,'EngReszMaxPwr'));
    CurrNumCyl=eval(get_param(block,'EngReszNumCyl'));
    CurrDisp=eval(get_param(block,'EngReszDisp'));
    NewNumCyl=round(eval(get_param(block,'EngReszNumCylDes')));

    sizetype=get_param(block,'EngReszSpecType');

    switch sizetype
    case 'Power'
        set_param(block,'EngReszMaxPwrDes',num2str(eval(get_param(block,'EngReszMaxPwrDesIn'))));
        PowerTarget=eval(get_param(block,'EngReszMaxPwrDesIn'));
        DispScaleFactor=DispScaleFactorByPower(CurrMaxPwrVal,PowerTarget,CurrNumCyl,NewNumCyl);
        set_param(block,'EngReszDispDesIn',num2str(DispScaleFactor*CurrDisp));
    case 'Displacement'
        DispTarget=eval(get_param(block,'EngReszDispDesIn'));
        PowerScaleFactor=PowerScaleFactorByDisp(CurrDisp,DispTarget,CurrNumCyl,NewNumCyl);
        set_param(block,'EngReszMaxPwrDes',num2str(PowerScaleFactor*CurrMaxPwrVal));
        set_param(block,'EngReszMaxPwrDesIn',num2str(PowerScaleFactor*CurrMaxPwrVal));
    end

    NewMaxPwrVal=eval(get_param(block,'EngReszMaxPwrDes'));


    if(round(CurrMaxPwrVal,2)~=round(NewMaxPwrVal,2)||CurrNumCyl~=NewNumCyl)&&~isempty(NewMaxPwrVal)&&~isempty(NewNumCyl)


        MinIVCVolLimit=0.1;
        MinVd=MinIVCVolLimit*NewNumCyl;
        MinPR=(sqrt(NewNumCyl/CurrNumCyl)*(MinVd/CurrDisp))^(2/3);
        MinPwr=round(MinPR*CurrMaxPwrVal,2);
        MaxVd=min(1.5*DispScaleFactorByPower(103.7766,2e5,4,NewNumCyl),...
        35000);

        ParamList={'EngReszNumCylDes',[1,1],{'gte',1;'int',0;'lte',20}};
        if strcmp(sizetype,'Power')
            ParamList=[ParamList;...
            {'EngReszMaxPwrDes',[1,1],{'gte',MinPwr;'lte',2e5};...
            }];
        else
            ParamList=[ParamList;...
            {'EngReszDispDesIn',[1,1],{'gte',MinVd;'lte',MaxVd};...
            }];
        end


        MaskObj=get_param(block,'MaskObject');
        Params=MaskObj.Parameters;
        ParamValues=cell(size(Params));
        for i=1:length(Params)
            ParamValues{i}=get_param(block,Params(i).Name);
        end

        close_system(block);
        for i=1:length(Params)
            set_param(block,Params(i).Name,ParamValues{i});
        end
        try
            autoblkscheckparams(block,ParamList);
            ErrFound=false;
        catch ErrMsg
            ErrFound=true;
        end
        if ErrFound&&nomsk
            errordlg(ErrMsg.message,...
            getString(message('autoblks:autoblkDynoMask:msgBxCfTle')),'replace');
            return
        elseif ErrFound
            open_system(block,'Mask');
            error(ErrMsg.message)
        end
        if~nomsk
            open_system(block,'Mask');
            hwb=waitbar(0,getString(message('autoblks:autoblkDynoMask:waitBMsg')));
        end


        if vvc
            [ddataobjs,~,ddobjs,~,~,~,~,~,~,~]=...
            loaddictionaries({'CiEngineCore.sldd';...
            'CiMappedEngine.sldd';...
            'CiEngineController.sldd';...
            'SiDynoReferenceApplication.sldd';...
            'SiEngine.sldd'});
            Vd=getDdData(ddataobjs{1},'PlntEngCIVd');
        else
            [hwse,~,hwsc,~,hwsd,~,hwset,~,hwsme,~]=loaddictionaries(block);
            ddobjs=[];
            Vd=getmdldata(hwse,'Vd');
        end

        if~nomsk
            waitbar(0.1,hwb);
        end


        if vvc
            updatedependentresizeparms(ddataobjs,block,vvc);
        else
            updatedependentresizeparms(hwse,block,vvc);
        end

        if~nomsk
            waitbar(0.2,hwb);
        end


        EngPwrRatio=NewMaxPwrVal/CurrMaxPwrVal;
        EngCylNumRatio=NewNumCyl/CurrNumCyl;
        EngSpdRatio=sqrt((EngCylNumRatio/EngPwrRatio));
        EngTrqRatio=EngPwrRatio/EngSpdRatio;
        EngDispDes=Vd*EngTrqRatio;
        EngDispRatio=EngTrqRatio;
        EngCylVolDes=EngDispDes/NewNumCyl;
        EngCylVol=Vd/CurrNumCyl;
        EngCylVolRatio=EngCylVolDes/EngCylVol;

        if vvc

            setDdData(ddataobjs{1},'PlntEngCINCyl',NewNumCyl);

            setDdData(ddataobjs{1},'PlntEngCIVd',EngDispDes);
            setDdData(ddataobjs{1},'PlntEngCIVexh',getDdData(ddataobjs{1},'PlntEngCIVexh')*EngDispRatio);
            setDdData(ddataobjs{1},'PlntEngCIVint',getDdData(ddataobjs{1},'PlntEngCIVint')*EngDispRatio);
            setDdData(ddataobjs{1},'PlntEngCIAirIntakeVol',getDdData(ddataobjs{1},'PlntEngCIAirIntakeVol')*EngDispRatio);
            setDdData(ddataobjs{1},'PlntEngCIExhSysVol',getDdData(ddataobjs{1},'PlntEngCIExhSysVol')*EngDispRatio);

            setDdData(ddataobjs{1},'PlntEngCIEgrArea',getDdData(ddataobjs{1},'PlntEngCIEgrArea')*EngPwrRatio);

            setDdData(ddataobjs{1},'PlntEngCIAFArea',getDdData(ddataobjs{1},'PlntEngCIAFArea')*EngPwrRatio);
            setDdData(ddataobjs{1},'PlntEngCIExhSysArea',getDdData(ddataobjs{1},'PlntEngCIExhSysArea')*EngPwrRatio);

            setDdData(ddataobjs{1},'PlntEngCISinj',EngCylVolRatio*getDdData(ddataobjs{1},'PlntEngCISinj'));

            setDdData(ddataobjs{1},'PlntEngCICompMassFlwRate',getDdData(ddataobjs{1},'PlntEngCICompMassFlwRate')*EngPwrRatio);
            setDdData(ddataobjs{1},'PlntEngCITurbMassFlwRate',getDdData(ddataobjs{1},'PlntEngCITurbMassFlwRate')*EngPwrRatio);

            setDdData(ddataobjs{3},'CtrlEcuCIEgrStdFlw',getDdData(ddataobjs{3},'CtrlEcuCIEgrStdFlw')*EngPwrRatio);

            setDdData(ddataobjs{3},'CtrlEcuCITrbPrStdFlwBpt',getDdData(ddataobjs{3},'CtrlEcuCITrbPrStdFlwBpt')*EngPwrRatio);

            setDdData(ddataobjs{1},'PlntEngCITurbSpdBreakPoints',getDdData(ddataobjs{1},'PlntEngCITurbSpdBreakPoints')/sqrt(EngPwrRatio));
            setDdData(ddataobjs{1},'PlntEngCICompSpdBreakPoints',getDdData(ddataobjs{1},'PlntEngCICompSpdBreakPoints')/sqrt(EngPwrRatio));

            setDdData(ddataobjs{1},'PlntEngCITurboInertia',getDdData(ddataobjs{1},'PlntEngCITurboInertia')*EngPwrRatio);
        else

            setmdldata(hwse,'NCyl',NewNumCyl);
            setmdldata(hwsme,'NCyl',NewNumCyl);
            setmdldata(hwsc,'NCyl',NewNumCyl);

            setmdldata(hwse,'Vd',EngDispDes);
            setmdldata(hwsme,'Vd',EngDispDes);
            setmdldata(hwse,'Vexh',getmdldata(hwse,'Vexh')*EngDispRatio);
            setmdldata(hwse,'Vint',getmdldata(hwse,'Vint')*EngDispRatio);
            setmdldata(hwse,'AirIntakeVol',getmdldata(hwse,'AirIntakeVol')*EngDispRatio);
            setmdldata(hwse,'ExhSysVol',getmdldata(hwse,'ExhSysVol')*EngDispRatio);

            setmdldata(hwsc,'Vd',EngDispDes);

            setmdldata(hwse,'EgrArea',getmdldata(hwse,'EgrArea')*EngPwrRatio);

            setmdldata(hwse,'AirFilterArea',getmdldata(hwse,'AirFilterArea')*EngPwrRatio);
            setmdldata(hwse,'ExhSysArea',getmdldata(hwse,'ExhSysArea')*EngPwrRatio);

            setmdldata(hwse,'Sinj',EngCylVolRatio*getmdldata(hwse,'Sinj'));

            setmdldata(hwsme,'Sinj',getmdldata(hwse,'Sinj'));

            setmdldata(hwsc,'Sinj',getmdldata(hwse,'Sinj'));

            setmdldata(hwse,'CompMassFlwRate',getmdldata(hwse,'CompMassFlwRate')*EngPwrRatio);
            setmdldata(hwse,'TurbMassFlwRate',getmdldata(hwse,'TurbMassFlwRate')*EngPwrRatio);

            setmdldata(hwsc,'f_egr_stdflow',getmdldata(hwsc,'f_egr_stdflow')*EngPwrRatio);

            setmdldata(hwsc,'f_turbo_pr_stdflow_bpt',getmdldata(hwsc,'f_turbo_pr_stdflow_bpt')*EngPwrRatio);

            setmdldata(hwse,'TurbSpdBreakPoints',getmdldata(hwse,'TurbSpdBreakPoints')/sqrt(EngPwrRatio));
            setmdldata(hwse,'CompSpdBreakPoints',getmdldata(hwse,'CompSpdBreakPoints')/sqrt(EngPwrRatio));

            setmdldata(hwse,'TurboInertia',getmdldata(hwse,'TurboInertia')*EngPwrRatio);
        end

        if~nomsk
            waitbar(0.3,hwb);
        end



        if vvc
            PlantSpeedUpdateList={...
            'PlntEngCIExhFracNBpt',...
            'PlntEngCITexhNBpt',...
            'PlntEngCINvNBpt',...
            'PlntEngCIGIMepSpdBpt',...
            'PlntEngTqNfNBpt'};
            rescaleparameters(PlantSpeedUpdateList,ddataobjs{1},EngSpdRatio,vvc);
        else
            PlantSpeedUpdateList={...
            'f_exhfrac_n_bpt',...
            'f_nv_n_bpt',...
            'f_t_exh_n_bpt',...
            'f_tqs_n_bpt',...
            'f_tq_nf_n_bpt'};
            rescaleparameters(PlantSpeedUpdateList,hwse,EngSpdRatio,vvc);
        end

        if~nomsk
            waitbar(0.5,hwb);
        end



        if vvc
            ControllerSpeedUpdateList={...
            'CtrlEcuCIMainSoiNBpt',...
            'CtrlEcuCITotNBpt',...
            'CtrlEcuCIEgrNBpt',...
            'CtrlEcuCIRpNBpt',...
            'CtrlEcuCIEngRevLim',...
            'CtrlEcuCINidle'};
            rescaleparameters(ControllerSpeedUpdateList,ddataobjs{3},EngSpdRatio,vvc);
        else
            ControllerSpeedUpdateList={...
            'f_main_soi_n_bpt',...
            'f_t_exh_n_bpt',...
            'f_tqs_n_bpt',...
            'f_f_tot_n_bpt',...
            'f_egr_n_bpt',...
            'f_rp_n_bpt',...
            'f_tq_nf_n_bpt',...
            'f_nv_n_bpt',...
            'N_idle',...
            'EngRevLim'};
            rescaleparameters(ControllerSpeedUpdateList,hwsc,EngSpdRatio,vvc);
        end

        if~nomsk
            waitbar(0.7,hwb);
        end

        if vvc

            setDdData(ddataobjs{1},'PlntEngCIGIMepFuelBpt',getDdData(ddataobjs{1},'PlntEngCIGIMepFuelBpt')*EngCylVolRatio);
            setDdData(ddataobjs{1},'PlntEngTqNf',getDdData(ddataobjs{1},'PlntEngTqNf')*EngTrqRatio);
            setDdData(ddataobjs{1},'PlntEngTqNfFBpt',getDdData(ddataobjs{1},'PlntEngTqNfFBpt')*EngCylVolRatio);
            setDdData(ddataobjs{1},'PlntEngCITexhFBpt',getDdData(ddataobjs{1},'PlntEngCITexhFBpt')*EngCylVolRatio);
            setDdData(ddataobjs{2},'PlntEngCIBrkTrqBpt',getDdData(ddataobjs{2},'PlntEngCIBrkTrqBpt')*EngTrqRatio);

            setDdData(ddataobjs{1},'PlntEngCIGIMepFuelBpt',getDdData(ddataobjs{1},'PlntEngCIGIMepFuelBpt')*EngCylVolRatio);
            setDdData(ddataobjs{1},'PlntEngTqNf',getDdData(ddataobjs{1},'PlntEngTqNf')*EngTrqRatio);
            setDdData(ddataobjs{1},'PlntEngTqNfFBpt',getDdData(ddataobjs{1},'PlntEngTqNfFBpt')*EngCylVolRatio);
            setDdData(ddataobjs{1},'PlntEngCITexhFBpt',getDdData(ddataobjs{1},'PlntEngCITexhFBpt')*EngCylVolRatio);
            setDdData(ddataobjs{3},'CtrlEcuCIEgrTqBpt',getDdData(ddataobjs{3},'CtrlEcuCIEgrTqBpt')*EngTrqRatio);
            setDdData(ddataobjs{3},'CtrlEcuCIRpTqBpt',getDdData(ddataobjs{3},'CtrlEcuCIRpTqBpt')*EngTrqRatio);
            setDdData(ddataobjs{3},'CtrlEcuCICmdTot',getDdData(ddataobjs{3},'CtrlEcuCICmdTot')*EngCylVolRatio);
            setDdData(ddataobjs{3},'CtrlEcuCIMainSoiFBpt',getDdData(ddataobjs{3},'CtrlEcuCIMainSoiFBpt')*EngCylVolRatio);
            setDdData(ddataobjs{3},'CtrlEcuCITotTqBpt',getDdData(ddataobjs{3},'CtrlEcuCITotTqBpt')*EngTrqRatio);

            setDdData(ddataobjs{1},'PlntEngCIExhFracTqBpt',getDdData(ddataobjs{1},'PlntEngCIExhFracTqBpt')*EngTrqRatio);
        else

            setmdldata(hwse,'f_tqs_f_bpt',getmdldata(hwse,'f_tqs_f_bpt')*EngCylVolRatio);
            setmdldata(hwse,'f_tq_nf',getmdldata(hwse,'f_tq_nf')*EngTrqRatio);
            setmdldata(hwse,'f_tq_nf_f_bpt',getmdldata(hwse,'f_tq_nf_f_bpt')*EngCylVolRatio);
            setmdldata(hwse,'f_t_exh_f_bpt',getmdldata(hwse,'f_t_exh_f_bpt')*EngCylVolRatio);
            setmdldata(hwsme,'f_tbrake_t_bpt',getmdldata(hwsme,'f_tbrake_t_bpt')*EngTrqRatio);

            setmdldata(hwsc,'f_tqs_f_bpt',getmdldata(hwsc,'f_tqs_f_bpt')*EngCylVolRatio);
            setmdldata(hwsc,'f_tq_nf',getmdldata(hwsc,'f_tq_nf')*EngTrqRatio);
            setmdldata(hwsc,'f_tq_nf_f_bpt',getmdldata(hwsc,'f_tq_nf_f_bpt')*EngCylVolRatio);
            setmdldata(hwsc,'f_t_exh_f_bpt',getmdldata(hwsc,'f_t_exh_f_bpt')*EngCylVolRatio);
            setmdldata(hwsc,'f_egr_tq_bpt',getmdldata(hwsc,'f_egr_tq_bpt')*EngTrqRatio);
            setmdldata(hwsc,'f_rp_tq_bpt',getmdldata(hwsc,'f_rp_tq_bpt')*EngTrqRatio);
            setmdldata(hwsc,'f_fcmd_tot',getmdldata(hwsc,'f_fcmd_tot')*EngCylVolRatio);
            setmdldata(hwsc,'f_main_soi_f_bpt',getmdldata(hwsc,'f_main_soi_f_bpt')*EngCylVolRatio);
            setmdldata(hwsc,'f_f_tot_tq_bpt',getmdldata(hwsc,'f_f_tot_tq_bpt')*EngTrqRatio);

            setmdldata(hwse,'f_exhfrac_trq_bpt',getmdldata(hwse,'f_exhfrac_trq_bpt')*EngTrqRatio);
        end

        if~nomsk
            waitbar(0.7,hwb);
        end

        if vvc

            SteadyEngSpdCmdPts=getDdData(ddataobjs{4},'CiDynoSSSpdCmd')*EngSpdRatio;
            setDdData(ddataobjs{4},'CiDynoSSSpdCmd',SteadyEngSpdCmdPts);
            SteadyTrqCmdPts=getDdData(ddataobjs{4},'CiDynoSSTrqCmd')*EngTrqRatio;
            setDdData(ddataobjs{4},'CiDynoSSTrqCmd',SteadyTrqCmdPts);

            setDdData(ddataobjs{2},'PlntEngCIBrkTrqFuelBpt',getDdData(ddataobjs{2},'PlntEngCIBrkTrqFuelBpt')*EngCylVolRatio);
            setDdData(ddataobjs{2},'PlntEngCIBrkTrqSpdBpt',getDdData(ddataobjs{2},'PlntEngCIBrkTrqSpdBpt')*EngSpdRatio);

            setDdData(ddataobjs{5},'PlntEngAccSpdBpt',...
            getDdData(ddataobjs{5},'PlntEngAccSpdBpt')*EngSpdRatio);
            setDdData(ddataobjs{5},'PlntEngAccPwrTbl',...
            getDdData(ddataobjs{5},'PlntEngAccPwrTbl')*EngSpdRatio);

        else

            SteadyEngSpdCmdPts=getmdldata(hwsd,'SteadyEngSpdCmdPts')*EngSpdRatio;
            setmdldata(hwsd,'SteadyEngSpdCmdPts',SteadyEngSpdCmdPts);
            SteadyTrqCmdPts=getmdldata(hwsd,'SteadyTrqCmdPts')*EngTrqRatio;
            setmdldata(hwsd,'SteadyTrqCmdPts',SteadyTrqCmdPts);

            setmdldata(hwsme,'f_tbrake_f_bpt',getmdldata(hwsme,'f_tbrake_f_bpt')*EngCylVolRatio);
            setmdldata(hwsme,'f_tbrake_n_bpt',getmdldata(hwsme,'f_tbrake_n_bpt')*EngSpdRatio);

            setmdldata(hwset,'AccSpdBpts',getmdldata(hwset,'AccSpdBpts')*EngSpdRatio);
            setmdldata(hwset,'AccPwrTbl',getmdldata(hwset,'AccPwrTbl')*EngPwrRatio);
            setmdldata(hwsme,'AccSpdBpts',getmdldata(hwsme,'AccSpdBpts')*EngSpdRatio);
            setmdldata(hwsme,'AccPwrTbl',getmdldata(hwsme,'AccPwrTbl')*EngPwrRatio);
        end

        if~nomsk
            waitbar(0.9,hwb);
        end


        saveDD(block,ddobjs);

        if~nomsk
            close(hwb);
        end


        close_system(block);

        if vvc
            updatedependentresizeparms(ddataobjs,block,vvc);
        else
            updatedependentresizeparms(hwse,block,vvc);
        end


        if nomsk
            RecalibrateCIController('SiDynoReferenceApplication/Subsystem3','OpenFcnNoMsk');
        elseif vvc
            RecalibrateCIController('SiDynoReferenceApplication/Subsystem3','OpenFcn');
            open_system(block,'Mask');
        else
            RecalibrateCIController('CiDynoReferenceApplication/Subsystem3','OpenFcn');
            open_system(block,'Mask');
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


        [ddataobjs,~,~,~,~,~,~,~,~,~]=...
        loaddictionaries({'CiEngineCore.sldd'});
    else

        set_param(block,'UserData',[]);


        [ddataobjs,~,~,~,~,~,~,~,~,~]=loaddictionaries(block);
    end

    updatedependentresizeparms(ddataobjs,block,vvc);
end

function updatedependentresizeparms(ddataobjs,block,vvc)

    if vvc
        Cps=getDdData(ddataobjs{1},'PlntEngCICps');
        Vd=getDdData(ddataobjs{1},'PlntEngCIVd');
        BrakeTq=(getDdData(ddataobjs{1},'PlntEngCIGIMepMap')...
        -getDdData(ddataobjs{1},'PlntEngTqsFMep')...
        +getDdData(ddataobjs{1},'PlntEngTqsPMEP'))*Vd/(Cps*2*pi);
        tqspeedbp=getDdData(ddataobjs{1},'PlntEngCIGIMepSpdBpt');
        NCyl=getDdData(ddataobjs{1},'PlntEngCINCyl');
        tqfuelbp=getDdData(ddataobjs{1},'PlntEngCIGIMepFuelBpt');
    else
        Cps=getmdldata(ddataobjs,'Cps');
        Vd=getmdldata(ddataobjs,'Vd');
        BrakeTq=(getmdldata(ddataobjs,'f_tqs_imepg')...
        -getmdldata(ddataobjs,'f_tqs_fmep')...
        +getmdldata(ddataobjs,'f_tqs_pmep'))*Vd/(Cps*2*pi);
        tqspeedbp=getmdldata(ddataobjs,'f_tqs_n_bpt');
        NCyl=getmdldata(ddataobjs,'NCyl');
        tqfuelbp=getmdldata(ddataobjs,'f_tqs_f_bpt');
    end
    maxtqvsspeed=max(BrakeTq);
    [MaxPwr,i]=max(maxtqvsspeed.*tqspeedbp*pi/30/1000.);
    set_param(block,'EngReszMaxPwr',num2str(MaxPwr));
    set_param(block,'EngReszDisp',num2str(round(1000.*Vd,2)));
    set_param(block,'EngReszNumCyl',num2str(NCyl));
    set_param(block,'EngReszSpdMaxPwr',num2str(round(tqspeedbp(i),0)));
    set_param(block,'EngReszTqMaxPwr',num2str(round(maxtqvsspeed(i),1)));


    Fuelbp=repmat(tqfuelbp(:),1,length(tqspeedbp));
    Speedbp=repmat(tqspeedbp,length(tqfuelbp),1);
    FuelFlow=Fuelbp.*Speedbp*NCyl/(1000*60*Cps);


    EngPwr=BrakeTq.*Speedbp*pi/30./1000.;
    BSFC=3600*FuelFlow./EngPwr;
    BSFC(isnan(BSFC))=Inf;
    BSFC(BSFC<=0)=Inf;
    [~,i]=min(BSFC(:));

    set_param(block,'EngReszBestFuelPwr',num2str(round(EngPwr(i),1)));
    set_param(block,'EngReszBestFuelSpd',num2str(round(Speedbp(i),0)));
    set_param(block,'EngReszBestFuelTq',num2str(round(BrakeTq(i),1)));
    set_param(block,'EngReszBestFuelBSFC',num2str(round(BSFC(i),1)));
    set_param(block,'EngReszIdleSpd',num2str(round(tqspeedbp(2),0)));

    set_param(block,'EngReszDisp',num2str(round(1000.*Vd,2)));

    [MaxTq,i]=max(maxtqvsspeed);
    set_param(block,'EngReszMaxTqSpd',num2str(round(tqspeedbp(i),0)));
    set_param(block,'EngReszMaxTq',num2str(round(MaxTq,1)));

    if vvc
        set_param(block,'EngReszIntkManVol',num2str(round(1000.*getDdData(ddataobjs{1},'PlntEngCIVint'),2)));
        set_param(block,'EngReszExhManVol',num2str(round(1000.*getDdData(ddataobjs{1},'PlntEngCIVexh'),2)));
        set_param(block,'EngReszMaxTurboSpd',num2str(round(30.*max(getDdData(ddataobjs{1},'PlntEngCICompSpdBreakPoints'))/pi,2)));
        set_param(block,'EngReszTurboRotInert',num2str(round(1000.*getDdData(ddataobjs{1},'PlntEngCITurboInertia'),3)));
        set_param(block,'EngReszInjSlp',num2str(round(getDdData(ddataobjs{1},'PlntEngCISinj'),2)));
    else
        set_param(block,'EngReszIntkManVol',num2str(round(1000.*getmdldata(ddataobjs,'Vint'),2)));
        set_param(block,'EngReszExhManVol',num2str(round(1000.*getmdldata(ddataobjs,'Vexh'),2)));
        set_param(block,'EngReszMaxTurboSpd',num2str(round(30.*max(getmdldata(ddataobjs,'CompSpdBreakPoints'))/pi,2)));
        set_param(block,'EngReszTurboRotInert',num2str(round(1000.*getmdldata(ddataobjs,'TurboInertia'),3)));
        set_param(block,'EngReszInjSlp',num2str(round(getmdldata(ddataobjs,'Sinj'),2)));
    end

end


function[hwse,hwseparent,hwsc,hwscparent,hwsd,hwsdparent,hwset,hwsetparent,hwsme,hwsmeparent]=loaddictionaries(block)
    if iscell(block)
        nobjs=numel(block);
        hwse=cell(nobjs,1);
        hwsc=cell(nobjs,1);
        for i=1:nobjs
            ddobj=Simulink.data.dictionary.open(block{i});
            hwse{i}=getSection(ddobj,'Design Data');
            hwsc{i}=ddobj;
        end
        hwseparent=[];
        hwscparent=[];
        hwsd=[];
        hwsdparent=[];
        hwset=[];
        hwsetparent=[];
        hwsme=[];
        hwsmeparent=[];
    elseif isempty(get_param(block,'UserData'))
        hwseparent='CiEngineCore';
        load_system(hwseparent);
        hwse=get_param(hwseparent,'modelworkspace');
        hwscparent='CiEngineController';
        load_system(hwscparent);
        hwsc=get_param(hwscparent,'modelworkspace');
        hwsdparent='CiDynoReferenceApplication';
        load_system(hwsdparent);
        hwsd=get_param(hwsdparent,'modelworkspace');
        hwsetparent=('CiEngine');
        load_system(hwsetparent);
        hwset=get_param(hwsetparent,'modelworkspace');
        hwsmeparent='CiMappedEngine';
        load_system(hwsmeparent);
        hwsme=get_param(hwsmeparent,'modelworkspace');
        dictionaryhandles={hwse,hwseparent,hwsc,hwscparent,hwsd,hwsdparent,hwset,hwsetparent,hwsme,hwsmeparent};
        set_param(block,'UserData',dictionaryhandles);
    else
        dictionaryhandles=get_param(block,'UserData');
        hwse=dictionaryhandles{1};
        hwseparent=dictionaryhandles{2};
        hwsc=dictionaryhandles{3};
        hwscparent=dictionaryhandles{4};
        hwsd=dictionaryhandles{5};
        hwsdparent=dictionaryhandles{6};
        hwset=dictionaryhandles{7};
        hwsetparent=dictionaryhandles{8};
        hwsme=dictionaryhandles{9};
        hwsmeparent=dictionaryhandles{10};
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
    else
        [~,hwseparent,~,hwscparent,~,~,~,hwsetparent,~,hwsmeparent]=loaddictionaries(block);
        save_system(hwseparent,which(hwseparent),'SaveModelWorkspace',true);
        set_param(hwscparent,'SimulationCommand','update');
        save_system(hwscparent,which(hwscparent),'SaveModelWorkspace',true);
        save_system(hwsetparent,which(hwsetparent),'SaveModelWorkspace',true);
        save_system(hwsmeparent,which(hwsmeparent),'SaveModelWorkspace',true);
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


function PowerScaleFactor=PowerScaleFactorByDisp(DispInit,DispTarget,NCylInit,NCylTarget)

    PowerScaleFactor=(sqrt(NCylTarget/NCylInit)*(DispTarget/DispInit))^(2/3);

end


function DispScaleFactor=DispScaleFactorByPower(PowerInit,PowerTarget,NCylInit,NCylTarget)

    DispScaleFactor=((PowerTarget/PowerInit)^(3/2))/sqrt((NCylTarget/NCylInit));

end
