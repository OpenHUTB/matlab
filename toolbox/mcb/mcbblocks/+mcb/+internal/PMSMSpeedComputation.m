function[milestone_speeds]=PMSMSpeedComputation(pmsm,inverter,varargin)
    [licenseStatus,licenseerror]=builtin('license','checkout','Motor_Control_Blockset');
    if licenseStatus==0
        error(licenseerror);
    end

    p=inputParser;
    addRequired(p,'pmsm',@(x)isstruct(x)&&min(isfield(x,{'p','Rs','Ld','Lq','FluxPM','B','I_rated'})));
    addRequired(p,'inverter',@(x)isstruct(x)&&min(isfield(x,{'V_dc'})));
    addParameter(p,'verbose',0,@(x)any(ismember(x,[0,1,2])));
    addParameter(p,'voltageEquation','actual',@(x)any(ismember(lower(x)...
    ,{'actual','approximate'})));
    addParameter(p,'constraintCurves',0,@(x)any(ismember(x,[1,0])));
    addParameter(p,'outputAll',0,@(x)any(ismember(x,[1,0])));
    addParameter(p,'FWCMethod','vclmt',@(x)any(ismember(lower(x),...
    {'vclmt','none','cccp','cvcp'})));

    parse(p,pmsm,inverter,varargin{:});

    pmsm=p.Results.pmsm;
    inverter=p.Results.inverter;
    if~isfield(inverter,'R_board')
        inverter.R_board=0;
    end
    Pp=pmsm.p;
    Irated=pmsm.I_rated;
    fluxPM=pmsm.FluxPM;
    R=pmsm.Rs;

    radps2rpm=30/pi;
    elec2mech=1/Pp;

    verbose=p.Results.verbose;
    voltageEquation=p.Results.voltageEquation;
    includeR=strcmpi(voltageEquation,'actual');
    constraintCurves=p.Results.constraintCurves;

    stk=dbstack;
    calledFromAnother=0;
    if length(stk)>1
        if strcmp(stk(2).name,'mcbPMSMCharacteristics')
            calledFromAnother=1;
        end
    end

    if pmsm.Lq<pmsm.Ld
        Lq=pmsm.Ld;
        Ld=pmsm.Lq;

        if calledFromAnother==0
            disp(message('mcb:blocks:APILqLessThanLdSwapping').getString());
        end
    else
        Ld=pmsm.Ld;
        Lq=pmsm.Lq;
    end
    Icritical=-fluxPM/Ld;

    outputAll=p.Results.outputAll;

    FWCMethod=lower(p.Results.FWCMethod);

    irdropVcc=1-includeR;

    I_short=inverter.V_dc/sqrt(3)/R;

    if Irated>(I_short)
        error(message('mcb:blocks:APIHighIRated',num2str(I_short)));
    end

    vmax=inverter.V_dc/sqrt(3)-(irdropVcc)*(pmsm.Rs+inverter.R_board)*Irated;

    CurrentSpeedArray=[];

    if outputAll==1
        verbose=0;
        constraintCurves=0;
    end

    motorType='ipmsm';

    if isfield(pmsm,'motorType')
        motorType=pmsm.motorType;
    end

    saliency=max(pmsm.Lq,pmsm.Ld)/min(pmsm.Lq,pmsm.Ld);
    if saliency<1.01
        motorType='spmsm';
    end

    if verbose
        disp(message('mcb:blocks:APImotorType',string(motorType)).getString());
    end

    intermediate_speed=-1;

    scale_high_speed=100;
    high_speed_min=1e5*pmsm.p*pi/30;

    if strcmpi(motorType,'ipmsm')
        if strcmpi(FWCMethod,'vclmt')==0
            FWCMethod='vclmt';
            disp(message('mcb:blocks:APIForceSetVCLMT').getString());
        end
        startval.id=0;startval.iq=0;startval.w=0;
        w_corner=mcb.internal.PMSMSpeedCurrentsFcn(pmsm,inverter,startval,5,...
        'voltageEquation',voltageEquation,'outputAll',outputAll);
        w_corner_rpm=w_corner(end)*elec2mech*radps2rpm;
        if outputAll==1
            CurrentSpeedArray=[CurrentSpeedArray,w_corner];
        end
        if verbose
            disp(message('mcb:blocks:APIshowwcorner',...
            num2str(floor(w_corner_rpm))).getString());
        end
        if constraintCurves==1
            mcbPMSMCharacteristics(pmsm,inverter,'speed',w_corner_rpm,...
            'opacity',1,'voltageEquation',voltageEquation,'FWCMethod',FWCMethod);
        end

        id_mtpv_Irated=Icritical;
        if abs(Icritical)>Irated

            iq_mtpv_Irated=0.1;
        else
            iq_mtpv_Irated=sqrt(Irated^2-id_mtpv_Irated^2);
        end

        w_mtpv_onset1=vmax/sqrt(Lq^2*iq_mtpv_Irated^2...
        +(Ld*id_mtpv_Irated+fluxPM)^2);
        startval.id=id_mtpv_Irated;startval.iq=iq_mtpv_Irated;
        startval.w=w_mtpv_onset1;
        [w_mtpv_onset,status_ok]=mcb.internal.PMSMSpeedCurrentsFcn(pmsm,inverter,...
        startval,3,'voltageEquation',voltageEquation,...
        'outputAll',outputAll);
        if status_ok==0&&verbose==2
            disp(message('mcb:blocks:APINRnoMTPVONSET').getString());
        end
        if status_ok==0
            startval.id=id_mtpv_Irated;startval.iq=iq_mtpv_Irated;
            startval.w=10*w_mtpv_onset1;
            [w_mtpv_onset,status_ok]=mcb.internal.PMSMSpeedCurrentsFcn(pmsm,inverter,...
            startval,3,'voltageEquation',voltageEquation,...
            'outputAll',outputAll);
        end
        speeds=w_mtpv_onset(end,:);
        w_mtpv_onset=w_mtpv_onset(:,imag(speeds)==0);
        speeds=w_mtpv_onset(end,:);w_mtpv_onset=w_mtpv_onset(:,speeds>=0);
        speeds=w_mtpv_onset(end,:);w_mtpv_onset=w_mtpv_onset(:,speeds<1e7);

        if isempty(w_mtpv_onset)==1||status_ok==0
            startval.id=0;startval.iq=0;startval.w=0;
            w_max=mcb.internal.PMSMSpeedCurrentsFcn(pmsm,inverter,...
            startval,7,'voltageEquation',voltageEquation,...
            'outputAll',outputAll);
            w_max_rpm=w_max(end)*elec2mech*radps2rpm;
            if outputAll==1
                CurrentSpeedArray=[CurrentSpeedArray,w_max];
            end
            if verbose
                disp(message('mcb:blocks:APIshowWmaxVCLMT',...
                num2str(floor(w_max_rpm))).getString());
            end
            if constraintCurves==1
                mcbPMSMCharacteristics(pmsm,inverter,'speed',w_max_rpm,...
                'opacity',w_corner_rpm/w_max_rpm,...
                'voltageEquation',voltageEquation,'FWCMethod',FWCMethod);
            end
            max_speed=w_max_rpm;
        else
            w_mtpv_onset_rpm=w_mtpv_onset(end)*elec2mech*radps2rpm;
            startval.id=Icritical;startval.iq=0.1;
            startval.w=w_mtpv_onset(end);
            [w_max,status_ok]=mcb.internal.PMSMSpeedCurrentsFcn(pmsm,inverter,...
            startval,4,'voltageEquation',voltageEquation,...
            'outputAll',outputAll);
            if status_ok==0&&verbose==2
                if outputAll==1
                    val1=w_max(1);
                    val2=w_max(2);
                else
                    val1=0;
                    val2=0;
                end
                disp(message('mcb:blocks:APINRDidnotConverge',...
                num2str(val1),num2str(val2),num2str(w_max(end))).getString());
            end
            w_max_rpm=w_max(end)*elec2mech*radps2rpm;

            if status_ok==0
                startval.id=Icritical;startval.iq=0.1;
                startval.w=max(scale_high_speed*w_mtpv_onset(end),high_speed_min);
                [w_max,status_ok]=mcb.internal.PMSMSpeedCurrentsFcn(pmsm,inverter,...
                startval,4,'voltageEquation',voltageEquation,...
                'outputAll',outputAll);
                if status_ok==0&&verbose==2
                    if outputAll==1
                        val1=w_max(1);
                        val2=w_max(2);
                    else
                        val1=0;
                        val2=0;
                    end
                    disp(message('mcb:blocks:APINRDidnotConverge',...
                    num2str(val1),num2str(val2),num2str(w_max(end))).getString());
                end
                w_max_rpm=w_max(end)*elec2mech*radps2rpm;
            end
            if w_mtpv_onset_rpm<w_max_rpm

                if outputAll==1
                    CurrentSpeedArray=[CurrentSpeedArray,w_mtpv_onset];
                end
                intermediate_speed=w_mtpv_onset_rpm;
                if verbose
                    disp(message('mcb:blocks:APIshowWmtpvOnset',...
                    num2str(floor(w_mtpv_onset_rpm))).getString());
                end
                if constraintCurves==1
                    mcbPMSMCharacteristics(pmsm,inverter,...
                    'speed',w_mtpv_onset_rpm,...
                    'opacity',w_corner_rpm/w_mtpv_onset_rpm,...
                    'voltageEquation',voltageEquation,'FWCMethod',FWCMethod);
                end
            end
            if outputAll==1
                CurrentSpeedArray=[CurrentSpeedArray,w_max];
            end
            if verbose
                disp(message('mcb:blocks:APIshowWmaxMTPV',...
                num2str(floor(w_max_rpm))).getString());
            end
            if constraintCurves==1
                mcbPMSMCharacteristics(pmsm,inverter,'speed',w_max_rpm,...
                'opacity',w_corner_rpm/w_max_rpm,...
                'voltageEquation',voltageEquation,'FWCMethod',FWCMethod);
            end
            max_speed=w_max_rpm;
        end

    else
        startval.id=0;startval.iq=0;startval.w=0;
        w_corner=mcb.internal.PMSMSpeedCurrentsFcn(pmsm,inverter,startval,6,...
        'voltageEquation',voltageEquation,'outputAll',outputAll);
        w_corner_rpm=w_corner(end)*elec2mech*radps2rpm;
        if outputAll==1
            CurrentSpeedArray=[CurrentSpeedArray,w_corner];
        end
        if verbose
            disp(message('mcb:blocks:APIshowwcorner',...
            num2str(floor(w_corner_rpm))).getString());
        end
        if constraintCurves==1
            mcbPMSMCharacteristics(pmsm,inverter,'speed',w_corner_rpm,...
            'opacity',1,'voltageEquation',voltageEquation,'FWCMethod',FWCMethod);
        end

        if strcmpi(FWCMethod,'none')==1
            w_noFW_max=mcb.internal.PMSMSpeedCurrentsFcn(pmsm,inverter,...
            startval,22,'voltageEquation',voltageEquation,...
            'outputAll',outputAll);
            w_noFW_max_rpm=w_noFW_max(end)*elec2mech*radps2rpm;
            if outputAll==1
                CurrentSpeedArray=[CurrentSpeedArray,w_noFW_max];
            end
            if verbose
                disp(message('mcb:blocks:APIshowWmaxNOFW',...
                num2str(floor(w_noFW_max_rpm))).getString());
            end
            if constraintCurves==1
                mcbPMSMCharacteristics(pmsm,inverter,...
                'speed',w_noFW_max_rpm,...
                'opacity',min(0.999,w_corner_rpm/w_noFW_max_rpm),...
                'voltageEquation',voltageEquation,'FWCMethod',FWCMethod);
            end
            max_speed=w_noFW_max_rpm;
        elseif strcmpi(FWCMethod,'cvcp')==1
            if(Irated>pmsm.FluxPM/pmsm.Ld)
                startval.id=0;startval.iq=0;startval.w=w_corner(end);
                w_cvcp_maxspeed=mcb.internal.PMSMSpeedCurrentsFcn(pmsm,...
                inverter,startval,33,'voltageEquation',voltageEquation,...
                'outputAll',outputAll);
                w_cvcp_maxspeed_rpm=w_cvcp_maxspeed(end)*elec2mech*radps2rpm;
                if outputAll==1
                    CurrentSpeedArray=[CurrentSpeedArray,w_cvcp_maxspeed];
                end
                if verbose
                    disp(message('mcb:blocks:APIshowWmaxCVCP',...
                    num2str(floor(w_cvcp_maxspeed_rpm))).getString());
                end
                if constraintCurves==1
                    mcbPMSMCharacteristics(pmsm,inverter,...
                    'speed',w_cvcp_maxspeed_rpm,...
                    'opacity',w_corner_rpm/w_cvcp_maxspeed_rpm,...
                    'voltageEquation',voltageEquation,'FWCMethod',FWCMethod);
                end
            else
                startval.id=0;startval.iq=0;startval.w=w_corner(end);
                w_cvcp_touchcircle=mcb.internal.PMSMSpeedCurrentsFcn(pmsm,...
                inverter,startval,24,'voltageEquation',voltageEquation,...
                'outputAll',outputAll);
                w_cvcp_touchcircle_rpm=w_cvcp_touchcircle(end)*elec2mech*radps2rpm;
                startval.id=0;startval.iq=0;startval.w=w_corner(end);
                w_cvcp_touchtorque=mcb.internal.PMSMSpeedCurrentsFcn(pmsm,...
                inverter,startval,33,'voltageEquation',voltageEquation,...
                'outputAll',outputAll);
                w_cvcp_touchtorque_rpm=w_cvcp_touchtorque(end)*elec2mech*radps2rpm;
                startval.id=0;startval.iq=0;startval.w=w_corner(end);
                w_circle_touchtorque=mcb.internal.PMSMSpeedCurrentsFcn(pmsm,...
                inverter,...
                startval,25,'voltageEquation',voltageEquation,...
                'outputAll',outputAll);
                w_circle_touchtorque_rpm=w_circle_touchtorque(end)*elec2mech*radps2rpm;

                if w_cvcp_touchtorque_rpm<w_circle_touchtorque_rpm
                    w_cvcp_maxspeed=w_cvcp_touchtorque;
                else
                    w_cvcp_maxspeed=w_circle_touchtorque;
                end
                w_cvcp_maxspeed_rpm=w_cvcp_maxspeed(end)*elec2mech*radps2rpm;
                if w_cvcp_maxspeed_rpm>w_cvcp_touchcircle_rpm

                    if outputAll==1
                        CurrentSpeedArray=[CurrentSpeedArray,w_cvcp_touchcircle];
                    end
                    intermediate_speed=w_cvcp_touchcircle_rpm;
                    if verbose
                        disp(message('mcb:blocks:APIshowWThresholdICVCP',...
                        num2str(floor(w_cvcp_touchcircle_rpm))).getString());
                    end
                    if constraintCurves==1
                        mcbPMSMCharacteristics(pmsm,inverter,...
                        'speed',w_cvcp_touchcircle_rpm,...
                        'opacity',w_corner_rpm/w_cvcp_touchcircle_rpm,...
                        'voltageEquation',voltageEquation,'FWCMethod',FWCMethod);
                    end
                end
                if outputAll==1
                    CurrentSpeedArray=[CurrentSpeedArray,w_cvcp_maxspeed];
                end
                if verbose
                    disp(message('mcb:blocks:APIshowWmaxCVCP',...
                    num2str(floor(w_cvcp_maxspeed_rpm))).getString());
                end
                if constraintCurves==1
                    mcbPMSMCharacteristics(pmsm,inverter,...
                    'speed',w_cvcp_maxspeed_rpm,...
                    'opacity',w_corner_rpm/w_cvcp_maxspeed_rpm,...
                    'voltageEquation',voltageEquation,'FWCMethod',FWCMethod);
                end
            end
            max_speed=w_cvcp_maxspeed_rpm;
        elseif strcmpi(FWCMethod,'cccp')==1
            startval.id=0;startval.iq=0;startval.w=w_corner(end);
            w_cccp_voltlimit=mcb.internal.PMSMSpeedCurrentsFcn(pmsm,...
            inverter,startval,28,'voltageEquation',voltageEquation,...
            'outputAll',outputAll);
            w_cccp_voltagelimit_rpm=w_cccp_voltlimit(end)*elec2mech*radps2rpm;
            startval.id=0;startval.iq=0;startval.w=w_corner(end);
            w_cccp_maxspeed=mcb.internal.PMSMSpeedCurrentsFcn(pmsm,...
            inverter,...
            startval,30,'voltageEquation',voltageEquation,...
            'outputAll',outputAll);
            if isempty(w_cccp_maxspeed)
                w_cccp_maxspeed=w_cccp_voltlimit;
                w_cccp_maxspeed_rpm=w_cccp_maxspeed(end)*elec2mech*radps2rpm;
                if outputAll==1
                    CurrentSpeedArray=[CurrentSpeedArray,w_cccp_maxspeed];
                end
                if verbose
                    disp(message('mcb:blocks:APIshowWmaxCCCP',...
                    num2str(floor(w_cccp_maxspeed_rpm))).getString());
                end
                if constraintCurves==1
                    mcbPMSMCharacteristics(pmsm,inverter,...
                    'speed',w_cccp_maxspeed_rpm,...
                    'opacity',w_corner_rpm/w_cccp_maxspeed_rpm,...
                    'voltageEquation',voltageEquation,'FWCMethod',FWCMethod);
                end
            elseif w_cccp_maxspeed(end)<w_cccp_voltlimit(end)
                w_cccp_maxspeed_rpm=w_cccp_maxspeed(end)*elec2mech*radps2rpm;
                if outputAll==1
                    CurrentSpeedArray=[CurrentSpeedArray,w_cccp_maxspeed];
                end
                if verbose
                    disp(message('mcb:blocks:APIshowWmaxCCCP',...
                    num2str(floor(w_cccp_maxspeed_rpm))).getString());
                end
                if constraintCurves==1
                    mcbPMSMCharacteristics(pmsm,inverter,...
                    'speed',w_cccp_maxspeed_rpm,...
                    'opacity',w_corner_rpm/w_cccp_maxspeed_rpm,...
                    'voltageEquation',voltageEquation,'FWCMethod',FWCMethod);
                end
            else
                intermediate_speed=w_cccp_voltagelimit_rpm;
                w_cccp_maxspeed_rpm=w_cccp_maxspeed(end)*elec2mech*radps2rpm;
                if outputAll==1
                    CurrentSpeedArray=[CurrentSpeedArray,w_cccp_voltlimit];
                    CurrentSpeedArray=[CurrentSpeedArray,w_cccp_maxspeed];
                end
                if constraintCurves==1
                    mcbPMSMCharacteristics(pmsm,inverter,...
                    'speed',w_cccp_voltagelimit_rpm,...
                    'opacity',w_corner_rpm/w_cccp_voltagelimit_rpm,...
                    'voltageEquation',voltageEquation,'FWCMethod',FWCMethod);
                    mcbPMSMCharacteristics(pmsm,inverter,...
                    'speed',w_cccp_maxspeed_rpm,...
                    'opacity',w_corner_rpm/w_cccp_maxspeed_rpm,...
                    'voltageEquation',voltageEquation,'FWCMethod',FWCMethod);
                end
                if verbose
                    disp(message('mcb:blocks:APIshowWThresholdVCCCP',...
                    num2str(floor(w_cccp_voltagelimit_rpm))).getString());
                    disp(message('mcb:blocks:APIshowWmaxCCCP',...
                    num2str(floor(w_cccp_maxspeed_rpm))).getString());
                end
            end
            max_speed=w_cccp_maxspeed_rpm;
        else
            id_mtpv_Irated=Icritical;
            if abs(Icritical)>Irated

                iq_mtpv_Irated=0.1;
            else
                iq_mtpv_Irated=sqrt(Irated^2-id_mtpv_Irated^2);
            end
            L=Ld;

            w_mtpv_onset1=vmax/sqrt(L^2*iq_mtpv_Irated^2...
            +(L*id_mtpv_Irated+fluxPM)^2);

            startval.id=id_mtpv_Irated;startval.iq=iq_mtpv_Irated;
            startval.w=w_mtpv_onset1;
            [w_mtpv_onset,status_ok]=mcb.internal.PMSMSpeedCurrentsFcn(pmsm,...
            inverter,startval,1,...
            'voltageEquation',voltageEquation,'outputAll',outputAll);
            if status_ok==0&&verbose==2
                disp(message('mcb:blocks:APINRnoMTPVONSET').getString());
            end
            if status_ok==0
                startval.id=id_mtpv_Irated;startval.iq=iq_mtpv_Irated;
                startval.w=10*w_mtpv_onset1;
                [w_mtpv_onset,status_ok]=mcb.internal.PMSMSpeedCurrentsFcn(pmsm,...
                inverter,startval,1,...
                'voltageEquation',voltageEquation,'outputAll',outputAll);
            end
            speeds=w_mtpv_onset(end,:);
            w_mtpv_onset=w_mtpv_onset(:,imag(speeds)==0);
            speeds=w_mtpv_onset(end,:);w_mtpv_onset=w_mtpv_onset(:,speeds>=0);
            speeds=w_mtpv_onset(end,:);w_mtpv_onset=w_mtpv_onset(:,speeds<1e7);

            if isempty(w_mtpv_onset)==1||status_ok==0
                startval.id=0;startval.iq=0;startval.w=w_corner(end);
                w_max_vclmt_bv=mcb.internal.PMSMSpeedCurrentsFcn(pmsm,...
                inverter,startval,8,'voltageEquation',voltageEquation,...
                'outputAll',outputAll);
                w_max_vclmt_bv_rpm=w_max_vclmt_bv(end)*elec2mech*radps2rpm;
                if outputAll==1
                    CurrentSpeedArray=[CurrentSpeedArray,w_max_vclmt_bv];
                end
                if verbose
                    disp(message('mcb:blocks:APIshowWmaxVCLMT',...
                    num2str(floor(w_max_vclmt_bv_rpm))).getString());
                end
                if constraintCurves==1
                    mcbPMSMCharacteristics(pmsm,inverter,...
                    'speed',w_max_vclmt_bv_rpm,...
                    'opacity',w_corner_rpm/w_max_vclmt_bv_rpm,...
                    'voltageEquation',voltageEquation,'FWCMethod',FWCMethod);
                end
                w_max=w_max_vclmt_bv;
                w_max_rpm=w_max(end)*elec2mech*radps2rpm;
                max_speed=w_max_rpm;
            else
                w_mtpv_onset_rpm=w_mtpv_onset(end)*elec2mech*radps2rpm;

                startval.id=Icritical;

                startval.iq=0.1;
                startval.w=w_mtpv_onset(end);
                [w_max,status_ok]=mcb.internal.PMSMSpeedCurrentsFcn(pmsm,inverter,...
                startval,2,'voltageEquation',voltageEquation,...
                'outputAll',outputAll);
                if status_ok==0&&verbose==2
                    if outputAll==1
                        val1=w_max(1);
                        val2=w_max(2);
                    else
                        val1=0;
                        val2=0;
                    end
                    disp(message('mcb:blocks:APINRDidnotConverge',...
                    num2str(val1),num2str(val2),num2str(w_max(end))).getString());
                end
                w_max_rpm=w_max(end)*elec2mech*radps2rpm;

                if w_max_rpm<w_mtpv_onset_rpm||status_ok==0
                    startval.id=Icritical;
                    startval.iq=0.1;
                    startval.w=max(scale_high_speed*w_mtpv_onset(end),high_speed_min);
                    [w_max,status_ok]=mcb.internal.PMSMSpeedCurrentsFcn(pmsm,inverter,...
                    startval,2,'voltageEquation',voltageEquation,...
                    'outputAll',outputAll);
                    if status_ok==0&&verbose==2
                        if outputAll==1
                            val1=w_max(1);
                            val2=w_max(2);
                        else
                            val1=0;
                            val2=0;
                        end
                        disp(message('mcb:blocks:APINRDidnotConverge',...
                        num2str(val1),num2str(val2),num2str(w_max(end))).getString());
                    end
                    w_max_rpm=w_max(end)*elec2mech*radps2rpm;
                end
                if w_mtpv_onset_rpm<w_max_rpm

                    if outputAll==1
                        CurrentSpeedArray=[CurrentSpeedArray,w_mtpv_onset];
                    end
                    intermediate_speed=w_mtpv_onset_rpm;
                    if verbose
                        disp(message('mcb:blocks:APIshowWmtpvOnset',...
                        num2str(floor(w_mtpv_onset_rpm))).getString());
                    end
                    if constraintCurves==1
                        mcbPMSMCharacteristics(pmsm,inverter,...
                        'speed',w_mtpv_onset_rpm,...
                        'opacity',w_corner_rpm/w_mtpv_onset_rpm,...
                        'voltageEquation',voltageEquation,'FWCMethod',FWCMethod);
                    end
                end
                if outputAll==1
                    CurrentSpeedArray=[CurrentSpeedArray,w_max];
                end
                if verbose
                    disp(message('mcb:blocks:APIshowWmaxMTPV',...
                    num2str(floor(w_max_rpm))).getString());
                end
                if constraintCurves==1
                    mcbPMSMCharacteristics(pmsm,inverter,'speed',...
                    w_max_rpm,'opacity',w_corner_rpm/w_max_rpm,...
                    'voltageEquation',voltageEquation,'FWCMethod',FWCMethod);
                end
                max_speed=w_max_rpm;
            end

        end
    end
    max_speed=round(max_speed);
    corner_speed=round(w_corner_rpm);
    intermediate_speed=round(intermediate_speed);
    if intermediate_speed<0
        milestone_speeds=[corner_speed;max_speed];
    else
        milestone_speeds=[corner_speed;intermediate_speed;max_speed];
    end
    if outputAll==1
        milestone_speeds=CurrentSpeedArray;
    end
end
