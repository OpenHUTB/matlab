function resultSets=getResultSets(rsIDList)




    if nargin==0
        rsIDList=stm.internal.getAllResultSetID();
    end

    rsIDList=sort(rsIDList);
    resultSets=repmat(sltest.testmanager.ResultSet,length(rsIDList),1);
    for k=1:length(rsIDList)
        resultSets(k)=sltest.testmanager.ResultSet([],rsIDList(k));
    end
end
