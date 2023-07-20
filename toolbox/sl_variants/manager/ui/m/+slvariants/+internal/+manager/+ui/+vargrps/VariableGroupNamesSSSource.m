classdef VariableGroupNamesSSSource<handle




    properties
        Children(1,:)slvariants.internal.manager.ui.vargrps.VariableGroupNamesSSRow;
        BDHandle;
        RootRow slvariants.internal.manager.ui.vargrps.VariableGroupNamesSSRow;

    end

    properties(Dependent,SetAccess=private,GetAccess=public)
        ModelName;
    end

    methods
        function obj=VariableGroupNamesSSSource(bdHandle)
            if nargin==0
                return;
            end
            obj.BDHandle=bdHandle;

            defaultGrpName=slvariants.internal.manager.ui.config.VMgrConstants.DefaultGroupName;
            obj.RootRow=slvariants.internal.manager.ui.vargrps.VariableGroupNamesSSRow(defaultGrpName,obj);
        end

        function modelName=get.ModelName(obj)
            modelName=getfullname(obj.BDHandle);
        end

        function children=getChildren(obj,~)
            children=slvariants.internal.manager.ui.vargrps.VariableGroupNamesSSRow.empty;
            if isempty(obj.RootRow)
                obj.Children=children;
                return;
            end

            row=obj.RootRow;
            while~isempty(row)
                children(end+1)=row;%#ok<AGROW>
                row=row.Next;
            end
            obj.Children=children;
        end




        function variableGroupPVPairs=getVariableGroupsCommand(obj)
            grpNameRows=obj.getChildren([]);

            numVarGrps=length(grpNameRows);
            variableGroupStructs=repmat(struct('Name',[],'VariantControls',[]),0,0);
            rowIndex=0;
            fullRangeVarNamesRefValuesMap=containers.Map();
            for i=1:numVarGrps
                if~grpNameRows(i).IsSelected

                    continue;
                end
                rowIndex=rowIndex+1;
                ctrlVarRows=grpNameRows(i).VariableGroupsSrc.getChildren([]);


                variableGroupStruct.Name=grpNameRows(i).GroupName;
                variableGroupStruct.VariantControls={};
                for ctrlVarRowIdx=1:length(ctrlVarRows)
                    ctrlVarName=ctrlVarRows(ctrlVarRowIdx).CtrlVarName;
                    modelname=obj.ModelName;
                    activeTab=slvariants.internal.manager.ui.utils.getActiveTabInVM(get_param(modelname,'handle'));
                    if ctrlVarRows(ctrlVarRowIdx).IsFullRange
                        if strcmp(activeTab,'variantReducerTab')
                            fullRangeVarNamesRefValuesMap(ctrlVarName)=ctrlVarRows(ctrlVarRowIdx).ReferenceValue;
                        else


                            variableGroupStruct.VariantControls{end+1}=ctrlVarName;
                            if isempty(ctrlVarRows(ctrlVarRowIdx).ReferenceValue)
                                variableGroupStruct.VariantControls{end+1}=0;
                            else
                                variableGroupStruct.VariantControls{end+1}=ctrlVarRows(ctrlVarRowIdx).ReferenceValue;
                            end
                        end
                        continue;
                    end
                    variableGroupStruct.VariantControls{end+1}=ctrlVarName;
                    if~isempty(ctrlVarRows(ctrlVarRowIdx).CtrlVarValues)
                        variableGroupStruct.VariantControls{end+1}=ctrlVarRows(ctrlVarRowIdx).CtrlVarValues;
                    else
                        variableGroupStruct.VariantControls{end+1}=ctrlVarRows(ctrlVarRowIdx).CtrlVar;
                    end
                end
                variableGroupStructs=[variableGroupStructs,variableGroupStruct];%#ok<AGROW>
            end

            variableGroupPVPairs={'VariableGroups',variableGroupStructs};

            if~isempty(fullRangeVarNamesRefValuesMap)
                fullRangeNameValuePairs={};
                fullRangeCtrlVars=fullRangeVarNamesRefValuesMap.keys;
                for i=1:numel(fullRangeCtrlVars)

                    fullRangeNameValuePairs(end+1)=fullRangeCtrlVars(i);%#ok<AGROW>
                    fullRangeNameValuePairs(end+1)={fullRangeVarNamesRefValuesMap(fullRangeCtrlVars{i})};%#ok<AGROW>
                end
                variableGroupPVPairs=[variableGroupPVPairs,{'FullRangeVariables',fullRangeNameValuePairs}];
            end
        end
    end
end
