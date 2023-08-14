function updateDiagram(model)










    studio=lGetStudio(model);


    if~isempty(studio)


        studio.App.updateDiagram(get_param(bdroot(model),'Handle'));
    else
        pm_error('physmod:pm_sli:sli:model:ModelNotOpen',model);
    end

end

function studio=lGetStudio(model)



    studio=[];

    e=GLUE2.Util.findAllEditors(model);
    if~isempty(e)
        studio=e(1).getStudio;
    else

        studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive();
        for idx1=1:numel(studios)
            editors=studios(idx1).App.getAllEditors();
            for idx2=1:numel(editors)
                if strcmp(bdroot(editors(idx2).getName()),model)
                    studio=studios(idx1);
                    return;
                end
            end
        end
    end

end
