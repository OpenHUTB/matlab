function treeAddOutSig=elabAdderTree(this,hN,...
    addInSym,addInASym,sigName,comm)%#ok<INUSL>










    if(nargin<6)
        comm=[];
    end

    numSym=numel(addInSym);
    numASym=numel(addInASym);

    if(numSym+numASym)==1

        treeAddOutSig=[addInSym,addInASym];
        return;
    end



    jj=1;
    for ii=1:max(numSym,numASym)

        if ii<=numSym
            addSubSig(jj)=addInSym(ii);%#ok<*AGROW>
            addSubOp(jj)='+';
            jj=jj+1;
        end
        if ii<=numASym
            addSubSig(jj)=addInASym(ii);
            addSubOp(jj)='-';
            jj=jj+1;
        end
    end





    treeSignalIn=addSubSig;
    stageNum=0;


    while(numel(treeSignalIn)>1)


        clear treeSignalOut;
        stageNum=stageNum+1;
        stageStr=['_stage',num2str(stageNum),'_'];
        for ii=1:floor(numel(treeSignalIn)/2)

            in1=treeSignalIn((2*ii)-1);
            in1Type=in1.Type;
            sig1Suffix=num2str((2*ii)-1);
            in1RegName=[sigName,stageStr,sig1Suffix];
            in2=treeSignalIn((2*ii));
            in2Type=in2.Type;
            sig2Suffix=num2str((2*ii));
            in2RegName=[sigName,stageStr,sig2Suffix];
            adderOutName=[sigName,stageStr,'add_',num2str(ii)];



            in1RegOut=hN.addSignal(in1Type,in1RegName);
            in2RegOut=hN.addSignal(in2Type,in2RegName);
            pirelab.getUnitDelayComp(hN,in1,in1RegOut,[in1RegName,'_reg']);
            pirelab.getUnitDelayComp(hN,in2,in2RegOut,[in2RegName,'_reg']);

            if(stageNum==1)


                in1_op=addSubOp((2*ii)-1);
                in2_op=addSubOp(2*ii);
            end



            if~hdlsignalisdouble(in1)
                if(in1_op=='+'&&in2_op=='-'&&~in1Type.Signed&&~in2Type.Signed)

                    adderOutType=hN.getType('FixedPoint','Signed',1,...
                    'WordLength',max(in1Type.WordLength,in2Type.WordLength)+1,...
                    'FractionLength',in1Type.FractionLength);
                elseif(in1Type.Signed~=in2Type.Signed)
                    if in1Type.Signed
                        in1WL=in1Type.WordLength;
                        in2WL=in2Type.WordLength+1;
                    else
                        in1WL=in1Type.WordLength+1;
                        in2WL=in2Type.WordLength;
                    end

                    adderOutType=hN.getType('FixedPoint','Signed',1,...
                    'WordLength',max(in1WL,in2WL)+1,...
                    'FractionLength',in1Type.FractionLength);
                else
                    adderOutType=hN.getType('FixedPoint','Signed',in1Type.Signed,...
                    'WordLength',max(in1Type.WordLength,in2Type.WordLength)+1,...
                    'FractionLength',in1Type.FractionLength);
                end
            else
                adderOutType=in1Type;
            end
            addOutSig=hN.addSignal(adderOutType,adderOutName);
            if(stageNum~=1)||...
                (in1_op=='+'&&in2_op=='+')

                addder=pirelab.getAddComp(hN,[in1RegOut,in2RegOut],addOutSig);
                treeSignalOut(ii)=addOutSig;
            elseif(in1_op=='+'&&in2_op=='-')


                addder=pirelab.getSubComp(hN,[in1RegOut,in2RegOut],addOutSig);
                treeSignalOut(ii)=addOutSig;
...
...
...
...
...
...
...
...
...
            end
            if~isempty(comm)
                addder.addComment(comm);
            end
        end


        if mod(numel(treeSignalIn),2)

            in1=treeSignalIn(end);
            in1Type=in1.Type;
            sig1Suffix=num2str((2*ii+1));
            in1ProcName=[sigName,stageStr,sig1Suffix];
            in1RegName=[in1ProcName,'_reg'];

            in1RegOut=hN.addSignal(in1Type,in1RegName);

            pirelab.getUnitDelayComp(hN,in1,in1RegOut,in1ProcName);


            treeSignalOut(end+1)=in1RegOut;
        end



        treeSignalIn=treeSignalOut;
    end


    treeAddOutSig=hN.addSignal(treeSignalOut.Type,[sigName,'_final_reg']);
    fin=pirelab.getUnitDelayComp(hN,treeSignalOut,treeAddOutSig,[sigName,'_final']);
    if~isempty(comm)
        fin.addComment(['Final result of the ',comm]);
    end

end
