function isOverlap=isVarSizeOverlap(typeSet)










    hasSizeInfo=all(cellfun(@(x)(isprop(x,'SizeVector')),typeSet,'UniformOutput',true));

    if~hasSizeInfo
        isOverlap=false;
        return;
    end

    vardimflag=any(cellfun(@(x)any(x.VariableDims),typeSet,'UniformOutput',true));
    sizelength=cellfun(@(x)length(x.SizeVector),typeSet,'UniformOutput',false);
    isequalsizelength=isequal(sizelength{:});


    if(~vardimflag)||(~isequalsizelength)
        isOverlap=false;
        return
    end


    dimLen=length(typeSet{1}.SizeVector);
    nEle=length(typeSet);

    pairwiseOverlap=false(nEle,nEle);
    for firstEleIdx=1:nEle-1
        for secondEleIdx=firstEleIdx+1:nEle
            isOverlapDim=false(dimLen,1);
            for dimIdx=1:dimLen
                firstSize=typeSet{firstEleIdx}.SizeVector(dimIdx);
                secondSize=typeSet{secondEleIdx}.SizeVector(dimIdx);
                firstVarflag=typeSet{firstEleIdx}.VariableDims(dimIdx);
                secondVarflag=typeSet{secondEleIdx}.VariableDims(dimIdx);

                if(firstSize==secondSize)
                    isOverlapDim(dimIdx)=true;

                elseif(firstVarflag==1)&&(secondVarflag==1)
                    isOverlapDim(dimIdx)=true;


                elseif(firstVarflag==1)&&(secondSize<=firstSize)
                    isOverlapDim(dimIdx)=true;

                elseif(secondVarflag==1)&&(firstSize<=secondSize)
                    isOverlapDim(dimIdx)=true;
                end

            end
            pairwiseOverlap(firstEleIdx,secondEleIdx)=all(isOverlapDim);
        end
    end

    isOverlap=any(pairwiseOverlap(:));

end
