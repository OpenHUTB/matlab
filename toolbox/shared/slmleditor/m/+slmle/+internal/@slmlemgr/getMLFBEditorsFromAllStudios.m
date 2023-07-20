function editors=getMLFBEditorsFromAllStudios(obj,objectId)




    editors={};


    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    if isempty(studios)
        return;
    end


    if obj.MLFBEditorMap.isKey(objectId)
        list=obj.MLFBEditorMap(objectId);
        editors=cell(1,length(list));
        for i=1:length(list)
            mlfbEd=list{i};
            for j=1:length(studios)
                studio=studios(j);
                if studio.isStudioVisible&&...
                    mlfbEd.studio==studio
                    editors{i}=mlfbEd;
                end
            end
        end
        editors=editors(cellfun(@(x)~isempty(x),editors));
    end



