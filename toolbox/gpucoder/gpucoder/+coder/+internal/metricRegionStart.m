function obj=metricRegionStart(name)%#codegen




    if(~coder.target('MATLAB'))
        if(nargin==0)
            name='';
        elseif(~ischar(name))
            error('Please input region name as a string')
        end
        coder.allowpcode('plain');
        coder.inline('always');
        obj=coder.internal.codeRegion('metric',name);
    else
        obj=coder.internal.dummyCodeRegionSim;
    end

end
