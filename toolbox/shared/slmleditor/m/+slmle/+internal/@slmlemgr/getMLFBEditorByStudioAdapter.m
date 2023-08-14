function editor=getMLFBEditorByStudioAdapter(obj,saEd)






    editor=[];


    values=obj.MLFBEditorMap.values;
    for i=1:length(values)
        list=values{i};
        for j=1:length(list)
            mlfb=list{j};
            if mlfb.ed==saEd
                editor=mlfb;
                return;
            end
        end
    end



