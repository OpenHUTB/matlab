function setPosRefTo(m2mObj,aTrgBlk,aRefBlk,aDir)



    trgBlkType=get_param([m2mObj.fPrefix,aTrgBlk],'BlockType');
    if strcmpi(trgBlkType,'Inport')||strcmpi(trgBlkType,'Outport')
        set_param([m2mObj.fPrefix,aTrgBlk],'position',[0,0,30,14]);
    end

    refCount=0;
    if isKey(m2mObj.fPosRefCount,aRefBlk)
        refCount=m2mObj.fPosRefCount(aRefBlk);
        m2mObj.fPosRefCount(aRefBlk)=refCount+1;
    else
        m2mObj.fPosRefCount(aRefBlk)=1;
    end

    posTrg=get_param([m2mObj.fPrefix,aTrgBlk],'position');
    widthTrg=posTrg(3)-posTrg(1);
    heightTrg=posTrg(4)-posTrg(2);

    posRef=get_param(aRefBlk,'position');
    if strcmpi(aDir,'east')
        posTrg(1)=posRef(3)+30*(refCount+1);
        posTrg(3)=posTrg(1)+widthTrg;
        posTrg(2)=posRef(2)/2+posRef(4)/2-heightTrg/2;
        posTrg(4)=posRef(2)/2+posRef(4)/2+heightTrg/2;
    elseif strcmpi(aDir,'west')
    elseif strcmpi(aDir,'north')
    elseif strcmpi(aDir,'south')
        posTrg(2)=posRef(4)+30*(refCount+1);
        posTrg(4)=posTrg(2)+heightTrg;
        posTrg(1)=posRef(1)/2+posRef(3)/2-widthTrg/2;
        posTrg(3)=posRef(1)/2+posRef(3)/2+widthTrg/2;
    elseif strcmpi(aDir,'over')
        posTrg=posRef;
    else
    end
    set_param([m2mObj.fPrefix,aTrgBlk],'position',posTrg);
end
