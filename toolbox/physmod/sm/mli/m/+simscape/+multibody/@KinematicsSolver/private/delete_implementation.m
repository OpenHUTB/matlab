function delete_implementation(ksObj)




    if(~isempty(ksObj.mSystem))
        closeViewer(ksObj.mSystem);
    end
