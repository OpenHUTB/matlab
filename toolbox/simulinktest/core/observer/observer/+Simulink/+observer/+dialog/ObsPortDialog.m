classdef(Sealed)ObsPortDialog<handle


    properties(SetAccess=private)
        model;
        obsH;
        SID;
        channelPath;
        channelSub;
        url;
        dialog;
        listeners;
        selectedBlock;
        curHighlighted;
    end













    methods(Access=private)


        function this=ObsPortDialog()

            this.model=-1;
            this.dialog=-1;
            this.selectedBlock=-1;
            this.listeners=struct;
        end


        function createDDGDialog(this,obsH)





            this.obsH=obsH;

            connector.ensureServiceOn();


            if this.isDebug()
                fileName='index-debug.html';
            else
                fileName='index.html';
            end
            this.url=sprintf('/toolbox/simulinktest/core/observer/html/%s?portUUID=%s',fileName,this.SID);
            this.url=connector.getUrl(this.url);
            if this.isDebug()
                log(['URL: ',this.url]);
            end


            this.dialog=DAStudio.Dialog(this);
        end

        function checkMdlCompileLockStatus(this)
            obsMdl=get_param(this.obsH,'ObserverModelName');
            if~strcmp(get_param(this.model,'SimulationStatus'),'stopped')
                DAStudio.error('Simulink:Observer:CannotEditObserverPortsInDesignCompile',getfullname(this.obsH),getfullname(this.model));
            elseif~strcmp(get_param(obsMdl,'SimulationStatus'),'stopped')
                DAStudio.error('Simulink:Observer:CannotEditObserverPortsInObserverCompile',getfullname(this.obsH),obsMdl);
            else
                editor=SLM3I.SLDomain.getLastActiveEditorFor(get_param(obsMdl,'Handle'));
                if~isempty(editor)&&editor.isLocked
                    DAStudio.error('Simulink:Observer:CannotEditObserverPortsWhenObserverLocked',getfullname(this.obsH),obsMdl);
                end
            end
        end

        function ret=getObservableAreaHierarchy(~,obsH)
            ret=Simulink.observer.internal.getObservableAreaHierarchy(obsH);
        end

        function ret=getObserverHierarchy(~,obsH)
            ret=Simulink.observer.internal.getObserverHierarchy(obsH);
        end

        function[blks,type,spec,filterStr]=getObservedSignal(~,obsPrtBlkH)
            blks=Simulink.observer.internal.getObservedBlockChainForceLoad(obsPrtBlkH);
            if isempty(blks)
                blks=-1;
                type='Unknown';
                spec='';
                filterStr='';
                return;
            end
            elemType=Simulink.observer.internal.getObservedEntityType(obsPrtBlkH);
            switch elemType
            case 'Outport'
                type='Outport';
                spec=num2str(Simulink.observer.internal.getObservedPortIndex(obsPrtBlkH)+1);
                filterStr=['Outport',spec];
            case 'SFState'
                actType=Simulink.observer.internal.getObservedStateActivityType(obsPrtBlkH);
                sfObj=Simulink.observer.internal.getObservedSFObj(obsPrtBlkH);
                sfHdl=idToHandle(sfroot,str2double(sfObj.ID));
                if~(isa(sfHdl,'Stateflow.Chart')||isa(sfHdl,'Stateflow.ReactiveTestingTableChart')...
                    ||isa(sfHdl,'Stateflow.StateTransitionTableChart')||isa(sfHdl,'Stateflow.TruthTableChart'))...
                    ||sfprivate('get_state_for_atomic_subchart',sfHdl.Id)~=0
                    blks=[blks(1:end-1),str2double(sfObj.ID)];
                end
                switch actType
                case 'Self'
                    type='SFStateSelf';
                    filterStr='Self activity';
                case 'Child'
                    type='SFStateChild';
                    filterStr='Child activity';
                case 'Leaf'
                    type='SFStateLeaf';
                    filterStr='Leaf state activity';
                end
                spec=sfObj.ID;
            case 'SFData'
                sfObj=Simulink.observer.internal.getObservedSFObj(obsPrtBlkH);
                switch sfObj.SFDataType
                case 'Local'
                    type='SFData';
                case 'Parameter'
                    type='SFParam';
                otherwise
                    type='';
                end
                stateId=sfprivate('get_state_for_atomic_subchart',sfprivate('block2chart',sfObj.ChartBlk));
                if stateId~=0
                    blks=[blks(1:end-1),stateId];
                end
                spec=sfObj.ID;
                filterStr=sfObj.Name;
            end
        end

        function[blkH,elemType,spec,filterStr]=findConnectedOutport(~,prtH)
            blkH=-1;
            elemType='Outport';
            spec='1';
            linH=get_param(prtH,'Line');
            if linH~=-1
                srcPrtH=get_param(linH,'SrcPortHandle');
            else
                srcPrtH=-1;
            end
            if srcPrtH~=-1
                blkH=get_param(get_param(srcPrtH,'Parent'),'Handle');
                spec=num2str(get_param(srcPrtH,'PortNumber'));
                filterStr=['Outport',spec];
            end
        end

        function pathStruct=getFullPathFromBlocks(this,signals)
            blocks=signals.blocks;
            elemType=signals.types{1};
            [blocks,ssid,actType]=this.reformatPathForSF(elemType,blocks,signals.specs{1});
            pathStruct.ssid=ssid;
            pathStruct.actType=actType;

            fullPath=string(getfullname(blocks)).join('|').replace(newline,' ').char;
            pathStruct.path=fullPath;
        end

        function traceToSource(this,signals)
            switch signals.types{1}
            case 'Outport'
                handles=signals.blocks;
                portIdx=signals.specs{1};
                blkH=handles(end);
                portHandles=get_param(blkH,'PortHandles');
                linH=get_param(portHandles.Outport(str2double(portIdx)),'Line');
                if linH~=-1
                    hdls=[blkH,linH];
                else
                    hdls=blkH;
                end
                SLStudio.HighlightSignal.removeHighlighting(get_param(this.model,'Handle'));
                SLStudio.HighlightSignal.removeHighlighting(bdroot(blkH));
                SLStudio.EmphasisStyleSheet.applyStyler(bdroot(blkH),hdls);
                sys=get_param(blkH,'parent');
                if~strcmp(get_param(sys,'open'),'on')
                    open_system(sys,'force','window');
                else
                    open_system(sys);
                end
            case{'SFStateSelf','SFStateChild','SFStateLeaf'}
                sfId=signals.blocks(end);
                Simulink.observer.internal.highlightObservedSFState(sfId);
            case{'SFData','SFParam'}

                handles=signals.blocks;
                blkH=handles(end);
                SLStudio.HighlightSignal.removeHighlighting(get_param(this.model,'Handle'));
                SLStudio.HighlightSignal.removeHighlighting(bdroot(blkH));
                SLStudio.EmphasisStyleSheet.applyStyler(bdroot(blkH),blkH);
                sys=get_param(blkH,'parent');
                if~strcmp(get_param(sys,'open'),'on')
                    open_system(sys,'force','window');
                else
                    open_system(sys);
                end
            end
        end

        function showObserverPort(~,blkH)
            obsMdlH=bdroot(blkH);
            SLStudio.HighlightSignal.removeHighlighting(obsMdlH);
            SLStudio.EmphasisStyleSheet.applyStyler(obsMdlH,blkH);
            sys=get_param(blkH,'parent');
            if~strcmp(get_param(sys,'open'),'on')
                open_system(sys,'force','window');
            else
                open_system(sys);
            end
        end

        function channelCallback(this,msg)


            log(['New message:',newline,evalc('disp(msg)')]);
            switch msg.type
            case 'status'
                switch msg.payload
                case 'ready'

                    this.dialog.show();
                    Simulink.observer.internal.resetObserverDialogNeedsRefreshFlag(this.obsH);
                case 'hangup'

                    if~this.isDebug()
                        Simulink.observer.dialog.ObsPortDialog.dialogCloseCallback(this);
                    end
                otherwise
                    fprintf(2,'Unexpected payload: %s\n',msg.payload);
                end
            case 'getPortData'
                s.type='dialogResp';
                s.uuid=msg.uuid;
                s.payload.portUUID=this.SID;
                s.payload.selectedBlock=this.selectedBlock;
                s.payload.OPHier=this.getObserverHierarchy(this.obsH);
                s.payload.SSHier=this.getObservableAreaHierarchy(this.obsH);
                s.payload.obsAreaName=strrep(get_param(this.obsH,'parent'),newline,' ');
                s.payload.obsName=get_param(this.obsH,'ObserverModelName');
                message.publish(this.channelPath,s);
            case 'toSource'
                this.traceToSource(msg.payload);
            case 'showObserverPort'
                this.showObserverPort(msg.payload);
            case 'getNeedsRefreshFlag'
                s.type='dialogResp';
                s.uuid=msg.uuid;
                s.payload=Simulink.observer.internal.getObserverDialogNeedsRefreshFlag(this.obsH);
                message.publish(this.channelPath,s);
            case 'resetNeedsRefreshFlag'
                Simulink.observer.internal.resetObserverDialogNeedsRefreshFlag(this.obsH);
            case 'getObservedSignal'
                s.type='dialogResp';
                s.uuid=msg.uuid;
                [s.payload.blks,s.payload.type,s.payload.spec,s.payload.filterStr]=this.getObservedSignal(msg.payload);
                message.publish(this.channelPath,s);
            case 'findConnectedOutport'
                s.type='dialogResp';
                s.uuid=msg.uuid;
                [s.payload.blkH,s.payload.type,s.payload.spec,s.payload.filterStr]=this.findConnectedOutport(msg.payload);
                message.publish(this.channelPath,s);
            case 'getFullPathFromBlocks'
                s.type='dialogResp';
                s.uuid=msg.uuid;
                s.payload=this.getFullPathFromBlocks(msg.payload);
                message.publish(this.channelPath,s);
            case 'setSelection'
                this.handleTreeSelectionChange(msg.payload.blocks,msg.payload.type);
            case 'AddBlocks'
                this.addBlocks(msg.payload.signals,msg.payload.destPath);
                s.type='dialogResp';
                s.uuid=msg.uuid;
                message.publish(this.channelPath,s);
            case 'DeleteBlocks'
                this.deleteBlocks(msg.payload);
                s.type='dialogResp';
                s.uuid=msg.uuid;
                message.publish(this.channelPath,s);
            case 'RewireBlocks'
                this.rewireBlocks(msg.payload.signals,msg.payload.blocks);
                s.type='dialogResp';
                s.uuid=msg.uuid;
                message.publish(this.channelPath,s);
            case 'ResolveBlocks'
                this.resolveBlocks(msg.payload);
                s.type='dialogResp';
                s.uuid=msg.uuid;
                message.publish(this.channelPath,s);
            case 'LoadMdlRefOrLibrary'
                success=this.loadMdlRefOrLibrary(msg.payload);
                s.type='dialogResp';
                s.uuid=msg.uuid;
                s.payload=success;
                message.publish(this.channelPath,s);
            case 'ObsPortHelp'
                helpview([docroot,'/sltest/helptargets.map'],'observer_port_block_ref');
            case 'eval'
                try
                    res=eval(msg.payload);
                    s.type='evalResp';
                    s.payload=res;
                    message.publish(this.channelPath,s);
                catch ME
                    s.type='evalErr';
                    s.payload=ME;
                    message.publish(this.channelPath,s);
                end
            otherwise
                assert(false,"Unexpected type: "+msg.type);
            end
        end
    end


    methods(Static)
        function instance=getInstance(h)

            singletons=Simulink.observer.dialog.ObsPortDialog.getSingletons();

            instance=-1;
            sid='invalid';

            if strcmp(get_param(h,'BlockType'),'ObserverReference')
                obsH=h;
                try
                    obsMdlH=Simulink.observer.internal.openObserverMdlFromObsRefBlk(obsH);
                catch ex
                    Simulink.output.Stage('Observer','ModelName',getfullname(bdroot(h)),'UIMode',true);
                    Simulink.output.error(ex.message);
                    return;
                end
                if obsMdlH==-1
                    return;
                end
                selBlk=[];
            elseif strcmp(get_param(h,'BlockType'),'ObserverPort')
                obsMdlH=bdroot(h);
                obs=get_param(obsMdlH,'ObserverContext');
                if isempty(obs)
                    DAStudio.error('Simulink:Observer:CannotConfigureStandaloneObserverPort',getfullname(h),getfullname(obsMdlH));
                end
                obsH=get_param(obs,'Handle');
                selBlk=h;
            else
                return;
            end

            try
                if nargin==1&&obsH~=-1
                    sid=Simulink.ID.getSID(obsH);
                    if~isKey(singletons,sid)||~isvalid(singletons(sid))
                        singletons(sid)=Simulink.observer.dialog.ObsPortDialog;
                        instance=singletons(sid);
                        log(['Created a new instance for port ',sid]);
                    else
                        instance=singletons(sid);
                        log(['Reusing the same instance for port ',sid]);
                    end



                    if~ishandle(instance.dialog)

                        instance.SID=sid;
                        instance.model=bdroot(obsH);
                        instance.selectedBlock=selBlk;
                        instance.channelPath=sprintf('/ObserverPorts/%s',instance.SID);
                        instance.channelSub=message.subscribe(instance.channelPath,@(msg)channelCallback(instance,msg));

                        instance.createDDGDialog(obsH);




                        instance.listeners.modelClosed=Simulink.listener(obsH,'ModelCloseEvent',@(~,~)Simulink.observer.dialog.ObsPortDialog.dialogCloseCallback(instance));
                        instance.listeners.subsysDeleted=Simulink.listener(obsH,'DeleteEvent',@(~,~)Simulink.observer.dialog.ObsPortDialog.dialogCloseCallback(instance));
                    else


                        instance.dialog.show();

                        instance.selectedBlock=selBlk;
                        instance.selectBlockInTree(obsH);
                    end

                end
            catch ME
                log(['Initialization failed for port ',sid]);
                log([ME.identifier,' - ',ME.message],ME.stack);
                instance=-1;
            end

            updateMlock();
        end

        function closeDialogForObsBlk(obsH)
            if obsH==-1
                return;
            end
            singletons=Simulink.observer.dialog.ObsPortDialog.getSingletons();
            try
                sid=Simulink.ID.getSID(obsH);
            catch
                return;
            end
            if isKey(singletons,sid)&&isvalid(singletons(sid))
                instance=singletons(sid);
                delete(instance.dialog);
            end
        end

        function refreshDialogForPort(uuid)

            singletons=Simulink.observer.dialog.ObsPortDialog.getSingletons();

            if~isKey(singletons,uuid)
                return;
            end

            instance=singletons(uuid);
            assert(isvalid(instance));


            instance.refreshDialog();
        end

        function expandTreesInDialog(obsH)
            sid=Simulink.ID.getSID(obsH);

            singletons=Simulink.observer.dialog.ObsPortDialog.getSingletons();

            if~isKey(singletons,sid)
                return;
            end

            instance=singletons(sid);
            assert(isvalid(instance));


            instance.expandTrees();
        end

        function setDialogLockStatus(obsH,isLocked)
            sid=Simulink.ID.getSID(obsH);

            singletons=Simulink.observer.dialog.ObsPortDialog.getSingletons();

            if~isKey(singletons,sid)
                return;
            end

            instance=singletons(sid);
            assert(isvalid(instance));

            msg.type='SetDisabled';


            msg.payload=isLocked;
            message.publish(instance.channelPath,msg);
        end

        function forceMunlock()
            log('Force munlock');
            munlock;
        end

        function dialogCloseCallback(obj)
            log('Dialog closed');
            if isvalid(obj)
                log('Deleting singleton instance');
                delete(obj);
            end
        end

    end

    methods(Static,Access=private)

        function newpath=convertPathFormat(path)
            newpath=string(path).split(newline).replace('/','//').join('/').char;
        end

        function[blkList,ssid,actType]=reformatPathForSF(elemType,blkList,spec)
            sfId=blkList(end);


            if ishandle(sfId)
                sfId=sfprivate('block2chart',sfId);
            end
            if ismember(elemType,{'SFData','SFParam'})
                actType='Local';
                blkH=sfprivate('chart2block',sfId);
                blkList=[blkList(1:end-1),blkH];
                dataHdl=idToHandle(sfroot,str2double(spec));
                ssid=num2str(dataHdl.SSIdNumber);
            elseif ismember(elemType,{'SFStateSelf','SFStateChild','SFStateLeaf'})
                if strcmp(elemType,'SFStateSelf')
                    actType='Self';
                elseif strcmp(elemType,'SFStateChild')
                    actType='Child';
                elseif strcmp(elemType,'SFStateLeaf')
                    actType='Leaf';
                end

                sfHdl=idToHandle(sfroot,sfId);
                if ismember(actType,{'Child','Leaf'})
                    if isa(sfHdl,'Stateflow.Chart')||...
                        isa(sfHdl,'Stateflow.ReactiveTestingTableChart')||...
                        isa(sfHdl,'Stateflow.StateTransitionTableChart')
                        blkH=sfprivate('chart2block',sfId);
                        ssid='';
                    elseif isa(sfHdl,'Stateflow.AtomicSubchart')
                        blkH=sfprivate('chart2block',sfHdl.Subchart.Id);
                        ssid='';
                    else
                        blkH=sfprivate('chart2block',sfHdl.Chart.Id);
                        ssid=num2str(sfHdl.SSIdNumber);
                    end
                else
                    blkH=sfprivate('chart2block',sfHdl.Chart.Id);
                    ssid=num2str(sfHdl.SSIdNumber);
                end
                blkList=[blkList(1:end-1),blkH];
            else

                ssid='';
                actType='';
            end
        end

        function configureObserverPort(obsPrtBlk,elemType,blkList,spec)
            switch elemType
            case 'Outport'
                Simulink.observer.internal.configureObserverPort(obsPrtBlk,'Outport',blkList,str2double(spec),true);
            case{'SFStateSelf','SFStateChild','SFStateLeaf'}
                [blkList,ssid,actType]=Simulink.observer.dialog.ObsPortDialog.reformatPathForSF(elemType,blkList,spec);
                Simulink.observer.internal.configureObserverPort(obsPrtBlk,'SFState',blkList,{actType,ssid},true);
            case{'SFData','SFParam'}
                [blkList,ssid,~]=Simulink.observer.dialog.ObsPortDialog.reformatPathForSF(elemType,blkList,spec);
                Simulink.observer.internal.configureObserverPort(obsPrtBlk,'SFData',blkList,ssid,true);
            case 'BlockInternal'
                Simulink.observer.internal.configureObserverPort(obsPrtBlk,'BlockInternal',blkList,spec,true);
            otherwise

            end
        end

        function s=getSingletons()

            persistent singletons;
            if~isa(singletons,'containers.Map')

                singletons=containers.Map('KeyType','char','ValueType','any');

            end
            s=singletons;
        end

        function tf=isDebug()
            tf=false;
        end

        function log(msg,st)
            if Simulink.observer.dialog.ObsPortDialog.isDebug()
                if nargin==1
                    st=dbstack;
                    st=st(3:end);
                end
                msg=[st(1).name,' (',st(1).file,':',num2str(st(1).line),'): ',msg];
                disp(msg);
            end
        end
    end


    methods

        function selectBlockInTree(this,h)
            s.type='changeSelection';
            s.payload=h;
            message.publish(this.channelPath,s);
        end

        function refreshDialog(this)

            s.type='Refresh';
            message.publish(this.channelPath,s);
        end
        function expandTrees(this)
            s.type='ExpandTrees';
            message.publish(this.channelPath,s);
        end

        function editor=getDesignEditor(this)
            editor=SLM3I.SLDomain.getLastActiveEditorFor(this.model);

            if isempty(editor)
                log('Closing dialog - navigated away');
                delete(this);
                return;
            end
        end

        function editor=getObsEditor(this)
            obsMdl=get_param(this.obsH,'ObserverModelName');
            editor=SLM3I.SLDomain.getLastActiveEditorFor(get_param(obsMdl,'Handle'));

            if isempty(editor)
                log('Closing dialog - navigated away');
                delete(this);
                return;
            end
        end

        function setHighlight(this,type)























            this.listeners.propertyChanged.Enabled='off';
            for i=1:numel(this.curHighlighted)
                h=this.curHighlighted(i);


                try
                    o=get_param(h,'Object');
                    o.hilite(type);
                catch
                end
            end
            this.listeners.propertyChanged.Enabled='on';
        end

        function handleTreeSelectionChange(this,blocks,type)

            this.setHighlight('none');
            this.curHighlighted=[];


            if isempty(blocks)
                return;
            end
            for i=1:numel(blocks)

                this.curHighlighted(end+1)=blocks(i);












            end
            this.setHighlight(type);
        end

        function success=loadMdlRefOrLibrary(this,blkH)
            success=false;
            try
                blkType=get_param(blkH,'BlockType');
                if strcmp(blkType,'ModelReference')
                    mdlName=get_param(blkH,'ModelName');
                    open_system(mdlName,'loadonly');
                elseif strcmp(blkType,'Reference')




                    DAStudio.error('Simulink:SltBlkMap:UnresolvedLibrary',get_param(blkH,'SourceBlock'),getfullname(blkH));
                end
            catch ME
                Simulink.observer.internal.error(ME,true,'Simulink:Observer:ObserverStage',getfullname(this.model));
                return;
            end
            success=true;
        end

        function deleteBlocks(this,blocks)
            try
                this.checkMdlCompileLockStatus();
            catch ME
                Simulink.observer.internal.error(ME,true,'Simulink:Observer:ObserverStage',getfullname(this.model));
                return;
            end
            for j=1:numel(blocks)
                prtHdls=get_param(blocks(j),'PortHandles');
                line=get_param(prtHdls.Outport,'Line');
                if line~=-1
                    destPorts=get_param(line,'DstPortHandle');
                    if all(destPorts==-1)
                        delete_line(line);
                    end
                end
                delete_block(blocks(j));
            end
        end

        function rewireBlocks(this,signals,blocks)
            try
                this.checkMdlCompileLockStatus();
            catch ME
                Simulink.observer.internal.error(ME,true,'Simulink:Observer:ObserverStage',getfullname(this.model));
                return;
            end
            for j=1:numel(blocks)
                this.configureObserverPort(blocks(j),signals.types{1},signals.blocks,signals.specs{1});
            end
        end

        function resolveBlocks(~,blocks)
            for j=1:numel(blocks)
                Simulink.observer.internal.getObservedBlockForceLoad(blocks(j));
            end
        end

        function addBlocks(this,signals,destPath)
            try
                this.checkMdlCompileLockStatus();
            catch ME
                Simulink.observer.internal.error(ME,true,'Simulink:Observer:ObserverStage',getfullname(this.model));
                return;
            end

            blocks=signals.blocks;
            if isnumeric(blocks)
                blocks=mat2cell(blocks,ones(1,size(blocks,1)),size(blocks,2));
            end
            for j=1:numel(blocks)
                obsPrtBlk=Simulink.observer.internal.addObserverPortsForSignalsInObserver(-1,this.convertPathFormat(destPath),false);
                this.configureObserverPort(obsPrtBlk,signals.types{j},blocks{j},signals.specs{j});
            end
        end

        function delete(this)

            this.setHighlight('none');
            log('Removed higlights');

            message.unsubscribe(this.channelSub);
            log('Unsubscribe from the channel');

            singletons=Simulink.observer.dialog.ObsPortDialog.getSingletons();
            remove(singletons,this.SID);
            log('Removed singleton instance from map');
            updateMlock();
        end
    end


    methods
        function s=getDialogSchema(this,~)


            wb.Type='webbrowser';
            wb.Tag='obsportdlg_webbrowser';
            wb.RowSpan=[1,1];
            wb.ColSpan=[1,1];
            wb.ClearCache=true;
            wb.DisableContextMenu=true;
            wb.EnableInspectorOnLoad=this.isDebug();
            wb.Url=this.url;
            wb.WebKitToolBar={};
            wb.MinimumSize=[600,400];
            wb.Debug=this.isDebug();



            s.DialogTag='ObserverPortDlg';
            s.DialogTitle=DAStudio.message('Simulink:ObserverPort:ObsPortDialogTitle',strrep(getfullname(this.obsH),newline,' '));
            s.LayoutGrid=[1,1];
            s.RowStretch=1;
            s.ColStretch=1;
            s.ExplicitShow=true;
            s.CloseCallback='Simulink.observer.dialog.ObsPortDialog.dialogCloseCallback';
            s.CloseArgs={this};
            s.EmbeddedButtonSet={''};
            s.StandaloneButtonSet={''};
            x=200;
            y=400;
            width=880;
            height=720;
            s.Geometry=[x,y,width,height];


            s.Items={wb};
        end
    end

end

function log(varargin)
    Simulink.observer.dialog.ObsPortDialog.log(varargin{:})
end


function updateMlock()
    singletons=Simulink.observer.dialog.ObsPortDialog.getSingletons();
    if~isempty(singletons)
        log('Mlock');
        mlock;
    else
        log('Munlock');
        munlock;
    end
end




































