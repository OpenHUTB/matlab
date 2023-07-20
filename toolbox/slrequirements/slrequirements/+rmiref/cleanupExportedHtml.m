


function cleanupExportedHtml(htmlFilePath)

    if~exist(htmlFilePath,'file')
        error('rmiref.cleanupExportedHtml(): file does not exist: %s',htmlFilePath);
    end


    fid=fopen(htmlFilePath,'r');
    html=fread(fid,'*char')';
    fclose(fid);




    html=regexprep(html,'<span\s+style=.display:none.>([^<]+)</span>','$1');

    html=regexprep(html,'\sstyle=''text-indent:-.\d+in''','');

    html=regexprep(html,'style=''margin-left:-[\d\.]+pt;','style=''');


    fid=fopen(htmlFilePath,'w');
    fwrite(fid,html,'char*1');
    fclose(fid);
end
