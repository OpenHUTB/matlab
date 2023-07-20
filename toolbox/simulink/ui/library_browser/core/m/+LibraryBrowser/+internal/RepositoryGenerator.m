classdef RepositoryGenerator<handle

    properties
        mLibraryHandle;
mLibraryName
        mTargetRelease;
        mRepositoryPath;
        mRepositoryFiles;
        mOtherLibraries;
    end

    properties(Access='private')
        mRootFolder;
        mDocNode;
        mDocRootNode;
    end

    methods(Access='public')
        function obj=RepositoryGenerator(libHandle,targetRelease)
            obj.mLibraryHandle=get_param(libHandle,'Handle');
            obj.mLibraryName=get_param(obj.mLibraryHandle,'Name');
            assert(isempty(targetRelease)||isa(targetRelease,'saveas_version'));
            obj.mTargetRelease=targetRelease;
        end

        function generate(obj)


            if~LibraryBrowser.hasDisplay()
                w=warning('off','backtrace');
                restorewarn=onCleanup(@()warning(w));
                MSLDiagnostic('sl_lib_browse2:sl_lib_browse2:SLLB_ReposNotSupportedNoDisplay',obj.mLibraryName).reportAsWarning;
                return;
            end
            obj.mRepositoryPath=LibraryBrowser.ReposDlg.getInstance().tempDir;
            hasTree=obj.libraryHasHierarchy;
            obj.initDOM(hasTree);


            obj.mRootFolder=[slfullfile(obj.mRepositoryPath,obj.mLibraryName),filesep];
            obj.buildTree(obj.mLibraryHandle,obj.mRootFolder,obj.mDocRootNode,hasTree);
            obj.writeToXML;
        end

    end

    methods(Access='private')


        function isLib=isBDaLibrary(~,input)
            if isnumeric(input)||bdIsLoaded(input)
                isLib=bdIsLibrary(input);
            else
                info=Simulink.MDLInfo(input,'isExtractInterface',false,'isExtractMetadata',false);
                isLib=info.IsLibrary;
            end
        end




        function isSFBasedBlk=isStateflowBasedBlock(~,graphHandle)
            isSFBasedBlk=false;
            if strcmpi(get_param(graphHandle,'BlockType'),'Subsystem')||...
                strcmpi(get_param(graphHandle,'BlockType'),'MessageViewer')


                sfblk=find_system(graphHandle,'SearchDepth',0,'FollowLinks','on','LookUnderMasks','none','BlockType','SubSystem','SFBlockType','NONE');
                if isempty(sfblk)
                    isSFBasedBlk=true;
                end
            end
        end




        function isBlockSimEventsCompatible=isThisSimulinkBlockSimEventsCompatible(~,blockHandle)
            isBlockSimEventsCompatible=false;


            permittedSimulinkBlockType={'Display','Scope','From','FromWorkspace',...
            'FromFile','FromSpreadsheet','Goto','Ground',...
            'Terminator','ToFile','ToWorkspace','ToAsyncQueueBlock'};





            block_type=get_param(blockHandle,"BlockType");

            if any(ismember(permittedSimulinkBlockType,block_type))
                isBlockSimEventsCompatible=true;
            end
        end

        function[inDiffLib,lib]=isInDiffLib(obj,graphHandle)
            lib=obj.mLibraryName;
            libIn=lib;
            inDiffLib=false;
            if strcmpi(get_param(graphHandle,'Type'),'block_diagram')
                if obj.mLibraryHandle~=graphHandle
                    inDiffLib=true;
                    lib=get_param(graphHandle,'Name');
                end
            else


                if strcmpi(get_param(graphHandle,'Type'),'annotation')
                    return;
                end
                blkOpenFcn=get_param(graphHandle,'OpenFcn');
                if~isempty(blkOpenFcn)

                    blkOpenFcn=obj.removeTrailingChars(blkOpenFcn);
                    try



                        if exist(blkOpenFcn,'file')==4&&...
                            obj.isBDaLibrary(blkOpenFcn)
                            inDiffLib=true;
                            lib=blkOpenFcn;
                        else
                            [lib,~,success]=obj.findLibraryAndSubsystem(blkOpenFcn);
                            if success
                                if isCharOrStringScalar(lib)&&...
                                    exist(lib,'file')==4&&...
                                    ~strcmpi(libIn,lib)&&...
                                    obj.isBDaLibrary(lib)
                                    inDiffLib=true;
                                end
                            end
                        end
                    catch E
                        fprintf('Error processing OpenFcn for %s: %s\n',getfullname(graphHandle),E.message);
                    end
                end
            end
        end


        function stringFound=isContainedIn(~,string,patterns)
            if iscell(patterns)
                len=length(patterns);
            else
                stringFound=contains(string,patterns);
                return;
            end
            for i=1:len
                stringFound=contains(string,patterns{i});
                if stringFound
                    return;
                end
            end
        end

        function[openfcn,functionmatch]=processOpenSystemInfo(obj,graphOpenFcn)
            openfcn=graphOpenFcn;
            functionmatch='load_open_subsystem';
            if~obj.isContainedIn(graphOpenFcn,functionmatch)
                functionmatch='open_system';
                if~obj.isContainedIn(graphOpenFcn,functionmatch)
                    functionmatch=[];
                    return;
                end
            end


            [startIdx,~]=regexp(graphOpenFcn,[functionmatch,'\((.*?)\)']);
            starts=regexp(graphOpenFcn,'\(');
            ends=regexp(graphOpenFcn,'\)');


            openfcn=graphOpenFcn(startIdx:ends(length(starts)));
        end

        function[lib,subsystem,success]=findLibraryAndSubsystem(obj,graphOpenFcn)
            lib=[];
            subsystem=[];
            success=1;


            graphOpenFcn=obj.removeTrailingChars(graphOpenFcn);
            if exist(graphOpenFcn,'file')==4||strcmpi(graphOpenFcn,'simulink')
                lib=graphOpenFcn;
            else
                [graphOpenFcn,functionmatch]=obj.processOpenSystemInfo(graphOpenFcn);
                if isempty(functionmatch)||isempty(graphOpenFcn)
                    success=0;
                    return;
                end
                cmd=strrep(graphOpenFcn,functionmatch,'i_parseArgs');
                try
                    [lib,subsystem]=eval(cmd);
                catch E
                    fprintf('Failed to evaluate OpenFcn: %s\n',E.message)
                    success=0;
                end
            end
        end

        function portal=initPortalForSnapshot(obj)
            snapshot=GLUE2.Portal;
            snapshot.suppressBadges=true;
            snapshot.isLibraryBrowserExport=true;
            snapshot.targetContext='ShowTargetOnly';
            opts=snapshot.exportOptions;
            opts.format='SVG';
            opts.backgroundColorMode='Transparent';
            opts.sizeMode='UseSpecifiedSize';
            opts.centerWithAspectRatioForSpecifiedSize=false;
            portal=snapshot;
        end

        function initDOM(obj,hasTree)
            docNode=matlab.io.xml.dom.Document('library');
            docRootNode=docNode.getDocumentElement;
            if~isempty(obj.mTargetRelease)&&obj.mTargetRelease<=saveas_version('R2019b')

                nameAttribute=docNode.createAttribute('name');
                nameAttribute.setNodeValue(obj.mLibraryName);
                docRootNode.setAttributeNode(nameAttribute);
            end

            hasTreeAttribute=docNode.createAttribute('hasTree');
            hasTreeAttribute.setNodeValue(sprintf('%d',hasTree));
            docRootNode.setAttributeNode(hasTreeAttribute);

            versionAttribute=docNode.createAttribute('revision');
            if~isempty(obj.mTargetRelease)
                versionAttribute.setNodeValue(obj.mTargetRelease.release);
            else

                versionAttribute.setNodeValue(simulink_version().release);
            end
            docRootNode.setAttributeNode(versionAttribute);

            obj.mDocNode=docNode;
            obj.mDocRootNode=docRootNode;
        end

        function blocks=customOrderList(~,blocksIn)
            if numel(blocksIn)>1

                positions=get_param(blocksIn,'Position');
                sortedIndex=i_qsort(positions,@i_comparePositions);
                blocks=blocksIn(sortedIndex);
            else
                blocks=blocksIn;
            end
        end

        function blks=findAllBlocks(~,graphHandle)


            blks=find_system(graphHandle,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'AllBlocks','on','SearchDepth',1,'LookUnderMasks','functional','Type','Block');

            annotations=find_system(graphHandle,'FindAll','on','MatchFilter',@Simulink.match.allVariants,'SearchDepth',1,'Type','annotation','ShowInLibBrowser','on');
            if~isempty(annotations)
                objs=get_param(annotations,'Object');
                for i=1:length(objs)
                    blks=[blks;annotations(i)];%#ok
                end
            end
            if isempty(blks)
                return;
            end

            if blks(1)==graphHandle
                blks(1)=[];
            end



            if strcmpi(get_param(graphHandle,'Type'),'block')
                if strcmpi(get_param(graphHandle,'BlockType'),'SubSystem')
                    isSSaLeafBlock=slInternal('isLeafBlock',graphHandle);




                    if(~strcmpi(get_param(graphHandle,'TemplateBlock'),'')||(isSSaLeafBlock&&isempty(annotations)))
                        blks=[];
                    end
                end
            end
        end

        function show=shouldShowGraph(obj,graphHandle)
            show=false;
            if strcmp(get_param(graphHandle,'Type'),'annotation')
                show=true;
            elseif strcmpi(get_param(graphHandle,'Type'),'block')&&...
                obj.isContainedIn(get_param(graphHandle,'MaskVariables'),{'ShowInLibBrowser','LibBrowserRedirect'})
                show=true;
            end
        end

        function resultBlks=filterBlocks(obj,blks)
            resultBlks=[];
            for i=1:length(blks)
                doFilter=0;
                graphHandle=blks(i);
                if strcmp(get_param(graphHandle,'Type'),'annotation')
                    if~isempty(obj.mTargetRelease)&&isR2016aOrEarlier(obj.mTargetRelease)
                        doFilter=1;
                    else

                        if strcmp(get_param(graphHandle,'annotationType'),'area_annotation')
                            doFilter=1;
                        end
                    end
                else
                    ioType=get_param(graphHandle,'IOType');

                    if strcmpi(ioType,'viewer')||strcmpi(ioType,'siggen')
                        doFilter=1;
                    elseif~obj.shouldShowGraph(graphHandle)
                        [diffLib,lib]=obj.isInDiffLib(graphHandle);
                        if~diffLib&&isempty(lib)





                            totalBlocks=setdiff(find_system(graphHandle,'SearchDepth',1,...
                            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                            'FollowLinks','on',...
                            'LookUnderMasks','all'),graphHandle);

                            if isempty(totalBlocks)&&strcmpi(get_param(graphHandle,'Type'),'block')&&...
                                strcmpi(get_param(graphHandle,'BlockType'),'SubSystem')


                                if strcmpi(get_param(graphHandle,'Mask'),'off')||...
                                    ~obj.isContainedIn(get_param(graphHandle,'MaskVariables'),'ShowInLibBrowser')
                                    doFilter=1;
                                end
                            end
                        end
                    end
                end
                if~doFilter
                    resultBlks=[resultBlks;graphHandle];%#ok
                end
            end
        end

        function isTree=libraryHasHierarchy(obj)
            isTree=[];
            lib=obj.mLibraryName;
            slBlocksFile=LibraryBrowser.internal.getSLBlocksFile(lib);
            if~isempty(slBlocksFile)
                [~,libMdls,isFlat,~,~,~,~,~,~]=LibraryBrowser.internal.getLibInfo(slBlocksFile);

                if length(isFlat)>1


                    ind=strcmpi(libMdls,lib);
                    ind=strfind(arrayfun(@(x)isequal(x,1),ind(:,:)),1);

                    isFlat=isFlat(ind);
                end
                if isFlat>-1


                    isTree=~isFlat;
                end
            end




            if isempty(isTree)
                blks=obj.findAllBlocks(obj.mLibraryHandle);
                for i=1:length(blks)
                    kidHandle=get_param(blks(i),'Handle');

                    if obj.isaSubsystemInTree(kidHandle)
                        isTree=true;
                        return;
                    end
                end
                isTree=false;
            end
        end

        function allLeafBlks=containsAllLeafBlks(obj,graphHandle)
            allLeafBlks=true;
            if strcmp(get_param(graphHandle,'Type'),'annotation')
                return;
            end


            if strcmpi(get_param(graphHandle,'Type'),'block')&&...
                obj.isStateflowBasedBlock(graphHandle)
                return;
            end
            openFcn=get_param(graphHandle,'OpenFcn');
            if~isempty(openFcn)


                [graphHandle,closelib]=obj.processOpenFcn(graphHandle,openFcn);%#ok<ASGLU>
            end
            try
                kidBlks=obj.findAllBlocks(graphHandle);
                for i=1:length(kidBlks)
                    kidHandle=kidBlks(i);
                    if strcmp(get_param(kidHandle,'Type'),'annotation')
                        continue;
                    end
                    kidOpen=get_param(kidHandle,'OpenFcn');


                    kidOpen=obj.removeTrailingChars(kidOpen);
                    if isempty(kidOpen)
                        if~isempty(obj.findAllBlocks(kidHandle))
                            allLeafBlks=false;
                            return;
                        end
                    else
                        [kidOpen,~,success]=obj.findLibraryAndSubsystem(kidOpen);
                        if~success
                            continue;
                        end





                        if isCharOrStringScalar(kidOpen)&&exist(kidOpen,'file')==4&&obj.isBDaLibrary(kidOpen)
                            allLeafBlks=false;
                            return;
                        end
                    end
                end
            catch me
                disp(me.message);
            end
        end









        function[graphHandle,closelib]=processOpenFcn(obj,graphHandle,openFcn)
            closelib=[];
            [lib,subsystem,success]=obj.findLibraryAndSubsystem(openFcn);
            if~success
                return;
            end

            if isCharOrStringScalar(lib)
                if isvarname(lib)
                    if~bdIsLoaded(lib)
                        if exist(lib,'file')==4
                            load_system(lib);
                            closelib=onCleanup(@()close_system(lib,0));
                        else

                            return;
                        end
                    end



                end
                try
                    graphHandle=get_param(lib,'Handle');
                catch




                end
            end

            if~isempty(subsystem)&&~strcmp(subsystem,'force')&&...
                ~strcmpi(subsystem,'mask')&&~strcmp(subsystem,'parameter')
                graphHandle=get_param(subsystem,'Handle');
            end
        end



        function isaSS=isaSubsystemInTree(obj,graphHandle)
            isaSS=false;


            if strcmpi(get_param(graphHandle,'Type'),'block')&&...
                obj.isStateflowBasedBlock(graphHandle)
                return;
            end


            if~obj.isContainedIn(get_param(graphHandle,'Name'),'Examples')
                [diffLib,lib]=obj.isInDiffLib(graphHandle);
                if diffLib
                    isaSS=true;
                else
                    kidBlks=find_system(graphHandle,'MatchFilter',@Simulink.match.allVariants,'FindAll','on','SearchDepth',1,'Type','annotation','ShowInLibBrowser','on');

                    if~isempty(kidBlks)
                        if strcmpi(get_param(graphHandle,"Type"),"block")
                            isaSS=true;
                        else
                            isaSS=false;
                        end
                    else


                        blkopen=get_param(graphHandle,'OpenFcn');
                        if~diffLib&&ischar(lib)&&exist(lib,'file')==4&&~isempty(blkopen)&&obj.isBDaLibrary(lib)

                            isaSS=true;
                            return;
                        end
                        isaSS=~slInternal('isLeafBlock',graphHandle);
                    end
                end
            end
        end



        function out=encodeKidName(~,in,escape_indices)


            n_esc=numel(escape_indices);
            n_out=numel(in)+3*n_esc;
            out=char(zeros(1,n_out));
            out(1:escape_indices(1)-1)=in(1:escape_indices(1)-1);
            i=escape_indices(1);
            for j=1:n_esc
                x=escape_indices(j);
                if j==n_esc
                    y=numel(in)+1;
                else
                    y=escape_indices(j+1);
                end

                esc=dec2hex(in(x));
                new_i=i+2+numel(esc);
                out(i:new_i-1)=['@',esc,'@'];
                i=new_i;

                n=y-x-1;
                out(i:i+n-1)=in(x+1:y-1);
                i=i+n;
            end


            if n_out>=i
                out=out(1:i-1);
            end
        end

        function buildTree(obj,graphHandle,iconDir,parentNode,parentHasHierarchy)
            assert(iconDir(end)==filesep);
            [diffLib,lib]=obj.isInDiffLib(graphHandle);
            if~diffLib


                if~exist(iconDir,'dir')
                    mkdir(iconDir);
                end
                blks=obj.findAllBlocks(graphHandle);
                blks=obj.filterBlocks(blks);
                blks=obj.customOrderList(blks);

                lenBlks=length(blks);
                if lenBlks>0
                    graphObj=get_param(graphHandle,'Object');



                    mdlDiagramPair=SLM3I.Util.getDiagram(graphObj.getFullName);%#ok
                    for i=1:lenBlks
                        kidHandle=blks(i);
                        if strcmp(get_param(kidHandle,'Type'),'annotation')

                            kidName=[tempname(iconDir),'Annotation'];
                            blkIconPath=[kidName,'.svg'];
                        else
                            tmpKidName=get_param(kidHandle,'Name');

                            [~,indices]=regexp(tmpKidName,'[^0-9a-zA-Z]','match');


                            if isempty(indices)
                                kidName=tmpKidName;
                            else
                                kidName=obj.encodeKidName(tmpKidName,indices);
                            end
                            blkIconPath=[iconDir,kidName,'.svg'];
                        end


                        blkIconRelPath=blkIconPath(numel(obj.mRootFolder)+1:end);
                        if ispc
                            blkIconRelPath=strrep(blkIconRelPath,filesep,'/');
                        end

                        kidHasHierarchy=~obj.containsAllLeafBlks(kidHandle);


                        [currNode,isNodeInTree]=obj.addNodeToXML(kidHandle,parentNode,blkIconRelPath,kidHasHierarchy);
                        if isNodeInTree&&parentHasHierarchy
                            kidIconDir=[iconDir,kidName,filesep];
                            obj.buildTree(kidHandle,kidIconDir,currNode,kidHasHierarchy);
                        else




                            find_system(kidHandle,'FollowLinks','on',...
                            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                            'LookUnderMasks','all');
                        end

                        obj.addFile(blkIconPath);
                        try
                            obj.generateSVG(kidHandle,blkIconPath,isNodeInTree&&parentHasHierarchy);
                        catch E
                            fprintf('Error generating image %s: %s\n',blkIconPath,E.message);
                            mdlDiagramPair=[];%#ok
                        end
                    end
                    mdlDiagramPair=[];%#ok
                end
            else



                obj.mOtherLibraries{end+1}=lib;
            end
        end



        function[currNode,blk_isNotLeafBlk]=addNodeToXML(obj,slHandle,parentNode,blkIconPath,hasTree)
            docNode=obj.mDocNode;
            blk_name=get_param(slHandle,'Name');
            blk_path=getfullname(slHandle);
            ref_block='';
            if isempty(obj.mTargetRelease)||obj.mTargetRelease>saveas_version('R2019b')



                nameLen=numel(obj.mLibraryName);
                if strncmp(blk_path,[obj.mLibraryName,'/'],nameLen+1)
                    blk_path=['$bdroot',blk_path(nameLen+1:end)];
                end
            end
            sid=get_param(slHandle,'SID');
            if strcmp(get_param(slHandle,'Type'),'annotation')
                blk_desc=get_param(slHandle,'Description');
                blk_class=get_param(slHandle,'Type');
                blk_open=blk_path;
                blk_type=blk_class;

                blkElement=docNode.createElement('annotation_node');
                keyword_name='TBD';
            else
                keyword_name=get_param(slHandle,'BlockKeywords');
                keyword_name=join(keyword_name,',');

                blk_type=get_param(slHandle,'BlockType');
                ref_block=get_param(slHandle,'ReferenceBlock');


                if(strcmpi(get_param(slHandle,'Mask'),'on'))
                    blk_desc=get_param(slHandle,'MaskDescription');
                    blk_class=get_param(slHandle,'MaskType');
                else
                    blk_desc=get_param(slHandle,'BlockDescriptionMID');
                    blk_class=get_param(slHandle,'BlockType');
                end



                blkOpenFcn=get_param(slHandle,'OpenFcn');
                if isempty(blkOpenFcn)
                    blk_open=blk_path;
                else

                    blkOpenFcn=obj.removeTrailingChars(blkOpenFcn);


                    [blkOpenFcn,~]=obj.processOpenSystemInfo(blkOpenFcn);
                    blk_open=blkOpenFcn;
                end

                hasTreeAttribute=docNode.createAttribute('hasTree');
                if hasTree
                    hasTreeAttribute.setNodeValue('1');
                else
                    hasTreeAttribute.setNodeValue('0');
                end

                blkElement=docNode.createElement('block_node');
                blkElement.setAttributeNode(hasTreeAttribute);
            end

            sidAttribute=docNode.createAttribute('SID');
            sidAttribute.setNodeValue(sid);
            blkElement.setAttributeNode(sidAttribute);

            blk_path=strrep(blk_path,newline,'\n');

            blk_position=get_param(slHandle,'Position');

            blk_isNotLeafBlk=obj.isaSubsystemInTree(slHandle);

            formatted_blk_port_domains=obj.generatePortDomainValues(slHandle,blk_isNotLeafBlk);

            blkName=docNode.createElement('block_name');
            blkClass=docNode.createElement('block_class');
            blkDesc=docNode.createElement('block_desc');
            blkPath=docNode.createElement('block_path');
            blkOpen=docNode.createElement('block_open');
            blkisNotLeafBlk=docNode.createElement('block_isNotLeafBlk');
            blkPosition=docNode.createElement('block_position');
            svgPath=docNode.createElement('block_icon');
            portdomains=docNode.createElement('port_domains');
            keys=docNode.createElement('keywords');
            blkType=docNode.createElement('block_type');
            blkReferenceBlock=docNode.createElement('block_reference');

            blkName.appendChild(docNode.createTextNode(strrep(blk_name,newline,'\n')));
            blkClass.appendChild(docNode.createTextNode(blk_class));
            blkDesc.appendChild(docNode.createTextNode(blk_desc));
            blkPath.appendChild(docNode.createTextNode(blk_path));
            blkOpen.appendChild(docNode.createTextNode(blk_open));
            if blk_isNotLeafBlk
                blkisNotLeafBlk.appendChild(docNode.createTextNode('1'));
            else
                blkisNotLeafBlk.appendChild(docNode.createTextNode('0'));
            end
            blkPosition.appendChild(docNode.createTextNode(num2str(blk_position)));
            svgPath.appendChild(docNode.createTextNode(blkIconPath));
            keys.appendChild(docNode.createTextNode(keyword_name));
            portdomains.appendChild(docNode.createTextNode(formatted_blk_port_domains));
            blkType.appendChild(docNode.createTextNode(blk_type));
            blkReferenceBlock.appendChild(docNode.createTextNode(ref_block));

            parentNode.appendChild(blkElement);
            blkElement.appendChild(blkName);
            blkElement.appendChild(blkClass);
            blkElement.appendChild(blkDesc);
            blkElement.appendChild(blkPath);
            blkElement.appendChild(blkOpen);
            blkElement.appendChild(blkisNotLeafBlk);
            blkElement.appendChild(blkPosition);
            blkElement.appendChild(svgPath);
            blkElement.appendChild(keys);
            blkElement.appendChild(portdomains);
            blkElement.appendChild(blkType);
            blkElement.appendChild(blkReferenceBlock);

            currNode=blkElement;
        end












        function formatted_port_domain_values=generatePortDomainValues(obj,graphHandle,blk_isNotLeafBlk)

            if isempty(obj.mTargetRelease)

                formatted_port_domain_values=obj.generate15bPortDomainValues(graphHandle,blk_isNotLeafBlk);
            elseif isR2015a(obj.mTargetRelease)

                formatted_port_domain_values=obj.generate15aPortDomainValues(graphHandle,blk_isNotLeafBlk);
            elseif isR2014bOrEarlier(obj.mTargetRelease)

                formatted_port_domain_values='';
            else




                formatted_port_domain_values=obj.generate15bPortDomainValues(graphHandle,blk_isNotLeafBlk);
            end
        end



        function formatted_port_domain_values=generate15bPortDomainValues(obj,graphHandle,blk_isNotLeafBlk)
            formatted_port_domain_values='NA.NA:0';
            if strcmp(get_param(graphHandle,'Type'),'annotation')
                return;
            end
            if(~blk_isNotLeafBlk)


                port_info=get_param(graphHandle,'PortHandles');


                if(slfeature('SupportResetWithInit')>0)
                    assert(numel(fieldnames(port_info))==10);
                else
                    assert(numel(fieldnames(port_info))==9);
                end

                port_dom_type_list=containers.Map();

                lconn_len=length(port_info.LConn);
                if lconn_len~=0
                    lconn_list=builtin('_get_port_type_for_block_search',port_info.LConn);
                    if~iscell(lconn_list)
                        lconn_list={lconn_list};
                    end
                    for conn_index=1:lconn_len
                        elem=lconn_list{conn_index};
                        if port_dom_type_list.isKey(elem)
                            port_dom_type_list(elem)=port_dom_type_list(elem)+1;
                        else
                            port_dom_type_list(elem)=1;
                        end
                    end
                end

                rconn_len=length(port_info.RConn);
                if rconn_len~=0
                    rconn_list=builtin('_get_port_type_for_block_search',port_info.RConn);
                    if~iscell(rconn_list)
                        rconn_list={rconn_list};
                    end
                    for conn_index=1:rconn_len
                        elem=rconn_list{conn_index};
                        if port_dom_type_list.isKey(elem)
                            port_dom_type_list(elem)=port_dom_type_list(elem)+1;
                        else
                            port_dom_type_list(elem)=1;
                        end
                    end
                end


                if(~isempty(port_dom_type_list))
                    port_dom_type_list('connection.all')=lconn_len+rconn_len;
                end



                num_out_sig_and_msg_port=numel(port_info.Outport)+numel(port_info.State);


                outport_message_mode=get_param(port_info.Outport,'MessageMode');
                logical_outport_message_mode=ismember(outport_message_mode,"on");
                num_outport_message_mode=sum(logical_outport_message_mode(:)==1);


                num_pure_sig_port=num_out_sig_and_msg_port-num_outport_message_mode;





                if obj.isThisSimulinkBlockSimEventsCompatible(graphHandle)
                    num_outport_message_mode=num_outport_message_mode+num_pure_sig_port;
                end

                if num_out_sig_and_msg_port>0
                    if(num_outport_message_mode>0)
                        port_dom_type_list('message.out_message')=num_outport_message_mode;
                    end
                    if(num_pure_sig_port>0)
                        port_dom_type_list('signal.out_signal')=num_pure_sig_port;
                    end
                end



                num_in_sig_and_msg_port=numel(port_info.Inport)+numel(port_info.Enable)+...
                numel(port_info.Trigger)+numel(port_info.Ifaction)+...
                numel(port_info.Reset);

                if(slfeature('SupportResetWithInit')>0)
                    num_in_sig_and_msg_port=num_in_sig_and_msg_port+numel(port_info.Event);
                end


                inport_message_mode=get_param(port_info.Inport,'MessageMode');
                logical_inport_message_mode=ismember(inport_message_mode,"on");
                num_inport_message_mode=sum(logical_inport_message_mode(:)==1);


                num_pure_sig_port=num_in_sig_and_msg_port-num_inport_message_mode;

                if obj.isThisSimulinkBlockSimEventsCompatible(graphHandle)
                    num_inport_message_mode=num_inport_message_mode+num_pure_sig_port;
                end
                if num_in_sig_and_msg_port>0
                    if(num_inport_message_mode>0)
                        port_dom_type_list('message.in_message')=num_inport_message_mode;
                    end
                    if(num_pure_sig_port>0)
                        port_dom_type_list('signal.in_signal')=num_pure_sig_port;
                    end
                end


                key_list=port_dom_type_list.keys();
                if~isempty(key_list)
                    values=cell(size(key_list));
                    for i=1:numel(values)
                        values{i}=[key_list{i},':',sprintf('%d',port_dom_type_list(key_list{i})),','];
                    end
                    formatted_port_domain_values=[values{:}];
                    formatted_port_domain_values(end)=[];
                end
            end
        end



        function formatted_port_domain_values=generate15aPortDomainValues(~,graphHandle,blk_isNotLeafBlk)
            formatted_port_domain_values='N.A.';
            if strcmp(get_param(graphHandle,'Type'),'annotation')
                return;
            end
            if(~blk_isNotLeafBlk)
                blk_port_domains={};


                port_info=get_param(graphHandle,'PortHandles');
                blk_port_domains=union(blk_port_domains,builtin('_get_port_type_for_block_search',port_info.LConn));
                blk_port_domains=union(blk_port_domains,builtin('_get_port_type_for_block_search',port_info.RConn));


                if(~isempty(blk_port_domains))
                    blk_port_domains={blk_port_domains{:},'connection'};%#ok<CCAT>
                end





                port_info_fields=fieldnames(port_info);
                out_sig_covered=false;
                in_sig_covered=false;
                for port_field_iter=1:numel(port_info_fields)

                    if(strcmp(port_info_fields{port_field_iter},'LConn')||...
                        strcmp(port_info_fields{port_field_iter},'RConn'))
                        continue;
                    end

                    if~isempty(port_info.(port_info_fields{port_field_iter}))
                        if(strcmp(port_info_fields{port_field_iter},'Outport')||...
                            strcmp(port_info_fields{port_field_iter},'State'))

                            if(~out_sig_covered)
                                blk_port_domains={blk_port_domains{:},'out_signal'};%#ok<CCAT>
                            end
                            out_sig_covered=true;
                        else
                            if(~in_sig_covered)
                                blk_port_domains={blk_port_domains{:},'in_signal'};%#ok<CCAT>
                            end
                            in_sig_covered=true;
                        end
                        if(in_sig_covered&&out_sig_covered)
                            break;
                        end
                    end
                end


                for index=1:length(blk_port_domains)
                    if(strcmp(formatted_port_domain_values,'N.A.'))
                        formatted_port_domain_values=blk_port_domains{index};
                    else
                        formatted_port_domain_values=[formatted_port_domain_values,',',blk_port_domains{index}];%#ok<AGROW>
                    end
                end
            end
        end

        function generateSVG(obj,graphHandle,blkIconPath,isSubsys)
            snapshot=obj.initPortalForSnapshot();
            element=SLM3I.SLDomain.handle2DiagramElement(graphHandle);
            if strcmp(get_param(graphHandle,'Type'),'annotation')


                target='NA';
                snapshot.setTarget('Simulink',graphHandle);
            else
                target=element.getFullPathName;
                snapshot.setTarget('Simulink',target);
            end

            if isSubsys&&strncmp(target,'simulink/',9)

                snapshot.excludeFilters={'BlockName','port'};
            else
                snapshot.excludeFilters={'BlockName'};
            end
            snapshot.exportOptions.fileName=blkIconPath;
            w=snapshot.targetSceneRect(3);
            h=snapshot.targetSceneRect(4);
            opts=snapshot.exportOptions;
            snapshot.targetOutputRect=[0,0,w,h];
            opts.size=[w,h];
            snapshot.export();
        end

        function files=writeToXML(obj,files)
            xmlFileName=slfullfile(obj.mRootFolder,'slLibraryBrowser.xml');
            writer=matlab.io.xml.dom.DOMWriter;
            writeToURI(writer,obj.mDocNode,xmlFileName);
            obj.mRepositoryFiles{end+1}=xmlFileName;
        end

        function openFcn=removeTrailingChars(~,blkOpenFcn)

            openFcn=strrep(blkOpenFcn,';','');

            openFcn=strrep(openFcn,newline,'');
        end

        function addFile(obj,file)
            obj.mRepositoryFiles{end+1}=file;
        end
    end
end

function[varargout]=i_parseArgs(varargin)%#ok
    [varargout{1:nargin}]=varargin{:};
    i=nargin+1;
    while i<(nargout+1)
        varargout{i}=[];
        i=i+1;
    end
end

function x=i_comparePositions(a,b)

    if max(a(2),b(2))<min(a(4),b(4))

        x=b(1)-a(1);
    else

        x=b(2)-a(2);
    end
end


function index=i_qsort(vector,compfunc)







    m=length(vector);
    index=1:m;
    sort_r(1,m);

    function sort_r(a,b)
        high=b;
        mid=fix((a+b)/2);
        temp=index(mid);
        index(mid)=index(a);
        index(a)=temp;
        pp=a;
        while(pp<high)
            if(iscell(vector))
                res=compfunc(vector{index(pp)},vector{index(pp+1)});
            else
                res=compfunc(vector(index(pp)),vector(index(pp+1)));
            end
            if(res==0)
                res=randi(2)-1;
            end
            if(res<=0)
                temp=index(pp);
                index(pp)=index(pp+1);
                index(pp+1)=temp;
                pp=pp+1;
            elseif(res>0)
                temp=index(pp+1);
                index(pp+1)=index(high);
                index(high)=temp;
                high=high-1;
            end
        end
        if(pp-1-a>0)
            sort_r(a,pp-1);
        end
        if(b-pp-1>0)
            sort_r(pp+1,b);
        end
    end
end

function isAChar=isCharOrStringScalar(c)
    isAChar=ischar(c)||(isstring(c)&&isscalar(c));
end

