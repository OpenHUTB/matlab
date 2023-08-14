function cgirComp=getCompareToValueComp(hN,hSignalsIn,hSignalsOut,opName,constVal,compName,isConstZero,nfpOptions)






    if(nargin<8)
        nfpOptions.Latency=int8(0);
        nfpOptions.MantMul=int8(0);
        nfpOptions.Denormals=int8(0);
    end

    if(nargin<7)
        isConstZero=false;
    end

    if(nargin<6)
        compName='compare';
    end

    if targetmapping.mode(hSignalsIn)

        cgirComp=targetmapping.getCompareToValueComp(hN,hSignalsIn,hSignalsOut,opName,constVal,compName,nfpOptions);
    else
        cgirComp=pircore.getCompareToValueComp(hN,hSignalsIn,hSignalsOut,opName,constVal,compName,isConstZero);
    end
end


