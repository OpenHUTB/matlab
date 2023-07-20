function preMdlContinueCallback(this,repo,evt)






    thisMdl=repo.getRunModel(this.RunID);
    if strcmp(thisMdl,evt.modelName)
        fullyLoadCache(this);
    end
end