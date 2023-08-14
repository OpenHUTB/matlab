




classdef StateOwnerSelectorTree<handle

    properties
ID
DisplayIcon
DisplayLabel
Children
    end

    methods

        function obj=StateOwnerSelectorTree(id,slObj)
            obj.ID=id;
            obj.DisplayLabel=strrep(slObj.Name,'/','//');
            obj.Children={};

            if isa(slObj,'Simulink.Root')
                obj.DisplayIcon=[matlabroot,'/toolbox/shared/dastudio/resources/search_warning.png'];
                obj.DisplayLabel=DAStudio.message('Simulink:blocks:StateReadWriteOwnSelectorTreeEmpty');
            elseif isa(slObj,'Simulink.BlockDiagram')
                obj.DisplayIcon=[matlabroot,'/toolbox/shared/dastudio/resources/SimulinkModelIcon.png'];
            elseif isa(slObj,'Simulink.SubSystem')
                obj.DisplayIcon=[matlabroot,'/toolbox/shared/dastudio/resources/SubSystemIcon.png'];
            elseif isa(slObj,'Simulink.ModelReference')
                obj.DisplayIcon=[matlabroot,'/toolbox/shared/dastudio/resources/MdlRefBlockIconNormal.png'];
            elseif isa(slObj,'Simulink.ObserverReference')
                obj.DisplayIcon=[matlabroot,'/toolbox/shared/simulinktest/resources/icons/ObserverEnabledBadge.png'];
            elseif isa(slObj,'Simulink.Block')
                if length(get_param(slObj.getFullName,'StateNameList'))>1
                    obj.DisplayIcon=[matlabroot,'/toolbox/shared/dastudio/resources/BlockIcon.png'];
                else
                    obj.DisplayIcon=[matlabroot,'/toolbox/shared/dastudio/resources/StateAccessBlock.png'];
                end
            elseif isa(slObj,'Stateflow.Chart')
                obj.DisplayIcon=[matlabroot,'/toolbox/shared/dastudio/resources/Chart.png'];
            elseif isa(slObj,'struct')
                obj.DisplayIcon=[matlabroot,'/toolbox/shared/dastudio/resources/StateAccessBlock.png'];
                if slObj.IsStatesNameEmpty
                    obj.DisplayIcon=[matlabroot,'/toolbox/shared/dastudio/resources/info2.png'];
                end
            else
                obj.DisplayIcon=[matlabroot,'/toolbox/shared/dastudio/resources/BlockIcon.png'];
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
