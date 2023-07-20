




























function prop=extractDataObjectInfo(mdl,obj,context)

    prop=[];


    if isa(obj,'Simulink.Data')
        prop=slci.WSVarInfo;

        if(strcmp(obj.CoderInfo.StorageClass,'Custom'))
            if strcmpi(get_param(mdl,'IgnoreCustomStorageClasses'),'off')

                package_name=obj.CSCPackageName;

                csc_name=obj.CoderInfo.CustomStorageClass;
                isSCAutoMigrationOn=(slfeature('ModelOwnedDataIM')==1)...
                &&(slfeature('AutoMigrationIM')==1)...
                &&(slfeature('AddContextToDataObject')==1)...
                &&(slfeature('AddContextToMWSDataObjects')==2)...
                &&(slfeature('AddContextToEmbeddedSignal')==3)...
                &&(slfeature('UseObservableWSProxyForEvalinInModelWS')==1);
                if isSCAutoMigrationOn
                    aPattern='(?<cscname>\w+)\s+[(](?<packagename>\w+)[)]';
                    result=regexp(csc_name,aPattern,'names');
                    if~isempty(result)
                        csc_name=result.cscname;
                    end
                end

                csc_defn=processcsc('GetCSCDefn',package_name,csc_name);
                csc_defn=csc_defn.getCSCDefnForPreview;
                assert(~isempty(csc_defn));
                assert(isa(csc_defn,'Simulink.CSCDefn'));



                if(strcmp(csc_name,'ExportToFile'))
                    prop.CSCHeaderFile=obj.CoderInfo.CustomAttributes.HeaderFile;
                    prop.CSCDefinitionFile=obj.CoderInfo.CustomAttributes.DefinitionFile;
                end

                prop.CSCName=csc_defn.Name;
                prop.Package=csc_defn.OwnerPackage;
                prop.Alias=obj.CoderInfo.Identifier;
                if csc_defn.IsOwnerInstanceSpecific
                    prop.Owner=obj.CoderInfo.CustomAttributes.Owner;
                else
                    prop.Owner=csc_defn.Owner;
                end
                prop.StorageClass='Custom';
                prop.DataAccess=csc_defn.DataAccess;

                prop.DataInit=csc_defn.DataInit;
                if strcmpi(prop.DataInit,'InstanceSpecific')&&...
                    isfield(obj.CoderInfo,'CustomAttributes')&&...
                    isfield(obj.CoderInfo.CustomAttributes,'DataInit')
                    prop.DataInit=obj.CoderInfo.CustomAttributes.DataInit;
                end

                prop.DataScope=csc_defn.DataScope;
                if strcmpi(prop.DataScope,'InstanceSpecific')&&...
                    isfield(obj.CoderInfo,'CustomAttributes')&&...
                    isfield(obj.CoderInfo.CustomAttributes,'DataScope')
                    prop.DataScope=obj.CoderInfo.CustomAttributes.DataScope;
                end
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
        else

            prop.Alias=obj.CoderInfo.Identifier;
            prop.StorageClass=obj.CoderInfo.StorageClass;

            switch obj.CoderInfo.StorageClass
            case 'Model default'
                prop.StorageClass='SimulinkGlobal';
                prop.DataAccess='Struct';
                prop.DataInit='Auto';
                prop.CSCType='FlatStructure';
            case 'SimulinkGlobal'
                prop.DataAccess='Struct';
                prop.DataInit='Auto';
                prop.CSCType='FlatStructure';
            case 'ExportedGlobal'
                prop.DataAccess='Direct';
                prop.DataInit='Auto';
                prop.CSCType='Unstructured';
            case 'ImportedExtern'
                prop.DataAccess='Direct';
                prop.DataInit='None';
                prop.CSCType='Unstructured';
            case 'ImportedExternPointer'
                prop.DataAccess='Pointer';
                prop.DataInit='None';
                prop.CSCType='Unstructured';
            end
        end
        if~isempty(obj.findprop('Value'))
            prop.InitialValue=obj.Value;
        elseif exist('context','var')&&isprop(obj,'InitialValue')

            try %#ok slResolve may fail, but that is ok, use default value



                init_val=slResolve(obj.InitialValue,context);
                prop.InitialValue=init_val;
            end
        end
        prop.IsStruct=isstruct(prop.InitialValue);



        prop.DataType=obj.DataType;
    end
end


