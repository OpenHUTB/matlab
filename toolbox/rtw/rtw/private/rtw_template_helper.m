function varargout=rtw_template_helper(function_name,varargin)








    [varargout{1:nargout}]=feval(function_name,varargin{1:end});






    function isValid=isValid_buildinToken(region_Name,token)%#ok
        isValid=false;
        FunctionBannerTokens={...
        'FunctionName','Arguments','ReturnType','GeneratedBy',...
        'ModelName','FunctionDescription','GeneratedFor',...
        'BlockDescription','"%"'};

        SharedUtilityBannerTokens={...
        'FunctionName','Arguments','ReturnType','GeneratedBy',...
        'FunctionDescription','"%"'};
        FileBannerTokens={...
        'FileName','FileType','FileTag','ModelName',...
        'ModelVersion','RTWFileVersion','RTWFileGeneratedOn',...
        'TLCVersion','SourceGeneratedOn','CodeGenSettings','"%"'};

        switch region_Name
        case 'FunctionBanner'
            tokens=FunctionBannerTokens;
        case 'SharedUtilityBanner'
            tokens=SharedUtilityBannerTokens;
        case 'FileBanner'
            tokens=FileBannerTokens;
        case 'FileTrailer'
            tokens=FileBannerTokens;
        otherwise
            return;
        end
        isValid=any(strcmp(tokens,token));
        return;





        function doclink=get_doc_link()
            doclink='<a href = "matlab:helpview([docroot ''/toolbox/ecoder/helptargets.map''], ''custom_file_processing'')">section</a>';
            return;


