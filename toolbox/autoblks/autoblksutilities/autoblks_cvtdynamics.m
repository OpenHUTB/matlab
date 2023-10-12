function[wdot_pri,wdot_sec,vdot_b,tau_pri_BoP,tau_sec_BoP,LockedState,NewPriSlipDir,NewSecSlipDir]=autoblks_cvtdynamics(theta_wedge,F_ax,J_pri,J_sec,m_b,mu_static,mu_kin,b_pri,b_sec,b_b,...
    tau_pri,tau_sec,r_pri,r_sec,phi_pri,phi_sec,PriSlipDir,SecSlipDir,w_pri,w_sec,v_b,PriVelMatch,SecVelMatch,StartSlipFlag)

%#codegen
    coder.allowpcode('plain')

    if PriSlipDir~=0&&PriVelMatch
        PriSlipDir=0;
    end
    DeltaPriVel=r_pri*w_pri-v_b;
    if PriSlipDir~=0&&DeltaPriVel~=0
        PriSlipDir=sign(DeltaPriVel);
    end


    if SecSlipDir~=0&&SecVelMatch
        SecSlipDir=0;
    end
    DeltaSecVel=r_sec*w_sec-v_b;
    if SecSlipDir~=0&&DeltaSecVel~=0
        SecSlipDir=sign(DeltaSecVel);
    end

    if PriSlipDir~=0&&SecSlipDir~=0
        LockedState=0;
    elseif PriSlipDir==0&&SecSlipDir==0
        LockedState=3;
    elseif SecSlipDir==0
        LockedState=1;
    else
        LockedState=2;
    end

    switch LockedState
    case 0
        tau_pri_BoP=PriSlipDir*FricTrq(theta_wedge,r_pri,F_ax,mu_kin);
        tau_sec_BoP=SecSlipDir*FricTrq(theta_wedge,r_sec,F_ax,mu_kin);
        wdot_pri=-(tau_pri_BoP-tau_pri+b_pri*w_pri)/J_pri;
        wdot_sec=-(tau_sec_BoP-tau_sec+b_sec*w_sec)/J_sec;
        vdot_b=(tau_pri_BoP/r_pri-b_b*v_b+tau_sec_BoP/r_sec)/m_b;
    case 1
        tau_pri_BoP=PriSlipDir*FricTrq(theta_wedge,r_pri,F_ax,mu_kin);
        wdot_pri=-(tau_pri_BoP-tau_pri+b_pri*w_pri)/J_pri;
        vdot_b=(r_sec^2*tau_pri_BoP-b_sec*r_pri*v_b+r_pri*r_sec*tau_sec-b_b*r_pri*r_sec^2*v_b)/(r_pri*(m_b*r_sec^2+J_sec));
        wdot_sec=vdot_b/r_sec;
        tau_sec_BoP=tau_sec-b_sec*w_sec-(J_sec*vdot_b)/r_sec;
    case 2
        tau_sec_BoP=SecSlipDir*FricTrq(theta_wedge,r_sec,F_ax,mu_kin);
        wdot_sec=-(tau_sec_BoP-tau_sec+b_sec*w_sec)/J_sec;
        vdot_b=(r_pri^2*tau_sec_BoP-b_pri*r_sec*v_b+r_pri*r_sec*tau_pri-b_b*r_pri^2*r_sec*v_b)/(r_sec*(m_b*r_pri^2+J_pri));
        wdot_pri=vdot_b/r_pri;
        tau_pri_BoP=tau_pri-b_pri*w_pri-(J_pri*vdot_b)/r_pri;
    otherwise
        vdot_b=((tau_pri-(b_pri*v_b)/r_pri)/r_pri+(tau_sec-(b_sec*v_b)/r_sec)/r_sec-b_b*v_b)/(m_b+J_pri/r_pri^2+J_sec/r_sec^2);
        wdot_pri=vdot_b/r_pri;
        wdot_sec=vdot_b/r_sec;
        tau_pri_BoP=tau_pri-b_pri*w_pri-(J_pri*vdot_b)/r_pri;
        tau_sec_BoP=tau_sec-b_sec*w_sec-(J_sec*vdot_b)/r_sec;
    end



    StartSlip=false;


    if PriSlipDir==0
        tau_pri_BoP_limit=FricTrq(theta_wedge,r_pri,F_ax,mu_static);
        if tau_pri_BoP>tau_pri_BoP_limit
            PriSlipDir=1;
            StartSlip=true;
        elseif tau_pri_BoP<-tau_pri_BoP_limit
            PriSlipDir=-1;
            StartSlip=true;
        end
    end


    if SecSlipDir==0
        tau_sec_BoP_limit=FricTrq(theta_wedge,r_sec,F_ax,mu_static);
        if tau_sec_BoP>tau_sec_BoP_limit
            SecSlipDir=1;
            StartSlip=true;
        elseif tau_sec_BoP<-tau_sec_BoP_limit
            SecSlipDir=-1;
            StartSlip=true;
        end
    end


    NewPriSlipDir=PriSlipDir;
    NewSecSlipDir=SecSlipDir;
    if StartSlip&&StartSlipFlag==0
        [wdot_pri,wdot_sec,vdot_b,tau_pri_BoP,tau_sec_BoP,LockedState,NewPriSlipDir,NewSecSlipDir]=autoblks_cvtdynamics(theta_wedge,F_ax,J_pri,J_sec,m_b,mu_static,mu_kin,b_pri,b_sec,b_b,...
        tau_pri,tau_sec,r_pri,r_sec,phi_pri,phi_sec,PriSlipDir,SecSlipDir,w_pri,w_sec,v_b,PriVelMatch,SecVelMatch,1);
    end

end


function Trq=FricTrq(theta_wedge,r,F_ax,mu)
%#codegen

    Trq=2*mu*F_ax*r/cosd(theta_wedge);
end