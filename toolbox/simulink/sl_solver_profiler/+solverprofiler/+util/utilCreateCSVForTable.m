function utilCreateCSVForTable(columnName,data,pathname,filename)


    columnNameFormat='';
    if~isempty(columnName)
        for i=1:length(columnName)
            columnNameFormat=[columnNameFormat,'%s, '];
        end
        columnNameFormat=[columnNameFormat,'\n'];
    end


    contentRowFormat='';
    if~isempty(data)
        for j=1:length(data(1,:))
            contentRowFormat=[contentRowFormat,'%s, '];
        end
        contentRowFormat=[contentRowFormat,'\n'];
    end


    fid=fopen(fullfile(pathname,filename),'w');
    try

        if~isempty(columnNameFormat)
            columnName=strrep(columnName,'| ','');
            fprintf(fid,columnNameFormat,columnName{:});
        end

        for i=1:length(data(:,1))
            for j=1:length(data(1,:))

                data{i,j}=num2str(removeHtmlStyling(data{i,j}));
            end
            fprintf(fid,contentRowFormat,data{i,:});
        end
        fclose(fid);
    catch
        fclose(fid);
    end

    function str=removeHtmlStyling(str)
        starts=strfind(str,'<');
        ends=strfind(str,'>');
        if~isempty(starts)
            for k=length(starts):-1:1
                str(starts(k):ends(k))=[];
            end
        end
    end

end