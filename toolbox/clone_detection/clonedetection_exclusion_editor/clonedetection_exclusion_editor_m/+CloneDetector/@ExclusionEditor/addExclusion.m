function result=addExclusion(this,propValues,varargin)




    result=[];
    window=Advisor.UIService.getInstance.getWindowById(this.AppID,this.windowId);

    if nargin>3&&varargin{2}==true
        bIsForTest=true;
    else
        bIsForTest=false;
    end

    if~this.isTableDataValid
        this.getTableData();
    end

    blockType=propValues.Type;
    exclusionRationale=propValues.rationale;

    blockPath=propValues.value;
    sid=Simulink.ID.getSID(blockPath);
    if contains(lower(blockType),{'masktype','blocktype','stateflow','blockparameters'})
        blockID=struct('sid',sid,'name',sid,'link',false);
    else
        blockID=struct('sid',sid,'name',blockPath,'link',true);
    end

    this.TableData{end+1}={blockID,blockType,exclusionRationale};


    if(nargin==3&&varargin{1}==true)
        this.saveToDefaultLocation();
    end

    if window.isOpen()||bIsForTest
        this.refreshUI;
    else
        window.open();
    end

    window.bringToFront();



    oldState=pause('on');
    pause(3);
    pause(oldState);
    this.updateDialogForAction(this.UpdateDialogAction.Dirty);
end


