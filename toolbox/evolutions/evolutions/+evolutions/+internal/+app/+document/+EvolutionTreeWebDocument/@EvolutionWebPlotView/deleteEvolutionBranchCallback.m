function deleteEvolutionBranchCallback(this,src,~)




    evtdata=evolutions.internal.ui.GenericEventData(src.Parent.UserData);
    notify(this,'DeleteEvolutionBranch',evtdata);
end
