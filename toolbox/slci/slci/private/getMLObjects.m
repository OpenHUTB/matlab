



function objs=getMLObjects(modelObj,objectID)

    objs={};

    switch objectID

    case 'MLData'

        charts=modelObj.getEMCharts();
        for k=1:numel(charts)
            objs=[objs,charts{k}.getData()];%#ok<AGROW>
        end

    case 'MLAst'

        charts=modelObj.getEMCharts();
        for k=1:numel(charts)
            chart=charts{k};
            funcAsts=chart.getAllFuncs();
            funcNodes=values(funcAsts);
            for p=1:numel(funcNodes)
                ast=funcNodes{p};
                numAst=getNumAst(ast,0);
                [asts,~]=getAllAst(ast,cell(1,numAst),0);
                objs=[objs,asts];%#ok<AGROW>
            end
        end

    otherwise

        assert(false,['Unknown object ID ',objectID]);
    end

end


function numAst=getNumAst(ast,numAst)
    assert(isa(ast,'slci.ast.SFAst'));
    ch=ast.getChildren();
    for k=1:numel(ch)
        numAst=getNumAst(ch{k},numAst);
    end
    numAst=numAst+1;
end


function[asts,idx]=getAllAst(ast,asts,idx)
    assert(isa(ast,'slci.ast.SFAst'));
    assert(iscell(asts));
    ch=ast.getChildren();
    for k=1:numel(ch)
        [asts,idx]=getAllAst(ch{k},asts,idx);
    end
    idx=idx+1;
    asts{idx}=ast;
end
