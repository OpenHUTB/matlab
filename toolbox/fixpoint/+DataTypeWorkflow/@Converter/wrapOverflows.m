function wrapOverflows=wrapOverflows(this,runName)













    this.assertDEValid();

    wrapOverflows=this.results(runName,@(r)~isempty(r.Wraps));
end