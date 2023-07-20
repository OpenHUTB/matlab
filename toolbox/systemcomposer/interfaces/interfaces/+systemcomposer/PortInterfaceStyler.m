classdef PortInterfaceStyler<handle





    properties
        styledObjs;
        styler;
        lastModel;
    end

    properties(Constant)
        stylerName='PortInterfaceUsageStyler';
        styleClass='PortUsingCurrentInterface';
    end

    methods(Static)
        function obj=getInstance()
            persistent theInstance;
            if isempty(theInstance)||~isvalid(theInstance)
                theInstance=systemcomposer.PortInterfaceStyler();
            end
            obj=theInstance;
        end

        function destroyStyler()
            styler=diagram.style.getStyler(systemcomposer.PortInterfaceStyler.stylerName);
            if~isempty(styler)
                destroy(styler);
            end
        end
    end

    methods
        function interfaceSelected(this,bdH,intrf)



            this.createStylerIfNeeded();



            this.removeAllStyles(bdH);
            harnessInfo=Simulink.harness.internal.getActiveHarness(bdH);
            if~isempty(harnessInfo)
                this.removeAllStyles(get_param(harnessInfo.model,'Handle'));
            end

            if isempty(intrf)
                return;
            end

            [users,harnessUsers]=this.getUsersOfInterface(bdH,intrf);



            if~isempty(harnessInfo)
                this.styleElements(users,get_param(harnessInfo.model,'Handle'));
                if~isempty(harnessUsers)
                    this.styleElements(harnessUsers,bdH);
                end
            else
                this.styleElements(users,bdH);
            end
        end

        function removeAllStyles(this,bdH)


            model=get_param(bdH,'Name');
            if this.styledObjs.isKey(model)
                diagObjs=this.styledObjs(model);
                for idx=1:length(diagObjs)
                    do=diagObjs(idx);
                    this.styler.removeClass(do,this.styleClass);
                end
                this.styledObjs.remove(model);
            end
        end

    end

    methods(Access=private)
        function this=PortInterfaceStyler()


            this.styledObjs=containers.Map('KeyType','char','ValueType','any');
            this.createStylerIfNeeded();
            this.lastModel=-1;
        end

        function createStylerIfNeeded(this)



            this.styler=diagram.style.getStyler(this.stylerName);

            if isempty(this.styler)||~isvalid(this.styler)

                diagram.style.createStyler(this.stylerName);
                this.styler=diagram.style.getStyler(this.stylerName);


                style=systemcomposer.internal.editor.getHighlightingStyle();


                selector=diagram.style.ClassSelector(this.styleClass);
                this.styler.addRule(style,selector);
            end
        end

        function[usages,harnessUsages]=getUsersOfInterface(this,model,interface)



            if~isequal(this.lastModel,model)
                mfModel=get_param(model,'SystemComposerMf0Model');
                if~isempty(mfModel)
                    for e=mfModel.topLevelElements
                        if isa(e,'systemcomposer.services.proxy.DictionaryResolver')||...
                            isa(e,'systemcomposer.services.proxy.CurrentModelResolver')
                            for prx=e.Proxies.toArray
                                prx.resolve();
                            end
                        end
                    end
                end


                this.lastModel=model;
            end

            usages=[];
            harnessUsages=[];



            allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            if(numel(allStudios)>0)
                st=allStudios(1);
                editor=st.App.getActiveEditor();

                blks=find_system(editor.getName,'SearchDepth',1,'findall','on','BlockType','ModelReference');



                if strcmp(get_param(editor.blockDiagramHandle,'IsHarness'),'on')
                    zcblks=cell2mat(arrayfun(@(x)systemcomposer.internal.harness.getZCPeerForHarnessBlock(x),blks,'UniformOutput',false));
                    if~isempty(zcblks)
                        blks=zcblks;
                    end
                end

                for idx=1:numel(blks)
                    comp=systemcomposer.utils.getArchitecturePeer(blks(idx));

                    compPorts=comp.getPorts();
                    for idx1=1:numel(compPorts)
                        compPort=compPorts(idx1);




                        if compPort.getPortInterface()==interface
                            slPorts=systemcomposer.utils.getSimulinkPeer(compPort);
                            assert(numel(slPorts)==1);
                            slPort=slPorts(1);
                            usages=[usages,slPort];
                        end
                    end
                end
            end


            u=interface.getUsages();
            hUsages=[];
            for i=1:length(u)


                archPort=u(i).p_Port;
                slPortBlocks=systemcomposer.utils.getSimulinkPeer(archPort);
                for j=1:length(slPortBlocks)
                    slPortBlock=slPortBlocks(j);
                    usages=[usages,slPortBlock];%#ok<*AGROW>
                end



                if strcmp(get_param(editor.blockDiagramHandle,'IsHarness'),'on')
                    hUsages=cell2mat(arrayfun(@(x)systemcomposer.internal.harness.getActiveHarnessPeer(x),usages,'UniformOutput',false));
                end



                if archPort.getArchitecture.hasParentComponent
                    compPort=archPort.getArchitecture.getParentComponent.getPort(archPort.getName);
                    slPorts=systemcomposer.utils.getSimulinkPeer(compPort);
                    assert(numel(slPorts)==1);
                    slPort=slPorts(1);
                    usages=[usages,slPort];


                    if~isempty(hUsages)
                        portType=get_param(slPort,'PortType');
                        portNumber=get_param(slPort,'PortNumber');
                        portHandles=get_param(get_param(hUsages,'Parent'),'PortHandles');
                        if strcmp(portType,'inport')
                            type='Inport';
                        else
                            type='Outport';
                        end
                        for j=1:length(portHandles)
                            if iscell(portHandles)
                                phStruct=portHandles{j};
                            else
                                phStruct=portHandles;
                            end
                            for ph=1:length(phStruct.(type))
                                if isequal(get_param(phStruct.(type)(ph),'PortNumber'),portNumber)
                                    hUsages=[hUsages,phStruct.(type)(ph)];
                                    break;
                                end
                            end
                        end
                    end
                end
                harnessUsages=[harnessUsages,hUsages];
                hUsages=[];
            end
        end

        function styleElements(this,users,bdH)


            diagObjs=[];
            model=get_param(bdH,'Name');
            for idx=1:length(users)
                slPort=users(idx);
                do=diagram.resolver.resolve(slPort);
                if~do.isNull
                    diagObjs=[diagObjs,do];
                    this.styler.applyClass(do,this.styleClass);
                end
            end
            this.styledObjs(model)=diagObjs;
        end

    end
end
