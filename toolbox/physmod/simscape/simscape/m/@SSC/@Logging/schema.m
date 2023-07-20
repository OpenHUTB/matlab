function schema







    mlock;

    pkg=findpackage('SSC');
    c=schema.class(pkg,'Logging');


    dt=findtype('SSC_LOGGING_OPTIONS');
    if isempty(dt)
        schema.EnumType('SSC_LOGGING_OPTIONS',{'none','all','local'});
    end


    m=schema.method(c,'getCCPropertyList','static');
    s=m.signature;
    s.Varargin='off';
    s.InputTypes={};
    s.OutputTypes={'MATLAB array'};

    m=schema.method(c,'logTypePostSet','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','mxArray','mxArray','mxArray'};
    s.OutputTypes={};

    m=schema.method(c,'isLogNameEnabled','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','mxArray'};
    s.OutputTypes={'bool'};

    m=schema.method(c,'validateLogName','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','string'};
    s.OutputTypes={'string'};

    m=schema.method(c,'logLimitPostSet','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','mxArray','mxArray','mxArray'};
    s.OutputTypes={};

    m=schema.method(c,'isLogDataHistoryEnabled','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','mxArray'};
    s.OutputTypes={'bool'};

    m=schema.method(c,'validateLogDataHistory','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','double'};
    s.OutputTypes={'double'};

    m=schema.method(c,'validateLogDecimation','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','double'};
    s.OutputTypes={'double'};


end

