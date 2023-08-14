function symstr=checksymmetry(b,tol)







    if nargin<2,tol=[];end
    if isempty(tol),tol=eps^(2/3);end


    b=b(:).';


    if max(abs(b-b(end:-1:1)))<=tol,
        symstr='symmetric';
    elseif max(abs(b+b(end:-1:1)))<=tol,
        symstr='antisymmetric';
    else
        symstr='none';
    end


