function perf(mat_file)


    data=importdata(mat_file);
    if isfield(data,'verification_data')
        ver_data=data.verification_data;
        for k=1:numel(ver_data)
            cell_data=ver_data{k};
            switch(cell_data.name)
            case 'PROFILER'
                prof_data=cell_data.data;
                write_csv(prof_data,[mat_file,'.csv']);
            end
        end
    else
        disp('no data avaliable for analysis');
        return;
    end

end

function write_csv(data,csv_file)
    Fid=fopen(csv_file,'w');
    for k=1:numel(data)
        struct_data=data(k);
        fprintf(Fid,struct_data.NAME);
        fprintf(Fid,',');
        fprintf(Fid,struct_data.TIME);
        fprintf(Fid,',');
        fprintf(Fid,struct_data.OBJECT);
        fprintf(Fid,',');
        fprintf(Fid,'\n');
    end
    fclose(Fid);
end

