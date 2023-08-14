

function activeEditor=getLastActiveEditor()

    activeEditor=[];
    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    if(~isempty(studios))
        studio=studios(1);
        studioApp=studio.App;
        activeEditor=studioApp.getActiveEditor;
    end
end