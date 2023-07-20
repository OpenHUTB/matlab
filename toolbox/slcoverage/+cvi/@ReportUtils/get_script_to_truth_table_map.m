function item=get_script_to_truth_table_map(map,line)




    len=size(map,1);
    sectionIdx=0;
    item=[];

    for i=1:len
        startLineNo=map{i,1};
        if line>=startLineNo
            sectionIdx=sectionIdx+1;
        else
            break;
        end
    end

    if sectionIdx>0
        item=map{sectionIdx,2};
    end

    return;
