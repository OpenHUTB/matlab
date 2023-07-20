function q=quatinv(q)
%#codegen


    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');
    eml_invariant(nargin>0,eml_message('MATLAB:minrhs'));
    eml_invariant(isreal(q),eml_message('aeroblks:aeroblkquateml:isNotReal'));
    eml_invariant(size(q,2)==4,eml_message('aeroblks:aeroblkquateml:wrongDimension'));



    for k=1:size(q,1)

        qnrm=q(k,1)*q(k,1)+q(k,2)*q(k,2)+q(k,3)*q(k,3)+q(k,4)*q(k,4);
        q(k,1)=q(k,1)/qnrm;
        q(k,2)=-q(k,2)/qnrm;
        q(k,3)=-q(k,3)/qnrm;
        q(k,4)=-q(k,4)/qnrm;
    end
