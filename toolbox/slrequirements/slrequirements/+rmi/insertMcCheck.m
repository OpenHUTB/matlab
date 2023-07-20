function insertMcCheck(reportFileName)






    [~,~,ext]=fileparts(reportFileName);
    if isempty(ext)
        reportFileName=[reportFileName,'.html'];
    elseif~strcmp(ext,'.html')
        error(message('Slvnv:reqmgt:UnsupportedFileType',reportFileName));
    end

    if exist(reportFileName,'file')==2
        disp(getString(message('Slvnv:reqmgt:PostprocessRptBegin',reportFileName)));
        backupName=strrep(reportFileName,'.html','_backup.html');
        copyfile(reportFileName,backupName);
        try
            localInsertMcCheck(reportFileName);
            delete(backupName);
        catch Ex
            warning(Ex.identifier,Ex.message);
            copyfile(backupName,reportFileName);
        end
        disp(getString(message('Slvnv:reqmgt:PostprocessRptEnd',reportFileName)));
    else
        warning(message('Slvnv:reqmgt:ReportFileNotFound',reportFileName));
    end
end

function localInsertMcCheck(reportFileName)
    tmpFileName=regexprep(reportFileName,'.html$','_tmp.html');
    fidIn=fopen(reportFileName);
    fidOut=fopen(tmpFileName,'w','n','UTF-8');
    done=false;
    while true
        line=fgetl(fidIn);
        if~ischar(line)
            break;
        end
        if~done
            if contains(line,'<head>')
                line=sprintf('%s\n%s',line,mcIconScript());
            elseif contains(line,'<hr>')
                line=insertMcIcon(line);
                done=true;
            end
        end
        fprintf(fidOut,'%s\n',line);
    end
    fclose(fidIn);
    fclose(fidOut);
    delete(reportFileName);
    movefile(tmpFileName,reportFileName);
end

function out=mcIconScript()


    mwlinkImage='http://127.0.0.1:31415/images/mwlink.ico';
    imageSize=32;


    alertLine1=getString(message('Slvnv:reqmgt:MatlabConnectorAlertLine1'));
    alertLine2=getString(message('Slvnv:reqmgt:MatlabConnectorAlertLine2'));
    alertLine3='>> rmi(\\''httpLink\\'')';
    alertContent=sprintf('%s\\\\n%s\\\\n%s',alertLine1,alertLine2,alertLine3);




    out=[...
    '<script type="text/javascript" charset="utf-8">',char(10)...
    ,'<!--',char(10)...
    ,'// We cannot simply hard-code mwlink.ico because this gets cached',char(10)...
    ,'// and browser does not call the URL when re-opening report.',char(10)...
    ,'function mcImage() {',char(10)...
    ,'    var randomnumber=Math.floor(Math.random()*1000001);',char(10)...
    ,'    var tmpUrl = "',mwlinkImage,'?" + randomnumber;',char(10)...
    ,'    return "<img src=\"" + tmpUrl + "\" width=\"',num2str(imageSize),'\" onError=\"alert(''',alertContent,''');\">";',char(10)...
    ,'}',char(10)...
    ,'-->',char(10)...
    ,'</script>'];
end

function out=insertMcIcon(in)
    firstHR=strfind(in,'<hr>');
    outLeft=in(1:firstHR-1);
    outRight=in(firstHR:end);
    insertedHTML='<script type="text/javascript">document.write("<p>" + mcImage() + "</p>");</script>';
    out=[outLeft,insertedHTML,outRight];
end

