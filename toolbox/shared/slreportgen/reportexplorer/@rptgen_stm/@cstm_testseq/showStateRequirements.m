function showStateRequirements(this,d,sect,state)





    elem=createElement(d,'emphasis',...
    getString(message('RptgenSL:rstm_cstm_testseq:stepRequirements')));
    para=createElement(d,'para',elem);
    appendChild(sect,para);


    try
        elem=createRequirementsTable(this,d,state);
    catch ME %#ok<NASGU>
        elem=createElement(d,'para',getString(message('RptgenSL:rstm_cstm_testseq:errorShowingReqLinks')));
    end
    appendChild(sect,elem);

end


function result=createRequirementsTable(this,d,state)

    reqs=cell2mat(getStateRequirements(this,state));


    details_level=RptgenRMI.option('detailsLevel');
    reqTable=RptgenRMI.reqsToTable(reqs,d,true,...
    true,true,true,...
    RptgenRMI.option('includeTags'),details_level,false,[]);

    numCols=size(reqTable,2);


    tm=makeNodeTable(d,reqTable,0,true);
    if numCols==3
        if details_level>0
            tm.setColWidths([1,13,7]);
        else
            tm.setColWidths([1,10,10]);
        end
    else
        tm.setColWidths([1,20]);
    end
    tm.setBorder(true);
    tm.setPageWide(true);
    tm.setNumHeadRows(0);
    tm.setNumFootRows(0);
    result=tm.createTable;
end