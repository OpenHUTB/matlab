function[funcName,inData,outData]=parse_ml_fun(funcLabel)

    funcLabel=regexprep(funcLabel,'^\s+','','once');
    funcLabel=simscape.compiler.mli.internal.filter_out_line_cont(funcLabel);

    newLineLoc=find(funcLabel==10);
    if(~isempty(newLineLoc))
        funcLabel=funcLabel(1:newLineLoc);
    end

    equalLoc=find(funcLabel=='=');
    if(isempty(equalLoc))
        lhsStrCells=[];
        rhsStrCells=regexp(funcLabel,'~|[_a-zA-Z]\w*','match');
    else
        lhsStrCells=regexp(funcLabel(1:equalLoc),'[_a-zA-Z]\w*','match');
        rhsStrCells=regexp(funcLabel(equalLoc:end),'~|[_a-zA-Z]\w*','match');
    end

    funcName='';
    inData=[];
    outData=[];

    switch(length(lhsStrCells))
    case 0

    otherwise

        outData=lhsStrCells;
    end

    switch(length(rhsStrCells))
    case 0

    case 1
        funcName=rhsStrCells(1);
        funcName=funcName{1};
    otherwise
        funcName=rhsStrCells(1);
        funcName=funcName{1};
        inData=rhsStrCells(2:end);
    end
end
