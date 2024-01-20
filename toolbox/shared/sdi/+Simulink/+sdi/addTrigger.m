function addTrigger(sig,varargin)

    if isscalar(sig)&&isa(sig,'Simulink.sdi.Signal')
        sig=sig.ID;
    end
    validateattributes(sig,{'numeric'},{'scalar','>=',0});

    p=inputParser;
    p.addParameter('Mode','Auto');
    p.addParameter('Position',0.5);
    p.addParameter('Delay',0);
    p.addParameter('SourceChannelComplexity','Scalar');
    p.addParameter('Type','Edge');
    p.addParameter('Polarity','Positive');
    p.addParameter('AutoLevel',true);
    p.addParameter('Level',0);
    p.addParameter('Hysteresis',0);
    p.addParameter('UpperLevel',0);
    p.addParameter('LowerLevel',0);
    p.addParameter('MinTime',0);
    p.addParameter('MaxTime',Inf);
    p.addParameter('Timeout',0);
    p.addParameter('Holdoff',0);

    try
        p.parse(varargin{:});
        t=locCreateController(p.Results);
        Simulink.sdi.addTriggerImpl('sdi',sig,t);
    catch me
        me.throwAsCaller();
    end
end


function t=locCreateController(params)
    t=scopesutil.TimeDomainTriggerController;
    fnames=fieldnames(params);
    for idx=1:length(fnames)
        t.(fnames{idx})=params.(fnames{idx});
    end
end
