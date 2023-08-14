

function editors=getAllEditorsForModel(modelHandle)

    editors=[];
    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    for idx=1:numel(studios)
        st=studios(idx);
        app=st.App;
        if(~isempty(app))
            if(app.blockDiagramHandle==modelHandle)
                editors=[editors,app.getAllEditors()];
            end
        end
    end
end