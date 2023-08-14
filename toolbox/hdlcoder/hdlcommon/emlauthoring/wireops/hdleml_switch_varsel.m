%#codegen
function y=hdleml_switch_varsel(zeroBasedIndex,clipToRange,sel,u)





    coder.allowpcode('plain')
    eml_prefer_const(zeroBasedIndex,clipToRange);

    if clipToRange
        y=select_one_port_vec_clip(zeroBasedIndex,sel,u);
    else
        y=select_one_port_vec(zeroBasedIndex,sel,u);
    end
end


function y=select_one_port_vec(zeroBasedIndex,sel,u)
    eml_prefer_const(zeroBasedIndex);
    y=u(end);
    for i=numel(u)-1:-1:1
        if sel==i-zeroBasedIndex
            y=u(i);
        end
    end
end




function y=select_one_port_vec_clip(zeroBasedIndex,sel,u)
    eml_prefer_const(zeroBasedIndex);
    if sel<=1-zeroBasedIndex
        y=u(1);
        return;
    end
    for i=coder.unroll(2:(numel(u)-1))
        if sel==i-zeroBasedIndex
            y=u(i);
            return;
        end
    end
    y=u(end);
end
