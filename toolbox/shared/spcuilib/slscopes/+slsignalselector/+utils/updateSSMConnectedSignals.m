function updateSSMConnectedSignals(blockHandle,updateCallback)







    try

        if ishandle(blockHandle)

            if i_LinkedToSignalAndScopeMgr(blockHandle)


                sigandscopemgr('UpdateSelections',blockHandle);

                if~isempty(updateCallback)
                    updateCallback();
                else



                    SSMgrMap=Simulink.scopes.SigScopeMgr.setgetSSM_Map();
                    SsmKey=Simulink.scopes.SigScopeMgr.handleToKey(bdroot(blockHandle));
                    if~isempty(SSMgrMap)&&SSMgrMap.isKey(SsmKey)
                        ssmSource=SSMgrMap(SsmKey);
                        ssmSource.refreshSignalSpreadsheet();
                    else



                        dlgs=DAStudio.ToolRoot.getOpenDialogs;
                        SSMIndex=0;
                        for i=1:numel(dlgs)
                            if strfind(dlgs(i).dialogTag,'SSMgr')
                                SSMIndex=i;
                                break;
                            end
                        end
                        if SSMIndex
                            SSMSource=dlgs(SSMIndex).getDialogSource;
                            SSMSource.refreshSignalSpreadsheet();
                        end
                    end
                end
            end
        end
    catch ME
        ME.message;
    end
end

function out=i_LinkedToSignalAndScopeMgr(block)
    out=~strcmp(get_param(block,'IOType'),'none');
end