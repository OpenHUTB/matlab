

function tfNames=updateTestFileFilters(rsID)
    rs=sltest.testmanager.TestResult.getResultFromID(rsID);
    tf=rs.updateTestFileFilters;
    if isempty(tf)
        tfNames={};
    else
        tfNames={tf.Name};
    end
end
