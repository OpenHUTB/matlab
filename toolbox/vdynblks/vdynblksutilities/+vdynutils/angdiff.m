function delta=angdiff(x,y)
%#codegen
    coder.allowpcode('plain');















%#codegen


    if nargin==1




        d=diff(x);
    else



        d=y-x;
    end


    delta=vdynutils.wrapToPi(d);

end
