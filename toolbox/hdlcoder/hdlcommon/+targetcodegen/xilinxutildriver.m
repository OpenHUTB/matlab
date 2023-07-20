



classdef xilinxutildriver<handle

    methods(Static)

        function addXilinxNetlistFiles(fileList,varargin)
            hdlCurrentDriver=hdlcurrentdriver();
            if(isfield(hdlCurrentDriver.cgInfo,'xilinxNetlistFiles'))
                hdlCurrentDriver.cgInfo.xilinxNetlistFiles=unique([hdlCurrentDriver.cgInfo.xilinxNetlistFiles,fileList]);
            else
                hdlCurrentDriver.cgInfo.xilinxNetlistFiles=unique(fileList);
            end
        end


        function fileList=getXilinxNetlistFiles(varargin)
            cgInfo=targetcodegen.basedriver.getCGInfo(varargin{:});
            if(isfield(cgInfo,'xilinxNetlistFiles'))
                fileList=cgInfo.xilinxNetlistFiles;
            else
                fileList={};
            end
        end


        function addXilinxOtherTargetFiles(fileList,varargin)
            hdlCurrentDriver=hdlcurrentdriver();
            if(isfield(hdlCurrentDriver.cgInfo,'xilinxOtherTargetFiles'))
                hdlCurrentDriver.cgInfo.xilinxOtherTargetFiles=unique([hdlCurrentDriver.cgInfo.xilinxOtherTargetFiles,fileList]);
            else
                hdlCurrentDriver.cgInfo.xilinxOtherTargetFiles=unique(fileList);
            end
        end


        function fileList=getXilinxOtherTargetFiles(varargin)
            cgInfo=targetcodegen.basedriver.getCGInfo(varargin{:});
            if(isfield(cgInfo,'xilinxOtherTargetFiles'))
                fileList=cgInfo.xilinxOtherTargetFiles;
            else
                fileList={};
            end
        end


        function fileList=getXilinxAllTargetFiles(varargin)
            fileList=unique([targetcodegen.xilinxutildriver.getXilinxNetlistFiles(varargin{:}),...
            targetcodegen.xilinxutildriver.getXilinxOtherTargetFiles(varargin{:})]);
        end


        function str=getTclScriptsToAddAllTargetFiles(hdlSynthCmd,varargin)
            str='';
            cgInfo=targetcodegen.basedriver.getCGInfo(varargin{:});
            targetFiles=targetcodegen.xilinxutildriver.getXilinxAllTargetFiles(cgInfo);
            if(~isempty(targetFiles))
                str=sprintf(hdlSynthCmd,targetFiles{:});
            end
        end


        function path=getSimulatorLibPath()
            path=hdlgetparameter('SimulationLibPath');
            if(isempty(path))
                path=hdlgetparameter('xilinxSimulatorLibPath');
            end
            path=strtrim(path);
        end

    end

end

