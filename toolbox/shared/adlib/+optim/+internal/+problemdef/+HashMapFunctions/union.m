function outHash=union(hash1,hash2,callerClass)













    hash2Fields=fieldnames(hash2);
    if isscalar(hash2Fields)

        outHash=hash1;
        field2=hash2Fields{1};
        if~isfield(hash1,field2)

            outHash.(field2)=hash2.(field2);
        elseif hash1.(field2)~=hash2.(field2)
            [startTag,endTag]=optim.internal.problemdef.createHotlinks(...
            '','ug_no_duplicate_names','normal',true);
            throwAsCaller(MException(...
            message('shared_adlib:HashMapFunctions:VariableNameClash',...
            callerClass,startTag,endTag)));
        end
        return
    end

    fn=[fieldnames(hash1);hash2Fields];

    [uniqueNames,idxUnique]=optim.internal.problemdef.makeUniqueNames(fn);


    idxDuplicate=true(size(fn));
    idxDuplicate(idxUnique)=false;


    for n=fn(idxDuplicate)'
        if hash1.(n{1})~=hash2.(n{1})
            [startTag,endTag]=optim.internal.problemdef.createHotlinks(...
            '','ug_no_duplicate_names','normal',true);
            throwAsCaller(MException(...
            message('shared_adlib:HashMapFunctions:VariableNameClash',...
            callerClass,startTag,endTag)));
        end
    end


    vars=[struct2cell(hash1);struct2cell(hash2)];

    outHash=cell2struct(vars(idxUnique),uniqueNames,1);