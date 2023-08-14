function updatedTree=assignMACIndex(this,tree)

    am=Advisor.Manager.getInstance;
    mp=ModelAdvisor.Preferences();

    if~isfield(am.slCustomizationDataStructure,'checkCellArray')
        am.loadslCustomization;
    end

    CheckIDMap=am.slCustomizationDataStructure.CheckIDMap;
    checkCellArray=am.slCustomizationDataStructure.checkCellArray;


    ConfigUICellArray=cell(1,numel(tree));
    jsonHasSeverityInfo=false;
    tree{1}.parent=NaN;
    for i=1:numel(tree)
        if~isempty(tree{i}.checkid)
            if CheckIDMap.isKey(tree{i}.checkid)
                matchCheckIndex=CheckIDMap(tree{i}.checkid);
                correspondingCheckObj=checkCellArray{matchCheckIndex};
                tree{i}.MACIndex=correspondingCheckObj.Index;
                foundMatch=true;
            else

                foundMatch=false;
                newID=ModelAdvisor.convertCheckID(tree{i}.checkid);
                if am.slCustomizationDataStructure.CheckIDMap.isKey(newID)
                    modeladvisorprivate('modeladvisorutil2','WarnOldCheckID',tree{i}.checkid,newID);
                    matchCheckIndex=am.slCustomizationDataStructure.CheckIDMap(newID);
                    correspondingCheckObj=am.slCustomizationDataStructure.checkCellArray{matchCheckIndex};
                    if~isempty(correspondingCheckObj)
                        tree{i}.MACIndex=correspondingCheckObj.Index;
                        foundMatch=true;
                    end
                end
                if~foundMatch
                    tree{i}.MACIndex=-1;
                end
            end

            if foundMatch&&~isempty(tree{i}.InputParameters)
                if~loc_verify_inputparam(tree{i}.InputParameters,correspondingCheckObj.InputParameters)
                    if~isempty(correspondingCheckObj.loadOutofdateInputParametersCallback)

                        status=correspondingCheckObj.loadOutofdateInputParametersCallback(tree{i});
                        if~status
                            tree{i}.MACIndex=-2;
                        end
                    else
                        tree{i}.MACIndex=-2;
                    end
                end
            end
        else
            tree{i}.MACIndex=0;
        end
    end

    updatedTree=tree;
end

function verified=loc_verify_inputparam(InputParameters1,InputParameters2)
    if~iscell(InputParameters1)
        InputParameters1=num2cell(InputParameters1);
    end

    if length(InputParameters1)==length(InputParameters2)
        verified=true;
        for i=1:length(InputParameters1)
            if~strcmp(InputParameters1{i}.type,InputParameters2{i}.Type)
                verified=false;
                break;
            end
        end
    else
        verified=false;
    end
end