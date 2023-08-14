classdef MissingDataStores<edittime.Violation




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
            obj=edittime.violations.MissingDataStores(system,blkHandle,checkID);
            out=obj.getJSON.json;
            out=out{1};
        end

    end

    methods
        function self=MissingDataStores(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic(system,blkHandle);
            self.setType(ModelAdvisor.CheckStatus.Failed);
        end

        function issueSummary=getIssueSummary(obj)
            issueSummary=DAStudio.message('Simulink:dialog:BlockEditTimeNotification_MissingDataStoreName');
        end

        function createDiagnostic(obj,system,blkhandle)
            blockEditTime=Simulink.BlockEditTimeController.getInstance();
            propName='DataStoreName';
            blkPrmValue=get_param(blkhandle,propName);
            isMissingDS=blockEditTime.isMissingDataStore(blkhandle,system,{blkPrmValue});
            if~isMissingDS
                diag=MSLDiagnostic(blkhandle,message('Simulink:dialog:BlockEditTimeCheck_InitFcnNotEmpty',system));
                if(isequal(1,slfeature('ShowMissingVarsAtEditTime'))||isequal(3,slfeature('ShowMissingVarsAtEditTime')))
                    isInitFcnEmpty=isempty(get_param(system,'InitFcn'));
                    if isInitFcnEmpty
                        diag=MSLDiagnostic(blkhandle,message('Simulink:dialog:ResolvedGlobalDataStore',system));
                    end
                end
            else
                vars={blkPrmValue};
                diag=MSLDiagnostic.empty();
                for i=1:length(vars)
                    dataStoreText=vars{i};
                    systemDDs=slprivate('getAllDataDictionaries',system);
                    [varCacheName,wsName]=blockEditTime.getVarCacheInfo(dataStoreText,system);

                    blkObj=get_param(blkhandle,'Object');
                    blkPath=blkObj.getFullName;
                    blkPath=strrep(blkPath,newline,' ');
                    if~isempty(varCacheName)&&~isempty(wsName)
                        if~isequal(dataStoreText,varCacheName)
                            if~isempty(systemDDs)
                                diag(i)=MSLDiagnostic(blkhandle,message('Simulink:DataStores:DSMemoryRenamed',dataStoreText,varCacheName,wsName,propName,blkPath,'normal',system));
                            end
                        else


                            wsNameDisplayed=edittime.violations.BlockEditTimeMissingParams.getWSStringForError(wsName);
                            diag(i)=MSLDiagnostic(blkhandle,message('Simulink:DataStores:DSMemoryDeleted',varCacheName,wsName,system,'normal',wsNameDisplayed,blkPath));
                        end
                    else
                        diag(i)=MSLDiagnostic(blkhandle,message('sledittimecheck:edittimecheck:MissingDataStore',dataStoreText,blkPath));
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
