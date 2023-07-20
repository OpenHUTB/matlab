function[hdlbody,hdlsignals]=multiCounterPhaseDecoder(this,maxCount,uniqueOffsets,registerout)


























    hdlsignals=[];
    hdlbody=[];


    [counterSizes,firstPhase]=findCounterSizes(this,uniqueOffsets);
    uniqueCounters=unique(counterSizes);

    for i=1:length(uniqueCounters)
        count=uniqueCounters(i);

        counterSizesIdx=find(counterSizes==count);
        dontNeedCounter=count==maxCount&&...
        numel(counterSizes(counterSizes==count))==1&&...
        all(uniqueOffsets{counterSizesIdx}==[0,1,count]);
        if count==1
            [cntvtype,cntsltype]=hdlgettypesfromsizes(1,0,0);
        else
            [cntvtype,cntsltype]=hdlgettypesfromsizes(ceil(log2(count)),0,0);
        end
        countStr=int2str(count);
        [~,counter_out]=hdlnewsignal(['count',countStr],'block',-1,0,0,cntvtype,cntsltype);
        hdlsignals=[hdlsignals,makehdlsignaldecl(counter_out)];%#ok<AGROW>
        hdlregsignal(counter_out);

        if count==maxCount

            phase=uniqueOffsets(counterSizes==count);
        else
            phase=firstPhase(counterSizesIdx);
        end


        [tmphdlbody,tmphdlsignals]=hdlcounter(counter_out,count,...
        ['Counter',countStr],1,1,phase,registerout);
        if dontNeedCounter


            if hdlgetparameter('isvhdl')
                tmphdlbody=regexp(tmphdlbody,['\\n  ',hdlsignalname(tmphdlsignals(1)),'.*\\n\\n'],'match');
            else
                tmphdlbody=regexp(tmphdlbody,'\\n  assign.*\\n\\n','match');
            end
            tmphdlbody=tmphdlbody{1};
        end
        hdlbody=[hdlbody,tmphdlbody];%#ok<AGROW>


        for j=1:length(counterSizesIdx)
            phaseSignals(counterSizesIdx(j))=tmphdlsignals(j);%#ok<AGROW>
        end
    end

    hdlsignals=[phaseSignals,hdlsignals];
end




function[counter,phase]=findCounterSizes(this,offsets)
    counter=zeros(1,length(offsets));
    phase=zeros(1,length(offsets));

    for i=1:length(offsets)
        offsetsVector=cell2mat(offsets(i));
        phase(i)=offsetsVector(1);
        if length(offsetsVector)==1||...
            length(offsetsVector)==this.tcinfo.nstates||...
            (length(offsetsVector)==3&&offsetsVector(3)==this.tcinfo.nstates)
            counter(i)=this.tcinfo.nstates;
        else
            counter(i)=abs(offsetsVector(2)-offsetsVector(1));
        end
    end
end
