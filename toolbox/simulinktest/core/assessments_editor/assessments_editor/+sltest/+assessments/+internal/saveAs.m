function res=saveAs(assessmentInfo)
    [filename,pathname]=uiputfile(...
    {'*.ainfo','Assessment File (*.ainfo)'},...
    'Save Assessements as ...');
    res=-1;
    if~isequal(filename,0)
        res=fullfile(pathname,filename);
        fid=fopen(res,'w');
        fprintf(fid,'%s',assessmentInfo);
        fclose(fid);
    end

end

