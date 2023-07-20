function T=PowerSystemStabilizerCback(block)





    T=[];


    parametres=get_param(block,'MaskValues');
    p8=parametres{8};
    if strcmp(p8,'on');
        param9='on';
        param10='on';
    else
        param9='off';
        param10='off';
    end
    visible={'on','on','on','on','on','on','on','on',param9,param10};
    set_param(block,'MaskVisibilities',visible);


    if strcmp('on',get_param(block,'Plot_On'))

        [Tsensor,K,Twashout,Tleadlag1,Tleadlag2,VSlimits,Vinit,FreqRange]=...
        getSPSmaskvalues(block,{'Tsensor','K','Twashout','Tleadlag1','Tleadlag2','VSlimits','Vinit','FreqRange'});

        T1n=Tleadlag1(1);
        T1d=Tleadlag1(2);
        T2n=Tleadlag2(1);
        T2d=Tleadlag2(2);

        numS=1;
        denS=[Tsensor,1];
        sysS=tf(numS,denS);
        numW=[Twashout,0];
        denW=[Twashout,1];
        sysW=tf(numW,denW);
        numL1=[T1n,1];
        denL1=[T1d,1];
        sysL1=tf(numL1,denL1);
        numL2=[T2n,1];
        denL2=[T2d,1];
        sysL2=tf(numL2,denL2);
        sysG=sysS*K*sysW*sysL1*sysL2;


        w=2*pi*FreqRange;
        [Mag,Pha]=bode(sysG,w);
        subplot(2,1,1)
        if strcmp('on',get_param(block,'MagdB_On'))
            Y=20*log10(squeeze(Mag));
            strLabel='dB';
        else
            Y=squeeze(Mag);
            strLabel='pu/pu';
        end

        semilogx(FreqRange,Y)
        ylabel(strLabel);grid;
        title('PSS Frequency Response');
        subplot(2,1,2);
        semilogx(FreqRange,rem(squeeze(Pha),360))
        ylabel('Degrees');grid;
        xlabel('Frequency (Hz)');
        set_param(block,'Plot_On','off')
    end