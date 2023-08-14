function updateExistingFigures(hFigs)






    for i=1:length(hFigs)
        if stm.internal.artifacts.getMode(hFigs(i))=="add"

            mode=0;
        else


            mode=-1;
        end

        stm.internal.overwriteOldFigures(hFigs(i).double,hFigs(i),mode);
    end
end
