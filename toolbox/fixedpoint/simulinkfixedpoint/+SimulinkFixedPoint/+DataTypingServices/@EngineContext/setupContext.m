function setupContext(this)







    for modelIndex=1:length(this.topModelModelReferences)
        load_system(this.topModelModelReferences{modelIndex});
    end
end