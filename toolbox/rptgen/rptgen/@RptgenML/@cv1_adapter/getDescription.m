function d=getDescription(this)






    if isempty(this.OldComponent)
        d=getString(message('rptgen:RptgenML_cv1_adapter:adapterDescriptionLabel'));
    else
        i=getinfo(this);
        d=i.Desc;
    end
