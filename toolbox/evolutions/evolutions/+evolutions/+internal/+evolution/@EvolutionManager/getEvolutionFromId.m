function evolution=getEvolutionFromId(obj,id)





    evolutions=obj.Infos;


    infoIdx=strcmp({obj.Infos.Id},id);
    evolution=evolutions(infoIdx);

end
