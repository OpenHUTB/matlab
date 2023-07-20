function[enumObject,errStr]=getEnumerationDefinitionByName(nameOfEnumClass,varargin)




    errStr='';
    enumObject=struct;

    UNIQUE_VALS=true;

    if~isempty(varargin)
        UNIQUE_VALS=varargin{1};
    end

    try


        [enumMembers,names]=enumeration(starepository.DataTypeHelper.parseDataTypeStringForEnumeration(nameOfEnumClass));

        if isempty(enumMembers)
            errStr=DAStudio.message('sl_web_widgets:tableview:enumDefinitionMissing',nameOfEnumClass);
        end
    catch ME
        errStr=ME.message;
        return;
    end

    if UNIQUE_VALS

        [uVal,uIdx,uIdxUVal]=unique(int32(enumMembers)');
        enumMembers=enumMembers(sort(uIdx));
        names=names(sort(uIdx));
    else
        [uVal,uIdx]=sort(int32(enumMembers)');
        enumMembers=enumMembers(uIdx);
        names=names(uIdx);
    end

    for k=1:length(enumMembers)
        enumObject.(names{k})=double(enumMembers(k));
    end
