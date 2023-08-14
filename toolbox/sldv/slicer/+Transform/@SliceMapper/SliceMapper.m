classdef SliceMapper<handle





    properties(GetAccess=public,SetAccess=protected)
        origMdlName;
        sliceMdlName;


        inlineSIDLibFirst;
        inlineSIDMdlRefFirst;
        inlineSIDlast;

        sliceSubsystem='';
        sliceRootSys='';
    end



    properties(GetAccess=public,SetAccess=protected,Transient=true)
        origIsLoaded;
        sliceIsLoaded;
        origMdlH;

        origTopMdlBlkMap;
        sliceMdlBlkMap;









        refMdlInfo;







        inlinedMdlRefSys;
    end



    properties(Access=protected)
        sidOrigMdlXforms;
        sidSliceMdlXforms;

        sidRefMdlInfo;
        sidInlinedMdlRefSysInfo;
    end


    properties(Hidden=true,Access=protected)
        dirty=false;
    end
    properties(Access=protected,Dependent=true)
isMdlBlkSlice
    end
    methods
        function yesno=get.isMdlBlkSlice(this)
            yesno=~isempty(this.sliceSubsystem)&&...
            Simulink.SubsystemType.isModelBlock(this.sliceSubsystem);
        end
    end

    methods(Access=protected)
        function init_props(this)
            this.refMdlInfo=containers.Map('KeyType','char','ValueType','any');
            this.sliceMdlBlkMap=containers.Map('KeyType','double','ValueType','any');
            this.origTopMdlBlkMap=containers.Map('KeyType','double','ValueType','any');
            this.inlinedMdlRefSys=containers.Map('KeyType','double','ValueType','any');
        end

        function clearsidtables(this)
            if(this.sliceIsLoaded&&this.origIsLoaded)

                this.sidOrigMdlXforms=[];
                this.sidSliceMdlXforms=[];

                this.dirty=true;
            end
        end


        function updateSidTables(this)

            this.sidOrigMdlXforms=encode_blkmap_as_cell(...
            this.origTopMdlBlkMap,@sid_encode_vect);


            this.sidSliceMdlXforms=encode_blkmap_as_cell(...
            this.sliceMdlBlkMap,@sid_encode_vect);

            this.sidInlinedMdlRefSysInfo=encode_blkmap_as_cell(...
            this.inlinedMdlRefSys,@identity);

            refModels=this.refMdlInfo.keys();
            refInfos=this.refMdlInfo.values();
            mdlCnt=numel(refModels);

            for idx=1:mdlCnt
                map=refInfos{idx}.blockMap;
                mapcell=encode_blkmap_as_cell(map,@sid_encode_vect);
                refInfos{idx}.blockSidCell=mapcell;
                refInfos{idx}.blockMap=[];
                refInfos{idx}.sidMdlRefBlk=sid_block(refInfos{idx}.mdlRefBlkH);
                refInfos{idx}.mdlRefBlkH=[];
            end

            allRefInfo=cell(1,2*mdlCnt);
            allRefInfo(1:2:end)=refModels;
            allRefInfo(2:2:end)=refInfos;

            this.sidRefMdlInfo=allRefInfo;

            this.dirty=false;
        end

        function loadSlice(this)
            this.sliceIsLoaded=true;
            if this.origIsLoaded
                this.convert2handles();
            end
        end

        function loadOrig(this)
            this.origIsLoaded=true;
            if this.sliceIsLoaded
                this.convert2handles();
            end
        end

        function convert2handles(this)
            this.origTopMdlBlkMap=map_from_nested_sidcell(this.sidOrigMdlXforms,...
            this.origMdlName,this.sliceMdlName);
            this.sliceMdlBlkMap=map_from_nested_sidcell(this.sidSliceMdlXforms,...
            this.sliceMdlName,this.origMdlName);

            this.inlinedMdlRefSys=blkmap_from_cell_array(...
            this.sidInlinedMdlRefSysInfo,@identity,this.sliceMdlName);

            allRefInfo=this.sidRefMdlInfo;

            if isempty(allRefInfo)
                this.refMdlInfo=containers.Map('KeyType','char','ValueType','any');
            else
                refModels=allRefInfo(1:2:end);
                refInfos=allRefInfo(2:2:end);

                for idx=1:numel(refInfos)
                    if(isModelLoaded(refModels{idx}))
                        sidcell=refInfos{idx}.blockSidCell;
                        map=map_from_nested_sidcell(this.sidSliceMdlXforms,...
                        this.sliceMdlName,refModels{idx});
                        refInfos{idx}.blockMap=map;
                        if isfield(refInfos{idx},'sidMdlRefBlk')
                            refInfos{idx}.mdlRefBlkH=sid_ext_obj(refInfos{idx}.sidMdlRefBlk,'');
                        else
                            refInfos{idx}.mdlRefBlkH=[];
                        end
                    end
                end

                this.refMdlInfo=containers.Map(refModels,refInfos);
            end
        end


        function[refMdlName,refPathIdx]=inlineMdlRefInfo(this,blkH)
            if this.inlinedMdlRefSys.isKey(blkH)
                info=this.inlinedMdlRefSys(blkH);
                refMdlName=info{1};
                refPathIdx=info{2};
            else



                parentH=get_param(get_param(blkH,'Parent'),'Handle');
                [refMdlName,refPathIdx]=this.inlineMdlRefInfo(parentH);
                if strcmp(get_param(blkH,'BlockType'),'Subsystem')
                    this.inlinedMdlRefSys(blkH)={refMdlName,refPathIdx};
                end
            end
        end


        function blkH_map=remap_by_path(this,blkH,newPrefix,charIdx)%#ok<INUSL>
            if nargin<4
                charIdx=0;
            end

            fullpath=getfullname(blkH);

            if charIdx>0
                pathsuffix=fullpath(charIdx:end);

                if isempty(pathsuffix)


                    mdlInfo=this.refMdlInfo(newPrefix);
                    if~isempty(mdlInfo)
                        blkH_map=mdlInfo.mdlRefBlkH;
                        return;
                    end
                end
            else
                [~,pathsuffix]=strtok(fullpath,'/');
            end

            newpath=[newPrefix,pathsuffix];
            try
                blkH_map=get_param(newpath,'Handle');
            catch Mex
                blkH_map=[];
            end
        end



        function[blkH_map,inlined]=remap_blksid(this,sidstr,blkH,newMdlName,fromSlice)
            if nargin<4
                fromSlice=false;
            end

            inlined=false;
            [~,wholesuffix]=strtok(sidstr,':');
            firstNum=strtok(wholesuffix(2:end),':');

            reuseSidNumber=false;

            if(fromSlice)



                sidNumber=str2double(firstNum);
                if this.isMdlBlkSlice&&(sidNumber<=this.inlineSIDMdlRefFirst)



                    if blkH==get_param(this.sliceRootSys,'handle')
                        blkH_map=get_param(this.sliceSubsystem,'handle');
                    else
                        mdlName=get_param(this.sliceSubsystem,'ModelName');
                        inlined=true;
                        blkH_map=this.remap_by_path(blkH,mdlName,length(this.sliceRootSys)+1);
                    end
                elseif(sidNumber==0)

                    blkH_map=this.remap_by_path(blkH,newMdlName);

                elseif(sidNumber<=this.inlineSIDLibFirst)


                    reuseSidNumber=true;

                elseif(sidNumber<=this.inlineSIDMdlRefFirst)



                    inlined=true;
                    blkH_map=this.remap_by_path(blkH,newMdlName);

                elseif(sidNumber<=this.inlineSIDlast)



                    inlined=true;

                    [refMdlName,refPathIdx]=this.inlineMdlRefInfo(blkH);
                    if isempty(refMdlName)
                        blkH_map=[];
                    else
                        blkH_map=this.remap_by_path(blkH,refMdlName,refPathIdx);
                    end

                else




                    reuseSidNumber=true;
                end
            else
                if this.is_an_implicit_link(blkH)

                    blkH_map=this.remap_by_path(blkH,newMdlName);
                else

                    reuseSidNumber=true;
                end
            end

            if reuseSidNumber
                if slfeature('UnifiedHarnessExtract')>0&&~isempty(this.sliceSubsystem)
                    newsid=Simulink.harness.internal.sidmap.getExtractedModelObjectSID(sidstr,...
                    this.sliceSubsystem,newMdlName);
                else
                    newsid=[newMdlName,wholesuffix];
                end

                if Simulink.ID.isValid(newsid)
                    blkH_map=Simulink.ID.getHandle(newsid);
                else


                    if strcmp(get_param(blkH,'BlockType'),'ModelReference')
                        refMdlName=get_param(blkH,'ModelName');
                        if this.refMdlInfo.isKey(refMdlName)
                            refInfo=this.refMdlInfo(refMdlName);
                        else
                            refInfo=[];
                        end
                        if isempty(refInfo)
                            blkH_map=[];
                        else
                            blkH_map=refInfo.sliceSubsysH;
                            if(refInfo.InlinedWithNewSubsys)
                                blkH_map=get_param(get_param(blkH_map,'parent'),'handle');
                            end
                            if~ishandle(blkH_map)
                                blkH_map=[];
                            end
                        end
                    else

                        blkH_map=[];
                    end
                end
            end

            if isempty(blkH_map)
                inlined=[];
            end
        end

        function isImplicit=is_an_implicit_link(this,blockH)%#ok<INUSL>
            parentObj=get_param(get_param(blockH,'Parent'),'Object');
            isImplicit=false;
            if isa(parentObj,'Simulink.Block')
                if~isempty(parentObj.ReferenceBlock)...
                    ||(isa(parentObj,'Simulink.SubSystem')&&~isempty(parentObj.TemplateBlock))
                    isImplicit=true;
                end
            end
        end

        function[blkH_map,inlined]=remap_blk_using_sid(this,blkH,newMdlName,fromSlice)
            sid=Simulink.ID.getSID(blkH);

            blkH_map=[];
            inlined=[];


            if this.sliceMdlBlkMap.isKey(blkH)
                blkH_map=this.sliceMdlBlkMap(blkH);
            elseif~isempty(sid)
                [blkH_map,inlined]=this.remap_blksid(sid,blkH,newMdlName,fromSlice);
            end
        end


        function[mapH,inlined]=remap_using_sids(this,objH,newMdlName,fromSlice)
            if nargin<4
                fromSlice=false;
            end

            objType=get_param(objH,'Type');

            switch(objType)
            case 'block'
                [mapH,inlined]=this.remap_blk_using_sid(objH,newMdlName,fromSlice);

            case 'port'
                [pType,pIdx,blkH]=port_attribs(objH);
                [mapBlkH,inlined]=this.remap_blk_using_sid(blkH,newMdlName,fromSlice);

                if~isempty(mapBlkH)
                    if strcmp(get_param(mapBlkH,'type'),'block_diagram')
                        mapBlkH=this.remap_by_path(blkH,newMdlName);
                    end
                    try
                        mapH=get_port(mapBlkH,pType,pIdx);
                    catch
                        mapH=[];
                    end
                else
                    mapH=[];
                end

            case 'line'
                mapH=[];
                srcPortH=get_param(objH,'SrcPortHandle');
                [pType,pIdx,blkH]=port_attribs(srcPortH);
                [mapBlkH,inlined]=this.remap_blk_using_sid(blkH,newMdlName,fromSlice);

                if~isempty(mapBlkH)
                    if strcmp(get_param(mapBlkH,'type'),'block_diagram')
                        mapBlkH=this.remap_by_path(blkH,newMdlName);
                    end
                    try
                        newPortH=get_port(mapBlkH,pType,pIdx);
                    catch
                        newPortH=[];
                    end

                    if~isempty(newPortH)
                        mapH=get_param(newPortH,'Line');
                    end
                end

            otherwise
                mapH=[];
                inlined=[];
            end
        end
    end

    methods(Static=true)

        function this=loadobj(s)
            if isstruct(s)
                this=Transform.SliceMapper(s.origMdlName,s.sliceMdlName);

                this.inlineSIDLibFirst=s.inlineSIDLibFirst;
                this.inlineSIDMdlRefFirst=s.inlineSIDMdlRefFirst;
                this.inlineSIDlast=s.inlineSIDlast;
                this.sidOrigMdlXforms=s.sidOrigMdlXforms;
                this.sidSliceMdlXforms=s.sidSliceMdlXforms;
                this.sidRefMdlInfo=s.sidRefMdlInfo;
                this.sidInlinedMdlRefSysInfo=s.sidInlinedMdlRefSysInfo;
                if isfield(s,'sliceSubsystem')&&isfield(s,'sliceRootSys')
                    this.sliceSubsystem=s.sliceSubsystem;
                    this.sliceRootSys=s.sliceRootSys;
                end
            else
                this=s;
            end

            this.origIsLoaded=isModelLoaded(this.origMdlName);
            if(this.origIsLoaded)
                this.origMdlH=get_param(this.origMdlName,'Handle');
            end

            this.sliceIsLoaded=isModelLoaded(this.sliceMdlName);

            if(this.origIsLoaded&&this.sliceIsLoaded)
                this.convert2handles();
            end
        end
    end


    methods(Access=public)

        function this=SliceMapper(origName,sliceName)
            this.origMdlName=origName;

            try
                this.origMdlH=get_param(this.origMdlName,'Handle');
            catch Mex
            end

            this.sliceMdlName=sliceName;
            this.origIsLoaded=true;
            this.sliceIsLoaded=true;
            this.init_props();
        end

        function s=saveobj(this)
            s.origMdlName=this.origMdlName;
            s.sliceMdlName=this.sliceMdlName;
            s.inlineSIDLibFirst=this.inlineSIDLibFirst;
            s.inlineSIDMdlRefFirst=this.inlineSIDMdlRefFirst;
            s.inlineSIDlast=this.inlineSIDlast;

            if this.dirty
                this.updateSidTables();
            end
            s.sidOrigMdlXforms=this.sidOrigMdlXforms;
            s.sidSliceMdlXforms=this.sidSliceMdlXforms;
            s.sidRefMdlInfo=this.sidRefMdlInfo;
            s.sidInlinedMdlRefSysInfo=this.sidInlinedMdlRefSysInfo;

            s.sliceSubsystem=this.sliceSubsystem;
            s.sliceRootSys=this.sliceRootSys;
        end


        function inlineMdlRefBlk(this,mdlRefPath,newSubsysH,refModelName,...
            mdlRefBlkH,refMdlIsInlinedWithNewSubsys)

            info=struct(...
            'modelname',refModelName,...
            'blockMap',containers.Map('KeyType','double','ValueType','any'),...
            'sliceSubsysH',newSubsysH,...
            'sliceSubsysPath',getfullname(newSubsysH),...
            'mdlRefBlkH',mdlRefBlkH,...
            'InlinedWithNewSubsys',false);

            charIdx=numel(mdlRefPath)+1;





            if refMdlIsInlinedWithNewSubsys
                innerSubSysH=get_param(Sldv.xform.getChildSubSystem(newSubsysH),'handle');
                innerSubSysName=get_param(innerSubSysH,'name');
                if contains(innerSubSysName,'sldvBlockReplacement')

                    charIdx=charIdx+length(innerSubSysName)+1;

                    info.sliceSubsysH=innerSubSysH;
                    info.sliceSubsysPath=getfullname(innerSubSysH);
                    info.InlinedWithNewSubsys=true;
                end
            end

            this.refMdlInfo(refModelName)=info;

            this.inlinedMdlRefSys(newSubsysH)={refModelName,charIdx};
        end

        function setInlinedSIDRange(this,inlineSIDLibFirst,inlineSIDMdlRefFirst,inlineSIDlast)
            this.inlineSIDLibFirst=inlineSIDLibFirst;
            this.inlineSIDMdlRefFirst=inlineSIDMdlRefFirst;
            this.inlineSIDlast=inlineSIDlast;


        end


        function origDeletion(this,origMdlHs)%#ok<INUSD>



            this.dirty=true;
        end

        function origTransform(this,origMdlH,sliceMdlHs,make2way)
            if nargin<4
                make2way=false;
            end



            mdlH=bdroot(origMdlH);
            if isempty(this.sliceSubsystem)
                isTopModel=(mdlH==this.origMdlH);
            else

                if~isempty(this.sliceSubsystem)&&...
                    Simulink.SubsystemType.isModelBlock(this.sliceSubsystem)
                    topMdlH=get_param(get_param(this.sliceSubsystem,'ModelName'),'Handle');
                else
                    topMdlH=get_param(bdroot(this.sliceSubsystem),'Handle');
                end
                isTopModel=(mdlH==topMdlH);
            end


            if isTopModel
                this.origTopMdlBlkMap(origMdlH)=sliceMdlHs;
            else
                refMdlName=get_param(mdlH,'Name');
                info=this.refMdlInfo(refMdlName);
                info.blockMap(origMdlH)=origMdlH;
            end

            if make2way



                for obj=sliceMdlHs
                    if this.sliceMdlBlkMap.isKey(obj)
                        origitms=this.sliceMdlBlkMap(obj);
                        origitms(end+1)=origMdlH;%#ok<AGROW>
                    else
                        origitms=origMdlH;
                    end
                    this.sliceMdlBlkMap(obj)=origitms;
                end
            end
            this.dirty=true;
        end

        function transformBlk(this,sliceBlkSid,sliceBlkH,sliceMdlHs)



            origblkH=this.remap_blksid(sliceBlkSid,sliceBlkH,this.origMdlName,true);
            this.origTransform(origblkH,sliceMdlHs);
        end

        function deletion(this,sliceMdlHs)%#ok<INUSD>








        end

        function deleteInsertedMap(this,sliceHs)
            for obj=sliceHs
                if isKey(this.sliceMdlBlkMap,obj)
                    keyInOrig=this.sliceMdlBlkMap(obj);

                    remove(this.sliceMdlBlkMap,obj);
                    if isKey(this.origTopMdlBlkMap,keyInOrig)

                        remove(this.origTopMdlBlkMap,keyInOrig);
                    end
                end
            end
        end

        function mapInlinedExpanded(this,sliceMdlHs,origContentsHs)
            for idx=1:numel(sliceMdlHs)
                obj=sliceMdlHs(idx);
                origH=origContentsHs(idx);
                this.origTransform(origH,obj,true);
            end
        end


        function insertion(this,sliceMdlHs)%#ok<INUSD>



            this.dirty=true;
        end

        function setSliceSubsystem(this,subsys,rootSys)

            if ischar(subsys)
                this.sliceSubsystem=subsys;
            else
                this.sliceSubsystem=getfullname(subsys);
            end
            this.sliceRootSys=[rootSys,'/',get_param(subsys,'Name')];
        end




        function origH=findInOrigByPath(this,sliceMdlH)
            origH=this.remap_by_path(sliceMdlH,this.origMdlName);
        end

        function[items,isInlined]=findInOrig(this,sliceMdlHs)
            items=[];
            isInlined=[];

            for objH=sliceMdlHs
                inlined=false;
                if this.sliceMdlBlkMap.isKey(objH)
                    origH=this.sliceMdlBlkMap(objH);
                else
                    [origH,inlined]=this.remap_using_sids(objH,this.origMdlName,true);
                end

                if~isempty(origH)
                    if~isempty(this.sliceSubsystem)&&...
                        ~this.isMdlBlkSlice

                        origParent=get_param(bdroot(origH),'Name');
                        subSys=this.sliceSubsystem;
                        subSysParent=get_param(bdroot(subSys),'Name');
                        if strcmpi(origParent,subSysParent)

                            origName=getfullname(origH);
                            if origH~=get_param(subSys,'handle')&&...
                                ~strncmp([subSys,'/'],origName,length(subSys)+1)

                                origH=[];
                            end
                        end
                    end

                    items=[items,origH];%#ok<AGROW>
                    isInlined=[isInlined,inlined];%#ok<AGROW>
                end
            end
        end

        function items=findInSlice(this,origMdlHs,refModelName)

            if(nargin<3||isempty(refModelName))
                blockMap=this.origTopMdlBlkMap;
                if this.isMdlBlkSlice
                    isTopModel=false;
                    subPath=this.sliceRootSys;
                else
                    isTopModel=true;
                end
            else
                if this.refMdlInfo.isKey(refModelName)
                    refInfo=this.refMdlInfo(refModelName);
                    blockMap=refInfo.blockMap;
                    isTopModel=false;
                    subPath=refInfo.sliceSubsysPath;
                elseif this.isMdlBlkSlice
                    blockMap=this.origTopMdlBlkMap;
                    isTopModel=false;
                    subPath=this.sliceRootSys;
                else

                    items=[];
                    return;
                end
            end

            items=[];

            for objH=origMdlHs
                if strcmp(this.sliceSubsystem,getfullname(objH))
                    sliceHs=get_param(this.sliceRootSys,'handle');
                elseif blockMap.isKey(objH)
                    sliceHs=blockMap(objH);
                else
                    if isTopModel
                        if~isempty(this.sliceSubsystem)&&...
                            ~startsWith(getfullname(objH),this.sliceSubsystem)



                            continue;
                        end
                        sliceHs=this.remap_using_sids(objH,this.sliceMdlName,false);
                    else
                        sliceHs=this.remap_by_path(objH,subPath);
                    end
                end

                if~isempty(sliceHs)
                    items=[items,sliceHs];%#ok<AGROW>
                end
            end
        end


        highlightModelObject(this,modelH,objH);

        function clearHighlight(this)
            slprivate('remove_hilite',this.sliceMdlName);
            slprivate('remove_hilite',this.origMdlName);
        end

        function hilightStartObjs(this,objHs)%#ok<INUSL>
            for objH=objHs
                set_param(objH,'HiliteAncestors','Find');
            end
        end

        function highlightInSlice(this,origMdlHs,refModelName)
            if(nargin<3)
                refModelName='';
            end

            this.clearHighlight();
            try
                sliceMdlH=get_param(this.sliceMdlName,'Handle');
                sliceMdlObjs=this.findInSlice(origMdlHs,refModelName);

                if isempty(sliceMdlObjs)
                    title=getString(message('Sldv:ModelSlicer:Transform:RemovedContent'));
                    str=getString(message('Sldv:ModelSlicer:Transform:SelectedContentIsNot',this.sliceMdlName));
                    msgbox(str,title);
                else

                    action_highlight('clear');

                    for objH=sliceMdlObjs
                        this.highlightModelObject(sliceMdlH,objH);
                    end
                end
                this.hilightStartObjs(origMdlHs);
            catch Mex
            end
        end

        function highlightInOrig(this,sliceMdlHs)
            import slslicer.internal.*;
            this.clearHighlight();
            try
                origMdlObjs=this.findInOrig(sliceMdlHs);

                if isempty(origMdlObjs)
                    title=getString(message('Sldv:ModelSlicer:Transform:CouldNotLocate'));
                    str=getString(message('Sldv:ModelSlicer:Transform:CouldNotLocateOrginal'));
                    msgbox(str,title);
                else

                    action_highlight('clear');

                    for objH=origMdlObjs
                        parentMdl=getfullname(bdroot(objH));
                        if Simulink.internal.isModelReferenceMultiInstanceNormalModeCopy(parentMdl)
                            parentMdl=get_param(parentMdl,'ModelReferenceNormalModeOriginalModelName');
                            mappedObjH=MdlRefCtxMgr.mapSlElementsToModel(objH,parentMdl);
                            this.highlightModelObject(get_param(parentMdl,'handle'),mappedObjH);
                        else
                            this.highlightModelObject(bdroot(objH),objH);
                        end
                    end
                end
                this.hilightStartObjs(sliceMdlHs);
            catch Mex
            end
        end

        function setAsActiveSlice(this)
            if isempty(this.refMdlInfo)
                allModels=get_param(this.origMdlName,'Handle');
            else
                allRefModels=keys(this.refMdlInfo);
                refMdlCnt=numel(allRefModels);
                allModels=zeros(1,refMdlCnt+1);
                allModels(1)=get_param(this.origMdlName,'Handle');
                for idx=1:refMdlCnt
                    try
                        allModels(idx+1)=get_param(allRefModels{idx},'Handle');
                    catch Mex
                    end
                end
            end

            modelslicerprivate('sliceActiveModelMapper','set',allModels,this);
        end
    end
end







function str=sid_block(blkH)
    str=Simulink.ID.getSID(blkH);
end

function str=sid_extended(objH)
    str='';
    if objH==0
        return;
    end

    try
        objType=get_param(objH,'Type');

        switch(objType)
        case 'block'
            str=sid_block(objH);
        case 'port'
            [pType,pIdx,blkH]=port_attribs(objH);
            sidstr=sid_block(blkH);
            str=sprintf('%s[P%s:%d]',sidstr,pType,pIdx);
        case 'line'
            srcPortH=get_param(objH,'SrcPortHandle');
            [~,pIdx,blkH]=port_attribs(srcPortH);
            sidstr=sid_block(blkH);
            str=sprintf('%s[O:%d]',sidstr,pIdx);
        end
    catch Mex
        str='';
    end

end

function obj=sid_ext_obj(sidstr,mdlName)%#ok<INUSD>
    if isempty(sidstr)
        obj=0;
        return;
    end

    [base,ext]=strtok(sidstr,'[');

    blkH=Simulink.ID.getHandle(base);

    if isempty(ext)
        obj=blkH;
    else
        if ext(2)=='P'
            portstr=ext(3:(end-1));
            [ptype,idxstr]=strtok(portstr,':');
            obj=get_port(blkH,ptype,str2double(idxstr(2:end)));
        else
            portIdx=str2double(ext(4:(end-1)));
            portH=get_port(blkH,'outport',portIdx);
            obj=get_param(portH,'Line');
        end
    end
end


function sidvect=sid_encode_vect(objHs)
    cnt=numel(objHs);
    sidvect=cell(1,cnt);
    for idx=1:cnt
        sidvect{idx}=sid_extended(objHs(idx));
    end
end


function objHs=sid_decode_vect(sidvect,mdlName)
    cnt=numel(sidvect);
    objHs=zeros(1,cnt);
    for idx=1:cnt
        objHs(idx)=sid_ext_obj(sidvect{idx},mdlName);
    end
end


function[pType,pIdx,blkH]=port_attribs(portH)
    pType=get_param(portH,'PortType');
    pIdx=get_param(portH,'PortNumber');
    blkH=get_param(get_param(portH,'Parent'),'Handle');
end

function out=map_from_sidvect(sidvect,mdlName)%#ok<DEFNU>
    objHs=sid_decode_vect(sidvect,mdlName);
    out=containers.Map('KeyType','double','ValueType','uint8');

    for obj=objHs
        out(obj)=uint8(1);
    end
end

function out=map_from_nested_sidcell(sidcell,keyMdl,valMdl)
    out=blkmap_from_cell_array(sidcell,@sid_decode_vect,keyMdl,valMdl);
end

function out=blkmap_from_cell_array(incell,valDecodeFcn,keyMdl,varargin)
    keyHs=sid_decode_vect(incell(1:2:end),keyMdl);
    if isempty(keyHs)
        out=containers.Map('KeyType','double','ValueType','any');
    else
        cnt=numel(incell)/2;
        vals=cell(1,cnt);

        for idx=1:cnt;
            try
                vals{idx}=feval(valDecodeFcn,incell{2*idx},varargin{:});
            catch
                vals{idx}=[];
            end
        end
        if numel(keyHs)==1
            keyHs={keyHs};
        end
        out=containers.Map(keyHs,vals);
    end
end

function out=encode_blkmap_as_cell(map,valEncodeFcn,varargin)
    keys=map.keys();
    keys=[keys{:}];
    vals=map.values();
    cnt=numel(vals);
    keys_encoded=sid_encode_vect(keys);

    vals_encoded=cell(1,cnt);
    for idx=1:cnt
        vals_encoded{idx}=feval(valEncodeFcn,vals{idx},varargin{:});
    end

    out(1:2:(2*cnt-1))=keys_encoded;
    out(2:2:(2*cnt))=vals_encoded;
end


function portH=get_port(blkH,pType,pIdx)
    portHandles=get_param(blkH,'PortHandles');

    switch(pType)
    case 'inport'
        prtArray=portHandles.Inport;
    case 'enable'
        prtArray=portHandles.Enable;
    case 'trigger'
        prtArray=portHandles.Trigger;
    case 'outport'
        prtArray=portHandles.Outport;
    case 'state'
        prtArray=portHandles.State;
    case 'ifaction'
        prtArray=portHandles.Ifaction;
    otherwise
        prtArray=[];
    end

    if pIdx>0&&pIdx<=numel(prtArray)
        portH=prtArray(pIdx);
    else
        portH=[];
    end
end

function out=identity(in)
    out=in;
end

function out=isModelLoaded(model)
    out=false;
    try
        mh=get_param(model,'Handle');
        out=(mh~=0);
    catch Mex
    end
end
