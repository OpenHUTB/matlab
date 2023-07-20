function res=parseInteractionInputs(varargin)




    p=inputParser;
    p.StructExpand=false;
    p.addParameter('Dimensions',"xyz");
    p.parse(varargin{:});

    res=p.Results;
