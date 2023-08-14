




classdef ParamOwnerTreeModel<handle

    properties
ID
DisplayIcon
DisplayLabel
Children
FullBlockPath
ArgName
    end

    methods

        function obj=ParamOwnerTreeModel(id,slObj)
            obj.ID=id;
            obj.Children={};

            if isa(slObj,'Simulink.Root')
                obj.DisplayIcon=[matlabroot,'/toolbox/shared/dastudio/resources/search_warning.png'];
                obj.DisplayLabel=DAStudio.message('Simulink:blocks:ParameterReaderWriterSelectorTreeEmpty');
            elseif isa(slObj,'Simulink.BlockDiagram')
                obj.DisplayIcon=[matlabroot,'/toolbox/shared/dastudio/resources/SimulinkModelIcon.png'];
                obj.DisplayLabel=slObj.Name;
            elseif isa(slObj,'Simulink.ModelReference')
                obj.DisplayIcon=[matlabroot,'/toolbox/shared/dastudio/resources/MdlRefBlockIcon.png'];
                obj.DisplayLabel=slObj.Name;
            elseif isa(slObj,'Simulink.SubSystem')
                obj.DisplayIcon=[matlabroot,'/toolbox/shared/dastudio/resources/SubSystemIcon.png'];
                obj.DisplayLabel=slObj.Name;
            elseif isa(slObj,'Simulink.Block')
                obj.DisplayIcon=[matlabroot,'/toolbox/shared/dastudio/resources/BlockIcon.png'];
                obj.DisplayLabel=slObj.Name;
            elseif isa(slObj,'Stateflow.Chart')
                obj.DisplayIcon=[matlabroot,'/toolbox/shared/dastudio/resources/Chart.png'];
                obj.DisplayLabel=slObj.Name;
            elseif isa(slObj,'DAStudio.WorkspaceNode')
                obj.DisplayIcon=[matlabroot,'/toolbox/shared/dastudio/resources/SimulinkWorkspace.png'];
                obj.DisplayLabel=slObj.getFullName;
            elseif isa(slObj,'DAStudio.WSOAdapter')
                obj.DisplayIcon=[matlabroot,'/toolbox/shared/dastudio/resources/SimscapeVariable.png'];
                [~,varName]=fileparts(slObj.getFullName);
                obj.DisplayLabel=varName;
            elseif isa(slObj,'struct')
                obj.DisplayIcon=[matlabroot,'/toolbox/shared/dastudio/resources/ParamAccessBlock.png'];
                idx=find(slObj.Name==':');
                if(~isempty(idx))
                    obj.DisplayLabel=slObj.Name(1:idx-1);
                else
                    obj.DisplayLabel=slObj.Name;
                end
                obj.FullBlockPath=slObj.FullBlockPath;
                obj.ArgName=slObj.ArgName;
            else
                obj.DisplayIcon=[matlabroot,'/toolbox/shared/dastudio/resources/BlockIcon.png'];
                obj.DisplayLabel=slObj.Name;
            end
        end


        function id=getID(obj)
            id=obj.ID;
        end


        function txt=getDisplayLabel(obj)
            txt=obj.DisplayLabel;
        end


        function icon=getDisplayIcon(obj)
            icon=obj.DisplayIcon;
        end


        function haschld=hasChildren(obj)
            haschld=~isempty(obj.Children);
        end


        function chld=getHierarchicalChildren(obj)
            chld=obj.Children;
        end
    end
end
