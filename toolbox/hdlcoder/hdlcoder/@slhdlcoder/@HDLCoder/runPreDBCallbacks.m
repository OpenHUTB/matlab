function runPreDBCallbacks(this)



    fcns=registerPreDBCallbacks(this,'get');
    for i=1:length(fcns)
        [~,cols]=size(fcns{i});
        feval(fcns{i}{1},fcns{i}{2:cols})
    end

end

