

























function prop=getCustomStorageClassProperties(aModelName,aPackageName,aCSCName)

    prop=slci.WSVarInfo;
    if strcmpi(get_param(aModelName,'IgnoreCustomStorageClasses'),'off')

        package_name=aPackageName;

        csc_name=aCSCName;

        csc_defn=processcsc('GetCSCDefn',package_name,csc_name);
        csc_defn=csc_defn.getCSCDefnForPreview;
        assert(~isempty(csc_defn));
        assert(isa(csc_defn,'Simulink.CSCDefn'));

        prop.CSCName=csc_defn.Name;
        prop.Package=csc_defn.OwnerPackage;

        if csc_defn.IsOwnerInstanceSpecific
            prop.Owner='';
        else
            prop.Owner=csc_defn.Owner;
        end
        prop.StorageClass='Custom';
        prop.DataAccess=csc_defn.DataAccess;

        prop.DataInit=csc_defn.DataInit;


        prop.DataScope=csc_defn.DataScope;

        prop.CSCType=csc_defn.CSCType;
        mem_section_defn=processcsc('GetMemorySectionDefn',...
        csc_defn.OwnerPackage,...
        csc_defn.MemorySection);
        prop.IsConst=mem_section_defn.IsConst;
    else
        prop.StorageClass='SimulinkGlobal';
        prop.DataAccess='Struct';
        prop.DataInit='Auto';
        prop.CSCType='FlatStructure';
    end
end
