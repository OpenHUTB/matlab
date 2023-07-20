function index=checkValidSubsrefIndex(index,pos,Nindex,exprSize,indexNames)




































    exprSize=[exprSize,ones(1,Nindex-numel(exprSize))];

    if(Nindex==1)




        if isnumeric(index)
            checkIsValidNumericIndex(index,prod(exprSize),pos);

        elseif islogical(index)
            checkIsValidLogicalIndex(index,prod(exprSize),pos);

        elseif~(ischar(index)||iscellstr(index)||isstring(index))

            throwAsCaller(MException(message('shared_adlib:operators:BadSubscript')));

        elseif numel(index)==1&&strcmp(index,':')


        else
            [~,index]=...
            getSubsrefLinearStringOutputs(index,exprSize,indexNames);
        end

    elseif(Nindex==numel(exprSize))

        index=optim.internal.problemdef.indexing.checkValidSubsrefIndex(...
        index,pos,1,[exprSize(pos),1],{indexNames(pos),{}});

    else
        throwAsCaller(MException(message('shared_adlib:operators:InvalidIdx')));
    end

end
