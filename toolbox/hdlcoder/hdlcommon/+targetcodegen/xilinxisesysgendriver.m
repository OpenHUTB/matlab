



classdef xilinxisesysgendriver<targetcodegen.xilinxsysgendriver

    methods(Static)

        function fileList=getXSGHDLFiles(xsgDir)

            fileListFileName='hdlFiles';
            fileListFilePath=fullfile(xsgDir,fileListFileName);
            fid=fopen(fileListFilePath);
            fileList=textscan(fid,'%s','delimiter',sprintf('\n'));
            fclose(fid);
            fileList=fileList{:}';
        end


        function[netlistFileList,otherFileList]=extractXSGTargetFiles(xsgDir)

            fileListFileName='globals';
            fileListFilePath=fullfile(xsgDir,fileListFileName);
            fid=fopen(fileListFilePath);
            fileLines=textscan(fid,'%s','delimiter',sprintf('\n'));
            fileLines=fileLines{:};
            fclose(fid);
            startLine=0;
            netlistFileList={};
            otherFileList={};
            for i=1:length(fileLines)
                if(strcmp(fileLines{i},'''files'' => ['))
                    startLine=i+1;
                    break;
                end
            end
            if(startLine>0)
                for i=startLine:length(fileLines)
                    if(strcmp(fileLines,'],'))
                        break;
                    end
                    fileName=fileLines{i}(2:end-2);
                    [~,~,ext]=fileparts(fileName);
                    switch lower(ext)
                    case{'.ngc'}
                        netlistFileList{end+1}=fileName;
                    case{'.mif'}
                        otherFileList{end+1}=fileName;
                    otherwise
                    end
                end
            end
        end


        function str=getXSGSynthesisScripts(hdlSynthCmd,codeGenDir,isVHDL,varargin)
            str='';
            xsgCodeGenPath=targetcodegen.xilinxsysgendriver.getXSGCodeGenPath(varargin{:});
            if(~isempty(xsgCodeGenPath))
                for i=1:length(xsgCodeGenPath)
                    libName=xsgCodeGenPath{i};
                    str=sprintf('%slib_vhdl new %s\n',str,libName);%#ok<*AGROW>
                    fileList=targetcodegen.xilinxisesysgendriver.getXSGHDLFiles(fullfile(codeGenDir,libName));
                    for j=1:length(fileList)
                        fileName=fileList{j};
                        fileLocation=[libName,'/',fileName];
                        addFileStr=sprintf(hdlSynthCmd,fileLocation);





                        if(isVHDL)
                            addFileStr=strtrim(addFileStr);
                            addFileStr=sprintf('%s -lib_vhdl %s\n',addFileStr,libName);
                        end
                        str=[str,addFileStr];
                    end
                end
            end
        end


        function xsgBlks=findXSGBlks(blk,varargin)
            searchAll=false;
            if(nargin>=2&&strcmpi(varargin{1},'all'))
                searchAll=true;
            end

            if(searchAll)
                xsgBlks=find_system(blk,'LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem,...
                'block_type','sysgen');
            else
                xsgBlks=find_system(blk,'SearchDepth',1,...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'LookUnderMasks','all','block_type','sysgen');
            end
        end
    end


    methods(Static)

        function[mdldir,strdir]=getXSGCodeGenDir(blk)

            xsgdir=xlgetparam(blk,'directory');

            top=hdlgettoplevel(blk);
            mdldir=fileparts(get_param(top,'FileName'));
            strdir=fullfile(mdldir,xsgdir);

            if length(xsgdir)>1
                if strcmp('//',xsgdir(1:2))||strcmp(':',xsgdir(2))

                    strdir=xsgdir;
                end
            end
            mdldir=strrep(mdldir,'\','/');
            strdir=strrep(strdir,'\','/');
        end


        function bool=isXSGSubsystem(blockPath)
            bool=~isempty(targetcodegen.xilinxisesysgendriver.findXSGBlks(blockPath));
        end
    end
end


