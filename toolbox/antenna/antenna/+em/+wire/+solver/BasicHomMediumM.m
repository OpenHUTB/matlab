classdef BasicHomMediumM<em.wire.solver.BasicMedium
    properties
epsilon_r
mu_r
EMSolObj
    end
    properties(Constant=true)
        relTol=1e-3;
        absTol=1e-10;
        neighborR=5;
    end
    methods
        function obj=BasicHomMediumM(epsilon_r,mu_r)
            obj.epsilon_r=epsilon_r;
            obj.mu_r=mu_r;
            obj.EMSolObj=em.wire.solver.EMSolution();
        end
        function lambda0=Lambda0(obj,freqs)
            lambda0=obj.c0./freqs;
        end
        function lambda=Lambda(obj,freqs)
            lambda=(obj.c0/sqrt(obj.epsilon_r*obj.mu_r))./freqs;
        end
        function waveNumber=WaveNumber(obj,freqs)
            waveNumber=(2*pi*freqs/obj.c0)*sqrt(obj.epsilon_r*obj.mu_r);
        end
        function PmV=CalcSegECoeffs(obj,rp_,Up,rsm_,Um,hm_,omV,...
            a_,nR,freqs)



            waveNumbers=(2*pi/obj.c0)*sqrt(obj.epsilon_r*obj.mu_r)*...
            obj.EMSolObj.Freqs;
            PmV=zeros(size(rp_,1),omV(end)+1,length(freqs));
            for freqInd=1:length(freqs)

                Rm=(rp_-rsm_)*waveNumbers(freqInd);
                tm=(Rm*Um');
                Tm=tm*Um;
                Rm_minus_Tm=Rm-Tm;
                cm2=sum(Rm_minus_Tm.^2,2);
                hm=hm_*waveNumbers(freqInd);
                tmTag=tm-hm/2;
                a2PlusCm2=(a_*waveNumbers(freqInd))^2+cm2;
                if nR<obj.neighborR
                    if(max(abs(tmTag))/hm)^omV(end)<10
                        Gprime=obj.G_prime_i(0:omV(end),hm,tm,a2PlusCm2);
                        G=obj.GiV(0:omV(end),hm,tmTag,Gprime);
                        S0=obj.S0(hm,tm,a2PlusCm2);
                        Cprime=obj.C_prime_i(0:omV(end),hm,tm,a2PlusCm2);
                        [Q1,Q2]=obj.Q12(0:omV(end),hm,tmTag,Gprime,...
                        Cprime);
                        Pm=zeros(size(tm,1),omV(end)+1);
                        Pm(:,1)=(Up*Um')*G(:,0+1);
                        if omV(end)>0
                            Pm(:,2)=(Up*Um')*(G(:,1+1)-Cprime(:,0+1)/hm);
                            if any(Um~=Up)
                                Pm(:,2)=Pm(:,2)+((Rm_minus_Tm*Up')/hm).*S0;
                            end
                            if omV(end)>1
                                Pm(:,3)=(Up*Um')*(G(:,2+1)-...
                                (2*tmTag/(hm^2)).*Cprime(:,0+1)-...
                                (2/(hm^2))*(Cprime(:,1+1)-G(:,0+1)));
                                if any(Um~=Up)
                                    Pm(:,3)=Pm(:,3)+...
                                    (2*(Rm_minus_Tm*Up')/(hm^2)).*...
                                    (Cprime(:,0+1)+tmTag.*S0);
                                end
                                if omV(end)>2
                                    om=3:omV(end);
                                    Pm(:,4:omV(end)+1)=(Up*Um')*(G(:,om+1)-...
                                    om.*(Q1(:,om+1)+...
                                    (tmTag.^(om-1).*Cprime(:,0+1)+...
                                    Cprime(:,om-1+1)-...
                                    (om-1).*Gprime(:,om-1))./(hm.^om)));
                                    if any(Um~=Up)
                                        Pm(:,4:omV(end)+1)=Pm(:,4:omV(end)+1)+...
                                        om.*(Rm_minus_Tm*Up').*...
                                        (Q2(:,om+1)+...
                                        (tmTag.^(om-1).*S0+...
                                        (om-1).*tmTag.^(om-2).*...
                                        Cprime(:,0+1))./(hm.^om));
                                    end
                                end
                            end
                        end
                    else
                        om=0:omV(end);

                        fullInt=reshape(quadv(@fullIntegrand,0,hm),[],...
                        omV(end)+1,3);%#ok<DQUADV>
                        Pm(:,1:omV(end)+1)=(Up*Um')*...
                        (squeeze(fullInt(:,1:omV(end)+1,1))+...
                        squeeze(fullInt(:,1:omV(end)+1,3)));
                        if any(Um~=Up)
                            Pm(:,1:omV(end)+1)=Pm(:,1:omV(end)+1)-...
                            (Rm_minus_Tm*Up').*...
                            squeeze(fullInt(:,1:omV(end)+1,2));
                        end
                    end
                else
                    raInit=sqrt((-tm).^2+a2PlusCm2);
                    raInitInv=1./raInit;
                    f1Init=exp(-1j*raInit).*raInitInv;
                    f2Init=-(raInitInv.^2+1j*raInitInv).*f1Init;
                    raEnd=sqrt((hm-tm).^2+a2PlusCm2);
                    raEndInv=1./raEnd;
                    f1End=exp(-1j*raEnd).*raEndInv;
                    f2End=-(raEndInv.^2+1j*raEndInv).*f1End;
                    f1_delta=(f1End-f1Init);
                    f1_av=(f1End+f1Init)/2;
                    f2_delta=(f2End-f2Init);
                    f2_av=(f2End+f2Init)/2;
                    Pm(:,1)=(Up*Um')*hm*f1_av;

                    if omV(end)>=1
                        Pm(:,2)=((Up*Um')*(f1_delta.*(hm/12-1/hm))+...
                        (Rm_minus_Tm*Up').*f2_av);

                        if omV(end)>=2
                            Pm(:,3)=f1_av.*(Up*Um')*hm/12+...
                            (Rm_minus_Tm*Up').*f2_delta/6;

                            if omV(end)>=3
                                Pm(:,4)=...
                                ((Up*Um')*f1_delta.*(hm/80-1/(4*hm))+...
                                (Rm_minus_Tm*Up').*f2_av/4);
                                Pm(:,5:omV(end)+1)=0;












                            end
                        end
                    end
                end
                PmV(:,:,freqInd)=Pm;
            end
            function y=fullIntegrand(sm)
                ra=sqrt((sm-tm).^2+a2PlusCm2);
                expOverra=exp(-1j*ra)./ra;
                y0=(((sm-hm/2)/hm).^(om(2:end)-1)).*expOverra;
                y1=((sm-hm/2)/hm).*y0;
                y1=[expOverra,y1];
                y2=(1/hm)*om(2:end).*(1+1j*ra).*y0./(ra.^2);
                y2=[zeros(size(tm)),y2];
                y3=(sm-tm).*y2;
                y=[y1,y2,y3];
            end
        end

        function ECoeffs=CalcSegEFullCoeffs(obj,rp_,rsm_,Um,hm_,...
            omV,a_,nR,freq)







            Rm=(rp_-rsm_)*obj.WaveNumber(freq);
            tm=(Rm*Um');
            Tm=tm*Um;
            RmMinusTm=mat2cell((Rm-Tm),ones(1,size(rp_,1)));
            cm2=cellfun(@(v,u)v*u',RmMinusTm,RmMinusTm);
            hm=hm_*obj.WaveNumber(freq);
            tmTag=tm-hm/2;
            a2PlusCm2=(a_*obj.WaveNumber(freq))^2+cm2;



            if all(abs(abs(Um)-[0,0,1])<sqrt(eps)*[1,1,1])

                Up_phi=[-1,0,0];
                Up_theta=[0,1,0]*sign(Um(3));
            else
                Up_phi=cross([0,0,1],Um)/norm(cross([0,0,1],Um));
                Up_theta=cross(Up_phi,Um)/norm(cross(Up_phi,Um));
            end


            isNotNeigbor=(nR>=obj.neighborR);
            isPseudoSing=(~isNotNeigbor&...
            (abs(tmTag)/hm).^omV(end)<10);
            isFullInt=(~isNotNeigbor&...
            ~((abs(tmTag)/hm).^omV(end)<10));
            Rm_minus_Tm=Rm-Tm;
            Pm=zeros(size(tm,1),omV(end)+1,3);

            if any(isPseudoSing)
                tm_ps=tm(isPseudoSing);
                a2PlusCm2_ps=a2PlusCm2(isPseudoSing);
                tmTag_ps=tmTag(isPseudoSing);
                Rm_minus_Tm_ps=Rm_minus_Tm(isPseudoSing,:);
                Gprime=obj.G_prime_i(0:omV(end),hm,tm_ps,a2PlusCm2_ps);
                G=obj.GiV(0:omV(end),hm,tmTag_ps,Gprime);
                S0=obj.S0(hm,tm_ps,a2PlusCm2_ps);
                Cprime=obj.C_prime_i(0:omV(end),hm,tm_ps,a2PlusCm2_ps);
                [Q1,Q2]=obj.Q12(0:omV(end),hm,tmTag_ps,Gprime,...
                Cprime);
                Pm_ps=zeros(size(tm_ps,1),omV(end)+1,3);
                Pm_ps(:,1,1)=G(:,0+1);
                if omV(end)>0
                    Pm_ps(:,2,1)=G(:,1+1)-Cprime(:,0+1)/hm;
                    Pm_ps(:,2,2)=((Rm_minus_Tm_ps*Up_theta')/hm).*S0;
                    Pm_ps(:,2,3)=((Rm_minus_Tm_ps*Up_phi')/hm).*S0;
                    if omV(end)>1
                        Pm_ps(:,3,1)=G(:,2+1)-...
                        (2*tmTag_ps/(hm^2)).*Cprime(:,0+1)-...
                        (2/(hm^2))*(Cprime(:,1+1)-G(:,0+1));
                        Pm_ps(:,3,2)=(2*(Rm_minus_Tm_ps*Up_theta')/(hm^2)).*...
                        (Cprime(:,0+1)+tmTag_ps.*S0);
                        Pm_ps(:,3,3)=(2*(Rm_minus_Tm_ps*Up_phi')/(hm^2)).*...
                        (Cprime(:,0+1)+tmTag_ps.*S0);
                        if omV(end)>2
                            om=3:omV(end);
                            Pm_ps(:,4:omV(end)+1,1)=G(:,om+1)-...
                            om.*(Q1(:,om+1)+...
                            (tmTag_ps.^(om-1).*Cprime(:,0+1)+...
                            Cprime(:,om-1+1)-...
                            (om-1).*Gprime(:,om-1))./(hm.^om));
                            Pm_ps(:,4:omV(end)+1,2)=om.*...
                            (Rm_minus_Tm_ps*Up_theta').*...
                            (Q2(:,om+1)+...
                            (tmTag_ps.^(om-1).*S0+...
                            (om-1).*tmTag_ps.^(om-2).*Cprime(:,0+1))./...
                            (hm.^om));
                            Pm_ps(:,4:omV(end)+1,3)=om.*...
                            (Rm_minus_Tm_ps*Up_phi').*...
                            (Q2(:,om+1)+...
                            (tmTag_ps.^(om-1).*S0+...
                            (om-1).*tmTag_ps.^(om-2).*Cprime(:,0+1))./...
                            (hm.^om));
                        end
                    end
                end
                Pm(isPseudoSing,:,:)=Pm_ps;
            end

            if any(isFullInt)
                tm_fi=tm(isFullInt);
                a2PlusCm2_fi=a2PlusCm2(isFullInt);
                Rm_minus_Tm_fi=Rm_minus_Tm(isFullInt,:);
                om=0:omV(end);


                fullInt=reshape(quadv(@fullIntegrand,0,hm),[],...
                omV(end)+1,3);%#ok<DQUADV>
                Pm_fi=zeros(size(tm_fi,1),omV(end)+1,3);
                Pm_fi(:,1:omV(end)+1,1)=...
                squeeze(fullInt(:,1:omV(end)+1,1))+...
                squeeze(fullInt(:,1:omV(end)+1,3));
                Pm_fi(:,1:omV(end)+1,2)=(Rm_minus_Tm_fi*Up_theta').*...
                squeeze(fullInt(:,1:omV(end)+1,2));
                Pm_fi(:,1:omV(end)+1,3)=(Rm_minus_Tm_fi*Up_phi').*...
                squeeze(fullInt(:,1:omV(end)+1,2));
                Pm(isFullInt,:,:)=Pm_fi;
            end


            if any(isNotNeigbor)
                tm_nnb=tm(isNotNeigbor);
                a2PlusCm2_nnb=a2PlusCm2(isNotNeigbor);
                Rm_minus_Tm_nnb=Rm_minus_Tm(isNotNeigbor,:);
                raInit=sqrt((-tm_nnb).^2+a2PlusCm2_nnb);
                raInitInv=1./raInit;
                f1Init=exp(-1j*raInit).*raInitInv;
                f2Init=-(raInitInv.^2+1j*raInitInv).*f1Init;
                raEnd=sqrt((hm-tm_nnb).^2+a2PlusCm2_nnb);
                raEndInv=1./raEnd;
                f1End=exp(-1j*raEnd).*raEndInv;
                f2End=-(raEndInv.^2+1j*raEndInv).*f1End;
                f1_delta=(f1End-f1Init);
                f1_av=(f1End+f1Init)/2;
                f2_delta=(f2End-f2Init);
                f2_av=(f2End+f2Init)/2;
                Pm_nnb=zeros(size(tm_nnb,1),omV(end)+1,3);
                Pm_nnb(:,1,1)=hm*f1_av;
                Pm_nnb(:,1,2:3)=0;
                if omV(end)>=1
                    Pm_nnb(:,2,1)=f1_delta*(hm/12-1/hm);
                    Pm_nnb(:,2,2)=(Rm_minus_Tm_nnb*Up_theta').*f2_av;
                    Pm_nnb(:,2,3)=(Rm_minus_Tm_nnb*Up_phi').*f2_av;
                    if omV(end)>=2
                        Pm_nnb(:,3,1)=f1_av*hm/12;
                        Pm_nnb(:,3,2)=(Rm_minus_Tm_nnb*Up_theta').*f2_delta/6;
                        Pm_nnb(:,3,3)=(Rm_minus_Tm_nnb*Up_phi').*f2_delta/6;
                        if omV(end)>=3
                            Pm_nnb(:,4,1)=f1_delta*(hm/80-1/(4*hm));
                            Pm_nnb(:,4,2)=(Rm_minus_Tm_nnb*Up_theta').*...
                            f2_av/4;
                            Pm_nnb(:,4,3)=(Rm_minus_Tm_nnb*Up_phi').*...
                            f2_av/4;
                            Pm_nnb(:,5:omV(end)+1,:)=0;
                        end
                    end
                end
                Pm(isNotNeigbor,:,:)=Pm_nnb;
            end
            ECoeffs=-1j*(2*pi*freq)*(obj.mu_r*obj.mu0)/(4*pi)*Pm;
            function y=fullIntegrand(sm)
                ra=sqrt((sm-tm_fi).^2+a2PlusCm2_fi);
                expOverra=exp(-1j*ra)./ra;
                y0=(((sm-hm/2)/hm).^(om(2:end)-1)).*expOverra;
                y1=((sm-hm/2)/hm).*y0;
                y1=[expOverra,y1];
                y2=-(1/hm)*om(2:end).*(1+1j*ra).*y0./(ra.^2);
                y2=[zeros(size(tm_fi)),y2];
                y3=(tm_fi-sm).*y2;
                y=[y1,y2,y3];
            end
        end

        function HCoeffs=CalcSegHFullCoeffs(obj,rp_,rsm_,Um,hm_,...
            omV,a_,nR,freq)







            Rm=(rp_-rsm_)*obj.WaveNumber(freq);
            tm=(Rm*Um');
            Tm=tm*Um;
            RmMinusTm=mat2cell((Rm-Tm),ones(1,size(rp_,1)));
            cm2=cellfun(@(v,u)v*u',RmMinusTm,RmMinusTm);
            hm=hm_*obj.WaveNumber(freq);
            tmTag=tm-hm/2;
            a2PlusCm2=(a_*obj.WaveNumber(freq))^2+cm2;



            if all(abs(abs(Um)-[0,0,1])<sqrt(eps)*[1,1,1])

                Up_phi=[-1,0,0];
                Up_theta=[0,1,0]*sign(Um(3));
            else
                Up_phi=cross([0,0,1],Um)/norm(cross([0,0,1],Um));
                Up_theta=cross(Up_phi,Um)/norm(cross(Up_phi,Um));
            end


            isNotNeigbor=(nR>=obj.neighborR);
            isPseudoSing=~isNotNeigbor&...
            (abs(tmTag)/hm).^omV(end)<10;
            isFullInt=~isNotNeigbor&...
            ~((abs(tmTag)/hm).^omV(end)<10);
            Rm_minus_Tm=Rm-Tm;
            Wm=zeros(size(tm,1),omV(end)+1,3);

            if any(isPseudoSing)
                tm_ps=tm(isPseudoSing);
                a2PlusCm2_ps=a2PlusCm2(isPseudoSing);
                tmTag_ps=tmTag(isPseudoSing);
                Rm_minus_Tm_ps=Rm_minus_Tm(isPseudoSing,:);
                Gprime=obj.G_prime_i(0:omV(end),hm,tm_ps,a2PlusCm2_ps);
                S0=obj.S0(hm,tm_ps,a2PlusCm2_ps);
                Cprime=obj.C_prime_i(0:omV(end),hm,tm_ps,a2PlusCm2_ps);
                Q3=obj.Q3(0:omV(end),hm,tmTag_ps,Gprime,Cprime);
                Wm_ps=zeros(size(tm_ps,1),omV(end)+1,3);
                Wm_ps(:,1,2)=-(Rm_minus_Tm_ps*Up_phi').*S0;
                Wm_ps(:,1,3)=(Rm_minus_Tm_ps*Up_theta').*S0;
                if omV(end)>0
                    Wm_ps(:,2,2)=-(Rm_minus_Tm_ps*Up_phi')/(hm).*...
                    (Cprime(:,0+1)+tmTag_ps.*S0);
                    Wm_ps(:,2,3)=(Rm_minus_Tm_ps*Up_theta')/(hm).*...
                    (Cprime(:,0+1)+tmTag_ps.*S0);
                    if omV(end)>1
                        om=2:omV(end);
                        Wm_ps(:,3:omV(end)+1,2)=-(Rm_minus_Tm_ps*Up_phi').*...
                        (Q3(:,om+1)+...
                        (tmTag_ps.^om.*S0+...
                        om.*tmTag_ps.^(om-1).*Cprime(:,0+1))./...
                        (hm.^om));
                        Wm_ps(:,3:omV(end)+1,3)=(Rm_minus_Tm_ps*Up_theta').*...
                        (Q3(:,om+1)+...
                        (tmTag_ps.^om.*S0+...
                        om.*tmTag_ps.^(om-1).*Cprime(:,0+1))./...
                        (hm.^om));
                    end
                end
                Wm(isPseudoSing,:,:)=Wm_ps;
            end

            if any(isFullInt)
                tm_fi=tm(isFullInt);
                a2PlusCm2_fi=a2PlusCm2(isFullInt);
                Rm_minus_Tm_fi=Rm_minus_Tm(isFullInt,:);
                om=0:omV(end);


                fullInt=quadv(@fullIntegrand,0,hm);%#ok<DQUADV>
                Wm_fi=zeros(size(tm_fi,1),omV(end)+1,3);
                Wm_fi(:,1:omV(end)+1,2)=-(Rm_minus_Tm_fi*Up_phi').*...
                fullInt(:,1:omV(end)+1);
                Wm_fi(:,1:omV(end)+1,3)=(Rm_minus_Tm_fi*Up_theta').*...
                fullInt(:,1:omV(end)+1);
                Wm(isFullInt,:,:)=Wm_fi;
            end


            if any(isNotNeigbor)
                tm_nnb=tm(isNotNeigbor);
                a2PlusCm2_nnb=a2PlusCm2(isNotNeigbor);
                Rm_minus_Tm_nnb=Rm_minus_Tm(isNotNeigbor,:);
                raInit=sqrt((-tm_nnb).^2+a2PlusCm2_nnb);
                raInitInv=1./raInit;
                f1Init=exp(-1j*raInit).*raInitInv;
                f2Init=-(raInitInv.^2+1j*raInitInv).*f1Init;
                raEnd=sqrt((hm-tm_nnb).^2+a2PlusCm2_nnb);
                raEndInv=1./raEnd;
                f1End=exp(-1j*raEnd).*raEndInv;
                f2End=-(raEndInv.^2+1j*raEndInv).*f1End;
                f2_delta=(f2End-f2Init);
                f2_av=(f2End+f2Init)/2;
                Wm_nnb=zeros(size(tm_nnb,1),omV(end)+1,3);
                Wm_nnb(size(tm_nnb,1),1,1)=0;
                Wm_nnb(:,1,2)=-(Rm_minus_Tm_nnb*Up_phi').*(hm*f2_av);
                Wm_nnb(:,1,3)=(Rm_minus_Tm_nnb*Up_theta').*(hm*f2_av);
                if omV(end)>=1
                    Wm_nnb(:,2,1)=0;
                    Wm_nnb(:,2,2)=-(Rm_minus_Tm_nnb*Up_phi').*...
                    (hm*f2_delta/12);
                    Wm_nnb(:,2,3)=(Rm_minus_Tm_nnb*Up_theta').*...
                    (hm*f2_delta/12);
                    if omV(end)>=2
                        Wm_nnb(:,3,1)=0;
                        Wm_nnb(:,3,2)=-(Rm_minus_Tm_nnb*Up_phi').*...
                        (hm*f2_av/12);
                        Wm_nnb(:,3,3)=(Rm_minus_Tm_nnb*Up_theta').*...
                        (hm*f2_av/12);
                        if omV(end)>=3
                            Wm_nnb(:,4,1)=0;
                            Wm_nnb(:,4,2)=-(Rm_minus_Tm_nnb*Up_phi').*...
                            (hm*f2_delta/80);
                            Wm_nnb(:,4,3)=(Rm_minus_Tm_nnb*Up_theta').*...
                            (hm*f2_delta/80);
                        end
                        Wm_nnb(:,5:omV(end)+1,:)=0;
                    end
                end
                Wm(isNotNeigbor,:,:)=Wm_nnb;
            end
            HCoeffs=-obj.WaveNumber(freq)*Wm/(4*pi);
            function y=fullIntegrand(sm)
                ra=sqrt((sm-tm_fi).^2+a2PlusCm2_fi);
                y=-(((sm-hm/2)/hm).^(om(1:end))).*(1+1j*ra).*...
                exp(-1j*ra)./(ra.^3);
            end
        end
    end

    methods(Static)
        function res=S0(hm,tm,a2PlusCm2)






            function y=integrandA(u)
                ra=sqrt(u.^2+a2PlusCm2);
                y=(((1/16)*a2PlusCm2.*(ra.^2)-1).*u)./(a2PlusCm2.*ra)+...
                ((a2PlusCm2/8-1).*log(u+ra))/2;
            end
            S0_A=integrandA(hm-tm)-integrandA(-tm);

            function y=integrandN(u)
                ra=sqrt((u-tmDelta).^2+a2PlusCm2);
                y=(1-(1+1j*ra).*exp(-1j*ra))./(ra.^3)+1./(2*ra)-ra/8;
            end
            tol=max(em.wire.solver.BasicHomMedium.absTol,...
            min(abs(S0_A))*em.wire.solver.BasicHomMedium.relTol);
            tm0=tm(1);
            tmDelta=tm-tm0;
            S0_N=quadv(@integrandN,-tm0,hm-tm0,tol);%#ok<DQUADV>

            res=S0_N+S0_A;







        end

        function res=Ci(om,hm,tm,a2PlusCm2)





            function y=integrandA(u)
                ra=sqrt(u.^2+a2PlusCm2);
                y=(((u+tm)/hm).^om).*exp(-1j*ra)./ra;
            end
            res=integrandA(hm-tm)-integrandA(-tm);

















        end

        function[resQ1,resQ2]=Q12(omV,hm,tm,Gprime,Cprime)












            nCkV=zeros(size(omV));
            resQ1=zeros(length(tm),length(omV));
            resQ2=zeros(length(tm),length(omV));
            for omInd=1:length(omV)
                om=omV(omInd);
                nCkV(1:omInd-2)=nCkV(1:omInd-2).*...
                ((om-1)./((om-1)-(0:omInd-3)));
                if omInd>1
                    nCkV(omInd-1)=1;
                    if omInd>3
                        l=omV(1:omInd-3);
                        u=(((tm).^(om-3-l))./(hm.^om)).*...
                        (Cprime(:,l+1+1)-(l+1).*Gprime(:,l+1));
                        v1=nCkV((1:omInd-3)+1);
                        v2=nCkV((1:omInd-3)+2);
                        resQ1(:,omInd)=(u*v1.').*tm;
                        resQ2(:,omInd)=u*v2.';
                    end
                end
            end
        end

        function resQ3=Q3(omV,hm,tm,Gprime,Cprime)






            nCkV=zeros(size(omV));
            resQ3=zeros(length(tm),length(omV));
            for omInd=1:length(omV)
                om=omV(omInd);
                nCkV(1:omInd-1)=nCkV(1:omInd-1).*(om./(om-(0:omInd-2)));
                if omInd>=1
                    nCkV(omInd)=1;
                    if omInd>2
                        l=omV(1:omInd-2);
                        u=(((tm).^(om-2-l))./(hm.^om)).*...
                        (Cprime(:,l+1+1)-(l+1).*Gprime(:,l+1));
                        v=nCkV((1:omInd-2)+2);
                        resQ3(:,omInd)=u*v.';
                    end
                end
            end
        end

        function res=C_prime_i(om,hm,tm,a2PlusCm2)





            function y=integrandA(u)
                ra=sqrt(u.^2+a2PlusCm2);
                y=(u.^om).*exp(-1j*ra)./ra;
            end
            res=integrandA(hm-tm)-integrandA(-tm);

















        end

        function res=GiV(omV,hm,tm,Gprime)






            nCk=zeros(size(omV));
            res=zeros(length(tm),length(omV));
            for omInd=1:length(omV)
                om=omV(omInd);
                nCk(1:omInd-1)=nCk(1:omInd-1).*(om./(om-(0:omInd-2)));
                nCk(omInd)=1;
                u=(((tm).^(omInd-1:-1:0))/(hm.^om)).*Gprime(:,1:omInd);
                v=nCk(1:omInd);
                res(:,omInd)=u*v.';
            end








        end

        function res=G_prime_i(l,hm,tm,a2PlusCm2)









            function y=integrand0A(u)
                ra=sqrt(u.^2+a2PlusCm2);
                y=(1-a2PlusCm2/4).*log(u+ra)-u.*ra/4;
            end
            G_prime0_A=integrand0A(hm-tm)-integrand0A(-tm);

            function y=integrand0N(u)
                ra=sqrt((u-tmDelta).^2+a2PlusCm2);
                y=(exp(-1j*ra)-1)./ra+ra/2;
            end
            tol=max(em.wire.solver.BasicHomMedium.absTol,...
            min(abs(G_prime0_A))*em.wire.solver.BasicHomMedium.relTol);
            tm0=tm(1);
            tmDelta=tm-tm0;
            G_prime0_N=quadv(@integrand0N,-tm0,hm-tm0,tol);%#ok<DQUADV>

            res=G_prime0_N+G_prime0_A;



            function y=removeEmpty(x,vecLen)
                if isempty(x)
                    y=zeros(vecLen,0);
                else
                    y=x{1};
                end
            end
            function y=prod_last_q_plus_1(x)
                if isempty(x)
                    y=0;
                else
                    y=x(end)*(3*a2PlusCm2/4);
                end
            end
            function y=integrandlA(u)
                ra=sqrt(u.^2+a2PlusCm2);
                y=cell2mat(cellfun(@(l,q1,prod1,q2,prod2,prod3)...
                (sum(((-1).^q1(2:end)).*u.^(l-2*q1(2:end)-1).*...
                ra.^(2*q1(2:end)+1).*prod1,2)+(-1).^(l/2).*...
                (sum((u./(l-2*q2(2:end))).*ra.^(l-2*q2(2:end)-1).*...
                prod2,2)+prod3.*(u.*ra+a2PlusCm2.*log(u+ra))/2)),...
                lCell,qCell1,prodCell1,qCell2,prodCell2,prodCell3,...
                'UniformOutput',false));
            end

            function y=integrandlN(u)
                ra=sqrt((u-tmDelta).^2+a2PlusCm2);
                y=(u-tmDelta).^l1.*(exp(-1j*ra)-1)./ra;
            end

            if length(l)>1
                l1=l(2:end);

                lCell=num2cell(l1);
                qCell1=arrayfun(@(x)[x,0:floor((x-1)/2)],l1,...
                'UniformOutput',false);
                prodCell1=cellfun(@(x)arrayfun(@(y)...
                prod((x(1)-2*(1:y)+1)./(2*(1:y)+1)),x(2:end)),qCell1,...
                'UniformOutput',false);
                lCellOeEmpty=arrayfun(@(x)(x:(x-1-2*floor((x-1)/2))*x),...
                l1,'UniformOutput',false);
                qCell2=cellfun(@(x)[x,0:(x/2-2)],lCellOeEmpty,...
                'UniformOutput',false);
                prodCell2=cellfun(@(x)removeEmpty(arrayfun(@(y)...
                prod(a2PlusCm2*(x(1)-2*(1:y)+1)./(x(1)-2*(1:y)+2),2),...
                x(2:end),'UniformOutput',false),length(a2PlusCm2)),...
                qCell2,'UniformOutput',false);
                prodCell3=cellfun(@(x)prod_last_q_plus_1(x),prodCell2,...
                'UniformOutput',false);
                if length(prodCell3)>1
                    prodCell3{2}=ones(size(a2PlusCm2));

                end
                G_primel_A=integrandlA(hm-tm)-integrandlA(-tm);
                tol=max(em.wire.solver.BasicHomMedium.absTol,...
                min(min(abs(G_primel_A)))*em.wire.solver.BasicHomMedium.relTol);
                G_primel_N=quadv(@integrandlN,-tm0,hm-tm0,tol);%#ok<DQUADV>

                res=[res,G_primel_N+G_primel_A];
            end








        end
    end
end