function SPS=ConvertForSFun(SPS)






    Mg=SPS.MgNotRed;
    MgColNames=SPS.MgColNamesNotRed;
    nb=SPS.Mg_nbNotRed;


    nStates=nb.x;
    nInputs=nb.u;
    nOutputs=nb.y;
    nSwitch=nb.s;

    MatIdx=[nStates,nOutputs,nSwitch,nStates,nInputs,nStates,nSwitch];
    MatIdx=int32(cumsum(double(MatIdx)));
    dXIdx=1:MatIdx(1);
    YIdx=MatIdx(1)+1:MatIdx(2);
    SwLIdx=MatIdx(2)+1:MatIdx(3);
    XIdx=MatIdx(3)+1:MatIdx(4);
    UIdx=MatIdx(4)+1:MatIdx(5);
    DIdx=MatIdx(5)+1:MatIdx(6);
    SwRIdx=MatIdx(6)+1:MatIdx(7);

    NewMg=zeros(MatIdx(3),MatIdx(7));
    NewMg(:,[dXIdx,YIdx])=Mg(:,[dXIdx,YIdx]);
    NewMg(:,[XIdx,UIdx])=Mg(:,[XIdx,UIdx]+nSwitch);

    if(nSwitch>0)
        NewMg(:,SwLIdx)=Mg(:,2*SwLIdx-SwLIdx(1));
        NewMg(:,SwRIdx)=Mg(:,2*SwLIdx-SwLIdx(1)+1);
    end;

    ColNames=cell(MatIdx(7),1);
    ColNames([dXIdx,YIdx])=MgColNames([dXIdx,YIdx]);
    ColNames([XIdx,UIdx])=MgColNames([XIdx,UIdx]+nSwitch);
    ColNames([XIdx,UIdx])=MgColNames([XIdx,UIdx]+nSwitch);
    ColNames(DIdx)=MgColNames([XIdx]+nSwitch);
    if(nSwitch>0)
        ColNames(SwLIdx)=MgColNames(2*SwLIdx-SwLIdx(1));
        ColNames(SwRIdx)=MgColNames(2*SwLIdx-SwLIdx(1)+1);
    end;

    N=any(NewMg(:,[dXIdx,YIdx,SwLIdx,UIdx]),2)-any(NewMg(:,[XIdx]),2);
    rowsWithXDep=find(N<0);
    rowsWithoutXDep=find(N>=0);
    NewMg=NewMg([rowsWithXDep',rowsWithoutXDep'],:);


    SPS.Mg=NewMg';
    SPS.MgColNames=ColNames;
    SPS.nb=nb;


