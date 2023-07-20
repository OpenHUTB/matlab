function schema







    mlock;

    pkg=findpackage('NetworkEngine');
    c=schema.class(pkg,'PhysicalNetworksSimulationOptions');



    dt=findtype('NE_PNSIM_OPTIONS');
    if isempty(dt)
        schema.EnumType('NE_PNSIM_OPTIONS',{'warning','error','none'});
    end


    dt=findtype('NE_PNSIM_OPTIONS_NO_NONE');
    if isempty(dt)
        schema.EnumType('NE_PNSIM_OPTIONS_NO_NONE',{'warning','error'});
    end






























    m=schema.method(c,'getCCPropertyList','static');
    s=m.signature;
    s.Varargin='off';
    s.InputTypes={...
    };
    s.OutputTypes={'MATLAB array'...
    };









    m=schema.method(c,'propertySetFcn_errorOptions','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle',...
'string'...
    };
    s.OutputTypes={...
    };





