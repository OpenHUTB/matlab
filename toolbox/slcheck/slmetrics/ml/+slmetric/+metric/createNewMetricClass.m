




function createNewMetricClass(classname)
    if isstring(classname)
        classname=classname.char;
    end

    if isvarname(classname)
        template=fileread(fullfile(matlabroot,'toolbox','slcheck',...
        'slmetrics','private','MetricTemplate.txt'));

        template=regexprep(template,'<CLASSNAME>',classname);

        filename=[classname,'.m'];

        if exist([pwd,filesep,filename],'file')~=2

            fid=fopen(filename,'w');
            if fid==-1
                DAStudio.error('slcheck:metricengine:MF_CannotOpenFile',filename,pwd);
            end

            fprintf(fid,'%s',template);
            fclose(fid);
            edit(filename);
        end
    else
        DAStudio.error('slcheck:metricengine:MF_InvalidClassName',classname);
    end
end