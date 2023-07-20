classdef BitstreamList<hdlturnkey.plugin.PluginListBase




    properties(Access=protected)








        CustomizationFileName='dlhdl_bitstream_registration';

    end

    methods
        function obj=BitstreamList


        end

        function buildBitstreamList(obj)


            obj.clearBitstreamList;




            obj.searchBitstreamRegistrationFile;

        end

        function hBitstream=getBitstream(obj,bsName)



            bsNameLower=lower(bsName);
            [isIn,hBitstream]=obj.isInList(bsNameLower);
            if~isIn
                error(message('dnnfpga:workflow:InvalidBitstreamName',bsName));
            end
        end

        function bsList=getBitstreamList(obj)

            allBistreamNameList=obj.getNameList;


            bsList={};
            for ii=1:length(allBistreamNameList)
                bsName=allBistreamNameList{ii};
                hBitstream=obj.getBitstream(bsName);
                if~hBitstream.Hidden
                    bsList{end+1}=bsName;%#ok<AGROW>
                end
            end
        end

    end

    methods(Access=protected)
        function clearBitstreamList(obj)
            obj.initList;
        end

        function addBitstream(obj,hBitstream)



            bsNameLower=lower(hBitstream.Name);


            [isIn,hExistingBitstream]=isInList(obj,bsNameLower);
            if isIn
                existingFilePath=hExistingBitstream.getAbsolutePath;
                error(message('dnnfpga:workflow:DuplicatedBitstreamName',bsNameLower,existingFilePath));
            else
                obj.insertPluginObject(bsNameLower,hBitstream);
            end
        end

        function searchBitstreamRegistrationFile(obj)




            bitstreamRegFiles=obj.searchCustomizationFileOnPath;

            currentFolder=pwd;
            for ii=1:length(bitstreamRegFiles)
                bitstreamRegFile=bitstreamRegFiles{ii};
                [bitstreamRegFileFolder,bitstreamRegFileName,~]=fileparts(bitstreamRegFile);




                cd(bitstreamRegFileFolder);
                hBitstreamList=eval(bitstreamRegFileName);


                obj.validateBitstreamInfoList(hBitstreamList,bitstreamRegFileName);


                for jj=1:length(hBitstreamList)
                    hBitstream=hBitstreamList{jj};
                    bitstreamRelativePath=hBitstream.Path;


                    bitstreamAbsolutePath=downstream.tool.getAbsoluteFolderPath(bitstreamRelativePath);
                    hBitstream.setAbsolutePath(bitstreamAbsolutePath);



                    if~hBitstream.Hidden&&~exist(bitstreamAbsolutePath,'file')
















                    end


                    obj.addBitstream(hBitstream);

                end
                cd(currentFolder);

            end
        end

        function validateBitstreamInfoList(~,hBitstreamList,bitstreamRegFileName)


            bitstreamInfoListMsg=message('dnnfpga:workflow:BitstreamListCellArray',bitstreamRegFileName);

            if~iscell(hBitstreamList)||isempty(hBitstreamList)
                error(bitstreamInfoListMsg);
            else
                for ii=1:length(hBitstreamList)
                    hBitstream=hBitstreamList{ii};
                    if~isa(hBitstream,'dnnfpga.bitstream.Bitstream')
                        error(bitstreamInfoListMsg);
                    end
                end
            end
        end

    end
end




