classdef(Hidden)MarkerFile








    methods(Static)



        function create(markerFile)

            if~exist(markerFile,'file')


                rtwprivate('rtw_create_directory_path',fileparts(markerFile));

                fid=fopen(markerFile,'w');
                fileCleanup=onCleanup(@()fclose(fid));

                fprintf(fid,'%sslprjVersion: %s',...
                message('RTW:buildProcess:markerFileHeaderText').getString,...
                coder.internal.folders.MarkerFile.getCurrentVersion());
            end
        end



        function createSimulationMarker()

            cacheFolder=Simulink.fileGenControl('get','CacheFolder');
            markerFile=fullfile(cacheFolder,Simulink.filegen.CodeGenFolderStructure.ModelSpecific.MarkerFile);

            coder.internal.folders.MarkerFile.create(markerFile);
        end






        function check(markerFile,okToPushNags)

            if nargin<2
                okToPushNags=false;
            end


            markerFileVersion=coder.internal.folders.MarkerFile.getVersion(markerFile);

            if isempty(markerFileVersion)||...
                strcmp(markerFileVersion,...
                coder.internal.folders.MarkerFile.getCurrentVersion())


                return;
            end


            coder.internal.folders.MarkerFile.throwSlprjIncompatibleError(markerFile,okToPushNags);
        end

        function checkAccelFolderConfiguration(folders,okToPushNags)





            markerFile=folders.Simulation.absolutePath('MarkerFile');


            markerFileVersion=coder.internal.folders.MarkerFile.getVersion(markerFile);




            accelFolder=fullfile(fileparts(markerFile),'accel');
            if isempty(markerFileVersion)&&~isfolder(accelFolder)
                return;
            end


            if strcmp(markerFileVersion,...
                coder.internal.folders.MarkerFile.getCurrentVersion())

                return;
            end




            coder.internal.folders.MarkerFile.throwSlprjIncompatibleError(markerFile,okToPushNags);
        end



        function checkSlprjDirectory(directory,okToPushNags)

            if nargin<2
                okToPushNags=false;
            end

            markerFile=fullfile(directory,Simulink.filegen.CodeGenFolderStructure.ModelSpecific.MarkerFile);

            coder.internal.folders.MarkerFile.check(markerFile,okToPushNags);
        end






        function checkFolderConfiguration(folders,isSimulationBuild,okToPushNags)

            if nargin<3
                okToPushNags=false;
            end



            if isSimulationBuild
                coder.internal.folders.MarkerFile.check(folders.Simulation.absolutePath('MarkerFile'),okToPushNags);
            else





                markerFiles=unique({folders.CodeGeneration.absolutePath('MarkerFile'),...
                fullfile(folders.CodeGeneration.Root,Simulink.filegen.CodeGenFolderStructure.ModelSpecific.MarkerFile)});

                cellfun(@(m)coder.internal.folders.MarkerFile.check(m,okToPushNags),markerFiles);
            end
        end



        function vers=getCurrentVersion()







            verInfo=coder.internal.folders.MarkerFile.getSimulinkVersion();
            infoMatVersion=coder.internal.infoMATFileMgr('getVersionForSlprj');
            vers=[verInfo.Version,infoMatVersion];
        end



        function vers=getSimulinkVersion()


            persistent verInfo;

            if isempty(verInfo)
                verInfo=coder.make.internal.cachedVer('Simulink');
            end

            vers=verInfo;
        end




        function vers=getVersion(markerFile)
            vers='';
            if exist(markerFile,'file')
                fid=fopen(markerFile,'r');
                if fid==-1
                    DAStudio.error('RTW:utility:fileIOError',makerFile,'open');
                end
                line1=fgetl(fid);%#ok<NASGU>
                line2=fgetl(fid);
                fclose(fid);

                if isequal(line2,-1)


                    vers='1';
                else
                    versTokens=regexp(line2,'slprjVersion:\s+(\S+)','tokens');
                    vers=versTokens{1}{1};
                end
            end
        end
    end

    methods(Static,Access=private)
        function throwSlprjIncompatibleError(markerFile,okToPushNags)



            markerFileContainingFolder=fileparts(markerFile);
            [~,dirToRemoveName]=fileparts(markerFileContainingFolder);

            if okToPushNags


                errMsg=DAStudio.message('RTW:buildProcess:slprjVerIncompatible',dirToRemoveName);
                btn1=DAStudio.message('RTW:buildProcess:slprjVerDlgBtn1');
                btn2=DAStudio.message('RTW:buildProcess:slprjVerDlgBtn2');
                response=questdlg(errMsg,...
                DAStudio.message('RTW:buildProcess:slprjVerDlgTitle'),...
                btn1,btn2,btn1);
                if isempty(response)||strcmp(response,btn2)
                    DAStudio.error('RTW:buildProcess:codeGenAborted',errMsg);

                elseif strcmp(response,btn1)
                    [s,w]=rmdir(markerFileContainingFolder,'s');
                    if~s
                        DAStudio.error('RTW:utility:removeError',w);
                    end


                    delete(['*',coder.internal.modelRefUtil([],'getBinExt',true),'.',mexext]);
                    delete(['*',coder.internal.modelRefUtil([],'getBinExt',false),'.',mexext]);
                end
            else
                DAStudio.error('RTW:buildProcess:slprjVerIncompatibleCmdLine',dirToRemoveName);
            end
        end
    end
end


