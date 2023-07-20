




function descrMap=buildMap(descrMap,descrTable,keyIdx)


    s=size(descrTable);
    for idx=1:s(1)
        key=strrep(descrTable{idx,keyIdx},' ','_');
        descrMap.(key)=descrTable(idx,:);
    end