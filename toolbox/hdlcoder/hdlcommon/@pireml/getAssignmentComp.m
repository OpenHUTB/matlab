function newComp=getAssignmentComp(hN,hInSignals,hOutSignals,zeroBasedIndex,...
    indexOptions,indices,outLen,compName)


    matrixTypes=hOutSignals.Type.is2DMatrix;
    hInT=hInSignals(1).Type;






















    fcnBody=[];
    if numel(indexOptions)==1&&(indexOptions==2||indexOptions==4)
        assert(numel(hInSignals(1).Type.Dimensions)==1)
        if outLen<=1&&~hInSignals(3).Type.isArrayType

            scriptName='hdleml_assign_vector_port';
            emlParams={~zeroBasedIndex};
        else
            [emlParams,scriptName,fcnBody]=getGenericAssignment(hInSignals,indexOptions,indices,outLen,zeroBasedIndex);
        end
    elseif all(indexOptions==1|indexOptions==3|indexOptions==0)

        [emlParams,scriptName,fcnBody]=getGenericAssignment(hInSignals,indexOptions,indices,outLen,zeroBasedIndex);
    elseif indexOptions(1)==1||indexOptions(1)==3||indexOptions(1)==0

        if hInT.isArrayType&&hInT.isRowVector&&outLen(2)<=1&&~hInSignals(3).Type.isArrayType

            scriptName='hdleml_assign_vector_port';
            emlParams={~zeroBasedIndex};
        elseif hInT.isArrayType&&~hInT.isRowVector&&~hInT.is2DMatrix

            hInSignals(3)=[];
            indices(2)=[];
            indexOptions(2)=[];
            outLen(2)=[];
            [emlParams,scriptName,fcnBody]=getGenericAssignment(hInSignals,indexOptions,indices,outLen,zeroBasedIndex);
        else
            [emlParams,scriptName,fcnBody]=getGenericAssignment(hInSignals,indexOptions,indices,outLen,zeroBasedIndex);
        end
    elseif indexOptions(2)==1||indexOptions(2)==3||indexOptions(2)==0

        if~hInT.is2DMatrix&&hInT.isArrayType&&~hInT.isRowVector&&outLen(1)<=1&&~hInSignals(3).Type.isArrayType

            scriptName='hdleml_assign_vector_port';
            emlParams={~zeroBasedIndex};
        elseif hInT.isArrayType&&hInT.isRowVector

            hInSignals(3)=[];
            indices(1)=[];
            indexOptions(1)=[];
            outLen(1)=[];
            [emlParams,scriptName,fcnBody]=getGenericAssignment(hInSignals,indexOptions,indices,outLen,zeroBasedIndex);
        else
            [emlParams,scriptName,fcnBody]=getGenericAssignment(hInSignals,indexOptions,indices,outLen,zeroBasedIndex);
        end
    elseif~hInT.is2DMatrix



        if hInT.isRowVector
            hInSignals(3)=[];
            indices(1)=[];
            indexOptions(1)=[];
            outLen(1)=[];
        else

            hInSignals(4)=[];
            indices(2)=[];
            indexOptions(2)=[];
            outLen(2)=[];
        end
        if outLen<=1&&~hInSignals(3).Type.isArrayType

            scriptName='hdleml_assign_vector_port';
            emlParams={~zeroBasedIndex};
        else
            [emlParams,scriptName,fcnBody]=getGenericAssignment(hInSignals,indexOptions,indices,outLen,zeroBasedIndex);
        end
    else

        if all(outLen<=1)&&~hInSignals(3).Type.isArrayType&&~hInSignals(4).Type.isArrayType

            scriptName='hdleml_assign_matrix_port';
            emlParams={~zeroBasedIndex};
        else
            [emlParams,scriptName,fcnBody]=getGenericAssignment(hInSignals,indexOptions,indices,outLen,zeroBasedIndex);
        end
    end

    newComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName',scriptName,...
    'EMLFileBody',fcnBody,...
    'EMLParams',emlParams,...
    'EMLFlag_ParamsFollowInputs',false,...
    'MatrixTypes',matrixTypes);

end

function[emlParams,scriptName,fcnBody]=getGenericAssignment(hInSignals,indexOptions,indices,outLen,zeroBasedIndex)


    emlParams={zeroBasedIndex};
    scriptName='hdleml_assignment';
    y0=hInSignals(1);
    y0_size=y0.Type.Dimensions;
    if~y0.Type.is2DMatrix&&numel(indexOptions)>1
        if y0.Type.isArrayType&&y0.Type.isRowVector
            y0_size=[1,y0_size];
        else
            y0_size=[y0_size,1];
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
    u=hInSignals(2);
    isScalarExpansion=~u.Type.isArrayType;
    idxSigs=hInSignals(3:end);
    dimOrder=1:numel(indexOptions);
    nonConstLogicalIndex=(indexOptions==2|indexOptions==4);
    nonConstDims=dimOrder(nonConstLogicalIndex);
    constDims=dimOrder(~nonConstLogicalIndex);

    fcnBody=sprintf(['%%#codegen\n',...
    'function y = %s(zeroBasedIndex, y0, u, varargin)\n',...
    '%%   Copyright 2018 The MathWorks, Inc.\n',...
    'coder.allowpcode(''plain'')\n',...
    'eml_prefer_const(zeroBasedIndex);\n\n',...
    'y = hdleml_define(y0);\n'],scriptName);


    for ii=constDims
        dimSize=y0_size(ii);
        dimIndices=indices{ii};
        idxVar=getIdxVar(ii);

        idxAssign=[idxVar,'_assign'];


        idxAssignIdx=[idxVar,'_assignIdx'];

        idxAssignVec=[idxAssign,'_vec'];
        idxAssignVecStr=int2str(dimIndices);
        isAssignAll=indexOptions(ii)==0||(numel(dimIndices)==dimSize&&all(dimIndices==1:dimSize));
        if~isAssignAll


            fcnBody=sprintf('%s%s = %s;\n',fcnBody,idxAssignVec,['[',idxAssignVecStr,']']);
            fcnBody=sprintf('%s%s = 1:%d;\n',fcnBody,idxAssignIdx,numel(dimIndices));
        end
        fcnBody=sprintf('%sfor %s = coder.unroll(1:%d)\n',fcnBody,idxVar,dimSize);
        if~isAssignAll



            fcnBody=sprintf('%sif any(%s == %s)\n',fcnBody,idxVar,idxAssignVec);
            fcnBody=sprintf('%s%s = %s(%s == %s);\n',fcnBody,idxAssign,idxAssignIdx,idxVar,idxAssignVec);
        else

            fcnBody=sprintf('%s%s = %s;\n',fcnBody,idxAssign,idxVar);
        end
    end


    idxSigNums=1:numel(nonConstDims);
    for ii=nonConstDims
        idxSigNum=idxSigNums(nonConstDims==ii);
        idxVar=getIdxVar(ii);
        dimSize=y0_size(ii);
        idxSig=idxSigs(idxSigNum);
        if indexOptions(ii)==4&&outLen(ii)>1
            fcnBody=getStartingIdxHandling(outLen(ii),idxSigNum,dimSize,idxVar,fcnBody);
        else
            if idxSig.Type.isArrayType
                vecLen=idxSig.Type.Dimensions;
            else
                vecLen=1;
            end
            fcnBody=getVectorHandling(vecLen,idxSigNum,dimSize,idxVar,fcnBody);
        end
    end



    assigneeIdxStr=getIdxVar(1);
    assignIdxStr=[getIdxVar(1),'_assign'];
    for ii=2:numel(indexOptions)
        dimStr=getIdxVar(ii);
        assigneeIdxStr=[assigneeIdxStr,', ',dimStr];%#ok<AGROW>
        assignIdxStr=[assignIdxStr,', ',[dimStr,'_assign']];%#ok<AGROW>
    end
    if~isScalarExpansion
        fcnBody=sprintf('%sy(%s) = u(%s);\n',fcnBody,assigneeIdxStr,assignIdxStr);
    else
        fcnBody=sprintf('%sy(%s) = u;\n',fcnBody,assigneeIdxStr);
    end



    otherwiseCell=cell(1,numel(dimOrder));
    for ii=1:numel(indexOptions)
        otherwiseCell{ii}=getIdxVar(ii);
    end


    for ii=nonConstDims(end:-1:1)
        assigneeIdxStr=otherwiseCell{1};
        for jj=2:numel(otherwiseCell)
            assigneeIdxStr=[assigneeIdxStr,', ',otherwiseCell{jj}];%#ok<AGROW>
        end
        idxVar=getIdxVar(ii);
        idxVarAssignee=[idxVar,'_assign'];

        defaultCond=[idxVarAssignee,' == 1'];
        if indexOptions(ii)==4&&outLen(ii)>1



            defaultCond=[defaultCond,' || ',idxVar,' == ',idxVarAssignee,' + ',int2str(outLen(ii))];%#ok<AGROW>
        end
        fcnBody=sprintf('%selseif %s\n',fcnBody,defaultCond);
        fcnBody=sprintf('%sy(%s) = y0(%s);\nend\n',fcnBody,assigneeIdxStr,assigneeIdxStr);

        fcnBody=sprintf('%send\nend\n',fcnBody);

        otherwiseCell{ii}=':';
    end


    for ii=constDims(end:-1:1)
        dimSize=y0_size(ii);
        dimIndices=indices{ii};
        isAssignAll=indexOptions(ii)==0||(numel(dimIndices)==dimSize&&all(dimIndices==1:dimSize));
        if~isAssignAll


            assigneeIdxStr=otherwiseCell{1};
            for jj=2:numel(otherwiseCell)
                assigneeIdxStr=[assigneeIdxStr,', ',otherwiseCell{jj}];%#ok<AGROW>
            end
            fcnBody=sprintf('%selse\n',fcnBody);
            fcnBody=sprintf('%sy(%s) = y0(%s);\nend\n',fcnBody,assigneeIdxStr,assigneeIdxStr);
        end

        fcnBody=sprintf('%send\n',fcnBody);

        otherwiseCell{ii}=':';
    end
end

function fcnBody=getStartingIdxHandling(outLen,idxSigNum,dimSize,idxVar,fcnBody)

    maxReachableIndex=dimSize-outLen+1;
    idxVarStart=[idxVar,'_assign'];

    fcnBody=sprintf('%sfor %s = coder.unroll(1:%d)\n',fcnBody,idxVarStart,outLen);


    fcnBody=sprintf('%sfor %s = coder.unroll(%s:%s+%d)\n',fcnBody,idxVar,idxVarStart,idxVarStart,maxReachableIndex-1);

    fcnBody=sprintf('%sif varargin{%d} == cast(%s-zeroBasedIndex-(%s-1),''like'',varargin{%d})\n',fcnBody,idxSigNum,idxVar,idxVarStart,idxSigNum);
end

function fcnBody=getVectorHandling(vecLen,idxSigNum,dimSize,idxVar,fcnBody)

    idxVarVec=[idxVar,'_assign'];


    fcnBody=sprintf('%sfor %s = coder.unroll(1:%d)\n',fcnBody,idxVarVec,vecLen);

    fcnBody=sprintf('%sfor %s = coder.unroll(1:%d)\n',fcnBody,idxVar,dimSize);

    fcnBody=sprintf('%sif varargin{%d}(%s) == cast(%s-zeroBasedIndex,''like'',varargin{%d}(%s))\n',fcnBody,idxSigNum,idxVarVec,idxVar,idxSigNum,idxVarVec);
end

function var=getIdxVar(dimNum)
    baseIdxVar='ii';
    var=char(double(baseIdxVar)+dimNum-1);
end
