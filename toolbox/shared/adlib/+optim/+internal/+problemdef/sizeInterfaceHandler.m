function varargout=sizeInterfaceHandler(obj,dim)








    try

        multipleInputs=nargin>1;
        multipleOutputs=nargout>1;


        if multipleInputs&&multipleOutputs
            throwAsCaller(MException(message('MATLAB:maxlhs')));
        end


        if multipleInputs&&...
            ((~isnumeric(dim)&&~islogical(dim))||~isscalar(dim)||dim<1||floor(dim)~=dim)
            throwAsCaller(MException(message('MATLAB:getdimarg:dimensionMustBePositiveInteger')));
        end


        thisSize=getSize(obj);


        if~multipleInputs&&~multipleOutputs

            varargout={thisSize};
        elseif~multipleInputs&&multipleOutputs

            ndims=numel(thisSize);
            if nargout>=ndims

                varargout(1:nargout)={1};
                szCell=num2cell(thisSize);
                [varargout{1:ndims}]=deal(szCell{:});
            else



                throwAsCaller(MException(message('shared_adlib:sizeInterfaceHandler:MustReturnNDimOutputs',ndims)));
            end
        else


            ndims=numel(thisSize);
            if dim<=ndims
                varargout{1}=thisSize(dim);
            else
                varargout{1}=1;
            end
        end
    catch E
        throwAsCaller(E);
    end