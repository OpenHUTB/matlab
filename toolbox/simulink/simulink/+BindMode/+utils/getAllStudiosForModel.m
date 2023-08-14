

function studios=getAllStudiosForModel(modelHandle)

    studios=[];
    allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    for idx=1:numel(allStudios)
        st=allStudios(idx);
        app=st.App;
        if(~isempty(app))
            if(app.blockDiagramHandle==modelHandle)
                studios=[studios,allStudios(idx)];
            end
        end
    end
end