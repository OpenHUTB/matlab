function storeIndexingData(visitor,forestSize,nTrees,...
    forestIndexList,treeIndexList,types,vals)




    if nTrees==0
        type=optim.internal.problemdef.ImplType.Numeric;
    elseif nTrees==1
        type=types(1);
    else

        type=optim.internal.problemdef.ImplType.typeSubsasgn(types);
    end

    if type==optim.internal.problemdef.ImplType.Numeric

        val=zeros(prod(forestSize),1);
        for i=1:nTrees

            vali=vals{i};


            forestIndex=forestIndexList{i};





            treeIndex=treeIndexList{i};

            val(forestIndex)=vali(treeIndex);
        end
        val=reshape(val,forestSize);
    else
        val=[];
    end


    push(visitor,type,val);

end
