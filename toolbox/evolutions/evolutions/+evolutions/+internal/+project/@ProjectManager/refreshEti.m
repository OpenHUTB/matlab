function refreshEti(obj,eti)






    for piIdx=1:numel(obj.Infos)

        curEtm=obj.Infos(piIdx).EvolutionTreeManager;
        if ismember(eti,curEtm.Infos)
            break;
        end
    end

    curEtm.refreshEti(eti);


