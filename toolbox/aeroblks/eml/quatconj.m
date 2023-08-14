function q=quatconj(q)
%#codegen


    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');
    eml_invariant(nargin>0,eml_message('MATLAB:minrhs'));
    eml_invariant(isreal(q),eml_message('aeroblks:aeroblkquateml:isNotReal'));
    eml_invariant(size(q,2)==4,eml_message('aeroblks:aeroblkquateml:wrongDimension'));
    for k=1+size(q,1):numel(q)
        q(k)=-q(k);
    end
