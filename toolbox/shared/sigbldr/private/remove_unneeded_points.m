function[xnew,ynew]=remove_unneeded_points(x,y)





    xnew=x;
    ynew=y;


    sameX=diff(x)==0;


    if all(sameX==0)
        return;
    end

    I_eliminate=find(sameX(1:(end-1))&diff(sameX)==0)+1;
    xnew(I_eliminate)=[];
    ynew(I_eliminate)=[];


    I_eliminate=find(diff(xnew)==0&diff(ynew)==0);
    xnew(I_eliminate)=[];
    ynew(I_eliminate)=[];


    if diff(xnew(1:2))==0
        xnew(1)=[];
        ynew(1)=[];
    end
    if diff(xnew((end-1):end))==0
        xnew(end)=[];
        ynew(end)=[];
    end
