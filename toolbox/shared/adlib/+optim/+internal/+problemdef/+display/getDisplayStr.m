function[HStr,AStr,bStr,bNeg]=getDisplayStr(H,A,b,varInfo,showZero)










































    if nargin<5
        showZero=false;
    end


    nObj=numel(b);


    Hnnz=nnz(H);
    Annz=nnz(A);
    bnnz=nnz(b);


    if(Hnnz==0&&Annz==0&&bnnz==0)
        HStr=strings(nObj,1);
        AStr=strings(nObj,1);
        bStr=strings(nObj,1);
        bNeg=false(nObj,1);
        return;
    end

    HStr=optim.internal.problemdef.display.createHStr(H,nObj,varInfo);
    AStr=optim.internal.problemdef.display.createAStr(A,nObj,varInfo);
    bStr=optim.internal.problemdef.display.createbStr(b,nObj);


    if showZero

        for i=1:nObj

            if strlength(bStr(i))~=0||strlength(AStr(i))~=0||strlength(HStr(i))~=0
                if strlength(AStr(i))==0&&strlength(HStr(i))==0


                    AStr(i)="0";
                end
                if strlength(bStr(i))==0

                    bStr(i)="0";
                end
            end
        end
    end


    bNeg=b<0;

end
