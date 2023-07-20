classdef PortSelectorSourceData<BindMode.BindModeSourceData






    properties(SetAccess=protected,GetAccess=public)
        modelName;


        clientName=BindMode.ClientNameEnum.SSM;

        isGraphical=false;
        modelLevelBinding=false;
        sourceElementPath;
        hierarchicalPathArray;
        sourceElementHandle;

        allowMultipleConnections=true;

        requiresDropDownMenu=false;
        dropDownElements;
    end

    properties(Hidden,SetAccess=private,GetAccess=public)



        UpdateCallback=[];
    end

    methods
        function newObj=PortSelectorSourceData(sourceElementHandle)


            newObj.modelName=get_param(bdroot(sourceElementHandle),'Name');


            newObj.sourceElementPath=getfullname(sourceElementHandle);
            try
                newObj.sourceElementHandle=sourceElementHandle;
            catch ME
                if strcmp(ME.identifier,'Simulink:Commands:InvSimulinkObjectName')
                    newObj.sourceElementHandle=-1;
                end
            end
            newObj.hierarchicalPathArray=BindMode.utils.getHierarchicalPathArray(newObj.sourceElementPath);
        end
    end

    methods(Hidden)

        function setUpdateCallback(this,cb)
            this.UpdateCallback=cb;
        end


        function result=allowStateflowBinding(~)
            result=false;
            activeEditor=BindMode.utils.getLastActiveEditor();
            assert(~isempty(activeEditor));
            BindMode.utils.showHelperNotification(activeEditor,message('Spcuilib:scopes:StateflowNotSupportedTextSiggen').string());
        end
    end
end
