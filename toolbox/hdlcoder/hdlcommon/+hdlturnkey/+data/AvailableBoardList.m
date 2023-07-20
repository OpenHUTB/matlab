


classdef AvailableBoardList<handle



    properties

        PluginDirList={};

        CustomObjList=containers.Map;
        PluginObjList=containers.Map;
    end

    properties(Abstract=true,Hidden=true)

BuiltInDirPath
BuiltInPackagePath

PluginDirName
PluginFileName
    end

    methods

        function obj=AvailableBoardList()

        end

        function buildAvailableBoardList(obj)



            searchPluginDirList(obj);

            buildBoardPluginList(obj);
        end

        function nameList=getBoardNameList(obj,isMLHDLC)
            if nargin==1
                isMLHDLC=false;
            end

            list2=obj.CustomObjList.keys;

            if~isMLHDLC

                list1=obj.PluginObjList.keys;

                nameList=union(list1,list2,'sorted');
            else
                nameList=list2;
            end
        end

        function isEmpty=isBoardListEmpty(obj)

            isEmpty=obj.PluginObjList.isempty&&obj.CustomObjList.isempty;
        end

        function[isIn,hP]=isInBoardList(obj,boardName)


            if obj.PluginObjList.isKey(boardName);
                isIn=true;
                hP=obj.PluginObjList(boardName);
            elseif obj.CustomObjList.isKey(boardName)
                isIn=true;
                hP=obj.CustomObjList(boardName);
            else
                isIn=false;
                hP=[];
            end

        end

    end

    methods(Access=protected)

        function searchPluginDirList(obj)








            obj.PluginDirList={};


            pluginDir.path=obj.BuiltInDirPath;
            pluginDir.packagepath=obj.BuiltInPackagePath;
            obj.PluginDirList{end+1}=pluginDir;


            customStructs=what(obj.PluginDirName);
            for ii=1:length(customStructs)
                customStruct=customStructs(ii);
                pluginDirPath=customStruct.path;
                packageDirs=customStruct.packages;

                if~exist(pluginDirPath,'dir')||isempty(packageDirs)
                    continue;
                end

                [isPackage,pluginDirPackagePath]=isPackageFolder(obj,pluginDirPath);
                if~isPackage
                    continue;
                end

                for jj=1:length(packageDirs)
                    packageName=sprintf('+%s',packageDirs{jj});
                    if downstream.plugin.PluginBase.existPluginFile(...
                        fullfile(pluginDirPath,packageName),obj.PluginFileName)

                        pluginDir.path=pluginDirPath;
                        pluginDir.packagepath=pluginDirPackagePath;
                        obj.PluginDirList{end+1}=pluginDir;
                        break;
                    end
                end
            end
        end

        function[isPackage,packagePath]=isPackageFolder(~,folderPath)
            isPackage=false;
            packagePath='';
            [~,packageName]=fileparts(folderPath);
            if~isempty(regexp(packageName,'^\+','once'))
                isPackage=true;
                packagePath=regexprep(packageName,'^\+','','once');
            end
        end

        function buildBoardPluginList(obj)






            obj.PluginObjList=containers.Map;

            for ii=1:length(obj.PluginDirList)
                pluginDir=obj.PluginDirList{ii};
                pluginDirPath=pluginDir.path;
                pluginDirPackagePath=pluginDir.packagepath;

                pluginStruct=what(pluginDirPath);
                packageDirs=pluginStruct.packages;
                for jj=1:length(packageDirs)
                    pluginPackage=packageDirs{jj};
                    packageName=sprintf('+%s',pluginPackage);


                    pluginPath=fullfile(pluginDirPath,packageName);
                    if~downstream.plugin.PluginBase.existPluginFile(...
                        pluginPath,obj.PluginFileName)
                        continue;


                    end
                    pluginPackagePath=sprintf('%s.%s',pluginDirPackagePath,pluginPackage);


                    try
                        hP=hdlturnkey.PluginBoard.loadPluginFile(pluginPackagePath,obj.PluginFileName);
                    catch %#ok<CTCH>

                        continue;
                    end

                    if~hP.isSupported

                        continue;
                    end

                    hP.PluginPath=pluginPath;
                    hP.PluginPackage=pluginPackagePath;



                    if~obj.PluginObjList.isKey(hP.BoardName)
                        obj.PluginObjList(hP.BoardName)=hP;
                    else
                        hPDup=obj.PluginObjList(hP.BoardName);
                        error(message('hdlcommon:workflow:DuplicateBoardName',hP.BoardName,hPDup.PluginPath,hP.PluginPath));
                    end

                end
            end
        end

    end

end


