function idxs=findSignals(signals,bpath,portIdx)






    idxs=[];
    for curIdx=1:length(signals)

        if signals(curIdx).outputPortIndex_==portIdx

            if signals(curIdx).blockPath_.pathIsLike(bpath)
                idxs(end+1)=curIdx;%#ok<AGROW>
            end
        end
    end

end
