function outVars=arrayunion(varsin,callerClass)















    varnames=cellfun(@fieldnames,varsin,'UniformOutput',false);
    varnames=vertcat(varnames{:});

    varhandles=cellfun(@struct2cell,varsin,'UniformOutput',false);
    varhandles=vertcat(varhandles{:});


    [uniqueNames,idxUnique,idxOut]=optim.internal.problemdef.makeUniqueNames(varnames);
    uniqueHandles=varhandles(idxUnique);


    idxDuplicate=true(size(varnames));
    idxDuplicate(idxUnique)=false;
    idxDuplicate=find(idxDuplicate);


    for dupIdx=idxDuplicate'
        if uniqueHandles{idxOut(dupIdx)}~=varhandles{dupIdx}
            [startTag,endTag]=optim.internal.problemdef.createHotlinks(...
            '','ug_no_duplicate_names','normal',true);
            throwAsCaller(MException(...
            message('shared_adlib:HashMapFunctions:VariableNameClash',...
            callerClass,startTag,endTag)));
        end
    end


    outVars=cell2struct(uniqueHandles,uniqueNames,1);
