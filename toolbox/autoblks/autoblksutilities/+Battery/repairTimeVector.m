function t=repairTimeVector(t,MinDeltaT,MaxDeltaT)










































    if nargin<2
        MinDeltaT=0.1;
    end
    if nargin<3
        MaxDeltaT=360;
    end


    if any(t<0)
        error(getString(message('autoblks:autoblkErrorMsg:errNegT')));
    end



    smallDTIdx=find(diff(t)<MinDeltaT);
    largeDTIdx=find(diff(t)>MaxDeltaT);




    for idx=1:numel(smallDTIdx)


        tIdx1=smallDTIdx(idx);


        if idx<numel(smallDTIdx)
            tIdx2=smallDTIdx(idx+1);
        else
            tIdx2=numel(t);
        end



        t(tIdx1+1:tIdx2)=t(tIdx1)+(t(tIdx1+1:tIdx2)-t(tIdx1+1))+MinDeltaT;

    end




    for idx=1:numel(largeDTIdx)


        tIdx1=largeDTIdx(idx);


        if idx<numel(largeDTIdx)
            tIdx2=largeDTIdx(idx+1);
        else
            tIdx2=numel(t);
        end



        t(tIdx1+1:tIdx2)=t(tIdx1)+(t(tIdx1+1:tIdx2)-t(tIdx1+1))+MaxDeltaT;

    end



    for idx=2:numel(t);
        if t(idx)-t(idx-1)<MinDeltaT
            t(idx)=t(idx-1)+MinDeltaT;
        end
    end


    t=t-t(1);
