function deletefile(filename)









    try




        filename=char(filename);
        if isscalar(dir(filename))
            wstate=warning;
            warningObj=onCleanup(@()warning(wstate));
            backtrace=warning('query','backtrace');
            backtraceObj=onCleanup(@()warning(backtrace));

            IDs={'backtrace','MATLAB:DELETE:FileNotFound',...
            'MATLAB:DELETE:Permission','MATLAB:DELETE:DirectoryDeletion'};
            for k=1:length(IDs)
                warning('off',IDs{k});
            end
            delete(filename)
        end
    catch
    end
end