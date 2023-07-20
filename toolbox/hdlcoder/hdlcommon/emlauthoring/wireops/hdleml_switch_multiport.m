%#codegen
function y=hdleml_switch_multiport(inputmode,zeroBasedIndex,sel,varargin)






    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(inputmode,zeroBasedIndex);

    if inputmode==1
        y=select_one_port(zeroBasedIndex,sel,varargin{:});
    else
        y=select_one_port_vec(zeroBasedIndex,sel,varargin{1});
    end
end



function y=select_one_port(zeroBasedIndex,sel,varargin)
    eml_prefer_const(zeroBasedIndex);
    for i=coder.unroll(1:nargin-3)
        if sel==i-zeroBasedIndex
            y=varargin{i};
            return;
        end
    end
    y=varargin{end};
end


function y=select_one_port_vec(zeroBasedIndex,sel,u)
    eml_prefer_const(zeroBasedIndex);
    if numel(u)>=1024
        idx=sel;
        if 1-zeroBasedIndex<=idx&&idx<=numel(u)-zeroBasedIndex
            y=u(double(idx)+zeroBasedIndex);
            return;
        end
    else
        for i=coder.unroll(1:numel(u)-1)
            if sel==i-zeroBasedIndex
                y=u(i);
                return;
            end
        end
    end

    y=u(end);
end
