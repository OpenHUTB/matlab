function y=hdleml_switch_multiport_enum(portIndices,sel,varargin)


%#codegen
    coder.allowpcode('plain')
    eml_prefer_const(portIndices);


    for i=coder.unroll(1:nargin-3)
        if sel==portIndices(i)
            y=varargin{i};
            return;
        end
    end
    y=varargin{end};
end
