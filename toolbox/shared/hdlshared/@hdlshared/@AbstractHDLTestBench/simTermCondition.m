function MaxErrorCnt=simTermCondition(this)




    if~isempty(this.InportSrc)
        NoOfTests=length(this.InportSrc(1).timeseries);
    else
        NoOfTests=0;
    end
    if~isempty(this.OutportSnk)
        MaxErrorCnt=max(NoOfTests,length(this.OutportSnk(1).timeseries));
    else
        MaxErrorCnt=NoOfTests;
    end
end
