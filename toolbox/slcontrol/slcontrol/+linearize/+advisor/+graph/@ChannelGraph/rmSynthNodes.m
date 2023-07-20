function this=rmSynthNodes(this)

    import linearize.advisor.graph.*


    nodes=this.Nodes;
    synthIdx=find(logical([nodes.IsSynth]));
    for sidx=synthIdx

        pred=predecessors(this,sidx);

        suc=successors(this,sidx);

        this.Adj(suc,pred)=true;
    end

    this=rmNodes(this,synthIdx);
