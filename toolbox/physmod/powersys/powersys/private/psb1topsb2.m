function[out,Y,names,srcNames,outNames,orgEdgeNbrs,idxSrc,idxOut,...
    circ2ssInfo,Mut,psbInfo]=psb1topsb2(psbInfo,commandLine,fid_outfile)











    [psbInfo,idxShortCircuits]=getShortCircuits(psbInfo);

    rlc=psbInfo.rlc;
    src=psbInfo.source;



    if isempty(rlc)&isempty(src)
        Erreur.message='Short-circuit limitation';
        Erreur.identifier='SpecializedPowerSystems:psb1topsb2';
        psberror(Erreur);
    end



    if commandLine
        detectIsol(rlc,src);
    end




    if commandLine|fid_outfile~=0
        [circ2ssInfo,idxLine]=getCommandLineInfo(psbInfo);
    else
        circ2ssInfo=[];
    end



    if~commandLine
        [Y,idxOut]=getOutputRequests(psbInfo,idxShortCircuits);
    else
        Y=struct('vnn',[],'ib',[]);
    end



    if~isempty(src)
        src=src(:,1:3);
    end

    if~isempty(rlc)
        if strcmp(psbInfo.unit,'OMU')
            rlc(:,5)=rlc(:,5)/1e3;
            rlc(:,6)=rlc(:,6)/1e6;
        elseif strcmp(psbInfo.unit,'OHM')
            omega=psbInfo.freq_sys*2*pi;
            rlc(:,5)=rlc(:,5)/omega;

            idx1=find(rlc(:,6)~=0&rlc(:,3)<2);
            rlc(idx1,6)=1./(rlc(idx1,6).*omega);
        else
            Erreur.message='Unsupported units specified';
            Erreur.identifier='SpecializedPowerSystems:psb1topsb2';
            psberror(Erreur);
        end
    end



    [rlc,src,Y,node,usedNodes,usedNodesOrg,newNodes]=...
    reassignNodeNumbers(psbInfo,rlc,src,Y);



    [Trf,qtyTrf,idxTrfMag,idxTrfWdgs,rlc]=...
    getTransformerData(rlc,commandLine,circ2ssInfo);



    [Mut,qtyMut,rlc]=getMutualData(rlc);



    if commandLine
        rlc=updatePiLineData(idxLine,rlc,circ2ssInfo);
    end







    [out,orgEdgeNbrs,rlc,edge,node]=...
    setSeriesBranchesOutputData(rlc,node);



    [out,orgEdgeNbrs,rlc,edge]=...
    setParallelBranchesOutputData(out,orgEdgeNbrs,rlc,edge);

    liste_neu2=[];

    if commandLine

        for k=1:length(usedNodes)
            idx1=find(usedNodesOrg==circ2ssInfo.liste_neu(k));
            liste_neu2(k)=newNodes(idx1);
        end
    end



    if qtyTrf>0
        [out,orgEdgeNbrs,rlc,edge,node,liste_neu2]=...
        setTransformerOutputData(out,orgEdgeNbrs,rlc,edge,node,...
        Trf,qtyTrf,idxTrfMag,idxTrfWdgs,liste_neu2,commandLine);
    end



    if qtyMut>0
        [out,orgEdgeNbrs,rlc,edge,node]=...
        setMutualOutpuData(out,orgEdgeNbrs,rlc,edge,node,Mut,qtyMut);
    end



    if~isempty(src)
        [out,orgEdgeNbrs,edge,idxSrc]=...
        setSourcesOutputData(out,orgEdgeNbrs,src,edge);
    else
        idxSrc=[];
    end








    if commandLine
        for k=1:length(liste_neu2)-1
            Y.vnn(k,:)=[liste_neu2(k),liste_neu2(length(liste_neu2))];
            idxOut=1:size(Y.vnn,1);
        end
    end



    [names,srcNames,outNames]=getLists(psbInfo,commandLine);




    function[SPS,idxShortCircuits]=getShortCircuits(SPS)






        RLClinesToDelete=[];

        if~isempty(SPS.rlc)




            ShortCircuits=find((SPS.rlc(:,1)==SPS.rlc(:,2))&...
            (SPS.rlc(:,3)~=2)&(SPS.rlc(:,3)~=3)&(SPS.rlc(:,3)~=4));



            for i=1:length(ShortCircuits)
                RLCelements=SPS.rlc(ShortCircuits(i),4:6)&1;
                if sum(RLCelements)==1

                    if any(SPS.SPIDresistors==ShortCircuits(i))

                    else
                        RLClinesToDelete(end+1)=ShortCircuits(i);%#ok mlint

                    end
                end
            end

            SPS.rlc(RLClinesToDelete,:)=[];
            SPS.rlcnames(RLClinesToDelete,:)=[];

            idxShortCircuits=RLClinesToDelete;






            ns=size(SPS.rlc,1);
            SPS.rlc(:,7)=(1:ns)';

        else
            idxShortCircuits=[];
        end









        function[]=detectIsol(rlc,src)
            if isempty(rlc)&isempty(src)
                return;
            else
                noeuds=[];
                if~isempty(rlc)
                    noeuds=rlc(:,1:2);
                end
                if~isempty(src)
                    noeuds=[noeuds;src(:,1:2)];
                end
            end

            liste=[-123456];
            nores=[];
            indres=1;
            newneu=[];

            for i=1:size(noeuds,1)
                if isempty(find(noeuds(i,1)==liste))&&...
                    isempty(find(noeuds(i,2)==liste))
                    if i==1
                        liste=[];
                    end
                    ww=noeuds(i,:);
                    wwold=[];
                    while length(ww)>length(wwold)
                        wwold=ww;
                        for j=1:size(noeuds,1)
                            cond1=~isempty(find(ww==noeuds(j,1)));
                            cond2=~isempty(find(ww==noeuds(j,2)));


                            if(cond1&~cond2)
                                ww=[ww,noeuds(j,2)];
                            end


                            if(~cond1&cond2)
                                ww=[ww,noeuds(j,1)];
                            end
                        end
                    end
                    liste=[liste,ww];
                    nores=[nores,indres*ones(1,length(ww))];
                    indres=indres+1;
                    ww=[];
                end
            end

            nbrres=indres-1;
            if nbrres>1
                Erreur.message='Detected isolated networks.';
                Erreur.identifier='SpecializedPowerSystems:psb1topsb2';
                psberror(Erreur);
            end








            function[circ2ssInfo,idxLine]=getCommandLineInfo(psbInfo)

                rlc=psbInfo.rlc;

                omega=psbInfo.freq_sys*2*pi;
                if~isempty(rlc)
                    rlcm=rlc;
                else
                    rlcm=[];
                end


                liste_neu=psbInfo.liste_neu;




                qtyTrf=0;
                idxMag=[];
                if~isempty(rlc)
                    idxWdgs=find(rlc(:,3)==2)';
                else
                    idxWdgs=[];
                end
                qtyWdgs=length(idxWdgs);
                if qtyWdgs>0
                    rlcm(idxWdgs,6)=zeros(qtyWdgs,1);
                    idxMag=zeros(1,ceil(qtyWdgs/2));
                    l=1;
                    for k=1:qtyWdgs-1
                        if(idxWdgs(k+1)>(idxWdgs(k)+1))
                            idxMag(l)=idxWdgs(k)+1;
                            l=l+1;
                        end
                    end
                    idxMag(l)=idxWdgs(k)+2;
                    idxMag=idxMag(find(idxMag));
                    qtyTrf=l;
                end



                for k=1:qtyTrf
                    idxm=idxMag(k);
                    thisTrf=find(idxWdgs<idxm);

                    rlcm(idxWdgs(thisTrf(1)),3)=0;

                    rlcm(idxWdgs(thisTrf(1)),2)=rlcm(idxm,1);
                    for m=2:length(thisTrf)
                        idx1=idxWdgs(thisTrf(m));


                        newNode=rlcm(idxm,1)+0.1*m;
                        if any(liste_neu==newNode)
                            message=['The intermediate node ',num2str(newNode,'%-8g'),...
                            ' of winding no. ',num2str(m,'%-8g'),...
                            ' of transformer no. ',num2str(k,'%-8g'),...
                            ' already exists!'];
                            Erreur.message=message;
                            Erreur.identifier='SpecializedPowerSystems:psb1topsb2';
                            psberror(Erreur);
                        end

                        liste_neu=[liste_neu,newNode];
                        rlcm(idx1,2)=newNode;

                        rlcm(idx1,3)=0;

                        if rlcm(idx1,5)==0



                            rlcm(idx1,4)=rlcm(idx1,4)/2;



                        else
                            rlcm(idx1,4)=0;
                        end
                    end

                    idxWdgs=idxWdgs(length(thisTrf)+1:length(idxWdgs));
                end




                qtyMut=0;
                idxMag=[];
                if~isempty(rlc)
                    idxWdgs=find(rlc(:,3)==3)';
                else
                    idxWdgs=[];
                end
                qtyWdgs=length(idxWdgs);
                if qtyWdgs>0
                    idxMag=zeros(1,ceil(qtyWdgs/2));
                    l=1;
                    for k=1:qtyWdgs-1
                        if(idxWdgs(k+1)>(idxWdgs(k)+1))
                            idxMag(l)=idxWdgs(k)+1;
                            l=l+1;
                        end
                    end
                    idxMag(l)=idxWdgs(k)+2;
                    idxMag=idxMag(find(idxMag));
                    qtyMut=l;
                end



                rlcmRowsToRemove=[];
                for k=1:qtyMut
                    idxm=idxMag(k);



                    idx1=find(liste_neu==rlc(idxm,1));
                    liste_neu(idx1)=[];
                    rlcmRowsToRemove=[rlcmRowsToRemove,idxm];

                    thisMut=find(idxWdgs<idxm);

                    rlcm(idxWdgs(thisMut(1)),3)=0;

                    for m=2:length(thisMut)

                        rlcm(idxWdgs(thisMut(m)),3)=0;
                    end

                    idxWdgs=idxWdgs(length(thisMut)+1:length(idxWdgs));
                end

                if~isempty(rlc)
                    rlcm(rlcmRowsToRemove,3:size(rlcm,2))=...
                    zeros(length(rlcmRowsToRemove),size(rlcm,2)-2);
                end




                qtyMut2=0;
                idxMag=[];
                if~isempty(rlc)
                    idxWdgs=find(rlc(:,3)==4)';
                else
                    idxWdgs=[];
                end

                qtyWdgs=length(idxWdgs);

                if qtyWdgs>0
                    idxMag=zeros(1,ceil(qtyWdgs*(qtyWdgs-1)/2));
                    l=1;
                    for k=1:qtyWdgs-1
                        if(idxWdgs(k+1)>(idxWdgs(k)+1))
                            idxMag(l)=idxWdgs(k)+1;
                            l=l+1;
                        end
                    end
                    idxMag(l)=idxWdgs(k)+2;
                    idxMag=idxMag(find(idxMag));
                    qtyMut2=l;
                end

                for k=1:qtyMut2
                    idxm=idxMag(k);
                    thisMut=find(idxWdgs<idxm);
                    qtyWdgsThisMut=length(thisMut);


                    nbMutualRows=qtyWdgsThisMut*(qtyWdgsThisMut-1)/2;
                    idxCouplingTerms=idxWdgs(thisMut(end))+...
                    1:idxWdgs(thisMut(end))+nbMutualRows;


                    idxMag(2,k)=idxCouplingTerms(end);
                end



                rlcmRowsToRemove=[];
                for k=1:qtyMut2
                    idxm=idxMag(1,k);


                    for m=idxMag(1,k):idxMag(2,k)
                        if m<=size(rlc,1)
                            idx1=find(liste_neu==rlc(m,1));
                            liste_neu(idx1)=[];
                        end
                    end


                    rlcmRowsToRemove=[rlcmRowsToRemove,idxm:idxMag(2,k)];

                    thisMut=find(idxWdgs<idxm);

                    rlcm(idxWdgs(thisMut(1)),3)=0;

                    for m=2:length(thisMut)

                        rlcm(idxWdgs(thisMut(m)),3)=0;
                    end

                    idxWdgs=idxWdgs(length(thisMut)+1:length(idxWdgs));
                end

                if~isempty(rlc)
                    rlcm(rlcmRowsToRemove,3:size(rlcm,2))=...
                    zeros(length(rlcmRowsToRemove),size(rlcm,2)-2);
                end



                if~isempty(rlc)
                    rlc1=rlcm(:,4:6);
                    if all(psbInfo.unit=='OMU')
                        rlc1(:,2)=rlc1(:,2)./1e3;
                        rlc1(:,3)=rlc1(:,3)./1e6;
                    elseif all(psbInfo.unit=='OHM')
                        rlc1(:,2)=rlc1(:,2)./omega;
                        idx1=find(rlcm(:,6));
                        rlc1(idx1,3)=1./(rlc1(idx1,3).*omega);
                    else
                        Erreur.message='Unsupported units used to specify rlc matrix';
                        Erreur.identifier='SpecializedPowerSystems:psb1topsb2';
                        psberror(Erreur);
                    end
                else
                    rlc1=[];
                end



                if~isempty(rlc)

                    idxLine=find(rlcm(:,3)<0);
                else
                    idxLine=[];
                end

                c_ligne=[];
                for k=1:length(idxLine)
                    ib=idxLine(k);

                    long=abs(rlcm(ib,3));
                    xl=rlc1(ib,2)*omega;
                    susc=rlc1(ib,3)*omega;
                    [z_ser,y_sh]=etazline(long,rlc1(ib,1),xl,susc);
                    rlc1(ib,1)=real(z_ser);
                    rlc1(ib,2)=imag(z_ser)/omega;
                    rlc1(ib,3)=0;
                    c_ligne(ib)=imag(y_sh)/omega;
                    for icol=9:10,
                        ib1=rlcm(ib,icol);
                        rlc1(ib1,3)=rlc1(ib1,3)+c_ligne(ib);
                    end
                end

                circ2ssInfo.rlcm=rlcm;
                circ2ssInfo.rlc1=rlc1;
                circ2ssInfo.liste_neu=liste_neu;
                circ2ssInfo.c_ligne=c_ligne;








                function[Y,idxOut]=getOutputRequests(psbInfo,idxShortCircuits)

                    rlc=psbInfo.rlc;

                    Y=struct('vnn',[],'ib',[]);
                    idxVout=find(psbInfo.ytype==0);
                    idxIout=find(psbInfo.ytype==1);
                    idxOut=[idxVout;idxIout];
                    qtyIout=length(idxIout);
                    qtyBr=zeros(qtyIout,1);
                    Y.ib=cell(qtyIout,1);

                    Vout=psbInfo.Outputs(idxVout,1);
                    for k=1:length(idxVout)
                        Y.vnn(k,:)=Vout{k};
                    end

                    Iout=psbInfo.Outputs(idxIout,:);






                    if~isempty(idxShortCircuits)
                        for k=1:size(Iout,1)
                            for m=length(idxShortCircuits):-1:1


                                mesure=abs(Iout{k,1});
                                if~isempty(mesure)
                                    idx1=find(mesure==idxShortCircuits(m));
                                    Iout{k,1}(idx1)=[];
                                end



                                idx1=find(abs(Iout{k,1})>idxShortCircuits(m));
                                idx1_sign=sign(Iout{k,1}(idx1));
                                Iout{k,1}(idx1)=(abs(Iout{k,1}(idx1))-1).*idx1_sign;
                            end
                        end
                    end

                    for k=1:qtyIout
                        qtyIbr=size(Iout{k,1},2);
                        qtyIsrc=size(Iout{k,2},2);
                        qtyTot=qtyIbr+qtyIsrc;
                        Y.ib{k}=zeros(5,qtyTot);
                        if qtyIbr>0
                            Y.ib{k}(1,1:qtyIbr)=sign(Iout{k,1});
                            Y.ib{k}(2,1:qtyIbr)=abs(Iout{k,1});

                            Y.ib{k}(5,1:qtyIbr)=rlc(Y.ib{k}(2,1:qtyIbr),3);





                            idx1=find(Y.ib{k}(5,1:qtyIbr)==2);
                            if~isempty(idx1)




                                for m=1:length(idx1)
                                    rlcRow=Y.ib{k}(2,idx1(m));
                                    if rlcRow==1


                                        isPrimaryWinding=1;
                                    else
                                        isPrimaryWinding=((rlc(rlcRow-1,3)~=2)&&...
                                        (rlc(rlcRow+1,3)==2));
                                    end

                                    if(isPrimaryWinding&&(rlc(rlcRow,4)==0)&&...
                                        (rlc(rlcRow,5)==0))





                                        idx3=find(rlc(:,3)==1);
                                        if~isempty(idx3)
                                            idx2=idx3(find(idx3>rlcRow));
                                            if~isempty(idx2)




                                                magBranchRow=idx2(1);




                                                if(isfinite(rlc(magBranchRow,4))|...
                                                    (isfinite(rlc(magBranchRow,5))...
                                                    &&rlc(magBranchRow,5)>0))
                                                    qtyIbr=qtyIbr+1;
                                                    qtyTot=qtyTot+1;
                                                    Y.ib{k}(1,qtyIbr)=sign(Iout{k,1}(idx1(m)));
                                                    Y.ib{k}(2,qtyIbr)=magBranchRow;
                                                    Y.ib{k}(5,qtyIbr)=1;







                                                end
                                            else
                                                Erreur.message='Magnetizing branch associated to primary winding not found.';
                                                Erreur.identifier='SpecializedPowerSystems:psb1topsb2';
                                                psberror(Erreur);
                                            end
                                        else
                                            Erreur.message='Magnetizing branch associated to primary winding not found.';
                                            Erreur.identifier='SpecializedPowerSystems:psb1topsb2';
                                            psberror(Erreur);
                                        end
                                    end
                                end
                            end

                        end

                        if qtyIsrc>0
                            Y.ib{k}(1,qtyIbr+1:qtyTot)=sign(Iout{k,2});
                            Y.ib{k}(2,qtyIbr+1:qtyTot)=abs(Iout{k,2});
                            Y.ib{k}(3,qtyIbr+1:qtyTot)=ones(1,qtyIsrc);
                            Y.ib{k}(4,qtyIbr+1:qtyTot)=Y.ib{k}(2,qtyIbr+1:qtyTot);
                        end
                    end








                    function[rlc,src,Y,node,usedNodes,usedNodesOrg,newNodes]=...
                        reassignNodeNumbers(psbInfo,rlc,src,Y)

                        if~isempty(rlc)








                            usedNodes=unique([rlc(:,1)',rlc(:,2)']);
                            idx1=find(rlc(:,3)==1&rlc(:,4)==inf&rlc(:,5)==0);
                            if~isempty(idx1)
                                idx2=find(rlc(idx1,1));
                                nodes2remove=rlc(idx1(idx2));
                                for k=1:length(nodes2remove)
                                    if~find(nodes2remove(k)==src(:,1));

                                        idx1=find(usedNodes==nodes2remove(k));
                                        usedNodes(idx1)=[];
                                    else
                                        rlc(idx1,5)=-1;
                                    end
                                end
                            end










                            TransformerWindings=find(rlc(:,3)==2);

                            if~isempty(TransformerWindings)

                                StartIndice=TransformerWindings(1);
                                StopIndice=TransformerWindings(end)+1;

                                MagBranches=find(rlc(StartIndice:StopIndice,3)==1)+StartIndice-1;

                                PrimaryBranches(1)=TransformerWindings(1);

                                for k=2:length(MagBranches)


                                    PrimaryBranches(k)=MagBranches(k-1)+1;%#ok mlint
                                end


                                for k=1:length(MagBranches)




                                    if rlc(PrimaryBranches(k),4)==0&&rlc(PrimaryBranches(k),5)==0





                                        usedNodes(find(usedNodes==rlc(MagBranches(k),1)))=[];%#ok mlint

                                        idx=find(psbInfo.liste_neu==rlc(MagBranches(k),1));
                                        idx_src=find(psbInfo.liste_neu(idx)==src(:,1));

                                        if~isempty(Y.vnn)
                                            idx_vnn=find(psbInfo.liste_neu(idx)==Y.vnn(:,1));
                                        end

                                        psbInfo.liste_neu(idx)=[];

                                        rlc(MagBranches(k),1)=rlc(PrimaryBranches(k),1);

                                        src(idx_src,1)=rlc(PrimaryBranches(k),1);%#ok mlint OT

                                        if~isempty(Y.vnn)
                                            Y.vnn(idx_vnn,1)=rlc(PrimaryBranches(k),1);%#ok mlint OT
                                        end

                                        psbInfo.rlc=rlc;

                                    end
                                end
                            end






                            idx1=find(rlc(:,3)==3);
                            idx2=[];
                            for k=1:length(idx1)
                                temp=rlc(idx1(k)+1,3);
                                if temp==0
                                    idx2=[idx2,idx1(k)+1];
                                end
                            end
                            for k=1:length(idx2)
                                idx1=find(usedNodes==rlc(idx2(k),1));
                                usedNodes(idx1)=[];
                            end










                            idx1=find(rlc(:,3)==4);
                            idx2=[];
                            if~isempty(idx1)
                                branchNbDiff=idx1(2:end)-idx1(1:end-1);
                                idx3=find(branchNbDiff>1);
                                if~isempty(idx3)





                                    nbGeneralMutuals=length(idx3)+1;

                                    for k=1:nbGeneralMutuals-1
                                        if k==1
                                            qtyWdgs=idx3(k);
                                        else

                                            qtyWdgs=idx3(k)-idx3(k-1);
                                        end

                                        nbMutualRows=qtyWdgs*(qtyWdgs-1)/2;
                                        idx2=[idx2,idx1(idx3(k))+1:idx1(idx3(k))+nbMutualRows];
                                    end


                                    qtyWdgs=idx1(end)-idx1(idx3(end)+1)+1;
                                    nbMutualRows=qtyWdgs*(qtyWdgs-1)/2;
                                    idx2=[idx2,idx1(end)+1:idx1(end)+nbMutualRows];

                                else

                                    qtyWdgs=length(idx1);
                                    nbMutualRows=qtyWdgs*(qtyWdgs-1)/2;
                                    idx2=idx1(end)+1:idx1(end)+nbMutualRows;
                                end

                                for k=1:length(idx2)
                                    idx1=find(usedNodes==rlc(idx2(k),1));
                                    usedNodes(idx1)=[];
                                end
                            end

                        else
                            usedNodes=[];
                        end
                        if~isempty(src)

                            usedNodes=unique([usedNodes,src(:,1)',src(:,2)']);
                        end


                        usedNodesOrg=usedNodes;
                        if isempty(find(usedNodes==0))
                            datum=usedNodes(1);
                            usedNodes(1)=0;
                            if~isempty(rlc)
                                idx=find(rlc(:,1)==datum);
                                rlc(idx,1)=0;
                                idx=find(rlc(:,2)==datum);
                                rlc(idx,2)=0;
                            end
                            if~isempty(src)
                                idx=find(src(:,1)==datum);
                                src(idx,1)=0;
                                idx=find(src(:,2)==datum);
                                src(idx,2)=0;
                            end
                            for k=1:size(Y.vnn,1)
                                idx=find(Y.vnn(k,:)==datum);
                                if~isempty(idx)
                                    Y.vnn(k,idx)=0;
                                end
                            end
                        end
                        qtyNodes=length(usedNodes);
                        newNodes=0:qtyNodes-1;

                        for k=2:qtyNodes
                            if~isempty(rlc)
                                idx=find(rlc(:,1)==usedNodes(k));
                                nn=ones(length(idx),1)*newNodes(k);
                                rlc(idx,1)=nn;
                                idx=find(rlc(:,2)==usedNodes(k));
                                nn=ones(length(idx),1)*newNodes(k);
                                rlc(idx,2)=nn;
                            end
                            if~isempty(src)
                                idx=find(src(:,1)==usedNodes(k));
                                nn=ones(length(idx),1)*newNodes(k);
                                src(idx,1)=nn;
                                idx=find(src(:,2)==usedNodes(k));
                                nn=ones(length(idx),1)*newNodes(k);
                                src(idx,2)=nn;
                            end
                            if~isempty(Y.vnn)
                                idx=find(Y.vnn(:,1)==usedNodes(k));
                                nn=ones(length(idx),1)*newNodes(k);
                                Y.vnn(idx,1)=nn;
                                idx=find(Y.vnn(:,2)==usedNodes(k));
                                nn=ones(length(idx),1)*newNodes(k);
                                Y.vnn(idx,2)=nn;
                            end
                        end
                        node=qtyNodes;








                        function[Trf,qtyTrf,idxTrfMag,idxTrfWdgs,rlc]=...
                            getTransformerData(rlc,commandLine,circ2ssInfo)

                            if~isempty(rlc)
                                idxWdgs=find(rlc(:,3)==2)';
                            else
                                idxWdgs=[];
                            end

                            qtyWdgs=length(idxWdgs);
                            if qtyWdgs>0
                                idxMag=zeros(1,ceil(qtyWdgs/2));
                                l=1;
                                for k=1:qtyWdgs-1
                                    if(idxWdgs(k+1)>(idxWdgs(k)+1))
                                        idxMag(l)=idxWdgs(k)+1;
                                        l=l+1;
                                    end
                                end
                                idxMag(l)=idxWdgs(k)+2;
                                idxMag=idxMag(find(idxMag));
                                qtyTrf=l;


                                idxTrfWdgs=idxWdgs;
                                idxTrfMag=idxMag;
















                                Trf=struct('qtyWdgs',[],'wdgs',[],'mag',[],'midNodes',[],'Saturable',[]);
                                for k=1:qtyTrf
                                    idxm=idxMag(k);
                                    thisTrf=find(idxWdgs<idxm);
                                    Trf(k).qtyWdgs=length(thisTrf);
                                    N=[1,[rlc(idxWdgs(thisTrf(2:Trf(k).qtyWdgs)),6)./...
                                    rlc(idxWdgs(1),6)]'];


                                    if rlc(idxm,5)==-1
                                        rlc(idxm,5)=0;
                                        Trf(k).Saturable=1;
                                    else
                                        Trf(k).Saturable=0;
                                    end

                                    Trf(k).mag=[rlc(idxm,1),rlc(idxm,2),rlc(idxm,4),rlc(idxm,5)...
                                    ,rlc(idxm,7)];

                                    for m=1:Trf(k).qtyWdgs
                                        idx1=thisTrf(m);
                                        Trf(k).wdgs(m,:)=[rlc(idxWdgs(idx1),1),rlc(idxWdgs(idx1),2),...
                                        rlc(idxWdgs(idx1),4),rlc(idxWdgs(idx1),5),N(m)...
                                        ,rlc(idxWdgs(idx1),7)];
                                    end


                                    if commandLine
                                        rlcm=circ2ssInfo.rlcm;
                                        Trf(k).midNodes(1,:)=rlcm(idxm,1);
                                        for m=2:Trf(k).qtyWdgs
                                            Trf(k).midNodes(m,:)=rlcm(idxWdgs(thisTrf(m)),2);
                                        end
                                    end
                                    idxWdgs=idxWdgs(Trf(k).qtyWdgs+1:length(idxWdgs));
                                end

                                k=qtyTrf:-1:1;
                                rlc(idxMag(k),:)=[];
                                k=find(rlc(:,3)==2);
                                rlc(k,:)=[];
                            else

                                qtyTrf=0;
                                Trf=[];
                                idxTrfMag=[];
                                idxTrfWdgs=[];
                            end









                            function[Mut,qtyMut,rlc]=getMutualData(rlc)



                                if~isempty(rlc)
                                    idxWdgs=find(rlc(:,3)==3)';
                                else
                                    idxWdgs=[];
                                end
                                qtyWdgs=length(idxWdgs);
                                qtyMut1=0;
                                if qtyWdgs>0









                                    Mut=struct('qtyWdgs',[],'mag',[],'wdgs',[]);
                                    idxMag=zeros(1,ceil(qtyWdgs/2));



                                    l=1;
                                    for k=1:qtyWdgs-1
                                        if(idxWdgs(k+1)>(idxWdgs(k)+1))
                                            idxMag(l)=idxWdgs(k)+1;
                                            l=l+1;
                                        end
                                    end
                                    idxMag(l)=idxWdgs(k)+2;
                                    idxMag=idxMag(find(idxMag));
                                    idxMutWdgs=idxWdgs;
                                    idxMutMag=idxMag;

                                    qtyMut1=l;
                                    for k=1:qtyMut1
                                        idxm=idxMag(k);
                                        thisMut=find(idxWdgs<idxm);
                                        Mut(k).qtyWdgs=length(thisMut);
                                        Mut(k).mag=[rlc(idxm,1),rlc(idxm,2),rlc(idxm,4),rlc(idxm,5)...
                                        ,rlc(idxm,7)];
                                        for m=1:Mut(k).qtyWdgs
                                            idx1=thisMut(m);
                                            Mut(k).wdgs(m,:)=[rlc(idxWdgs(idx1),1),rlc(idxWdgs(idx1),2),...
                                            rlc(idxWdgs(idx1),4),rlc(idxWdgs(idx1),5)...
                                            ,rlc(idxWdgs(idx1),7)];
                                        end
                                        idxWdgs=idxWdgs(Mut(k).qtyWdgs+1:length(idxWdgs));
                                    end
                                    k=qtyMut1:-1:1;
                                    rlc(idxMag(k),:)=[];
                                    k=find(rlc(:,3)==3);
                                    rlc(k,:)=[];
                                else
                                    qtyMut1=0;
                                    Mut=[];
                                end



                                if~isempty(rlc)
                                    idxWdgs=find(rlc(:,3)==4)';
                                else
                                    idxWdgs=[];
                                end
                                qtyWdgs=length(idxWdgs);

                                if qtyWdgs>0
                                    if~isstruct(Mut)









                                        Mut=struct('qtyWdgs',[],'mag',[],'wdgs',[]);
                                    end
                                    idxMag=zeros(1,qtyWdgs*(qtyWdgs-1)/2);



                                    l=1;
                                    for k=1:qtyWdgs-1
                                        if(idxWdgs(k+1)>(idxWdgs(k)+1))
                                            idxMag(l)=idxWdgs(k)+1;
                                            l=l+1;
                                        end
                                    end
                                    idxMag(l)=idxWdgs(k)+2;
                                    idxMag=idxMag(find(idxMag));
                                    idxMutWdgs=idxWdgs;
                                    idxMutMag=idxMag;

                                    qtyMut2=l;
                                    for k=1:qtyMut2
                                        idxm=idxMag(1,k);
                                        thisMut=find(idxWdgs<idxm);



                                        idx=qtyMut1+k;

                                        Mut(idx).qtyWdgs=length(thisMut);


                                        nbMutualRows=Mut(idx).qtyWdgs*(Mut(idx).qtyWdgs-1)/2;
                                        idxCouplingTerms=idxWdgs(thisMut(end))+...
                                        1:idxWdgs(thisMut(end))+nbMutualRows;


                                        idxMag(2,k)=idxCouplingTerms(end);





                                        l=1;
                                        for m=1:Mut(idx).qtyWdgs
                                            idx1=thisMut(m);
                                            Mut(idx).wdgs(m,:)=[rlc(idxWdgs(idx1),1),rlc(idxWdgs(idx1),2),...
                                            rlc(idxWdgs(idx1),4),rlc(idxWdgs(idx1),5)...
                                            ,rlc(idxWdgs(idx1),7)];

                                            Mut(idx).R(m,m)=rlc(idxWdgs(idx1),4);
                                            Mut(idx).L(m,m)=rlc(idxWdgs(idx1),5);
                                            for n=m+1:Mut(idx).qtyWdgs
                                                idx2=idxCouplingTerms(l);
                                                Mut(idx).R(m,n)=rlc(idx2,4);
                                                Mut(idx).L(m,n)=rlc(idx2,5);
                                                Mut(idx).R(n,m)=Mut(idx).R(m,n);
                                                Mut(idx).L(n,m)=Mut(idx).L(m,n);
                                                l=l+1;
                                            end
                                        end
                                        idxWdgs=idxWdgs(Mut(idx).qtyWdgs+1:length(idxWdgs));
                                    end


                                    k=qtyMut2:-1:1;
                                    for m=1:length(k)
                                        rlc(idxMag(1,k(m)):idxMag(2,k(m)),:)=[];
                                    end


                                    k=find(rlc(:,3)==4);
                                    rlc(k,:)=[];
                                else
                                    qtyMut2=0;
                                end

                                qtyMut=qtyMut1+qtyMut2;








                                function rlc=updatePiLineData(idxLine,rlc,circ2ssInfo)




                                    qtyLine=size(idxLine,1);
                                    if~isempty(rlc)
                                        rlc(idxLine,3:6)=[zeros(qtyLine,1),circ2ssInfo.rlc1(idxLine,1:3)];
                                    end

                                    for k=1:qtyLine
                                        for m=9:10
                                            idx1=find(rlc(:,7)==rlc(idxLine(k),m));
                                            rlc(idx1,6)=circ2ssInfo.c_ligne(idxLine(k));
                                        end
                                    end








                                    function[out,orgEdgeNbrs,rlc,edge,node]=...
                                        setSeriesBranchesOutputData(rlc,node)



                                        if~isempty(rlc)
                                            idxSer=find(rlc(:,3)==0)';
                                        else
                                            idxSer=[];
                                        end

                                        qtySer=length(idxSer);
                                        edge=1;
                                        out=[];
                                        orgEdgeNbrs=[];

                                        if qtySer>0
                                            out=zeros(qtySer*3,8);

                                            orgEdgeNbrs=zeros(qtySer*3,1);
                                            for k=1:qtySer
                                                RLCname=rlc(idxSer(k),7);
                                                RLC=rlc(idxSer(k),4:6);
                                                n1=rlc(idxSer(k),1);
                                                n2=rlc(idxSer(k),2);
                                                typ=sum((RLC~=0).*[4,2,1]);
                                                switch typ
                                                case 1
                                                    out(edge,1:5)=[edge,2,n1,n2,RLC(3)];
                                                    orgEdgeNbrs(edge,1)=RLCname;
                                                    edge=edge+1;
                                                case 2
                                                    out(edge,1:5)=[edge,8,n1,n2,RLC(2)];
                                                    orgEdgeNbrs(edge,1)=RLCname;
                                                    edge=edge+1;
                                                case 3
                                                    out(edge,1:5)=[edge,8,n1,node,RLC(2)];
                                                    orgEdgeNbrs(edge,1)=RLCname;
                                                    edge=edge+1;
                                                    out(edge,1:5)=[edge,2,node,n2,RLC(3)];
                                                    orgEdgeNbrs(edge,1)=RLCname;
                                                    edge=edge+1;
                                                    node=node+1;
                                                case 4
                                                    out(edge,1:5)=[edge,4,n1,n2,RLC(1)];
                                                    orgEdgeNbrs(edge,1)=RLCname;
                                                    edge=edge+1;
                                                case 5
                                                    out(edge,1:5)=[edge,4,n1,node,RLC(1)];
                                                    orgEdgeNbrs(edge,1)=RLCname;
                                                    edge=edge+1;
                                                    out(edge,1:5)=[edge,2,node,n2,RLC(3)];
                                                    orgEdgeNbrs(edge,1)=RLCname;
                                                    edge=edge+1;
                                                    node=node+1;
                                                case 6
                                                    out(edge,1:5)=[edge,4,n1,node,RLC(1)];
                                                    orgEdgeNbrs(edge,1)=RLCname;
                                                    edge=edge+1;
                                                    out(edge,1:5)=[edge,8,node,n2,RLC(2)];
                                                    orgEdgeNbrs(edge,1)=RLCname;
                                                    edge=edge+1;
                                                    node=node+1;
                                                case 7
                                                    out(edge,1:5)=[edge,4,n1,node,RLC(1)];
                                                    orgEdgeNbrs(edge,1)=RLCname;
                                                    edge=edge+1;
                                                    out(edge,1:5)=[edge,8,node,node+1,RLC(2)];
                                                    orgEdgeNbrs(edge,1)=RLCname;
                                                    edge=edge+1;
                                                    out(edge,1:5)=[edge,2,node+1,n2,RLC(3)];
                                                    orgEdgeNbrs(edge,1)=RLCname;
                                                    edge=edge+1;
                                                    node=node+2;
                                                end
                                            end
                                            idx=find(out(:,1));
                                            out=out(idx,:);
                                            idx=find(orgEdgeNbrs);
                                            orgEdgeNbrs=orgEdgeNbrs(idx);
                                            k=qtySer:-1:1;
                                            rlc(idxSer(k),:)=[];
                                        end








                                        function[out,orgEdgeNbrs,rlc,edge]=...
                                            setParallelBranchesOutputData(out,orgEdgeNbrs,rlc,edge);

                                            if~isempty(rlc)
                                                idxPar=find(rlc(:,3)==1)';
                                            else
                                                idxPar=[];
                                            end
                                            qtyPar=length(idxPar);
                                            if qtyPar>0

                                                out=[out;zeros(qtyPar*3,8)];
                                                orgEdgeNbrs=[orgEdgeNbrs;zeros(qtyPar*3,1)];

                                                for k=1:qtyPar
                                                    RLCname=rlc(idxPar(k),7);
                                                    RLC=rlc(idxPar(k),4:6);
                                                    n1=rlc(idxPar(k),1);
                                                    n2=rlc(idxPar(k),2);
                                                    typ=sum((RLC~=0).*[4,2,1]);
                                                    switch typ
                                                    case 1
                                                        out(edge,1:5)=[edge,2,n1,n2,RLC(3)];
                                                        orgEdgeNbrs(edge,1)=RLCname;
                                                        edge=edge+1;
                                                    case 2
                                                        out(edge,1:5)=[edge,8,n1,n2,RLC(2)];
                                                        orgEdgeNbrs(edge,1)=RLCname;
                                                        edge=edge+1;
                                                    case 3
                                                        out(edge,1:5)=[edge,8,n1,n2,RLC(2)];
                                                        orgEdgeNbrs(edge,1)=RLCname;
                                                        edge=edge+1;
                                                        out(edge,1:5)=[edge,2,n1,n2,RLC(3)];
                                                        orgEdgeNbrs(edge,1)=RLCname;
                                                        edge=edge+1;
                                                    case 4
                                                        out(edge,1:5)=[edge,4,n1,n2,RLC(1)];
                                                        orgEdgeNbrs(edge,1)=RLCname;
                                                        edge=edge+1;
                                                    case 5
                                                        out(edge,1:5)=[edge,4,n1,n2,RLC(1)];
                                                        orgEdgeNbrs(edge,1)=RLCname;
                                                        edge=edge+1;
                                                        out(edge,1:5)=[edge,2,n1,n2,RLC(3)];
                                                        orgEdgeNbrs(edge,1)=RLCname;
                                                        edge=edge+1;
                                                    case 6
                                                        out(edge,1:5)=[edge,4,n1,n2,RLC(1)];
                                                        orgEdgeNbrs(edge,1)=RLCname;
                                                        edge=edge+1;
                                                        out(edge,1:5)=[edge,8,n1,n2,RLC(2)];
                                                        orgEdgeNbrs(edge,1)=RLCname;
                                                        edge=edge+1;
                                                    case 7
                                                        out(edge,1:5)=[edge,4,n1,n2,RLC(1)];
                                                        orgEdgeNbrs(edge,1)=RLCname;
                                                        edge=edge+1;
                                                        out(edge,1:5)=[edge,8,n1,n2,RLC(2)];
                                                        orgEdgeNbrs(edge,1)=RLCname;
                                                        edge=edge+1;
                                                        out(edge,1:5)=[edge,2,n1,n2,RLC(3)];
                                                        orgEdgeNbrs(edge,1)=RLCname;
                                                        edge=edge+1;
                                                    end
                                                end
                                                idx=find(out(:,1));
                                                out=out(idx,:);
                                                idx=find(orgEdgeNbrs);
                                                orgEdgeNbrs=orgEdgeNbrs(idx);
                                                k=qtyPar:-1:1;
                                                rlc(idxPar(k),:)=[];
                                            else

                                            end








                                            function[out,orgEdgeNbrs,rlc,edge,node,liste_neu2]=...
                                                setTransformerOutputData(out,orgEdgeNbrs,rlc,edge,node,...
                                                Trf,qtyTrf,idxTrfMag,idxTrfWdgs,liste_neu2,commandLine)


                                                out=[out;zeros(11*qtyTrf,8)];
                                                orgEdgeNbrs=[orgEdgeNbrs;zeros(qtyTrf*11,1)];

                                                for k=1:qtyTrf

                                                    RLCname=Trf(k).mag(5);
                                                    cond1=isfinite(Trf(k).mag(3));
                                                    cond2=isfinite(Trf(k).mag(4))&Trf(k).mag(4)>0;
                                                    if cond1
                                                        out(edge,1:5)=[edge,4,Trf(k).mag(1),Trf(k).mag(2)...
                                                        ,Trf(k).mag(3)];
                                                        orgEdgeNbrs(edge,1)=RLCname;
                                                        edge=edge+1;
                                                    end
                                                    if cond2
                                                        out(edge,1:5)=[edge,8,Trf(k).mag(1),Trf(k).mag(2)...
                                                        ,Trf(k).mag(4)];
                                                        orgEdgeNbrs(edge,1)=RLCname;
                                                        edge=edge+1;
                                                    end

                                                    for m=1:Trf(k).qtyWdgs
                                                        cond3=Trf(k).wdgs(m,3)==0;
                                                        cond4=Trf(k).wdgs(m,4)==0;





                                                        wdgState=(cond3&cond4)+(~cond3&cond4)*2+(cond3&~cond4)*3+...
                                                        (~cond3&~cond4)*4;

                                                        if(wdgState>1)

                                                            if((m==1)&&(cond1|cond2|Trf(k).Saturable))
                                                                wdgNode1=Trf(k).mag(1);
                                                            else
                                                                wdgNode1=node;
                                                                node=node+1;
                                                            end
                                                        end

                                                        RLCname=Trf(k).wdgs(m,6);


                                                        switch wdgState
                                                        case 1
                                                            wdgNode1=Trf(k).wdgs(m,1);
                                                        case 2
                                                            if(commandLine&m>1)


                                                                out(edge,1:5)=[edge,4,Trf(k).wdgs(m,1),node...
                                                                ,Trf(k).wdgs(m,3)/2];
                                                                orgEdgeNbrs(edge,1)=RLCname;
                                                                edge=edge+1;
                                                                out(edge,1:5)=[edge,4,node,wdgNode1...
                                                                ,Trf(k).wdgs(m,3)/2];
                                                                if commandLine
                                                                    Trf(k).midNodes(m,2)=node;
                                                                end
                                                                orgEdgeNbrs(edge,1)=RLCname;
                                                                edge=edge+1;
                                                                node=node+1;
                                                            else
                                                                if commandLine
                                                                    Trf(k).midNodes(m,2)=wdgNode1;
                                                                end
                                                                out(edge,1:5)=[edge,4,Trf(k).wdgs(m,1),wdgNode1...
                                                                ,Trf(k).wdgs(m,3)];
                                                                orgEdgeNbrs(edge,1)=RLCname;
                                                                edge=edge+1;
                                                            end
                                                        case 3
                                                            out(edge,1:5)=[edge,8,Trf(k).wdgs(m,1),wdgNode1...
                                                            ,Trf(k).wdgs(m,4)];
                                                            orgEdgeNbrs(edge,1)=RLCname;
                                                            edge=edge+1;
                                                        case 4
                                                            if commandLine
                                                                Trf(k).midNodes(m,2)=wdgNode1;
                                                            end
                                                            out(edge,1:5)=[edge,4,Trf(k).wdgs(m,1),node...
                                                            ,Trf(k).wdgs(m,3)];
                                                            orgEdgeNbrs(edge,1)=RLCname;
                                                            edge=edge+1;
                                                            out(edge,1:5)=[edge,8,node,wdgNode1,Trf(k).wdgs(m,4)];
                                                            orgEdgeNbrs(edge,1)=RLCname;
                                                            edge=edge+1;
                                                            node=node+1;
                                                        end


                                                        if m==1

                                                            out(edge,1:7)=[edge,11,wdgNode1,Trf(k).wdgs(m,2),0,0,k];
                                                            orgEdgeNbrs(edge,1)=RLCname;
                                                            edge=edge+1;
                                                        else

                                                            out(edge,1:8)=[edge,3,wdgNode1,Trf(k).wdgs(m,2),0,0,k...
                                                            ,Trf(k).wdgs(m,5)];
                                                            orgEdgeNbrs(edge,1)=RLCname;
                                                            edge=edge+1;
                                                        end
                                                    end
                                                end

                                                idx=find(out(:,1));
                                                out=out(idx,:);
                                                idx=find(orgEdgeNbrs);
                                                orgEdgeNbrs=orgEdgeNbrs(idx);
                                                if commandLine
                                                    for k=1:qtyTrf
                                                        idxm=idxTrfMag(k);
                                                        thisTrf=find(idxTrfWdgs<idxm);
                                                        for m=1:length(thisTrf)


                                                            if m>1
                                                                cand=[Trf(k).midNodes(m,2)];
                                                            end
                                                        end

                                                        for m=1:length(cand)
                                                            idx1=find(liste_neu2==cand(m));
                                                            if isempty(idx1)
                                                                liste_neu2=[liste_neu2,cand(m)];
                                                            end
                                                        end


                                                        idxTrfWdgs=idxTrfWdgs(Trf(k).qtyWdgs+1:length(idxTrfWdgs));

                                                    end
                                                end








                                                function[out,orgEdgeNbrs,rlc,edge,node]=...
                                                    setMutualOutpuData(out,orgEdgeNbrs,rlc,edge,node,Mut,qtyMut)











                                                    qtyWdgs=0;
                                                    for k=1:qtyMut
                                                        qtyWdgs=qtyWdgs+Mut(k).qtyWdgs;
                                                    end



                                                    out=[out;zeros(qtyWdgs,8)];


                                                    orgEdgeNbrs=[orgEdgeNbrs;zeros(qtyWdgs*3,1)];
                                                    for k=1:qtyMut





                                                        if~isempty(Mut(k).mag)

                                                            purelyResistive=all(Mut(k).wdgs(:,4)==0)&&(Mut(k).mag(4)==0);
                                                            purelyInductive=all(Mut(k).wdgs(:,3)==0)&&(Mut(k).mag(3)==0);
                                                        else

                                                            purelyResistive=all(all(Mut(k).L==0));
                                                            purelyInductive=all(all(Mut(k).R==0));
                                                        end

                                                        for m=1:Mut(k).qtyWdgs
                                                            RLCname=Mut(k).wdgs(m,5);
                                                            if purelyInductive

                                                                out(edge,1:6)=[edge,10,Mut(k).wdgs(m,1),Mut(k).wdgs(m,2)...
                                                                ,Mut(k).wdgs(m,4),k];
                                                                orgEdgeNbrs(edge,1)=RLCname;
                                                                edge=edge+1;
                                                            elseif purelyResistive

                                                                out(edge,1:6)=[edge,7,Mut(k).wdgs(m,1),Mut(k).wdgs(m,2)...
                                                                ,Mut(k).wdgs(m,3),k];
                                                                orgEdgeNbrs(edge,1)=RLCname;
                                                                edge=edge+1;
                                                            elseif~purelyResistive&&~purelyInductive

                                                                out(edge,1:6)=[edge,7,Mut(k).wdgs(m,1),node...
                                                                ,Mut(k).wdgs(m,3),k];
                                                                orgEdgeNbrs(edge,1)=RLCname;
                                                                edge=edge+1;
                                                                out(edge,1:6)=[edge,10,node,Mut(k).wdgs(m,2)...
                                                                ,Mut(k).wdgs(m,4),k];
                                                                orgEdgeNbrs(edge,1)=RLCname;
                                                                edge=edge+1;
                                                                node=node+1;
                                                            end
                                                        end
                                                    end

                                                    idx=find(out(:,1));
                                                    out=out(idx,:);
                                                    idx=find(orgEdgeNbrs);
                                                    orgEdgeNbrs=orgEdgeNbrs(idx);








                                                    function[out,orgEdgeNbrs,edge,idxSrc]=...
                                                        setSourcesOutputData(out,orgEdgeNbrs,src,edge)

                                                        idxE=find(src(:,3)==0)';
                                                        qtyE=length(idxE);
                                                        idxJ=find(src(:,3)==1)';
                                                        qtyJ=length(idxJ);
                                                        out=[out;zeros(qtyE+qtyJ,8)];
                                                        srcNames=zeros(qtyE+qtyJ,1);
                                                        for k=1:qtyE
                                                            out(edge,1:4)=[edge,1,src(idxE(k),1),src(idxE(k),2)];
                                                            orgEdgeNbrs(edge,1)=-idxE(k);
                                                            idxSrc(k)=idxE(k);
                                                            edge=edge+1;
                                                        end

                                                        for k=1:qtyJ
                                                            out(edge,1:4)=[edge,12,src(idxJ(k),1),src(idxJ(k),2)];
                                                            orgEdgeNbrs(edge,1)=-idxJ(k);
                                                            idxSrc(k+qtyE)=idxJ(k);
                                                            edge=edge+1;
                                                        end









                                                        function[names,srcNames,outNames]=getLists(psbInfo,commandLine)

                                                            if~commandLine
                                                                names=psbInfo.rlcnames;
                                                                srcNames=cellstr(psbInfo.srcstr);

                                                                outNames=cellstr(psbInfo.outstr);
                                                                if~isempty(names)
                                                                    names=strrep(names,char(10),' ');
                                                                end
                                                                if~isempty(srcNames)
                                                                    srcNames=strrep(srcNames,char(10),' ');
                                                                end
                                                                if~isempty(outNames)
                                                                    outNames=strrep(outNames,char(10),' ');
                                                                end
                                                            else
                                                                names=[];
                                                                srcNames=[];
                                                                outNames=[];
                                                            end






