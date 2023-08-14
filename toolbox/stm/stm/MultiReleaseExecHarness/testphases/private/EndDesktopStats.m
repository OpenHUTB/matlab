



function result=EndDesktopStats
    result=[];
    if 0


        result.endClock=clock;
        result.memory=GetDesktopMemStats;
        result.numWarnings=WarningCount;


        result.mexheap=IMTPerfTracerMemStats();
    end

