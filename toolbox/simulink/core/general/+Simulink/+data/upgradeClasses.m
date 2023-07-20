function upgradeClasses(outputDirectory)




    if nargin==0
        outputDirectory=tempname(cd);
    else
        [~,dirName,ext]=fileparts(outputDirectory);
        if(isempty(outputDirectory)||~isempty(ext)||...
            ~isequal(outputDirectory,strtrim(outputDirectory))||...
            (dirName(1)=='@')||...
            (dirName(1)=='+'))
            DAStudio.error('Simulink:dialog:InputArgumentMustBeDirectoryName');
        end
    end

    if local_IsRelativePath(outputDirectory)
        outputDirectory=fullfile([cd,filesep,outputDirectory]);
    end


    userUDDPackageList=slprivate('find_valid_packages','FindOldUserPkgs');
    userMCOSPackageList=slprivate('find_valid_packages','FindNewUserPkgs');

    if isempty(userUDDPackageList)
        msgbox(DAStudio.message('Simulink:dialog:NoOldClasses'));
        return;
    end


    oldPackagesToUpgrade=setdiff(userUDDPackageList,userMCOSPackageList);
    if isempty(oldPackagesToUpgrade)
        msgbox(DAStudio.message('Simulink:dialog:NoOldClassesToMigrate'));
        return;
    end


    writeOutMCOSVersionOfOldClasses(oldPackagesToUpgrade,outputDirectory);



    function writeOutMCOSVersionOfOldClasses(oldPackages,outputDirectory)


        h=waitbar(0,'','Name',DAStudio.message('Simulink:dialog:DCDPleaseWait'));
        waitbarCleanup=onCleanup(@()local_CloseWaitbar(h));


        outputDirectoryExistedBefore=exist(outputDirectory,'dir');
        packageWritten=false;


        origPath=path;

        try

            for idx=1:length(oldPackages)
                packageName=oldPackages{idx};


                local_AdvanceWaitbar(h,idx/length(oldPackages),packageName);


                uddPathDefFile=which(['@',packageName,filesep,'packagedefn.mat']);
                if isempty(which(uddPathDefFile))
                    loc_reportWarning('Simulink:dialog:NoPackageDefinitionFile',packageName);
                    continue;
                end
                uddPackageDir=fileparts(uddPathDefFile);


                packageInfo=load(uddPathDefFile);
                if~isfield(packageInfo,'hThisPackageDefn')
                    loc_reportWarning('Simulink:dialog:InvalidPackageDefinitionFile',packageName);
                    continue;
                end
                packageDefn=packageInfo.hThisPackageDefn;
                clear packageInfo;

                if~isequal(packageName,packageDefn.PackageName)
                    loc_reportWarning('Simulink:dialog:InconsistentPackageName',...
                    packageName,packageDefn.PackageName);
                    continue;
                end

                if~strcmp(packageDefn.CSCHandlingMode,'v2 - CSC Registration File')

                    loc_reportWarning('Simulink:dialog:CannotMigrateR13CustomStorageClasses',...
                    packageDefn.PackageName);
                    continue;
                end



                mfilesInUDDPackage=dir([uddPackageDir,filesep,'*.m']);
                if(isempty(mfilesInUDDPackage)||...
                    ((length(mfilesInUDDPackage)==1)&&...
                    (strcmp(mfilesInUDDPackage.name,'csc_registration.m'))))

                    classDirs=dir([uddPackageDir,filesep,'@*']);
                    for dirIdx=1:length(classDirs)
                        classDir=[uddPackageDir,filesep,classDirs(dirIdx).name];
                        mfilesInUDDPackage=dir([classDir,filesep,'*.m']);
                        if~isempty(mfilesInUDDPackage)

                            break;
                        end
                    end
                end

                if~isempty(mfilesInUDDPackage)
                    loc_reportWarning('Simulink:dialog:Level1PackageFilesNotPCoded',packageName);
                end


                mcosPackageDir=[outputDirectory,filesep,'+',packageName];
                if exist(mcosPackageDir,'dir')
                    DAStudio.error('Simulink:dialog:MCOSPackageFolderAlreadyExists',mcosPackageDir,packageName);
                else
                    try
                        local_mkdir(mcosPackageDir);
                    catch errs
                        DAStudio.error('Simulink:dialog:UnableToCreateFolderToStoreMCOSClasses',mcosPackageDir,errs.message);
                    end
                end


                packageDefn.OrigPackageDir=uddPackageDir;
                packageDefn.PackageDir=mcosPackageDir;


                enumLists=createEnumLists(packageDefn);

                for j=1:length(packageDefn.Classes)
                    classDefn=packageDefn.Classes(j);


                    writeOutMCOSClass(packageDefn,classDefn,enumLists);
                end


                srcCSCFile=[uddPackageDir,filesep,'csc_registration.m'];
                dstCSCFile=[mcosPackageDir,filesep,'csc_registration.m'];
                if exist(srcCSCFile,'file')
                    fileWritten=local_CopyFileIfNeeded(srcCSCFile,dstCSCFile);
                    if~fileWritten
                        DAStudio.error('Simulink:dialog:UnableToCopyFile',packageName,...
                        srcCSCFile);
                    end
                end


                srcTLCDir=[uddPackageDir,filesep,'tlc',filesep];
                dstTLCDir=[mcosPackageDir,filesep,'tlc',filesep];
                if exist(srcTLCDir,'dir')
                    tlcFiles=dir([srcTLCDir,'*.tlc']);
                    for tlcIdx=1:length(tlcFiles)
                        fileWritten=local_CopyFileIfNeeded([srcTLCDir,tlcFiles(tlcIdx).name],...
                        [dstTLCDir,tlcFiles(tlcIdx).name]);
                        if~fileWritten
                            DAStudio.error('Simulink:dialog:UnableToCopyFile',packageName,...
                            [dstTLCDir,tlcFiles(tlcIdx).name]);
                        end
                    end
                end

                packageWritten=true;
                clear packageDefn
            end

            if packageWritten
                if(outputDirectoryExistedBefore)
                    messages=DAStudio.message('Simulink:dialog:MCOSDirAlreadyExists',outputDirectory);
                else
                    messages=DAStudio.message('Simulink:dialog:WarnAboutFolderToStoreMCOSClasses',outputDirectory);
                end


                if isempty(regexp(path,outputDirectory))%#ok
                    addpath(outputDirectory);
                    savepath;
                    newMessage=DAStudio.message('Simulink:dialog:WarnAboutAddingMCOSClassesToPath',...
                    outputDirectory);
                    messages=local_AddMessage(messages,newMessage);
                end


                warndlg(messages,DAStudio.message('Simulink:dialog:DCDWarnDialogName'));
            else
                msgbox(DAStudio.message('Simulink:dialog:NoOldClassesToMigrate'));
            end

        catch errs

            path(origPath);
            rethrow(errs);
        end


        function enumLists=createEnumLists(packageDefn)

            enumLists=struct;

            for i=1:length(packageDefn.EnumTypes)
                enumType=packageDefn.EnumTypes(i);

                outputString='{';

                for j=1:length(enumType.EnumStrings)
                    enumString=enumType.EnumStrings{j};
                    outputString=[outputString,'''',enumString,'''; '];%#ok
                end
                if~isempty(enumType.EnumStrings)

                    outputString(end-1:end)='';
                end
                outputString=[outputString,'}'];%#ok

                enumLists.(enumType.EnumTypeName)=outputString;
            end


            function isEnum=local_IsEnumType(propType,enumLists)
                isEnum=ismember(propType,fieldnames(enumLists));


                function writeOutMCOSClass(packageDefn,classDefn,enumLists)


                    packageName=packageDefn.PackageName;
                    className=classDefn.ClassName;


                    if isempty(classDefn.DeriveFromPackage)
                        assert(isempty(classDefn.DeriveFromClass));
                        outputString=['classdef ',className,' < handle\n'];
                    else
                        assert(~isempty(classDefn.DeriveFromClass));
                        deriveFromClass=[classDefn.DeriveFromPackage,'.',classDefn.DeriveFromClass];
                        outputString=['classdef ',className,' < ',deriveFromClass,'\n'];
                    end
                    outputString=[outputString,'%',packageName,'.',className,'  Class definition.\n\n'];


                    outputString=addLocalProperties(outputString,packageDefn,classDefn,enumLists);


                    methodsString='';
                    if classDefn.UseCSCRegFile
                        methodsString=addSetupCoderInfo(methodsString,packageDefn);
                    end


                    methodsString=addConstructorMethod(methodsString,classDefn);


                    if~isempty(methodsString)
                        outputString=[outputString,...
                        '  methods\n',...
                        methodsString,...
                        '  end % methods\n'];
                    end


                    outputString=[outputString,'end % classdef\n'];


                    outputString=sprintf(strrep(outputString,'%','%%'));


                    origDir=cd;
                    cleanup=onCleanup(@()cd(origDir));
                    outputDir=fileparts(packageDefn.PackageDir);
                    cd(outputDir);


                    classDir=[packageDefn.PackageDir,filesep,'@',classDefn.ClassName];
                    classFileName=[classDir,filesep,classDefn.ClassName,'.m'];
                    if~exist(classDir,'dir')
                        local_mkdir(classDir);
                    end


                    fid=fopen(classFileName,'w');
                    if fid==-1
                        DAStudio.error('Simulink:dialog:DCDUnableToOpenFileForWrite',classFileName);
                    end


                    fwrite(fid,outputString);
                    fclose(fid);


                    function outputString=addLocalProperties(outputString,packageDefn,classDefn,enumLists)

                        if~isempty(classDefn.LocalProperties)
                            setPropertyTypes=local_CheckIfSuperClassSupportsPropertyTypes(packageDefn,classDefn);
                            if~setPropertyTypes
                                outputString=[outputString,...
                                '  % NOTE:\n',...
                                '  % This class was originally defined in the Simulink data class designer\n',...
                                '  % but it is not a subclass of a Simulink data class.  As a result, the\n',...
                                '  % upgraded class cannot support the specification of property types.\n\n'];
                            end


                            prevPropType='no previous type';
                            for i=1:length(classDefn.LocalProperties)
                                propDefn=classDefn.LocalProperties(i);
                                propName=propDefn.PropertyName;
                                propType=propDefn.PropertyType;
                                mcosPropType=local_TranslatePropType(propType,enumLists);
                                factoryValue=local_TranslateFactoryValue(propDefn.FactoryValue,propType,packageDefn);

                                if~isequal(propType,prevPropType)

                                    if(i>1)
                                        outputString=[outputString,'  end\n\n'];%#ok
                                    end


                                    if setPropertyTypes
                                        outputString=[outputString,'  properties'];%#ok
                                    else

                                        outputString=[outputString,'  % Property type from data class designer: ''',propType,'''\n'];%#ok
                                        outputString=[outputString,'  properties'];%#ok
                                        if~isempty(mcosPropType)
                                            outputString=[outputString,' %'];%#ok
                                        end
                                    end

                                    if isempty(mcosPropType)
                                        outputString=[outputString,'\n'];%#ok
                                    elseif isequal(propType,'on/off')

                                        assert(isequal(mcosPropType,'char'));
                                        outputString=[outputString,...
                                        ' (PropertyType = ''char'', AllowedValues = {''on''; ''off''})\n'];%#ok
                                    elseif local_IsEnumType(propType,enumLists)

                                        assert(isequal(mcosPropType,'char'));
                                        outputString=[outputString,...
                                        ' (PropertyType  = ''char'', ...\n            '];%#ok
                                        if~setPropertyTypes
                                            outputString=[outputString,' %'];%#ok
                                        end

                                        outputString=[outputString,...
                                        '  AllowedValues = ',enumLists.(propType),')\n'];%#ok
                                    else

                                        outputString=[outputString,...
                                        ' (PropertyType = ''',mcosPropType,''')\n'];%#ok
                                    end
                                end


                                outputString=[outputString,...
                                '    ',propName,' = ',factoryValue,';\n'];%#ok

                                prevPropType=propType;
                            end


                            outputString=[outputString,'  end\n\n'];
                        end


                        function outputString=addConstructorMethod(outputString,classDefn)
                            className=classDefn.ClassName;
                            defaultClassInitStr='% ENTER CLASS INITIALIZATION CODE HERE (optional) ...';


                            classInitStr=classDefn.Initialization;
                            if isequal(classInitStr,defaultClassInitStr)
                                classInitStr='';
                            end

                            if~isempty(classInitStr)

                                outputString=[outputString,...
                                '    %---------------------------------------------------------------------------\n',...
                                '    function h = ',className,'(varargin)\n'];
                            elseif(classDefn.UseCSCRegFile)

                                outputString=[outputString,...
                                '    %---------------------------------------------------------------------------\n',...
                                '    function h = ',className,'()\n'];
                            else

                                return;
                            end


                            if~isempty(classInitStr)
                                classInitStr=strrep(classInitStr,sprintf('\n'),[sprintf('\n'),'      ']);
                                outputString=[outputString,'      ',classInitStr,'\n'];
                            end

                            outputString=[outputString,'    end\n\n'];


                            function outputString=addSetupCoderInfo(outputString,packageDefn)
                                packageName=packageDefn.PackageName;


                                outputString=[outputString,...
                                '    function setupCoderInfo(h)\n',...
                                '      % Use custom storage classes from this package\n',...
                                '      useLocalCustomStorageClasses(h, ''',packageName,''');\n',...
                                '    end\n\n'];


                                function propType=local_TranslatePropType(propType,enumLists)

                                    switch propType
                                    case{'MATLAB array';'mxArray';'handle'}
                                        propType='';
                                    case 'double'
                                        propType='double scalar';
                                    case 'int32'
                                        propType='int32 scalar';
                                    case 'bool'
                                        propType='logical scalar';
                                    case{'string';'on/off'}
                                        propType='char';
                                    otherwise
                                        if local_IsEnumType(propType,enumLists)
                                            propType='char';
                                        else
                                            assert(false,'Unexpected property type');
                                        end
                                    end


                                    function factoryValue=local_TranslateFactoryValue(factoryValue,propType,packageDefn)

                                        if isempty(factoryValue)
                                            switch propType
                                            case{'MATLAB array','handle'}
                                                factoryValue='[]';
                                            case 'double'
                                                factoryValue='0';
                                            case 'int32'
                                                factoryValue='int32(0)';
                                            case 'bool'
                                                factoryValue='false';
                                            case 'on/off'
                                                factoryValue='''off''';
                                            case 'string'
                                                factoryValue='''''';
                                            otherwise
                                                enumTypes=packageDefn.EnumTypes;
                                                assert(~isempty(enumTypes)&&~isempty(find(enumTypes,'EnumTypeName',propType)));

                                                thisEnumType=find(enumTypes,'EnumTypeName',propType);
                                                factoryValue=['''',thisEnumType.EnumStrings{1},''''];
                                            end

                                        else



                                            switch propType
                                            case 'int32'
                                                factoryValue=['int32(',factoryValue,')'];
                                            end
                                        end


                                        function retVal=local_CheckIfSuperClassSupportsPropertyTypes(packageDefn,classDefn)

                                            retVal=false;

                                            fullClassName=[packageDefn.PackageName,'.',classDefn.ClassName];
                                            superPackageName=classDefn.DeriveFromPackage;
                                            superClassName=classDefn.DeriveFromClass;


                                            if(isempty(superPackageName)||isempty(superClassName))
                                                loc_reportWarning('Simulink:dialog:UpgradeClassWithoutSuperclass',...
                                                fullClassName);
                                                return;
                                            end


                                            hSuperPackage=meta.package.fromName(superPackageName);
                                            if isempty(hSuperPackage)
                                                loc_reportWarning('Simulink:dialog:UpgradeClassCannotFindSuperclassPackage',...
                                                fullClassName,superPackageName);
                                                return;
                                            end

                                            hSuperClass=Simulink.data.findClass(hSuperPackage,superClassName);
                                            if isempty(hSuperClass)
                                                loc_reportWarning('Simulink:dialog:UpgradeClassCannotFindSuperclass',...
                                                fullClassName,[superPackageName,'.',superClassName]);
                                                return;
                                            end


                                            if isobject(hSuperClass)

                                                retVal=(hSuperClass<meta.class.fromName('Simulink.data.HasPropertyType'));
                                            else
                                                retVal=(hSuperClass.isDerivedFrom('Simulink.Signal')||...
                                                hSuperClass.isDerivedFrom('Simulink.Parameter')||...
                                                hSuperClass.isDerivedFrom('Simulink.CustomStorageClassAttributes'));
                                            end

                                            if~retVal
                                                loc_reportWarning('Simulink:dialog:SuperclassDoesNotSupportPropertyTypes',...
                                                fullClassName);
                                            end


                                            function local_mkdir(thisDirPath)
                                                [parentDir,subDir]=fileparts(thisDirPath);

                                                if((~exist(parentDir,'dir'))&&...
                                                    (~isempty(parentDir)))
                                                    local_mkdir(parentDir)
                                                end

                                                mkdir(parentDir,subDir);


                                                function isRelPath=local_IsRelativePath(fullDirPath)

                                                    parentDir=fileparts(fullDirPath);

                                                    if isempty(parentDir)
                                                        isRelPath=true;
                                                    elseif strcmp(parentDir,fullDirPath)
                                                        isRelPath=false;
                                                    else
                                                        isRelPath=local_IsRelativePath(parentDir);
                                                    end


                                                    function rc=local_CopyFileIfNeeded(srcFile,dstFile)

                                                        rc=false;


                                                        dstDir=fileparts(dstFile);
                                                        if~exist(dstDir,'dir')
                                                            local_mkdir(dstDir);
                                                        end


                                                        if~exist(dstFile,'file')
                                                            [rc,message,messageid]=copyfile(srcFile,dstFile);
                                                            if(0==rc)
                                                                error(messageid,message);
                                                            else

                                                                [rc,message,messageid]=fileattrib(dstFile,'+w');
                                                                if(0==rc)
                                                                    error(messageid,message);
                                                                end
                                                            end
                                                        else
                                                            loc_reportWarning('Simulink:dialog:DCDUnableToOverwriteFile',dstFile);
                                                        end


                                                        function messages=local_AddMessage(messages,newMessage)

                                                            if isempty(messages)
                                                                messages=newMessage;
                                                                return;
                                                            elseif isempty(newMessage)
                                                                return;
                                                            end


                                                            messages=[messages,sprintf('\n\n'),newMessage];


                                                            function local_AdvanceWaitbar(h,value,packageName)

                                                                try
                                                                    waitbar(value,h,DAStudio.message('Simulink:dialog:DCDWritingPkg',packageName));
                                                                catch

                                                                end


                                                                function local_CloseWaitbar(h)

                                                                    try
                                                                        close(h);
                                                                    catch

                                                                    end

                                                                    function loc_reportWarning(warnId,varargin)
                                                                        MSLDiagnostic([],message(warnId,varargin{:})).reportAsWarning;




