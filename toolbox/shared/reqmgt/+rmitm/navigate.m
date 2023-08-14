function navigate(varargin)





    if dig.isProductInstalled('Simulink Test')&&license('test','simulink_test')
        [testFile,testCaseId]=rmitm.resolve(varargin{:});

        if isempty(testFile)
            error(message('Slvnv:rmitm:UnableToLocate',strtok(varargin{1},'|')));
        end


        callback=@()stm.internal.openTestCase(testFile,testCaseId);
        sltest.internal.invokeFunctionAfterWindowRenders(callback);
    else
        errordlg(getString(message('Slvnv:slreq:CannotNavigateInvalidLicense','Simulink Test')),...
        getString(message('Slvnv:rmi:navigate:NavigationError')));
    end
end
