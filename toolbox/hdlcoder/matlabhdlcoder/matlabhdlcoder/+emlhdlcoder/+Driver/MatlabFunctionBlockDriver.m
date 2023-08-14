classdef MatlabFunctionBlockDriver<handle



    properties(Access=private)
        hHDLDriver;
        hTopFunctionName;
        hTopScriptName;
        hEMLHDLConfig;
    end

    methods


        function this=MatlabFunctionBlockDriver(hdlConfig,hdlDriver)

            this.hHDLDriver=hdlDriver;
            this.hEMLHDLConfig=hdlConfig;

            this.hTopFunctionName=hdlConfig.DesignFunctionName;
            this.hTopScriptName=hdlConfig.TestBenchScriptName;
        end


        function success=checkLicense(~)
            success=false;


            if(~license('test','SIMULINK'))
                warning(message('hdlcoder:matlabhdlcoder:noSimulinkLicense'));
                return;
            end

            success=true;
        end


        function success=fixConvSucess(this)
            success=this.hEMLHDLConfig.IsFixPtConversionDone;
            if(~success)
                warning(message('hdlcoder:matlabhdlcoder:fixptConvRequriedforMatlabFunctionBlock'));
            end
        end


        function doIt(this,cgInfo)

            if(~this.checkLicense)
                return;
            end

            if(~this.fixConvSucess())
                return;
            end

            topName=cgInfo.topName;
            mfFcnName=[topName,'_slcfg'];

            this.genSLMFModel(cgInfo,mfFcnName);
        end
    end

    methods(Access=private)


        function sizeStr=getSizeStr(~,typeInfo)
            if(typeInfo.numdims>1)
                sizeStr='[';
                for i=1:typeInfo.numdims
                    sizeStr=sprintf('%s%d ',sizeStr,typeInfo.dims(i));
                end
                sizeStr=sprintf('%s]',sizeStr);
            else
                sizeStr=sprintf('%d',typeInfo.dims);
            end
        end


        function mfBlkName=genSLMFModel(this,codeGenInfo,mfFcnName)

            hdlCfg=codeGenInfo.codegenSettings;
            script=this.getKernelScript(hdlCfg.DesignFunctionName);

            mt=mtree(script);
            funcNode=mt.root;
            [inPortNames,outPortNames]=coder.internal.MTREEUtils.getFcnInputOutputParamNames(hdlCfg.DesignFunctionName,funcNode);

            coderConstIndices=this.hHDLDriver.cgInfo.coderConstIndices;

            nonConstInportNames=inPortNames;
            nonConstInportNames(coderConstIndices)=[];


            structInputNames=this.screenForStructInputs(codeGenInfo.emlDutInterface.origInportPsuedoRecordTypes,nonConstInportNames);
            structInputNames=unique([structInputNames,this.screenForStructInputs(codeGenInfo.emlDutInterface.origOutportPsuedoRecordTypes,outPortNames)]);
            if~isempty(structInputNames)
                errObj=message('hdlcoder:matlabhdlcoder:UnsupportedMLFCNBLKStructInputs',strjoin(structInputNames,', '));
                if(hdlismatlabmode)
                    emlhdlcoder.EmlChecker.CheckRepository.addCgirCheck(errObj.getString(),errObj.Identifier,...
                    'Error',mfFcnName,0,0);
                else
                    this.hHDLDriver.addCheck(this.hHDLDriver.ModelName,'Error',errObj,'model');
                end
                error(errObj.getString());
            end

            load_system('eml_lib');

            mfMdlHandle=new_system();
            mfMdlName=get_param(mfMdlHandle,'Name');
            hdlsetup(mfMdlName);
            open_system(mfMdlName);

            mfHandle=add_block('eml_lib/MATLAB Function',[mfMdlName,'/',mfFcnName],'MakeNameUnique','on');
            mfBlkName=get_param(mfHandle,'Name');
            mfBlkPath=[mfMdlName,'/',mfBlkName];

            r=sfroot;
            m=r.find('-isa','Stateflow.Machine','Name',mfMdlName);
            c=m.find('-isa','Stateflow.EMChart','Path',mfBlkPath);
            d=c.find('-isa','Stateflow.Data');


            for i=1:length(d)
                d(i).delete;
            end

            c.InputFimath='hdlfimath';
            c.TreatAsFi='Fixed-point & Integer';


            numInPorts=0;
            numOutPorts=0;

            inPortVals=this.hHDLDriver.cgInfo.inVals;
            inputITCs=this.hHDLDriver.cgInfo.inputITCs;
            assert(length(inPortNames)==length(inPortVals));



            initFcnStr='';
            for ii=1:length(inputITCs)
                d=Stateflow.Data(c);
                d.Name=inPortNames{ii};

                itc=inputITCs{ii};

                if(isa(itc,'coder.Constant'))
                    d.Scope='Parameter';
                    val=itc.Value;
                    d.Scope='Parameter';
                    typeInfo=pirgetvaluetypeinfo(val);
                    if isa(val,'embedded.fi')
                        initFcnStr=sprintf('%s\n%s = fi(%s, %s);',initFcnStr,...
                        d.Name,mat2str(val.double()),val.numerictype().tostring());
                        d.DataType='Expression';
                        d.Props.Type.Expression=['fixdt(''',typeInfo.sltype,''')'];
                    else
                        initFcnStr=sprintf('%s\n%s = %s;',initFcnStr,d.Name,mat2str(val));
                        d.DataType='Expression';
                        d.Props.Type.Expression=typeInfo.sltype;
                    end
                    d.Tunable=0;
                else
                    d.Scope='Input';
                    numInPorts=numInPorts+1;

                    coderType=itc;
                    typeInfo=matlabcoder2simulinktypes(coderType);

                    d.DataType='Expression';
                    d.Props.Type.Expression=['fixdt(''',typeInfo.sltype,''')'];

                end

                d.Props.Array.Size=this.getSizeStr(typeInfo);
                if(typeInfo.iscomplex)
                    d.props.Complexity='on';
                else
                    d.props.Complexity='off';
                end
            end

            for ii=1:length(outPortNames)
                d=Stateflow.Data(c);
                d.Name=outPortNames{ii};
                d.Scope='Output';
                numOutPorts=numOutPorts+1;
            end


            c.Script=script;


            set_param(mfMdlName,'initFcn',initFcnStr);

            this.transferSettings(mfMdlName,mfBlkPath,hdlCfg);

            inPortHandles=zeros(1,numInPorts);
            for i=1:numInPorts
                slHandle=add_block('built-in/Inport',[mfMdlName,'/in',num2str(i)],'MakeNameUnique','on');
                inPortHandles(i)=slHandle;
            end
            outPortHandles=zeros(1,numOutPorts);
            for i=1:numOutPorts
                slHandle=add_block('built-in/Outport',[mfMdlName,'/out',num2str(i)],'MakeNameUnique','on');
                outPortHandles(i)=slHandle;
            end

            emlhdlcoder.Driver.SimulinkUtilDriver.formatBlockWithPorts(inPortHandles,outPortHandles,mfHandle);
        end

        function transferSettings(~,mfMdlName,mfBlkPath,hdlCfg)


            emlhdlcoder.Driver.SimulinkUtilDriver.transferMdlSettings(mfMdlName,hdlCfg);


            blkSettings=struct('slParam',{},'hdlCfgParam',{});
            blkSettings(end+1).slParam='ConstMultiplierOptimization';blkSettings(end).hdlCfgParam='ConstantMultiplierOptimization';
            blkSettings(end+1).slParam='DistributedPipelining';blkSettings(end).hdlCfgParam='DistributedPipelining';
            blkSettings(end+1).slParam='InputPipeline';blkSettings(end).hdlCfgParam='InputPipeline';

            blkSettings(end+1).slParam='MapPersistentVarsToRAM';blkSettings(end).hdlCfgParam='MapPersistentVarsToRAM';
            blkSettings(end+1).slParam='OutputPipeline';blkSettings(end).hdlCfgParam='OutputPipeline';
            blkSettings(end+1).slParam='InstantiateFunctions';blkSettings(end).hdlCfgParam='InstantiateFunctions';

            emlhdlcoder.Driver.SimulinkUtilDriver.transferHDLSettings(mfBlkPath,blkSettings,hdlCfg);

            if(strcmpi(hdlCfg.LoopOptimization,'LoopNone'))
                val='none';
            elseif(strcmpi(hdlCfg.LoopOptimization,'UnrollLoops'))
                val='Unrolling';
            else
                val='Streaming';
            end
            hdlset_param(mfBlkPath,'LoopOptimization',val);
        end

        function script=getKernelScript(~,ipFileName)
            script=fileread(which(ipFileName));
        end

        function structInputNames=screenForStructInputs(~,origPsuedoRecordTypes,portNames)
            assert(length(origPsuedoRecordTypes)==length(portNames));

            structInputNames={};
            for ii=1:length(origPsuedoRecordTypes)
                tp=origPsuedoRecordTypes{ii};
                if isfield(tp,'isRecordType')&&tp.isRecordType
                    structInputNames{end+1}=portNames{ii};%#ok<AGROW>
                end
            end
        end
    end
end



