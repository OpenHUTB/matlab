














































classdef BlockPath<Simulink.SimulationData.BlockPath


    methods(Access='public')


        function obj=BlockPath(varargin)




            mlock;

            obj=obj@Simulink.SimulationData.BlockPath(varargin{:});



            obj=obj.cacheSSIDs(false);

        end


        function this=validate(this,bAllowInactiveVariant)%#ok<INUSD>













            if length(this)~=1
                Simulink.SimulationData.utError('InvalidBlockPathArray');
            end


            if(getLength(this)==0)
                Simulink.SimulationData.utError('BlockPathCannotBeEmpty');
            end


            for i=1:(getLength(this)-1)
                currPath=getBlock(this,i);
                currModel=...
                Simulink.SimulationData.BlockPath.getModelNameForPath(currPath);
                nextModel=...
                Simulink.SimulationData.BlockPath.getModelNameForPath(getBlock(this,i+1));

                currBlockType=Simulink.BlockPath.checkPath(currModel,currPath);

                if(~isequal(currBlockType,'ModelReference'))
                    Simulink.SimulationData.utError('InvalidBlockPathNotModelBlock',...
                    currPath,nextModel);
                else
                    if(isequal(get_param(currPath,'ProtectedModel'),'on'))
                        Simulink.SimulationData.utError('InvalidBlockPathProtectedModel',currPath);
                    end

                    refMdls={get_param(currPath,'ModelName')};
                    if(~ismember(nextModel,refMdls))
                        Simulink.SimulationData.utError('InvalidBlockPathIncorrectReference',...
                        currPath,get_param(currPath,'ModelName'),nextModel);
                    end
                end
            end



            this=this.fixMdlRefStateflowPaths;


            lastPath=getBlock(this,getLength(this));
            lastModel=...
            Simulink.SimulationData.BlockPath.getModelNameForPath(lastPath);
            Simulink.BlockPath.checkPath(lastModel,lastPath);


            if~isempty(this.sub_path)


                if~slprivate('is_stateflow_based_block',lastPath)
                    Simulink.SimulationData.utError('BPathNonStateflowSubPath',...
                    lastPath);
                end


                if~Simulink.BlockPath.utCheckStateflowSignal(lastPath,this.sub_path)
                    Simulink.SimulationData.utError('BPathInvalidStateflowSubPath',...
                    this.sub_path,lastPath);
                end
            end
        end









        function open(this,varargin)

            try
                [openType,force]=Simulink.BlockPath.parseOpenArgs(varargin{:});
            catch ME
                throwAsCaller(ME);
            end


            this.validate();


            topModel=bdroot(get_param(this.getBlock(1),'handle'));
            studioApp=SLM3I.SLDomain.getLastActiveStudioAppFor(topModel);
            if(isempty(studioApp))
                open_system(topModel);
                studioApp=SLM3I.SLDomain.getLastActiveStudioAppFor(topModel);
            end
            studioApp.getStudio().raise();

            blockHandle=get_param(this.getBlock(this.getLength()),'handle');
            parent=get_param(blockHandle,'parent');
            if~isempty(parent)


                d=SLM3I.Util.getDiagram(parent);%#ok<NASGU>
            end
            openReq=SLM3I.BlockOpenRequest(blockHandle,openType,force);
            blockHid=this.getHierarchyId();
            studioApp.processOpenRequest(openReq,blockHid);
        end
    end


    methods(Access='public',Hidden=true)


        function this=fixMdlRefStateflowPaths(this)










            len=this.getLength();
            if len<2||~isempty(this.SubPath)
                return;
            end


            warn_state=warning('off','all');
            cl=onCleanup(@()warning(warn_state));


            bpath=this.path{len};
            mdl=Simulink.SimulationData.BlockPath.getModelNameForPath(bpath);
            try
                load_system(mdl);
            catch me %#ok<NASGU>
                return;
            end


            try
                blockType=get_param(bpath,'BlockType');
            catch me %#ok<NASGU>
                blockType='';
            end
            if~isempty(blockType)
                return;
            end


            pos=strfind(bpath,'/');
            if isempty(pos)
                return;
            end
            pos=pos(end);
            newBpath=bpath(1:pos-1);
            newSubPath=bpath(pos+1:end);


            if Simulink.BlockPath.utIsStateflowChart(newBpath)
                this.path{len}=newBpath;
                this.SubPath=newSubPath;
            end

        end


        function this=cacheSSIDs(this,bOpenMdl)
            function mySSID=loc_getSSIDForBlockOrEmpty(myBlock)


                try
                    mySSID=Simulink.ID.getSID(myBlock);
                catch ME %#ok<NASGU>
                    mySSID='';
                end
            end




            for idx=1:length(this)


                this(idx).ssid={};


                if~isempty(this(idx).path)&&~isempty(this(idx).path{1})



                    if bOpenMdl
                        try
                            this(idx).validate();
                        catch me %#ok<NASGU>




                            continue;
                        end
                    end


                    ids=cellfun(@(x)loc_getSSIDForBlockOrEmpty(x),this(idx).path,'UniformOutput',false);


                    this(idx).ssid=reshape(ids,size(this(idx).path));
                end
            end

        end


        function this=refreshFromSSIDcache(this,bOpenMdl)
            function myPath=loc_updatePathFromSSID(mySSID,myPath)




                if(~isempty(mySSID))
                    try
                        myPath=Simulink.ID.getFullName(mySSID);
                        myPath=Simulink.SimulationData.BlockPath.manglePath(myPath);
                    catch me2
                        if~bOpenMdl
                            return;
                        end

                        errID=Simulink.SimulationData.errorID('BPathSSIDRefreshFailed');
                        newError=MException(errID,DAStudio.message(errID));
                        newError=newError.addCause(me2);
                        throw(newError);
                    end
                end
            end



            for objIdx=1:length(this)


                if isempty(this(objIdx).ssid)
                    continue;
                end

                this(objIdx).path=cellfun(@(x,y)loc_updatePathFromSSID(x,y),...
                this(objIdx).ssid,this(objIdx).path,...
                'UniformOutput',false);
            end

        end



        function res=getSSID(this,idx)



            if length(this)~=1
                Simulink.SimulationData.utError('InvalidBlockPathArray');
            end

            try
                res=this.ssid{idx};
            catch me %#ok<NASGU>
                Simulink.SimulationData.utError('InvalidBlockPathBlockIndex');
            end
        end




        function this=reparentBlockPath(this,newTopModel)




            for idx=1:length(this)
                if(getLength(this(idx))>0)
                    topPath=this(idx).path{1};



                    [match,~,~,~,parts]=regexp(topPath,'^[^/]+(/.*)$');


                    if(~isempty(match))
                        topBlocks=parts{1}{1};

                        this(idx).path{1}=[newTopModel,topBlocks];


                        if(~isempty(this(idx).ssid))
                            topSSID=this(idx).ssid{1};




                            [match,~,~,~,parts]=regexp(topSSID,'^[^:]+(:.*)$');


                            if(~isempty(match))
                                topID=parts{1}{1};
                                this(idx).ssid{1}=[newTopModel,topID];
                            end
                        end
                    end
                end
            end
        end



        function toReturn=getAsString(this)



            if length(this)~=1
                Simulink.SimulationData.utError('InvalidBlockPathArray');
            end

            toReturn='{';
            needsSeparator=false;

            for i=1:getLength(this)
                currBlock=getBlock(this,i);

                if(needsSeparator)
                    toReturn=[toReturn,', '];%#ok<AGROW>
                else
                    needsSeparator=true;
                end

                toReturn=[toReturn,'''',currBlock,''''];%#ok<AGROW>
            end

            toReturn=[toReturn,'}'];
        end





        function parent=getParent(this)
            validate(this);
            cells=convertToCell(this);
            size=length(cells);

            s=cells{size};

            s=get_param(s,'Parent');

            if(isempty(get_param(s,'Parent')))

                if(size==1)

                    parent=s;
                    return;
                else
                    cells=cells(1:size-1);
                end
            else

                cells{size}=s;
            end
            parent=Simulink.BlockPath(cells);
        end




        function openParent(this,varargin)
            validate(this);
            parent=getParent(this);
            if(ischar(parent))

                try
                    [openType,~]=Simulink.BlockPath.parseOpenArgs(varargin{:});
                catch ME
                    throwAsCaller(ME);
                end
                args={parent};
                switch(openType)
                case 'NEW_TAB'
                    args=[args,'TAB'];
                case 'NEW_WINDOW'
                    args=[args,'WINDOW'];
                end
                open_system(args{:});
            else
                parent.open(varargin{:});
            end
        end




        function blockHid=getHierarchyId(this,varargin)
            length=this.getLength();
            hids(length)=GLUE2.HierarchyId;
            for i=1:length
                localPath=this.getBlock(i);
                blockHandle=get_param(localPath,'handle');

                parent=get_param(blockHandle,'parent');
                if~isempty(parent)
                    d=SLM3I.Util.getDiagram(parent);%#ok<NASGU>
                end
                b=SLM3I.SLDomain.handle2DiagramElement(blockHandle);
                hids(i)=GLUE2.HierarchyServiceUtils.getDefaultHID(b);
            end
            blockHid=GLUE2.HierarchyService.join(hids);
        end


        function toReturn=utStringWithEscapeChar(this)



            if length(this)~=1
                Simulink.SimulationData.utError('InvalidBlockPathArray');
            end
            toReturn='{';
            needsSeparator=false;
            for i=1:getLength(this)
                currBlock=getBlock(this,i);
                currBlock=strrep(currBlock,'\','\\');
                currBlock=strrep(currBlock,',','\,');
                currBlock=strrep(currBlock,'''','\''');
                currBlock=strrep(currBlock,'{','\{');
                currBlock=strrep(currBlock,'}','\}');
                if(needsSeparator)
                    toReturn=[toReturn,', '];%#ok<AGROW>
                else
                    needsSeparator=true;
                end

                toReturn=[toReturn,'''',currBlock,''''];%#ok<AGROW>
            end

            toReturn=[toReturn,'}'];
        end




        function outPath=toPipePath(this)
            if length(this)~=1
                Simulink.SimulationData.utError('InvalidBlockPathArray');
            end

            outPath='';
            if(~isempty(this.SubPath))
                outPath=slprivate('encpath',this.SubPath,'','','none');
            end

            for index=this.getLength():-1:1
                if(index==this.getLength())
                    if(isempty(this.SubPath))
                        sepType='none';
                    else
                        sepType='stateflow';
                    end
                else
                    sepType='modelref';
                end

                blockPath=this.getBlock(index);

                outPath=slprivate('encpath',blockPath,'',outPath,sepType);
            end
        end
    end


    methods(Access='private',Static=true)


        function blocktype=checkPath(model,path)


            try
                load_system(model);
            catch me
                errID=Simulink.SimulationData.errorID('InvalidBlockPathCouldNotLoadModel');
                newError=MException(errID,DAStudio.message(errID,model,path));
                newError=newError.addCause(me);
                throw(newError);
            end

            try
                blocktype=get_param(path,'BlockType');
            catch me
                errID=Simulink.SimulationData.errorID('InvalidBlockPathInvalidBlock');
                newError=MException(errID,DAStudio.message(errID,path));
                newError=newError.addCause(me);
                throw(newError);
            end
        end

        function[openType,force]=parseOpenArgs(varargin)
            p=inputParser;
            addParameter(p,'OpenType','REUSE_TAB',@(x)Simulink.BlockPath.validateOpenArg('OpenType',x));
            addParameter(p,'Force',false,@(x)Simulink.BlockPath.validateOpenArg('Force',x));
            parse(p,varargin{:});
            openType=upper(p.Results.OpenType);
            switch openType
            case 'CURRENT-TAB'
                openType='REUSE_TAB';
            case 'NEW-TAB'
                openType='NEW_TAB';
            case 'NEW-WINDOW'
                openType='NEW_WINDOW';
            end

            if(isa(p.Results.Force,'logical'))
                force=p.Results.Force;
            else
                force=strcmpi(p.Results.Force,'on');
            end
        end

        function validateOpenArg(arg,x)
            switch arg
            case 'OpenType'
                validateattributes(x,{'char'},{'nonempty'});
                try




                    validatestring(x,["REUSE_TAB","NEW_TAB","NEW_WINDOW"]);
                catch
                    validatestring(x,["current-tab","new-tab","new-window"]);
                end

            case 'Force'
                validateattributes(x,{'logical','char'},{'nonempty'});
                if(isa(x,'char'))
                    validatestring(x,["on","off"]);
                end
            end
        end

    end


    methods(Static=true,Hidden=true)


        function bIsSF=utIsStateflowChart(blk)




            bIsSF=false;

            try
                if strcmpi(get_param(blk,'BlockType'),'SubSystem')&&...
                    slprivate('is_stateflow_based_block',blk)


                    cId=sfprivate('block2chart',blk);
                    bIsSF=sfprivate('is_sf_chart',cId)||...
                    Stateflow.STT.StateEventTableMan.isStateEventTableChart(cId);
                end
            catch me %#ok<NASGU>


            end

        end


        function bValid=utCheckStateflowSignal(bpath,signalName)



            bValid=false;


            sigs=...
            Simulink.SimulationData.ModelLoggingInfo.getDefaultChartSignals(...
            [],...
            bpath,...
            true,...
            Simulink.SimulationData.SignalLoggingInfo.empty);


            for idx=1:length(sigs)
                curSignal=sigs(idx).blockPath_.SubPath;
                if strcmp(signalName,curSignal)
                    bValid=true;
                    return;
                end
            end
        end






        function bpath=fromPipePath(inPath)
            blocks={};
            subPath='';

            restPath=inPath;
            while(~isempty(restPath))
                [block,submodel,restPath,sepChar]=slprivate('decpath',restPath,true);

                switch sepChar
                case 'modelref'
                    blocks{end+1}=block;%#ok<AGROW>

                case 'stateflow'
                    if(~isempty(submodel)||isempty(restPath))
                        errID=Simulink.SimulationData.errorID('PipePathDecodeError');
                        me=MException(errID,DAStudio.message(errID,inPath));
                        throw(me);
                    end

                    blocks{end+1}=block;%#ok<AGROW>

                    [subPath,submodel,restPath,sepChar]=slprivate('decpath',restPath);
                    if(isempty(subPath)||~isempty(submodel)||~isempty(restPath)||~strcmp(sepChar,'none'))
                        errID=Simulink.SimulationData.errorID('PipePathDecodeError');
                        me=MException(errID,DAStudio.message(errID,inPath));
                        throw(me);
                    end

                case 'none'
                    blocks{end+1}=block;%#ok<AGROW>
                    if(~isempty(submodel)||~isempty(restPath))
                        errID=Simulink.SimulationData.errorID('PipePathDecodeError');
                        me=MException(errID,DAStudio.message(errID,inPath));
                        throw(me);
                    end

                otherwise
                    errID=Simulink.SimulationData.errorID('PipePathDecodeError');
                    me=MException(errID,DAStudio.message(errID,inPath));
                    throw(me);
                end
            end

            bpath=Simulink.BlockPath(blocks,subPath);
        end






        function blockPath=fromHierarchyIdAndHandle(parentHid,handle)

            hs=GLUE2.HierarchyService;
            m3iobj=hs.getM3IObject(parentHid);
            tempObj=m3iobj.temporaryObject;



            if(isempty(tempObj)||...
                ~isa(tempObj,'SLM3I.Diagram')||...
                get_param(get_param(handle,'parent'),'handle')~=tempObj.handle)
                blockPath=Simulink.BlockPath;
                return;
            end

            paths={};


            obj=get_param(handle,'object');
            currentPath=obj.getFullName();
            currentModelHandle=bdroot(handle);


            currentHid=parentHid;
            while hs.isValid(currentHid)
                obj=hs.getM3IObject(currentHid);
                target=obj.temporaryObject;


                if isa(target,'SLM3I.Diagram')&&target.handle==currentModelHandle

                    paths=[{currentPath},paths];%#ok<AGROW>

                    currentPath=[];
                    currentModelHandle=-1;
                end


                if isa(target,'SLM3I.Block')&&isempty(currentPath)

                    currentPath=target.getFullPathName();
                    currentModelHandle=bdroot(target.handle);
                end


                currentHid=hs.getParent(currentHid);

            end


            blockPath=Simulink.BlockPath(paths);
        end
    end
end


