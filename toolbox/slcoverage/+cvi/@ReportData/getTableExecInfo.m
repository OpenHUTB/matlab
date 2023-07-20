function cvstruct=getTableExecInfo(this,cvstruct,tables,options)




    tableExecData=this.metricData.tableExec;

    tableCnt=length(tables);
    testCnt=length(cvstruct.tests);
    if testCnt==1
        coumnCnt=1;
    else
        coumnCnt=testCnt+1;
    end


    if options.cumulativeReport
        coumnCnt=testCnt;
    end


    cvstruct.tables=struct('cvId',num2cell(tables),...
    'dimSizes',cell(1,tableCnt),...
    'breakPtValues',cell(1,tableCnt),...
    'covered',cell(1,tableCnt),...
    'testData',cell(1,tableCnt));

    for i=1:tableCnt
        tableId=tables(i);
        isJustified=cv('get',cv('get',tableId,'.slsfobj'),'.isJustified');
        [cvstruct.tables(i).breakPtValues,cvstruct.tables(i).dimSizes]=...
        cv('get',tableId,'.breakPtValues','.dimBrkSizes');


        for testIdx=1:coumnCnt
            [~,execCnt,brkEq,executedIn]=tableinfo(tableExecData.dataObjs{testIdx},cv('get',cv('get',tableId,'.slsfobj'),'.handle'));
            cvstruct.tables(i).testData(testIdx).execCnt=execCnt;
            cvstruct.tables(i).testData(testIdx).breakPtEquality=cat(1,brkEq{:});
            cvstruct.tables(i).testData(testIdx).executedIn=convertTrace(executedIn);


        end


        cvstruct.tables(i).covered=all(cvstruct.tables(i).testData(end).execCnt);
        cvstruct.tables(i).isJustified=false;
        if isJustified
            cvstruct.tables(i).isJustified=~cvstruct.tables(i).covered;
        end



    end
end

function executedIn=convertTrace(executedIn)
    for idx=1:numel(executedIn)
        if isempty(executedIn{idx})
            executedIn(idx)={''};
        else
            executedIn(idx)=join({executedIn{idx}.traceLabel},',');
        end
    end
end

