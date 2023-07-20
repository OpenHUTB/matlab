function mdladvObj=getHdladvObj(varargin)







    persistent HDLWAObjKey;
    if isempty(HDLWAObjKey)
        HDLWAObjKey='';
    end


    dut=[];
    scope_o=[];
    mdladvObj=[];

    if(nargin>0)
        dut=varargin{1};
    end

    if(nargin>1)
        scope_o=varargin{2};
    end


    appObjMap=Advisor.Manager.getInstance.ApplicationObjMap;

    if isKey(appObjMap,HDLWAObjKey)

        HDLWAObj=appObjMap(HDLWAObjKey);
        if(isempty(dut)&&isempty(scope_o))

            mdladvObj=HDLWAObj.getRootMAObj;
            return;
        elseif strcmp(HDLWAObj.AnalysisRoot,dut)


            mdladvObj=HDLWAObj.getRootMAObj;
        else

            HDLWAObj.delete;

            HDLWAObjKey='';
        end
    else

        HDLWAObjKey='';
    end


    if isempty(HDLWAObjKey)&&~isempty(scope_o)
        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(scope_o.getFullName,'new','com.mathworks.HDL.WorkflowAdvisor');
        HDLWAObjKey=mdladvObj.ApplicationID;
    end

end

