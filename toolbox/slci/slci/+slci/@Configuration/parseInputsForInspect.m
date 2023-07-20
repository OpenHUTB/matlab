function parseInputsForInspect(aObj,varargin)





    p=inputParser;
    p.addParamValue('DisplayResults',aObj.getDefaultDisplayResults());
    p.parse(varargin{:});


    res=p.Results;
    aObj.setDisplayResults(res.DisplayResults);

end
