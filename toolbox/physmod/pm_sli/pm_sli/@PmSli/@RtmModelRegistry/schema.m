function schema






    mlock;

    pkg=findpackage('PmSli');
    c=schema.class(pkg,'RtmModelRegistry');

    p=schema.prop(c,'modelInfo','mxArray');

    m=schema.method(c,'registerModel');
    s=m.signature;
    s.Varargin='off';
    s.InputTypes={'handle',...
'mxArray'...
    };
    s.OutputTypes={};

    m=schema.method(c,'isModelRegistered');
    s=m.signature;
    s.Varargin='off';
    s.InputTypes={'handle',...
'mxArray'...
    };
    s.OutputTypes={'bool'};


    m=schema.method(c,'storeBlockData');
    s=m.signature;
    s.Varargin='on';
    s.InputTypes={'handle',...
    'mxArray',...
    'mxArray',...
'mxArray'...
    };
    s.OutputTypes={};


    m=schema.method(c,'getBlockData');
    s=m.signature;
    s.Varargin='on';
    s.InputTypes={'handle',...
    'mxArray',...
'mxArray'...
    };
    s.OutputTypes={'mxArray',...
    'mxArray',...
'mxArray'...
    };



    m=schema.method(c,'getModelBlockEntries');
    s=m.signature;
    s.Varargin='off';
    s.InputTypes={'handle',...
'mxArray'...
    };
    s.OutputTypes={'mxArray',...
    'mxArray',...
    };

    m=schema.method(c,'createModelEntry');
    s=m.signature;
    s.Varargin='off';
    s.InputTypes={'handle',...
'mxArray'...
    };
    s.OutputTypes={'mxArray'...
    };


    m=schema.method(c,'getModelData');
    s=m.signature;
    s.Varargin='off';
    s.InputTypes={'handle',...
'mxArray'...
    };
    s.OutputTypes={'mxArray'...
    };


    m=schema.method(c,'setExaminingModel');
    s=m.signature;
    s.Varargin='off';
    s.InputTypes={'handle',...
    'mxArray',...
'bool'...
    };
    s.OutputTypes={...
    };





