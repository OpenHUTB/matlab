


function exportData(obj)

    files=keys(obj.fData);
    for i=1:numel(files)
        file=files{i};
        data=obj.fData(file);

        if~isempty(data)

            text=jsonencode(data,'PrettyPrint',true);

            out_file=obj.getJsonFile(file);


            fid=fopen(out_file,'wt');
            fprintf(fid,text);
            fclose(fid);
        end
    end

end
