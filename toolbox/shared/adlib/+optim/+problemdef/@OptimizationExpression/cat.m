function eout=cat(dim,varargin)


















    if~isscalar(dim)||~isreal(dim)||dim~=floor(dim)||...
        dim<=0||~isfinite(dim)
        throw(MException(message('MATLAB:catenate:invalidDimension')))
    end




    eout=[];
    eoutIs0by0=true;

    exprList=cell(1,nargin);

    numRight=0;

    outSize=[0,0];

    input=varargin;
    i=1;
    while(i<=numel(input))



        expr=input{i};
        if isnumeric(expr)&&~isa(expr,'optim.problemdef.OptimizationExpression')
            while i<numel(input)&&isnumeric(input{i+1})&&~builtin('isempty',input{i+1})


                expr=cat(dim,expr,input{i+1});
                i=i+1;
            end
            expr=optim.problemdef.OptimizationNumeric(expr);
        end
        if isa(expr,'optim.problemdef.OptimizationExpression')

            concatWith0by0=~any(getSize(expr));
            if~concatWith0by0
                if eoutIs0by0
                    eout=optim.problemdef.OptimizationExpression(expr);
                    outSize=getSize(eout);
                    numRight=numRight+1;
                    exprList{1}=expr.OptimExprImpl;
                    eoutIs0by0=false;
                else


                    exprSize=getSize(expr);

                    inSize=outSize;

                    outSize=checkInputs(outSize,exprSize,dim);
                    if isequal(exprSize,outSize)

                        eout=optim.problemdef.OptimizationExpression(expr);
                        exprList{1}=expr.OptimExprImpl;
                    elseif~isequal(inSize,outSize)



                        numRight=numRight+1;
                        exprList{numRight}=expr.OptimExprImpl;
                    end
                end
            end
            i=i+1;
        else
            inputType=class(input{i});
            requiredType='OptimizationExpression';
            throwAsCaller(MException(message('MATLAB:invalidConversion',requiredType,inputType)));
        end

    end

    if eoutIs0by0

        eout=optim.problemdef.OptimizationExpression([0,0],{{},{}});
    elseif numRight>1
        exprList(numRight+1:end)=[];


        eout=optim.problemdef.OptimizationExpression([]);

        createConcat(eout.OptimExprImpl,exprList,dim,outSize);

        eout.IndexNamesStore=optim.internal.problemdef.makeValidIndexNames(...
        {{},{}},outSize);
    end

end


function outSize=checkInputs(leftSize,rightSize,dim)


    padding=max([numel(leftSize),numel(rightSize),dim]);
    leftSize(end+1:padding)=1;
    rightSize(end+1:padding)=1;


    inconsistentCols=(leftSize~=rightSize);
    inconsistentCols=inconsistentCols([1:dim-1,dim+1:end]);
    if any(inconsistentCols)
        throwAsCaller(MException(message('MATLAB:catenate:opaqueDimensionMismatch')));
    end


    outSize=rightSize;
    outSize(dim)=leftSize(dim)+rightSize(dim);
end
