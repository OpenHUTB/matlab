function slciTestEnv_cleanup(prevFeatureVal)


    fprintf('### Resetting MATLAB:loadlibrary:DirectoryCleanupFailed waring ###\n');
    warning(prevFeatureVal.warn.state,'MATLAB:loadlibrary:DirectoryCleanupFailed');
