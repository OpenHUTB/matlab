function prm=buildBlockParams(this,hC)














    bfp=hC.SimulinkHandle;

    switch(this.Blocks{1})
    case 'commdigbbndpm3/BPSK Demodulator Baseband'
        prm=buildPSKparams(this,bfp,hC,2);
    case 'commdigbbndpm3/QPSK Demodulator Baseband'
        prm=buildPSKparams(this,bfp,hC,4);
    case 'commdigbbndpm3/M-PSK Demodulator Baseband'
        prm=buildPSKparams(this,bfp,hC,this.hdlslResolve('M',bfp));

        if isfield(prm,'sinInitPhase')&&~isfield(prm,'sin3Pi8Phase')

            if((abs(prm.phaseOffset-(pi/8)))>abs(prm.phaseOffset-(3*pi/8)))

                prm.isPi8=false;
            else
                prm.isPi8=true;
            end
        end



    end

end


function prm=buildPSKparams(this,bfp,hC,M)




    rto=get_param(bfp,'RunTimeObject');
    num_rtp=rto.NumRuntimePrms;


    prm=struct;
    prm.M=M;
    prm.phaseOffset=this.hdlslResolve('Ph',bfp);



    prm.phaseOffset=mod((prm.phaseOffset),2*pi);








    for ii=1:num_rtp
        if~isempty(rto.RuntimePrm(ii))
            prm.(rto.RuntimePrm(ii).Name)=rto.RuntimePrm(ii).Data;
        end
    end







    if~isfield(prm,'sinInitPhase')

        switch(prm.M)
        case 2
            binedges=[-1,1,3,5,7]*(pi/4);
        case 4
            binedges=[0,1,2,3,4]*(pi/2);
        case 8
            binedges=(0:8)*(pi/4);
        end
        prm.phaseBins=histc(prm.phaseOffset,binedges);
        prm.phaseBins(end)=[];
    end

    if M>2
        prm.isGrayCoded=strcmpi(get_param(bfp,'Dec'),'Gray');
    end




end


