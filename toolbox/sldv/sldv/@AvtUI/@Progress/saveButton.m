


function saveButton(dlgSrc,dialogH)




    if~isempty(dlgSrc.logPath)

        [~,~,ext]=fileparts(dlgSrc.logPath);
        if strncmpi(ext,'.htm',4)
            web(dlgSrc.logPath);
        else
            edit(dlgSrc.logPath);
        end
        return;
    end

    saveStyles={'*.txt','Text file';'*.html','HTML File'};
    title=getString(message('Sldv:SldvresultsSummary:SaveSimulinkDesignVerifier'));

    [year,month,day,hour,min,sec]=datevec(now);
    fileName=sprintf('sldv_log_%d_%d_%d_%d_%d_%d',year,month,day,hour,min,floor(sec));

    [fileName,pathName,style]=uiputfile(saveStyles,title,fileName);



    if~ischar(fileName)
        return;
    end

    rawLog=dlgSrc.Log;

    exts={'.txt','.html'};
    if any(fileName=='.')
        filePath=fullfile(pathName,fileName);
    else
        filePath=fullfile(pathName,[fileName,exts{style}]);
    end

    fid=fopen(filePath,'w');

    if fid==-1
        errordlg(getString(message('Sldv:SldvresultsSummary:ProgressSaveError',filePath)),...
        getString(message('Sldv:SldvresultsSummary:ProgressSaveErrorTitle')),'modal');
        return;
    end

    if(style==1)

        str=sldvshareprivate('util_remove_html',rawLog);
        fprintf(fid,'%s',str);
    else

        fprintf(fid,'<html><body>\n%s</html></html>',rawLog);
    end

    fclose(fid);
    dlgSrc.logPath=filePath;
    dlgSrc.saved=true;
    dlgSrc.Log=[dlgSrc.Log,'<br>',getString(message('Sldv:SldvresultsSummary:LogSavedIn')),' ',filePath,'<br>'];
    dialogH.refresh();

