function qnorm=aeroblkquatnormalize(q)




%#codegen
    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');


    qn=norm(q);


    qnorm=q/qn;

end
