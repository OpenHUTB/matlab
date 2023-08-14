function[swapIdx,zerosidx,P,A_bar]=swapEquations(A)
















    na=size(A,1);

    swapIdx=dmperm(A);


    zerosidx=~swapIdx;
    swapIdx(zerosidx)=setdiff(1:na,swapIdx(swapIdx>0));
    if nargout>2

        P=false(na);
        for i=1:na
            P(swapIdx(i),i)=true;
        end
        if nargout>3
            A_bar=P*A;
        end
    end

