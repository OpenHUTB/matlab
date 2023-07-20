function[dataOut,indexOut,wValidOut]=...
    shifter2D_data(dataIn,indexIn,wValidIn,dwx,dwy,IndexAddrW)




%#codegen
    coder.allowpcode('plain');


    dataInTemp=reshape(dataIn,[3,3]);
    indexInTemp=reshape(indexIn,[3,3]);
    wValidInTemp=reshape(wValidIn,[3,3]);


    persistent dataInternal;
    persistent indexInternal;
    persistent wValidInternal;



    s1=0;
    w1=32;
    f1=0;

    s2=0;
    w2=IndexAddrW;
    f2=0;

    s3=0;
    w3=1;
    f3=0;


    if(isempty(dataInternal))
        dataInternal=fi(zeros(3,3),s1,w1,f1);
    end
    if(isempty(indexInternal))
        indexInternal=fi(zeros(3,3),s2,w2,f2);
    end
    if(isempty(wValidInternal))
        wValidInternal=fi(zeros(3,3),s3,w3,f3);
    end


    dataOut=reshape(dataInternal,size(dataIn));
    indexOut=reshape(indexInternal,size(indexIn));
    wValidOut=reshape(wValidInternal,size(wValidIn));




    dataInternal=moveW(dataInTemp,dwx,dwy,s1,w1,f1);
    indexInternal=moveW(indexInTemp,dwx,dwy,s2,w2,f2);
    wValidInternal=moveW(wValidInTemp,dwx,dwy,s3,w3,f3);
end


function wxyOut=moveW(wxy,dwx,dwy,s,w,f)
    wxyOut=fi(zeros(3,3),s,w,f);
    wxy1=fi(zeros(3,3),s,w,f);
    assert(dwx>=0&&dwx<3);

    for ibx=0:3-1
        newIbx=fi((ibx+dwx),0,ceil(log2(3*3)),0);
        if(newIbx>=3)
            newIbx=fi(newIbx-3,0,ceil(log2(3*3)),0);
        end
        wxy1(ibx+1,:,:)=wxy(newIbx+1,:,:);
    end

    for iby=0:3-1
        newIby=fi((iby+dwy),0,ceil(log2(3*3)),0);
        if(newIby>=3)
            newIby=fi(newIby-3,0,ceil(log2(3*3)),0);
        end
        wxyOut(:,iby+1,:)=wxy1(:,newIby+1,:);
    end
end
