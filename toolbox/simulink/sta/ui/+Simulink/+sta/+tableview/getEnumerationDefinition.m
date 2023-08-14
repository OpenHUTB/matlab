function[enumObject,errStr]=getEnumerationDefinition(sigID)



    repoUtil=starepository.RepositoryUtility();
    nameOfEnumClass=repoUtil.getMetaDataByName(sigID,'EnumName');

    enumObject=[];
    errStr=[];

    nameOfEnumClass=starepository.DataTypeHelper.parseDataTypeStringForEnumeration(nameOfEnumClass);

    whichEnumDefinition=which(nameOfEnumClass);

    if isempty(whichEnumDefinition)
        errStr=DAStudio.message('sl_sta:editor:enumNotOnPath',nameOfEnumClass);
    end

    try


        [enumMembers,names]=enumeration(nameOfEnumClass);
    catch ME
        errStr=ME.message;
        return;
    end


    [uVal,uIdx,uIdxUVal]=unique(int32(enumMembers)');
    enumMembers=enumMembers(sort(uIdx));
    names=names(sort(uIdx));


    for k=length(enumMembers):-1:1

        enumObject(k).value=int32(enumMembers(k));
        enumObject(k).label=names{k};
    end
