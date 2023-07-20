function saveData(obj)





    objEqnData='obj.EqnData';

    fModechart=matlab.internal.feature("SSC2HDLModechart");


    if(fModechart)
        fieldstoSave={'.IC.X','.IM','.IC.Q','.IC.CI'};
    else
        fieldstoSave={'.IC','.IM'};
    end
    for strctfield=fieldstoSave
        eval(strcat(obj.DataName,strctfield{1},'=',objEqnData,strctfield{1},';'));
    end


    if~isempty(obj.EqnData.DiffClumpInfo)
        for assignfield=fields(obj.EqnName.DiffClumpInfo)
            eval(strcat(obj.DataName,'.DiffClumpInfo.',assignfield{1},' = obj.EqnData.DiffClumpInfo.',assignfield{1},';'));
        end
    end


    if~isempty(obj.EqnData.ClumpInfo)
        for i=1:numel(obj.EqnData.ClumpInfo)
            clumpFields=fields(obj.EqnName.ClumpInfo(i));
            for j=1:numel(clumpFields)
                assignfield=strcat(clumpFields(j));
                eval(strcat(obj.DataName,'.ClumpInfo(',num2str(i),').',assignfield{1},'= obj.EqnData.ClumpInfo(',num2str(i),').',assignfield{1},';'));
            end
        end
    end



    save(strcat(obj.DataName,'.mat'),obj.DataName);



end


