classdef ComponentDispNameReaderWriter<handle






    properties(Constant,Access=public)
        ComponentDispNameMapFileDir=fullfile('appdata','3p');
        ComponentDispNameMapFileName='component_display_name_map.txt';
        ComponentDispNameSeparator='<@>';
    end

    methods(Static,Access=public)
        function mapFile=getDispNameToComponentMapFile()







            spRoot=matlabshared.supportpkg.getSupportPackageRoot();

            mapFileDir=hwconnectinstaller.internal.ComponentDispNameReaderWriter.ComponentDispNameMapFileDir;
            mapFileName=hwconnectinstaller.internal.ComponentDispNameReaderWriter.ComponentDispNameMapFileName;
            mapFile=fullfile(spRoot,mapFileDir,mapFileName);

            hwconnectinstaller.internal.inform(...
            sprintf('Location of the component_display_name_map.txt is "%s" .',...
            mapFile));


            fileExistance=exist(mapFile,'file');


            if~isequal(fileExistance,2)
                error('hwconnectinstaller:componentinstall:MapFileDoesNotExist',...
                'The file component_display_name_map.txt does not exist at "%s".',mapFileDir);
            end
        end
    end
end