function variables=getAllVariablesInExpresssion(expression)


    startIdxs=regexp(expression,'[a-zA-Z](\w*)');

    dotIdxs=regexp(expression,'\.')+1;
    startIdxs=setdiff(startIdxs,dotIdxs);


    snwidx=regexp(expression,'\W');

    numVars=length(startIdxs);

    endIdxs=zeros(1,numVars);
    variables=cell(1,numVars);
    for i=1:numVars
        tmp=find(snwidx>startIdxs(i),1);
        if isempty(tmp)
            endIdxs(i)=length(expression);
        else
            endIdxs(i)=snwidx(tmp)-1;
        end
        variables{i}=expression(startIdxs(i):endIdxs(i));
    end
end