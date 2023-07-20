


function rs=getResultSetObj(rs)
    if~isa(rs,'sltest.testmanager.ResultSet')
        rs=sltest.testmanager.TestResult.getResultFromID(rs);
    end
    assert(isa(rs,'sltest.testmanager.ResultSet'));
end
