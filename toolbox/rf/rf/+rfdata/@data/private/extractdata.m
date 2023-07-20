function datasec=extractdata(h,a_cell)





    datasec=cell(1,numel(a_cell));
    ds_idx=1;
    ncell=numel(a_cell);
    for temp_i=1:ncell
        dataline=sscanf(a_cell{temp_i},'%f');
        if~isempty(dataline)
            datasec{ds_idx}=dataline;
            ds_idx=ds_idx+1;
        end
    end
    datasec=datasec(1:ds_idx-1);