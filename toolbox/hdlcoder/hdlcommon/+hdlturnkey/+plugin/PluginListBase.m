


classdef(Abstract)PluginListBase<hdlturnkey.plugin.ListBase


    properties(Abstract,Access=protected)

        CustomizationFileName;
    end

    methods

        function obj=PluginListBase()

        end

    end

    methods(Access=protected)

        function customFiles=searchCustomizationFileOnPath(obj)

            customFiles={};


            allFiles=which(obj.CustomizationFileName,'-ALL');

            if isempty(allFiles)
                return;
            end

            if~iscell(allFiles)
                allFiles={allFiles};
            end


            for ii=1:length(allFiles)
                [folder,name,~]=fileparts(allFiles{ii});
                allFiles{ii}=fullfile(folder,name);
            end
            customFiles=unique(allFiles);
        end

        function reportInvalidPlugin(~,pluginPath,MEmsg)

            msgObj=message('hdlcommon:workflow:InvalidPlugin',pluginPath,MEmsg);
            warning(msgObj);
        end

        function[packName,packFullPath,packPath]=getPackageName(~,pluginPath)








            regStr='\.\w+$';
            packName=regexprep(pluginPath,regStr,'');


            packFileFullPath=which(pluginPath);
            packFullPath=fileparts(packFileFullPath);


            packCell=regexp(packName,'\.','split');
            for ii=1:length(packCell)
                packCell{ii}=sprintf('+%s',packCell{ii});
            end
            packPath=fullfile(packCell{:});

        end

    end

end



