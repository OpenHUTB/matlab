function mcNet=elabMedianCore(this,topNet,blockInfo,dataRate)





    bankWL=ceil(log2(blockInfo.NSize));
    bankType=pir_ufixpt_t(bankWL,0);
    ctlType=pir_boolean_t();
    NSize=blockInfo.NSize;
    bSize=blockInfo.bSize;
    inTop=topNet.PirInputSignals(1);
    dinType=inTop.Type;
    dinvType=pirelab.getPirVectorType(dinType,NSize);



    mcNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','MedianCore',...
    'InportNames',{'dataCol','processData'},...
    'InportTypes',[dinvType,ctlType],...
    'InportRates',[dataRate,dataRate],...
    'OutportNames',{'medianValue'},...
    'OutportTypes',dinType...
    );


    dataCol=mcNet.PirInputSignals(1);
    processData=mcNet.PirInputSignals(2);
    medianValue=mcNet.PirOutputSignals(1);








    dataColsplit=dataCol.split;
    for i=1:NSize

        d(i)=dataColsplit.PirOutputSignals(i);
    end



    t3=[1,2;2,3;1,2];
    t5=[1,2,3,4;2,4,3,5;1,3,2,5;2,3,4,5;3,4,0,0];
    t7=[1,2,3,4,5,6;1,3,2,4,5,7;1,5,2,6,3,7;2,5,4,7,0,0;3,5,4,6,0,0;2,3,4,5,6,7];

    switch NSize
    case 3
        sTable=t3;
    case 5
        sTable=t5;
    case 7
        sTable=t7;
    otherwise
        sTable=t3;

    end



    msNet=this.elabSort2(mcNet,dataRate,dinType);
    msNet.addComment('Compare two value');
    msiNet=this.elabSort2_Idx(mcNet,dataRate,NSize,dinType);
    msiNet.addComment('Compare two value with Idx');


    [scol,addDelay,sortNdelay]=sortN(mcNet,msNet,d,NSize,sTable,'sortedIn');

    if addDelay
        dcol(1)=mcNet.addSignal(dinvType,'dCol1');
        pirelab.getUnitDelayComp(mcNet,scol,dcol(1));
        sortNdelay=sortNdelay+1;
    else
        dcol(1)=scol;
    end


    dprocessData=mcNet.addSignal(ctlType,'dprocessData');
    pirelab.getIntDelayComp(mcNet,processData,dprocessData,sortNdelay);

    for i=1:NSize-1
        dcol(i+1)=mcNet.addSignal(dinvType,['dCol',num2str(i+1)]);


        delaycomp=pirelab.getUnitDelayEnabledComp(mcNet,dcol(i),dcol(i+1),dprocessData);

    end

    for i=1:NSize
        dsplit=dcol(i).split;
        medians(i)=dsplit.PirOutputSignals(bSize+1);
    end



    [medianIdx,delayIdx]=sortNIdx(mcNet,msiNet,medians,bankType,NSize,sTable,'sortMedians');


    if delayIdx>0

        len=length(dcol);

        for ii=len+delayIdx:-1:len+1

            dcol(ii)=mcNet.addSignal(dinvType,['dcol',num2str(ii)]);
            pirelab.getIntDelayComp(mcNet,dcol(ii-1),dcol(ii),delayIdx);

        end
    end




    for i=1:NSize
        sfcol(i)=mcNet.addSignal(dinvType,['sfCol',num2str(i)]);
        sfcolReg(i)=mcNet.addSignal(dinvType,['sfColReg',num2str(i)]);
        comp=pirelab.getMultiPortSwitchComp(mcNet,[medianIdx(i),dcol(1+delayIdx:end)],sfcol(i),1,0,'Floor','Wrap');
        comp.addComment('Shuffle the data col based on the order of median values');
        pirelab.getUnitDelayComp(mcNet,sfcol(i),sfcolReg(i));
        sfcolsplit(i)=sfcolReg(i).split;

    end


    if NSize==3



        uncoveredReg=sortN(mcNet,msNet,[sfcolsplit(1).PirOutputSignals(3),sfcolsplit(2).PirOutputSignal(2),sfcolsplit(3).PirOutputSignal(1)],NSize,sTable,'sortedUncover');

        uncoveredRegSplit=uncoveredReg.split;
        uncoveredReg2=uncoveredRegSplit.PirOutputSignals(2);

        mm=sfcolsplit(2).PirOutputSignal(2);
        uorderv1=sfcolsplit(2).PirOutputSignal(3);
        uorderv2=sfcolsplit(2).PirOutputSignal(1);

        mmReg=mcNet.addSignal(dinType,'mmReg');
        uorderv1Reg=mcNet.addSignal(dinType,'uorderv1Reg');
        uorderv2Reg=mcNet.addSignal(dinType,'uorderv2Reg');

        mucsel=mcNet.addSignal(ctlType,'mucSel');
        muosel=mcNet.addSignal(ctlType,'muoSel');
        msel=mcNet.addSignal(ctlType,'mSel');

        pirelab.getUnitDelayComp(mcNet,mm,mmReg);
        pirelab.getUnitDelayComp(mcNet,uorderv1,uorderv1Reg);
        pirelab.getUnitDelayComp(mcNet,uorderv2,uorderv2Reg);

        comp=pirelab.getRelOpComp(mcNet,[mmReg,uncoveredReg2],mucsel,'<');
        comp.addComment('Find median of medians location');

        unordervalue=mcNet.addSignal(dinType,'unorderValue');


        pirelab.getSwitchComp(mcNet,[uorderv1Reg,uorderv2Reg],unordervalue,mucsel,'','==',1);
        pirelab.getRelOpComp(mcNet,[unordervalue,uncoveredReg2],muosel,'<');

        pirelab.getLogicComp(mcNet,[mucsel,muosel],msel,'xor');

        pirelab.getSwitchComp(mcNet,[uncoveredReg2,unordervalue],medianValue,msel,'','==',1);
    else




        mp=bSize+1;
        lcorner1=sfcolsplit(1).pirOutputSignals(mp+1:NSize);

        for i=2:bSize

            lcorner2=sfcolsplit(i).pirOutputSignals(mp+1:NSize);

            if i>2
                for k=1:length(lcorner2)
                    lcorner2Reg(k,i-2)=mcNet.addSignal(dinType,[lcorner2(k).Name,'Reg']);
                    pirelab.getIntDelayComp(mcNet,lcorner2(k),lcorner2Reg(k,i-2),1);

                end
                lcorner2=lcorner2Reg(:,i-2);
            end

            lcorner1=oddEvenmergehdl(mcNet,msNet,lcorner1,lcorner2,['lcorner',num2str(i-1)]);

            for kk=1:length(lcorner1)
                lcorner1Reg(kk,i-1)=mcNet.addSignal(dinType,['lcorner1Reg',num2str(kk),'_',num2str(i-1)]);
                pirelab.getIntDelayComp(mcNet,lcorner1(kk),lcorner1Reg(kk,i-1),1);
            end
            lcorner1=lcorner1Reg(:,i-1);

        end
        lcornerReg=lcorner1;















        rcorner1=sfcolsplit(mp+1).pirOutputSignals(1:mp-1);
        for i=mp+2:NSize
            rcorner2=sfcolsplit(i).pirOutputSignals(1:mp-1);
            if i>(mp+2)
                for k=1:length(rcorner2)
                    rcorner2Reg(k,i-(mp+2))=mcNet.addSignal(dinType,[rcorner2(k).Name,'Reg']);
                    pirelab.getIntDelayComp(mcNet,rcorner2(k),rcorner2Reg(k,i-(mp+2)),1);

                end
                rcorner2=rcorner2Reg(:,i-(mp+2));
            end

            rcorner1=oddEvenmergehdl(mcNet,msNet,rcorner1,rcorner2,['rcorner',num2str(NSize-i+1)]);

            for kk=1:length(rcorner1)
                rcorner1Reg(kk,i-mp-1)=mcNet.addSignal(dinType,['rcorner1Reg',num2str(kk),'_',num2str(i-mp-1)]);
                pirelab.getIntDelayComp(mcNet,rcorner1(kk),rcorner1Reg(kk,i-mp-1),1);
            end
            rcorner1=rcorner1Reg(:,i-mp-1);
        end
        rcornerReg=rcorner1;














        corner=oddEvenmergehdl(mcNet,msNet,lcornerReg,rcornerReg,'corner');

        for i=1:length(corner)
            cornerReg(i)=mcNet.addSignal(dinType,['cornerReg',num2str(i)]);
            pirelab.getIntDelayComp(mcNet,corner(i),cornerReg(i),1);
        end


        if NSize==5
            mmdelay=2;
            uncovereddelay=3;
            regionSeldelay=5;
        else
            mmdelay=4;
            uncovereddelay=3;
            regionSeldelay=6;
        end



        mm=sfcolsplit(mp).PirOutputSignal(mp);
        mmReg=mcNet.addSignal(dinType,'mmReg');
        comp=pirelab.getIntDelayComp(mcNet,mm,mmReg,mmdelay);
        comp.addComment('Delay median of medians');

        regionSel=mcNet.addSignal(ctlType,'regionSel');
        comp=pirelab.getRelOpComp(mcNet,[mmReg,cornerReg(length(corner)/2)],regionSel,'<');
        comp.addComment('Find median of medians location');

        uncovered=oddEvenmergehdl(mcNet,msNet,cornerReg,mmReg,'uncover');



        for i=1:length(uncovered)
            uncoveredReg(i)=mcNet.addSignal(dinType,['uncoveredReg',num2str(i)]);
            pirelab.getIntDelayComp(mcNet,uncovered(i),uncoveredReg(i),uncovereddelay);
        end


        for i=1:NSize
            dsfcolReg(i)=mcNet.addSignal(dinvType,['dsfcolReg_',num2str(i)]);
            pirelab.getIntDelayComp(mcNet,sfcolReg(i),dsfcolReg(i),mmdelay);
            dsfcolRegsplit(i)=dsfcolReg(i).split;
        end



        ccornerdown(1:mp-1)=dsfcolRegsplit(mp).pirOutputSignals(mp+1:NSize);
        ccornerup(1:mp-1)=dsfcolRegsplit(mp).pirOutputSignals(1:mp-1);
        for jj=1:mp-1
            ccornerdown(mp*jj:(jj+1)*mp-1)=dsfcolRegsplit(mp+jj).pirOutputSignals(mp:NSize);
            ccornerup(mp*jj:(jj+1)*mp-1)=dsfcolRegsplit(mp-jj).pirOutputSignals(1:mp);
        end






        for k=1:length(ccornerdown)
            ccorner(k)=mcNet.addSignal(dinType,['ccorner_',num2str(k)]);
            pirelab.getSwitchComp(mcNet,[ccornerdown(k),ccornerup(k)],ccorner(k),regionSel,'','==',1);
        end



        for m=1:mp-1
            if m==1
                regin=ccorner;
            else
                regin=ccornerPReg(:,m-1);
            end
            for n=1:length(regin)
                ccornerPReg(n,m)=mcNet.addSignal(dinType,['ccornerPipeReg',num2str(n),'_',num2str(m)]);
                pirelab.getIntDelayComp(mcNet,regin(n),ccornerPReg(n,m),1);
            end
        end



        in1=ccornerPReg(1:mp-1,1);

        for jj=1:mp-1














            in2=ccornerPReg(mp*jj:(jj+1)*mp-1,jj);

            ccorner1=oddEvenmergehdl(mcNet,msNet,in1,in2,['ccorner',num2str(jj)]);

            for i=1:length(ccorner1)
                ccornerReg(i,jj)=mcNet.addSignal(dinType,['ccornerReg',num2str(i),'_',num2str(jj)]);
                pirelab.getIntDelayComp(mcNet,ccorner1(i),ccornerReg(i,jj),1);
            end
            in1=ccornerReg(:,jj);
        end




        finalseq=oddEvenmergehdl(mcNet,msNet,uncoveredReg,in1,'median');


        for i=1:length(finalseq)
            fseqReg(i)=mcNet.addSignal(dinType,['fseqReg',num2str(i)]);
            pirelab.getIntDelayComp(mcNet,finalseq(i),fseqReg(i),1);
        end



        dregionSel=mcNet.addSignal(ctlType,'dregionSel');

        pirelab.getIntDelayComp(mcNet,regionSel,dregionSel,regionSeldelay);


        idx2=floor(NSize*NSize/2)+1;
        idx1=idx2-length(ccorner);

        pirelab.getSwitchComp(mcNet,[fseqReg(idx1),fseqReg(idx2)],medianValue,dregionSel,'','==',1);


    end

end

function[sortCol,addDelay,sortNdelay]=sortN(mcNet,msNet,ins,NSize,sTable,sname)

    [stages,pcoms]=size(sTable);
    dinType=ins(1).Type;
    dinvType=pirelab.getPirVectorType(dinType,NSize);
    sIn=ins;
    m=1;
    sortNdelay=0;
    for i=1:stages
        for j=1:NSize
            if isempty(find(sTable(i,:)==j))
                sOut(i,j)=sIn(j);
            else
                sOut(i,j)=mcNet.addSignal(dinType,[sname,'_',num2str(i),'_',num2str(j)]);
            end
        end

        for k=1:2:pcoms
            t1=sTable(i,k);
            t2=sTable(i,k+1);
            if t1~=0
                pirelab.instantiateNetwork(mcNet,msNet,[sIn(t1),sIn(t2)],[sOut(i,t1),sOut(i,t2)],'msNet_inst');
            end
        end

        if rem(i,3)==0

            for jj=1:NSize
                sortColReg(m,jj)=mcNet.addSignal(dinType,[sname,'ColReg_',num2str(i),'_',num2str(jj)]);
                pirelab.getUnitDelayComp(mcNet,sOut(i,jj),sortColReg(m,jj),'sorted ColRegister');
            end
            sIn=sortColReg(m,:);
            m=m+1;
            sortNdelay=sortNdelay+1;
        else

            sIn=sOut(i,:);
        end
    end

    sortCol=mcNet.addSignal(dinvType,[sname,'ColVector']);
    pirelab.getMuxComp(mcNet,sIn,sortCol);
    addDelay=(rem(stages,3)~=0);
end




function[medianIdx,delay]=sortNIdx(mcNet,msiNet,medians,bankType,NSize,sTable,sname)

    dinType=medians(1).Type;

    for i=1:NSize
        startIdx(i)=mcNet.addSignal(bankType,['startIdx',num2str(i)]);

        pirelab.getConstComp(mcNet,startIdx(i),i,['const',num2str(i)]);
    end

    sIn=medians;
    idxIn=startIdx;

    [stages,pcoms]=size(sTable);
    m=1;
    for i=1:stages
        for j=1:NSize
            if isempty(find(sTable(i,:)==j))
                sOut(i,j)=sIn(j);
                sOutIdx(i,j)=idxIn(j);
            else
                sOut(i,j)=mcNet.addSignal(dinType,['sortedMedians_',num2str(i),'_',num2str(j)]);
                sOutIdx(i,j)=mcNet.addSignal(bankType,['sortedIdx_',num2str(i),'_',num2str(j)]);
            end
        end

        for k=1:2:pcoms
            t1=sTable(i,k);
            t2=sTable(i,k+1);
            if t1~=0
                pirelab.instantiateNetwork(mcNet,msiNet,[sIn(t1),idxIn(t1),sIn(t2),idxIn(t2)],...
                [sOut(i,t1),sOutIdx(i,t1),sOut(i,t2),sOutIdx(i,t2)],'msNet_inst');
            end
        end













        if rem(i,3)==0&&(NSize==3||(i~=stages))

            for jj=1:NSize
                sortColReg(m,jj)=mcNet.addSignal(dinType,[sname,'ColReg_',num2str(i),'_',num2str(jj)]);
                sortIdxReg(m,jj)=mcNet.addSignal(bankType,[sname,'IdxReg_',num2str(i),'_',num2str(jj)]);
                pirelab.getUnitDelayComp(mcNet,sOut(i,jj),sortColReg(m,jj),'sorted ColRegister');
                pirelab.getUnitDelayComp(mcNet,sOutIdx(i,jj),sortIdxReg(m,jj),'sorted IdxRegister');
            end
            sIn=sortColReg(m,:);
            idxIn=sortIdxReg(m,:);
            m=m+1;
        else

            sIn=sOut(i,:);
            idxIn=sOutIdx(i,:);
        end

    end
    medianIdx=idxIn;
    delay=m-1;
end



function y=oddEvenmergehdl(mcNet,msNet,s1,s2,sname)


    idxcnt=zeros(10,1);
    [odds1,evens1]=formOddEvenSequence(s1);
    [odds2,evens2]=formOddEvenSequence(s2);


    [c1,level1,idxcnt]=OddEvenMergecore(mcNet,msNet,odds1,evens2,0,idxcnt,sname);
    [c2,level2,idxcnt]=OddEvenMergecore(mcNet,msNet,odds2,evens1,0,idxcnt,sname);

    clevel=max(level1,level2);
    if mod(clevel,4)==0

        dType=c1(1).Type;
        for i=1:length(c1)
            c1Reg(i)=mcNet.addSignal(dType,[c1(i).Name,'Reg']);
            pirelab.getUnitDelayComp(mcNet,c1(i),c1Reg(i));
        end


        for i=1:length(c2)
            c2Reg(i)=mcNet.addSignal(dType,[c2(i).Name,'Reg']);
            pirelab.getUnitDelayComp(mcNet,c2(i),c2Reg(i));
        end


        c1_next=c1Reg;
        c2_next=c2Reg;
    else
        c1_next=c1;
        c2_next=c2;
    end
    level=clevel+1;







    y=finalCompare(mcNet,msNet,c1_next,c2_next,level,idxcnt,sname);

end


function[y,level,idxcnt]=OddEvenMergecore(mcNet,msNet,s1,s2,level,idxcnt,sname)

    n1=length(s1);
    n2=length(s2);

    if n2==0
        y=s1;
        level=level+1;
        for i=1:n1
            idxcnt(level)=idxcnt(level)+1;

        end

        return;
    elseif n1==0
        y=s2;

        level=level+1;

        for i=1:n2
            idxcnt(level)=idxcnt(level)+1;

        end

        return;
    else
        n=max(n1,n2);

    end



    if n>1
        [odds1,evens1]=formOddEvenSequence(s1);
        [odds2,evens2]=formOddEvenSequence(s2);


        [c1,level1,idxcnt]=OddEvenMergecore(mcNet,msNet,odds1,evens2,level,idxcnt,sname);
        [c2,level2,idxcnt]=OddEvenMergecore(mcNet,msNet,odds2,evens1,level,idxcnt,sname);






        clevel=max(level1,level2);

        if mod(clevel,4)==0

            dType=c1(1).Type;
            for i=1:length(c1)
                c1Reg(i)=mcNet.addSignal(dType,[c1(i).Name,'Reg']);
                pirelab.getUnitDelayComp(mcNet,c1(i),c1Reg(i));
            end


            for i=1:length(c2)
                c2Reg(i)=mcNet.addSignal(dType,[c2(i).Name,'Reg']);
                pirelab.getUnitDelayComp(mcNet,c2(i),c2Reg(i));
            end


            c1_next=c1Reg;
            c2_next=c2Reg;
        else
            c1_next=c1;
            c2_next=c2;
        end
        level=clevel+1;

        y=finalCompare(mcNet,msNet,c1_next,c2_next,level,idxcnt,sname);

    else
        level=level+1;

        [y,idxcnt]=finalCompare(mcNet,msNet,s1,s2,level,idxcnt,sname);

    end
end


function[odd,even]=formOddEvenSequence(s)

    odd=s(1:2:end);
    even=s(2:2:end);
end

function[y,idxcnt]=finalCompare(mcNet,msNet,c,d,level,idxcnt,sname)

    len1=length(c);
    len2=length(d);
    if len1==0
        y=d;
        idxcnt(level)=idxcnt(level)+1;


        return;
    elseif len2==0
        y=c;
        idxcnt(level)=idxcnt(level)+1;

        return;
    else
        len=min(len1,len2);
    end


    dType=c(1).Type;

    k=1;

    for i=1:len
        idxcnt(level)=idxcnt(level)+1;

        y(k)=mcNet.addSignal(dType,[sname,'L_',num2str(level),'_',num2str(idxcnt(level))]);
        idxcnt(level)=idxcnt(level)+1;

        y(k+1)=mcNet.addSignal(dType,[sname,'H_',num2str(level),'_',num2str(idxcnt(level))]);














        pirelab.instantiateNetwork(mcNet,msNet,[c(i),d(i)],[y(k),y(k+1)],'msNet_inst');
        k=k+2;
    end
    if len1~=len2
        idxcnt(level)=idxcnt(level)+1;

        if len==len1

            y(k)=d(end);
        else

            y(k)=c(end);
        end
    end
end
