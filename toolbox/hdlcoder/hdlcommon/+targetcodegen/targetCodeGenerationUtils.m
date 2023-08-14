



classdef targetCodeGenerationUtils<handle
    methods(Static)
        function fpMode=isFloatingPointMode()
            fpMode=targetcodegen.targetCodeGenerationUtils.isAlteraMode()||targetcodegen.targetCodeGenerationUtils.isXilinxMode()...
            ||targetcodegen.targetCodeGenerationUtils.isNFPMode();
        end

        function alteraMode=isAlteraMode()
            mode=targetcodegen.targetCodeGenerationUtils.getMode();
            alteraMode=(strcmpi(mode,'ALTERAFPFUNCTIONS')|...
            strcmpi(mode,'ALTFP'));
        end

        function alteraMode=isALTERAFPFUNCTIONSMode()
            mode=targetcodegen.targetCodeGenerationUtils.getMode();
            alteraMode=strcmpi(mode,'ALTERAFPFUNCTIONS');
        end

        function alteraMode=isALTFPMode()
            mode=targetcodegen.targetCodeGenerationUtils.getMode();
            alteraMode=strcmpi(mode,'ALTFP');
        end

        function xilinxMode=isXilinxMode()
            mode=targetcodegen.targetCodeGenerationUtils.getMode();
            xilinxMode=strcmpi(mode,'XILINXLOGICORE');
        end

        function nfpMode=isNFPMode()
            mode=targetcodegen.targetCodeGenerationUtils.getMode();
            nfpMode=strcmpi(mode,'NATIVEFLOATINGPOINT');
        end

        function fc=getConfigurationObject()
            hDriver=hdlcurrentdriver;
            if(isempty(hDriver)||~isa(hDriver,'slhdlcoder.HDLCoder'))
                fc=[];
            else
                fc=hDriver.getParameter('FloatingPointTargetConfiguration');
            end
        end

        function[synthTool,synthFamily,targetFreq]=getSynthesisTargetInfo()
            hDriver=hdlcurrentdriver;
            if(isempty(hDriver)||~isa(hDriver,'slhdlcoder.HDLCoder'))
                synthTool=[];
                synthFamily=[];
                targetFreq=[];
            else
                synthTool=hDriver.getParameter('SynthesisTool');
                synthFamily=hDriver.getParameter('SynthesisToolChipFamily');
                targetFreq=hDriver.getParameter('TargetFrequency');
            end
        end

        function mode=getMode()
            fc=targetcodegen.targetCodeGenerationUtils.getConfigurationObject();
            if(isempty(fc))
                mode='NONE';
            else
                mode=fc.Library;
            end
        end

        function tables=getIPTablesFromPlugins(mode)
            hD=downstream.DownstreamIntegrationDriver('',false,false,'',downstream.queryflowmodesenum.MATLAB,'',true);
            [~,hA]=hD.hAvailableToolList.isInToolList(targetcodegen.targetCodeGenerationUtils.getToolName(mode));
            if(isempty(hA))
                error(message('hdlcommon:targetcodegen:ToolNotSet',mode,targetcodegen.targetCodeGenerationUtils.getToolName(mode)));
            end
            hP=hA.AvailablePlugin;
            tables=hP.IPLatencyTables;
        end

        function toolName=getToolName(mode)
            switch upper(mode)
            case{'ALTERAFPFUNCTIONS'}
                toolName={'Altera Quartus II','Intel Quartus Pro'};
                return;
            case{'ALTFP'}
                toolName='Altera Quartus II';
                return;
            case{'XILINXLOGICORE'}
                toolName='Xilinx ISE';
                return;
            case{'NATIVEFLOATINGPOINT'}
                toolName='NATIVEFLOATINGPOINT';
                return;
            otherwise
                assert(0);
            end
        end

        function lTable=getLatencyTable(mode)

            if strcmpi(mode,'NATIVEFLOATINGPOINT')
                lTable=targetcodegen.targetCodeGenerationUtils.latencyTableForNativeFloatingPoint();
                return;
            end
            hDI=downstream.DownstreamIntegrationDriver('',false,false,'',downstream.queryflowmodesenum.MATLAB,'',true);
            toolName=targetcodegen.targetCodeGenerationUtils.getToolName(mode);
            if ischar(toolName)
                [~,hA]=hDI.hAvailableToolList.isInToolList(toolName);
            else
                for kk=1:length(toolName)
                    [~,hA]=hDI.hAvailableToolList.isInToolList(toolName(kk));
                    if(~isempty(hA))
                        break;
                    end
                end
            end
            if(isempty(hA))
                lTable=[];
                return;
            end
            hP=hA.AvailablePlugin;
            tables=hP.IPLatencyTables;
            switch(upper(mode))
            case{'ALTERAFPFUNCTIONS'}
                lTable=tables{1};
            case{'ALTFP'}
                lTable=tables{2};
            case{'XILINXLOGICORE'}
                lTable=tables{3};
            case{'NATIVEFLOATINGPOINT'}
                lTable=tables{4};
            otherwise
                assert(0);
            end
        end

        function latency=resolveLatencyForComp(c)
            hDriver=hdlcurrentdriver;
            assert(targetmapping.mode(c.PirOutputSignals)||targetmapping.mode(c.PirInputSignals));
            p=pir(c.Owner.getCtxName);
            latency=int32(hDriver.getTargetCodeGenDriver(p).resolveLatencyForComp(c));
        end

        function resolveLatencyForComps(p)
            hDriver=hdlcurrentdriver;
            targetDriver=hDriver.getTargetCodeGenDriver(p);
            for i=1:length(p.Networks)
                n=p.Networks(i);
                for j=1:length(n.Components)
                    c=n.Components(j);
                    if targetmapping.mode(c.PirOutputSignals)||targetmapping.mode(c.PirInputSignals)
                        targetDriver.resolveLatencyForComp(c);
                    end
                end
            end
        end

        function extraArgs=getExtraArgs(ip,dataType)
            fc=hdlgetparameter('FloatingPointTargetConfiguration');
            if(isempty(fc))
                extraArgs='';
            else
                ips=fc.IPConfig.getIPSettings(ip,dataType);
                extraArgs=ips.ExtraArgs;
            end
        end

        function latency=resolveLatencyFromIPSettings(lEntry,this)
            dataType=lEntry.dataType;
            fc=this.getParameter('FloatingPointTargetConfiguration');
            ipc=fc.IPConfig;
            ips=ipc.getIPSettings(lEntry.name,dataType);
            latency=fc.LibrarySettings.resolveLatencyFromIPSettings(ips);
        end

        function lTable=latencyTableForALTERFPFUNCTION()
            idx=0;
            lTable=struct('compType',{},'name',{},'dataType',{});

            lEntry.compType=idx;idx=idx+1;lEntry.name='AddSub';lEntry.dataType='SINGLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Mul';lEntry.dataType='SINGLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Div';lEntry.dataType='SINGLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+0;lEntry.name='Convert';lEntry.dataType='SINGLE_TO_NUMERICTYPE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Convert';lEntry.dataType='NUMERICTYPE_TO_SINGLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Relop';lEntry.dataType='SINGLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Abs';lEntry.dataType='SINGLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Sqrt';lEntry.dataType='SINGLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Rsqrt';lEntry.dataType='SINGLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Recip';lEntry.dataType='SINGLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Exp';lEntry.dataType='SINGLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Log';lEntry.dataType='SINGLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Sin';lEntry.dataType='SINGLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Cos';lEntry.dataType='SINGLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='MultAdd';lEntry.dataType='SINGLE';lTable(end+1)=lEntry;

            idx=0;
            lEntry.compType=idx;idx=idx+1;lEntry.name='AddSub';lEntry.dataType='DOUBLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Mul';lEntry.dataType='DOUBLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Div';lEntry.dataType='DOUBLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+0;lEntry.name='Convert';lEntry.dataType='DOUBLE_TO_NUMERICTYPE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Convert';lEntry.dataType='NUMERICTYPE_TO_DOUBLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Relop';lEntry.dataType='DOUBLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Abs';lEntry.dataType='DOUBLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Sqrt';lEntry.dataType='DOUBLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Rsqrt';lEntry.dataType='DOUBLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Recip';lEntry.dataType='DOUBLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Exp';lEntry.dataType='DOUBLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Log';lEntry.dataType='DOUBLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Sin';lEntry.dataType='DOUBLE';lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Cos';lEntry.dataType='DOUBLE';lTable(end+1)=lEntry;
        end

        function lTable=latencyTableForALTFP()
            idx=0;
            lTable=struct('compType',{},'name',{},'dataType',{},'minLatency',{},'maxLatency',{},'isRange',{});

            lEntry.compType=idx;idx=idx+1;lEntry.name='AddSub';lEntry.dataType='SINGLE';lEntry.minLatency=7;lEntry.maxLatency=14;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Mul';lEntry.dataType='SINGLE';lEntry.minLatency=11;lEntry.maxLatency=11;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Div';lEntry.dataType='SINGLE';lEntry.minLatency=6;lEntry.maxLatency=33;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+0;lEntry.name='Convert';lEntry.dataType='SINGLE_TO_NUMERICTYPE';lEntry.minLatency=6;lEntry.maxLatency=6;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Convert';lEntry.dataType='NUMERICTYPE_TO_SINGLE';lEntry.minLatency=6;lEntry.maxLatency=6;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Relop';lEntry.dataType='SINGLE';lEntry.minLatency=1;lEntry.maxLatency=3;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Abs';lEntry.dataType='SINGLE';lEntry.minLatency=1;lEntry.maxLatency=1;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Sqrt';lEntry.dataType='SINGLE';lEntry.minLatency=16;lEntry.maxLatency=28;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Rsqrt';lEntry.dataType='SINGLE';lEntry.minLatency=26;lEntry.maxLatency=26;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Recip';lEntry.dataType='SINGLE';lEntry.minLatency=20;lEntry.maxLatency=20;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Exp';lEntry.dataType='SINGLE';lEntry.minLatency=17;lEntry.maxLatency=17;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Log';lEntry.dataType='SINGLE';lEntry.minLatency=21;lEntry.maxLatency=21;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Sin';lEntry.dataType='SINGLE';lEntry.minLatency=36;lEntry.maxLatency=36;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Cos';lEntry.dataType='SINGLE';lEntry.minLatency=35;lEntry.maxLatency=35;lEntry.isRange=true;lTable(end+1)=lEntry;

            idx=0;
            lEntry.compType=idx;idx=idx+1;lEntry.name='AddSub';lEntry.dataType='DOUBLE';lEntry.minLatency=7;lEntry.maxLatency=14;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Mul';lEntry.dataType='DOUBLE';lEntry.minLatency=11;lEntry.maxLatency=11;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Div';lEntry.dataType='DOUBLE';lEntry.minLatency=10;lEntry.maxLatency=61;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+0;lEntry.name='Convert';lEntry.dataType='DOUBLE_TO_NUMERICTYPE';lEntry.minLatency=6;lEntry.maxLatency=6;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Convert';lEntry.dataType='NUMERICTYPE_TO_DOUBLE';lEntry.minLatency=6;lEntry.maxLatency=6;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Relop';lEntry.dataType='DOUBLE';lEntry.minLatency=1;lEntry.maxLatency=3;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Abs';lEntry.dataType='DOUBLE';lEntry.minLatency=1;lEntry.maxLatency=1;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Sqrt';lEntry.dataType='DOUBLE';lEntry.minLatency=30;lEntry.maxLatency=57;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Rsqrt';lEntry.dataType='DOUBLE';lEntry.minLatency=36;lEntry.maxLatency=36;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Recip';lEntry.dataType='DOUBLE';lEntry.minLatency=27;lEntry.maxLatency=27;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Exp';lEntry.dataType='DOUBLE';lEntry.minLatency=25;lEntry.maxLatency=25;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Log';lEntry.dataType='DOUBLE';lEntry.minLatency=34;lEntry.maxLatency=34;lEntry.isRange=true;lTable(end+1)=lEntry;
        end

        function lTable=latencyTableForXILINXLOGICORE()
            lTable=struct('compType',{},'name',{},'dataType',{},'minLatency',{},'maxLatency',{},'isRange',{});

            lEntry.compType=0;lEntry.name='AddSub';lEntry.dataType='SINGLE';lEntry.minLatency=12;lEntry.maxLatency=12;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=1;lEntry.name='Mul';lEntry.dataType='SINGLE';lEntry.minLatency=8;lEntry.maxLatency=8;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=2;lEntry.name='Div';lEntry.dataType='SINGLE';lEntry.minLatency=28;lEntry.maxLatency=28;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=3;lEntry.name='Convert';lEntry.dataType='SINGLE_TO_NUMERICTYPE';lEntry.minLatency=6;lEntry.maxLatency=6;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=3;lEntry.name='Convert';lEntry.dataType='NUMERICTYPE_TO_SINGLE';lEntry.minLatency=6;lEntry.maxLatency=6;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=4;lEntry.name='Relop';lEntry.dataType='SINGLE';lEntry.minLatency=2;lEntry.maxLatency=2;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=6;lEntry.name='Sqrt';lEntry.dataType='SINGLE';lEntry.minLatency=28;lEntry.maxLatency=28;lEntry.isRange=true;lTable(end+1)=lEntry;

            lEntry.compType=0;lEntry.name='AddSub';lEntry.dataType='DOUBLE';lEntry.minLatency=12;lEntry.maxLatency=12;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=1;lEntry.name='Mul';lEntry.dataType='DOUBLE';lEntry.minLatency=9;lEntry.maxLatency=9;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=2;lEntry.name='Div';lEntry.dataType='DOUBLE';lEntry.minLatency=57;lEntry.maxLatency=57;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=3;lEntry.name='Convert';lEntry.dataType='DOUBLE_TO_NUMERICTYPE';lEntry.minLatency=6;lEntry.maxLatency=6;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=3;lEntry.name='Convert';lEntry.dataType='NUMERICTYPE_TO_DOUBLE';lEntry.minLatency=6;lEntry.maxLatency=6;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=4;lEntry.name='Relop';lEntry.dataType='DOUBLE';lEntry.minLatency=2;lEntry.maxLatency=2;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=6;lEntry.name='Sqrt';lEntry.dataType='DOUBLE';lEntry.minLatency=57;lEntry.maxLatency=57;lEntry.isRange=true;lTable(end+1)=lEntry;
        end

        function lTable=latencyTableForNativeFloatingPoint()
            idx=0;
            lTable=struct('compType',{},'name',{},'dataType',{},'minLatency',{},'maxLatency',{},'ulp',{},'isRange',{});

            lEntry.compType=idx;idx=idx+1;lEntry.name='AddSub';lEntry.dataType='SINGLE';lEntry.minLatency=6;lEntry.maxLatency=11;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='AddSub';lEntry.dataType='HALF';lEntry.minLatency=4;lEntry.maxLatency=8;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='AddSub';lEntry.dataType='DOUBLE';lEntry.minLatency=6;lEntry.maxLatency=11;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Mul';lEntry.dataType='SINGLE';lEntry.minLatency=6;lEntry.maxLatency=8;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Mul';lEntry.dataType='HALF';lEntry.minLatency=4;lEntry.maxLatency=6;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Mul';lEntry.dataType='DOUBLE';lEntry.minLatency=6;lEntry.maxLatency=9;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Div';lEntry.dataType='DOUBLE';lEntry.minLatency=31;lEntry.maxLatency=61;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Div';lEntry.dataType='SINGLE';lEntry.minLatency=17;lEntry.maxLatency=32;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Div';lEntry.dataType='HALF';lEntry.minLatency=10;lEntry.maxLatency=19;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+0;lEntry.name='Convert';lEntry.dataType='SINGLE_TO_NUMERICTYPE';lEntry.minLatency=6;lEntry.maxLatency=6;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Convert';lEntry.dataType='NUMERICTYPE_TO_SINGLE';lEntry.minLatency=6;lEntry.maxLatency=6;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+0;lEntry.name='Convert';lEntry.dataType='SINGLE_TO_HALF';lEntry.minLatency=2;lEntry.maxLatency=3;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Convert';lEntry.dataType='HALF_TO_SINGLE';lEntry.minLatency=1;lEntry.maxLatency=2;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Convert';lEntry.dataType='DOUBLE_TO_SINGLE';lEntry.minLatency=3;lEntry.maxLatency=6;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Convert';lEntry.dataType='SINGLE_TO_DOUBLE';lEntry.minLatency=3;lEntry.maxLatency=5;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Convert';lEntry.dataType='DOUBLE_TO_NUMERICTYPE';lEntry.minLatency=3;lEntry.maxLatency=6;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Convert';lEntry.dataType='NUMERICTYPE_TO_DOUBLE';lEntry.minLatency=3;lEntry.maxLatency=6;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Convert';lEntry.dataType='HALF_TO_NUMERICTYPE';lEntry.minLatency=2;lEntry.maxLatency=3;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Convert';lEntry.dataType='NUMERICTYPE_TO_HALF';lEntry.minLatency=2;lEntry.maxLatency=4;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;

            lEntry.compType=idx;idx=idx+1;lEntry.name='Relop';lEntry.dataType='SINGLE';lEntry.minLatency=1;lEntry.maxLatency=3;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Relop';lEntry.dataType='DOUBLE';lEntry.minLatency=1;lEntry.maxLatency=3;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Relop';lEntry.dataType='HALF';lEntry.minLatency=1;lEntry.maxLatency=2;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Abs';lEntry.dataType='SINGLE';lEntry.minLatency=0;lEntry.maxLatency=0;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Abs';lEntry.dataType='DOUBLE';lEntry.minLatency=0;lEntry.maxLatency=0;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Sqrt';lEntry.dataType='SINGLE';lEntry.minLatency=16;lEntry.maxLatency=28;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Sqrt';lEntry.dataType='HALF';lEntry.minLatency=6;lEntry.maxLatency=12;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Sqrt';lEntry.dataType='DOUBLE';lEntry.minLatency=36;lEntry.maxLatency=58;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Rsqrt';lEntry.dataType='SINGLE';lEntry.minLatency=16;lEntry.maxLatency=30;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Rsqrt';lEntry.dataType='DOUBLE';lEntry.minLatency=33;lEntry.maxLatency=59;lEntry.ulp=1;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Recip';lEntry.dataType='SINGLE';lEntry.minLatency=16;lEntry.maxLatency=31;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Recip';lEntry.dataType='HALF';lEntry.minLatency=10;lEntry.maxLatency=19;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Recip';lEntry.dataType='DOUBLE';lEntry.minLatency=30;lEntry.maxLatency=60;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='HDLRecip';lEntry.dataType='SINGLE';lEntry.minLatency=14;lEntry.maxLatency=21;lEntry.ulp=5;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Rem';lEntry.dataType='SINGLE';lEntry.minLatency=15;lEntry.maxLatency=24;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Rounding';lEntry.dataType='SINGLE';lEntry.minLatency=3;lEntry.maxLatency=5;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Rounding';lEntry.dataType='DOUBLE';lEntry.minLatency=3;lEntry.maxLatency=5;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Fix';lEntry.dataType='SINGLE';lEntry.minLatency=3;lEntry.maxLatency=5;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Fix';lEntry.dataType='DOUBLE';lEntry.minLatency=3;lEntry.maxLatency=5;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Exp';lEntry.dataType='SINGLE';lEntry.minLatency=16;lEntry.maxLatency=26;lEntry.ulp=1;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Exp';lEntry.dataType='HALF';lEntry.minLatency=9;lEntry.maxLatency=16;lEntry.ulp=1;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Log';lEntry.dataType='DOUBLE';lEntry.minLatency=34;lEntry.maxLatency=44;lEntry.ulp=1;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Log';lEntry.dataType='SINGLE';lEntry.minLatency=20;lEntry.maxLatency=27;lEntry.ulp=1;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Log';lEntry.dataType='HALF';lEntry.minLatency=9;lEntry.maxLatency=17;lEntry.ulp=1;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Log2';lEntry.dataType='SINGLE';lEntry.minLatency=16;lEntry.maxLatency=26;lEntry.ulp=2;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Log10';lEntry.dataType='SINGLE';lEntry.minLatency=17;lEntry.maxLatency=27;lEntry.ulp=1;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Log10';lEntry.dataType='HALF';lEntry.minLatency=10;lEntry.maxLatency=18;lEntry.ulp=1;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='ATan';lEntry.dataType='SINGLE';lEntry.minLatency=36;lEntry.maxLatency=36;lEntry.ulp=2;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='ATan2';lEntry.dataType='SINGLE';lEntry.minLatency=42;lEntry.maxLatency=42;lEntry.ulp=5;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='ASin';lEntry.dataType='SINGLE';lEntry.minLatency=17;lEntry.maxLatency=23;lEntry.ulp=2;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='ACos';lEntry.dataType='SINGLE';lEntry.minLatency=17;lEntry.maxLatency=23;lEntry.ulp=2;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Sin';lEntry.dataType='DOUBLE';lEntry.minLatency=34;lEntry.maxLatency=34;lEntry.ulp=1;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Sin';lEntry.dataType='SINGLE';lEntry.minLatency=27;lEntry.maxLatency=27;lEntry.ulp=2;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Sin';lEntry.dataType='HALF';lEntry.minLatency=8;lEntry.maxLatency=14;lEntry.ulp=1;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Cos';lEntry.dataType='DOUBLE';lEntry.minLatency=48;lEntry.maxLatency=48;lEntry.ulp=1;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Cos';lEntry.dataType='SINGLE';lEntry.minLatency=27;lEntry.maxLatency=27;lEntry.ulp=2;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Cos';lEntry.dataType='HALF';lEntry.minLatency=9;lEntry.maxLatency=14;lEntry.ulp=1;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Tan';lEntry.dataType='SINGLE';lEntry.minLatency=33;lEntry.maxLatency=33;lEntry.ulp=3;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Sinh';lEntry.dataType='SINGLE';lEntry.minLatency=18;lEntry.maxLatency=30;lEntry.ulp=1;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Cosh';lEntry.dataType='SINGLE';lEntry.minLatency=17;lEntry.maxLatency=27;lEntry.ulp=1;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Tanh';lEntry.dataType='SINGLE';lEntry.minLatency=25;lEntry.maxLatency=43;lEntry.ulp=1;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Asinh';lEntry.dataType='SINGLE';lEntry.minLatency=94;lEntry.maxLatency=94;lEntry.ulp=2;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Acosh';lEntry.dataType='SINGLE';lEntry.minLatency=93;lEntry.maxLatency=93;lEntry.ulp=2;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Atanh';lEntry.dataType='SINGLE';lEntry.minLatency=67;lEntry.maxLatency=67;lEntry.ulp=3;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Mod';lEntry.dataType='SINGLE';lEntry.minLatency=16;lEntry.maxLatency=26;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='SinCos';lEntry.dataType='SINGLE';lEntry.minLatency=27;lEntry.maxLatency=27;lEntry.ulp=2;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Signum';lEntry.dataType='SINGLE';lEntry.minLatency=0;lEntry.maxLatency=0;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Signum';lEntry.dataType='DOUBLE';lEntry.minLatency=0;lEntry.maxLatency=0;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='MinMax';lEntry.dataType='SINGLE';lEntry.minLatency=1;lEntry.maxLatency=3;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='GainPow2';lEntry.dataType='SINGLE';lEntry.minLatency=1;lEntry.maxLatency=2;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='GainPow2';lEntry.dataType='DOUBLE';lEntry.minLatency=1;lEntry.maxLatency=2;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='GainPow2';lEntry.dataType='HALF';lEntry.minLatency=1;lEntry.maxLatency=2;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Uminus';lEntry.dataType='SINGLE';lEntry.minLatency=0;lEntry.maxLatency=0;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Uminus';lEntry.dataType='DOUBLE';lEntry.minLatency=0;lEntry.maxLatency=0;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Uminus';lEntry.dataType='HALF';lEntry.minLatency=0;lEntry.maxLatency=0;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Pow2';lEntry.dataType='SINGLE';lEntry.minLatency=14;lEntry.maxLatency=23;lEntry.ulp=1;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Pow10';lEntry.dataType='SINGLE';lEntry.minLatency=16;lEntry.maxLatency=26;lEntry.ulp=1;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Pow';lEntry.dataType='SINGLE';lEntry.minLatency=33;lEntry.maxLatency=54;lEntry.ulp=1;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='MultAdd';lEntry.dataType='SINGLE';lEntry.minLatency=8;lEntry.maxLatency=14;lEntry.ulp=0;lEntry.isRange=true;lTable(end+1)=lEntry;
            lEntry.compType=idx;idx=idx+1;lEntry.name='Hypot';lEntry.dataType='SINGLE';lEntry.minLatency=17;lEntry.maxLatency=33;lEntry.ulp=1;lEntry.isRange=true;lTable(end+1)=lEntry;
        end

        function ulp=getOperatorULP(name,dataType)

            table=struct2table(targetcodegen.targetCodeGenerationUtils.getLatencyTable('NATIVEFLOATINGPOINT'));

            ulp=table.ulp(strcmpi(table.name,name)&strcmpi(table.dataType,dataType));
        end

        function[min,max]=getOperatorLatencies(name,dataType,mode)
            if nargin<3
                mode=targetcodegen.targetCodeGenerationUtils.getMode();
            end
            table=struct2table(targetcodegen.targetCodeGenerationUtils.getLatencyTable(mode));

            min=table.minLatency(strcmpi(table.name,name)&strcmpi(table.dataType,dataType));
            max=table.maxLatency(strcmpi(table.name,name)&strcmpi(table.dataType,dataType));
        end
    end
end



