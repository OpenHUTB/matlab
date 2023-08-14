function[smap,rmap]=mblkint(N,no,nr)







    ns=no*N;
    len=no+ns;
    smap=zeros(1,len);
    smap(1:no)=(no+N):N:len;
    smap((no+1):N:len)=1:no;
    ko=no+(2:N);
    ki=no+(1:N-1);
    for k=1:no
        smap(ko)=ki;
        ko=ko+N;
        ki=ki+N;
    end
    if(nr>0)
        nrs=no*nr;
        rmap=nrs+(1:ns);
        ko=1:nr;
        ki=1:no:nrs;
        for k=1:no
            rmap(ko)=ki;
            ko=ko+N;
            ki=ki+1;
        end
    else
        rmap=[];
    end
    return
