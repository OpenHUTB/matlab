function saturationOverflows=saturationOverflows(this,runName)













    this.assertDEValid();

    saturationOverflows=this.results(runName,@(r)~isempty(r.Saturations));
end