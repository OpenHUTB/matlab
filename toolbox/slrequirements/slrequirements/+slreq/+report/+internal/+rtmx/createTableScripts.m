function scriptStr=createTableScripts()

    import slreq.report.internal.rtmx.*
    filename=fullfile(matlabroot,'toolbox','slrequirements',...
    'slrequirements','+slreq','+report','+internal','+rtmx','forwardTableScripts.js');
    scriptContent=fileread(filename);

    scriptStr=createCellStr('script',scriptContent);
end
