function resetDataBuffer(this)




    ds=this.Application.DataSource;
    if~isempty(ds)
        resetDataBuffer(ds);
    end
end
