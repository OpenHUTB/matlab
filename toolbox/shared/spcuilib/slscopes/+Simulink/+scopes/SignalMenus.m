classdef SignalMenus













    methods(Static)


        function schema=menu_OpenViewerMenu(cbinfo)








            schema=sl_container_schema;
            schema.tag='Simulink:OpenViewerMenu';
            schema.label=DAStudio.message('Simulink:studio:OpenViewerMenu');

            isforeachorinside=false;
            if~strcmpi(get_param(cbinfo.uiObject.handle,'Type'),'block_diagram')
                isforeachorinside=strcmpi(get_param(cbinfo.uiObject.handle,'IsForEachSSOrInside'),'on');
            end


            if~usejava('jvm')||cbinfo.model.isLibrary
                schema.state='Hidden';
            elseif Simulink.scopes.SignalMenus.HasViewersOnPort(cbinfo)&&...
                ~SLStudio.Utils.isConnectionLineSelected(cbinfo)&&~isforeachorinside
                schema.state='Enabled';
                schema.generateFcn=@Simulink.scopes.SignalMenus.GenerateOpenViewerMenu;
            else
                schema.state='Disabled';
                schema.generateFcn=@loc_EmptyChildren;
            end
            schema.autoDisableWhen='Busy';
        end

        function childrenFcns=GenerateOpenViewerMenu(cbinfo)








            port=Simulink.scopes.SignalMenus.GetViewerReadyPort(cbinfo);
            if~isempty(port)
                viewermap=Simulink.scopes.ViewerUtil.GetPortViewers(port.handle,'viewer');
            else
                viewermap={};
            end

            childrenFcns={};
            if isempty(viewermap)
                childrenFcns={DAStudio.Actions('HiddenSchema')};
                return;
            end


            viewerhandles=viewermap.values;
            viewernames=viewermap.keys;


            for i=1:length(viewerhandles)
                childrenFcns{i}={@Simulink.scopes.SignalMenus.OpenViewerMenuItem,...
                {viewernames{i},viewerhandles{i},port.handle}};
            end
        end

        function schema=OpenViewerMenuItem(cbinfo)














            viewername=cbinfo.userdata{1};
            viewerdata.viewerH=cbinfo.userdata{2};
            viewerdata.portH=cbinfo.userdata{3};

            schema=sl_action_schema;
            schema.label=viewername;
            schema.tag=['Simulink:OpenViewerMenuItem_',viewername];

            schema.userdata=viewerdata;
            schema.callback=@Simulink.scopes.SignalActions.OpenViewer;

            schema.autoDisableWhen='Never';
        end


        function schema=menu_CreateAndConnectViewerMenu(cbinfo)













            schema=sl_container_schema;
            schema.tag='Simulink:CreateAndConnectViewerMenu';
            schema.label=DAStudio.message('Simulink:studio:CreateAndConnectViewerMenu');



            srcPortM3I=Simulink.scopes.SignalMenus.GetViewerReadyPort(cbinfo);

            isforeachorinside=false;
            if~strcmpi(get_param(cbinfo.uiObject.handle,'Type'),'block_diagram')
                isforeachorinside=strcmpi(get_param(cbinfo.uiObject.handle,'IsForEachSSOrInside'),'on');
            end
            if~usejava('jvm')||cbinfo.model.isLibrary
                schema.state='Hidden';
            elseif~isempty(srcPortM3I)&&~Simulink.scopes.Util.isBlockDiagramCompiled(cbinfo)&&...
                ~SLStudio.Utils.isConnectionLineSelected(cbinfo)&&~isforeachorinside
                schema.state='Enabled';
                schema.userdata.portH=srcPortM3I.handle;
                schema.generateFcn=@Simulink.scopes.SignalMenus.GenerateCreateAndConnectViewerMenu;
            else
                schema.state='Disabled';
                schema.generateFcn=@loc_EmptyChildren;
            end
            schema.autoDisableWhen='Busy';
        end

        function libraryFcns=GenerateCreateAndConnectViewerMenu(cbinfo)









            portH=cbinfo.userdata.portH;



            vlc=Simulink.scopes.ViewerLibraryCache.Instance;
            libraries=vlc.getAllViewerLibs;

            if isempty(libraries)
                libraryFcns={DAStudio.Actions('HiddenSchema')};
                return;
            end


            preferredOrder=Simulink.scopes.ViewerUtil.GetPreferredLibraryOrder('viewer');
            libraries=Simulink.scopes.ViewerUtil.sortLibraries(libraries,preferredOrder);

            for index=1:length(libraries)

                if strcmp(libraries{index}.label,'Computer Vision')
                    findMPlay=cellfun(@(children)strcmp(children.ioType,'MPlay'),libraries{index}.children);
                    libraries{index}.children(findMPlay)=[];

                    if isempty(libraries{index}.children)
                        libraryFcns{index}={};
                        continue;
                    end
                end

                libraryFcns{index}={@Simulink.scopes.SignalMenus.CreateAndConnectViewerLibraryMenu,...
                {libraries{index},portH}};%#ok<*AGROW>
            end


            emptyCat=cellfun(@(x)isempty(x),libraryFcns);
            libraryFcns(emptyCat)=[];
        end

        function schema=CreateAndConnectViewerLibraryMenu(cbinfo)










            library=cbinfo.userdata{1};
            schema=sl_container_schema;
            schema.tag=['Simulink:CreateViewerLibraryMenu_',library.tag];
            schema.label=library.label;
            portH=cbinfo.userdata{2};
            modelH=get_param(SLStudio.Utils.getModelName(cbinfo,false),'Handle');

            if isempty(library.children)
                schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
                return;
            end



            for index=1:length(library.children)
                schema.childrenFcns{index}={@Simulink.scopes.SignalMenus.CreateAndConnectViewerMenuItem,...
                {modelH,portH,library.children{index}}};
            end
            schema.autoDisableWhen='Busy';

        end

        function schema=CreateAndConnectViewerMenuItem(cbinfo)











            block=cbinfo.userdata{3};
            schema=sl_action_schema;
            schema.tag=['Simulink:CreateViewerItem_',block.tag];
            schema.label=block.label;


            viewerdata.IOType='viewer';
            viewerdata.modelH=cbinfo.userdata{1};
            viewerdata.viewerpath=block.path;
            viewerdata.portH=cbinfo.userdata{2};
            viewerdata.axis=1;
            schema.userdata=viewerdata;

            schema.callback=@Simulink.scopes.SignalActions.CreateAndConnectIOBlock;

            schema.autoDisableWhen='Busy';
        end


        function schema=menu_ConnectToExistingViewerMenu(cbinfo)













            schema=sl_container_schema;
            schema.tag='Simulink:ConnectToViewerMenu';
            schema.label=DAStudio.message('Simulink:studio:ConnectToViewerMenu');

            port=Simulink.scopes.SignalMenus.GetViewerReadyPort(cbinfo);
            isforeachorinside=false;
            if~strcmpi(get_param(cbinfo.uiObject.handle,'Type'),'block_diagram')
                isforeachorinside=strcmpi(get_param(cbinfo.uiObject.handle,'IsForEachSSOrInside'),'on');
            end
            childrenFcn={};
            if~isempty(port)&&Simulink.scopes.SignalMenus.HasViewers(cbinfo)&&...
                ~Simulink.scopes.Util.isBlockDiagramCompiled(cbinfo)&&...
                ~SLStudio.Utils.isConnectionLineSelected(cbinfo)&&~isforeachorinside

                childrenFcn=Simulink.scopes.SignalMenus.GetViewers('connect',cbinfo);
            end
            if~usejava('jvm')||cbinfo.model.isLibrary
                schema.state='Hidden';
            elseif isempty(childrenFcn)
                schema.state='Disabled';
                schema.childrenFcn=loc_EmptyChildren;
            else
                schema.state='Enabled';
                schema.childrenFcn=childrenFcn;
            end
            schema.autoDisableWhen='Busy';

        end

        function viewerFcns=GetViewers(operation,cbinfo)








            connect=strcmp(operation,'connect');


            port=Simulink.scopes.SignalMenus.GetViewerReadyPort(cbinfo);


            graphh=SLStudio.Utils.getDiagramHandle(cbinfo);


            if connect==true
                viewermap=Simulink.scopes.ViewerUtil.GetModelViewers(graphh,'viewer');
            else
                viewermap=Simulink.scopes.ViewerUtil.GetPortViewers(port.handle,'viewer');
            end


            viewerFcns=Simulink.scopes.SignalMenus.GetAvailableViewerFunctions(viewermap,port,operation);

        end

        function menuFcns=GetAvailableViewerFunctions(viewermap,port,operation)




            menuFcns={};
            if~isempty(viewermap)
                viewernames=viewermap.keys;
                viewerhandles=viewermap.values;
                ichild=1;
                for i=1:length(viewernames)
                    if Simulink.scopes.ViewerUtil.HasFreeAxes(...
                        'viewer',viewerhandles{i},port.handle,operation)
                        menuFcns{ichild}={@Simulink.scopes.SignalMenus.GenerateConnectToViewerSubmenu,...
                        {viewerhandles{i},port.handle,operation,viewernames{i}}};
                        ichild=ichild+1;
                    end
                end
            end
        end

        function schema=GenerateConnectToViewerSubmenu(cbinfo)











            schema=sl_container_schema;
            if strcmp(cbinfo.userdata{3},'connect')
                schema.tag=['Simulink:ConnectToViewerSubmenu_',cbinfo.userdata{4}];
            else
                schema.tag=['Simulink:DisconnectViewerSubmenu_',cbinfo.userdata{4}];
            end
            schema.label=cbinfo.userdata{4};
            schema.userdata=cbinfo.userdata;
            childrenFcns=Simulink.scopes.SignalMenus.GenerateConnectToViewerAxes(cbinfo);

            if~isempty(childrenFcns)
                schema.childrenFcns=childrenFcns;
            else

                schema.userdata{5}=1;
                schema=Simulink.scopes.SignalActions.ConnectToViewerAxes(schema);
            end
            schema.autoDisableWhen='Busy';
        end

        function childrenFcns=GenerateConnectToViewerAxes(cbinfo)












            viewerh=cbinfo.userdata{1};
            porth=cbinfo.userdata{2};
            operation=cbinfo.userdata{3};



            if strcmp(operation,'delete')||...
                ~Simulink.scopes.ViewerUtil.ViewerHasMultipleAxes(viewerh)
                childrenFcns={};
                return;
            end



            axesnames=Simulink.scopes.ViewerUtil.GetPortAxesNames(...
            'viewer',viewerh,porth,operation);

            ichild=0;


            if~isempty(axesnames)
                childrenFcns={};
                for i=1:length(axesnames)
                    if~isempty(axesnames{i})
                        ichild=ichild+1;
                        childrenFcns{ichild}={@Simulink.scopes.SignalActions.ConnectToViewerAxes,...
                        {viewerh,porth,operation,axesnames{i},i,cbinfo.userdata{4}}};
                    end
                end
            end

            if isempty(axesnames)||ichild==0
                childrenFcns={DAStudio.Actions('HiddenSchema')};
                return;
            end

        end


        function schema=menu_DisconnectViewerMenu(cbinfo)




            schema=sl_container_schema;
            schema.tag='Simulink:DisconnectViewerMenu';
            schema.label=DAStudio.message('Simulink:studio:DisconnectViewerMenu');

            if~usejava('jvm')||cbinfo.model.isLibrary
                schema.state='Hidden';
            elseif Simulink.scopes.SignalMenus.HasViewersOnPort(cbinfo)&&...
                ~Simulink.scopes.Util.isBlockDiagramCompiled(cbinfo)&&...
                ~SLStudio.Utils.isConnectionLineSelected(cbinfo)
                schema.state='Enabled';
                schema.userdata=cbinfo.userdata;
                schema.userdata.operation='disconnect';
                schema.generateFcn=@Simulink.scopes.SignalMenus.GenerateConnectToViewer;
            else
                schema.state='Disabled';
                schema.generateFcn=@loc_EmptyChildren;
            end
            schema.autoDisableWhen='Busy';
        end

        function viewerFcns=GenerateConnectToViewer(cbinfo)








            operation=cbinfo.userdata.operation;
            viewerFcns=Simulink.scopes.SignalMenus.GetViewers(operation,cbinfo);

            if isempty(viewerFcns)
                viewerFcns={DAStudio.Actions('HiddenSchema')};
                return;
            end

        end


        function schema=menu_DeleteViewerMenu(cbinfo)






            schema=sl_container_schema;
            schema.tag='Simulink:DeleteViewerMenu';
            schema.label=DAStudio.message('Simulink:studio:DeleteViewerMenu');

            if~usejava('jvm')||cbinfo.model.isLibrary
                schema.state='Hidden';
            elseif Simulink.scopes.SignalMenus.HasViewersOnPort(cbinfo)&&...
                ~Simulink.scopes.Util.isBlockDiagramCompiled(cbinfo)&&...
                ~SLStudio.Utils.isConnectionLineSelected(cbinfo)
                schema.state='Enabled';
                schema.userdata=cbinfo.userdata;
                schema.userdata.operation='delete';
                schema.generateFcn=@Simulink.scopes.SignalMenus.GenerateConnectToViewer;
            else
                schema.state='Disabled';
                schema.generateFcn=@loc_EmptyChildren;
            end
            schema.autoDisableWhen='Busy';
        end



        function schema=menu_CreateAndConnectGeneratorMenu(cbinfo)











            schema=sl_container_schema;
            schema.tag='Simulink:CreateAndConnectGeneratorMenu';
            schema.label=DAStudio.message('Simulink:studio:CreateAndConnectGeneratorMenu');

            portM3I=Simulink.scopes.SignalMenus.GetGeneratorReadyPort(cbinfo);
            if~usejava('jvm')||cbinfo.model.isLibrary
                schema.state='Hidden';
            elseif(~isempty(portM3I))&&~Simulink.scopes.Util.isBlockDiagramCompiled(cbinfo)
                schema.state='Enabled';

                schema.userdata.portH=[portM3I.handle];
                schema.generateFcn=@Simulink.scopes.SignalMenus.GenerateCreateAndConnectGeneratorMenu;
            else
                schema.state='Disabled';
                schema.generateFcn=@loc_EmptyChildren;
            end
        end

        function libraryFcns=GenerateCreateAndConnectGeneratorMenu(cbinfo)









            portH=cbinfo.userdata.portH;



            vlc=Simulink.scopes.ViewerLibraryCache.Instance;
            libraries=vlc.getAllGeneratorLibs;

            if isempty(libraries)
                libraryFcns={DAStudio.Actions('HiddenSchema')};
                return;
            end


            preferredOrder=Simulink.scopes.ViewerUtil.GetPreferredLibraryOrder('siggen');
            libraries=Simulink.scopes.ViewerUtil.sortLibraries(libraries,preferredOrder);

            for index=1:length(libraries)
                libraryFcns{index}={@Simulink.scopes.SignalMenus.CreateAndconnectGeneratorLibraryMenu,...
                {libraries{index},portH}};%#ok<*AGROW>
            end
        end

        function schema=CreateAndconnectGeneratorLibraryMenu(cbinfo)










            library=cbinfo.userdata{1};
            schema=sl_container_schema;
            schema.tag=['Simulink:CreateGeneratorLibraryMenu_',library.tag];
            schema.label=library.label;
            portH=cbinfo.userdata{2};
            modelH=get_param(SLStudio.Utils.getModelName(cbinfo,false),'Handle');

            if isempty(library.children)
                schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
                return;
            end


            for index=1:length(library.children)
                schema.childrenFcns{index}={@Simulink.scopes.SignalMenus.CreateAndConnectGeneratorMenuItem,...
                {modelH,portH,library.children{index}}};
            end

        end

        function schema=CreateAndConnectGeneratorMenuItem(cbinfo)











            block=cbinfo.userdata{3};
            schema=sl_action_schema;
            schema.tag=['Simulink:CreateGeneratorItem_',block.tag];
            schema.label=block.label;


            viewerdata.IOType='siggen';
            viewerdata.modelH=cbinfo.userdata{1};
            viewerdata.viewerpath=block.path;
            viewerdata.portH=cbinfo.userdata{2};
            viewerdata.axis=1;
            schema.userdata=viewerdata;

            schema.callback=@Simulink.scopes.SignalActions.CreateAndConnectIOBlock;

        end


        function schema=menu_ConnectToExistingGeneratorMenu(cbinfo)










            schema=sl_container_schema;
            schema.tag='Simulink:ConnectToExistingGeneratorMenu';
            schema.label=DAStudio.message('Simulink:studio:ConnectToExistingGeneratorMenu');


            port=Simulink.scopes.SignalMenus.GetGeneratorReadyPort(cbinfo);
            modelH=get_param(SLStudio.Utils.getModelName(cbinfo,false),'Handle');

            hasviewers=Simulink.scopes.ViewerUtil.HasViewers(modelH,'siggen');
            if~usejava('jvm')||cbinfo.model.isLibrary
                schema.state='Hidden';
            elseif~isempty(port)&&hasviewers&&~Simulink.scopes.Util.isBlockDiagramCompiled(cbinfo)
                schema.state='Enabled';
                schema.generateFcn=@Simulink.scopes.SignalMenus.GenerateConnectToExistingGeneratorMenu;
            else
                schema.state='Disabled';
                schema.generateFcn=@loc_EmptyChildren;
            end
        end

        function viewerFcns=GenerateConnectToExistingGeneratorMenu(cbinfo)









            port=Simulink.scopes.SignalMenus.GetGeneratorReadyPort(cbinfo);


            graphh=SLStudio.Utils.getDiagramHandle(cbinfo);

            viewermap=Simulink.scopes.ViewerUtil.GetModelViewers(graphh,'siggen');
            viewerFcns=Simulink.scopes.SignalMenus.GetAvailableGeneratorFunctions(viewermap,port);

            if isempty(viewerFcns)
                viewerFcns={DAStudio.Actions('HiddenSchema')};
                return;
            end

        end

        function menuFcns=GetAvailableGeneratorFunctions(viewermap,port)




            menuFcns={};
            if~isempty(viewermap)
                viewernames=viewermap.keys;
                viewerhandles=viewermap.values;
                ichild=1;
                for i=1:length(viewernames)


                    if Simulink.scopes.ViewerUtil.HasFreeAxes(...
                        'siggen',viewerhandles{i},[port.handle],'connect')
                        menuFcns{ichild}={@Simulink.scopes.SignalMenus.ConnectToGeneratorSubMenu,...
                        {viewerhandles{i},[port.handle],'connect',viewernames{i}}};
                        ichild=ichild+1;
                    end
                end
            end
        end

        function schema=ConnectToGeneratorSubMenu(cbinfo)











            schema=sl_container_schema;
            if strcmp(cbinfo.userdata{3},'connect')
                schema.tag=['Simulink:ConnectToGeneratorSubmenu_',cbinfo.userdata{4}];
            else
                schema.tag=['Simulink:DisconnectGeneratorSubmenu_',cbinfo.userdata{4}];
            end
            schema.label=cbinfo.userdata{4};
            schema.userdata=cbinfo.userdata;
            childrenFcns=Simulink.scopes.SignalMenus.GenerateConnectToGeneratorAxes(cbinfo);

            if~isempty(childrenFcns)
                schema.childrenFcns=childrenFcns;
            else

                schema.userdata{5}=1;
                schema=Simulink.scopes.SignalActions.ConnectToGeneratorMenuItem(schema);
            end
            schema.autoDisableWhen='Busy';
        end

        function childrenFcns=GenerateConnectToGeneratorAxes(cbinfo)












            viewerh=cbinfo.userdata{1};
            porth=cbinfo.userdata{2};
            operation=cbinfo.userdata{3};



            if strcmp(operation,'delete')||...
                ~Simulink.scopes.ViewerUtil.GeneratorHasMultipleAxes(viewerh)
                childrenFcns={};
                return;
            end



            axesnames=Simulink.scopes.ViewerUtil.GetPortAxesNames(...
            'siggen',viewerh,porth,operation);

            ichild=0;


            if~isempty(axesnames)
                childrenFcns={};
                for i=1:length(axesnames)
                    if~isempty(axesnames{i})
                        ichild=ichild+1;
                        childrenFcns{ichild}={@Simulink.scopes.SignalActions.ConnectToGeneratorMenuItem...
                        ,{viewerh,porth,operation,axesnames{i},i,cbinfo.userdata{4}}};
                    end
                end
            end

            if isempty(axesnames)||ichild==0
                childrenFcns={DAStudio.Actions('HiddenSchema')};
                return;
            end

        end



        function schema=menu_SwitchGeneratorConnectionMenu(cbinfo)















            schema=sl_container_schema;
            schema.tag='Simulink:SwitchGeneratorConnectionMenu';
            schema.label=DAStudio.message('Simulink:studio:SwitchGeneratorConnectionMenu');

            graphh=SLStudio.Utils.getDiagramHandle(cbinfo);
            [~,hasMultipleGenerators]=Simulink.scopes.ViewerUtil.HasViewers(graphh,'siggen');

            if hasMultipleGenerators
                schema.state='Enabled';
                schema.generateFcn=@Simulink.scopes.SignalMenus.GenerateSwitchGeneratorConnectionMenu;
            else
                schema.state='Disabled';
                schema.generateFcn=@loc_EmptyChildren;
            end

        end

        function generatorFcns=GenerateSwitchGeneratorConnectionMenu(cbinfo)









            port=SLStudio.Utils.getOneMenuTarget(cbinfo);


            graphh=SLStudio.Utils.getDiagramHandle(cbinfo);


            generatormap=Simulink.scopes.ViewerUtil.GetModelViewers(graphh,'siggen');



            generatorFcns=Simulink.scopes.SignalMenus.GetAvailableGeneratorFunctions(generatormap,port);

            if isempty(generatorFcns)
                generatorFcns={DAStudio.Actions('HiddenSchema')};
                return;
            end

        end


        function port=GetGeneratorReadyPort(cbinfo)






            target=SLStudio.Utils.getOneMenuTarget(cbinfo);
            line=SLStudio.Utils.getSingleSelectedLine(cbinfo);

            if isempty(target)
                port=[];
            elseif~isempty(line)
                noSrc=SLStudio.Utils.lineHasUnconnectedInport(line);
                if noSrc

                    port=SLStudio.Utils.getLineDestPorts(line);
                else
                    port=[];
                end
            elseif SLStudio.Utils.objectIsValidPort(target)&&strcmp(target.type,'In Port')



                port=target;
            else

                port=[];
            end
        end

        function port=GetViewerReadyPort(cbinfo)







            target=SLStudio.Utils.getOneMenuTarget(cbinfo);
            if SLStudio.Utils.objectIsValidPort(target)&&...
                strcmpi(target.type,'Out Port')
                port=target;
            else
                l=SLStudio.Utils.getSingleSelectedLine(cbinfo);
                if~isempty(l)
                    port=SLStudio.Utils.getLineSourcePort(l);
                else
                    port=[];
                end
            end

        end

        function found=HasViewers(cbinfo)









            graphh=SLStudio.Utils.getDiagramHandle(cbinfo);
            found=Simulink.scopes.ViewerUtil.HasViewers(graphh,'viewer');
        end

        function found=HasViewersOnPort(cbinfo)









            found=false;
            port=Simulink.scopes.SignalMenus.GetViewerReadyPort(cbinfo);
            if~isempty(port)
                porth=port.handle;
                found=Simulink.scopes.ViewerUtil.HasViewersOnPort(porth,'viewer');
            end
        end
    end

end

function schemas=loc_EmptyChildren(~)
    schemas={DAStudio.Actions('HiddenSchema')};
end


