function tooltip=getTooltip(system,blkHandle,varargin)
    editEngine=edittimecheck.EditTimeEngine.getInstance();
    ohandle=blkHandle;
    violations=editEngine.getViolations(system,ohandle);
    if strcmp(get_param(blkHandle,'type'),'line')

        ohandle=get_param(blkHandle,'Dstporthandle');
        for i=1:length(ohandle)
            violations=[violations,editEngine.getViolations(system,ohandle(i))];
        end
        ohandle=get_param(blkHandle,'Srcporthandle');
        violations=[violations,editEngine.getViolations(system,ohandle)];
    end
    checkMgr=edittimecheck.CheckManager.getInstance;
    tooltip='';


    if nargin==3
        needCompareType=true;
        if(varargin{1}==ModelAdvisor.CheckStatus.Warning)
            comparisonSet=ModelAdvisor.CheckStatus.Warning;
        else
            comparisonSet=ModelAdvisor.CheckStatus.Failed;
        end
    else
        needCompareType=false;
    end
    for i=1:length(violations)

        if~needCompareType||(violations(i).getViolationStatus()==comparisonSet)
            jsonData=checkMgr.getSLdiagnosticJSON(violations(i));
            if~isempty(jsonData)
                tooltip=jsondecode(jsonData).message;
            end
            break;
        end
    end