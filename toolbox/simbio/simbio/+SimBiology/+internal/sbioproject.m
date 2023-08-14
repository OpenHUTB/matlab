classdef sbioproject<handle




    properties
        filenameMap;
        outputDir;

        version=NaN;
    end

    methods
        function obj=sbioproject(projfilename,varargin)

            validateattributes(projfilename,{'char','string'},{'scalartext'},mfilename,'PROJFILENAME');
            projfilename=char(projfilename);

            obj.filenameMap=containers.Map;















            [locpath,~,projFilenameExt]=fileparts(projfilename);
            if isempty(projFilenameExt)
                if~exist(projfilename,'file')
                    projfilename=[projfilename,'.sbproj'];
                end
            end
            if isempty(locpath)
                projfilename=[pwd,filesep,projfilename];
            end

            if nargin==1
                useDesktopTempdir=false;
            else
                useDesktopTempdir=varargin{1};
            end

            if useDesktopTempdir
                obj.outputDir=SimBiology.web.internal.desktopTempname();
            else
                tempDir=sbiogate('sbiotempdir');
                obj.outputDir=tempname(tempDir);
            end


            if~exist(obj.outputDir,'dir')
                mkdir(obj.outputDir);
            end


            filenames=unzip(projfilename,obj.outputDir);


            for i=1:numel(filenames)


                fullfilename=filenames{i};
                [~,name,ext]=fileparts(filenames{i});
                obj.filenameMap([name,ext])=fullfilename;
            end
        end

        function delete(obj)
            if~isempty(obj.outputDir)


                recycle_status=recycle;
                recycle off;

                SimBiology.internal.sbioproject.cleanupDirectory(obj.outputDir);


                recycle(recycle_status);
            end
        end

        function fullFilenames=loadFiles(obj,filenames)

            if~iscell(filenames)
                filenames={filenames};
            end


            fullFilenames=cell(size(filenames));
            for i=1:numel(filenames)
                filename=filenames{i};
                [~,~,ext]=fileparts(filename);
                newFilename=[SimBiology.web.internal.desktopTempname(),ext];
                while any(strcmp(fullFilenames,newFilename))
                    newFilename=[SimBiology.web.internal.desktopTempname(),ext];
                end
                fullFilenames{i}=newFilename;
            end


            fullFilenames=copyFiles(obj,filenames,fullFilenames);

        end

        function targetFilenames=loadFilesIntoTargetLocations(obj,filenames,targetFilenames)

            if~iscell(filenames)
                filenames={filenames};
            end
            if~iscell(targetFilenames)
                targetFilenames={targetFilenames};
            end
            if numel(filenames)~=numel(targetFilenames)
                error('Must specify a target filename for each file to load/copy from the project.');
            end


            targetFilenames=copyFiles(obj,filenames,targetFilenames);
        end

        function[fullFilenames,varargout]=loadFilesMatchingRegexp(obj,str)
            keys=obj.filenameMap.keys;
            idx=cellfun(@(x)~isempty(regexp(x,str,'match')),keys);
            filenames=keys(idx);
            fullFilenames=obj.loadFiles(filenames);




            if nargout==2
                varargout{1}=filenames;
            end
        end

        function version=getProjectVersion(obj)
            if isnan(obj.version)
                newName=obj.loadFilesMatchingRegexp('modelLookup.mat');

                if isempty(newName)
                    obj.version=[];
                else

                    obj.version=1;


                    try
                        projectJSON=obj.loadFilesMatchingRegexp('projectVersion.json');
                        if~isempty(projectJSON)
                            jsonObj=jsondecode(fileread(projectJSON{1}));
                            obj.version=jsonObj.currentVersion;
                        end
                    catch ex


                        obj.version=[];
                    end
                end
            end
            version=obj.version;
        end

        function releaseVersion=getReleaseVersion(obj)
            version=obj.getProjectVersion;
            releaseVersion=obj.mapVersionToRelease(version);
        end
    end

    methods(Access=private)

        function targetFilenames=copyFiles(obj,filenames,targetFilenames)









            for i=1:numel(filenames)
                filename=filenames{i};
                if obj.filenameMap.isKey(filename)
                    originalFilename=obj.filenameMap(filename);

                    copyfile(originalFilename,targetFilenames{i},'f');
                else


                    targetFilenames{i}='';
                end
            end
        end
    end

    methods(Static=true,Access=private)

        function cleanupDirectory(dirname)
            dirInfo=dir(dirname);


            subdirInfo=dirInfo([dirInfo.isdir]);
            for i=1:numel(subdirInfo)
                info=subdirInfo(i);

                if~strcmp(info.name,'.')&&~strcmp(info.name,'..')
                    SimBiology.internal.sbioproject.cleanupDirectory([info.folder,filesep,info.name]);
                end
            end


            delete([dirname,filesep,'*']);


            rmdir(dirname,'s');
        end

        function release=mapVersionToRelease(version)


            projectVersionFile=fullfile(matlabroot,'toolbox','simbio','simbio','+SimBiology','+web','+templates','projectVersion.json');
            jsonObj=jsondecode(fileread(projectVersionFile));
            versionHistory=jsonObj.versionHistory;

            release='';
            for i=1:numel(versionHistory)
                if version==versionHistory(i).version
                    release=versionHistory(i).release;
                    return;
                end
            end
        end
    end
end

