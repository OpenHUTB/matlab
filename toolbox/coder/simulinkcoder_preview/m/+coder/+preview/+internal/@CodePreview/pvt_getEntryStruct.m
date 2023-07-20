




function entryStruct=pvt_getEntryStruct(obj)
    entry=obj.getEntry();
    if isa(entry,'coderdictionary.data.StorageClass')
        entryStruct=loc_getStorageClassStruct(entry);
    elseif isa(entry,'coderdictionary.data.LegacyStorageClass')
        entryStruct=loc_getLegacyStorageClassStruct(entry);
    elseif isa(entry,'coderdictionary.data.MemorySection')
        entryStruct=loc_getMemorySectionStruct(entry);
    elseif isa(entry,'coderdictionary.data.LegacyMemorySection')
        entryStruct=loc_getLegacyMemorySectionStruct(entry);
    else
        error(['Preview does not support ',class(entry)]);
    end
end

function entryStruct=loc_getLegacyMemorySectionStruct(data)
    className=data.getPropertyValue('ClassName');
    package=data.Package;
    ms=processcsc('GetMemorySectionDefn',package,className);
    entryStruct.StorageClass=[];
    entryStruct.MemorySection=ms;
end


function entryStruct=loc_getMemorySectionStruct(data)
    ms=getDefaultMemorySectionDefinition;
    ms.Name=data.Name;
    ms.Comment=strrep(data.Comment,'\n',newline);
    ms.PrePragma=strrep(data.PreStatement,'\n',newline);
    ms.PostPragma=strrep(data.PostStatement,'\n',newline);
    ms.IsConst=false;
    ms.IsVolatile=false;
    ms.Qualifier='';
    entryStruct.StorageClass=[];
    entryStruct.MemorySection=ms;
end

function entryStruct=loc_getLegacyStorageClassStruct(data)
    className=data.getPropertyValue('ClassName');
    package=data.Package;
    sc=processcsc('GetCSCDefn',package,className);
    if isempty(sc.MemorySection)
        ms=[];
    else
        ms=processcsc('GetMemorySectionDefn',package,sc.MemorySection);
    end
    entryStruct.StorageClass=sc;
    entryStruct.MemorySection=ms;
end
function entryStruct=loc_getStorageClassStruct(data)
    sc=struct('Name','','DataInit','',...
    'DataAccess','','IsDataAccessInstanceSpecific',false,...
    'DataScope','','IsDataScopeInstanceSpecific',false,...
    'HeaderFile','','IsHeaderFileInstanceSpecific',false,...
    'CommentSource','','TypeComment','','DeclareComment','','DefineComment','',...
    'CSCType','',...
    'CSCTypeAttributes','',...
    'MultiInstanceCSCTypeAttributes','',...
    'isAccessMethod',false,...
    'IsGrouped',true,...
    'DefinitionFile','',...
    'DataUsage',struct('isParameter',false,'isSignal',false));
    sc.Name=data.Name;
    switch data.DataInit
    case coderdictionary.data.DataInitEnum.Dynamic
        sc.DataInit='Dynamic';
    case coderdictionary.data.DataInitEnum.Static
        sc.DataInit='Static';
    case coderdictionary.data.DataInitEnum.None
        sc.DataInit='None';
    case coderdictionary.data.DataInitEnum.Auto
        sc.DataInit='Auto';
    end

    if strcmp(data.DataAccess,'Pointer')
        sc.DataAccess='Pointer';
    else

        sc.DataAccess='Direct';
        if strcmp(data.DataAccess,'Function')
            sc.isAccessMethod=true;
        end
    end

    switch data.DataScope
    case coderdictionary.data.ScopeEnum.Exported
        sc.DataScope='Exported';
    case coderdictionary.data.ScopeEnum.Imported
        sc.DataScope='Imported';
    end
    sc.HeaderFile=data.HeaderFile;
    sc.DefinitionFile=data.DefinitionFile;

    if data.AccessibleByParameters
        sc.DataUsage.isParameter=true;
    end

    if data.AccessibleBySignals
        sc.DataUsage.isSignal=true;
    end

    if strcmp(data.StorageType,'Unstructured')
        sc.CSCType='Unstructured';
    elseif strcmp(data.StorageType,'Structured')

        sc.CSCType='FlatStructure';





        structProp=struct('IsTypeDef',true,'IsStructNameInstanceSpecific',false,...
        'StructName','','BitPackBoolean',false,'TypeToken','',...
        'TypeTag',' ','TypeName','');
        structProp.StructName=data.ComponentSingleInstance.InstanceNamingRule;
        structProp.TypeName=data.ComponentSingleInstance.TypeNamingRule;
        sc.CSCTypeAttributes=structProp;
    else
        sc.CSCType='Mixed';
        if strcmp(data.SingleInstanceStorageType,'Structured')
            sc.SingleInstanceCSCType='FlatStructure';
            structProp=struct('IsTypeDef',true,'IsStructNameInstanceSpecific',false,...
            'StructName','','BitPackBoolean',false,'TypeToken','',...
            'TypeTag',' ','TypeName','');
            structProp.StructName=data.ComponentSingleInstance.InstanceNamingRule;
            structProp.TypeName=data.ComponentSingleInstance.TypeNamingRule;
            sc.CSCTypeAttributes=structProp;
        else
            sc.SingleInstanceCSCType='Unstructured';
        end
        structProp=struct('IsTypeDef',true,'IsStructNameInstanceSpecific',false,...
        'StructName','','BitPackBoolean',false,'TypeToken','',...
        'TypeTag',' ','TypeName','','Placement','');
        structProp.StructName=data.ComponentMultiInstance.InstanceNamingRule;
        structProp.TypeName=data.ComponentMultiInstance.TypeNamingRule;
        structProp.Placement=data.ComponentMultiInstance.Placement;
        sc.MultiInstanceCSCTypeAttributes=structProp;
    end
    if isempty(data.MemorySection)
        ms=getDefaultMemorySectionDefinition;
    else
        ms=getMemorySectionDefinition(data.MemorySection);
    end
    ms.IsConst=data.Const;
    ms.IsVolatile=data.Volatile;
    ms.Qualifier=data.OtherQualifier;
    entryStruct.StorageClass=sc;
    entryStruct.MemorySection=ms;
end


function ms=getDefaultMemorySectionDefinition
    ms=struct('Name','','Comment','','PrePragma','','PostPragma','',...
    'IsConst',false,'IsVolatile',false,'Qualifier','');
end

function ms=getMemorySectionDefinition(data)
    ms=getDefaultMemorySectionDefinition;
    ms.Name=data.Name;
    ms.Comment=strrep(data.Comment,'\n',newline);
    ms.PrePragma=strrep(data.PreStatement,'\n',newline);
    ms.PostPragma=strrep(data.PostStatement,'\n',newline);
    ms.IsConst=false;
    ms.IsVolatile=false;
    ms.Qualifier='';
end


