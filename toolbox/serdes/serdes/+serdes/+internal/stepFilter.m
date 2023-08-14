function[y,state]=stepFilter(x,num,den,state)
























%#codegen
    coder.allowpcode('plain')

    ns=size(state,1)-1;
    [nr,nc]=size(x);
    assert(nr==1&&nc==1,'Filter input must be a scalar.');
    [nr,ncn]=size(num);
    assert(nr==ns&&ncn>=3,'Filter numerator must be Nx3 or wider.');
    [nr,ncd]=size(den);
    assert(nr==ns&&ncd==ncn-1,...
    'Filter denominator must be N rows and one column narrower than numerator.');
    for indx=ncn:-1:2
        state(:,indx)=state(:,indx-1);
    end
    state(1,1)=x;
    for indx=1:ns
        state(indx+1,1)=num(indx,:)*state(indx,:).'-...
        den(indx,:)*state(indx+1,2:ncn).';
    end
    y=state(ns+1,1);
end


