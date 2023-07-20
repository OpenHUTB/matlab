classdef(Sealed=true)Root<handle




    properties(Hidden=true,SetAccess=private)

        noncompileCheckList={};
        diyCheckList={};
        compileCheckList={};
        compileForCodegenCheckList={};
        cgirCheckList={};
        sldvCheckList={};
        missLicenseCheckList={};
        missLicenseTaskList={};


        TaskList={};



        allCallBackFcnListName={};


        taskCallBackFcnListName={};


        CallbackErrorMsg={};


        modelToExclusion={};


        defaultExclusionFile=[matlabroot,filesep,'toolbox',filesep,'simulink',filesep,'simulink',...
        filesep,'modeladvisor',filesep,'defaultExclusions.xml'];


        IsCustomCheck=true;


        ExpertMode=false;
    end

    properties(Access=private)
        CheckIDMap=containers.Map();



        OrderedTaskAdvisorNodes={};

        TaskAdvisorNodeID2Index=containers.Map;
        nodeCount=0;

    end

    methods(Hidden=true)
        function setAllCallBackFcnListName(this,value)
            this.allCallBackFcnListName=value;
        end

        function setTaskCallBackFcnListName(this,value)
            this.taskCallBackFcnListName=value;
        end

        function setTaskList(this,value)
            this.TaskList=value;
        end

        function setCallbackErrorMsg(this,value)
            this.CallbackErrorMsg=value;
        end

        function setIsCustomCheck(this,value)
            this.IsCustomCheck=value;
        end

        function setCheckInfo(this,idMap)


            this.CheckIDMap=idMap;
        end

        function clearCheckInfo(this)
            this.CheckIDMap=containers.Map();
        end




        function resetCollectedNodes(this,orderedNodes)
            assert(iscell(orderedNodes),'Expecting cell array');
            this.OrderedTaskAdvisorNodes=orderedNodes;
            this.TaskAdvisorNodeID2Index=containers.Map();
            for n=1:length(orderedNodes)
                this.TaskAdvisorNodeID2Index(orderedNodes{n}.ID)=n;
            end
        end

        function nodes=getTaskAdvisorNodes(this)
            nodes=this.OrderedTaskAdvisorNodes;
        end

        function node=getTaskAdvisorNode(this,id)
            node=[];
            if this.TaskAdvisorNodeID2Index.isKey(id)
                node=this.OrderedTaskAdvisorNodes{this.TaskAdvisorNodeID2Index(id)};
            end
        end
    end

    methods(Static=true)
        function singleObj=Root()
            persistent SingleRoot;
            if isempty(SingleRoot)||~isvalid(SingleRoot)
                SingleRoot=singleObj;
            else
                singleObj=SingleRoot;
            end
        end
    end
end
