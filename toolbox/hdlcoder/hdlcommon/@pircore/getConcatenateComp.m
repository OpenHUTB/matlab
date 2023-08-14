function concatComp=getConcatenateComp(hN,hInSignals,hOutSignal,mode,...
    dim,compName,shouldDrawOverride)




    narginchk(6,7);
    if nargin<7
        shouldDrawOverride=false;
    end
    numIns=length(hInSignals);
    assert(ischar(dim));
    dimInt=int32(str2double(dim));

    hT=hInSignals(1).Type;
    in1IsRowVector=hT.isArrayType&&hT.isRowVector;
    scalarConcat=~hT.isArrayType||...
    strcmpi(mode,'Vector')||...
    (dimInt==1&&~in1IsRowVector)||(dimInt==2&&in1IsRowVector);

    if scalarConcat
        if numIns==1
            concatComp=pirelab.getWireComp(hN,hInSignals,hOutSignal,compName);
        else
            concatComp=hN.addComponent2(...
            'kind','concat',...
            'name',compName,...
            'InputSignals',hInSignals,...
            'OutputSignals',hOutSignal,...
            'Mode',mode,...
            'ConcatDim',dim);
            concatComp.setShouldDraw(shouldDrawOverride);
        end
    else



        if dimInt==1&&hOutSignal.Type.NumberOfDimensions~=3
            if hT.isRowVector




                stride=hT.Dimensions;
                numScalars=stride*numIns;
                sigs=hdlhandles(1,numScalars);
                for ii=1:numIns
                    hC=hInSignals(ii).split;
                    hC.setShouldDraw(shouldDrawOverride);
                    for jj=1:stride
                        sigs(ii+(jj-1)*numIns)=hC.PirOutputSignals(jj);
                    end
                end
                outT=hOutSignal.Type;
                if outT.is2DMatrix
                    dims=outT.Dimensions;
                    colT=hN.getType('Array','BaseType',sigs(1).Type,...
                    'Dimensions',dims(1),'VectorOrientation',2);
                    colsigs=hdlhandles(1,dims(2));
                    for ii=1:dims(2)
                        colsigs(ii)=hN.addSignal(colT,['col',int2str(ii)]);
                        startidx=1+dims(1)*(ii-1);
                        colConcat=hN.addComponent2(...
                        'kind','concat',...
                        'name',compName,...
                        'InputSignals',sigs(startidx:startidx+dims(1)-1),...
                        'OutputSignals',colsigs(ii),...
                        'Mode','Vector',...
                        'ConcatDim','2');
                        colConcat.setShouldDraw(shouldDrawOverride);

                    end
                    sigs=colsigs;
                end



                dim='2';
            else

                sigs=hInSignals;
            end
        else


            sigs=hInSignals;
        end
        concatComp=hN.addComponent2(...
        'kind','concat',...
        'name',compName,...
        'InputSignals',sigs,...
        'OutputSignals',hOutSignal,...
        'Mode',mode,...
        'ConcatDim',dim);
        concatComp.setShouldDraw(shouldDrawOverride);


        if targetmapping.isValidDataType(hInSignals(1).Type)
            concatComp.setSupportTargetCodGenWithoutMapping(true);
        end
    end
