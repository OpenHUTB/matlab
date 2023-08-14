classdef SignalActions













    methods(Static)

        function schema=act_DisconnectGenerator(cbinfo)







            schema=sl_action_schema;
            schema.tag='Simulink:DisconnectGenerator';
            schema.label=DAStudio.message('Simulink:studio:DisconnectGenerator');
            schema.state='Enabled';

            vd=[];
            target=SLStudio.Utils.getOneMenuTarget(cbinfo);
            if SLStudio.Utils.objectIsValidSigGenPort(target)&&...
                ~Simulink.scopes.Util.isBlockDiagramCompiled(cbinfo)
                schema.state='Enabled';
                ownerH=target.container.handle;
                if ishandle(ownerH)
                    vd=Simulink.scopes.ViewerUtil.GetGeneratorAndPort(ownerH,target.handle);
                end
                if~isempty(vd)
                    vd.IOType='siggen';
                    schema.userdata=vd;
                    schema.callback=@Simulink.scopes.SignalActions.DisconnectIOBlock;
                end
            end

            if isempty(vd)
                schema.state='Disabled';
                schema.callback=DAStudio.getDefaultCallback;
            end
        end


        function schema=act_DisconnectAndDeleteGenerator(cbinfo)







            schema=sl_action_schema;
            schema.tag='Simulink:DisconnectAndDeleteGenerator';
            schema.label=DAStudio.message('Simulink:studio:DisconnectAndDeleteGenerator');

            target=SLStudio.Utils.getOneMenuTarget(cbinfo);
            vd=[];
            if SLStudio.Utils.objectIsValidSigGenPort(target)&&...
                ~Simulink.scopes.Util.isBlockDiagramCompiled(cbinfo)
                schema.state='Enabled';
                ownerH=target.container.handle;
                if ishandle(ownerH)
                    vd=Simulink.scopes.ViewerUtil.GetGeneratorAndPort(ownerH,target.handle);
                end
                if~isempty(vd)
                    vd.IOType='siggen';
                    vd.axis=1;
                    schema.userdata=vd;
                    schema.callback=@Simulink.scopes.SignalActions.DeleteIOBlock;
                end
            end

            if isempty(vd)
                schema.state='Disabled';
                schema.callback=DAStudio.getDefaultCallback;
            end
        end

        function schema=act_DisplayGenerator(cbinfo)













            schema=sl_toggle_schema;
            schema.tag='Simulink:DisplayGenerator';
            schema.label=DAStudio.message('Simulink:studio:DisplayGenerator');

            target=SLStudio.Utils.getOneMenuTarget(cbinfo);
            if SLStudio.Utils.objectIsValidSigGenPort(target)
                schema.state='Enabled';
                vd.portH=target.handle;
                if strcmp(get_param(vd.portH,'ShowSigGenPortName'),'on')
                    schema.checked='Checked';
                else
                    schema.checked='Unchecked';
                end
                schema.userdata=vd;
                schema.callback=@Simulink.scopes.SignalActions.ToggleDisplayGenerator;
            else
                schema.state='Disabled';
                schema.callback=DAStudio.getDefaultCallback;
            end
        end

        function schema=act_GeneratorParameters(cbinfo)







            schema=sl_action_schema;
            schema.tag='Simulink:GeneratorParameters';
            schema.label=DAStudio.message('Simulink:studio:GeneratorParameters');
            schema.userdata=schema.tag;
            schema.state='Enabled';

            target=SLStudio.Utils.getOneMenuTarget(cbinfo);
            vd=[];
            if SLStudio.Utils.objectIsValidSigGenPort(target)
                ownerH=target.container.handle;
                if ishandle(ownerH)
                    vd=Simulink.scopes.ViewerUtil.GetGeneratorAndPort(ownerH,target.handle);
                end

                if~isempty(vd)
                    schema.userdata=vd;
                    schema.callback=@Simulink.scopes.SignalActions.OpenViewer;
                end
            end

            if isempty(vd)
                schema.state='Disabled';
                schema.callback=DAStudio.getDefaultCallback;
            end
        end

        function schema=ConnectToViewerAxes(cbinfo)


















            schema=sl_action_schema;
            schema.label=cbinfo.userdata{4};
            schema.tag='Simulink:DummyTag';


            viewerdata.IOType='viewer';
            viewerdata.viewerH=cbinfo.userdata{1};
            viewerdata.portH=cbinfo.userdata{2};
            viewerdata.operation=cbinfo.userdata{3};
            viewerdata.axis=cbinfo.userdata{5};


            schema.userdata=viewerdata;
            switch viewerdata.operation
            case 'delete'
                schema.tag=['Simulink:DeleteViewerMenuItem_',cbinfo.userdata{4}];
                schema.callback=@Simulink.scopes.SignalActions.DeleteIOBlock;
            case 'disconnect'
                if numel(cbinfo.userdata)==6
                    schema.tag=['Simulink:DisconnectViewerMenuItem_',cbinfo.userdata{6},'_',cbinfo.userdata{4}];
                else
                    schema.tag=['Simulink:DisconnectViewerMenuItem_',cbinfo.userdata{4}];
                end
                schema.callback=@Simulink.scopes.SignalActions.DisconnectIOBlock;
            case 'connect'
                if numel(cbinfo.userdata)==6
                    schema.tag=['Simulink:ConnectViewerMenuItem_',cbinfo.userdata{6},'_',cbinfo.userdata{4}];
                else
                    schema.tag=['Simulink:ConnectViewerMenuItem_',cbinfo.userdata{4}];
                end
                schema.callback=@Simulink.scopes.SignalActions.ConnectIOBlock;
            end
            schema.autoDisableWhen='Busy';
        end

        function schema=ConnectToGeneratorMenuItem(cbinfo)













            schema=sl_action_schema;
            schema.label=cbinfo.userdata{4};
            schema.tag=['Simulink:ConnectToGeneratorMenuItem_',schema.label];


            viewerdata.IOType='siggen';
            viewerdata.viewerH=cbinfo.userdata{1};
            viewerdata.portH=cbinfo.userdata{2};
            viewerdata.operation='connect';
            viewerdata.axis=cbinfo.userdata{5};


            schema.userdata=viewerdata;
            schema.tag='Simulink:ConnectGeneratorMenuItem_';
            if numel(cbinfo.userdata)==6
                schema.tag=[schema.tag,cbinfo.userdata{6},'_'];
            end
            schema.tag=[schema.tag,cbinfo.userdata{4}];


            schema.callback=@Simulink.scopes.SignalActions.ConnectIOBlock;
        end

        function success=ConnectIOBlock(cbinfo)



















            vd=cbinfo.userdata;



            for i=1:length(vd.portH)

                currPort=vd.portH(i);


                if strcmp(vd.IOType,'siggen')&&...
                    Simulink.scopes.ViewerUtil.HasViewersOnPort(...
                    currPort,'siggen')
                    block=get_param(currPort,'Parent');

                    existingGen=Simulink.scopes.ViewerUtil.GetGeneratorAndPort(...
                    block,currPort);
                    if~isempty(existingGen)
                        Simulink.scopes.ViewerUtil.Disconnect(...
                        vd.IOType,existingGen.viewerH,existingGen.axis,...
                        existingGen.portH);
                    end
                end

                success=Simulink.scopes.ViewerUtil.Connect(...
                vd.IOType,vd.viewerH,vd.axis,currPort);
            end

            if success
                Simulink.scopes.SigScopeMgr.updateSSMFromRightClickContextMenu(cbinfo);
            end

        end

        function success=DisconnectIOBlock(cbinfo)

















            vd=cbinfo.userdata;
            success=Simulink.scopes.ViewerUtil.Disconnect(...
            vd.IOType,vd.viewerH,vd.axis,vd.portH);



            if success
                Simulink.scopes.SigScopeMgr.updateSSMFromRightClickContextMenu(cbinfo);
            end
        end

        function CreateAndConnectIOBlock(cbinfo)








            viewerH=Simulink.scopes.SignalActions.CreateIOBlock(cbinfo);
            connected=false;

            if viewerH
                vd=cbinfo.userdata;


                for i=1:length(vd.portH)
                    connectedOne=Simulink.scopes.ViewerUtil.Connect(vd.IOType,viewerH,...
                    vd.axis,vd.portH(i));
                    connected=connected||connectedOne;
                end
                if connected&&isViewerOpened(viewerH)
                    sigandscopemgr('ConnectToMPlay',viewerH);
                end
            end

            if connected&&...
                (strcmp(get(viewerH,'BlockType'),'SignalViewerScope')...
                ||strcmp(get(viewerH,'BlockType'),'Scope'))
                open_system(viewerH);
            end



            if connected
                Simulink.scopes.SigScopeMgr.updateSSMFromRightClickContextMenu(cbinfo);
            end

        end

        function viewerH=CreateIOBlock(cbinfo)

















            modelH=cbinfo.editorModel.Handle;
            fullpath=cbinfo.userdata.viewerpath;



            current_sys=get_param(0,'CurrentSystem');
            load_system(strtok(fullpath,'/'));
            set_param(0,'CurrentSystem',current_sys);
            mdlName=get_param(modelH,'Name');

            if strcmp(get_param(modelH,'type'),'block')
                mdlName=getfullname(modelH);
            end
            ioTypeName=get_param(fullpath,'Name');
            viewerH=add_block(fullpath,[mdlName,'/',ioTypeName],'MakeNameUnique','on','SSMgrBlock','on');


            if strcmp(ioTypeName,'MPlay')

                MPlayIO.mplayinst(viewerH);
            end
        end


        function DeleteIOBlock(cbinfo)











            Simulink.scopes.SignalActions.DelayedDeleteIOBlockCB(cbinfo);
        end

        function DelayedDeleteIOBlockCB(cbinfo)
            vd=cbinfo.userdata;



            hasOtherConnections=...
            Simulink.scopes.ViewerUtil.CheckForOtherConnections(vd.viewerH,vd.portH);




            if hasOtherConnections
                paths=...
                Simulink.scopes.ViewerUtil.ConnectedPathsString(vd.viewerH,true);

                vgName=[get_param(vd.viewerH,'Parent'),'/'...
                ,Simulink.scopes.ViewerUtil.FormatBlockName(get_param(vd.viewerH,'Name'))];


                dp=DAStudio.DialogProvider;

                if strcmp(vd.IOType,'viewer')

                    warnMessage=sprintf('%s\n%s\n\n%s',DAStudio.message('Simulink:studio:ViewerMultipleConnections',vgName),...
                    paths,DAStudio.message('Simulink:studio:DisconnectDeleteViewer'));
                    reply=dp.questdlg(warnMessage,DAStudio.message('Simulink:studio:ViewerConnections'),...
                    {getString(message('Simulink:blocks:OKButton')),...
                    getString(message('Simulink:blocks:CancelButton'))},...
                    getString(message('Simulink:blocks:CancelButton')));
                else

                    warnMessage=sprintf('%s\n%s\n\n%s',DAStudio.message('Simulink:studio:GeneratorMultipleConnections',vgName),...
                    paths,DAStudio.message('Simulink:studio:DisconnectDeleteGenerator'));
                    reply=dp.questdlg(warnMessage,DAStudio.message('Simulink:studio:GeneratorConnections'),...
                    {getString(message('Simulink:blocks:OKButton')),...
                    getString(message('Simulink:blocks:CancelButton'))},...
                    getString(message('Simulink:blocks:CancelButton')));
                end

                if(strcmp(reply,getString(message('Simulink:blocks:CancelButton')))||isempty(reply))
                    return;
                end

            end



            cbinfo.userdata.axis=0;
            disconnected=Simulink.scopes.SignalActions.DisconnectIOBlock(cbinfo);

            if disconnected
                delete_block(vd.viewerH);
                Simulink.scopes.SigScopeMgr.updateSSMFromRightClickContextMenu(cbinfo);
            end
        end

        function OpenViewer(cbinfo)











            viewerH=cbinfo.userdata.viewerH;
            open_system(viewerH);

        end

        function ToggleDisplayGenerator(cbinfo)



            vd=cbinfo.userdata;
            if strcmp(get_param(vd.portH,'ShowSigGenPortName'),'on')
                set_param(vd.portH,'ShowSigGenPortName','off');
            else
                set_param(vd.portH,'ShowSigGenPortName','on');
            end
        end

    end

end

function isValid=isViewerOpened(blk)
    ioObj=get_param(blk,'userdata');
    isValid=~isempty(ioObj)&&isa(ioObj,'MPlayIO.MPlay');
    if isValid
        hMPlay=ioObj.hMPlay;
        isValid=~isempty(hMPlay)&&isa(hMPlay,'uiscopes.Framework');
        if isValid
            hFig=hMPlay.Parent;
            isValid=ishghandle(hFig);
        end
    end
end

