function saveSystemSettings(this,treeNode,batchName)




    topModel=this.ModelName;
    blkSID=Simulink.ID.getSID(treeNode);
    settingMap=this.getSystemSettingMapForShortcut(blkSID,batchName);
    for m={'DataTypeOverride','MinMaxOverflowLogging'}
        param=m{:};
        setting='UseLocalSettings';


        try
            setting=get_param(treeNode.getFullName,param);
        catch
        end


        if~strcmpi(setting,'UseLocalSettings')

            try
                settingMap.insert(param,setting);
            catch
            end

            settingMap.insert('DAObject',treeNode);
            if isa(treeNode,'Simulink.ModelReference')||...
                ~isequal(bdroot(treeNode.getFullName),topModel)
                node_parent_model=bdroot(treeNode.getFullName);
                if~isequal(node_parent_model,topModel)
                    topCh=this.getChildrenForSystem(topModel);
                    topModelTracePath='';
                    for i=1:length(topCh)
                        if fxptds.isStateflowChartObject(topCh(i))
                            topCh(i)=topCh(i).up;
                        end
                        if isa(topCh(i),'Simulink.ModelReference')
                            if isequal(topCh(i).ModelName,node_parent_model)
                                topModelTracePath={Simulink.ID.getSID(topCh(i))};
                                break;
                            end
                        end
                    end
                    if isempty(topModelTracePath)
                        children=SimulinkFixedPoint.AutoscalerUtils.getMdlRefs(topModel);
                        modelName=node_parent_model;
                        while~isequal(modelName,topModel)
                            breakOuterLoop=false;
                            for i=length(children):-1:1
                                child=children{i};
                                if isequal(modelName,child)
                                    continue;
                                end
                                ch=this.getChildrenForSystem(child);
                                for np=1:length(ch)
                                    if isa(ch(np),'Simulink.ModelReference')
                                        if isequal(ch(np).ModelName,modelName)
                                            if isempty(topModelTracePath)
                                                topModelTracePath={Simulink.ID.getSID(ch(np))};
                                            else
                                                topModelTracePath=[topModelTracePath,{Simulink.ID.getSID(ch(np))}];%#ok<AGROW>
                                            end
                                            modelName=bdroot(ch(np).getFullName);
                                            breakOuterLoop=true;
                                            break;
                                        end
                                    end
                                end
                                if breakOuterLoop
                                    break;
                                end
                            end


                            if(i==1)
                                modelName=topModel;
                            end
                        end
                    end
                    settingMap.insert('TopModelTracePath',topModelTracePath);
                end
            end
            settingMap.insert('SID',blkSID);


            if strcmpi(param,'DataTypeOverride')&&~strcmpi(treeNode.(param),'UseLocalSettings')
                try

                    settingMap.insert('DataTypeOverrideAppliesTo',treeNode.DataTypeOverrideAppliesTo);
                catch


                end
            end
        end
    end

    children=this.getChildrenForSystem(treeNode.getFullName);

    for i=1:length(children)
        child=children(i);
        if fxptds.isStateflowChartObject(child)
            child=child.up;
        end
        this.saveSystemSettings(child,batchName);
    end
end
