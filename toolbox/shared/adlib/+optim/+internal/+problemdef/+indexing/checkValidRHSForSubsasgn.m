function checkValidRHSForSubsasgn(exprSize,rhsSize,isLinearIndexing)















    if all(rhsSize==1)
        return
    end

    if isLinearIndexing

        if prod(exprSize)~=prod(rhsSize)
            throwAsCaller(MException('MATLAB:subsassignnumelmismatch',getString(message('MATLAB:matrix:singleSubscriptNumelMismatch'))));
        end
    else

        if(sum(exprSize~=1)==1)&&(sum(rhsSize~=1)==1)




            if prod(exprSize)~=prod(rhsSize)
                leftSizeStr=strjoin(string(exprSize),'-by-');
                rightSizeStr=strjoin(string(rhsSize),'-by-');
                throwAsCaller(MException('MATLAB:subsassignnumelmismatch',getString(message('MATLAB:matrix:subsassigndimmismatchWithSizes',leftSizeStr,rightSizeStr))));
            end
        else



            if~isequal(exprSize,rhsSize)
                leftSizeStr=strjoin(string(exprSize),'-by-');
                rightSizeStr=strjoin(string(rhsSize),'-by-');
                throwAsCaller(MException('MATLAB:subsassigndimmismatch',getString(message('MATLAB:matrix:subsassigndimmismatchWithSizes',leftSizeStr,rightSizeStr))));
            end
        end
    end

