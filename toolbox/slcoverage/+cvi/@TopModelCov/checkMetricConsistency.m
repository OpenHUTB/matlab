function res=checkMetricConsistency(newRoot,oldRoot,changeBoth)




    try

        if nargin<3
            changeBoth=false;
        end
        res=checkTableChecksum(oldRoot,newRoot,changeBoth);
    catch MEx
        rethrow(MEx);
    end

    function res=checkTableChecksum(oldRoot,newRoot,changeBoth)
        res=false;
        if isequal(cv('get',oldRoot,'.metricChecksum.table'),...
            cv('get',newRoot,'.metricChecksum.table'))
            return;
        end
        res=true;
        topSlsfOld=cv('get',oldRoot,'.topSlsf');
        topSlsfNew=cv('get',newRoot,'.topSlsf');

        descsOld=cv('DecendentsOf',topSlsfOld);
        descsNew=cv('DecendentsOf',topSlsfNew);
        metricEnum=cvi.MetricRegistry.getEnum('tableExec');
        for idx=1:numel(descsOld)
            blockCvId=descsOld(idx);
            tableOld=cv('MetricGet',blockCvId,metricEnum,'.baseObjs');
            if~isempty(tableOld)
                breakPtValuesOld=cv('get',tableOld,'table.breakPtValues');
                tableNew=cv('MetricGet',descsNew(idx),metricEnum,'.baseObjs');
                breakPtValuesNew=cv('get',tableNew,'table.breakPtValues');
                if~isequalwithequalnans(breakPtValuesOld,breakPtValuesNew)%#ok<DISEQN>
                    diffBrkPtValues=breakPtValuesOld(breakPtValuesOld~=breakPtValuesNew);

                    signs=sign(diffBrkPtValues);

                    signs(signs==0)=1;
                    breakPtValuesOld(breakPtValuesOld~=breakPtValuesNew)=signs*Inf;
                    cv('set',tableOld,'table.breakPtValues',breakPtValuesOld);
                    if changeBoth
                        cv('set',tableNew,'table.breakPtValues',breakPtValuesOld);
                    end
                end
            end
        end
