classdef ComponentDispNameReader<hwconnectinstaller.internal.ComponentDispNameReaderWriter;







    properties
    end

    methods(Static,Access=public)
        function installLoc=get3PInstallLocByDispName(tpDispName)










            validateattributes(tpDispName,{'char'},{'nonempty'},'get3PInstallLocByDispName','tpDispName',1);




            tpComponentName=hwconnectinstaller.internal.ComponentDispNameReader.get3PComponentNameFromDispName(tpDispName);



            hwconnectinstaller.internal.inform(...
            sprintf('Corresponding instructionSet component name for 3P tool "%s" is "%s" .',...
            tpDispName,tpComponentName));




            installLoc=matlab.internal.get3pInstallLocation(tpComponentName);

            hwconnectinstaller.internal.inform(...
            sprintf('Install location of 3P tool with component name "%s" and display name "%s" is "%s" .',...
            tpComponentName,tpDispName,installLoc));

        end

        function tpComponentName=get3PComponentNameFromDispName(tpDispName)















            validateattributes(tpDispName,{'char'},{'nonempty'},'get3PComponentNameFromDispName','tpDispName',1);


            mapFile=hwconnectinstaller.internal.ComponentDispNameReaderWriter.getDispNameToComponentMapFile();


            filedata=fileread(mapFile);




            list=strsplit(filedata,{'\r','\n'});





            uniqList=unique(list,'last');
            [rowLen,colLen]=size(uniqList);


            keySet={};
            valueSet={};

            token=hwconnectinstaller.internal.ComponentDispNameReaderWriter.ComponentDispNameSeparator;

            hwconnectinstaller.internal.inform(...
            sprintf('\nEntries in the map file are \n'));

            for ii=1:colLen


                splitStr=regexp(uniqList{rowLen,ii},token,'split');

                if length(splitStr)==2
                    keySet{end+1}=splitStr{2};%#ok<AGROW>
                    valueSet{end+1}=splitStr{1};%#ok<AGROW>

                    hwconnectinstaller.internal.inform(...
                    sprintf('ComponentName<@>DispName -> %s<@>%s \n',...
                    splitStr{1},splitStr{2}));
                end
            end

            dispToCompNameMap=containers.Map(keySet,valueSet);



            if~dispToCompNameMap.isKey(tpDispName)
                error(message('hwconnectinstaller:installapi:DisplayNameDoesNotExist',...
                tpDispName));
            else
                tpComponentName=dispToCompNameMap(tpDispName);
            end

        end

    end

end

