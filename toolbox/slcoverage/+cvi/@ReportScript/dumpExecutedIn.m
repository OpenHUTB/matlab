function dumpExecutedIn(this,blkEntry,options)




    allmetricName=[this.metricNames,this.toMetricNames];
    allRuns=[];
    for idx=1:numel(allmetricName)
        mn=allmetricName{idx};
        if isfield(blkEntry,mn)
            cmf=blkEntry.(mn);
            if isfield(cmf,'executedIn')
                ei=split(cmf.executedIn,',');
                allRuns=[allRuns,ei];
            end
            if isfield(cmf,'totalExecutedIn')
                ei=split(cmf.totalExecutedIn,',');
                allRuns=[allRuns,ei'];
            end
            if isfield(cmf,'outcome')
                ei=split(cmf.outcome.executedIn,',');
                allRuns=[allRuns,ei'];
            end
        end
    end
    allRuns=unique(allRuns);
    printIt(this,'<table>');
    printIt(this,'<tr><td width="150"><b>%s </b></td>\n','Executed in tests: ');

    for idx=1:numel(allRuns)
        if~isempty(allRuns{idx})
            linkedRun=sprintf('<a href="">%s</a>',allRuns{idx});
            printIt(this,'<td> %s </td>\n',linkedRun);
        end
    end

    printIt(this,'</tr></table>\n');

