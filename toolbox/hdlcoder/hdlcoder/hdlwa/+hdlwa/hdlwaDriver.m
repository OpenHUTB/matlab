


classdef hdlwaDriver<handle
    properties(SetAccess=private,GetAccess=private)
objectiveDriver
pirFrontEnd
pir
TaskIDToObjMap
    end
    properties(Constant)
        modelChecksumFileName='modelchecksum.mat';
    end
    methods


        function this=hdlwaDriver
            this.objectiveDriver=[];
            this.pir=[];
            this.pirFrontEnd=[];
            this.TaskIDToObjMap=containers.Map();
        end


        function setObjectiveDriver(this,objDriver)
            this.objectiveDriver=objDriver;
        end


        function objDriver=getObjectiveDriver(this)
            objDriver=this.objectiveDriver;
        end



        function setPirAndFE(this,p,pFE)
            this.pirFrontEnd=pFE;
            this.pir=p;
        end


        function pirFE=getPirFrontEnd(this)
            pirFE=this.pirFrontEnd;
        end


        function p=getPIR(this)
            p=this.pir;
        end


        function createTaskObjMap(this,mdlAdvObj)

            this.TaskIDToObjMap=containers.Map();

            allHDLWATasks=mdlAdvObj.getTaskObj('com.mathworks.HDL','-regexp',true);
            for ii=1:length(allHDLWATasks)
                taskObj=allHDLWATasks{ii};
                taskID=taskObj.getID;
                this.TaskIDToObjMap(taskID)=taskObj;
            end
        end


        function taskObj=getTaskObj(this,taskID)
            if this.TaskIDToObjMap.isKey(taskID)
                taskObj=this.TaskIDToObjMap(taskID);
            else
                error(message('hdlcoder:workflow:InvalidTaskID',taskID));
            end
        end

    end

    methods(Static)
        function retval=modelName(mdlName)

            if nargin<1
                mdlName='';
            end

            retval='';

            persistent mdl;
            if isempty(mdl)
                mdl='';
            end

            if isempty(mdlName)
                retval=mdl;
            else
                mdl=mdlName;
            end
        end

        function hdlwaDriver=getHDLWADriverObj()

            hdlcoderObj=hdlwa.hdlwaDriver.getHDLCoderObj;

            hdlwaDriver=hdlcoderObj.getWorkflowAdvisorDriver;
        end

        function hdlcoderObj=getHDLCoderObj()

            hdlcoderObj=hdlmodeldriver(hdlwa.hdlwaDriver.modelName);
        end

        function isFeatureOn=isFILFeatureOn()
            try

                if~hdlcoderui.isslhdlcinstalled
                    isFeatureOn=false;
                    return;
                end


                mdlName=hdlwa.hdlwaDriver.modelName;
                if~isempty(mdlName)
                    filProp=hdlget_param(mdlName,'GenerateFILBlock');
                    isFeatureOn=strcmpi(filProp,'on');
                else
                    isFeatureOn=false;
                end

            catch %#ok<CTCH>
                isFeatureOn=false;
            end
        end
    end
end

