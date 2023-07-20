function weights=shifter2D(load,wxyIn,dwx,dwy)
%#codegen

    coder.allowpcode('plain');

    wxyInT=reshape(wxyIn,[3,3]);

    persistent wxy;

    if(isempty(wxy))
        wxy=uint32(zeros(3,3));
    end


    weights=reshape(wxy,size(wxyIn));


    if(load)
        wxy=wxyInT;
    else
        wxy=moveW(wxy,dwx,dwy);
    end
end


function wxyOut=moveW(wxy,dwx,dwy)
    wxyOut=uint32(zeros(3,3));
    wxy1=uint32(zeros(3,3));
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
