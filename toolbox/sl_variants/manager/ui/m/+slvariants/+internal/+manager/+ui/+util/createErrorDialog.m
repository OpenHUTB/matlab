function createErrorDialog(value,errorId,varargin)







    dp=DAStudio.DialogProvider;
    errorMessage=DAStudio.message(errorId,varargin{:});
    if~isempty(value)
        errorMessage=[value,': ',errorMessage];
    end
    dp.errordlg(errorMessage,'Error',true);
end


