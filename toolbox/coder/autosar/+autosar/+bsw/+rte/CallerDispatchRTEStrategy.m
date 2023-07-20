classdef CallerDispatchRTEStrategy<autosar.bsw.rte.RTEStrategy






    properties(Access=private)
ServiceFcnPrototype
PhysicalIdType
BswCompType
    end

    methods
        function this=CallerDispatchRTEStrategy(serviceFunctionName,serviceFcnPrototype,physicalIdType,bswCompType)
            this@autosar.bsw.rte.RTEStrategy(serviceFunctionName);
            this.ServiceFcnPrototype=serviceFcnPrototype;
            this.PhysicalIdType=physicalIdType;
            this.BswCompType=bswCompType;
        end

        function createRTE(this,simulinkFcnBlk,inArgHandles,outArgHandles,portDefArgument,~)





            fcnCallerName=[this.ServiceFunctionName,'(caller)'];
            fcnCallerBlk=[simulinkFcnBlk,'/',fcnCallerName];
            if isempty(find_system(simulinkFcnBlk,'SearchDepth',1,...
                'BlockType','FunctionCaller','Name',fcnCallerName))
                add_block('built-in/FunctionCaller',fcnCallerBlk,...
                'FunctionPrototype',this.ServiceFcnPrototype,...
                'Position',[335,200,595,240]);
            end
            autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlock(fcnCallerBlk);



            bswModuleUsesIds=any(strcmp(this.BswCompType,{'Dem','NvM','FiM'}));
            if bswModuleUsesIds&&~strcmp(this.ServiceFunctionName,...
                'Dem_SetPfcCycleQualified')
                idConstantName='Id';
                idConstantBlock=[simulinkFcnBlk,'/',idConstantName];
                if isempty(find_system(simulinkFcnBlk,'SearchDepth',1,...
                    'BlockType','Constant','Name',idConstantName))
                    add_block('built-in/Constant',idConstantBlock);
                end
                set_param(idConstantBlock,'Value',num2str(portDefArgument),...
                'OutDatatypeStr',this.PhysicalIdType,...
                'Position',[265,205,295,235]);
                autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlock(idConstantBlock);


                lh=get_param(idConstantBlock,'LineHandles');
                if(lh.Outport==-1)||...
                    ~strcmp(getfullname(get_param(lh.Outport,'DstBlockHandle')),fcnCallerBlk)
                    add_line(simulinkFcnBlk,[idConstantName,'/1'],...
                    [fcnCallerName,'/1'],...
                    'autorouting','on');
                end
                autosar.mm.mm2sl.MRLayoutManager.homeBlk(idConstantBlock);
            end



            if bswModuleUsesIds
                startIdx=2;
            else
                startIdx=1;
            end
            ph=get_param(fcnCallerBlk,'PortHandles');
            inArgIdx=1;
            for pIdx=startIdx:length(ph.Inport)
                inArgHandle=inArgHandles(inArgIdx);
                argBlockName=get_param(inArgHandle,'Name');
                lh=get_param(inArgHandle,'LineHandles');
                if(lh.Outport==-1)||...
                    ~strcmp(getfullname(get_param(lh.Outport,'DstBlockHandle')),fcnCallerBlk)
                    autosar.mm.mm2sl.layout.LayoutHelper.addLine(simulinkFcnBlk,...
                    [argBlockName,'/1'],...
                    [fcnCallerName,'/',num2str(pIdx)]);
                end
                autosar.mm.mm2sl.MRLayoutManager.homeBlk(inArgHandle);
                inArgIdx=inArgIdx+1;
            end

            for pIdx=1:length(ph.Outport)
                outArgHandle=outArgHandles(pIdx);
                argBlockName=get_param(outArgHandle,'Name');
                lh=get_param(outArgHandle,'LineHandles');
                if(lh.Inport==-1)||...
                    ~strcmp(getfullname(get_param(lh.Inport,'SrcBlockHandle')),fcnCallerBlk)
                    autosar.mm.mm2sl.layout.LayoutHelper.addLine(simulinkFcnBlk,...
                    [fcnCallerName,'/',num2str(pIdx)],...
                    [argBlockName,'/1']);
                end
                autosar.mm.mm2sl.MRLayoutManager.homeBlk(outArgHandle);
            end

            if slfeature('FaultAnalyzerBsw')
                faultCallerName='Update Faults';
                faultCallerBlock=[simulinkFcnBlk,'/',faultCallerName];
                faultCaller=find_system(simulinkFcnBlk,'SearchDepth',1,...
                'BlockType','FunctionCaller',...
                'MaskType','Fault Update Caller');
                if isempty(faultCaller)
                    add_block('autosarspkglib_internal_utils/Update Faults',faultCallerBlock);
                end
            end
        end
    end
end


