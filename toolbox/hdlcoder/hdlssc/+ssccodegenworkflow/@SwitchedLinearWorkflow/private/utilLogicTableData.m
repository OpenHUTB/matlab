function[logicTableInput,logicTableOutput]=utilLogicTableData(mode,indexVector)

    logicTableInput=utilLogicTableInput(mode);
    logicTableOutput=utilLogicTableOutput(indexVector);
end


function inputTable=utilLogicTableInput(mode)

    inputTable=false(size(mode,3),size(mode,1));
    for i=1:size(mode,3)
        inputTable(i,:)=logical(mode(:,:,i)');
    end
end


function outputTable=utilLogicTableOutput(indexVector)


    if(max(indexVector)==1)
        columnSize=1;
    else


        columnSize=ceil(log2(max(indexVector)));
    end
    outputTable=false(size(indexVector,1),columnSize);
    indexVector=indexVector-1;
    for i=1:size(indexVector,1)
        outputTable(i,:)=logical(bitget(indexVector(i),columnSize:-1:1));
    end
end