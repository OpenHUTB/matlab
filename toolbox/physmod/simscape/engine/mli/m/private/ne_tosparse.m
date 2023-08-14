function A=ne_tosparse(logicalsparse,pr)








    if nargin<=1
        A=double(logicalsparse);
    else
        A=sparse(size(logicalsparse,1),size(logicalsparse,2));
        A(logicalsparse)=pr;
    end
