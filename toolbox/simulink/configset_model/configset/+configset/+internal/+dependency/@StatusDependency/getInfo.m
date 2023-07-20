function out=getInfo(obj)


    out.statusLimit=obj.StatusLimit;
    n=length(obj.ParentList);
    if n>0
        a=cell(n,1);
        for i=1:n
            pl=obj.ParentList{i};
            s=[];
            s.name=pl.Name;
            s.values=pl.ValueSet;
            s.flag=~pl.Negate;
            a{i}=s;
        end
        out.parentList=a;
        if~isempty(obj.License)
            out.licenseDep=obj.License.LicenseNames;
        end
    end

