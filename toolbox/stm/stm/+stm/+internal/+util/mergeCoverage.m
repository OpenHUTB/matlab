function resultID=mergeCoverage(arrayOfResultIDs)




    res=int32(arrayOfResultIDs);


    count=nnz(arrayfun(@(id)stm.internal.hasCoverageResults(id),res));

    if count<2
        error(message('stm:CoverageStrings:MergeCoverageError'));
    end

    covString=message('stm:CoverageStrings:MergedCoverageResult',datestr(now)).getString();
    resultID=stm.internal.createResultSet(covString);
    try
        stm.internal.mergeCoverage(res,resultID)
    catch me
        stm.internal.deleteResult(resultID,'resultset');
        rethrow(me);
    end
end
