function[hdlbody,hdlsignals,phaseSignals]=multiCounterPhaseDecoder(this,clkenable,maxCount,uniqueOffsets,registerout)































    hdlsignals=[];
    hdlbody=[];








    [counterSizes,firstPhase]=findCounterSizes(uniqueOffsets,maxCount);

    uniqueCounters=unique(counterSizes);

    for i=1:length(uniqueCounters)
        count=uniqueCounters(i);

        [cntvtype,cntsltype]=hdlgettypesfromsizes(ceil(log2(count)),0,0);
        [idxname,counter_out]=hdlnewsignal(['count',num2str(count)],'block',-1,0,0,cntvtype,cntsltype);

        hdlregsignal(counter_out);
        hdlsignals=[hdlsignals,makehdlsignaldecl(counter_out)];



        ProcessName=['Counter',num2str(count)];



        counterSizesIdx=find(counterSizes==uniqueCounters(i));

        if count==maxCount

            phase=uniqueOffsets(find(counterSizes==count));
        else
            phase=firstPhase(counterSizesIdx);
        end


        [tmphdlbody,tmphdlsignals]=hdlcounter(counter_out,count,ProcessName,1,1,phase,registerout);
        hdlsignals=[hdlsignals,makehdlsignaldecl(tmphdlsignals)];
        hdlbody=[hdlbody,tmphdlbody];



        for j=1:length(counterSizesIdx)
            phaseSignals(counterSizesIdx(j))=tmphdlsignals(j);
        end
    end









    function[counter,phase]=findCounterSizes(offsets,maxCount)

        counter=zeros(1,length(offsets));
        phase=zeros(1,length(offsets));

        for i=1:length(offsets)
            offsetsVector=cell2mat(offsets(i));
            if length(offsetsVector)==1||length(offsetsVector)==maxCount
                counter(i)=maxCount;
                phase(i)=offsetsVector(1);
            else
                counter(i)=abs(offsetsVector(2)-offsetsVector(1));
                phase(i)=offsetsVector(1);
            end
        end



