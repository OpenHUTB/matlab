%#codegen

function op=op_single_ge(a,b)
    coder.allowpcode('plain');
    coder.inline('never');
    t_a=typecast(a,'single');
    t_b=typecast(b,'single');
    op=t_a>=t_b;

end
