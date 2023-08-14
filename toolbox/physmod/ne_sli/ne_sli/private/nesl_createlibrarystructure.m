function obj=nesl_createlibrarystructure(pkg,depErrFlag)










    if nargin==1
        depErrFlag=false;
    end

    parseLibraryPackage=ne_private('ne_parselibrarypackage');
    libHelpers=parseLibraryPackage(pkg);
    if numel(libHelpers)==0
        obj=[];
        return;
    end

    obj=struct();
    for idx=1:numel(libHelpers)
        libHelper=libHelpers{idx};
        [srcFileDir,srcFileName,srcExt]=fileparts(libHelper.SourceFile);
        if strcmp(srcFileName,'sl_postprocess')
            fcnHandle=pm_pathtofunctionhandle(srcFileDir,srcFileName);%#ok<NASGU>
            eval(['obj.',libHelper.Path,'= fcnHandle;']);
        elseif strcmp(srcFileName,'lib')
            libObj=simscape.Library(libHelper.SourceFile);
            fcnHandle=pm_pathtofunctionhandle(srcFileDir,srcFileName);
            try
                feval(fcnHandle,libObj);




                libObj.Name=strrep(libObj.Name,'/','//');
                libObj.Annotation=strrep(libObj.Annotation,'/','//');
                if isempty(libObj.Name)
                    if~isempty(regexp(libHelper.Path,'\.lib','once'))

                        libObj.Name=strrep(libHelper.Path,'.lib','');
                    elseif~isempty(regexp(libHelper.Path,'^lib','once'))


                        pkgNameFcn=ne_private('ne_packagenamefromdirectorypath');
                        [junk,pkgNameForLib]=pkgNameFcn(libHelper.SourceFile);%#ok<ASGLU>
                        libObj.Name=pkgNameForLib;
                    end
                end

                eval(['obj.',libHelper.Path,'=libObj;']);

            catch e
                pm_warning('physmod:network_engine:ne_createlibrarystructure:IncorrectLibFile',...
                libHelper.SourceFile,e.message);
            end
        elseif strcmp(srcExt,'.sscx')
            variantsObj=simscape.Variant(libHelper.SourceFile);%#ok<NASGU>
            eval(['obj.',libHelper.Path,'=variantsObj;']);
        elseif~isempty(meta.class.fromName(libHelper.Command))&&...
            meta.class.fromName(libHelper.Command).Enumeration

        else
            [depList,missingList]=lFileDependency(libHelper.SourceFile);%#ok
            if~isempty(missingList)
                mfstr=missingList{1};
                for j=2:numel(missingList)
                    mfstr=[mfstr,newline,missingList{j}];%#ok
                end
                if depErrFlag
                    pm_error('physmod:network_engine:ne_createlibrarystructure:MissingDependencyFiles',...
                    mfstr,libHelper.SourceFile);
                else
                    pm_warning('physmod:network_engine:ne_createlibrarystructure:MissingDependencyFiles',...
                    mfstr,libHelper.SourceFile);
                end
            end
            if~libHelper.IsSSCFunction
                tmp=evalin('base',libHelper.Command);%#ok
                eval(['obj.',libHelper.Path,'=tmp;']);
            end
        end
    end

    [pkgPath,pkgName]=fileparts(pkg);
    if isempty(pkgPath)
        pkgPath=pwd;
    end
    source=pkgPath;
    name=pkgName(2:end);
    obj=lCreateMissingLibObjs(obj,name,source);

end

function obj=lCreateMissingLibObjs(obj,name,source)



    if isstruct(obj)
        fNames=fieldnames(obj);
        for idx=1:numel(fNames)
            obj.(fNames{idx})=lCreateMissingLibObjs(obj.(fNames{idx}),fNames{idx},fullfile(source,['+',name]));
        end
        if~any(strcmp(fNames,'lib'))

            lib=simscape.Library(fullfile(source,['+',name],'lib.m'));
            lib.Name=name;
            obj.lib=lib;
        end
    end

end

function[depList,missingList]=lFileDependency(fn)


    fullFileName=which(fn);
    [fpath,fname,fsuffix]=fileparts(fullFileName);
    if strcmpi(fsuffix,'.sscp')
        fullSourceFileName=fullfile(fpath,[fname,'.ssc']);


        dirResults=dir(fullSourceFileName);
        if numel(dirResults)==1
            [depList,missingList]=...
            simscape.compiler.dependency.internal.ssc_dependency_file(fullSourceFileName);
        else
            depList={};
            missingList={};
        end
    else
        if strcmpi(fsuffix,'.ssc')
            [depList,missingList]=...
            simscape.compiler.dependency.internal.ssc_dependency_file(fullFileName);
        else




            depList={};
            missingList={};
        end
    end
end




