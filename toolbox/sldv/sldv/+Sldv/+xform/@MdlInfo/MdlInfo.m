classdef MdlInfo<handle







    properties(SetAccess=protected,Hidden)

        SubsystemTree=[];


        ModelRefBlkTree=[];



        MdlsLoadedForMdlRefTree={};



        MdlOrigParams=[];



        HasMultiInsNormalMode=false;






        MdlInlinerOnlyMode=false;
    end

    properties(SetAccess=private)

        ModelH=[];




        OrigModelH=[];


        TestComp=[];




        ForceReplaceModel=false;





        replacementDDPath='';
    end

    properties(Access=private)


        WorkOnCopy=false;
    end

    properties(Access=private,Dependent)

ModelWasCompiled
    end


    methods
        function obj=MdlInfo(objH,varargin)
            obj.InactiveMdlBlkToCacheInfo=containers.Map('keyType','double','valueType','any');

            modelH=[];
            if nargin<1
                error(message('Sldv:xform:MdlInfo:MdlInfo:IncorrectArguments'));
            end


            nargs=nargin-1;
            if nargs<4
                copyMdlParams=[];
            else
                copyMdlParams=varargin{4};
            end
            if nargs<3
                copyMdlFileOpts=[];
            else
                copyMdlFileOpts=varargin{3};
            end
            if nargs<2
                openCopyModel=true;
            else
                openCopyModel=varargin{2};
            end
            if nargs<1
                copyMdl=false;
            else
                copyMdl=varargin{1};

                if~islogical(copyMdl)
                    obj.MdlInlinerOnlyMode=true;
                    obj.OrigModelH=varargin{1};
                    copyMdl=false;
                end
            end

            if copyMdl&&isempty(copyMdlFileOpts)
                error(message('Sldv:xform:MdlInfo:MdlInfo:InvalidFileName'));
            end

            if ischar(objH)
                try
                    modelH=get_param(objH,'Handle');
                catch Mex %#ok<NASGU>
                end
            else
                if ishandle(objH)
                    if isa(objH,'Simulink.BlockDiagram')
                        modelH=get(objH,'Handle');
                    else
                        try
                            modelH=get_param(objH,'Handle');
                        catch Mex %#ok<NASGU>
                        end
                    end
                end
            end


            if~isempty(modelH)
                if obj.MdlInlinerOnlyMode
                    obj.ModelH=modelH;
                else
                    modelObj=get_param(modelH,'Object');
                    if isa(modelObj,'Simulink.BlockDiagram')
                        obj.ModelH=modelH;
                        obj.OrigModelH=modelH;
                        obj.TestComp=Sldv.Token.get.getTestComponent;
                        obj.WorkOnCopy=copyMdl;
                        obj.genCopyMdl(openCopyModel,copyMdlFileOpts,copyMdlParams);
                    else
                        modelH=[];
                    end
                end
            end

            if isempty(modelH)
                error(message('Sldv:xform:MdlInfo:MdlInfo:IncorrectInput'));
            end
        end

        function delete(obj)
            obj.closeLoadedReferredMdls;



        end

        function value=get.ModelWasCompiled(obj)
            value=Sldv.xform.MdlInfo.isMdlCompiled(obj.ModelH);
        end

        function compileModel(obj,target)


            if nargin<2
                target='compileForSizes';
            end

            Sldv.xform.MdlInfo.compileBlkDiagram(obj.ModelH,obj.ModelWasCompiled,target);
            if sldvprivate('mdl_has_vardimsignal',obj.ModelH)&&~slfeature('DVVarSizeSignal')
                error(message('Sldv:xform:MdlInfo:MdlInfo:VarSizedSignals'));
            end
        end

        function termModel(obj)
            Sldv.xform.MdlInfo.termBlkDiagram(obj.ModelH,obj.ModelWasCompiled);
        end

        function closeLoadedReferredMdls(obj)





            Sldv.xform.silentCloseModels(obj.MdlsLoadedForMdlRefTree);
            obj.MdlsLoadedForMdlRefTree={};
        end

        function restoreCopyMdlParams(obj)


            if obj.WorkOnCopy&&~isempty(obj.MdlOrigParams)
                params=fieldnames(obj.MdlOrigParams);
                for i=1:length(params)
                    set_param(obj.ModelH,params{i},obj.MdlOrigParams.(params{i}));
                end
            end
        end


        constructMdlRefBlksTree(obj,mdlRefBlkRepRulesTree)





        constructSubsystemTree(obj,genSSCompiledInfo,genBuiltinBlkInfo)









        refmodelH=deriveReferencedModelH(obj,mdlBlkH)






    end

    methods(Static)
        function value=isMdlCompiled(mdlH)

            if~isempty(mdlH)
                simStatus=get_param(mdlH,'SimulationStatus');


                value=any(strcmp(simStatus,{'paused','initializing','compiled'}));
            else
                value=false;
            end
        end

        compileBlkDiagram(mdlH,mdlWasCompiled,target)



        termBlkDiagram(mdlH,mdlWasCompiled)


    end

    methods(Access=protected)
        function mdlRefBlkNode=constructMdlRefBlkTreeNode(obj,blockH,parentNode)%#ok<INUSL>
            if nargin<2
                parentNode=[];
            end
            mdlRefBlkNode=Sldv.xform.MdlRefBlkTreeNode(blockH);
            if~isempty(parentNode)
                mdlRefBlkNode.connectUp(parentNode)
            end
        end

        function subsystemNode=constructSubSystemTreeNode(obj,blockH,...
            parentNode,genSSCompiledInfo,busObjectList)
            if nargin<5
                busObjectList=[];
            end
            if nargin<4
                genSSCompiledInfo=false;
            end
            if nargin<3
                parentNode=[];
            end
            subsystemNode=Sldv.xform.SubSystemTreeNode(blockH);
            if~isempty(parentNode)
                subsystemNode.connectUp(parentNode)
            end
            if genSSCompiledInfo
                obj.constructSubSystemCompIOinfo(subsystemNode,busObjectList);
            end
        end

        function constructSubSystemCompIOinfo(obj,blockInfo,busObjectList)%#ok<INUSL>
            if~isempty(blockInfo.Up)
                blockInfo.constructCompIOInfo(busObjectList);
                blockInfo.checkSampleTimeInheritance;
            end
        end

        function constructSubsystemTreeBuiltinBlks(obj,allBlksH,allBlkTypes,systemTable,busObjectList)%#ok<INUSL>



            for idx=1:length(allBlksH)
                obj.constructBuiltinBlk(allBlksH(idx),systemTable,busObjectList);
            end
        end

        function constructBuiltinBlk(obj,blockH,systemTable,busObjectList)
            blockObj=get_param(blockH,'Object');
            if~blockObj.isSynthesized&&...
                ~(isa(blockObj,'Simulink.InportShadow')&&blockObj.isPostCompileVirtual)

                parentH=get_param(blockObj.Parent,'Handle');
                assert(systemTable.isKey(parentH),getString(message('Sldv:xform:MdlInfo:MdlInfo:ParentInSubsysTable')));
                parentSS=systemTable(parentH);


                if~parentSS.isSFbased
                    parentSSInfo=parentSS.getSubsystemHierarlInfoForBlks;
                    blockInfo=parentSS.constructBuiltinBlk(blockH,obj,parentSSInfo,busObjectList);
                    parentSS.BltinBlksList{end+1}=blockInfo;
                end
            end
        end


        function setForceReplaceModel(obj)
            obj.ForceReplaceModel=true;
        end

        function setReplacementDDPath(obj,repDDPath)
            obj.replacementDDPath=repDDPath;
            obj.deleteRepDDIfExists();




            obj.replacementDDPath=repDDPath;
        end

        function cachePropertiesForInactiveMdlBlks(obj,modelH)

            mdlBlks=Sldv.utils.findModelBlocks(modelH,false);


            inactiveIdx=strcmp(get_param(mdlBlks,'CompiledIsActive'),'off');


            withinSfIdx=cellfun(@(m)loc_filterSf(m),mdlBlks(~inactiveIdx));
            if isempty(withinSfIdx)
                withinSfIdx=false;
            end
            mdlBlksToCache=mdlBlks(inactiveIdx|withinSfIdx);
            for idx=1:length(mdlBlksToCache)
                mdlBlkH=get_param(mdlBlksToCache{idx},'handle');
                obj.InactiveMdlBlkToCacheInfo(mdlBlkH)=obj.cacheAttributes(mdlBlkH);
            end
            function yesno=loc_filterSf(mdlBlk)
                sid=Simulink.ID.getSID(mdlBlk);
                yesno=length(strsplit(sid,'::'))>1;
            end
        end

        function cacheInfo=cacheAttributes(obj,blockH)
            ph=get_param(blockH,'PortHandles');
            cacheInfo=struct;
            fields=fieldnames(ph);
            for idx=1:length(fields)
                f=fields{idx};
                ports=ph.(f);
                cacheInfo.(f)={};
                for jdx=1:length(ports)
                    try
                        attrib=obj.cachePortAttributes(ports(jdx));
                    catch




                        attrib=[];
                    end
                    cacheInfo.(f){end+1}=attrib;
                end
            end
        end

        function attributes=cachePortAttributes(~,portH)

            attributes=struct('CompiledBusType',[],...
            'CompiledPortComplexSignal',[],...
            'CompiledPortAliasedThruDataType',[],...
            'CompiledPortDesignMax',[],...
            'CompiledPortDesignMin',[],...
            'CompiledPortDimensions',[],...
            'CompiledPortFrameData',[],...
            'CompiledPortWidth',[],...
            'CompiledPortSampleTime',[],...
            'CompiledPortDimensionsMode',[],...
            'CompiledBusStruct',[],...
            'CompiledSignalHierarchy',[],...
            'CompiledPortSymbolicDimensions',[]);
            fields=fieldnames(attributes);
            for idx=1:length(portH)
                ph=portH(idx);
                for jdx=1:length(fields)
                    attributes.(fields{jdx})=get(ph,fields{jdx});
                end

                attributes.CompiledPortUnits=getPortUnit(ph);









                attributes=Sldv.xform.MdlInfo.getSettableSignalAttributes(attributes);
            end
            function val=getPortUnit(ph)
                val='';
                parent=get_param(ph,'Parent');
                type=get_param(ph,'PortType');
                type=[upper(type(1)),type(2:end)];
                units=get_param(parent,'CompiledPortUnits');
                if~isempty(units)
                    unit=units.(type);
                    val=unit{get_param(ph,'PortNumber')};
                end
            end
        end

        genCopyMdl(obj,openCopyModel,copyMdlFileOpts,copyMdlParams)


    end

    properties(Access=private,Hidden)
InactiveMdlBlkToCacheInfo
    end

    methods(Access=?Sldv.xform.BlkReplacer,Hidden)
        function listener=createInactiveMdlBlkPropCacheListener(obj,modelH)
            cosObj=get_param(modelH,'InternalObject');
            listener=addlistener(cosObj,'SLCompEvent::POST_PROPAGATION_EVENT',...
            @(~,~)obj.cachePropertiesForInactiveMdlBlks(modelH));
        end

        function resetMdlBlkCacheInfo(obj)
            obj.InactiveMdlBlkToCacheInfo=containers.Map('keyType','double','valueType','any');
        end

        function reopenGeneratedModel(obj)
            replacementModelFileName=get_param(obj.ModelH,'filename');
            replacementModelName=get_param(obj.ModelH,'Name');

            Sldv.close_system(obj.ModelH,1,'SkipCloseFcn',true,'closeReferencedModels',false);
            Sldv.load_system_no_callbacks(replacementModelFileName);

            obj.ModelH=get_param(replacementModelName,'handle');
        end

        function deleteRepDDIfExists(obj)
            if isfile(obj.replacementDDPath)
                try
                    delete(obj.replacementDDPath);
                catch



                    ddObj=Simulink.data.Dictionary(obj.replacementDDPath);
                    close(ddObj);
                    delete(obj.replacementDDPath);
                end
                obj.replacementDDPath='';
            end
        end
    end

    methods(Static,Access=protected)
        function modAttrStruct=getSettableSignalAttributes(attrStruct)

















            if contains(attrStruct.CompiledBusType,'NOT_BUS')
                dtStr=attrStruct.CompiledPortAliasedThruDataType;
                if~isempty(dtStr)
                    if sl('sldtype_is_builtin',dtStr)
                        modAttrStruct.OutDataTypeStr=dtStr;
                    elseif sldvshareprivate('util_is_enum_type',dtStr)
                        modAttrStruct.OutDataTypeStr=['Enum: ',dtStr];
                    elseif sldvshareprivate('util_is_fxp_type',dtStr)
                        modAttrStruct.OutDataTypeStr=sprintf('fixdt(''%s'')',dtStr);
                    else
                    end
                end
            end


            modAttrStruct.OutMax=Sldv.xform.MdlInfo.lnum2str(attrStruct.CompiledPortDesignMax);


            modAttrStruct.OutMin=Sldv.xform.MdlInfo.lnum2str(attrStruct.CompiledPortDesignMin);


            if~strcmp(attrStruct.CompiledBusType,'BUS')
                if~isempty(attrStruct.CompiledPortSymbolicDimensions)&&...
                    contains(attrStruct.CompiledPortSymbolicDimensions,{'INHERIT','NOSYMBOLIC'})
                    modAttrStruct.Dimensions=Sldv.xform.MdlInfo.getDimensionsStr(attrStruct.CompiledPortDimensions);
                else
                    modAttrStruct.Dimensions=attrStruct.CompiledPortSymbolicDimensions;
                end
            end


            modAttrStruct.SampleTime=Sldv.xform.MdlInfo.getSampleTimeStr(attrStruct.CompiledPortSampleTime);


            modAttrStruct.SignalType=Sldv.xform.MdlInfo.getComplexityStr(attrStruct.CompiledPortComplexSignal);


            if strcmp(attrStruct.CompiledBusType,'NOT_BUS')
                modAttrStruct.SamplingMode=Sldv.xform.MdlInfo.getFrameDataStr(attrStruct.CompiledPortFrameData);
            end


            modAttrStruct.Unit=Sldv.xform.MdlInfo.lcell2mat(attrStruct.CompiledPortUnits);


            modAttrStruct.DimensionsMode=Sldv.xform.MdlInfo.getDimensionsMode(attrStruct.CompiledPortDimensionsMode);




        end

        function dimsStr=getDimensionsStr(compDims)
            if isempty(compDims)
                dimsStr='';
                return;
            end
            if(compDims(1)>=2)
                nDims=compDims(1);
                dimsStr='';
                spcVal='';
                for k=1:nDims
                    if k>1
                        spcVal=' ';
                    end
                    dimsStr=sprintf('%s%s%d',dimsStr,spcVal,compDims(k+1));
                end
                dimsStr=['[',dimsStr,']'];
            else
                dimsStr=sprintf('%d',compDims(2));
            end

        end

        function Complexity=getComplexityStr(compComplex)
            Complexity='';
            if compComplex==0
                Complexity='real';
            elseif compComplex==1
                Complexity='complex';
            end
        end

        function SamplingMode=getFrameDataStr(compFrame)
            SamplingMode='';
            if compFrame==0
                SamplingMode='Sample based';
            elseif compFrame==1
                SamplingMode='Frame based';
            end
        end

        function DimensionsMode=getDimensionsMode(compDimsMode)
            DimensionsMode='';
            if compDimsMode==0
                DimensionsMode='Fixed';
            elseif compDimsMode==1
                DimensionsMode='Variable';
            end
        end


        function str=lnum2str(str)
            if isnumeric(str)||islogical(str)
                str=num2str(str);
            end
        end


        function tsStr=getSampleTimeStr(compTs)

            if isempty(compTs)
                tsStr='';
                return;
            end



            if iscell(compTs)||isnan(compTs(1))||((length(compTs)==2)&&isnan(compTs(2)))
                tsStr='';
                return;
            end







            if isinf(compTs(1))

                tsStr='inf';
                return;
            end

            if(length(compTs)==2)&&(compTs(1)==0)&&(compTs(2)==0)

                tsStr='0';
                return;
            end

            if(compTs(1)==-1&&compTs(2)==-1)&&(length(compTs)==4)




                tsStr='-1';
                return;
            end


            ts=compTs;

            tsStr=['[',sprintf('%.17g',ts(1)),',',sprintf('%.17g',ts(2)),']'];
        end




        function members=lcell2mat(members)
            if iscell(members)
                members=cell2mat(members);
            end
        end

    end
end

