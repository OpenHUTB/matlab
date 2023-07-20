function[reqTableBlock,chartH]=create(name)



    if nargin==0
        name='';
    end

    if~slreq.modeling.isScalarText(name)
        error('Slvnv:reqmgt:specBlock:InvalidInputToCreate',...
        DAStudio.message('Slvnv:reqmgt:specBlock:InvalidInputToCreate'));
    end

    [reqTableBlock,chartH]=Stateflow.ReqTable.internal.API.createEmptySpecBlock(name);


    isUILoaded=false;
    while~isUILoaded
        pause(0.2);
        tableData=Stateflow.ReqTable.internal.TableManager.getTableData(chartH.Id);
        isUILoaded=tableData.isUILoaded;
    end


    reqTableBlock=slreq.modeling.RequirementsTable(reqTableBlock,chartH);
end
