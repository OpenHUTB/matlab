function[data,timeStamp]=transformedStatistics(mdl)





    rawStats=simscape.internal.statistics.sli.getStatistic(...
    getfullname(mdl));
    xf=simscape.statistics.data.internal.Transformer(rawStats);
    p=xf.Paths(xf.hasData(xf.Paths));
    stats=xf.transform(p);
    timeStamp=string(missing);
    if~isempty(rawStats)&&isstruct(rawStats)&&isfield(rawStats,'Timestamp')
        timeStamp=rawStats.Timestamp;
    end


    data=struct('Path',cellstr(p),'Statistic',num2cell(stats));

end