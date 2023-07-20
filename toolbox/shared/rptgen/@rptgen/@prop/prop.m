function p=prop(h,propName,dataType,factoryValue,description,pType)





    if iscell(dataType)


        enumType=[h.Package.Name,'_',h.Name,'_',propName];
        e=rptgen.enum(enumType,dataType(:,1),dataType(:,2));
        dataType=e.Name;
    elseif isa(dataType,'rptgen.enum')
        dataType=dataType.Name;
    end

    p=rptgen.prop(h,propName,dataType);
    p.AccessFlags.Init='on';

    if nargin>3
        p.FactoryValue=factoryValue;
    end

    if nargin>4
        p.Description=description;
    end

    if nargin<6||isempty(pType)||isequal(pType,0)
        pType='MATLAB_Report_Gen';
    end

    if ischar(pType)
        if~license('test',pType)



            p.AccessFlags.PublicSet='off';



            p.AccessFlags.Serialize='off';
            p.Visible='off';
        end
    elseif pType==1

        p.AccessFlags.PublicGet='on';
    elseif pType==2

        p.Visible='off';
        p.AccessFlags.Serialize='off';

    end