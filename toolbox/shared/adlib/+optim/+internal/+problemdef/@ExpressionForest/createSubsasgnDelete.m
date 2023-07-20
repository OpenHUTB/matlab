function createSubsasgnDelete(obj,exprLHS,linIdx,outSize)













    if isempty(linIdx)

        copy(obj,exprLHS);
        obj.Size=outSize;
        return;
    else

        inNelem=numel(exprLHS);

        keepIdx=true(inNelem,1);
        keepIdx(linIdx)=false;
        if~any(keepIdx)


            createZeros(obj,outSize);
        else

            copy(obj,exprLHS);



            SubsasgnDeleteIdx(obj,linIdx);
            obj.Size=outSize;



            if prod(outSize)<inNelem
                forestIndexList=obj.ForestIndexList;


                newIdx=cumsum(keepIdx);

                for i=1:obj.NumTrees
                    idx=newIdx(forestIndexList{i});
                    forestIndexList{i}=idx;
                end
                obj.ForestIndexList=forestIndexList;
            end
        end
    end

end