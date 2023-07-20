function fc_enable=dnnfpgaFccontrollerlibEnbGen(start,fc_ready,fifo_valid)
%#codegen



    coder.allowpcode('plain');

    MINPATHDELAY=14;
    persistent start_d1;
    if(isempty(start_d1))
        start_d1=false;
    end

    persistent fcInProg;
    if(isempty(fcInProg))
        fcInProg=false;
    end

    persistent fcInProgMinCnt;
    if(isempty(fcInProgMinCnt))
        fcInProgMinCnt=fi(0,0,8,0);
    end


    if(fcInProg==true)
        fc_enable=fifo_valid;
    else
        fc_enable=false;
    end

    if((start==true)&&(start_d1==false))
        fcInProg=true;
    elseif((fc_ready==true)&&(fcInProgMinCnt>=MINPATHDELAY))
        fcInProg=false;
    end



    if(fcInProgMinCnt<MINPATHDELAY)
        fcInProgMinCnt=fi(fcInProgMinCnt+1,0,8,0);
    elseif(start==true)
        fcInProgMinCnt=fi(0,0,8,0);
    end

    start_d1=start;
end
