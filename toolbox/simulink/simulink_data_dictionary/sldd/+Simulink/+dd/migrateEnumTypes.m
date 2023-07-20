function[migrated,notMigrated]=...
    migrateEnumTypes(enumClassNames,dd)























    migrated=l_successStruct('',{});
    notMigrated=l_errorStruct('',{});
    ddOpenedHere=false;


    if iscell(enumClassNames)

        for i=1:length(enumClassNames)
            enumClassName=enumClassNames{i};
            if~ischar(enumClassName)
                DAStudio.error('SLDD:sldd:EnumTypeMigrationInvalidClassNamesArg');
            end
        end
    else
        DAStudio.error('SLDD:sldd:EnumTypeMigrationInvalidClassNamesArg');
    end

    if ischar(dd)
        ddConn=Simulink.dd.open(dd);
        ddOpenedHere=true;
    else
        if isa(dd,'Simulink.dd.Connection')
            ddConn=dd;
        else
            DAStudio.error('SLDD:sldd:EnumTypeMigrationInvalidDDArg');
        end
    end

    for i=1:length(enumClassNames)
        enumClassName=enumClassNames{i};

        errorStruct=[];
        successStruct=[];
        renamedClassdefMFile='';
        renamedClassdefPFile='';


        if~ischar(enumClassName)
            errorStruct=l_errorStruct(enumClassName,...
            DAStudio.message('SLDD:sldd:EnumTypeMigrationClassNameNotString'));
        end
        if isempty(errorStruct)
            hClass=Simulink.getMetaClassIfValidEnumDataType(enumClassName);
            if isempty(hClass)
                errorStruct=l_errorStruct(enumClassName,...
                DAStudio.message('SLDD:sldd:EnumTypeMigrationClassNotEnum'));
            end
        end


        if isempty(errorStruct)
            if ddConn.entryExists(['Global.',enumClassName],false)

                errorStruct=l_errorStruct(enumClassName,...
                DAStudio.message('SLDD:sldd:EnumTypeMigrationNameAlreadyDefined'));
            end
        end

        if isempty(errorStruct)

            ddEnumTypeSpec=...
            Simulink.dd.createEnumTypeSpecFromMCOSEnum(enumClassName);



            classdefMFile='';
            classdefPFile='';

            classdefFile=which(enumClassName);
            existStatus=exist(classdefFile,'file');
            switch existStatus
            case 0

            case 2

            case 6

                classdefPFile=classdefFile;

                renamedClassdefPFile=[classdefPFile,'.save'];
                [~,moveMessage,~]=movefile(classdefPFile,renamedClassdefPFile);
                if isempty(moveMessage)


                    classdefFile=which(enumClassName);
                    existStatus=exist(classdefFile,'file');
                else
                    renamedClassdefPFile='';
                    errorStruct=l_errorStruct(enumClassName,moveMessage);
                end
            otherwise

            end
        end

        if isempty(errorStruct)
            if existStatus==2

                classdefMFile=classdefFile;

                renamedClassdefMFile=[classdefMFile,'.save'];
                [~,moveMessage,~]=movefile(classdefMFile,renamedClassdefMFile);
                if~isempty(moveMessage)
                    renamedClassdefMFile='';
                    errorStruct=l_errorStruct(enumClassName,moveMessage);
                end
            end
        end

        if isempty(errorStruct)

            classdefFile=which(enumClassName);
            existStatus=exist(classdefFile,'file');
            if existStatus~=0
                errorStruct=l_errorStruct(enumClassName,...
                DAStudio.message('SLDD:sldd:EnumTypeMigrationMultipleClassdefOnPath'));
            end
        end

        if isempty(errorStruct)


            if Simulink.data.internal.clearClass(enumClassName)


                ddConn.insertEntry('Global',enumClassName,ddEnumTypeSpec);
                renamedFiles={};
                if~isempty(renamedClassdefMFile)
                    renamedFiles{end+1}=renamedClassdefMFile;
                end
                if~isempty(renamedClassdefPFile)
                    renamedFiles{end+1}=renamedClassdefPFile;
                end
                successStruct=l_successStruct(enumClassName,renamedFiles);
            else


                errorStruct=l_errorStruct(enumClassName,...
                DAStudio.message('SLDD:sldd:EnumTypeMigrationInstancesExist'));
            end
        end

        if~isempty(successStruct)
            migrated=[migrated,successStruct];
        else
            if~isempty(errorStruct)
                notMigrated=[notMigrated,errorStruct];

                if~isempty(renamedClassdefMFile)
                    movefile(renamedClassdefMFile,classdefMFile);
                end
                if~isempty(renamedClassdefPFile)
                    movefile(renamedClassdefPFile,classdefPFile);
                end
            end
        end

    end

    if ddOpenedHere
        ddConn.saveChanges;
        ddConn.close;
    end

end

function errorStruct=l_errorStruct(enumClassName,errorMessage)
    errorStruct=struct('className',enumClassName,'reason',errorMessage);
end

function successStruct=l_successStruct(enumClassName,renamedFiles)
    if isempty(enumClassName)

        initialRenamedFiles={};
    else

        initialRenamedFiles='';
    end
    successStruct=struct('className',enumClassName,...
    'renamedFiles',initialRenamedFiles);



    if~isempty(enumClassName)
        successStruct.renamedFiles=renamedFiles;
    end
end
