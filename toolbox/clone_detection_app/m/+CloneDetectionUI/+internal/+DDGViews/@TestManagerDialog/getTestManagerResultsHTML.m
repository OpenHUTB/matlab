function htmlFile=getTestManagerResultsHTML(this,~)




    htmlFile=fullfile(tempdir,'clone_detection_test_manager_index.html');


    closeImg=fullfile(matlabroot,'toolbox','clone_detection_app','m','ui','images','close.png');
    strrep(closeImg,filesep,[filesep,filesep]);
    openImg=fullfile(matlabroot,'toolbox','clone_detection_app','m','ui','images','open.png');
    strrep(openImg,filesep,[filesep,filesep]);
    cssPath=fullfile(matlabroot,'toolbox','clone_detection_app','m','ui','css','testmanager.css');
    tickImg=fullfile(matlabroot,'toolbox','clone_detection_app','m','ui','images','tick.png');
    failedImg=fullfile(matlabroot,'toolbox','clone_detection_app','m','ui','images','failed.png');

    html=[
    '<!DOCTYPE html>',...
    '<html>',...
    '<head>',...
    '<meta http-equiv="X-UA-Compatible" content="IE=8"> ',...
    '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',...
    '<title>Clone Detection Report</title>',...
    '<link rel="stylesheet" type="text/css" href="',cssPath,'">',...
    '</head>',...
    '<body>'];


    html=[html,...
    '<center>'];

    resultSet=CloneDetectionUI.internal.util.runTestManager(get_param(this.model,'Name'));
    result=strcmp(resultSet.Outcome,'Passed');
    if(result)
        img=tickImg;
        resultsMsg=message('sl_pir_cpp:toolstrip:TestManagerDialogPassedResult').getString;
    else
        img=failedImg;
        resultsMsg=message('sl_pir_cpp:toolstrip:TestManagerDialogFailedResult').getString;
    end

    html=[html,...
    '<div>',...
    '<center>',...
    '<img src="',img,'" height="50" width = "50"/>',...
    '&nbsp<span><b>',resultsMsg,'</b></span>',...
    '</center>',...
    '</div>'];

    testManagerURL=sprintf('matlab:CloneDetectionUI.internal.util.launchTestManager(''%s'')',get_param(this.model,'Name'));

    viewResultsStr=message('sl_pir_cpp:toolstrip:TestManagerDialogViewResult').getString;
    html=[html,...
    '<br><center><a href="',testManagerURL,'">',...
    viewResultsStr,...
    '</a></center><br/>'];


    html=[html,...
    '<script>',...
    'var z;',...
    'var coll = document.getElementsByClassName("collapsible");',...
    'var i;',...
    '    for (i = 0; i < coll.length; i++) {',...
    '        coll[i].addEventListener("click", function() {',...
    '        console.log("hello report"); ',...
    '        this.classList.toggle("active");',...
    '        var content = this.nextElementSibling;',...
    '         if (content.style.maxHeight) {',...
    '            content.style.maxHeight = null;',...
    '        }',...
    '        else {',...
    '            content.style.maxHeight = content.scrollHeight + "px";',...
    '        }',...
    '      });',...
    '    }',...
    '</script>',...
    '</body>',...
'</html>'
    ];

    fid=fopen(htmlFile,'w');
    fprintf(fid,'%s',html);
    fclose(fid);

end


