function updateStoredRun(this,storedRunID,varNames,varargin)




    if~this.isValidRunID(storedRunID)
        return;
    end


    varValues=Simulink.sdi.internal.Util.baseWorkspaceValuesForNames(varNames);


    res=cellfun(@isempty,varNames);
    if any(res==true)
        error(message('SDI:sdi:EmptyVarNames'));
    end


    this.safeTransaction(@helperUpdateStoredRun,this,storedRunID,...
    varNames,varValues,varargin{:});

    sigCount=this.getSignalCount(storedRunID);

    if sigCount==0

        this.removeEmptyRun(storedRunID);
        if~isempty(varargin)
            this.warnDialogParam=varargin{1};
        end
    elseif~isempty(varargin)

        mdlName=varargin{1};
        this.recordHarnessModelMetaData(mdlName,storedRunID)
    else

        this.updateFlag=storedRunID;
    end

    notify(this,'signalsInsertedEvent',...
    Simulink.sdi.internal.SDIEvent('signalsInsertedEvent',storedRunID));
end

function helperUpdateStoredRun(this,storedRunID,varNames,varValues,varargin)
    this.updateRunFromNamesAndValues(storedRunID,varNames,varValues,...
    varargin{:});
end
