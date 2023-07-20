







function[foundDuplicate,errmsg]=checkAmbigousXmlOptions(...
    m3iModel,componentPackage,datatypePackage,interfacePackage,...
    implName)
    errmsg='';
    atomicComponents=autosar.mm.Model.findChildByTypeName(m3iModel,...
    'Simulink.metamodel.arplatform.component.AtomicComponent');
    [implPackage,~]=autosar.mm.sl2mm.ModelBuilder.getNodePathAndName(implName);
    packagePaths={componentPackage,datatypePackage,interfacePackage...
    ,implPackage};
    qualifiedPaths={implName};
    for i=1:length(atomicComponents)
        str=autosar.api.Utils.getQualifiedName(atomicComponents{i});
        [~,componentName]=autosar.mm.sl2mm.ModelBuilder.getNodePathAndName(str);


        qualifiedPaths=[qualifiedPaths,[componentPackage,'/',componentName]];%#ok<AGROW>
    end



    numQualifiedPaths=length(qualifiedPaths);
    [~,unique_pkg_indices]=unique(qualifiedPaths);
    duplicates=unique(qualifiedPaths(setdiff(1:numQualifiedPaths,unique_pkg_indices)));
    if~isempty(duplicates)
        foundDuplicate=1;
        errmsg=DAStudio.message('RTW:autosar:duplicatePkgPath',duplicates{1});
        return;
    end



    [indexSet1,indexSet2]=autosar.mm.util.findAmbigousPkgElementNames(...
    packagePaths,qualifiedPaths);
    foundDuplicate=0;
    if~isempty(indexSet1)&&~isempty(indexSet2)
        str2='';
        foundDuplicate=1;
        switch indexSet1{1}
        case 1
            str2=DAStudio.message('RTW:autosar:uiCompPackageLabel');
        case 2
            str2=DAStudio.message('RTW:autosar:uiDatatypePackageLabel');
        case 3
            str2=DAStudio.message('RTW:autosar:uiInterfacePackageLabel');
        case 4
            str2=DAStudio.message('RTW:autosar:uiImplLabel');
        case 5
            str2=DAStudio.message('RTW:autosar:uiIBLabel');
        end
        switch indexSet2{1}
        case 1
            str1=DAStudio.message('RTW:autosar:uiImplLabel');
        otherwise
            str1=DAStudio.message('RTW:autosar:uiComponentName');
        end

        strtrim(str1);
        strtrim(str2);

        str1=str1(1:end-1);
        str2=str2(1:end-1);
        errmsg=DAStudio.message('RTW:autosar:xmlOptionsSameLocationErr',str1,packagePaths{indexSet1{1}},str2);
    end
end

