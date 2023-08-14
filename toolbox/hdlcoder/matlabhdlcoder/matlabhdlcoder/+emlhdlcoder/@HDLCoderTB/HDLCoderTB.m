classdef HDLCoderTB<handle




    properties(Access=private)
        hHDLDriver;
        hTopFunctionName;
        hTopScriptName;
        hUseFiAccel;
        hCgInfo;
    end

    methods

        function this=HDLCoderTB(varargin)


            this.hTopScriptName=varargin{1};
            this.hTopFunctionName=varargin{2};
            this.hHDLDriver=varargin{3};
            this.hUseFiAccel=varargin{4};

            hMgr=emlhdlcoder.WorkFlow.CodeGenInfoManager.instance;
            this.hCgInfo=hMgr.getCgInfo;

        end


        function hdlDrv=getHDLDriver(this)
            hdlDrv=this.hHDLDriver;
        end


        function generateCustomScripts(this,postCodeGen,postTBGen,synthTool,topNetworkName)
            hdlDrv=this.hHDLDriver;
            isSystemC=(this.hCgInfo.codegenSettings.TargetLanguage=="SystemC");
            hdlDrv.setParameter('hdlcompilescript',(postCodeGen||postTBGen)&&~isSystemC);
            hdlDrv.setParameter('hdlcompiletb',postTBGen&&~isSystemC);
            hdlDrv.setParameter('hdlsimscript',postTBGen&&~isSystemC);
            hdlDrv.setParameter('hdlsimprojectscript',false);
            hdlDrv.setParameter('hdlsynthscript',postCodeGen&&~isSystemC);
            hdlDrv.setParameter('hdlmapfile',false);

            if(nargin>=5)
                topName=topNetworkName;
            else
                [~,topName,~]=fileparts(this.hTopFunctionName);
            end


            scriptGen=hdlshared.EDAScriptsBase(...
            this.hCgInfo.EntityNames,...
            this.hCgInfo.EntityPaths,...
            hdlDrv.TestBenchFilesList,...
            topName);

            epl=this.hCgInfo.hdlEntityPortList;
            epl_ref=this.hCgInfo.hdlEntityRefPortList;
            scriptGen.writeAllScripts(epl,epl_ref,synthTool);
        end


        function setToolScriptOptions(this,hdlDrv,tool)
            hdlDrv.setParameter('hdlcompilescript',true);
            hdlDrv.setParameter('hdlcompiletb',true);
            hdlDrv.setParameter('hdlsimscript',true);
            hdlDrv.setParameter('hdlsimprojectscript',false);
            hdlDrv.setParameter('hdlsynthscript',false);
            hdlDrv.setParameter('hdlmapfile',false);


            if strcmpi(tool,'isim')
                topFcnName=this.hTopFunctionName;

                c1='-work xlib=./work';
                c2='-nodebug';
                hdlDrv.setParameter('hdlcompileinit',sprintf('%s\n%s\n',c1,c2));
                hdlDrv.setParameter('hdlcompileterm','');
                hdlDrv.setParameter('hdlcompilevhdlcmd','%s %s\n');
                hdlDrv.setParameter('hdlcompileverilogcmd','%s %s\n');
                hdlDrv.setParameter('hdlcompilefilepostfix','_isim_tb_compile.do');

                s1='run all';
                s2='quit';

                hdlDrv.setParameter('hdlsiminit',sprintf('%s\n%s\n',s1,s2));
                hdlDrv.setParameter('hdlsimcmd','');
                hdlDrv.setParameter('hdlsimterm','');
                hdlDrv.setParameter('hdlsimviewwavecmd','');



                hdlDrv.setParameter('hdlsimprojectfilepostfix','_tb_simprj.do');
                hdlDrv.setParameter('hdlsimprojectscript',true);
                p1='-lib xlib=./work';

                tbPostFix=hdlDrv.getParameter('tb_postfix');
                p2=sprintf('xlib.%s%s',topFcnName,tbPostFix);

                p3=sprintf('-o %s',[topFcnName,'_isim_design.exe']);
                hdlDrv.setParameter('hdlsimprojectinit',sprintf('%s\n%s\n%s',p1,p2,p3));
                hdlDrv.setParameter('hdlsimprojectcmd','');
                hdlDrv.setParameter('hdlsimprojectterm','');
            else

                e1='onerror {quit -f}';
                e2='onbreak {quit -f}';
                c1='run -all';
                c2='quit -f';
                libC='vlib %s';




                hdlDrv.setParameter('hdlcompileinit',sprintf('%s\n%s\n%s\n',e1,e2,libC));
                hdlDrv.setParameter('hdlcompileterm',sprintf('%s\n',c2));


                if~contains(hdlDrv.getParameter('hdlcompilevhdlcmd'),'vcom')
                    hdlDrv.setParameter('hdlcompilevhdlcmd','vcom %s %s\n');
                end
                if~contains(hdlDrv.getParameter('hdlcompileverilogcmd'),'vlog')
                    hdlDrv.setParameter('hdlcompileverilogcmd','vlog %s %s\n');
                end

                hdlDrv.setParameter('hdlcompilefilepostfix','_vsim_tb_compile.do');

                hdlDrv.setParameter('hdlsiminit',sprintf('%s\n%s\n',e1,e2));


                if~contains(hdlDrv.getParameter('hdlsimcmd'),'vsim')
                    hdlDrv.setParameter('hdlsimcmd','vsim -voptargs=+acc %s.%s\n');
                end

                hdlDrv.setParameter('hdlsimterm',sprintf('%s\n%s\n',c1,c2));
            end
        end


        function generateTBScriptsForAutoSim(this,hdlDrv,simTool,topNetworkName)
            this.setToolScriptOptions(hdlDrv,simTool);

            if(nargin>=4)
                topName=topNetworkName;
            else
                [~,topName,~]=fileparts(this.hTopFunctionName);
            end

            p=pir('MLHDLC');
            scriptGen=hdlshared.EDAScriptsBase(...
            p.getEntityNames,...
            p.getEntityPaths,...
            hdlDrv.TestBenchFilesList,...
            [hdlDrv.getParameter('module_prefix'),topName]);

            epl=this.hCgInfo.hdlEntityPortList;
            epl_ref=this.hCgInfo.hdlEntityRefPortList;

            scriptGen.writeAllScripts(epl,epl_ref);
        end


        function typeMisMatch=isValOfType(~,val,tI)%#ok<*MANU>
            vI=pirgetvaluetypeinfo(val);

            sameBaseType=strcmpi(vI.sltype,tI.sltype);
            if~sameBaseType
                if(vI.issigned==tI.issigned&&...
                    vI.wordsize==tI.wordsize&&...
                    vI.binarypoint==tI.binarypoint)
                    sameBaseType=true;
                end
            end

            sameVecKind=(vI.isvector==tI.isvector);

            if all(vI.dims==tI.dims)
                sameVecSize=true;
            else
                sameVecSize=isequal(max(vI.dims),max(tI.dims));
            end

            sameComplexity=tI.iscomplex==vI.iscomplex;

            typeMisMatch=~(sameBaseType&&sameVecKind&&sameVecSize&&sameComplexity);
        end


        function validateSimValue(~,val)
            if isfi(val)
                nt=numerictype(val);
                if nt.isslopebiasscaled
                    error(message('hdlcoder:matlabhdlcoder:slopebias'));
                end
            end
        end


        function validateDataForTB(this,emlDutInterface,loggedData)
            inportNames=emlDutInterface.inportNames;
            outportNames=emlDutInterface.outportNames;

            numIn=length(inportNames);
            numOut=length(outportNames);

            inputVals=cell(1,numIn);
            for ii=1:numIn
                inputVals{ii}=loggedData.inputs{ii}(1,:);
            end

            outputVals=cell(1,numOut);
            for ii=1:numOut
                outputVals{ii}=loggedData.outputs{ii}(1,:);
            end

            for ii=1:numIn
                tp=emlDutInterface.inputTypesInfo{ii};
                val=inputVals{ii};
                this.validateSimValue(val);

                typeMismatch=this.isValOfType(val,tp);
                if typeMismatch
                    error(message('hdlcoder:matlabhdlcoder:inputtypemismatch',ii));
                end
            end

            for ii=1:numOut
                tp=emlDutInterface.outputTypesInfo{ii};
                val=outputVals{ii};

                this.validateSimValue(val);

                typeMismatch=this.isValOfType(val,tp);
                if typeMismatch
                    warning(message('hdlcoder:matlabhdlcoder:typemismatch',ii));
                end
            end
        end


        function status=generateTB(this,hdlDrv,streamInfo)
            if nargin<3
                streamInfo=struct(...
                'streamedInPorts',[],...
                'streamedOutPorts',[],...
                'streamedInPortsRelative',[],...
                'streamedOutPortsRelative',[]);
            end


            simCmd=hdlDrv.getParameter('hdlsimcmd');
            newCmd=strrep(simCmd,'work.%s','%s.%s');
            hdlDrv.setParameter('hdlsimcmd',newCmd);

            savedpath=path;
            onCleanupObj=onCleanup(@()path(savedpath));

            cginfo=this.getHDLDriver.cgInfo;
            hdlCfg=cginfo.HDLConfig;
            if hdlCfg.IsFixPtConversionDone
                if exist(this.hCgInfo.fxpBldDir,'dir')
                    addpath(this.hCgInfo.fxpBldDir);
                end
            end

            status=true;
            fprintf('\n');
            hdldisp(message('hdlcoder:hdldisp:BeginTBGen'));
            topScriptName=regexprep(this.hTopScriptName,'\.((m(lx)*)|p)$','');
            if isempty(topScriptName)
                if contains(this.hCgInfo.codegenSettings.SynthesisTool,'Cadence Stratus')


                    error(message('Coder:hdl:mltb_not_specified_for_stratus').getString());
                else
                    hdldisp(message('Coder:hdl:tb_skiptb'));
                    status=false;
                    return;
                end
            end
            this.hTopScriptName=topScriptName;


            hdlTBGen=emlhdlcoder.HDLTestbench;
            allFields=fields(this.hCgInfo.hdlTBGen);
            for m=1:numel(allFields)
                fdname=allFields{m};
                hdlTBGen.(fdname)=this.hCgInfo.hdlTBGen.(fdname);
            end
            hdlTBGen.initParamsCommon;


            dataLogger=emlhdlcoder.HDLTBDataLogger(this.hHDLDriver,this.hTopFunctionName,this.hTopScriptName,this.hCgInfo);
            emlDutInterface=this.hCgInfo.emlDutInterface;

            loggedData=dataLogger.computeData(emlDutInterface,streamInfo);

            this.validateDataForTB(emlDutInterface,loggedData);
            dataLog=this.massageLoggedData(loggedData,streamInfo);
            hdlTBGen.collectTestBenchDataEML(dataLog);

            disp(['### ',message('Coder:hdl:tb_beginhdltb').getString()]);
            gp=pir;
            mp='module_prefix';
            hcs='hdlcodingstandard';
            if gp.hasParam(mp)&&~isempty(gp.getParamValue(mp))
                paramStruct=struct(mp,'');
                gp.initParams(paramStruct);
            end
            if gp.hasParam(hcs)&&~isempty(gp.getParamValue(hcs))
                paramStruct=struct(hcs,1);
                gp.initParams(paramStruct);
            end
            hdlTBGen.makehdltbpir(this.hCgInfo);
            if hdlCfg.TargetLanguage=="SystemC"


                prepareAndGenerateSystemCTB(this,hdlCfg,emlDutInterface,loggedData);
            end
            tbFileList=hdlTBGen.TestBenchFilesList;
            hdlDrv.TestBenchFilesList=tbFileList;
            hdlDrv.cgInfo.hdlTbFiles=tbFileList;
        end


        function dataLog=massageLoggedData(this,loggedData,streamInfo)

            if numel(loggedData.outputs)>0
                designLatency=this.hCgInfo.outputPortLatency+...
                this.hCgInfo.outputPortEnabledLatency;
                phaseCycles=this.hCgInfo.outputPortPhaseCycles;
                baseRateScaling=this.hCgInfo.baseRateScaling;
            else
                designLatency=0;
                phaseCycles=0;
                baseRateScaling=1;
            end

            idc=this.hHDLDriver.getParameter('ignoredatachecking');

            lat=max(idc,designLatency+ceil(phaseCycles/baseRateScaling));
            this.hHDLDriver.setParameter('ignoredatachecking',max(lat));
            if numel(loggedData.outputs)>1

                if lat>0
                    for ii=1:numel(lat)
                        hdldisp(message('hdlcoder:hdldisp:OutportLatency',sprintf('%d',ii),sprintf('%d',lat(ii))));
                    end
                end

            else
                if lat>0
                    hdldisp(message('hdlcoder:hdldisp:OutportLatency','',sprintf('%d',lat)));
                end
            end




            streamedInputs=streamInfo.streamedInPortsRelative;
            streamedOutputs=streamInfo.streamedOutPortsRelative;

            numDataIn=numel(loggedData.inputs);
            numDataOut=numel(loggedData.outputs);
            numStreamed=numel(streamedInputs)+numel(streamedOutputs);
            numIn=numDataIn+numStreamed;
            numOut=numDataOut+numStreamed;

            dataLog.inputData=cell(1,numIn);
            dataLog.outputData=cell(1,numOut);

            isTCUsed=this.hCgInfo.isTCUsed;

            if isTCUsed||(numStreamed>0)


                latency=max(designLatency+ceil(phaseCycles/baseRateScaling));
            else




                latency=max(designLatency*baseRateScaling+phaseCycles);
            end

            for ii=1:numDataIn
                data=loggedData.inputs{ii};
                if isempty(data)
                    error(message('hdlcoder:matlabhdlcoder:invalidsimdata'));
                end

                if latency>0&&~isenum(data)

                    data(end+1:end+latency,:)=0;
                end

                dataLog.inputData{ii}=data;


                if isempty(streamedInputs)
                    streamIn=[];
                else
                    streamIn=streamedInputs(ii==[streamedInputs.data]);
                end

                if~isempty(streamIn)
                    assert(isscalar(streamIn));

                    validData=true(size(data,1),1);
                    validData(end-latency+1:end)=false;
                    dataLog.inputData{streamIn.valid}=validData;

                    readyData=true(size(data,1),1);
                    dataLog.outputData{streamIn.ready}=readyData;
                end
            end

            for ii=1:numDataOut
                data=loggedData.outputs{ii};

                if latency>0

                    data(1+latency:end+latency,:)=data(1:end,:);
                    if~isenum(data)
                        data(1:latency,:)=0;
                    end
                end

                dataLog.outputData{ii}=data;


                if isempty(streamedOutputs)
                    streamOut=[];
                else
                    streamOut=streamedOutputs(ii==[streamedOutputs.data]);
                end

                if~isempty(streamOut)
                    assert(isscalar(streamOut));

                    validData=true(size(data,1),1);
                    validData(1:latency)=false;
                    dataLog.outputData{streamOut.valid}=validData;

                    readyData=true(size(data,1),1);
                    dataLog.inputData{streamOut.ready}=readyData;
                end
            end
        end


        generateBDWImportScripts(this,sysCTB,dName);
        generateSystemCTB(this,in,out,moduleName,codegenDirectory,testCases);
        prepareAndGenerateSystemCTB(this,hdlCfg,emlDutInterface,loggedData);
    end
end



