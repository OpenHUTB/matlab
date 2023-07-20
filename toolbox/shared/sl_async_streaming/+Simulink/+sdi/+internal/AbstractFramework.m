classdef AbstractFramework<handle





    methods(Abstract)
        registerEnginePlugins(this,eng,isMainEng);
        unregisterEnginePlugins(this);
        ret=featureCheck(this,varargin);
        ret=displaySimulinkHelp(this);
        ret=getHelpMapFile(this);
        launchHelpAbout(this);
        clearNewDataNotification(this);
        addNewDataNotification(this,mdl);
        createDynamicEnum(this,className,labels,vals,baseClass);
        ret=evalWksVar(this,mdl,str);
        ret=createMATLABStructForBus(this,mdl,str);
        ret=getPCTHelpAnchor(this)


        ret=highlightSignal(this,sid,bpath,portIdx,metaData);
        out=getParam(this,hndl,param);
        out=getLogVarNamesFromModel(this,model);
        [runID,runIndex,varargout]=createRunFromModel(this,obj,model,varargin);
        recordHarnessModelMetaData(this,obj,model,runID);
        out=getBlockSource(this,bpath,sid);
        obj=getModelCloseUtil(this);


        out=getReportFolder(this);
        outputFileName=createSnapshot(this,name,format);


        out=getSID(this,varargin);
        out=getFullName(this,sid);
        out=addSimulinkTimeseries(this,obj,varName,varValue);
        out=isSLDVData(this,varValue);
        out=addSLDVRuns(this,varValue);
    end
end
