classdef FPGADeviceFamilyList<hdlturnkey.plugin.PluginListBase




    properties(Access=protected)










        CustomizationFileName='dlhdl_device_registration';

    end

    methods
        function obj=FPGADeviceFamilyList


        end

        function buildFPGADeviceFamilyList(obj)


            obj.clearDeviceFamilyList;




            obj.searchDevFamilyRegistrationFile;

        end

    end

    methods(Access=protected)
        function clearDeviceFamilyList(obj)
            obj.initList;
        end

        function addDeviceFamily(obj,hDeviceFamily)



            dfNameLower=lower(hDeviceFamily.Name);


            [isIn,hExistingFamily]=isInList(obj,dfNameLower);
            if isIn
                error(message('dnnfpga:workflow:DuplicateDeviceFamily',dfNameLower));
            else
                obj.insertPluginObject(dfNameLower,hDeviceFamily);
            end
        end

        function searchDevFamilyRegistrationFile(obj)




            deviceFamilyRegFiles=obj.searchCustomizationFileOnPath;

            currentFolder=pwd;
            for ii=1:length(deviceFamilyRegFiles)
                deviceFamilyRegFile=deviceFamilyRegFiles{ii};
                [deviceFamilyRegFileFolder,deviceFamilyRegFileName,~]=fileparts(deviceFamilyRegFile);

                cd(deviceFamilyRegFileFolder);
                hDeviceFamilyList=eval(deviceFamilyRegFileName);

                for jj=1:length(hDeviceFamilyList)
                    hDeviceFamily=hDeviceFamilyList{jj};

                    obj.addDeviceFamily(hDeviceFamily);
                end
                cd(currentFolder);
            end
        end

    end
end




