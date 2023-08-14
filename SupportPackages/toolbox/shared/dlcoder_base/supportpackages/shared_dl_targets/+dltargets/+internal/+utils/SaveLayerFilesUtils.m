classdef SaveLayerFilesUtils<handle






    methods(Static)

        function fullpath=getFileFullPath(file,codegendir,codegentarget)
            if strcmpi(codegentarget,'mex')

                fullpath=file;
                return;
            else

                [~,file,ext]=fileparts(file);
                file=[file,ext];
            end
            fullpath=fullfile(codegendir,file);
        end

        function saveOneFile(codegendir,codegentarget,prec,filename,data)

            filename=dltargets.internal.utils.SaveLayerFilesUtils.getFileFullPath(filename,codegendir,codegentarget);
            dltargets.internal.utils.SaveLayerFilesUtils.checkForWindowsLongPath(filename);
            [fileID,fopenError]=fopen(filename,'w');

            if(fileID==-1)
                error(message('dlcoder_spkg:cnncodegen:FopenError',filename,fopenError));
            end
            count=fwrite(fileID,data,prec);
            if(count==0)&&~isempty(data)
                error(message('dlcoder_spkg:cnncodegen:FailedToWriteParameters'));
            end
            fclose(fileID);
        end

        function checkForWindowsLongPath(filename)


            if(ispc&&length(filename)>=260)
                error(message('dlcoder_spkg:cnncodegen:LongWindowsPath',filename));
            end
        end

        function writeStringValues(fileID,stringVal)
            len=numel(stringVal);

            fwrite(fileID,len,'uint32');

            fwrite(fileID,stringVal,'char*1');
        end

        function stringVal=readStringValues(fileID)

            [len,count]=fread(fileID,1,'uint32');
            assert(count==1,message('dlcoder_spkg:postCodegenUpdate:IncorrectCharactersRead'));


            [stringVal,count]=fread(fileID,len,'*char');
            assert(count==len,message('dlcoder_spkg:postCodegenUpdate:IncorrectCharactersRead'));

            stringVal=convertCharsToStrings(stringVal);
        end

    end

end
