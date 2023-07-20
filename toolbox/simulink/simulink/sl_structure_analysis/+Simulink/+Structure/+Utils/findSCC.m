





function DEOut=findSCC(DE)

    [~,n]=size(DE);



    [p,~,r,~]=dmperm(DE|speye(size(DE)));


    cIdx=find(diff(r)>1);

    nSCC=length(cIdx);

    DEOut=cell(nSCC,1);

    for i=1:nSCC

        k=cIdx(i);


        idx=p(r(k):r(k+1)-1);

        DE_i=DE;

        indexToRemove=setdiff(1:n,idx);

        DE_i(indexToRemove,:)=0;
        DE_i(:,indexToRemove)=0;


        DEOut{i}=DE_i;
    end

end