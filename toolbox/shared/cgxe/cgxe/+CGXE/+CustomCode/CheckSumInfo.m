

classdef CheckSumInfo

    properties
PreprocessorOpts
        SrcFileName=''
SrcFileDate
SrcFileBytes
HeaderFilesPaths
HeaderFilesDates
HeaderFilesBytes
Checksum
    end

    methods



        function obj=CheckSumInfo(srcFile,isFile,feOpts,srcRawToken)

            useSrcRawToken=isFile&&nargin>3&&~isempty(srcRawToken);


            feOpts.PreprocOutput=[tempname(),'.i'];
            clr=onCleanup(@()deleteFile(feOpts.PreprocOutput));


            feOpts.ErrorOutput=[tempname(),'.err'];
            clr2=onCleanup(@()deleteFile(feOpts.ErrorOutput));


            if isFile
                checkForUnsupportedExtensions(srcFile);
                msgs=internal.cxxfe.FrontEnd.parseFile(srcFile,feOpts);
            else
                msgs=internal.cxxfe.FrontEnd.parseText(srcFile,feOpts);
            end

            isOK=false;
            if isfile(feOpts.PreprocOutput)
                [chkSum,isOK]=CGXE.CustomCode.CheckSumInfo.computeTextCheckSum(feOpts.PreprocOutput,true);
            end

            if~isOK

                chkSum=CGXE.Utils.md5(msgs);
            end




            if useSrcRawToken
                chkSum=CGXE.Utils.md5(chkSum,srcRawToken);
            else



                if ispc
                    srcFileForChk=lower(srcFile);
                else
                    srcFileForChk=srcFile;
                end
                chkSum=CGXE.Utils.md5(chkSum,srcFileForChk);
            end



            hFilesPaths=cell(1,100);
            idx=1;
            fid=fopen(feOpts.ErrorOutput,'rb');
            if fid>=0
                while true
                    tline=fgetl(fid);
                    if~ischar(tline)
                        break
                    end
                    if idx>=numel(hFilesPaths)
                        hFilesPaths{idx*2}=[];
                    end
                    hFilesPaths{idx}=strtrim(tline);
                    idx=idx+1;
                end
                fclose(fid);
            end
            hFilesPaths(idx:end)=[];


            hFilesPaths=unique(hFilesPaths);

            hFilesDates=zeros(size(hFilesPaths));
            hFilesBytes=zeros(size(hFilesPaths));
            badIdx=false(size(hFilesPaths));

            for ii=1:numel(hFilesPaths)
                st=dir(hFilesPaths{ii});
                if isempty(st)

                    badIdx(ii)=true;
                    continue
                end

                for jj=1:numel(feOpts.Preprocessor.SystemIncludeDirs)
                    if strncmp([feOpts.Preprocessor.SystemIncludeDirs{jj},filesep],...
                        hFilesPaths{ii},...
                        numel(feOpts.Preprocessor.SystemIncludeDirs{jj})+1)
                        badIdx(ii)=true;
                    end
                end

                hFilesDates(ii)=st.datenum;
                hFilesBytes(ii)=st.bytes;
            end
            hFilesPaths(badIdx)=[];
            hFilesDates(badIdx)=[];
            hFilesBytes(badIdx)=[];



            if isFile&&isfile(srcFile)

                obj.SrcFileName=srcFile;
                st=dir(srcFile);
                obj.SrcFileDate=st.datenum;
                obj.SrcFileBytes=st.bytes;
            end
            obj.PreprocessorOpts=internal.cxxfe.util.OptionsHelper.toStruct(feOpts.Preprocessor);
            obj.HeaderFilesPaths=hFilesPaths;
            obj.HeaderFilesDates=hFilesDates;
            obj.HeaderFilesBytes=hFilesBytes;






            hFiles=cell(size(hFilesPaths));
            for i=1:numel(hFilesPaths)
                [~,hFileName,hExt]=fileparts(hFilesPaths{i});
                hFiles{i}=[hFileName,hExt];
            end



            hFiles=sort(hFiles);
            chkSum=CGXE.Utils.md5(chkSum,hFiles);

            obj.Checksum=chkSum;
        end


        function upToDate=isUpToDate(obj,isFile,feOpts)
            upToDate=false;

            srcFileDate=[];
            srcFileBytes=[];
            if isFile&&~isempty(obj.SrcFileName)&&isfile(obj.SrcFileName)
                st=dir(obj.SrcFileName);
                srcFileDate=st.datenum;
                srcFileBytes=st.bytes;
            end


            if isequal(obj.SrcFileDate,srcFileDate)&&...
                isequal(obj.SrcFileBytes,srcFileBytes)&&...
                isequal(feOpts.Preprocessor.IncludeDirs,obj.PreprocessorOpts.IncludeDirs)&&...
                isequal(feOpts.Preprocessor.Defines,obj.PreprocessorOpts.Defines)&&...
                isequal(feOpts.Preprocessor.UnDefines,obj.PreprocessorOpts.UnDefines)&&...
                isequal(feOpts.Preprocessor.PreIncludes,obj.PreprocessorOpts.PreIncludes)&&...
                isequal(feOpts.Preprocessor.PreIncludeMacros,obj.PreprocessorOpts.PreIncludeMacros)&&...
                isequal(feOpts.Preprocessor.IgnoredMacros,obj.PreprocessorOpts.IgnoredMacros)

                upToDate=true;


                for ii=1:numel(obj.HeaderFilesPaths)
                    st=dir(obj.HeaderFilesPaths{ii});
                    if isempty(st)
                        upToDate=false;
                        return
                    end
                    if(obj.HeaderFilesDates(ii)~=st.datenum)||...
                        (obj.HeaderFilesBytes(ii)~=st.bytes)
                        upToDate=false;
                        return
                    end
                end
            end
        end
    end

    methods(Static=true)

        function[chkSum,isOk]=computeTextCheckSum(srcFile,isFile)

            isOk=true;
            txt=[];
            if isFile&&isfile(srcFile)
                fid=fopen(srcFile,'rb');
                if fid>2

                    txt=fread(fid,Inf,'*uint8');
                    fclose(fid);
                else
                    isOk=false;
                end
            else

                txt=srcFile;
            end



            try
                txt=CGXE.CustomCode.strcxxtrim(char(txt));
            catch
            end

            chkSum=CGXE.Utils.md5(txt);
        end








        function[feOpts,restoreFcn]=setupOptions(feOpts)
            oldPreproc=feOpts.DoPreprocessOnly;
            oldComments=feOpts.Preprocessor.KeepComments;
            oldLines=feOpts.Preprocessor.KeepLineDirectives;
            oldOptions=feOpts.ExtraOptions;





            feOpts.DoPreprocessOnly=true;
            feOpts.Preprocessor.KeepComments=false;
            feOpts.Preprocessor.KeepLineDirectives=false;
            feOpts.ExtraOptions(end+1:end+2)={'--trace_includes'};

            if nargout>1
                restoreFcn=@()restoreOptions(feOpts,...
                oldPreproc,...
                oldComments,...
                oldLines,...
                oldOptions);
            end
        end
    end
end

function checkForUnsupportedExtensions(fileName)
    unsupportedListForCCfiles={'.lib','.dll','.so','.exe',['.',mexext],'.dylib','.a','.o','.obj'};
    [~,fileName,ext]=fileparts(fileName);
    if ismember(ext,unsupportedListForCCfiles)
        throw(MException(message('Simulink:CustomCode:UnexpectedExtension',[fileName,ext])));
    end
end

function deleteFile(fileName)

    if isfile(fileName)
        delete(fileName);
    end
end


function restoreOptions(feOptions,oldPreproc,oldComments,oldLines,oldOptions)
    feOptions.DoPreprocessOnly=oldPreproc;
    feOptions.Preprocessor.KeepComments=oldComments;
    feOptions.Preprocessor.KeepLineDirectives=oldLines;
    feOptions.ExtraOptions=oldOptions;
end
