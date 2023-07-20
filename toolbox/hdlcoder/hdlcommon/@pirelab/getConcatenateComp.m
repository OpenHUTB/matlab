function concatComp=getConcatenateComp(hN,hInSignals,hOutSignal,...
    mode,dim,compName,shouldDrawOverride)




    narginchk(5,7);
    if nargin<7
        shouldDrawOverride=false;
    end

    if nargin<6
        compName='concatenate';
    end

    if isnumeric(dim)
        dimInt=int32(dim);
        dim=int2str(dimInt);
    else
        dimInt=int32(str2double(dim));
    end

    hD=hdlcurrentdriver;

    assert(dimInt<=3);

    numIn=numel(hInSignals);
    haveMatrixInput=false;
    if strcmp(mode,'Multidimensional array')
        for ii=1:numIn
            if hInSignals(ii).Type.isMatrix
                haveMatrixInput=true;
                break;
            end
        end
    end

    if haveMatrixInput&&numIn==1


        concatComp=pirelab.getWireComp(hN,hInSignals,hOutSignal,compName);
        return;
    end

    if~isempty(hD)&&...
        ~hD.getParameter('loop_unrolling')&&hD.getParameter('isvhdl')
        hInSigs=hInSignals;
    else



        if haveMatrixInput&&hOutSignal.Type.is2DMatrix
            if dimInt==1

                outDims=hOutSignal.Type.Dimensions;
                hInScalar=hdlhandles(outDims(1),outDims(2));
                hBaseT=hInSignals(1).Type.BaseType;


                baseRow=0;
                for ii=1:numIn
                    hT=hInSignals(ii).Type;
                    if hT.is2DMatrix
                        numRows=hT.Dimensions(1);
                        numCols=hT.Dimensions(2);
                    else
                        if hT.isRowVector
                            numRows=1;
                            numCols=hT.Dimensions(1);
                        else
                            numRows=hT.Dimensions(1);
                            numCols=1;
                        end
                    end
                    hC=hInSignals(ii).split;
                    hC.setShouldDraw(shouldDrawOverride);
                    for cc=1:numCols
                        if hC.PirOutputSignals(cc).Type.isArrayType
                            hC2=hC.PirOutputSignals(cc).split;
                            hC2.setShouldDraw(shouldDrawOverride);
                            for rr=1:numRows
                                myRow=baseRow+rr;
                                hInScalar(myRow,cc)=hC2.PirOutputSignals(rr);
                            end
                        else
                            myRow=baseRow+1;
                            hInScalar(myRow,cc)=hC.PirOutputSignals(cc);
                        end
                    end
                    baseRow=baseRow+numRows;
                end


                hInSigs=hdlhandles(1,numCols);
                hColType=hN.getType('Array','BaseType',hBaseT,'Dimensions',...
                outDims(1),'VectorOrientation',2);
                for cc=1:numCols
                    hInSigs(cc)=hN.addSignal(hColType,sprintf('col_%d',cc));
                    columnConcat=pirelab.getConcatenateComp(hN,hInScalar(:,cc),hInSigs(cc),...
                    'Vector','2');
                    columnConcat.setShouldDraw(shouldDrawOverride);
                end

                dim='2';
            else


                hInSigs=[];
                for ii=1:numel(hInSignals)
                    if hInSignals(ii).Type.is2DMatrix
                        hC=hInSignals(ii).split;
                        hC.setShouldDraw(shouldDrawOverride);
                        for jj=1:numel(hC.PirOutputSignals)
                            hInSigs=[hInSigs,hC.PirOutputSignals(jj)];%#ok<AGROW>
                        end
                    else
                        hInSigs=[hInSigs,hInSignals(ii)];%#ok<AGROW>
                    end
                end
            end
        else
            hInSigs=hInSignals;
        end
    end


    concatComp=pircore.getConcatenateComp(hN,hInSigs,hOutSignal,...
    mode,dim,compName,shouldDrawOverride);

end


