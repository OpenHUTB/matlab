function help






    pkg=findpackage('RptgenSL');
    dirInfo=what(pkg.Name);

    fcn=sort(get(pkg.Functions,'Name'));

    maxSize=length(pkg.Name)+max(cellfun('length',fcn))+1;

    disp(getString(message('RptgenSL:rptgen_sl:classesAndFunctionsMsg')))
    for i=1:length(fcn)
        helpContent=help(fullfile(dirInfo(1).path,fcn{i}));
        cr=find(helpContent==char(10));
        ws=find(helpContent==' ');
        helpContent=helpContent(ws(2)+1:cr(1)-1);

        fcnName=[pkg.Name,'.',fcn{i}];
        disp([fcnName,blanks(maxSize-length(fcnName)),' - ',helpContent]);
    end

