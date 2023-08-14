function y=eml_al_matrix_inverse(u)



%#codegen

    coder.allowpcode('plain');
    y=inv(u);

end

