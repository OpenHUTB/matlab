



classdef basedriver<handle
    properties(SetAccess=protected,GetAccess=protected)
        targetCompInventory=[]
        config=[]
    end

    properties(Constant=true)

        SUCCESS=0;
        SUBSYSTEM_IN_LOOP=1;
        DELAY_CONSTRAINT_NOT_MET=2;
        ILLEGAL_RATES=3;
        USER_DEFINED_BLOCK_FOUND=4;
        UNSUPPORTED_BLOCK=5;
    end

    methods(Abstract=true)
        replaceWithTargetFunctions(this,p,hdldriver)
        replaceWithInstantiationComp(this,ntk,c)
        flag=isCompCompatible(~,ntk)
        [latency,isLatencyCustom]=getDefaultLatency(this,targetIPType,targetCompDataType,hC)
    end

    methods(Abstract=true,Static=true)
        name=getMaskName(compClass)
        name=getFunctionName(varargin)
    end

    methods
        function this=basedriver(config,varargin)
            this.targetCompInventory=targetcodegen.targetCompInventory.createInventoryWithHDLCoderDriver(hdlcurrentdriver);
            this.config=config;
        end


        function inventory=getInventory(this)
            inventory=this.targetCompInventory;
        end


        function latency=resolveLatencyForComp(this,c)
            latency=this.getCustomizedLatency(c);
            c.setTargetCodeGenerationLatency(latency);
        end
    end

    methods(Access=protected)

        function createInventoryAndReplaceWithTargetFunctions(this,p,~)
            assert(~(hdlgetparameter('generateTargetComps')&&isempty(this.targetCompInventory)));
            targetCodeGenSuccess=true;
            ntks=p.Networks;
            for i=1:length(ntks)
                n=ntks(i);
                if~this.replaceWithTargetFunctionsInNtk(n)
                    targetCodeGenSuccess=false;
                end
            end
            gp=pir;
            gp.setTargetCodeGenSuccess(targetCodeGenSuccess);

            gp.doDeadLogicElimination;
            if targetCodeGenSuccess&&~isempty(this.targetCompInventory)
                this.targetCompInventory.setPathToFiles;
                newFiles=this.targetCompInventory.getPathToFiles;
                for ii=1:numel(newFiles)
                    p.addEntityNameAndPath(newFiles{ii},'');
                end
                if targetcodegen.targetCodeGenerationUtils.isXilinxMode()

                    targetcodegen.xilinxutildriver.addXilinxNetlistFiles(this.targetCompInventory.getNgcFileList)
                end
            end
        end

        function latency=getCustomizedLatency(this,c)
            targetIPType=c.getTargetIPTypeIndex;
            if(strcmpi(targetIPType,'NOIP'))
                latency=-1;
            elseif(strcmpi(targetIPType,'CONVERT')&&isEqual(c.PirInputSignals.Type,c.PirOutputSignals.Type))
                latency=-1;
            else
                targetCompDataType=c.getTargetCompDataTypeIndex(true);
                latency=this.getDefaultLatency(targetIPType,targetCompDataType,c);
                if(latency==-1&&contains(targetIPType,'CONVERT'))
                    targetCompDataType=c.getTargetCompDataTypeIndex(false);
                    latency=this.getDefaultLatency(targetIPType,targetCompDataType,c);
                end
            end
        end
    end

    methods(Access=private)

        function flag=replaceWithTargetFunctionsInNtk(this,ntk)
            flag=false;
            if~this.areAllCompsCompatible(ntk)
                return;
            end
            comps=ntk.Components;
            for i=1:length(comps)
                c=comps(i);
                if~targetcodegen.basedriver.isFloatingPtDataTypesAtInterface(c)


                    continue;
                end
                if c.isSupportTargetCodeGenWithoutMapping
                    className=c.ClassName;
                    switch className
                    case 'nfpreinterpretcast_comp'
                        targetCompMap=transformnfp.getTargetCompMap(true);
                        transformnfp.transformNFPComp(ntk,c,targetCompMap,...
                        'nfp_cast_comp',c.PirInputSignals(1).Type.getLeafType.isSingleType||c.PirOutputSignals(1).Type.getLeafType.isSingleType);
                    end
                    continue;
                end
                this.replaceWithInstantiationComp(ntk,c);
            end
            flag=true;
        end

        function flag=areAllCompsCompatible(this,ntk)
            flag=true;
            comps=ntk.Components;
            for i=1:length(comps)
                c=comps(i);
                if~targetcodegen.basedriver.isFloatingPtDataTypesAtInterface(c)


                    continue;
                end
                if c.isSupportTargetCodeGenWithoutMapping



                    continue;
                end
                if~this.isCompCompatible(c)
                    flag=false;
                    targetcodegen.basedriver.markUnsupportedBlock(ntk,c);
                    return;
                end
            end
        end
    end

    methods(Static)

        function color=getBlockColor
            color='lightblue';
        end


        function cgInfo=getCGInfo(varargin)
            if(~isempty(varargin))
                cgInfo=varargin{:};
            else
                hCurrentDriver=hdlcurrentdriver();
                cgInfo=hCurrentDriver.cgInfo;
            end
        end

        function hdlCodeGenStatus=getCodeGenStatus(varargin)
            if(~isempty(varargin))
                if(ischar(varargin{:}))
                    cgDir=varargin{:};
                else
                    cgInfo=varargin{:};
                    if(~isfield(cgInfo,'codegenDir'))
                        hdlCodeGenStatus=[];
                        return;
                    end
                    cgDir=cgInfo.codegenDir;
                end
            else
                hCurrentDriver=hdlcurrentdriver();
                cgDir=hCurrentDriver.hdlGetCodegendir;
            end
            cgsFilePath=fullfile(cgDir,incrementalcodegen.IncrementalCodeGenDriver.hdlCodeGenStatusFileName);
            if(exist(cgsFilePath,'file')==2)
                try
                    hdlCodeGenStatus=load(cgsFilePath);
                catch %#ok<CTCH>
                    hdlCodeGenStatus=[];
                end
            else
                hdlCodeGenStatus=[];
            end
        end


        function toolPath=getToolPath(toolBinary,lib)
            [status,toolDir]=downstream.AvailableToolList.simplewhich(toolBinary);
            if(status~=true)
                toolName=targetcodegen.targetCodeGenerationUtils.getToolName(lib);
                if~ischar(toolName)
                    toolName=char(toolName(1));
                end
                error(message('hdlcommon:targetcodegen:ToolNotSet',lib,toolName));
            end
            toolPath=fullfile(toolDir,toolBinary);
            toolPath=strtrim(toolPath);
        end
    end

    methods(Static=true,Access=protected)

        function name=getFunctionNamePrivate(prefix,compClass,specialization)
            if nargin<3
                specialization=[];
            end
            if~isempty(specialization)
                name=[prefix,specialization];
                return;
            end
            matched=regexp(compClass,'(?:target_)*(?<type>\w+)_comp','names');
            if isempty(matched)
                error(message('hdlcommon:targetcodegen:InternalErrorIllegalTargetCompClass'));
            end
            name=[prefix,matched.type];
        end


        function name=getMaskNamePrivate(compClass,prefix)
            matched=regexp(compClass,'target_(?<type>\w+)_comp','names');
            if isempty(matched)
                if strcmpi(compClass,'nfpsparseconstmultiply_comp')
                    name=[prefix,'SparseConstMultiply'];
                    return;
                else
                    error(message('hdlcommon:targetcodegen:InternalErrorIllegalTargetCompClass'));
                end
            end
            name=[prefix,matched.type];
        end


        function disconnectReceivers(signals,comp)
            for i=1:length(signals)
                s=signals(i);
                s.disconnectReceiver(comp,i-1);
            end
        end


        function disconnectDrivers(signals,comp)
            for i=1:length(signals)
                s=signals(i);
                s.disconnectDriver(comp,i-1);
            end
        end



        function flag=isFloatingPtDataTypesAtInterface(c)
            flag=false;
            inputSignals=c.PirInputSignals;
            outputSignals=c.PirOutputSignals;
            if isempty(inputSignals)&&isempty(outputSignals)
                return;
            end
            for i=1:length(inputSignals)
                currInputSignal=inputSignals(i);
                if targetmapping.isValidDataType(currInputSignal.Type)
                    flag=true;
                    return;
                end
            end
            for i=1:length(outputSignals)
                currOutputSignal=outputSignals(i);
                if targetmapping.isValidDataType(currOutputSignal.Type)
                    flag=true;
                    return;
                end
            end
        end


        function markUnsupportedBlock(ntk,c)
            ntk.setTargetCodeGenMsgID(targetcodegen.basedriver.UNSUPPORTED_BLOCK);
            if c.OrigModelHandle>0
                cPath=[get_param(c.OrigModelHandle,'parent'),'/',get_param(c.OrigModelHandle,'name')];
            else
                cPath='Unidentified block';
            end
            ntk.setTargetCodeGenOffendingCompList(cPath);
        end
    end
end


