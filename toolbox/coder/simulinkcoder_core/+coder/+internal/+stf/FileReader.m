classdef FileReader<handle








    properties(SetAccess=private)


        FileTextBuffer char;





        Filename char;


        Name char;



        Success logical=true;





        ErrorArguments cell={};




        GenSettings;



        Options={};
    end

    properties(Access=private)
        DirectoryInfo struct;
    end

    methods(Static)
        function fileReader=getInstance(systemTargetFile)
            fileReader=coder.internal.stf.FileReader.read(systemTargetFile);
        end
        function clearCache()

            coder.internal.stf.FileReader.setGetSTFMap([]);
        end
    end

    methods



        function parseSettings(this,model)%#ok<INUSD> 



            beginTag=' BEGIN_RTW_OPTIONS';
            endTag=' END_RTW_OPTIONS';
            startPoint=strfind(this.FileTextBuffer,beginTag);
            endPoint=strfind(this.FileTextBuffer,endTag);
            rtwoptions={};

            if~isempty(startPoint)&&isempty(endPoint)

                DAStudio.error('RTW:configSet:stfTokenMissing',' END_RTW_OPTIONS');
            else
                rtwOptsStr=this.FileTextBuffer(startPoint+length(beginTag):endPoint);

                try


                    eval(rtwOptsStr);
                catch exc


                    DAStudio.error('RTW:buildProcess:errorInSystemTargetFile',...
                    this.Name,exc.message);
                end
            end

            if~exist('rtwoptions','var')
                rtwoptions={};
            end


            if~isempty(rtwoptions)&&~strcmpi(rtwoptions(1).type,'category')
                DAStudio.error('RTW:configSet:stfSettingOutOfDate');
            end


            if exist('rtwgensettings','var')
                if~isfield(rtwgensettings,'BuildDirSuffix')%#ok<NODEF>
                    DAStudio.error('RTW:makertw:buildDirSuffixUnavailable');
                end
                if~isfield(rtwgensettings,'DisableBuildDirOverride')
                    rtwgensettings.DisableBuildDirOverride='no';
                end
            else
                rtwgensettings.BuildDirSuffix='';
                rtwgensettings.DisableBuildDirOverride='no';
            end

            if~isfield(rtwgensettings,'ModelReferenceDirSuffix')
                rtwgensettings.ModelReferenceDirSuffix='';
            end



            rtwgensettings.SystemTargetFile=this.Filename;

            this.GenSettings=rtwgensettings;
            this.Options=rtwoptions;
        end
    end

    methods(Access=private)



        function this=FileReader()
        end

        function upToDate=isUpToDate(this,currentDirectoryInfo)

            upToDate=false;

            if~isempty(currentDirectoryInfo)
                upToDate=currentDirectoryInfo.datenum==this.DirectoryInfo.datenum;
            end
        end
    end

    methods(Static,Access=private)

        function reader=read(stfName)


            systemTargetFileMap=coder.internal.stf.FileReader.SystemTargetFileMap();



            stfFilename=which(stfName);





            if isempty(stfFilename)
                key=stfName;
            else
                key=stfFilename;
            end


            if systemTargetFileMap.isKey(key)
                reader=systemTargetFileMap(key);




                dirInfo=dir(reader.Filename);
                readerUpToDate=reader.isUpToDate(dirInfo);


                if readerUpToDate
                    return;
                else



                    stfFilename=reader.Filename;
                    stfName=reader.Name;
                    systemTargetFileMap.remove(reader.Filename);
                    systemTargetFileMap.remove(reader.Name);
                end
            end






            if isempty(stfFilename)
                stfFilename=coder.internal.stf.FileReader.getSystemTargetFileFromInstallRoot(stfName);
            end


            reader=coder.internal.stf.FileReader();
            reader.Name=stfName;
            reader.Filename=stfFilename;
            reader.DirectoryInfo=dir(stfFilename);

            if isempty(reader.DirectoryInfo)



                reader.Success=false;
                reader.ErrorArguments={'Simulink:utility:SystemTargetFileNotFound',stfFilename};
            else


                fileID=fopen(reader.Filename,'rt');

                if fileID==-1
                    reader.Success=false;
                    reader.ErrorArguments={'RTW:utility:fileIOError',stfFilename,'open'};
                else
                    fileText=fread(fileID);
                    fclose(fileID);

                    if isempty(fileText)
                        reader.Success=false;
                        reader.ErrorArguments={'RTW:utility:fileIOError',stfFilename,'read'};
                    else
                        reader.FileTextBuffer=native2unicode(fileText',get_param(0,'CharacterEncoding'));
                    end
                end
            end


            if reader.Success
                systemTargetFileMap(reader.Name)=reader;
                systemTargetFileMap(reader.Filename)=reader;%#ok<NASGU>
            end
        end

        function fileName=getSystemTargetFileFromInstallRoot(name)
            fileName=name;

            rtwroot=fullfile(matlabroot,'rtw','c');


            [~,targetDir]=fileparts(fileName);
            candidateSTF=fullfile(rtwroot,targetDir,fileName);

            if(exist(candidateSTF,'file')==2)
                fileName=candidateSTF;
            else

                stfs=dir(fullfile(rtwroot,'**',fileName));
                if~isempty(stfs)

                    fileName=fullfile(stfs(1).folder,stfs(1).name);
                end
            end
        end

        function map=setGetSTFMap(value)
            persistent STFMap;
            if nargin
                STFMap=value;
            end
            map=STFMap;
        end

        function map=SystemTargetFileMap()
            map=coder.internal.stf.FileReader.setGetSTFMap;
            if isempty(map)
                map=coder.internal.stf.FileReader.setGetSTFMap(containers.Map('KeyType','char','ValueType','any'));
            end
        end
    end
end



