function newComp=getSelectorComp(hN,hInSignals,hOutSignals,zeroBasedIndex,...
    indexOptions,indices,outLen,compName)

















    hInT=hInSignals(1).Type;
    hOutT=hOutSignals(1).Type;

    if all(indexOptions==0)
        newComp=pirelab.getWireComp(hN,hInSignals(1),hOutSignals);
    else
        if zeroBasedIndex==1
            indexMode='Zero-based contiguous';
        else
            indexMode='One-based contiguous';
        end

        loopUnrolling=true;
        if strcmpi(hdlfeature('DisableLoopUnrollingForSelector'),'on')
            loopUnrolling=false;
        elseif(hInT.isMatrix&&~hInT.is2DMatrix)

            loopUnrolling=false;
        end

        if loopUnrolling
            matrixSelect=length(indexOptions)==2;
            if(~hInT.isArrayType)



                for ii=1:numel(indexOptions)
                    if any(indexOptions(ii)==[2,4])
                        indices{ii}=translatePort2Dlg(hInSignals(2),zeroBasedIndex);
                        indexOptions(ii)=1;
                        hInSignals(2)=[];
                    end
                end
                if~hOutT.is2DMatrix
                    newComp=get1DDialogSelect(hN,hInSignals,hOutSignals,indices,zeroBasedIndex);
                    return
                end
            elseif(~matrixSelect&&indexOptions==2)||...
                (~hInT.is2DMatrix&&any(indexOptions==2)&&isNonConst1DIndex(hInT,indexOptions,indices,outLen,zeroBasedIndex))

                if matrixSelect
                    if hInT.isRowVector
                        if numel(hInSignals)==3
                            hInSignals(2)=[];
                        end
                    else
                        if numel(hInSignals)==3
                            hInSignals(3)=[];
                        end
                    end
                end
                newComp=get1DVectorPortSelect(hN,hInSignals,hOutSignals,indexMode,compName);
                return
            elseif(~matrixSelect&&indexOptions==4)||...
                (~hInT.is2DMatrix&&any(indexOptions==4)&&isNonConst1DIndex(hInT,indexOptions,indices,outLen,zeroBasedIndex))

                if matrixSelect
                    outLenIdx=outLen>=1;
                    removeSig=numel(hInSignals)>2;
                    if removeSig
                        hInSignals([false,~outLenIdx])=[];
                    end
                    outLen=outLen(outLenIdx);
                end
                newComp=get1DStartIdxPortSelect(hN,hInSignals,hOutSignals,indexMode,outLen);
                return
            elseif all(indexOptions==1|indexOptions==3|indexOptions==0)

                if~hOutT.isArrayType

                    demuxInput=pirelab.demuxSignal(hN,hInSignals(1));
                    if~hInT.is2DMatrix

                        if numel(indices)==1||indices{1}>1-zeroBasedIndex
                            idx=indices{1};
                        else
                            idx=indices{2};
                        end
                        newComp=pirelab.getWireComp(hN,demuxInput(idx+zeroBasedIndex),hOutSignals);
                    else

                        demux2=pirelab.demuxSignal(hN,demuxInput(indices{2}+zeroBasedIndex));
                        newComp=pirelab.getWireComp(hN,demux2(indices{1}+zeroBasedIndex),hOutSignals);
                    end
                    return
                elseif~hOutT.is2DMatrix&&~hInT.is2DMatrix

                    if numel(indices)==1||(numel(indices{2})==1&&indices{2}==1-zeroBasedIndex)
                        demuxInput=pirelab.demuxSignal(hN,hInSignals(1));
                        newComp=pirelab.getMuxComp(hN,demuxInput(indices{1}+zeroBasedIndex),hOutSignals);
                        return
                    elseif numel(indices{1})==1&&indices{1}==1-zeroBasedIndex
                        demuxInput=pirelab.demuxSignal(hN,hInSignals(1));
                        newComp=pirelab.getMuxComp(hN,demuxInput(indices{2}+zeroBasedIndex),hOutSignals);
                        return
                    end
                end
            elseif(indexOptions(1)==1||indexOptions(1)==3||indexOptions(1)==0)

                if~hInT.is2DMatrix&&(~hInT.isArrayType||(hInT.isColumnVector||~hInT.isRowVector))


                    indices(2)=[];
                    hInSignals(2)=[];
                    indexOptions(2)=[];
                elseif~hInT.is2DMatrix

                    numRepeat=numel(indices{1});
                    newComp=get1DPortSelect(hN,hInSignals,hOutSignals,indexMode,outLen(2),compName,indexOptions(2),numRepeat);
                    return
                end
            elseif(indexOptions(2)==1||indexOptions(2)==3||indexOptions(2)==0)

                if~hInT.is2DMatrix&&(~hInT.isArrayType||hInT.isRowVector)



                    hInSignals(2)=[];
                    indexOptions(1)=[];
                    indices(1)=[];
                elseif~hInT.is2DMatrix

                    numRepeat=numel(indices{2});
                    newComp=get1DPortSelect(hN,hInSignals,hOutSignals,indexMode,outLen(1),compName,indexOptions(1),numRepeat);
                    return
                end
            elseif~hInT.is2DMatrix



                if~hInT.isArrayType

                    indices{1}=translatePort2Dlg(hInSignals(2),zeroBasedIndex);
                    indices{2}=translatePort2Dlg(hInSignals(3),zeroBasedIndex);

                    indexOptions(1)=1;
                    indexOptions(2)=1;

                    hInSignals(3)=[];
                    hInSignals(2)=[];
                    if~hOutT.is2DMatrix
                        newComp=get1DDialogSelect(hN,hInSignals,hOutSignals,indices,zeroBasedIndex);
                        return
                    end
                elseif hInT.isRowVector


                    numRepeat=numel(translatePort2Dlg(hInSignals(2),zeroBasedIndex));
                    hInSignals(2)=[];
                    outLen(1)=[];
                    newComp=get1DPortSelect(hN,hInSignals,hOutSignals,indexMode,outLen,compName,indexOptions(2),numRepeat);
                    return
                else

                    numRepeat=numel(translatePort2Dlg(hInSignals(3),zeroBasedIndex));
                    hInSignals(3)=[];
                    outLen(2)=[];
                    newComp=get1DPortSelect(hN,hInSignals,hOutSignals,indexMode,outLen,compName,indexOptions(1),numRepeat);
                    return
                end
            end
        end



        [emlParams,scriptName,fcnBody]=getGenericSelector(hInSignals,indexOptions,indices,outLen,zeroBasedIndex,loopUnrolling);
        newComp=hN.addComponent2(...
        'kind','cgireml',...
        'Name',compName,...
        'InputSignals',hInSignals,...
        'OutputSignals',hOutSignals,...
        'EMLFileName',scriptName,...
        'EMLFileBody',fcnBody,...
        'EMLParams',emlParams,...
        'EMLFlag_RunLoopUnrolling',false,...
        'EMLFlag_ParamsFollowInputs',false,...
        'MatrixTypes',true);
    end

end


function val=isNonConst1DIndex(hInT,indexOptions,indices,outLen,zeroBasedIndex)
    if~hInT.isArrayType


        val=false;
        return
    elseif hInT.isRowVector
        dims=[1,hInT.Dimensions];
    else
        dims=[hInT.Dimensions,1];
    end
    constDim=indexOptions==0|indexOptions==1|indexOptions==3;
    if dims(~constDim)==1


        val=false;
    else
        dialogDim=indexOptions==1|indexOptions==3;


        val=any(indexOptions==0)||...
        any(dialogDim)&&numel(indices{dialogDim})==1&&indices{dialogDim}==1-zeroBasedIndex&&(outLen(dialogDim)==0||outLen(dialogDim)==1);
    end
end

function[emlParams,scriptName,fcnBody]=getGenericSelector(hInSignals,indexOptions,indices,outLen,zeroBasedIndex,loopUnrolling)
    emlParams={zeroBasedIndex};
    U=hInSignals(1);
    if U.Type.isArrayType
        U_size=U.Type.Dimensions;
    else
        U_size=1;
    end
    if~U.Type.isMatrix&&numel(indexOptions)>1
        if U.Type.isArrayType&&U.Type.isRowVector
            U_size=[1,U_size];
        else
            U_size=[U_size,1];
        end
    end
    for ii=1:numel(indices)


        dimIdx=indices{ii};
        dimIdx=dimIdx+zeroBasedIndex;
        if iscolumn(dimIdx)
            dimIdx=dimIdx.';
        end
        indices{ii}=dimIdx;
    end
    idxSigs=hInSignals(2:end);
    dimOrder=1:numel(indexOptions);
    assignAllIndex=indexOptions==0;
    constLogicalIndex=(indexOptions==1|indexOptions==3);
    assignAllDims=dimOrder(assignAllIndex);
    constDims=dimOrder(constLogicalIndex);
    nonConstDims=dimOrder(~(constLogicalIndex|assignAllIndex));
    isScalarExpansion=~U.Type.isArrayType;

    scriptName='hdleml_selector';
    fcnBody=sprintf(['%%#codegen\n',...
    'function y = %s(zeroBasedIndex, u, varargin)\n',...
    '%%   Copyright 2018 The MathWorks, Inc.\n',...
    'coder.allowpcode(''plain'')\n',...
    'eml_prefer_const(zeroBasedIndex);\n\n',...
    'y = hdleml_define(u('],scriptName);


    indexPortNumber=1;
    for numDim=1:length(indexOptions)
        switch indexOptions(numDim)
        case 0
            fcnBody=sprintf('%s 1:%d',fcnBody,U_size(numDim));
        case 1
            fcnBody=sprintf('%s 1:%d',fcnBody,length(indices{numDim}));
        case 2
            if idxSigs(indexPortNumber).Type.isArrayType
                vecLen=idxSigs(indexPortNumber).Type.Dimensions;
            else
                vecLen=1;
            end
            fcnBody=sprintf('%s 1:%d',fcnBody,vecLen);
            indexPortNumber=indexPortNumber+1;
        case 3
            fcnBody=sprintf('%s 1:%d',fcnBody,length(indices{numDim}));
        case 4
            fcnBody=sprintf('%s 1:%d',fcnBody,outLen(numDim));
            indexPortNumber=indexPortNumber+1;
        end
        if numDim<length(indexOptions)
            fcnBody=sprintf('%s,',fcnBody);
        end
    end
    fcnBody=sprintf('%s));\n',fcnBody);

    for ii=constDims
        dimIndices=indices{ii};

        idxVar=getIdxVar(ii);


        idxSelect=[idxVar,'_select'];


        idxSelectVec=[idxSelect,'_vec'];
        idxSelectVecStr=int2str(dimIndices);


        fcnBody=sprintf('%s%s = %s;\n',fcnBody,idxSelectVec,['[',idxSelectVecStr,']']);

        if loopUnrolling
            fcnBody=sprintf('%sfor %s = coder.unroll(1:%d)\n',fcnBody,idxSelect,numel(dimIndices));
        else
            fcnBody=sprintf('%sfor %s = 1:%d\n',fcnBody,idxSelect,numel(dimIndices));
        end



        fcnBody=sprintf('%s%s = %s(%s);\n',fcnBody,idxVar,idxSelectVec,idxSelect);

    end

    idxSigNums=1:numel(nonConstDims);
    for ii=nonConstDims
        idxSigNum=idxSigNums(nonConstDims==ii);
        idxVar=getIdxVar(ii);
        dimSize=U_size(ii);
        idxSig=idxSigs(idxSigNum);
        if indexOptions(ii)==4&&outLen(ii)>1
            fcnBody=getStartingIdxHandling(outLen(ii),idxSigNum,dimSize,idxVar,loopUnrolling,fcnBody);
        else
            if idxSig.Type.isArrayType
                vecLen=idxSig.Type.Dimensions;
            else
                vecLen=1;
            end
            fcnBody=getVectorHandling(vecLen,idxSigNum,dimSize,idxVar,loopUnrolling,fcnBody);
        end
    end


    selectIdxStr=[];
    outIdxStr=[];
    for ii=1:numel(indexOptions)
        if ii~=1
            outIdxStr=[outIdxStr,', '];%#ok<AGROW>
            selectIdxStr=[selectIdxStr,', '];%#ok<AGROW>
        end
        if any(assignAllDims==ii)

            dimStr=':';
            outIdxStr=[outIdxStr,dimStr];%#ok<AGROW>
        else
            dimStr=getIdxVar(ii);
            outIdxStr=[outIdxStr,[dimStr,'_select']];%#ok<AGROW>
        end
        selectIdxStr=[selectIdxStr,dimStr];%#ok<AGROW>

    end
    if~isScalarExpansion
        fcnBody=sprintf('%sy(%s) = u(%s);\n',fcnBody,outIdxStr,selectIdxStr);
    else
        fcnBody=sprintf('%sy(%s) = u;\n',fcnBody,outIdxStr);
    end

    for ii=nonConstDims(end:-1:1)
        fcnBody=sprintf('%send\nend\nend\n',fcnBody);
    end

    for ii=constDims(end:-1:1)

        fcnBody=sprintf('%send\n',fcnBody);
    end

end

function constIdx=translatePort2Dlg(sig,zeroBasedIndex)
    portIdxType=sig.Type;
    if portIdxType.isArrayType
        constIdx=ones(portIdxType.Dimensions,1)-zeroBasedIndex;
    else
        constIdx=1-zeroBasedIndex;
    end
end

function fcnBody=getVectorHandling(vecLen,idxSigNum,dimSize,idxVar,loopUnrolling,fcnBody)

    idxVarVec=[idxVar,'_select'];

    if loopUnrolling


        fcnBody=sprintf('%sfor %s = coder.unroll(1:%d)\n',fcnBody,idxVarVec,vecLen);

        fcnBody=sprintf('%sfor %s = coder.unroll(%d:-1:1)\n',fcnBody,idxVar,dimSize);
    else


        fcnBody=sprintf('%sfor %s = 1:%d\n',fcnBody,idxVarVec,vecLen);

        fcnBody=sprintf('%sfor %s = %d:-1:1\n',fcnBody,idxVar,dimSize);
    end


    fcnBody=sprintf('%sif varargin{%d}(%s) == cast(%s-zeroBasedIndex,''like'',varargin{%d}(%s)) || %s == %d\n',fcnBody,idxSigNum,idxVarVec,idxVar,idxSigNum,idxVarVec,idxVar,dimSize);

end

function fcnBody=getStartingIdxHandling(outLen,idxSigNum,dimSize,idxVar,loopUnrolling,fcnBody)

    maxReachableIndex=dimSize-outLen+1;
    idxVarStart=[idxVar,'_select'];

    if loopUnrolling

        fcnBody=sprintf('%sfor %s = coder.unroll(1:%d)\n',fcnBody,idxVarStart,outLen);


        fcnBody=sprintf('%sfor %s = coder.unroll(%s+%d:-1:%s)\n',fcnBody,idxVar,idxVarStart,maxReachableIndex-1,idxVarStart);


        fcnBody=sprintf('%sif varargin{%d} == cast(%s-zeroBasedIndex-(%s-1),''like'',varargin{%d}) || %s == %s+%d\n',fcnBody,idxSigNum,idxVar,idxVarStart,idxSigNum,idxVar,idxVarStart,maxReachableIndex-1);
    else

        fcnBody=sprintf('%sfor %s = 1:%d\n',fcnBody,idxVarStart,outLen);


        fcnBody=sprintf('%sfor %s = %d:-1:1\n',fcnBody,idxVar,dimSize);


        fcnBody=sprintf('%sif (varargin{%d} + %s - 1) == cast(%s-zeroBasedIndex,''like'',varargin{%d}) || %s == %d\n',fcnBody,idxSigNum,idxVarStart,idxVar,idxSigNum,idxVar,dimSize);
    end

end

function var=getIdxVar(dimNum)
    baseIdxVar='ii';
    var=char(double(baseIdxVar)+dimNum-1);
end

function newComp=get1DDialogSelect(hN,hInSignals,hOutSignals,indices,zeroBasedIndex)
    demuxInput=pirelab.demuxSignal(hN,hInSignals(1));


    if~hOutSignals.Type.isArrayType



        if~hInSignals.Type.is2DMatrix
            if indices{1}>1-zeroBasedIndex||numel(indices)<2
                idx=indices{1};
            else
                idx=indices{2};
            end
            newComp=pirelab.getWireComp(hN,demuxInput(idx+zeroBasedIndex),hOutSignals);
        else
            demux2=pirelab.demuxSignal(hN,demuxInput(indices{2}+zeroBasedIndex));
            newComp=pirelab.getWireComp(hN,demux2(indices{1}+zeroBasedIndex),hOutSignals);
        end
    else

        if~hInSignals.Type.is2DMatrix

            if numel(indices)==1||(numel(indices{2})==1&&indices{2}+zeroBasedIndex==1)
                demuxInput=pirelab.demuxSignal(hN,hInSignals(1));
                newComp=pirelab.getMuxComp(hN,demuxInput(indices{1}+zeroBasedIndex),hOutSignals);
            else

                demuxInput=pirelab.demuxSignal(hN,hInSignals(1));
                newComp=pirelab.getMuxComp(hN,demuxInput(indices{2}+zeroBasedIndex),hOutSignals);

            end
        end
    end

end

function newComp=get1DPortSelect(hN,hInSignals,hOutSignals,indexMode,outLen,compName,indexOption,numRepeat)
    needConcatAtOutput=numRepeat>1;
    if needConcatAtOutput


        hOutT=hOutSignals.Type;
        outDims=hOutT.Dimensions;
        if hOutT.isRowVector
            outDims=[1,outDims];
        elseif~hOutT.is2DMatrix
            outDims=[outDims,1];
        end

        interimOutDims=outDims;
        interimOutDims(outDims==numRepeat)=1;
        if all(interimOutDims==1)
            subOutT=hOutT.getLeafType;
        else
            subOutT=pirelab.createPirArrayType(hOutT.getLeafType,interimOutDims);
        end
        concatOutSig=hOutSignals;
        hOutSignals=hN.addSignal(subOutT,[compName,'_out']);
    end

    if indexOption==2
        newComp=get1DVectorPortSelect(hN,hInSignals,hOutSignals,indexMode,compName);
    else
        newComp=get1DStartIdxPortSelect(hN,hInSignals,hOutSignals,indexMode,outLen);
    end

    if needConcatAtOutput
        hConcatInSignals=repmat(hOutSignals,1,numRepeat);
        newComp=pireml.getConcatenateComp(hN,hConcatInSignals,concatOutSig,[compName,'_out_mux']);
    end
end

function newComp=get1DStartIdxPortSelect(hN,hInSignals,hOutSignals,indexMode,outLen)
    outMux=pirelab.getMuxOnOutput(hN,hOutSignals(1));
    outSigs=outMux.PirInputSignals;
    inLen=hInSignals(1).Type.getDimensions;
    selectorSig=hInSignals(2);
    numSels=selectorSig.Type.getDimensions;
    ip_sig=hdlissignaltype(hInSignals(1));
    op_sig=hdlissignaltype(hOutSignals(1));
    if~ip_sig.iscolvec&&op_sig.iscolvec
        changingRowColVec=1;
    else
        changingRowColVec=0;
    end
    if numSels==1&&changingRowColVec

        demuxInput=hInSignals(1);
        inputSignals=[selectorSig;demuxInput];
        switchOutName=sprintf('temp_%s',hOutSignals(1).Name);
        switchOutSig=hN.addSignal(outSigs(1).Type,switchOutName);
        newComp=pireml.getMultiPortSwitchComp(hN,inputSignals,switchOutSig,...
        0,indexMode);
        for ii=1:outLen
            newComp=pirelab.getWireComp(hN,switchOutSig,outSigs(ii));
        end
    else

        selectorSize=inLen-outLen+1;
        demuxInput=pirelab.demuxSignal(hN,hInSignals(1));
        for ii=1:outLen
            inputSignals=[selectorSig;demuxInput(ii:selectorSize+ii-1)];
            newComp=pireml.getMultiPortSwitchComp(hN,inputSignals,outSigs(ii),...
            1,indexMode);
        end
    end
end


function newComp=get1DVectorPortSelect(hN,hInSignals,hOutSignals,indexMode,compName)
    if hInSignals(2).Type.getDimensions==1
        demuxSelector=hInSignals(2);
    else
        demuxSelector=pirelab.demuxSignal(hN,hInSignals(2));
    end
    if hOutSignals(1).Type.isArrayType
        outMux=pirelab.getMuxOnOutput(hN,hOutSignals(1));
        myOutputs=outMux.PirInputSignals;
        out_vec_len=hOutSignals(1).Type.Dimensions;
    else
        myOutputs=hOutSignals(1);
        out_vec_len=1;
    end
    for ii=1:out_vec_len
        if length(demuxSelector)==1
            inputSignals=[demuxSelector;hInSignals(1)];
        else
            inputSignals=[demuxSelector(ii);hInSignals(1)];
        end
        newComp=pireml.getMultiPortSwitchComp(hN,inputSignals,myOutputs(ii),...
        0,indexMode,'floor','wrap',compName);
    end
end
