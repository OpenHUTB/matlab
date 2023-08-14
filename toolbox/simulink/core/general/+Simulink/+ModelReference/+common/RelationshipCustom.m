



classdef RelationshipCustom<Simulink.ModelReference.common.Relationship
    properties
        TempDirName='';
        customFileRec;
        obfuscateCode=true;
    end
    methods


        function obj=RelationshipCustom(protectedModelCreator,customFileRec,obfuscate)

            obj@Simulink.ModelReference.common.Relationship;

            custom=Simulink.ModelReference.common.constructTargetRelationshipName('custom',protectedModelCreator.Target);
            obj.DirName='codegen';
            obj.RelationshipName=custom;
            obj.customFileRec=customFileRec;
            obj.obfuscateCode=obfuscate;
        end


        function populate(obj,~)

            obj.checkSourceFiles(obj.customFileRec);


            if obj.obfuscateCode
                obj.customFileRec=obj.protectFiles(obj.customFileRec);
            end


            obj.addSourceFilesAsPartsToPackage(obj.customFileRec);
        end

        function checkSourceFiles(~,customFileRec)
            for i=1:length(customFileRec)
                currentFile=customFileRec(i).sourceFile;


                if isfolder(currentFile)
                    DAStudio.error('Simulink:protectedModel:DirectorySpecifiedInsteadOfFile',currentFile);
                end

                if exist(currentFile,'file')==0
                    DAStudio.error('Simulink:protectedModel:FileDoesNotExist',currentFile);
                end
            end

        end



        function srcFiles=protectFiles(obj,customFileRec)

            pFiles={};
            cFiles={};
            otherFiles={};


            for it=1:length(customFileRec)
                currentRec=customFileRec(it);
                [~,~,fext]=fileparts(currentRec.sourceFile);
                if strcmp(fext,'.m')

                    pFiles{end+1}=currentRec;%#ok<AGROW>
                elseif strcmp(fext,'.c')||strcmp(fext,'.h')

                    cFiles{end+1}=currentRec;%#ok<AGROW>
                else

                    otherFiles{end+1}=currentRec;%#ok<AGROW>
                end
            end

            srcFiles=struct('sourceFile',{},'destinationPath',{});

            for it=1:length(pFiles)
                srcFiles(end+1)=obj.protectMATLABFile(pFiles{it});%#ok<AGROW>
            end


            srcFiles=obj.protectCFiles(cFiles,srcFiles);


            for it=1:length(otherFiles)
                srcFiles(end+1)=otherFiles{it};%#ok<AGROW>
            end
        end




        function out=protectCFiles(obj,fileRecs,protectedRecs)
            if~isempty(fileRecs)

                obj.TempDirName=tempname;
                currentDir=pwd;
                mkdir(obj.TempDirName);
                oc=onCleanup(@()cd(currentDir));
                cd(obj.TempDirName);


                for i=1:length(fileRecs)
                    currentFile=fileRecs{i}.sourceFile;
                    copyfile(currentFile,obj.TempDirName,'f');
                end


                destDir=fullfile(obj.TempDirName,'ofc');
                mkdir(destDir);
                obfuscate('.',destDir,'',1,true);


                ofcFiles=struct('sourceFile',{},'destinationPath',{});
                for i=1:length(fileRecs)
                    currentFile=fileRecs{i}.sourceFile;
                    [~,fname,fext]=fileparts(currentFile);
                    srcF=fullfile(destDir,[fname,'_ofc',fext]);
                    destF=fullfile(destDir,[fname,fext]);
                    copyfile(srcF,destF);
                    ofcFiles(end+1).sourceFile=destF;%#ok<AGROW>
                    ofcFiles(end).destinationPath=fileRecs{i}.destinationPath;
                end


                out=[protectedRecs,ofcFiles];
            else
                out=protectedRecs;
            end

        end


        function removeDirectory(obj)
            if~isempty(obj.TempDirName)
                sl('removeDir',obj.TempDirName);
                obj.TempDirName='';
            end
        end


        function out=protectMATLABFile(~,fileRec)
            pcode(fileRec.sourceFile,'-inplace');
            [fpath,fname,~]=fileparts(fileRec.sourceFile);
            out.sourceFile=fullfile(fpath,[fname,'.p']);
            out.destinationPath=fileRec.destinationPath;
        end

        function delete(obj)
            obj.removeDirectory();
        end

        function addSourceFilesAsPartsToPackage(obj,customFileRec)
            for i=1:length(customFileRec)
                currentFileRec=customFileRec(i);






                if~isempty(strfind(currentFileRec.destinationPath,'..'))
                    DAStudio.error('Simulink:protectedModel:ProtectedMdlCustomRelNoRelativePaths',currentFileRec.destinationPath);
                end


                if ispc
                    correctedDestinationPath=strrep(currentFileRec.destinationPath,filesep,'/');
                else
                    correctedDestinationPath=currentFileRec.destinationPath;
                end


                obj.addPartUsingFilePattern(currentFileRec.sourceFile,correctedDestinationPath);
            end
        end
    end
    methods(Static)
        function out=getEncryptionCategory()
            out='RTW';
        end


        function out=getRelationshipYear()
            out='2012';
        end

    end
end



