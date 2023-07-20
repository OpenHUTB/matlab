function q=quatnormalize(q)
%#codegen


    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');
    eml_invariant(nargin>0,eml_message('MATLAB:minrhs'));






    qm=quatmod(q);
    for j=1:4
        for i=1:size(q,1)
            q(i,j)=q(i,j)/qm(i);
        end
    end
