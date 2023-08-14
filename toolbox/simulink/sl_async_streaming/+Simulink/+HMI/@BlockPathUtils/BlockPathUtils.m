






classdef BlockPathUtils<Simulink.SimulationData.BlockPath


    methods(Static)


        function[path,ssid,sub_path]=getPathMetaData(bpath)

            path=bpath.path;
            ssid=bpath.ssid;
            sub_path=bpath.sub_path;
        end


        function bpath=createPathFromMetaData(path,ssid,sub_path,subSysPath)



            if nargin>3&&~isempty(subSysPath)
                mdl=Simulink.SimulationData.BlockPath.getModelNameForPath(...
                subSysPath);
                if~strcmp(path{1},mdl)
                    path{1}=[subSysPath,'/',path{1}];
                end
            end


            bpath=Simulink.BlockPath;
            bpath.path=path;
            bpath.ssid=ssid;
            bpath.sub_path=sub_path;
        end


        function bpath=createPathWithModelNameFromMetaData(mdl,path,ssid,sub_path,~)

            path={[mdl,'/',path{1}]};
            bpath=Simulink.BlockPath;
            bpath.path=path;
            if~isempty(ssid)
                bpath.ssid={[mdl,':',ssid{1}]};
            end
            bpath.sub_path=sub_path;
        end


        function[newPath,newSSID,new_sub_path]=updateModelNameForMetaData(...
            path,...
            ssid,...
            sub_path,...
            oldMdlName,...
            newMdlName,...
            subSysPath)



            if isempty(subSysPath)
                bpath=Simulink.HMI.BlockPathUtils.createPathFromMetaData(...
                path,ssid,sub_path);
                bpath=bpath.updateTopModelName(oldMdlName,newMdlName);
                [newPath,newSSID,new_sub_path]=...
                Simulink.HMI.BlockPathUtils.getPathMetaData(bpath);


            elseif length(path)==1&&strcmp(path{1},oldMdlName)
                newPath={newMdlName};
                newSSID={};
                new_sub_path=sub_path;



            else
                newPath=path;
                newSSID=ssid;
                new_sub_path=sub_path;
            end
        end


        function[newPath,newSSID,new_sub_path]=removeModelName(...
            model,...
            path,...
            ssid,...
            sub_path)

            if strfind(path{:},model)
                path={path{1}(length(model)+2:end)};
            end
            bpath=Simulink.HMI.BlockPathUtils.createPathFromMetaData(...
            path,ssid,sub_path);
            [newPath,newSSID,new_sub_path]=...
            Simulink.HMI.BlockPathUtils.getPathMetaData(bpath);

        end


        function ret=getPathRelationship(oldPath,newPath)





            import Simulink.SimulationData.BlockPath;
            oldMdl=BlockPath.getModelNameForPath(oldPath);
            newMdl=BlockPath.getModelNameForPath(newPath);
            if~strcmp(oldMdl,newMdl)
                ret='new_model';
                return;
            end

            ret='same_model';
            if length(newPath)<length(oldPath)
                searchStr=[newPath,'/'];
                len=length(searchStr);
                if strcmp(searchStr,oldPath(1:len))
                    ret='parent';
                end
            elseif length(newPath)>length(oldPath)
                searchStr=[oldPath,'/'];
                len=length(searchStr);
                if strcmp(searchStr,newPath(1:len))
                    ret='child';
                end
            end
        end

    end

end
