function dpstring=convDALutPart2String(this,dalut)






    dpstring='[';


    for ph=1:size(dalut,1)
        dpstr=convSerialPart2String(this,dalut(ph,:));

        dpstr=strrep(dpstr,'[','');
        dpstr=strrep(dpstr,']','');
        dpstring=[dpstring,dpstr];
        if ph<size(dalut,1)
            dpstring=[dpstring,'; '];
        else
            dpstring=[dpstring,']'];
        end
    end


