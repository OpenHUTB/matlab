function list=getconceptualarglist(this)



    if isempty(this.object.ConceptualArgs)
        list={''};
        return;
    end

    for id=1:length(this.object.ConceptualArgs)
        list{id}=this.object.ConceptualArgs(id).Name;%#ok
    end