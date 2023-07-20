function result=addExclusion(this,propValues,varargin)

    persistent value;
    if(isempty(value))
        value=true;
        Simulink.DDUX.logData('EXCLUSION','maexclusionui',value);
    end

    result=[];
    window=Advisor.UIService.getInstance.getWindowById('ExclusionEditor',this.windowId);

    if nargin>3&&varargin{2}==true
        bIsForTest=true;
    else
        bIsForTest=false;
    end


    if~this.isTableDataValid
        this.getTableData();
    end




    if strcmp(propValues.Type,'Subsystem')&&...
        strcmp(propValues.propDesc,DAStudio.message('ModelAdvisor:engine:ExclusionContextMenusChartWithAllDescendants'))
        propValues.Type='Chart';
    end

    type=propValues.Type;
    summary=propValues.rationale;

    sid=propValues.value;
    extype=lower(propValues.Type);
    if contains(extype,{'masktype','blocktype','stateflow','blockparameters'})
        id=struct('sid',sid,'name',sid,'link',false);
    else
        name=slcheck.getFullPathFromSID(sid);
        id=struct('sid',sid,'name',name,'link',true);
    end

    checks=propValues.checkIDs;
    if numel(checks)==1&&strcmp(checks{1},'.*')
        checks='{All Checks}';
    else
        checks=['{',strjoin(checks,', '),'}'];
    end
    checkStruct.checks=checks;
    checkStruct.rowNum=numel(this.TableData)+1;

    this.TableData{end+1}={id,type,summary,checkStruct};

    if window.isOpen()||bIsForTest
        this.refreshUI;
    else
        window.open();
    end

    window.bringToFront();
    this.setDialogDirty(true);


    if(nargin==3&&varargin{1}==true)
        this.saveToDefaultLocation();
    end
end
