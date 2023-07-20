function[nstates,clkEnableSignals,outputoffsets,inprate,outprate,clkenbrates]=designTimingController(this,rawClkReqTmp)














    rawClkReq=[];


    hasConstRate=false;
    for i=1:length(rawClkReqTmp)
        current=rawClkReqTmp(i);
        if current.Rate==Inf
            hasConstRate=true;
        else
            rawClkReq=[rawClkReq,current];%#ok
        end
    end




    [up,down,offset,offsetScale,baseRate]=this.scaleRelative2SampleTime(rawClkReq);



    timingInfoMatrix.up=up;
    timingInfoMatrix.down=down;
    timingInfoMatrix.offset=offset;






    outputoffsets={};

    [clkUp,nstates,outputoffsets,inprate,outprate,clkenbrates]=this.compute_tc_params(up,down,offset,offsetScale,outputoffsets);





    clkEnableSignals=[];














