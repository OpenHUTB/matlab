function outSize=getSubsasgnGrowLinearNumeric(maxIdx,outSize,indexNames)











    if maxIdx>prod(outSize)

        if numel(outSize)==2



            if outSize(1)==1

                if~isempty(indexNames{2})
                    throwAsCaller(MException(message('shared_adlib:operators:BadNumericArrayGrowth',2)));
                else
                    canGrow=true;

                    nonScalarDim=2;
                end
            elseif outSize(2)==1

                if~isempty(indexNames{1})
                    throwAsCaller(MException(message('shared_adlib:operators:BadNumericArrayGrowth',1)));
                else
                    canGrow=true;

                    nonScalarDim=1;
                end
            elseif outSize(1)==0&&outSize(2)==0

                canGrow=true;

                nonScalarDim=2;
                outSize(1)=1;
            else

                canGrow=false;
            end
        else




            nonScalarDim=find(outSize~=1);
            canGrow=numel(nonScalarDim)==1;
            if canGrow&&nonScalarDim<=numel(indexNames)&&~isempty(indexNames{nonScalarDim})
                throwAsCaller(MException(message('shared_adlib:operators:BadNumericArrayGrowth',nonScalarDim)));
            end
        end
        if~canGrow
            throwAsCaller(MException(message('MATLAB:matrix:ambiguousArrayGrowth')));
        end

        outSize(nonScalarDim)=maxIdx;
    end