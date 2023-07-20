classdef blkEditTimeCheck<handle















    properties
        mBlkHandle;
        mMdlName;
        mVarName={};
        mPos=[];
        origPosition=[];
        mPropname={};
        mPropList={};
        mClose=[];
        positionFlag=false;
        mClassSuggestion='Default';
    end

    methods(Access=public)

        function id=getID(obj)
            id=[obj.mMdlName,'_',num2str(obj.mBlkHandle),'_',obj.mPropname{1}];
        end

        function obj=blkEditTimeCheck(mdlName,blockFullName,propName,varargin)





            obj.setDialogDetails(mdlName,blockFullName);
            if(nargin==2)
                return;
            end
            if(nargin==3)

                blkPrmValue=get_param(obj.mBlkHandle,propName);
                blkCtrlr=Simulink.BlockEditTimeController.getInstance();
                dsmNotFound=blkCtrlr.isMissingDataStore(obj.mBlkHandle,obj.mMdlName,{blkPrmValue});
                obj.mPropname{end+1}=propName;
                if(dsmNotFound)
                    obj.mVarName{end+1}=blkPrmValue;
                end
            elseif(nargin>2)
                assert(nargin==5||nargin==6);
                varList=varargin{1};
                pos=varargin{2};
                obj.mPos=pos;
                if(~isempty(propName)&&~isempty(varList))
                    populateVariableAndPropName(obj,propName,varList);
                else

                    blockEditTime=Simulink.BlockEditTimeController.getInstance();
                    [vars,propNames]=blockEditTime.findAllMissingVariables(obj.mBlkHandle,obj.mMdlName);
                    if isempty(vars)
                        blkEditTimeCheck.openDialogsRefresh(obj.mBlkHandle);
                    else
                        obj.mVarName=vars;
                        obj.mPropList=propNames;
                    end
                end
                if(nargin==6)
                    obj.mClassSuggestion=varargin{3};
                end
            end
        end

        function populateVariableAndPropName(this,propName,varList)
            this.mVarName{end+1}=unique(varList,'stable');
            this.mPropname{end+1}=propName;
        end

        function diagnostics=getDiagnostics(obj)
            diagnostics=getMissingVariableDiagnostic(obj);
        end

        function updateBadges(obj,action)
            if strcmp(action.EventData.Result,'Success')
                blkEditTimeCheck.refreshEditTimeNotifications(obj);
            end
        end
    end

    methods(Hidden,Static)

        function diag=getDiagnosticFromTestAPI(mdlName,blkHandle,blkSrc,textToParse,propName)
            assert(nargin==5);
            dlgSrc=blkSrc;

            if Simulink.ID.isValid(blkHandle)
                blkHandle=get_param(blkHandle,'Handle');
            elseif ischar(blkHandle)
                blkHandle=str2double(blkHandle);
            end
            obj=blkEditTimeCheck(mdlName,blkHandle,propName);
            if isempty(textToParse)
                obj.mVarName='';
            else
                if isa(dlgSrc.getDialogSource,'Simulink.SLDialogSource')
                    var_name=dlgSrc.findMissingVariables(textToParse,propName);
                else
                    var_name=textToParse;
                end
                if~iscell(var_name)
                    var_name={var_name};
                end
                obj.mVarName={unique(var_name,'stable')};
            end
            diag=obj.getMissingVariableDiagnostic();
        end

        function diag=getDiagnosticForSignalName(mdlName,blkHandle,blkSrc,textToParse,propName)

            assert(nargin==5);
            dlgSrc=blkSrc;
            if isa(dlgSrc.getDialogSource,'Simulink.SLDialogSource')
                var_name=dlgSrc.findMissingVariables(textToParse,propName);
            else
                var_name=textToParse;
            end
            if~iscell(var_name)
                vars={var_name};
            else
                vars=var_name;
            end

            if Simulink.ID.isValid(blkHandle)
                blkHandle=get_param(blkHandle,'Handle');
            elseif ischar(blkHandle)
                blkHandle=str2double(blkHandle);
            end
            varName=unique(vars,'stable');
            obj=blkEditTimeCheck(mdlName,blkHandle,propName,varName,[100,100]);
            diag=obj.getMissingVariableDiagnostic();
        end

    end

    methods(Static)
        function obj=createBlkEditTimeForDataStore(dlgSrc,propName)
            obj=blkEditTimeCheck(dlgSrc,propName);
        end

        function refreshEditTimeNotifications(obj)
            blkEditTimeCheck.openDialogsRefresh(obj.mBlkHandle);
            blkEditTimeCheck.openCanvasRefresh(obj.mMdlName);
        end

        function openDialogsRefresh(blkHandle)
            srcObj=get_param(blkHandle,'Object');
            dlgSrc=srcObj.getDialogSource;
            if isa(srcObj,'Simulink.Port')&&(srcObj.Line~=-1)
                tempSrc=get_param(srcObj.Line,'Object');
                dlgSrc=tempSrc.getLine;
                if~isempty(dlgSrc)

                    ed=DAStudio.EventDispatcher;
                    ed.broadcastEvent('PropertyChangedEvent',dlgSrc);
                    openDlgs=DAStudio.ToolRoot.getOpenDialogs(dlgSrc);
                    if isempty(openDlgs)

                        openDlgs=DAStudio.ToolRoot.getOpenDialogs(srcObj);
                    end
                end
            else
                openDlgs=DAStudio.ToolRoot.getOpenDialogs(dlgSrc);
            end
            for i=1:length(openDlgs)
                openDlgs(i).refresh;
            end
        end

        function openCanvasRefresh(mdlName)

            EditTimeEngine=edittimecheck.EditTimeEngine.getInstance();
            EditTimeEngine.refreshWorkspaceChecks(mdlName);
        end
    end

    methods(Access=private)

        function setDialogDetails(this,mdlName,blockFullName)
            this.mBlkHandle=get_param(blockFullName,'Handle');
            this.mMdlName=mdlName;
        end

        function diag=getMissingVariableDiagnostic(obj)
            diag=MSLDiagnostic.empty();
            if isempty(obj.mVarName)
                diag=MSLDiagnostic(obj.mBlkHandle,message('Simulink:dialog:BlockEditTimeCheck_InitFcnNotEmpty',obj.mMdlName));
                if(isequal(1,slfeature('ShowMissingVarsAtEditTime'))||isequal(3,slfeature('ShowMissingVarsAtEditTime')))
                    isInitFcnEmpty=isempty(get_param(obj.mMdlName,'InitFcn'));
                    if isInitFcnEmpty
                        diag=MSLDiagnostic(obj.mBlkHandle,message('Simulink:dialog:BlockEditTimeCheck_RefreshChecksForMissingVariables',obj.mMdlName));
                    end
                end
            else
                varMap=containers.Map;
                if~isempty(obj.mPropname)
                    for j=1:length(obj.mPropname)
                        for i=1:length(obj.mVarName{j})
                            value=keys(varMap);
                            if(isempty(value))||(isempty(find(cellfun(@(x)any(strcmp(x,obj.mVarName{j}{i})),value),1)))
                                varMap(obj.mVarName{j}{i})=obj.mPropname{j};
                            end
                        end
                    end
                end
                vars=keys(varMap);
                for i=1:length(vars)
                    variableName=vars{i};
                    propName=varMap(vars{i});
                    blkCtrlr=Simulink.BlockEditTimeController.getInstance();
                    ddName=get_param(obj.mMdlName,'DataDictionary');
                    hasDD=~isempty(ddName);
                    hasBWS=false;
                    blkObj=get_param(obj.mBlkHandle,'Object');
                    blkPath=blkObj.getFullName;
                    blkPath=strrep(blkPath,newline,' ');
                    if slfeature('SLModelAllowedBaseWorkspaceAccess')>0
                        hasBWS=strcmp(get_param(obj.mMdlName,'HasAccessToBaseWorkspace'),'on');
                    else
                        if(hasDD)
                            ddConn=Simulink.dd.open(ddName);
                            hasBWS=ddConn.HasAccessToBaseWorkspace;
                        end
                    end
                    if(~hasDD||hasBWS)
                        diag(i)=MSLDiagnostic(obj.mBlkHandle,message('SLDD:sldd:VarMissingBase',variableName,obj.mMdlName,'','normal',propName,blkPath,' '));
                    else
                        diag(i)=MSLDiagnostic(obj.mBlkHandle,message('SLDD:sldd:VarMissing',variableName,obj.mMdlName,'','normal',propName,blkPath,' '));
                    end
                    [varCacheName,wsName]=blkCtrlr.getVarCacheInfo(variableName,obj.mMdlName);
                    if~isempty(varCacheName)&&~isempty(wsName)
                        if~isequal(variableName,varCacheName)
                            if~isempty(ddName)
                                diag(i)=MSLDiagnostic(obj.mBlkHandle,message('SLDD:sldd:VarRenamedUpdateRef',variableName,varCacheName,wsName,propName,blkPath,'normal',obj.mMdlName));
                            end
                        else


                            wsNameDisplayed=edittime.violations.BlockEditTimeMissingParams.getWSStringForError(wsName);
                            diag(i)=MSLDiagnostic(obj.mBlkHandle,message('SLDD:sldd:VarDeleted',varCacheName,wsName,obj.mMdlName,'normal',wsNameDisplayed,propName,blkPath,' '));
                        end
                    end
                end

            end
        end

    end

end
