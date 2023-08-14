classdef BlockEditTimeMissingParams<edittime.Violation
    methods(Static)
        function strRep=getWSStringForError(wsName)
            switch wsName
            case 'base workspace'
                strRep=DAStudio.message('SLDD:sldd:BaseWorkspace');
            case 'model workspace'
                strRep=DAStudio.message('SLDD:sldd:ModelWorkspace');
            otherwise
                strRep=wsName;
            end
        end


        function out=getDiagnosticJSON(system,blkHandle,checkID)
            obj=edittime.violations.BlockEditTimeMissingParams(system,blkHandle,checkID);
            out=obj.getJSON.json;
            out=out{1};
        end
    end

    methods
        function self=BlockEditTimeMissingParams(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic(system,blkHandle);
            self.setType(ModelAdvisor.CheckStatus.Failed);
        end

        function issueSummary=getIssueSummary(obj)
            issueSummary=DAStudio.message('Simulink:dialog:BlockEditTimeNotification_UnrecognizedFunctionsOrVariables');
        end

        function createDiagnostic(obj,system,blkhandle)
            blockEditTime=Simulink.BlockEditTimeController.getInstance();
            [vars,propNames]=blockEditTime.findAllMissingVariables(blkhandle,system);
            diag=MSLDiagnostic.empty();
            if isempty(vars)
                diag=MSLDiagnostic(blkhandle,message('Simulink:dialog:BlockEditTimeCheck_InitFcnNotEmpty',system));
                if(isequal(1,slfeature('ShowMissingVarsAtEditTime'))||isequal(3,slfeature('ShowMissingVarsAtEditTime')))
                    isInitFcnEmpty=isempty(get_param(system,'InitFcn'));
                    if isInitFcnEmpty
                        diag=MSLDiagnostic(blkhandle,message('Simulink:dialog:BlockEditTimeCheck_RefreshChecksForMissingVariables',system));
                    end
                end
            else
                vars=unique(vars,'stable');
                for i=1:length(vars)
                    variableName=vars{i};
                    propName=propNames{i};
                    blkCtrlr=Simulink.BlockEditTimeController.getInstance();
                    ddName=get_param(system,'DataDictionary');
                    hasDD=~isempty(ddName);
                    hasBWS=false;
                    blkObj=get_param(blkhandle,'Object');
                    blkPath=blkObj.getFullName;
                    blkPath=strrep(blkPath,newline,' ');
                    if slfeature('SLModelAllowedBaseWorkspaceAccess')>0
                        try
                            hasBWS=strcmp(get_param(system,'HasAccessToBaseWorkspace'),'on');
                        catch E


                            if strcmp(E.identifier,'SLDD:sldd:DictionaryNotFound')
                                diag=MSLDiagnostic(blkhandle,message('SLDD:sldd:DictionaryNotFound',ddName));
                                break;
                            end
                        end
                    else
                        if(hasDD)
                            ddConn=Simulink.dd.open(ddName);
                            hasBWS=ddConn.HasAccessToBaseWorkspace;
                        end
                    end
                    if(~hasDD||hasBWS)
                        diag(i)=MSLDiagnostic(blkhandle,message('SLDD:sldd:VarMissingBase',variableName,system,'','normal',propName,blkPath,' '));
                    else
                        diag(i)=MSLDiagnostic(blkhandle,message('SLDD:sldd:VarMissing',variableName,system,'','normal',propName,blkPath,' '));
                    end
                    [varCacheName,wsName]=blkCtrlr.getVarCacheInfo(variableName,system);
                    if~isempty(varCacheName)&&~isempty(wsName)
                        if~isequal(variableName,varCacheName)
                            if~isempty(ddName)
                                diag(i)=MSLDiagnostic(blkhandle,message('SLDD:sldd:VarRenamedUpdateRef',variableName,varCacheName,wsName,propName,blkPath,'normal',system));
                            end
                        else


                            wsNameDisplayed=edittime.violations.BlockEditTimeMissingParams.getWSStringForError(wsName);
                            diag(i)=MSLDiagnostic(blkhandle,message('SLDD:sldd:VarDeleted',varCacheName,wsName,system,'normal',wsNameDisplayed,propName,blkPath,' '));
                        end
                    end
                end
            end
            obj.diagnostic=diag;
        end

        function size=addToPopupSize(obj)
            size=[0,length(obj.diagnostic)*60];
        end

    end
end
