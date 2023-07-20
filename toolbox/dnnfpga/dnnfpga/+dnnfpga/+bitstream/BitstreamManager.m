classdef BitstreamManager<handle




    properties(Access=protected)
        hBitstreamList=[];
    end

    methods(Access=public)
        function obj=BitstreamManager()



            obj.hBitstreamList=dnnfpga.bitstream.BitstreamList;


            obj.buildBitstreamList;
        end

        function hBitstream=resolveBitstream(obj,bitstreamName,exampleStr)










            if nargin<3
                exampleStr='';
            end


            [bsFilePath,bsFileName,ext]=fileparts(bitstreamName);
            try
                if isempty(ext)&&isempty(bsFilePath)
                    hBitstream=obj.getBitstreamFromList(bsFileName);
                elseif~isempty(ext)&&isempty(bsFilePath)
                    hBitstream=obj.getBitstreamOnPath(bitstreamName);
                elseif~isempty(ext)&&~isempty(bsFilePath)
                    hBitstream=obj.getBitstreamWithPath(bitstreamName);
                else
                    error(message('dnnfpga:workflow:InvalidBitstreamFormat'));
                end
            catch ME


                msgInstallHSP=dnnfpga.apis.messageInstallHSP;


                msgSpecifyBitstreamFile=message('dnnfpga:workflow:AllowedBitstreamFormats',sprintf(exampleStr,'myFile.bit'),sprintf(exampleStr,'C:\myFolder\myFile.bit'));

                if isempty(obj.getBitstreamList)














                    error(message('dnnfpga:workflow:BitstreamListEmpty',ME.message,...
                    msgInstallHSP.getString,msgSpecifyBitstreamFile.getString));

                else




















                    msgSpecifyBitstreamName=message('dnnfpga:workflow:AllowedBitstreamNames',strjoin(obj.getBitstreamList,'\n'),sprintf(exampleStr,'zcu102_single'));


                    error(message('dnnfpga:workflow:BitstreamLoadFailure',ME.message,...
                    msgSpecifyBitstreamName.getString,msgInstallHSP.getString,msgSpecifyBitstreamFile.getString));
                end
            end


            hBitstream.loadBitstreamBuildInfo;



        end
    end

    methods(Access=protected)


        function buildBitstreamList(obj)

            obj.hBitstreamList.buildBitstreamList;
        end

        function bsList=getBitstreamList(obj)
            bsList=obj.hBitstreamList.getBitstreamList;
        end

        function hBitstream=getBitstreamFromList(obj,bsName)
            hBitstream=obj.hBitstreamList.getBitstream(bsName);
        end

        function hBitstream=getBitstreamWithPath(~,bsName)

            if~isfile(bsName)
                error(message('dnnfpga:workflow:BitstreamFileMissing',bsName));
            else
                bitstreamFileInfo=dir(bsName);
                absPath=fullfile(bitstreamFileInfo.folder,bitstreamFileInfo.name);
                hBitstream=dlhdl.Bitstream('Name',bsName,'AbsolutePath',absPath);
            end
        end

        function hBitstream=getBitstreamOnPath(obj,bsName)
            allFiles=obj.searchBitstreamFileOnPath(bsName);

            if isempty(allFiles)
                error(message('dnnfpga:workflow:BitstreamNotOnPath',bsName));
            elseif length(allFiles)>1
                error(message('dnnfpga:workflow:BitstreamDuplicateOnPath',bsName,strjoin(allFiles,'\n')));
            else
                absPath=allFiles{1};
                hBitstream=dlhdl.Bitstream('Name',bsName,'AbsolutePath',absPath);
            end
        end

        function allFiles=searchBitstreamFileOnPath(~,bsName)





            [~,~,ext]=fileparts(bsName);
            if isempty(ext)
                error(message('dnnfpga:workflow:NoBitstreamExtension'));
            end


            allFiles=which(bsName,'-ALL');


            if~iscell(allFiles)
                allFiles={allFiles};
            end
        end
    end
end





