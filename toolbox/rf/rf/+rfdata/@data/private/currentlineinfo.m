function result=currentlineinfo(h,type,name,xname,xdata,xunit,...
    yunit,other,Zs,Z0,Zl,indexes)




    result.Type=type;
    result.Name=name;
    result.Xname=xname;
    result.XData=xdata;
    result.XUnit=xunit;
    result.YUnit=yunit;
    if nargin==7
        other='';
        Zs=50;
        Z0=50;
        Zl=50;
        indexes={};
    elseif nargin==8
        Zs=50;
        Z0=50;
        Zl=50;
        indexes={};
    elseif nargin==9
        Z0=50;
        Zl=50;
        indexes={};
    elseif nargin==10
        Zl=50;
        indexes={};
    elseif nargin==11
        indexes={};
    end
    result.OtherInfo=other;
    result.Zs=Zs;
    result.Z0=Z0;
    result.Zl=Zl;
    result.Indexes=indexes;