classdef NeighborhoodCreator<handle




    properties(GetAccess=public,SetAccess=immutable)




        ncc(1,1)


        nccNw(1,1)


        numSamples(1,1)double


        imgSize(1,2)double




        maxNhoodSize(1,2)double


        nccRate(1,1)double



        inputType(1,1)



        inputBaseType(1,1)



        compareMap containers.Map
    end

    properties(Access=private)



        unitDelayNetwork=[]
        lineBufferNetwork=[]
    end

    methods(Access=public)
        function this=NeighborhoodCreator(ncc)
            this.ncc=ncc;
            this.nccNw=ncc.ReferenceNetwork;
            [this.numSamples,~]=pirelab.getVectorTypeInfo(ncc.PirInputSignals(1));



            ncc.Owner.copyOptimizationOptions(this.nccNw,false);



            this.imgSize=this.getImageSize;
            this.maxNhoodSize=this.getMaxNhoodSize;

            inSig=ncc.PirInputSignals(1);
            this.nccRate=inSig.SimulinkRate;
            this.inputType=inSig.Type;
            this.inputBaseType=this.inputType.BaseType;

            this.compareMap=containers.Map;
        end

        function doit(this)
            inputSig=this.addSig(this.nccNw,this.inputType,'sample');
            validSig=this.addSig(this.nccNw,pir_boolean_t,'valid');
            inputSig.addDriver(this.nccNw.PirInputPorts(1));
            validSig.addDriver(this.nccNw.PirInputPorts(2));

            inputSig_delayed=this.addSig(this.nccNw,this.inputType,'sample_delayed');
            pirelab.getIntDelayComp(this.nccNw,inputSig,inputSig_delayed,1,'delaySample');

            validSig_delayed=this.addSig(this.nccNw,pir_boolean_t,'valid_delayed');
            pirelab.getIntDelayComp(this.nccNw,validSig,validSig_delayed,1,'delayValid');

            [isLastSample,rowCtr,colCtr,rowCtrEnd,colCtrEnd]=...
            this.makeCounterNetwork(validSig,validSig_delayed);

            maxNhoodSig=this.makeNhoodCreatorNetwork(inputSig_delayed,validSig_delayed,isLastSample);

            this.makeAllBoundaryCheckNetworks(maxNhoodSig,rowCtr,colCtr,rowCtrEnd,colCtrEnd);

            this.addAllValidDelays(validSig_delayed,rowCtr,rowCtrEnd);
        end
    end



    methods(Access=private)


        function maxSize=getMaxNhoodSize(this)
            maxX=0;
            maxY=0;
            for i=1:(this.numSamples*2):numel(this.ncc.PirOutputSignals)
                sz=this.getNhoodSize(i);
                maxX=max(sz(1),maxX);
                maxY=max(sz(2),maxY);
            end




            lhsCols=ceil(maxY/2)-1;
            rhsCols=maxY-1-lhsCols;





            lhsColsRounded=ceil(lhsCols/this.numSamples)*this.numSamples;
            rhsColsRounded=ceil(rhsCols/this.numSamples)*this.numSamples;




            maxYRounded=lhsColsRounded+this.numSamples+rhsColsRounded;

            maxSize=[maxX,maxYRounded];
        end



        function nhoodSize=getNhoodSize(this,outPortNum)
            npudt=this.getNPUDataTag(outPortNum);
            nhoodSize=[npudt.getKernelRows,npudt.getKernelCols];
        end



        function imgSize=getImageSize(this)
            imgSize=[];

            for i=1:(this.numSamples*2):numel(this.ncc.PirOutputSignals)
                npudt=this.getNPUDataTag(i);
                thisImgSize=[npudt.getImageRows,npudt.getImageCols];

                if isempty(imgSize)
                    imgSize=thisImgSize;
                else
                    assert(isequal(imgSize,thisImgSize));
                end
            end

            assert(~isempty(imgSize));
        end



        function npudt=getNPUDataTag(this,outPortNum)
            hS=this.ncc.PirOutputSignals(outPortNum);



            hNPUComp=hS.getReceivers.Owner;
            hN=hNPUComp.ReferenceNetwork;

            assert(hN.hasNPUDataTag);
            npudt=hN.getNPUDataTag;
        end




        function offset=getOffset(this,nhoodSize)
            centerCol=ceil(nhoodSize(2)/2);
            rhsCols=nhoodSize(2)-centerCol;



            rhsColsRounded=ceil(rhsCols/this.numSamples)*this.numSamples;
            offset=rhsColsRounded-rhsCols;
        end



        function enabledLatency=getLatency(this,nhoodSize)
            nhoodRows=nhoodSize(1);
            nhoodCols=nhoodSize(2);
            imgCols=this.imgSize(2);

            centerRow=ceil(nhoodRows/2);
            centerCol=ceil(nhoodCols/2);









            numRowsAfterCenter=nhoodRows-centerRow;
            numColsAfterCenter=nhoodCols-centerCol;

            pixelsToFirstNhood=numRowsAfterCenter*imgCols...
            +numColsAfterCenter+1+this.getOffset(nhoodSize);
            enabledLatency=ceil(pixelsToFirstNhood/this.numSamples)-1;
        end

    end


    methods(Access=private)



        function hS=addSig(this,hN,type,name)
            hS=hN.addSignal(type,name);
            hS.SimulinkRate=this.nccRate;
        end



        function selectorComp=selectFromSig(~,inSig,outSig,xIdxs,yIdxs)
            hN=inSig.Owner;

            selectorComp=pirelab.getSelectorComp(hN,inSig,outSig,...
            'One-based',...
            {'Index vector (dialog)','Index vector (dialog)'},...
            {xIdxs,yIdxs},...
            {0,0},...
            '2');
        end

        function scalarSigs=splitSig(this,arraySig,name)
            hN=arraySig.Owner;
            inType=arraySig.Type;

            if~inType.isArrayType
                scalarSigs=arraySig;
            elseif inType.is2DMatrix
                numRows=inType.Dimensions(1);
                numCols=inType.Dimensions(2);
                assert(numRows>1&&numCols>1);


                baseType=inType.BaseType;
                colType=pirelab.createPirArrayType(baseType,[numRows,1]);
                for col=numCols:-1:1
                    colName=sprintf('%s_col%d',name,col);
                    colSigs(col)=this.addSig(hN,colType,colName);

                    for row=numRows:-1:1
                        scalarName=sprintf('%s_row%d',colName,row);
                        scalarSigs(row,col)=this.addSig(hN,baseType,scalarName);
                    end

                    pirelab.getSplitComp(hN,colSigs(col),scalarSigs(:,col),colName);
                end

                pirelab.getSplitComp(hN,arraySig,colSigs,name);
            else
                dims=inType.Dimensions;
                assert(numel(dims)==1);

                if inType.isColumnVector
                    elemStr='row';
                    outputSize=[dims,1];
                else

                    outputSize=[1,dims];

                    if inType.isRowVector
                        elemStr='col';
                    else
                        elemStr='elem';
                    end
                end

                baseType=inType.BaseType;
                for i=dims:-1:1
                    elemName=sprintf('%s_%s%d',name,elemStr,i);
                    scalarSigs(i)=this.addSig(hN,baseType,elemName);
                end

                pirelab.getSplitComp(hN,arraySig,scalarSigs,name);
                scalarSigs=reshape(scalarSigs,outputSize);
            end
        end

        function arraySig=concatSigs(this,scalarSigs,a_1DOr2D,name)
            assert(ismember(a_1DOr2D,{'1D','2D'}));
            concatAs1D=strcmp(a_1DOr2D,'1D');

            assert(~concatAs1D||any(size(scalarSigs)==1));
            hN=scalarSigs(1,1).Owner;
            baseType=scalarSigs(1,1).Type;

            if numel(scalarSigs)==1
                arraySig=scalarSigs;
            elseif concatAs1D
                arrayType=pirelab.createPirArrayType(baseType,numel(scalarSigs));
                arraySig=this.addSig(hN,arrayType,name);
                pirelab.getConcatenateComp(hN,...
                scalarSigs,...
                arraySig,...
                'Vector',...
                1,...
                name);
            else
                [numRows,numCols]=size(scalarSigs);

                if numRows>1
                    colType=pirelab.createPirArrayType(baseType,[numRows,1]);

                    for col=numCols:-1:1
                        colName=sprintf('%s_col%d',name,col);
                        colSigs(col)=this.addSig(hN,colType,colName);
                        pirelab.getConcatenateComp(hN,...
                        scalarSigs(:,col),...
                        colSigs(col),...
                        'Multidimensional array',...
                        1,...
                        colName);
                    end
                else
                    colSigs=scalarSigs;
                end

                if numCols>1
                    matType=pirelab.createPirArrayType(baseType,[numRows,numCols]);
                    arraySig=this.addSig(hN,matType,name);
                    pirelab.getConcatenateComp(hN,...
                    colSigs,...
                    arraySig,...
                    'Multidimensional array',...
                    2,...
                    name);
                else
                    arraySig=colSigs;
                end
            end
        end

        function constSig=addConstant(this,hN,type,value,name)
            constSig=this.addSig(hN,type,name);
            pirelab.getConstComp(hN,constSig,value,name);
        end

        function logicSig=addLogic(this,inSig1,inSig2,op,name)
            hN=inSig1.Owner;
            logicSig=this.addSig(hN,pir_boolean_t,name);
            pirelab.getLogicComp(hN,[inSig1,inSig2],logicSig,op,name);
        end

        function convSig=addDTC(this,inSig,outType,name)
            hN=inSig.Owner;
            convSig=this.addSig(hN,outType,name);
            pirelab.getDTCComp(hN,...
            inSig,...
            convSig,...
            'Floor',...
            'Wrap',...
            'RWV',...
            name);
        end

        function switchedSig=addBooleanSwitch(this,trueSig,falseSig,compareSig,name)
            hN=trueSig.Owner;
            switchedSig=this.addSig(hN,trueSig.Type,name);
            pirelab.getSwitchComp(hN,...
            [trueSig,falseSig],...
            switchedSig,...
            compareSig,...
            name,...
            '~=',...
            0);
        end





        function checkSig=checkValueInBounds(this,hSig,...
            lowerBound,upperBound,rowOrCol)
            hN=hSig.Owner;

            switch rowOrCol
            case 'row'
                maxUpperBound=prod(this.imgSize)+1;
            otherwise
                assert(strcmp(rowOrCol,'col'));
                maxUpperBound=this.imgSize(2)+1;
            end

            lowerBound=max(lowerBound,0);
            upperBound=min(upperBound,maxUpperBound);
            key=sprintf('%s_%s_>_%d_<_%d',hN.RefNum,hSig.RefNum,...
            lowerBound,upperBound);

            if this.compareMap.isKey(key)
                checkSig=this.compareMap(key);
            else
                lowerInBounds=lowerBound>0;
                upperInBounds=upperBound<maxUpperBound;

                assert(lowerInBounds||upperInBounds);

                if lowerInBounds
                    lowerCheckSig=this.addCompare(hSig,'>',lowerBound,...
                    sprintf('%s_gt_%d',rowOrCol,lowerBound));
                end

                if upperInBounds
                    upperCheckSig=this.addCompare(hSig,'<',upperBound,...
                    sprintf('%s_lt_%d',rowOrCol,upperBound));
                end

                if lowerInBounds&&upperInBounds
                    name=sprintf('%s_gt_%d_lt_%d',rowOrCol,lowerBound,upperBound);
                    checkSig=this.addLogic(lowerCheckSig,upperCheckSig,'and',name);
                elseif lowerInBounds
                    checkSig=lowerCheckSig;
                else
                    checkSig=upperCheckSig;
                end

                this.compareMap(key)=checkSig;
            end
        end




        function compareSig=addCompare(this,inSig,op,value,name)
            hN=inSig.Owner;

            key=sprintf('%s_%s_%s_%d',hN.RefNum,inSig.RefNum,op,value);

            if this.compareMap.isKey(key)
                compareSig=this.compareMap(key);
            else
                compareSig=this.addSig(hN,pir_boolean_t,name);
                pirelab.getCompareToValueComp(hN,inSig,compareSig,op,...
                value,name);

                this.compareMap(key)=compareSig;
            end
        end
    end


    methods(Access=private)

        function[isLastSample,rowCtr,colCtr,rowCtrEnd,colCtrEnd]=...
            makeCounterNetwork(this,validSig,validSigDelayed)

            networkName='counterNetwork';
            outportNames={'isLastSample','rowCtr','colCtr','rowCtrEnd','colCtrEnd'};

            rowCtrType=pir_ufixpt_t(ceil(log2(prod(this.imgSize)))+1,0);
            colCtrType=pir_ufixpt_t(ceil(log2(this.imgSize(2)))+1,0);

            newN=pirelab.createNewNetwork(...
            'Network',this.nccNw,...
            'Name',networkName,...
            'InportNames',{'valid','valid_delayed'},...
            'InportTypes',[pir_boolean_t,pir_boolean_t],...
            'InportRates',[this.nccRate,this.nccRate],...
            'OutportNames',outportNames,...
            'OutportTypes',[pir_boolean_t,rowCtrType,colCtrType,rowCtrType,colCtrType],...
            'OutportRates',repmat(this.nccRate,1,5));
            this.nccNw.copyOptimizationOptions(newN,false);

            this.fillCounterNetwork(newN);

            isLastSample=this.addSig(this.nccNw,pir_boolean_t,outportNames{1});
            rowCtr=this.addSig(this.nccNw,rowCtrType,outportNames{2});
            colCtr=this.addSig(this.nccNw,colCtrType,outportNames{3});
            rowCtrEnd=this.addSig(this.nccNw,rowCtrType,outportNames{4});
            colCtrEnd=this.addSig(this.nccNw,colCtrType,outportNames{5});

            pirelab.instantiateNetwork(this.nccNw,newN,...
            [validSig,validSigDelayed],...
            [isLastSample,rowCtr,colCtr,rowCtrEnd,colCtrEnd],...
            networkName);
        end

        function fillCounterNetwork(this,hN)
            validSig=hN.PirInputSignals(1);
            validSigDelayed=hN.PirInputSignals(2);

            isLastSample=hN.PirOutputSignals(1);
            rowCtr=hN.PirOutputSignals(2);
            colCtr=hN.PirOutputSignals(3);
            rowCtrEnd=hN.PirOutputSignals(4);
            colCtrEnd=hN.PirOutputSignals(5);


            maxRowCtrVal=prod(this.imgSize);
            pirelab.getCounterComp(hN,...
            validSig,...
            rowCtr,...
            'Count limited',...
            maxRowCtrVal,...
            this.numSamples,...
            maxRowCtrVal,...
            false,...
            false,...
            true,...
            false,...
            'rowCtr',...
            this.numSamples);


            maxColCtrVal=this.imgSize(2);
            pirelab.getCounterComp(hN,...
            validSig,...
            colCtr,...
            'Count limited',...
            maxColCtrVal,...
            this.numSamples,...
            maxColCtrVal,...
            false,...
            false,...
            true,...
            false,...
            'colCtr',...
            this.numSamples);





            isMaxValue=this.addCompare(rowCtr,'==',maxRowCtrVal,'rowCtrIsMax');
            pirelab.getLogicComp(hN,[isMaxValue,validSigDelayed],isLastSample,'and');




            onEndValues=this.addCompare(rowCtrEnd,'~=',0,'onEndValues');







            firstSig=this.addConstant(hN,rowCtrEnd.Type,this.numSamples,'numSamples');

            maxRowCtrEndVal=...
            (this.maxNhoodSize(1)-1)*this.imgSize(2)+...
            this.maxNhoodSize(2);

            pirelab.getCounterComp(hN,...
            [isLastSample,firstSig,onEndValues],...
            rowCtrEnd,...
            'Count limited',...
            0,...
            this.numSamples,...
            maxRowCtrEndVal,...
            false,...
            true,...
            true,...
            false,...
            'rowCtrEnd',...
            0);





            pirelab.getCounterComp(hN,...
            [isLastSample,onEndValues],...
            colCtrEnd,...
            'Count limited',...
            this.numSamples,...
            this.numSamples,...
            maxColCtrVal,...
            true,...
            false,...
            true,...
            false,...
            'colCtrEnd',...
            this.numSamples);
        end

    end


    methods(Access=private)



        function nhoodSig=makeNhoodCreatorNetwork(this,inputSignal,validSignal,isLastSampleSig)
            nhoodType=pirelab.createPirArrayType(this.inputBaseType,this.maxNhoodSize);


            networkName=sprintf('NeighborhoodCreator_%dx%d',...
            this.maxNhoodSize(1),this.maxNhoodSize(2));

            newN=pirelab.createNewNetwork(...
            'Network',this.nccNw,...
            'Name',networkName,...
            'InportNames',{'sample','valid','isLastSample'},...
            'InportTypes',[this.inputType,pir_boolean_t,pir_boolean_t],...
            'InportRates',[this.nccRate,this.nccRate,this.nccRate],...
            'OutportNames',{'neighborhood'},...
            'OutportTypes',nhoodType,...
            'OutportRates',this.nccRate);
            this.nccNw.copyOptimizationOptions(newN,false);
            newN.addComment(['Create neighborhood of size ',mat2str(this.maxNhoodSize)]);

            this.createNhoodInNetwork(newN);

            nhoodSig=this.addSig(this.nccNw,nhoodType,'neighborhood');

            pirelab.instantiateNetwork(this.nccNw,newN,...
            [inputSignal,validSignal,isLastSampleSig],nhoodSig,networkName);
        end



        function createNhoodInNetwork(this,hN)

            inputSignal=hN.PirInputSignals(1);
            validInSignal=hN.PirInputSignals(2);
            isLastSampleSig=hN.PirInputSignals(3);

            maxNhoodX=this.maxNhoodSize(1);
            maxNhoodY=this.maxNhoodSize(2);


            assert(mod(maxNhoodY,this.numSamples)==0);
            numUnitDelays=maxNhoodY/this.numSamples-1;


            numPixelsInLineBuffers=this.imgSize(2)-numUnitDelays*this.numSamples;
            assert(mod(numPixelsInLineBuffers,this.numSamples)==0);
            lineBufferDelay=numPixelsInLineBuffers/this.numSamples;



            yAdj=-(this.numSamples-1):0;



            nhoodSigs(maxNhoodX,maxNhoodY+yAdj)=this.splitSig(inputSignal,...
            sprintf('row%d_col%d',maxNhoodX,numUnitDelays+1));



            lastDelayedSig=inputSignal;
            onEndValsSig=isLastSampleSig;

            for i=maxNhoodX:-1:1

                for j=numUnitDelays:-1:1
                    name=sprintf('row%d_col%d',i,j);
                    [lastDelayedSig,onEndValsSig]=this.createUnitDelayNetwork(hN,...
                    lastDelayedSig,onEndValsSig,validInSignal,isLastSampleSig,name);

                    nhoodSigs(i,j*this.numSamples+yAdj)=this.splitSig(lastDelayedSig,name);
                end


                if i>1&&lineBufferDelay>0
                    name=sprintf('row%d_linebuffer',i-1);

                    if lineBufferDelay<5





                        for k=1:lineBufferDelay
                            [lastDelayedSig,onEndValsSig]=this.createUnitDelayNetwork(hN,...
                            lastDelayedSig,onEndValsSig,validInSignal,isLastSampleSig,name);
                        end
                    else
                        [lastDelayedSig,onEndValsSig]=this.createLineBufferNetwork(hN,...
                        lastDelayedSig,onEndValsSig,validInSignal,isLastSampleSig,...
                        lineBufferDelay,name);
                    end

                    nhoodSigs(i-1,maxNhoodY+yAdj)=this.splitSig(lastDelayedSig,...
                    sprintf('row%d_col%d',i-1,numUnitDelays+1));
                end
            end


            pirelab.getNilComp(hN,onEndValsSig,[],'Terminator');


            maxNhoodSig=this.concatSigs(nhoodSigs,'2D','max_neighborhood');
            pirelab.getWireComp(hN,maxNhoodSig,hN.PirOutputSignals);
        end

        function[sampleSig_out,onEndValsSig_out]=createUnitDelayNetwork(this,hN,...
            sampleSig,onEndValsSig,validInSig,isLastSampleSig,name)



            if isempty(this.unitDelayNetwork)
                this.unitDelayNetwork=pirelab.createNewNetwork('Network',hN,...
                'Name',name,...
                'InportNames',{'sample_in','onEndValues_in','valid','isLastSample'},...
                'InportTypes',[this.inputType,pir_boolean_t,pir_boolean_t,pir_boolean_t],...
                'InportRates',[this.nccRate,this.nccRate,this.nccRate,this.nccRate],...
                'OutportNames',{'sample_out','onEndValues_out'},...
                'OutportTypes',[this.inputType,pir_boolean_t],...
                'OutportRates',[this.nccRate,this.nccRate]);
                hN.copyOptimizationOptions(this.unitDelayNetwork,false);

                this.unitDelayNetwork.flatten(true);
                this.unitDelayNetwork.flattenHierarchy();

                this.fillUnitDelayNetwork(this.unitDelayNetwork);
            end

            sampleSig_out=this.addSig(hN,this.inputType,sampleSig.Name);
            onEndValsSig_out=this.addSig(hN,pir_boolean_t,onEndValsSig.Name);

            pirelab.instantiateNetwork(hN,this.unitDelayNetwork,...
            [sampleSig,onEndValsSig,validInSig,isLastSampleSig],...
            [sampleSig_out,onEndValsSig_out],name);
        end

        function fillUnitDelayNetwork(this,hN)
            sampleSig=hN.PirInputSignals(1);
            onEndValsSig=hN.PirInputSignals(2);
            validInSig=hN.PirInputSignals(3);
            isLastSampleSig=hN.PirInputSignals(4);

            sampleSig_out=hN.PirOutputSignals(1);
            onEndValsSig_out=hN.PirOutputSignals(2);



            onEndValsInner=this.addLogic(onEndValsSig,isLastSampleSig,'or','onEndVals');
            pirelab.getIntDelayComp(hN,onEndValsInner,onEndValsSig_out,1,'onEndVals_delay');



            enbSig=this.addLogic(validInSig,onEndValsSig_out,'or','enb');

            pirelab.getIntDelayEnabledComp(hN,...
            sampleSig,...
            sampleSig_out,...
            enbSig,...
            1,...
            'sample_delay',...
            0,...
            '',...
            this.ncc.Owner.hasSLHWFriendlySemantics);
        end

        function[sampleSig_out,onEndValsSig_out]=createLineBufferNetwork(this,hN,...
            sampleSig,onEndValsSig,validInSig,isLastSampleSig,nDelays,name)



            if isempty(this.lineBufferNetwork)
                this.lineBufferNetwork=pirelab.createNewNetwork('Network',hN,...
                'Name',name,...
                'InportNames',{'sample_in','onEndValues_in','valid','isLastSample'},...
                'InportTypes',[this.inputType,pir_boolean_t,pir_boolean_t,pir_boolean_t],...
                'InportRates',[this.nccRate,this.nccRate,this.nccRate,this.nccRate],...
                'OutportNames',{'sample_out','onEndValues_out'},...
                'OutportTypes',[this.inputType,pir_boolean_t],...
                'OutportRates',[this.nccRate,this.nccRate]);
                hN.copyOptimizationOptions(this.lineBufferNetwork,false);

                this.lineBufferNetwork.flatten(true);
                this.lineBufferNetwork.flattenHierarchy();

                this.fillLineBufferNetwork(this.lineBufferNetwork,nDelays);
            end

            sampleSig_out=this.addSig(hN,this.inputType,sampleSig.Name);
            onEndValsSig_out=this.addSig(hN,pir_boolean_t,onEndValsSig.Name);

            pirelab.instantiateNetwork(hN,this.lineBufferNetwork,...
            [sampleSig,onEndValsSig,validInSig,isLastSampleSig],...
            [sampleSig_out,onEndValsSig_out],name);
        end




        function fillLineBufferNetwork(this,hN,nDelays)
            sampleSig=hN.PirInputSignals(1);
            onEndValsSig=hN.PirInputSignals(2);
            validInSig=hN.PirInputSignals(3);
            isLastSampleSig=hN.PirInputSignals(4);

            sampleSig_out=hN.PirOutputSignals(1);
            onEndValsSig_out=hN.PirOutputSignals(2);





            ramSize=nDelays-2;
            addrType=pir_ufixpt_t(ceil(log2(ramSize)),0);





            wrEn=this.addLogic(validInSig,onEndValsSig,'or','wrEn');




            wrAddr=this.addSig(hN,addrType,'wrAddr');
            pirelab.getCounterComp(hN,...
            wrEn,...
            wrAddr,...
            'Count limited',...
            0,...
            1,...
            ramSize-1,...
            false,...
            false,...
            true,...
            false,...
            'wrAddr',...
            0);






            wrAddrNext=this.getNextWrAddr(hN,wrAddr,wrEn,ramSize);





















            endValsCountType=pir_ufixpt_t(ceil(log2(nDelays+2)),0);


            endValsCount=this.addSig(hN,endValsCountType,'endValsCount');



            endValsNonzero=this.addCompare(endValsCount,'~=',0,'endValsNonzero');



            endValsLoad=this.addLogic(onEndValsSig,isLastSampleSig,'or','endValsLoad');
            endValsOne=this.addConstant(hN,endValsCountType,1,'one');

            pirelab.getCounterComp(hN,...
            [endValsLoad,endValsOne,endValsNonzero],...
            endValsCount,...
            'Count limited',...
            0,...
            1,...
            nDelays+1,...
            false,...
            true,...
            true,...
            false,...
            'endValsCount',...
            0);



            pirelab.getWireComp(hN,endValsNonzero,onEndValsSig_out);










            rdAddr=this.addSig(hN,addrType,'rdAddr');
            rdAddrLoad=this.addCompare(endValsCount,'==',nDelays,'rdAddrLoad');
            endValsLtNdelays=this.addCompare(endValsCount,'<',nDelays,sprintf('lt_%d',nDelays));
            rdEnEndVals=this.addLogic(endValsNonzero,endValsLtNdelays,'and','rdEnEndVals');
            rdEn=this.addLogic(wrEn,rdEnEndVals,'or','rdEn');

            pirelab.getCounterComp(hN,...
            [rdAddrLoad,wrAddrNext,rdEn],...
            rdAddr,...
            'Count limited',...
            0,...
            1,...
            ramSize-1,...
            false,...
            true,...
            true,...
            false,...
            'rdAddr',...
            0);



            ramOutSig=this.instantiateRAM(hN,sampleSig,wrAddr,wrEn,rdAddr);







            readFromRam=this.addLogic(wrEn,endValsNonzero,'or','readFromRAM');
            enbFinalDelay=this.addSig(hN,pir_boolean_t,'enb');
            pirelab.getIntDelayComp(hN,readFromRam,enbFinalDelay,1,'enb_delay');
            pirelab.getIntDelayEnabledComp(hN,...
            ramOutSig,...
            sampleSig_out,...
            enbFinalDelay,...
            1,...
            'sample_final_delay',...
            0,...
            '',...
            this.ncc.Owner.hasSLHWFriendlySemantics);
        end

        function wrAddrNext=getNextWrAddr(this,hN,wrAddr,wrEn,ramSize)




            addrType=wrAddr.Type;
            needDTCs=ceil(log2(ramSize))~=ceil(log2(ramSize+1));
            if needDTCs
                plusOneAddrType=pir_ufixpt_t(ceil(log2(ramSize+1)),0);
                wrAddrToAdd=this.addDTC(wrAddr,plusOneAddrType,'wrAddr');
            else
                plusOneAddrType=addrType;
                wrAddrToAdd=wrAddr;
            end


            wrAddrOne=this.addConstant(hN,plusOneAddrType,1,'one');
            wrAddrPlusOne=this.addSig(hN,plusOneAddrType,'wrAddrPlusOne');
            pirelab.getAddComp(hN,[wrAddrToAdd,wrAddrOne],wrAddrPlusOne);


            wrAddrZero=this.addConstant(hN,plusOneAddrType,0,'zero');
            wrAddrIsMax=this.addCompare(wrAddr,'==',ramSize-1,'wrAddrIsMax');
            wrAddrIncr=this.addBooleanSwitch(wrAddrZero,wrAddrPlusOne,wrAddrIsMax,'wrAddrIncr');

            if needDTCs
                wrAddrIncr=this.addDTC(wrAddrIncr,addrType,'wrAddrIncr');
            end



            wrAddrNext=this.addBooleanSwitch(wrAddrIncr,wrAddr,wrEn,'wrAddrNext');
        end

        function ramOutSig=instantiateRAM(this,hN,sampleIn,wrAddr,wrEn,rdAddr)
            name='ram';
            ramInSigs=this.splitSig(sampleIn,name);

            for i=this.numSamples:-1:1
                if this.numSamples>1
                    name=sprintf('%s_%d',name,i);
                end

                allOutSigs(i)=this.addSig(hN,this.inputBaseType,name);

                pirelab.getSimpleDualPortRamComp(hN,...
                [ramInSigs(i),wrAddr,wrEn,rdAddr],...
                allOutSigs(i),...
                name);
            end

            ramOutSig=this.concatSigs(allOutSigs,'1D','ram');
        end
    end


    methods(Access=private)

        function makeAllBoundaryCheckNetworks(this,maxNhoodSig,...
            rowCtr,colCtr,rowCtrEnd,colCtrEnd)
            boundCheckMap=containers.Map;

            for i=1:(this.numSamples*2):numel(this.nccNw.PirOutputSignals)
                nhoodSize=this.getNhoodSize(i);

                key=sprintf('%d_%d',nhoodSize(1),nhoodSize(2));

                if boundCheckMap.isKey(key)
                    allNhoodsOut=boundCheckMap(key);
                else



                    allNhoodsOut=this.makeBoundaryCheckNetwork(...
                    maxNhoodSig,rowCtr,colCtr,rowCtrEnd,colCtrEnd,nhoodSize,i);
                    boundCheckMap(key)=allNhoodsOut;
                end

                for j=1:this.numSamples
                    allNhoodsOut(j).addReceiver(this.nccNw.PirOutputPorts(i+j-1));
                end
            end
        end

        function allNhoodsOut=makeBoundaryCheckNetwork(this,...
            nhoodIn,rowCtr,colCtr,rowCtrEnd,colCtrEnd,nhoodSize,outIndex)

            networkName=sprintf('BoundaryCheck_%dx%d',nhoodSize(1),nhoodSize(2));
            if this.numSamples==1
                nhoodOutNames={'neighborhoodOut'};
            else
                nhoodOutNames=arrayfun(@(i){sprintf('neighborhoodOut_%d',i)},1:this.numSamples);
            end

            nhoodOutType=pirelab.createPirArrayType(this.inputBaseType,nhoodSize);

            newN=pirelab.createNewNetwork(...
            'Network',this.nccNw,...
            'Name',networkName,...
            'InportNames',{'neighborhoodIn','rowCtr','colCtr','rowCtrEnd','colCtrEnd'},...
            'InportTypes',[nhoodIn.Type,rowCtr.Type,colCtr.Type,rowCtrEnd.Type,colCtrEnd.Type],...
            'InportRates',[this.nccRate,this.nccRate,this.nccRate,this.nccRate,this.nccRate],...
            'OutportNames',nhoodOutNames,...
            'OutportTypes',repmat(nhoodOutType,1,this.numSamples),...
            'OutportRates',repmat(this.nccRate,1,this.numSamples));
            this.nccNw.copyOptimizationOptions(newN,false);

            this.createBoundaryCheckInNetwork(newN,nhoodSize,outIndex);

            for i=this.numSamples:-1:1
                allNhoodsOut(i)=this.addSig(this.nccNw,nhoodOutType,nhoodOutNames{i});
            end

            pirelab.instantiateNetwork(this.nccNw,newN,...
            [nhoodIn,rowCtr,colCtr,rowCtrEnd,colCtrEnd],allNhoodsOut,networkName);
        end

        function createBoundaryCheckInNetwork(this,hN,nhoodSize,outIndex)
            maxNhoodSig=hN.PirInputSignals(1);
            rowCtr=hN.PirInputSignals(2);
            colCtr=hN.PirInputSignals(3);
            rowCtrEnd=hN.PirInputSignals(4);
            colCtrEnd=hN.PirInputSignals(5);






            offset=this.getOffset(nhoodSize);

            xIdxStart=this.maxNhoodSize(1)-nhoodSize(1)+1;
            xIdxEnd=this.maxNhoodSize(1);
            yIdxStart=this.maxNhoodSize(2)-nhoodSize(2)+1...
            -offset-(this.numSamples-1);
            yIdxEnd=this.maxNhoodSize(2)-offset;

            if xIdxStart==1&&yIdxStart==1&&...
                isequal([xIdxEnd,yIdxEnd],this.maxNhoodSize)


                nhoodIn=maxNhoodSig;
            else
                xIdxs=xIdxStart:xIdxEnd;
                yIdxs=yIdxStart:yIdxEnd;

                nhoodInType=pirelab.createPirArrayType(...
                this.inputBaseType,[numel(xIdxs),numel(yIdxs)]);
                nhoodIn=this.addSig(hN,nhoodInType,'neighborhood');

                this.selectFromSig(maxNhoodSig,nhoodIn,xIdxs,yIdxs);
            end





            maxEndVal=this.getLatency(nhoodSize)*this.numSamples;
            onEndFrame=this.addCompare(rowCtrEnd,'>',0,'onEndFrame');
            endFrameInBounds=this.addCompare(rowCtrEnd,'<=',maxEndVal,'endFrameInBounds');
            useEndCounters=this.addLogic(onEndFrame,endFrameInBounds,'and','useEndCounters');
            rowCtrToUse=this.addBooleanSwitch(rowCtrEnd,rowCtr,useEndCounters,'rowCtr');
            colCtrToUse=this.addBooleanSwitch(colCtrEnd,colCtr,useEndCounters,'colCtr');

            nhoodOut=this.createConstantBoundary(hN,nhoodIn,...
            rowCtrToUse,colCtrToUse,nhoodSize,outIndex);

            if this.numSamples==1
                allFinalBlocks=pirelab.getWireComp(hN,nhoodOut,hN.PirOutputSignals(1));
            else



                for i=this.numSamples:-1:1


                    allFinalBlocks(i)=this.selectFromSig(...
                    nhoodOut,hN.PirOutputSignals(i),...
                    1:nhoodSize(1),...
                    (1+i-1):(nhoodSize(2)+i-1));
                end
            end

            enabledLatency=this.getLatency(nhoodSize);

            for i=1:this.numSamples
                allFinalBlocks(i).setOutputDelay(1);
                allFinalBlocks(i).setEnabledOutputDelay(enabledLatency);
            end
        end

        function nhoodOut=createConstantBoundary(this,hN,nhoodIn,...
            rowCtrSig,colCtrSig,nhoodSize,outIndex)


            boundaryConstantSig=this.addSig(hN,this.inputBaseType,'boundary');
            pirelab.getConstComp(hN,boundaryConstantSig,this.getNPUDataTag(outIndex).getBoundaryConstantValue);





            nhoodRows=nhoodSize(1);
            nhoodCols=nhoodSize(2)+this.numSamples-1;


            scalarSigs=this.splitSig(nhoodIn,'neighborhood');

            for col=nhoodCols:-1:1
                for row=nhoodRows:-1:1
                    scalarMaskedSigs(row,col)=this.maskSignal(...
                    hN,scalarSigs(row,col),rowCtrSig,colCtrSig,boundaryConstantSig,...
                    row,col,nhoodSize);
                end
            end


            nhoodOut=this.concatSigs(scalarMaskedSigs,'2D','neighborhood_masked');
        end

        function sigOut=maskSignal(this,hN,sigIn,rowCtrSig,colCtrSig,boundaryConstantSig,...
            rowOrig,colOrig,nhoodSize)

            centerRowOrig=ceil(nhoodSize(1)/2);
            centerColOrig=ceil(nhoodSize(2)/2);







            row=nhoodSize(1)-rowOrig+1;
            col=nhoodSize(2)+this.numSamples-colOrig;
            centerRow=nhoodSize(1)-centerRowOrig+1;
            centerCol=nhoodSize(2)+this.numSamples-centerColOrig;




            offset=this.getOffset(nhoodSize);
            col=col+offset;
            centerCol=centerCol+offset;





            col=ceil(col/this.numSamples)*this.numSamples;
            centerCol=ceil(centerCol/this.numSamples)*this.numSamples;

            if row==centerRow&&col==centerCol
                sigOut=sigIn;
                return;
            end



            if row<centerRow



                rowCheckSig=this.checkValueInBounds(rowCtrSig,...
...
                (row-1)*this.imgSize(2)+centerCol-1,...
...
                (centerRow-1)*this.imgSize(2)+centerCol,...
                'row');
            elseif row>centerRow



                rowCheckSig=this.checkValueInBounds(rowCtrSig,...
...
                (centerRow-1)*this.imgSize(2)+centerCol-1,...
...
                (row-1)*this.imgSize(2)+centerCol,...
                'row');
            end

            if col<centerCol




                colCheckSig=this.checkValueInBounds(colCtrSig,...
                col-1,centerCol,'col');
            elseif col>centerCol




                colCheckSig=this.checkValueInBounds(colCtrSig,...
                centerCol-1,col,'col');
            end

            if row~=centerRow&&col~=centerCol

                checkSigName=sprintf('inBounds_%d_%d',rowOrig,colOrig);
                checkSig=this.addLogic(rowCheckSig,colCheckSig,'or',checkSigName);
            elseif row~=centerRow

                checkSig=rowCheckSig;
            else

                checkSig=colCheckSig;
            end

            sigOut=this.addSig(hN,sigIn.Type,sigIn.Name);
            pirelab.getSwitchComp(hN,...
            [boundaryConstantSig,sigIn],sigOut,checkSig,'mask',...
            '~=',0);
        end

    end


    methods(Access=private)

        function addAllValidDelays(this,validSig,rowCtr,rowCtrEnd)
            validOutMap=containers.Map;

            for i=1:(this.numSamples*2):numel(this.nccNw.PirOutputSignals)
                nhoodSize=this.getNhoodSize(i);

                enabledLatency=this.getLatency(nhoodSize);
                key=sprintf('%d',enabledLatency);

                if validOutMap.isKey(key)
                    validOut=validOutMap(key);
                else
                    validOut=this.makeValidDelayNetwork(enabledLatency,...
                    validSig,rowCtr,rowCtrEnd);
                    validOutMap(key)=validOut;
                end

                for j=1:this.numSamples
                    portIdx=i+j-1+this.numSamples;
                    validOut.addReceiver(this.nccNw.PirOutputPorts(portIdx));
                end
            end
        end

        function validOut=makeValidDelayNetwork(this,enabledLatency,...
            validIn,rowCtr,rowCtrEnd)
            networkName=sprintf('ValidDelay_%d',enabledLatency);

            newN=pirelab.createNewNetwork(...
            'Network',this.nccNw,...
            'Name',networkName,...
            'InportNames',{'validIn','rowCtr','rowCtrEnd'},...
            'InportTypes',[pir_boolean_t,rowCtr.Type,rowCtrEnd.Type],...
            'InportRates',[this.nccRate,this.nccRate,this.nccRate],...
            'OutportNames',{'validOut'},...
            'OutportTypes',pir_boolean_t,...
            'OutportRates',this.nccRate);
            this.nccNw.copyOptimizationOptions(newN,false);

            this.addValidDelayToNetwork(newN,enabledLatency);

            validOut=this.addSig(this.nccNw,pir_boolean_t,...
            sprintf('valid_delayed_%d',enabledLatency));
            pirelab.instantiateNetwork(this.nccNw,newN,...
            [validIn,rowCtr,rowCtrEnd],validOut,networkName);
        end

        function validOut=addValidDelayToNetwork(this,hN,nDelays)







            validIn=hN.PirInputSignals(1);
            rowCtr=hN.PirInputSignals(2);
            rowCtrEnd=hN.PirInputSignals(3);
            validOut=hN.PirOutputSignals;

            assert(nDelays>0);



            rowCtrMax=nDelays*this.numSamples;
            rowCtrGtLatency=this.addCompare(rowCtr,'>',rowCtrMax,'sampleGtLatency');
            validCurrFrame=this.addLogic(validIn,rowCtrGtLatency,'and','validCurrFrame');



            endCtrMax=(nDelays+1)*this.numSamples;
            endCtrGtZero=this.addCompare(rowCtrEnd,'>',0,'processingEndFrame');
            endCtrInCurrNhood=this.addCompare(rowCtrEnd,'<',endCtrMax,'endFrameWithinNhood');
            validEndFrame=this.addLogic(endCtrGtZero,endCtrInCurrNhood,'and','validPrevFrame');

            isValid=this.addLogic(validCurrFrame,validEndFrame,'or','validOut');

            finalBlock=pirelab.getWireComp(hN,isValid,validOut);

            finalBlock.setOutputDelay(1);
            finalBlock.setEnabledOutputDelay(nDelays);
        end

    end

end


