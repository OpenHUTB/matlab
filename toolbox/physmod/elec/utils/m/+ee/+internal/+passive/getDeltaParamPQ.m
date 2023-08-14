function[R,L,C,IL0,VC0]=getDeltaParamPQ(component_structure_PQ,VRated,FRated,P,Qpos,Qneg,Vmag0,Vang0,Freq0)%#codegen




    coder.allowpcode('plain');

    R=0;
    L=0;
    C=0;
    IL0=[0,0,0];
    VC0=[0,0,0];

    if component_structure_PQ==1
        R=3*VRated^2/P;
    else
        e=ee.internal.ElectricalConstants;
        Vphasor=sqrt(2)*Vmag0.*exp(1i*(Vang0-pi/6)).*[1,e.a2,e.a];
        w=2*pi*FRated;
        wInitial=2*pi*Freq0;
        if component_structure_PQ==2
            L=3*VRated^2/(Qpos*w);
            IL0=imag(Vphasor/(1i*wInitial*L));
        elseif component_structure_PQ==3
            C=-Qneg/(VRated^2*w)/3;
            VC0=imag(Vphasor);
        elseif component_structure_PQ==4
            R=3*(VRated^2*P)/(Qpos^2+P^2);
            L=3*(Qpos*VRated^2)/(w*(Qpos^2+P^2));
            IL0=imag(Vphasor/(R+1i*wInitial*L));
        elseif component_structure_PQ==5
            R=3*(P*VRated^2)/(P^2+Qneg^2);
            C=-(P^2+Qneg^2)/(Qneg*VRated^2*w)/3;
            VC0=imag(Vphasor/(1i*wInitial*C)/(R+1/(1i*wInitial*C)));
        elseif component_structure_PQ==6
            L=3*(Qpos*VRated^2)/(w*(Qneg^2+2*Qneg*Qpos+Qpos^2));
            C=-(Qneg^2+2*Qneg*Qpos+Qpos^2)/(Qneg*VRated^2*w)/3;
            IL0=imag(Vphasor/(1i*wInitial*L+1/(1i*wInitial*C)));
            VC0=imag(Vphasor/(1i*wInitial*C)/(1i*wInitial*L+1/(1i*wInitial*C)));
        elseif component_structure_PQ==7
            R=3*(P*VRated^2)/(P^2+Qneg^2+2*Qneg*Qpos+Qpos^2);
            L=3*(Qpos*VRated^2)/(w*(P^2+Qneg^2+2*Qneg*Qpos+Qpos^2));
            C=-(P^2+Qneg^2+2*Qneg*Qpos+Qpos^2)/(Qneg*VRated^2*w)/3;
            IL0=imag(Vphasor/(R+1i*wInitial*L+1/(1i*wInitial*C)));
            VC0=imag(Vphasor/(1i*wInitial*C)/(R+1i*wInitial*L+1/(1i*wInitial*C)));
        elseif component_structure_PQ==8
            R=3*VRated^2/P;
            L=3*VRated^2/(Qpos*w);
            IL0=imag(Vphasor/(1i*wInitial*L));
        elseif component_structure_PQ==9
            R=3*VRated^2/P;
            C=-Qneg/(VRated^2*w)/3;
            VC0=imag(Vphasor);
        elseif component_structure_PQ==10
            L=3*VRated^2/(Qpos*w);
            C=-Qneg/(VRated^2*w)/3;
            VC0=imag(Vphasor);
            IL0=imag(Vphasor/(1i*wInitial*L));
        elseif component_structure_PQ==11
            R=3*VRated^2/P;
            L=3*VRated^2/(Qpos*w);
            C=-Qneg/(VRated^2*w)/3;
            VC0=imag(Vphasor);
            IL0=imag(Vphasor/(1i*wInitial*L));
        end
    end


end