function[out,dscr]=CodeCoverageSettings_entries(cs,~)


    dscr='CodeCoverageSettings enum option is dynamic generated.';

    toolNames=coder.coverage.CodeCoverageHelper.getTools(true);
    toolDisplayNames=coder.coverage.CodeCoverageHelper.getDisplayNamesForTools(cs,toolNames);

    out=struct('str',toolNames,'disp',toolDisplayNames);
