function dsr=getDatasetRef(this,varargin)




    domain=[];
    if~isempty(varargin)
        domain=char(varargin{1});
    end

    dsr=Simulink.sdi.DatasetRef(this.id,domain,this.Repo);
end
