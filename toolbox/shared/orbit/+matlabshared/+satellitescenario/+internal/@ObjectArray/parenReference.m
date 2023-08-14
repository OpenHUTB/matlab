function varargout=parenReference(asset,s)





    assert(s(1).Type==matlab.internal.indexing.IndexingOperationType.Paren);


    handles=asset.Handles(s(1).Indices{:});
    asset.Handles=handles;

    if numel(s)==1

        [varargout{1:nargout}]=asset;
    else

        try

            [varargout{1:nargout}]=asset.(s(2:end));
        catch ME

            if strcmp(ME.identifier,'MATLAB:TooManyOutputs')



                asset.(s(2:end));
                varargout={};
            else

                throwAsCaller(ME);
            end
        end
    end
end

