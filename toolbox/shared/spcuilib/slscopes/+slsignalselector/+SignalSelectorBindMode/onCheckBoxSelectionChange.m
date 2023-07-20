function result=onCheckBoxSelectionChange(this,dropDownValue,~,~,bindableMetaData,isChecked)

















    try

        activeDisplay=find(strcmp(this.dropDownElements,dropDownValue));


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
                    result=0;
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




        [signalMetaData,inModelRef]=getSignalMetaData(this.sourceElementHandle,portHandle,bindableMetaData);

        if inModelRef



            encPath=signalMetaData.hierarchicalPathArr{1};

            hierarchicalPath=encPath;




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
                getSFSignalData(portHandle,1,hierarchicalPath,bindableMetaData.hierarchicalPathArr{end},signalMetaData);
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

        if isChecked
            slsignalselector.utils.SignalSelectorUtilities.addSelection(this.sourceElementHandle,...
            activeDisplay,portHandle,relPath,ParentMdlBlkHandle)
            result=1;
        else
            result=slsignalselector.utils.SignalSelectorUtilities.removeSelection(this.sourceElementHandle,...
            activeDisplay,portHandle,relPath,ParentMdlBlkHandle);
        end


        viewerMask=Simulink.Mask.get(this.sourceElementHandle);
        isMPlay=~isempty(viewerMask)&&contains(viewerMask.Type,'MPlay');
        if isMPlay



            MPlayIO.mplayinst(this.sourceElementHandle,true);
        end


        isViewer=strcmp(get_param(this.sourceElementHandle,'IOType'),'viewer');
        if isViewer
            slsignalselector.SignalSelectorBindMode.updateWebScopeViewerTitle(this.sourceElementHandle);
        end

    catch ex
        result.error=true;
        if isa(ex,'MException')
            result.faultMessage=ex.message;
        end
    end
end

function[signalMetaData,inModelRef]=getSignalMetaData(SourceBlockHandle,selectionHandles,bindableMetaData)

    [~,modelRefBlockIndex]=slsignalselector.utils.SignalSelectorUtilities.hasSelectionModelRef(selectionHandles);

    if~isempty(modelRefBlockIndex)

        selectionHandles=selectionHandles(~modelRefBlockIndex);
    end

    inModelRef=slsignalselector.utils.SignalSelectorUtilities.i_IsObjectInsideModelRef(SourceBlockHandle,selectionHandles);



    if~isempty(bindableMetaData.hierarchicalPathArr)
        signalMetaData=bindableMetaData;
    else
        if inModelRef
            selectionRows=BindMode.utils.getSignalRowsInSelection(selectionHandles,inModelRef);
        else

            selectionRows=BindMode.utils.getSignalRowsInSelection(selectionHandles);
        end
        signalMetaData=selectionRows{1}.bindableMetaData;
    end


end
