classdef Map

    properties(Constant=true, Access=private, Hidden=true)
        baseUrl='https://ssd.mathworks.com/supportfiles/R2022a/';
        pakDestPath = fullfile(userpath,'sim3d_project',['R',version('-release')],'WindowsNoEditor/AutoVrtlEnv/Content/Paks/');
        csvFileName='Maps';
        csvFileExtension='.xlsx';
    end


    methods(Static=true, Access=public)
        function download(map)
            pakFile=sim3d.utils.internal.ScenesMapping.getPakFile(map);
            if(~isempty(pakFile))
                try
                    tempFolder=tempname;
                    mkdir(tempFolder);
                    websave(fullfile(tempFolder,[sim3d.maps.Map.csvFileName,sim3d.maps.Map.csvFileExtension]),fullfile(sim3d.maps.Map.baseUrl,[sim3d.maps.Map.csvFileName,sim3d.maps.Map.csvFileExtension]));
                catch
                    fprintf('\n');
                    error('Could not connect to the server. Please try again')
                end
                csvFileServer=readtable(fullfile(tempFolder,[sim3d.maps.Map.csvFileName,sim3d.maps.Map.csvFileExtension]));

                try
                    csvlocal=readtable(fullfile(sim3d.maps.Map.pakDestPath,[sim3d.maps.Map.csvFileName,sim3d.maps.Map.csvFileExtension]));
                catch
                    csvlocal=csvFileServer;
                    csvlocal(:,:)=[];
                end
                colServer=width(csvFileServer);
                colLocal=width(csvlocal);
                if colLocal<colServer
                    for i=1:(colServer-colLocal)
                        name=csvFileServer.Properties.VariableNames{colLocal+i};
                        csvlocal.(name)(:)="[]";
                    end
                end
                mapIndexServer=find(strcmp(csvFileServer.MapName,map),1);
                mapIndexLocal=find(strcmp(csvlocal.MapName,map),1);
                if~isempty(mapIndexLocal)
                    for i=1:colServer
                        csvlocal.(i)(mapIndexLocal)=csvFileServer.(i)(mapIndexServer);
                    end
                else
                    newMap=[];
                    for i=1:colServer
                        newMap=[newMap,csvFileServer.(i)(mapIndexServer)];
                    end
                    csvlocal=[csvlocal;newMap];
                    mapIndexLocal=height(csvlocal);
                end
                currentVersion=version('-release');
                currentVersionSplit=split(currentVersion,{'a','b'});
                currentVersionFiltered=str2double(currentVersionSplit(1));
                requiredVersion=csvlocal.MinimumRelease{mapIndexLocal};
                requiredVersionSplit=split(requiredVersion,{'R','a','b'});
                requiredVersionFiltered=str2double(requiredVersionSplit(2));
                currentVersionOrder=currentVersion(end);
                requiredVersionOrder=requiredVersion(end);

                currentVersion=version;
                requiredVersion=csvlocal.ReleaseUpdate{mapIndexLocal};

                updateCompatible=false;
                releaseCompatible=false;
                matlabSupportsMap=false;
                if(~strcmp(requiredVersion,'[]'))
                    if(contains(currentVersion,requiredVersion))
                        updateCompatible=true;
                    end
                else
                    updateCompatible=true;
                end
                if((currentVersionFiltered==requiredVersionFiltered)&&(currentVersionOrder>=requiredVersionOrder))||(currentVersionFiltered>requiredVersionFiltered)
                    releaseCompatible=true;
                end
                if(updateCompatible&&releaseCompatible)
                    matlabSupportsMap=true;
                end

                if(matlabSupportsMap)
                    mapUrl=[sim3d.maps.Map.baseUrl,convertStringsToChars(pakFile)];
                    mapPath=fullfile(sim3d.maps.Map.pakDestPath,pakFile);
                    mapExist=dir(mapPath);
                    pakDestFolderExist=dir(sim3d.maps.Map.pakDestPath);

                    if isempty(pakDestFolderExist)
                        mkdir(sim3d.maps.Map.pakDestPath)
                    end

                    if~isempty(mapExist)
                        delete(mapPath);
                    end

                    try
                        websave(mapPath,mapUrl);
                    catch
                        fprintf('\n');
                        error('Could not connect to the server. Please try again');
                    end
                    fprintf('\nMap is susccesfully downloaded and is up-to-date\n')
                    writetable(csvlocal,fullfile(sim3d.maps.Map.pakDestPath,[sim3d.maps.Map.csvFileName,sim3d.maps.Map.csvFileExtension]),'WriteMode','overwritesheet');
                else
                    fprintf('\n');
                    warning('Make sure you are in the minimum MATLAB release that supports this map or higher')
                    fprintf('\n');
                end
                rmdir(tempFolder,'s');
            else
                fprintf('\n');
                warning('Incorrect map name')
                fprintf('\n');
            end
        end


        function delete(map)
            pakFile=sim3d.utils.internal.ScenesMapping.getPakFile(map);
            if(~isempty(pakFile))
                mapPath=fullfile(sim3d.maps.Map.pakDestPath,pakFile);
                mapExist=dir(mapPath);
                if~isempty(mapExist)
                    try
                        delete(mapPath);
                        fprintf("\n%s was successfully deleted\n",map)
                    catch
                        fprintf('\n');
                        error('Could not delete the map. Please try again');
                    end
                else
                    fprintf('\n');
                    warning('%s map does not exist',map)
                    fprintf('\n');
                end
                try
                    csvlocal=readtable(fullfile(sim3d.maps.Map.pakDestPath,[sim3d.maps.Map.csvFileName,sim3d.maps.Map.csvFileExtension]));
                    mapIndex=find(strcmp(csvlocal.MapName,map),1);
                    if(~isempty(mapIndex))
                        csvlocal(mapIndex,:)=[];
                        try
                            writetable(csvlocal,fullfile(sim3d.maps.Map.pakDestPath,[sim3d.maps.Map.csvFileName,sim3d.maps.Map.csvFileExtension]),'WriteMode','overwritesheet');
                        catch
                            fprintf('\n');
                            warning('Could not update the CSV file. Try deleting the map again')
                            fprintf('\n');
                        end
                    end
                catch
                    fprintf('\n');
                    warning('No CSV file found. Could not track your local maps')
                    fprintf('\n');
                end
            else
                fprintf('\n');
                warning('Incorrect map name')
                fprintf('\n');
            end
        end


        function server()
            try
                tempFolder=tempname;
                mkdir(tempFolder);
                websave(fullfile(tempFolder,[sim3d.maps.Map.csvFileName,sim3d.maps.Map.csvFileExtension]),fullfile(sim3d.maps.Map.baseUrl,[sim3d.maps.Map.csvFileName,sim3d.maps.Map.csvFileExtension]));
                csvFileServer=readtable(fullfile(tempFolder,[sim3d.maps.Map.csvFileName,sim3d.maps.Map.csvFileExtension]));
                if(~isempty(csvFileServer))
                    cols=width(csvFileServer);
                    for i=1:cols
                        csvFileServer.(i)=string(csvFileServer.(i));
                    end
                    fprintf('\n')
                    disp(csvFileServer)
                    fprintf('\n');
                    csvlocalPath=fullfile(sim3d.maps.Map.pakDestPath,[sim3d.maps.Map.csvFileName,sim3d.maps.Map.csvFileExtension]);
                    csvlocalExist=dir(csvlocalPath);
                    if~isempty(csvlocalExist)
                        csvlocal=readtable(fullfile(sim3d.maps.Map.pakDestPath,[sim3d.maps.Map.csvFileName,sim3d.maps.Map.csvFileExtension]));
                        numOfMaps=length(csvlocal.MapName);
                        for i=1:numOfMaps
                            mapIndex=find((strcmp(csvFileServer.MapName,csvlocal.MapName(i))),1);
                            mapVersionServer=str2double(csvFileServer.Version(mapIndex));
                            mapVersionLocal=csvlocal.Version(i);
                            if(mapVersionServer>mapVersionLocal)
                                fprintf('\n');
                                warning("%s has an updated version. Make sure you download the map again in the supported MATLAB release",csvlocal.MapName{i})
                                fprintf('\n');
                            end
                        end
                    end
                else
                    fprintf("\nNo maps are available on the server. Check back later\n")
                end
                rmdir(tempFolder,'s');
            catch
                fprintf('\n');
                error('Could not connect to the server. Please try again');
            end
        end


        function local()
            try
                csvlocal=readtable(fullfile(sim3d.maps.Map.pakDestPath, ...
                    [sim3d.maps.Map.csvFileName,sim3d.maps.Map.csvFileExtension]));
                cols=width(csvlocal);
                for i=1:cols
                    csvlocal.(i)=string(csvlocal.(i));
                end
                if~isempty(csvlocal)
                    fprintf('\n')
                    disp(csvlocal)
                    fprintf('\n');
                else
                    fprintf("\nNo maps found\n")
                end
            catch
                fprintf("\nNo maps found\n")
            end
        end

    end
end

