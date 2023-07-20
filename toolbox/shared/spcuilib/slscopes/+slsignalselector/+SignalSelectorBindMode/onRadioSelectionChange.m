function success=onRadioSelectionChange(this,dropDownValue,~,~,bindableMetaData,isChecked)













    success=false;


    if(strcmp(get_param(bdroot(this.sourceElementHandle),'SimulationStatus'),'running'))
        MSLDiagnostic('Simulink:blocks:SigSelectionNADuringSim').reportAsWarning;
        return
    end
    try

        inSF=0;



        if~isfield(bindableMetaData,'blockPathStr')
            stateHandle=Simulink.ID.getHandle(bindableMetaData.sid);
            if isprop(stateHandle,'Chart')
                bindableMetaData.blockPathStr=stateHandle.Chart.Path;
            else
                bindableMetaData.blockPathStr=stateHandle.Path;
            end
            inSF=1;
        end


        isValidHandle=getSimulinkBlockHandle(bindableMetaData.blockPathStr);


        if isValidHandle==-1
            if strfind(bindableMetaData.blockPathStr,'StateflowChart')
                portHandle=get_param(bindableMetaData.hierarchicalPathArr{end-1},'Handle');
                inSF=1;
            else





                bindableMetaData.blockPathStr=erase(bindableMetaData.blockPathStr,['/',bindableMetaData.name,':o1']);
                portHandle=get_param(bindableMetaData.blockPathStr,'Handle');




                isStateflow=strcmp(slsignalselector.utils.SignalSelectorUtilities....
                determineBlockType(portHandle),'Stateflow');
                if isStateflow
                    inSF=1;
                else
                    success=0;
                    return;
                end
            end
        elseif inSF


            portHandle=get_param(bindableMetaData.blockPathStr,'Handle');
        else


            port=get_param(bindableMetaData.blockPathStr,'PortHandles');

            if(bindableMetaData.outputPortNumber>length(port.Outport))
                if~isempty(port.State)
                    portHandle=port.State(1);
                else
                    portHandle=-1;
                end
            else
                portHandle=port.Outport(bindableMetaData.outputPortNumber);
            end
        end

        inModelRef=slsignalselector.utils.SignalSelectorUtilities.i_IsObjectInsideModelRef(this.sourceElementHandle,portHandle);

        if inModelRef

            encPath=signalMetaData.hierarchicalPathArr{1};
            hierarchicalPath=erase(encPath,'~');




            modelRefBlock=strtrim(signalMetaData.hierarchicalPathArr{end-1});
            modelName=strtok(modelRefBlock,'/');
            if~bdIsLoaded(modelName)
                try


                    load_system(modelName)
                catch
                    DAStudio.error('Simulink:blocks:ModelNotFound',modelName);
                end
            end
            PortsAndBlocks=get_param(modelRefBlock,'Handle');

            if inSF
                [~,relPath,ParentMdlBlkHandle,portHandle,~]=slsignalselector.utils.SignalSelectorUtilities....
                getSFSignalData(portHandle,1,hierarchicalPath,bindableMetaData.hierarchicalPathArr{end});
            else
                [relPath,ParentMdlBlkHandle,portHandle]=slsignalselector.utils.SignalSelectorUtilities....
                getRelativePath(hierarchicalPath,portHandle,PortsAndBlocks);
            end
        else
            relPath='';
            ParentMdlBlkHandle=-1;

            if inSF



                signalMetaData.blockPathStr=['StateflowChart/',stateHandle.LoggingInfo.LoggingName,':o1'];
                [~,relPath,~,~,~]=slsignalselector.utils.SignalSelectorUtilities.getSFSignalData(portHandle,0,'',signalMetaData.blockPathStr);
            end

        end

        if(isChecked==1)
            inputNumber=find(strcmp(this.dropDownElements,dropDownValue));

            slsignalselector.utils.SignalSelectorUtilities.switchSelection(this.sourceElementHandle,...
            inputNumber,[],portHandle,relPath,ParentMdlBlkHandle,this.UpdateCallback)

            success=1;


            isViewer=strcmp(get_param(this.sourceElementHandle,'IOType'),'viewer');
            if isViewer
                slsignalselector.SignalSelectorBindMode.updateWebScopeViewerTitle(this.sourceElementHandle);
            end
        end
    catch ex
        success.error=true;
        if isa(ex,'MException')
            success.faultMessage=ex.message;
        end
    end
end
