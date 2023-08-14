function qout=quatdivide(q,r)
%#codegen


    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');
    eml_invariant(nargin>1,eml_message('MATLAB:minrhs'));







    qout=quatmultiply(quatinv(r),q);
