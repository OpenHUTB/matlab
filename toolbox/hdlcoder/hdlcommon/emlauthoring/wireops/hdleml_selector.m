%#codegen
function y=hdleml_selector(indices,u)















    coder.allowpcode('plain')
    eml_prefer_const(indices);

    y=u(indices);
end
