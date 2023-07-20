function n=getName(this)






    if isempty(this.OldComponent)
        n=getString(message('rptgen:RptgenML_cv1_adapter:adapterVersionLabel'));
    else
        i=getinfo(this);
        n=i.Name;
    end
