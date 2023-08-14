classdef ToolStripPopups


    methods(Static)





        function gw=generateAvailableContextModelsPopupList(opType,cbinfo)
            gw=dig.GeneratedWidget(cbinfo.EventData.namespace,cbinfo.EventData.type);


            switch opType
            case 'observeSignals'
                header=gw.Widget.addChild('PopupListHeader','observeSignalsHeader');
                header.Label='simulinktest:toolstrip:observeSignalsHeaderText';
            case 'sendBlockToObserver'
                header=gw.Widget.addChild('PopupListHeader','sendBlockToObserverHeader');
                header.Label='simulinktest:toolstrip:sendBlockToObserverHeaderText';
            otherwise
                return;
            end


            switch opType
            case{'observeSignals','sendBlockToObserver'}
                obsMdlList=Simulink.observer.internal.getAvailableObserversForArea(cbinfo.model.Handle);
                sltest.internal.menus.ToolStripPopups.createNewObserverItem(gw,opType);
                for j=1:numel(obsMdlList)
                    sltest.internal.menus.ToolStripPopups.createExistingObserverItem(gw,obsMdlList(j),opType,j);
                end
            otherwise
                return;
            end
        end


        function gw=generateAssociatedCoSimPortsPopupList(opType,cbinfo)
            import sltest.internal.menus.getObserverPortBlocks;
            gw=dig.GeneratedWidget(cbinfo.EventData.namespace,cbinfo.EventData.type);

            switch opType
            case 'gotoObserverPort'

                header=gw.Widget.addChild('PopupListHeader','gotoObserverPortHeader');
                header.Label='simulinktest:toolstrip:gotoObserverPortHeaderText';


                obsPrtBlks=getObserverPortBlocks(cbinfo.getSelection,cbinfo.model.Name);
                if isempty(obsPrtBlks)
                    sltest.internal.menus.ToolStripPopups.createNoCoSimPortItem(gw,opType);
                else
                    for j=1:size(obsPrtBlks,1)
                        obsRefH=obsPrtBlks{j,1};
                        [mdlName,blkSID,blkH]=Simulink.sltblkmap.internal.getBlockFromMapElemStr(obsPrtBlks{j,2});
                        if blkH~=-1
                            obsPrtName=strrep(getfullname(blkH),newline,' ');
                            sltest.internal.menus.ToolStripPopups.createLoadedCoSimPortItem(gw,obsRefH,obsPrtName,opType,j);
                        else
                            sltest.internal.menus.ToolStripPopups.createUnloadedCoSimPortItem(gw,obsRefH,mdlName,blkSID,opType,j);
                        end
                    end
                end
            end
        end
    end

    methods(Static,Access=private)
        function createNewObserverItem(gw,opType)

            actionName=[opType,'NewObserverAction'];
            action=gw.createAction(actionName);
            switch opType
            case 'observeSignals'
                action.text=DAStudio.message('simulinktest:toolstrip:observeSignalsInNewObserverActionText');
                action.description=DAStudio.message('simulinktest:toolstrip:observeSignalsInNewObserverActionDescription');
                action.setCallbackFromArray(@(cbinfo)sltest.internal.menus.Callbacks.ObserveSignalsInNewObserver(cbinfo),dig.model.FunctionType.Action);
            case 'sendBlockToObserver'
                action.text=DAStudio.message('simulinktest:toolstrip:sendBlockToNewObserverActionText');
                action.description=DAStudio.message('simulinktest:toolstrip:sendBlockToNewObserverActionDescription');
                action.setCallbackFromArray(@(cbinfo)sltest.internal.menus.Callbacks.SendBlockToNewObserver(cbinfo),dig.model.FunctionType.Action);
            otherwise
                return;
            end
            action.enabled=true;


            itemName=[opType,'NewObserverItem'];
            item=gw.Widget.addChild('ListItem',itemName);
            item.ActionId=[gw.Namespace,':',actionName];
        end

        function createExistingObserverItem(gw,obsBlkH,opType,idx)

            actionName=[opType,'ExistingObserverAction_',num2str(idx)];
            action=gw.createAction(actionName);
            action.text=get_param(obsBlkH,'ObserverModelName');
            obsPath=strrep(getfullname(obsBlkH),newline,' ');
            switch opType
            case 'observeSignals'
                action.description=DAStudio.message('simulinktest:toolstrip:observeSignalsInExistingObserverActionDescription',obsPath);
                action.setCallbackFromArray(@(cbinfo)sltest.internal.menus.Callbacks.ObserveSignalsInExistingObserver(cbinfo,obsPath),dig.model.FunctionType.Action);
            case 'sendBlockToObserver'
                action.description=DAStudio.message('simulinktest:toolstrip:sendBlockToExistingObserverActionDescription',obsPath);
                action.setCallbackFromArray(@(cbinfo)sltest.internal.menus.Callbacks.SendBlockToExistingObserver(cbinfo,obsPath),dig.model.FunctionType.Action);
            otherwise
                return;
            end
            action.enabled=true;


            itemName=[opType,'ExistingObserverItem_',num2str(idx)];
            item=gw.Widget.addChild('ListItem',itemName);
            item.ActionId=[gw.Namespace,':',actionName];
        end

        function createNoCoSimPortItem(gw,opType)
            actionName=[opType,'NoCoSimPortsAction'];
            action=gw.createAction(actionName);
            action.text=DAStudio.message('simulinktest:toolstrip:gotoObserverPortNoAssociatedPortsLabelText');
            action.description='';
            action.enabled=false;

            itemName=[opType,'NoCoSimPortsItem'];
            item=gw.Widget.addChild('ListItem',itemName);
            item.ActionId=[gw.Namespace,':',actionName];
        end

        function createLoadedCoSimPortItem(gw,obsRefH,obsPrtName,opType,idx)
            actionName=[opType,'LoadedCoSimPortAction_',num2str(idx)];
            action=gw.createAction(actionName);
            action.text=obsPrtName;
            obsRefName=strrep(getfullname(obsRefH),newline,' ');
            switch opType
            case 'gotoObserverPort'
                action.description=DAStudio.message('simulinktest:toolstrip:gotoLoadedObserverPortActionDescription',obsRefName);
                action.setCallbackFromArray(@(cbinfo)sltest.internal.menus.Callbacks.GotoLoadedObserverPort(cbinfo,obsRefH,obsPrtName),dig.model.FunctionType.Action);
            otherwise
                return;
            end
            action.enabled=true;

            itemName=[opType,'LoadedCoSimPortItem_',num2str(idx)];
            item=gw.Widget.addChild('ListItem',itemName);
            item.ActionId=[gw.Namespace,':',actionName];
        end

        function createUnloadedCoSimPortItem(gw,obsRefH,mdlName,blkSID,opType,idx)
            actionName=[opType,'UnloadedCoSimPortAction_',num2str(idx)];
            action=gw.createAction(actionName);
            obsRefName=strrep(getfullname(obsRefH),newline,' ');
            switch opType
            case 'gotoObserverPort'
                action.text=DAStudio.message('simulinktest:toolstrip:gotoUnloadedObserverPortActionText',blkSID);
                action.description=DAStudio.message('simulinktest:toolstrip:gotoUnloadedObserverPortActionDescription',obsRefName);
                action.setCallbackFromArray(@(cbinfo)sltest.internal.menus.Callbacks.GotoUnloadedObserverPort(cbinfo,obsRefH,mdlName,blkSID),dig.model.FunctionType.Action);
            otherwise
                return;
            end
            action.enabled=true;

            itemName=[opType,'UnloadedCoSimPortItem_',num2str(idx)];
            item=gw.Widget.addChild('ListItem',itemName);
            item.ActionId=[gw.Namespace,':',actionName];
        end
    end
end
