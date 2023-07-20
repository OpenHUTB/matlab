function filename=p_getfile(this)




    if isempty(this.file)
        filename=[];
    else
        filename=this.file.filename;
    end
