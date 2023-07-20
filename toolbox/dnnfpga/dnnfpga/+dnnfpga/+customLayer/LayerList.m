classdef LayerList<hdlturnkey.plugin.PluginListBase




    properties(Access=protected)


        CustomizationFileName='dlhdl_customLayer_registration';

    end

    methods
        function obj=LayerList


        end

        function buildLayerList(obj)


            obj.clearLayerList;



            obj.searchLayerRegistrationFile;

        end

        function searchLayerRegistrationFile(obj)




            regFiles=obj.searchCustomizationFileOnPath;

            currentFolder=pwd;
            for ii=1:length(regFiles)
                regFile=regFiles{ii};
                [regFileFolder,regFileName,~]=fileparts(regFile);
                cd(regFileFolder);
                hLayerList=eval(regFileName);


                obj.validateLayerList(hLayerList,regFileName);

                for jj=1:length(hLayerList)
                    hLayer=hLayerList{jj};
                    layerRelativePath=hLayer.Model;


                    layerAbsolutePath=downstream.tool.getAbsoluteFolderPath(layerRelativePath);
                    hLayer.setModelPath(layerAbsolutePath);
                    obj.addLayer(hLayer);
                end

            end
            cd(currentFolder);
        end
        function list=getLayerList(obj)

            namelist=obj.getNameList;

            list={};
            for idx=1:length(namelist)
                bsName=namelist{idx};
                hLayer=obj.getLayer(bsName);
                list{end+1}=hLayer;%#ok<AGROW>
            end

        end
    end
    methods(Access=protected)
        function clearLayerList(obj)


            obj.initList;
        end
        function addLayer(obj,hLayer)



            nameLowercase=lower(hLayer.Name);


            [isIn,hExistingLayer]=isInList(obj,nameLowercase);
            if isIn
                existingModelPath=hExistingLayer.Model;
                error(message('dnnfpga:customLayer:DuplicateBlockName',nameLowercase,existingModelPath));
            else
                obj.insertPluginObject(nameLowercase,hLayer);
            end
        end

        function hLayer=getLayer(obj,name)



            nameLower=lower(name);
            [~,hLayer]=obj.isInList(nameLower);
        end

        function validateLayerList(~,hLayerList,regFileName)



            layerInfoListMsg=message('dnnfpga:customLayer:LayerListCellArray',regFileName);

            for idx=1:length(hLayerList)
                hLayer=hLayerList{idx};
                if~isa(hLayer,'dnnfpga.customLayer.CustomLayer')
                    error(layerInfoListMsg);
                end
            end
        end
    end
end

