function T=MBPowerSystemStabilizerCback(block,CB)





    T=[];

    switch CB

    case 'Mode'

        parametres=get_param(block,'MaskValues');
        p1=parametres{1};
        p13=parametres{13};
        if strcmp(p1,'Detailed settings')
            param2='off';
            param3='off';
            param4='off';
            param5='off';
            param6='on';
            param7='on';
            param8='on';
            param9='on';
            param10='on';
            param11='on';
        else
            param2='on';
            param3='on';
            param4='on';
            param5='on';
            param6='off';
            param7='off';
            param8='off';
            param9='off';
            param10='off';
            param11='off';
        end
        if strcmp(p13,'on')
            param14='on';
            param15='on';
        else
            param14='off';
            param15='off';
        end
        visible={'on',param2,param3,param4,param5,param6,param7,param8,param9,param10,param11,'on','on',param14,param15};
        set_param(block,'MaskVisibilities',visible)


    case 'Plot'
        if strcmp('on',get_param(block,'Plot_On'))

            set_param(block,'Plot_On','off');

            [OperationMode,Kg,GL,GI,GH,GLd,TcLF,GId,TcIF,GHd,TcHF,LIM,FreqRange,MagdB_On]=...
            getSPSmaskvalues(block,{'OperationMode','Kg','GL','GI','GH','GLd','TcLF','GId','TcIF','GHd','TcHF','LIM','FreqRange','MagdB_On'});

            [~,~,PSS]=MBPowerSystemStabilizerInit(block,OperationMode,Kg,GL,GI,GH,GLd,TcLF,GId,TcIF,GHd,TcHF,LIM);


            numLF1=[PSS.TL1,PSS.KL11];
            denLF1=[PSS.TL2,1];
            sysLF1=tf(numLF1,denLF1);
            numLF2=[PSS.TL3,1];
            denLF2=[PSS.TL4,1];
            sysLF2=tf(numLF2,denLF2);
            numLF3=[PSS.TL5,1];
            denLF3=[PSS.TL6,1];
            sysLF3=tf(numLF3,denLF3);
            numLF4=[PSS.TL7,PSS.KL17];
            denLF4=[PSS.TL8,1];
            sysLF4=tf(numLF4,denLF4);
            numLF5=[PSS.TL9,1];
            denLF5=[PSS.TL10,1];
            sysLF5=tf(numLF5,denLF5);
            numLF6=[PSS.TL11,1];
            denLF6=[PSS.TL12,1];
            sysLF6=tf(numLF6,denLF6);

            sysLF=PSS.Kg*PSS.KL*((PSS.KL1*sysLF1*sysLF2*sysLF3)-(PSS.KL2*sysLF4*sysLF5*sysLF6));


            numIF1=[PSS.TI1,PSS.KI11];
            denIF1=[PSS.TI2,1];
            sysIF1=tf(numIF1,denIF1);
            numIF2=[PSS.TI3,1];
            denIF2=[PSS.TI4,1];
            sysIF2=tf(numIF2,denIF2);
            numIF3=[PSS.TI5,1];
            denIF3=[PSS.TI6,1];
            sysIF3=tf(numIF3,denIF3);
            numIF4=[PSS.TI7,PSS.KI17];
            denIF4=[PSS.TI8,1];
            sysIF4=tf(numIF4,denIF4);
            numIF5=[PSS.TI9,1];
            denIF5=[PSS.TI10,1];
            sysIF5=tf(numIF5,denIF5);
            numIF6=[PSS.TI11,1];
            denIF6=[PSS.TI12,1];
            sysIF6=tf(numIF6,denIF6);

            sysIF=PSS.Kg*PSS.KI*((PSS.KI1*sysIF1*sysIF2*sysIF3)-(PSS.KI2*sysIF4*sysIF5*sysIF6));


            numHF1=[PSS.TH1,PSS.KH11];
            denHF1=[PSS.TH2,1];
            sysHF1=tf(numHF1,denHF1);
            numHF2=[PSS.TH3,1];
            denHF2=[PSS.TH4,1];
            sysHF2=tf(numHF2,denHF2);
            numHF3=[PSS.TH5,1];
            denHF3=[PSS.TH6,1];
            sysHF3=tf(numHF3,denHF3);
            numHF4=[PSS.TH7,PSS.KH17];
            denHF4=[PSS.TH8,1];
            sysHF4=tf(numHF4,denHF4);
            numHF5=[PSS.TH9,1];
            denHF5=[PSS.TH10,1];
            sysHF5=tf(numHF5,denHF5);
            numHF6=[PSS.TH11,1];
            denHF6=[PSS.TH12,1];
            sysHF6=tf(numHF6,denHF6);

            sysHF=PSS.Kg*PSS.KH*((PSS.KH1*sysHF1*sysHF2*sysHF3)-(PSS.KH2*sysHF4*sysHF5*sysHF6));


            numLIFin=[-1.759e-3,1];
            denLIFin=[1.2739e-4,1.7823e-2,1];
            sysLIFin=tf(numLIFin,denLIFin);

            numHFin=[80,0,0];
            denHFin=[1,82,161,80];
            sysHFin=tf(numHFin,denHFin);


            sysL=sysLIFin*sysLF;
            sysI=sysLIFin*sysIF;
            sysH=sysHFin*sysHF;
            sysG=sysL+sysI+sysH;


            w=2*pi*FreqRange;
            [MagL,PhaseL]=bode(sysL,w);
            [MagI,PhaseI]=bode(sysI,w);
            [MagH,PhaseH]=bode(sysH,w);
            [MagG,PhaseG]=bode(sysG,w);
            subplot(2,1,1)
            if MagdB_On==1
                YL=20*log10(squeeze(MagL));
                YI=20*log10(squeeze(MagI));
                YH=20*log10(squeeze(MagH));
                YG=20*log10(squeeze(MagG));
                strLabel='dB';
            else
                YL=squeeze(MagL);
                YI=squeeze(MagI);
                YH=squeeze(MagH);
                YG=squeeze(MagG);
                strLabel='pu/pu';
            end

            semilogx(FreqRange,YL,'m',FreqRange,YI,'g',FreqRange,YH,'b',FreqRange,YG,'r')
            ylabel(strLabel);grid;
            legend('LF band','IF band','HF band','Global','Location','NorthWest');
            title('MB-PSS Frequency Response');
            subplot(2,1,2);
            semilogx(FreqRange,rem(squeeze(PhaseL),360),'m',FreqRange,rem(squeeze(PhaseI),360),'g',FreqRange,rem(squeeze(PhaseH),360),'b',FreqRange,rem(squeeze(PhaseG),360),'r');
            ylabel('Degrees');grid;
            xlabel('Frequency (Hz)');

        end
    end