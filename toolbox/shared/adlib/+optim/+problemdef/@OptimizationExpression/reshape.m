function eout=reshape(obj,varargin)





    outSize=checkInputs(obj,varargin);


    eout=optim.problemdef.OptimizationExpression([]);

    createReshape(eout.OptimExprImpl,obj.OptimExprImpl,outSize);

    eout.IndexNamesStore=optim.internal.problemdef.makeValidIndexNames(...
    {{},{}},outSize);

end

function outSize=checkInputs(obj,cellSz)



    if isempty(cellSz)
        throwAsCaller(MException(message('MATLAB:minrhs')));
    end

    if isscalar(cellSz)



        outSize=cellSz{1};


        if numel(outSize)<2
            throwAsCaller(MException(message('MATLAB:getReshapeDims:sizeVector')));
        end


        if~isrow(outSize)
            throwAsCaller(MException(message('MATLAB:checkDimRow:rowSize')));
        end



        cellSz=num2cell(outSize);
    end




    emptyIndex=0;


    for i=1:numel(cellSz)
        szI=cellSz{i};

        if~isnumeric(szI)
            try

                szI=double(szI);
                cellSz{i}=szI;
            catch E
                throwAsCaller(MException(message('MATLAB:invalidConversion','double',class(szI))));
            end
        end

        if isempty(szI)
            if emptyIndex

                throwAsCaller(MException(message('MATLAB:getReshapeDims:unknownDim')));
            else


                emptyIndex=i;
                continue;
            end
        end


        if~isscalar(szI)
            throwAsCaller(MException(message('MATLAB:checkDimScalar:scalarSize')));
        end


        if szI<0
            throwAsCaller(MException(message('MATLAB:checkDimCommon:nonnegativeSize')));
        end


        if~isreal(szI)
            throwAsCaller(MException(message('MATLAB:checkDimCommon:complexSize')));
        end
        if isinf(szI)||(floor(szI)~=szI)
            throwAsCaller(MException(message('MATLAB:getReshapeDims:notRealInt')));
        end

    end


    if emptyIndex

        cellSz{emptyIndex}=1;
        outSize=[cellSz{:}];
        prodKnownDim=prod(outSize);
        totalElem=numel(obj);
        emptyDim=totalElem/prodKnownDim;
        if floor(emptyDim)~=emptyDim

            throwAsCaller(MException(message('MATLAB:getReshapeDims:notDivisible',prodKnownDim,totalElem)));
        else
            outSize(emptyIndex)=emptyDim;
        end
    else

        outSize=[cellSz{:}];
        if numel(obj)~=prod(outSize)
            throwAsCaller(MException(message('MATLAB:getReshapeDims:notSameNumel')));
        end
    end

end
