function[w_vec,i_vec,vMatrix]=hBridgeAverageModeInit_private(Vs,Ra,La,R_on,D_on,F,freewheeling_mode)







    p=1/F;
    R_on2=R_on/2;

    R1=R_on+Ra;
    if freewheeling_mode==ee.enum.converters.freewheeling_mode.one_switch_one_diode
        R2=D_on+R_on/2+Ra;
    elseif freewheeling_mode==ee.enum.converters.freewheeling_mode.two_diodes
        R2=2*D_on+Ra;
    else
        R2=R_on/2+D_on*R_on2/(R_on2+D_on)+Ra;
    end

    L=R1/La;
    L2=R2/La;
    c1=L*R1*Vs;
    c6=L*L2*R1;
    c9=L2*R2*Vs;
    c15=L*R1*Ra;
    c16=L*R2*Ra;
    c17=L*L2;
    c18=L2*R2*Ra;
    c19=R1*R2;
    c20=L*L2*R2;


    w_vec=0:p/20:p;
    w_vec(1)=p/1000;
    i_max=Vs/R1;
    i_vec=-i_max:i_max/50:i_max;
    i_vec(51)=i_max/1000;
    vMax=10*Vs;vMin=-10*Vs;
    vMatrix=zeros(length(i_vec),length(w_vec));

    for jj=1:length(w_vec)

        w=w_vec(jj);

        if L*w<40
            c2=exp(L*w);
            c4=exp((L*w)/2);
            c21=sinh((L*w)/2);
        else
            c2=exp(40);
            c4=exp(40/2);
            c21=sinh((40)/2);
        end
        c5=exp(L*w+L2*(p-w));
        c7=exp(L2*(p-w));
        c8=exp(L2*w-L*w-L2*p);
        c10=exp((L2*(p-w))/2);
        c11=sinh((L2*(p-w))/2);
        c3=exp(L*w+(L2*(p-w))/2);

        for ii=1:length(i_vec)

            i=i_vec(ii);
            if freewheeling_mode~=2

                i0=-((2*L*Vs*c21-2*L2*Vs*c21)/c4+(L*Vs-L2*Vs+c17*Vs*p-c17*Vs*w+c20*i*p)/c5-(L*Vs)/c7+(L2*Vs)/c7+c17*Vs*w-(c17*Vs*p)/c7-(c20*i*p)/c7-(2*c6*i*p*c11)/c10)/((L*R1-L*R2-L2*R1+L2*R2)/c7-(L*R1-L*R2-L2*R1+L2*R2+c6*p-c6*w+c20*w)/c5-(2*L*R1*c21)/c4+(2*L*R2*c21)/c4+(2*L2*R1*c21)/c4-(2*L2*R2*c21)/c4+c6*p-c6*w+c20*w);
                if i0>0
                    v=((2*c9*c21-2*L2*c19*i0*c21+2*c18*i*c21)/c4+(2*c11*(L*R2*Vs-L*c19*i0+c16*i))/c3-L*c9*w-(2*L*R2*Vs*c11)/c10+(2*c15*i*c11)/c10-(2*c16*i*c11)/c10+c6*R2*i*p-c6*Ra*i*p+c6*Ra*i*w-L*c18*i*w)/((2*L2*R2*c21)/c4-(2*L*R2*c21)/c4+(2*L*R1*c11)/c10-c6*p+c6*w-c20*w+(2*L*R2*c21)/exp((L*w)/2+L2*(p-w)));
                else

                    v=Vs+Ra*i-(R1*i*p)/w+(2*R1*i*p*c21)/(w*(2*c21-L*w*c4));
                    if v>vMax,v=vMax;elseif v<vMin,v=vMin;end

                    if i>0
                        v_max=Vs;v_min=vMin;
                    else
                        v_max=vMax;v_min=-Vs;
                    end
                    not_converged=1;
                    while not_converged
                        vb=v-i*Ra;
                        i_given_v=-((L2*(Vs-vb))/R1+(L*vb*log(1-(R2*(Vs-vb)*(1/c2-1))/(R1*vb)))/R2-(L2*(Vs-vb))/(R1*c2)+(L*(Vs-vb)*(1/c2-1))/R1-(L*L2*w*(Vs-vb))/R1)/(L*L2*p);
                        if i_given_v>i
                            v_min=v;
                        else
                            v_max=v;
                        end
                        v_last=v;
                        v=(v_min+v_max)/2;
                        if abs(v-v_last)<0.01
                            not_converged=0;
                        end
                    end
                end
            else

                i0=-((4*L*Vs*c21-4*L2*Vs*c21)/c4+(2*L*Vs-2*L2*Vs+2*c17*Vs*p-2*c17*Vs*w+c20*i*p)/c5-(2*L*Vs)/c7+(2*L2*Vs)/c7+2*c17*Vs*w-(2*c17*Vs*p)/c7-(c20*i*p)/c7-(2*c6*i*p*c11)/c10)/((L*R1-L*R2-L2*R1+L2*R2)/c7-(L*R1-L*R2-L2*R1+L2*R2+c6*p-c6*w+c20*w)/c5-(2*L*R1*c21)/c4+(2*L*R2*c21)/c4+(2*L2*R1*c21)/c4-(2*L2*R2*c21)/c4+c6*p-c6*w+c20*w);
                if i0>0
                    v=(c1+L*R2*Vs-c9-(c1)/c7-(L*R2*Vs)/c7+L*R2*Vs*c8-c15*i+c16*i+L2*c19*i0-c18*i-(L*R2*Vs)/c2+(c9)/c2-c6*Vs*p+c6*Vs*w+L*c9*w+(L*c19*i0)/c2-(c16*i)/c2-(L2*c19*i0)/c2+(c18*i)/c2+(c15*i)/c7-(c16*i)/c7-L*c19*i0*c8+c16*i*c8-c6*R2*i*p+c6*Ra*i*p-c6*Ra*i*w+L*c18*i*w)/(L*R2-L*R1-L2*R2+L*R2*c8-(L*R2)/c2+(L2*R2)/c2+(L*R1)/c7-(L*R2)/c7+c6*p-c6*w+c20*w);
                else

                    v=Vs+Ra*i-(R1*i*p)/w+(2*R1*i*p*c21)/(w*(2*c21-L*w*c4));

                    if i>0
                        v_max=Vs;v_min=vMin;
                    else
                        v_max=vMax;v_min=-Vs;
                    end
                    not_converged=1;
                    while not_converged
                        vb=v-i*Ra;
                        i_given_v=-((L2*(Vs-vb))/R1-(L2*(Vs-vb))/(R1*c2)+(L*log(1-(R2*(Vs-vb)*(1/c2-1))/(R1*(Vs+vb)))*(Vs+vb))/R2+(L*(Vs-vb)*(1/c2-1))/R1-(L*L2*w*(Vs-vb))/R1)/(L*L2*p);
                        if i_given_v>i
                            v_min=v;
                        else
                            v_max=v;
                        end
                        v_last=v;
                        v=(v_min+v_max)/2;
                        if abs(v-v_last)<0.01
                            not_converged=0;
                        end
                    end
                end
            end
            if v>vMax,v=vMax;elseif v<vMin,v=vMin;end
            vMatrix(ii,jj)=v;
        end
    end

end