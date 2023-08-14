function[Vseq,Dseq]=eigenshuffle(Asequence)










































































































































    Asize=size(Asequence);
    if(Asize(1)~=Asize(2))
        error('Asequence must be a (pxpxn) array of eigen-problems, each of size pxp')
    end
    p=Asize(1);
    if length(Asize)<3
        n=1;
    else
        n=Asize(3);
    end


    Vseq=zeros(p,p,n);
    Dseq=zeros(p,n);
    for i=1:n
        [V,D]=eig(Asequence(:,:,i));
        D=diag(D);



        [junk,tags]=sort(real(D),1,'descend');

        Dseq(:,i)=D(tags);
        Vseq(:,:,i)=V(:,tags);
    end


    if n<2


        return
    end



    for i=2:n

        V1=Vseq(:,:,i-1);
        V2=Vseq(:,:,i);
        D1=Dseq(:,i-1);
        D2=Dseq(:,i);
        dist=(1-abs(V1'*V2)).*sqrt(...
        distancematrix(real(D1),real(D2)).^2+...
        distancematrix(imag(D1),imag(D2)).^2);




        reorder=munkres(dist);

        Vseq(:,:,i)=Vseq(:,reorder,i);
        Dseq(:,i)=Dseq(reorder,i);



        S=squeeze(real(sum(Vseq(:,:,i-1).*Vseq(:,:,i),1)))<0;
        Vseq(:,S,i)=-Vseq(:,S,i);
    end







    function d=distancematrix(vec1,vec2)

        [vec1,vec2]=ndgrid(vec1,vec2);
        d=abs(vec1-vec2);

        function[assignment,cost]=munkres(costMat)













...
...
...
...
...

...
...
...
...
...
...
...

...
...
...
...
...






            assignment=zeros(1,size(costMat,1));
            cost=0;

            costMat(costMat~=costMat)=Inf;
            validMat=costMat<Inf;
            validCol=any(validMat,1);
            validRow=any(validMat,2);

            nRows=sum(validRow);
            nCols=sum(validCol);
            n=max(nRows,nCols);
            if~n
                return
            end

            maxv=10*max(costMat(validMat));

            dMat=zeros(n)+maxv;
            dMat(1:nRows,1:nCols)=costMat(validRow,validCol);








            minR=min(dMat,[],2);
            minC=min(bsxfun(@minus,dMat,minR));





            zP=dMat==bsxfun(@plus,minC,minR);

            starZ=zeros(n,1);
            while any(zP(:))
                [r,c]=find(zP,1);
                starZ(r)=c;
                zP(r,:)=false;
                zP(:,c)=false;
            end

            while 1




                if all(starZ>0)
                    break
                end
                coverColumn=false(1,n);
                coverColumn(starZ(starZ>0))=true;
                coverRow=false(n,1);
                primeZ=zeros(n,1);
                [rIdx,cIdx]=find(dMat(~coverRow,~coverColumn)==bsxfun(@plus,minR(~coverRow),minC(~coverColumn)));
                while 1








                    cR=find(~coverRow);
                    cC=find(~coverColumn);
                    rIdx=cR(rIdx);
                    cIdx=cC(cIdx);
                    Step=6;
                    while~isempty(cIdx)
                        uZr=rIdx(1);
                        uZc=cIdx(1);
                        primeZ(uZr)=uZc;
                        stz=starZ(uZr);
                        if~stz
                            Step=5;
                            break;
                        end
                        coverRow(uZr)=true;
                        coverColumn(stz)=false;
                        z=rIdx==uZr;
                        rIdx(z)=[];
                        cIdx(z)=[];
                        cR=find(~coverRow);
                        z=dMat(~coverRow,stz)==minR(~coverRow)+minC(stz);
                        rIdx=[rIdx(:);cR(z)];
                        cIdx=[cIdx(:);stz(ones(sum(z),1))];
                    end
                    if Step==6





                        [minval,rIdx,cIdx]=outerplus(dMat(~coverRow,~coverColumn),minR(~coverRow),minC(~coverColumn));
                        minC(~coverColumn)=minC(~coverColumn)+minval;
                        minR(coverRow)=minR(coverRow)-minval;
                    else
                        break
                    end
                end












                rowZ1=find(starZ==uZc);
                starZ(uZr)=uZc;
                while rowZ1>0
                    starZ(rowZ1)=0;
                    uZc=primeZ(rowZ1);
                    uZr=rowZ1;
                    rowZ1=find(starZ==uZc);
                    starZ(uZr)=uZc;
                end
            end


            rowIdx=find(validRow);
            colIdx=find(validCol);
            starZ=starZ(1:nRows);
            vIdx=starZ<=nCols;
            assignment(rowIdx(vIdx))=colIdx(starZ(vIdx));
            cost=trace(costMat(assignment>0,assignment(assignment>0)));

            function[minval,rIdx,cIdx]=outerplus(M,x,y)
                [nx,ny]=size(M);
                minval=inf;
                for r=1:nx
                    x1=x(r);
                    for c=1:ny
                        M(r,c)=M(r,c)-(x1+y(c));
                        if minval>M(r,c)
                            minval=M(r,c);
                        end
                    end
                end
                [rIdx,cIdx]=find(M==minval);


