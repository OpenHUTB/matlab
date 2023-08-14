function cleanup=compileModelForRTW(model)




    import coder.dictionary.internal.isModelCompiled;
    if~isModelCompiled(model)
        feval(model,[],[],[],'compileForRTW');
        cleanup=onCleanup(@()feval(model,[],[],[],'term'));
    else
        cleanup=[];
    end
end
