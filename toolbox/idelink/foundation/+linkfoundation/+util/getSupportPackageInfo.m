function ret=getSupportPackageInfo(attribute,adaptorShortName)




















    persistent SupportPkgCustomInfo;
    persistent SupportPkgRootDirs;



    exportedInfoFields={'ShortName','TargetRootFolder','ExamplesRootFolder','VendorIDEInfo','XMakefileConfigFolder'};
    allowedAttributes=[{'SupportPkgName'},exportedInfoFields];

    pkgs=[];




    allSPCustomInfoFiles=which('support_package_custominfo','-all');
    for i=1:numel(allSPCustomInfoFiles)
        [pat,~,ext]=fileparts(allSPCustomInfoFiles{i});
        sep=strfind(pat,filesep);
        if isequal(pat(sep(end-2)+1:sep(end-1)-1),'supportpackages')&&...
            isequal(pat(sep(end)+1:end),'registry')&&isequal(ext,'.m')
            pkgs(end+1).RootDir=pat(1:sep(end)-1);%#ok<AGROW>
        end
    end

    if numel(pkgs)>0
        pkgRootDirs={pkgs.RootDir};
    else
        pkgRootDirs={};
    end

    if~isempty(setxor(pkgRootDirs,SupportPkgRootDirs))||~isa(SupportPkgCustomInfo,'containers.Map')




        SupportPkgCustomInfo=containers.Map('KeyType','char','ValueType','any');

        for i=1:numel(pkgs)
            registryDir=fullfile(pkgs(i).RootDir,'registry');
            customInfoFcn='support_package_custominfo';
            customInfoFile=fullfile(registryDir,[customInfoFcn,'.m']);
            if exist(customInfoFile,'file')
                oldDir=pwd;
                cd(registryDir);
                try
                    info=feval(customInfoFcn);
                catch %#ok<CTCH>
                    info=[];
                    MSLDiagnostic('ERRORHANDLER:utils:UnreadableSupportPkgInfo',customInfoFile).reportAsWarning;
                end
                cd(oldDir);

                if isfield(info,'SupportPackageType')&&strcmpi(info.SupportPackageType,'targets')&&...
                    isfield(info,'SupportPackageSubType')&&strcmpi(info.SupportPackageSubType,'idelink')

                    if all(isfield(info,[{'Name','ShortName'},exportedInfoFields]))&&ischar(info.ShortName)
                        SupportPkgCustomInfo(info.ShortName)=info;
                    else
                        MSLDiagnostic('ERRORHANDLER:utils:InvalidSupportPkgInfo',customInfoFile).reportAsWarning;
                    end
                end
            end
        end

        SupportPkgRootDirs=pkgRootDirs;
    end




    idx=find(strcmpi(attribute,allowedAttributes));
    if isempty(idx)
        DAStudio.error('ERRORHANDLER:utils:InvalidInputParameter','linkfoundation.util.getSupportPackageInfo',attribute,'attribute');
    else
        field=allowedAttributes{idx};
    end

    if exist('adaptorShortName','var')
        if~isKey(SupportPkgCustomInfo,adaptorShortName)
            DAStudio.error('ERRORHANDLER:utils:InvalidLinkExt',adaptorShortName);
        end

        ret=SupportPkgCustomInfo(adaptorShortName).(field);
    else

        ret=cellfun(@(c)c.(field),values(SupportPkgCustomInfo),'UniformOutput',false);
    end
