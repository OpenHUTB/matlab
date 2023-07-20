function elaborateConvEncoderNetwork(this,topNet,blockInfo)









    insignals=topNet.PirInputSignals;

    in=insignals(1);


    if blockInfo.hasResetPort
        rst=insignals(2);
    else
        rst=[];
    end


    outsignals=topNet.PirOutputSignals;
    encoded=outsignals(1);
    numoutports=length(outsignals);
    if numoutports>1
        fst=outsignals(2);
    end



    k=blockInfo.k;
    n=blockInfo.n;
    clength=blockInfo.clength;
    gmatrix=blockInfo.gmatrix;
    fbmatrix=blockInfo.fbmatrix;

    [dim,hBT]=pirelab.getVectorTypeInfo(in);
    if dim>1
        ins=demuxSignal(this,topNet,in,'in_entry');
    else
        ins=in;
    end



    for i=1:k

        vType=pirelab.getPirVectorType(hBT,clength(i));
        sreg(i)=topNet.addSignal(vType,['sreg',num2str(i),'out']);%#ok
    end

    sregs=cell(1,k);
    for i=1:k
        tmp=demuxSignal(this,topNet,sreg(i),['sreg',num2str(i),'_entry']);
        sregs{i}=tmp;
    end



    hasFeedback=~isempty(fbmatrix);
    if(hasFeedback)

        for i=1:k
            fbXORin=[];
            num=base2dec(num2str(fbmatrix(i)),8);
            binst=dec2bin(num);
            validbits=length(binst);
            for ii=1:validbits
                if(binst(ii)=='1')
                    kk=clength(i)-validbits+ii;
                    if(kk==1)
                        fbXORin=[fbXORin,ins(i)];%#ok
                    else
                        tmp=sregs{i};
                        fbXORin=[fbXORin,tmp(kk)];%#ok
                    end

                end
            end


            fbout(i)=topNet.addSignal(hBT,['fbout',num2str(i)]);%#ok

            c=pirelab.getBitwiseOpComp(topNet,fbXORin,fbout(i),'XOR');
            c.addComment(['Feedback Connection ',num2str(fbmatrix(i))]);

        end
    end




    for i=1:k

        if(hasFeedback)
            sfregin=fbout(i);
        else
            sfregin=ins(i);
        end
        if isempty(rst)
            c=pirelab.getTapDelayComp(topNet,sfregin,sreg(i),clength(i)-1,['shift',num2str(i)],zeros(1,clength(i)-1),false,true);
        else








            rstEnb=rst;
            c=pirelab.getTapDelayEnabledResettableComp(topNet,sfregin,sreg(i),'',rstEnb,clength(i)-1,['shift',num2str(i)],zeros(1,clength(i)-1),false,true);
        end
        c.addComment(['Shift Register for Constraint Length ',num2str(clength(i))]);

    end



    for i=1:n
        outXORin=[];

        for j=1:k

            if~hasFeedback||(gmatrix(j,i)~=fbmatrix(j))
                num=base2dec(num2str(gmatrix(j,i)),8);
                binst=dec2bin(num);
                validbits=length(binst);
                for ii=1:validbits
                    if(binst(ii)=='1')
                        kk=clength(j)-validbits+ii;
                        tmp=sregs{j};
                        outXORin=[outXORin,tmp(kk)];%#ok

                    end
                end
            else
                outXORin=[outXORin,ins(j)];%#ok
            end

        end


        encodeds(i)=topNet.addSignal(hBT,['encoded_entry',num2str(i)]);%#ok



        encodeds(i).SimulinkRate=in(1).SimulinkRate;%#ok




        if length(outXORin)>1

            [hasSame,idx]=findsameconnection(gmatrix,i);
            if(hasSame)
                pirelab.getDTCComp(topNet,encodeds(idx),encodeds(i),'floor','wrap');
            else
                c=pirelab.getBitwiseOpComp(topNet,outXORin,encodeds(i),'XOR');
                c.addComment(['Output Polynomial: [',num2str(gmatrix(:,i)'),']']);
            end
        else


            pirelab.getDTCComp(topNet,outXORin,encodeds(i),'floor','wrap');
        end

    end

    pirelab.getMuxComp(topNet,encodeds,encoded);





    if(numoutports>1)

        fstMUXin=[];
        for i=k:-1:1
            tmp=sregs{i};
            fstMUXin=[fstMUXin,tmp(1:clength(i)-1)];%#ok
        end

        fstType=pir_ufixpt_t(sum(clength)-k,0);
        finalst=topNet.addSignal(fstType,'finalst');

        c=pirelab.getBitConcatComp(topNet,fstMUXin,finalst);


        finalst.SimulinkRate=in(1).simulinkRate;
        c.addComment('Final State');


        pirelab.getDTCComp(topNet,finalst,fst,'Nearest','saturate');

    end


end



function[hasSame,index]=findsameconnection(gmatrix,currentidx)




    [row,~]=size(gmatrix);
    index=8;
    hasSame=false;

    for j=currentidx-1:-1:1

        eq=true;
        for k=1:row
            eq=eq&&(gmatrix(k,currentidx)==gmatrix(k,j));
        end

        found=eq&&currentidx>j;

        if(found&&(j<index))
            hasSame=found;
            index=j;
        end
    end
end

