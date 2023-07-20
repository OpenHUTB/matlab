


function htmlOut=formatCheckCallbackOutput(this,CheckObj,ResultHandles,ResultDescription,recordCounter,addCGIRRefMdlMsg,TaskObj)
    htmlOut='';


    autoConvertProjectResultData=false;
    if strcmp(CheckObj.CallbackStyle,'StyleThree')
        if CheckObj.SupportHighlighting&&...
            isempty(CheckObj.ProjectResultData)&&~isempty(ResultHandles)

            autoConvertProjectResultData=true;
        end
    end

    for resultCounter=1:length(ResultDescription)
        if(resultCounter<=length(ResultHandles))
            ExecFunctionReturn=ResultHandles{resultCounter};
        else
            ExecFunctionReturn=[];
        end
        if strcmp(CheckObj.CallbackStyle,'StyleThree')
            if~isempty(ExecFunctionReturn)

                if~iscell(ExecFunctionReturn)
                    if isnumeric(ExecFunctionReturn)
                        ExecFunctionReturn=num2cell(ExecFunctionReturn);
                    elseif ischar(ExecFunctionReturn)
                        tmpExecFunctionReturn{1}=ExecFunctionReturn;
                        ExecFunctionReturn=tmpExecFunctionReturn;
                    else
                        DAStudio.error('Simulink:tools:MAUnsupportDataType');
                    end
                    ResultHandles{resultCounter}=ExecFunctionReturn;
                    CheckObj.Result{2}=ResultHandles;
                end

                startPos=savefoundObjects(CheckObj,ExecFunctionReturn);

                tempBuf='';
                for ReturnCounter=1:length(ExecFunctionReturn)
                    tempBuf=[tempBuf,'<p />',this.getHiliteHyperlink(startPos+ReturnCounter,recordCounter,CheckObj)];%#ok<AGROW>
                    if autoConvertProjectResultData

                        this.setCheckResultMap(ExecFunctionReturn{ReturnCounter});
                    end
                end
                ExecFunctionReturn=tempBuf;
                if CheckObj.PushToModelExplorer






                    currentResult=ModelAdvisor.ListViewParameter;
                    currentResult.Name=[DAStudio.message('Simulink:tools:MAResult'),' ',num2str(resultCounter)];
                    currentResult.Data=loc_convertToListViewData(CheckObj.Result{2}{resultCounter});
                    currentResult.Attributes=CheckObj.PushToModelExplorerProperties;
                    CheckObj.setListViewParameters(...
                    [CheckObj.getListViewParameters,{currentResult}]);
                end
            end
        end
        htmlOut=[htmlOut,'<p />',modeladvisorprivate('modeladvisorutil2','emitHTMLforMAElements',ResultDescription{resultCounter})];%#ok<AGROW>
        if~isempty(ExecFunctionReturn)
            if iscell(ExecFunctionReturn)
                htmlOut=[htmlOut,'<p />',modeladvisorprivate('modeladvisorutil2','emitHTMLforMAElements',ExecFunctionReturn{:})];%#ok<AGROW>
            else
                htmlOut=[htmlOut,'<p />',modeladvisorprivate('modeladvisorutil2','emitHTMLforMAElements',ExecFunctionReturn)];%#ok<AGROW>
            end
        end
    end




    if strcmp(CheckObj.CallbackContext,'CGIR')
        if addCGIRRefMdlMsg
            htmlOut=[htmlOut,DAStudio.message('ModelAdvisor:engine:CGIRChecksNoteRefMdlBuild')];
        elseif~strcmp(bdroot(this.System),this.System)
            htmlOut=[DAStudio.message('ModelAdvisor:engine:CGIRChecksNoteRootModel'),htmlOut];
        end
    end

    if modeladvisorprivate('modeladvisorutil2','FeatureControl','EmitInputParameter')&&this.EmitInputParametersToReport

        htmlOut=[htmlOut,modeladvisorprivate('modeladvisorutil2','emitInputParameter',CheckObj)];
    end



    if this.ShowExclusions
        htmlOut=[htmlOut,generateExclusionReporting(this)];
    end

    div_start=modeladvisorprivate('modeladvisorutil2','CreateIgnorePortion','<div class="subsection">');
    div_end=modeladvisorprivate('modeladvisorutil2','CreateIgnorePortion','</div>');

    htmlOut=[div_start,htmlOut,div_end];
end

function htmlOut=generateExclusionReporting(this)
    htmlOut='';

    if slfeature('ExclusionEditorWebUI')==1&&...
        ~strcmp(this.CustomTARootID,'com.mathworks.Simulink.CloneDetection.CloneDetection')

        htmlOut=slcheck.generateExclusionReport(this);

        htmlOut=[htmlOut,slcheck.generateJustificationReport(this)];

        return;
    end

    exclusions=ModelAdvisor.getExclusions(this.ActiveCheck.ID,this);

    tableRows=0;
    if~isempty(exclusions)
        exclusionCount=this.ActiveCheck.exclusionIndex;
        this.ActiveCheck.exclusionIndex={};
        mdlExclusionsExist=false;
        for e=1:length(exclusions)
            if strcmpi(exclusions(e).Factory,'off')
                mdlExclusionsExist=true;
                break;
            end
        end

        if~isempty(exclusionCount)
            for e=1:length(exclusions)
                if exclusionCount{e}~=0&&strcmpi(exclusions(e).Factory,'off')
                    tableRows=tableRows+1;
                end

            end
        end
        if~strcmp(this.CustomTARootID,'com.mathworks.Simulink.CloneDetection.CloneDetection')

            if tableRows~=0
                rowNumber=0;
                exclusionInfo=ModelAdvisor.Table(tableRows,2);
                exclusionInfo.setColHeading(1,DAStudio.message('ModelAdvisor:engine:ExclusionRationale'));
                exclusionInfo.setColHeading(2,DAStudio.message('ModelAdvisor:engine:ExclusionUsageCount'));
                for e=1:length(exclusions)
                    if exclusionCount{e}~=0&&strcmpi(exclusions(e).Factory,'off')
                        rowNumber=rowNumber+1;
                        rationale=exclusions(e).Rationale;
                        exclusionInfo.setEntry(rowNumber,1,rationale);
                        exclusionInfo.setEntry(rowNumber,2,[num2str(exclusionCount{e})]);
                    end
                end
                if~isempty(exclusionInfo)
                    htmlOut=[htmlOut,'<H5>',DAStudio.message('ModelAdvisor:engine:CheckExclusionRules'),'</H5>',exclusionInfo.emitHTML];
                end
            else
                htmlOut=[htmlOut,'<H5>',DAStudio.message('ModelAdvisor:engine:CheckExclusionRules'),'</H5>'];
                if~this.ActiveCheck.SupportExclusion&&mdlExclusionsExist
                    htmlOut=[htmlOut,'<b>',DAStudio.message('ModelAdvisor:engine:CheckNotSupportedExclusion'),'</b><br/>'];
                elseif mdlExclusionsExist
                    htmlOut=[htmlOut,DAStudio.message('ModelAdvisor:engine:NoExclusionsApplied'),'<br/>'];
                end
            end
        end
    end
end



function startPos=savefoundObjects(checkObj,foundObjects)
    FOUND_OBJECTS=checkObj.FoundObjects;
    startPos=length(FOUND_OBJECTS);
    if~ischar(foundObjects)
        if iscell(foundObjects)
            for i=1:length(foundObjects)
                FOUND_OBJECTS=pushFOUND_OBJECTS(FOUND_OBJECTS,startPos+i,foundObjects{i});
            end
        else
            for i=1:length(foundObjects)
                FOUND_OBJECTS=pushFOUND_OBJECTS(FOUND_OBJECTS,startPos+i,foundObjects(i));
            end
        end
    else
        FOUND_OBJECTS(startPos+1).handle=get_param(foundObjects,'handle');
        FOUND_OBJECTS(startPos+1).fullname=getfullname(foundObjects);
        FOUND_OBJECTS(startPos+1).name=get_param(foundObjects,'name');
        FOUND_OBJECTS(startPos+1).SID=Simulink.ID.getSID(foundObjects);
    end
    checkObj.FoundObjects=FOUND_OBJECTS;
end

function FOUND_OBJECTS=pushFOUND_OBJECTS(FOUND_OBJECTS,position,foundObject)
    if isa(foundObject,'Stateflow.Object')
        FOUND_OBJECTS(position).handle=foundObject;
        if isprop(foundObject,'Name')
            FOUND_OBJECTS(position).fullname=[foundObject.Path,'/',foundObject.Name];
            FOUND_OBJECTS(position).name=foundObject.Name;
        else
            FOUND_OBJECTS(position).fullname=[foundObject.Path,'/',Simulink.ID.getSID(foundObject)];
            FOUND_OBJECTS(position).name=foundObject.Path;
        end
    else
        FOUND_OBJECTS(position).handle=get_param(foundObject,'handle');
        FOUND_OBJECTS(position).fullname=getfullname(foundObject);
        FOUND_OBJECTS(position).name=get_param(foundObject,'name');
    end
    FOUND_OBJECTS(position).SID=Simulink.ID.getSID(foundObject);
end


function cacheObj=loc_convertToListViewData(showobjects)
    try
        if isnumeric(showobjects)
            showobjects=num2cell(showobjects);
        end
        cacheObj=[];
        for i=1:length(showobjects)
            cacheObj=[cacheObj,get_param(showobjects{i},'object')];%#ok<AGROW>
        end
        showobjects=cacheObj;
        if~isa(showobjects,'DAStudio.Object')&&~isa(showobjects,'Simulink.DABaseObject')
            MSLDiagnostic('ModelAdvisor:engine:UnSupportObjforME').reportAsWarning;
            return
        end
    catch E
        disp(E.message);
        MSLDiagnostic('ModelAdvisor:engine:UnSupportObjforME').reportAsWarning;
        return;
    end
end
