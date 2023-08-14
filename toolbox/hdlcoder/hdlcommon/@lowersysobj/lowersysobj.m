classdef lowersysobj<handle





    methods(Static)

        hNewC=lowerDspDelay(hN,hC);
        hNewC=lowerConvolutionEncoder(hN,hC);
        hNewC=lowerViterbiDecoder(hN,hC);
        hNewC=lowerFilterComp(hN,hC);

        function[implMap,pirSupportMap]=getSysObjImplMap()

            persistent sysObjMap allowedObjMap;
            if isempty(sysObjMap)
                [sysObjMap,allowedObjMap]=lowersysobj.createSysObjMap;
            end
            implMap=sysObjMap;
            pirSupportMap=allowedObjMap;
        end

        function found=isPIRSupportedObject(objectName)

            [sysObjMap,~]=lowersysobj.getSysObjImplMap();
            found=isKey(sysObjMap,objectName);
            if~found

                found=lowersysobj.isSystemObjectHDLBlackBox(objectName);
            end
        end

        function found=isAllowedAuthoredObject(objectName)

            [~,allowedObjMap]=lowersysobj.getSysObjImplMap();
            found=isKey(allowedObjMap,objectName);
        end

        function renameBBoxPorts(hC,sysObjImpl)
            nin=sysObjImpl.getNumInputs;
            nout=sysObjImpl.getNumOutputs;

            inportNames=getInputNames(sysObjImpl);

            outportNames=getOutputNames(sysObjImpl);

            for ii=1:nin
                hC.PirInputPorts(ii).Name=char(inportNames(ii));
            end
            for ii=1:nout
                hC.PirOutputPorts(ii).Name=char(outportNames(ii));
            end
        end


        function flag=isSystemObjectHDLBlackBox(name)




            flag=false;
            mc=meta.class.fromName(name);

            if~isempty(mc)
                flag=lowersysobj.isSysObjDerivedFromHDLBlackBox(mc);
            end
        end
        function flag=isSysObjDerivedFromHDLBlackBox(mc)


            flag=false;

            if strcmp(mc.Name,lowersysobj.getBlackBoxName())
                flag=true;
                return;
            end

            for ix=1:length(mc.SuperClasses)
                flag=lowersysobj.isSysObjDerivedFromHDLBlackBox(mc.SuperClasses{ix});
                if flag
                    return;
                end
            end
        end

        function s=getBlackBoxName()
            s='hdl.BlackBox';
        end

        function s=getPIRHDLFunctionObjectName()
            s='hdl.internal.PIRHDLFunctionObject';
        end

        function b=isDerivedFromHDLBlackBox(sysObjName)
            mc=meta.class.fromName(sysObjName);
            superClass=mc.SuperclassList;
            sysObjParent=superClass.Name;
            b=strcmpi(sysObjParent,lowersysobj.getBlackBoxName());
        end

        function implName=getImplementationName(sysObjClassName)
            sysObjImplStr=sysObjClassName;
            [sysObjMap,~]=lowersysobj.getSysObjImplMap();
            if isKey(sysObjMap,sysObjImplStr)
                implName=sysObjMap(sysObjImplStr);
            else
                implName='';
            end
        end

        function lowerPirSysObjComp(hN,hC)

            sysObjImpl=hC.getSysObjImpl;



            sysObjClassName=class(sysObjImpl);
            if isempty(hC.Name)
                hC.Name=sysObjClassName;
            end

            if~isa(sysObjImpl,lowersysobj.getBlackBoxName())&&...
                ~isa(sysObjImpl,lowersysobj.getPIRHDLFunctionObjectName())
                implName=lowersysobj.getImplementationName(sysObjClassName);
                if isempty(implName)
                    error(message('hdlcoder:matlabhdlcoder:unsupportedsystemobject',...
                    sysObjClassName,lowersysobj.getCompName(hC)));
                end
                impl=eval(implName);
                hNewC=impl.elaborate(hN,hC);
            elseif(isa(sysObjImpl,lowersysobj.getPIRHDLFunctionObjectName()))
                implName=sysObjImpl.getPIRImplmentation();
                impl=eval(implName);
                hNewC=impl.elaborate(hN,hC);
            else
                bboxClassName=lowersysobj.getBlackBoxName();
                implName=lowersysobj.getImplementationName(bboxClassName);
                impl=eval(implName);
                lowersysobj.renameBBoxPorts(hC,sysObjImpl);
                params=sysObjImpl.getBlackboxProperties;
                setImplParams(impl,params(1:end-2));
                hNewC=impl.baseElaborate(hN,hC);
                hC=hNewC;
            end

            lowersysobj.postLowering(hN,hC,hNewC);
        end

        function lowerNetwork(hN)
            vComps=hN.Components;
            for j=1:length(vComps)
                hC=vComps(j);
                if strcmp(hC.ClassName,'sysobj_comp')&&hC.isLowerable
                    lowersysobj.lowerPirSysObjComp(hN,hC);
                end
            end
        end

        function doLowering(hPir)

            vNetworks=hPir.Networks;
            for i=1:length(vNetworks)
                hN=vNetworks(i);
                lowersysobj.lowerNetwork(hN);
            end

        end

        function doValidation(hPir,varargin)
            if nargin>=2
                simulinkFlow=varargin{1};
            else
                simulinkFlow=false;
            end
            vNetworks=hPir.Networks;
            for i=1:length(vNetworks)
                hN=vNetworks(i);
                lowersysobj.validateNetwork(hN,simulinkFlow);
            end

        end

        function validateNetwork(hN,simulinkFlow)
            vComps=hN.Components;
            for j=1:length(vComps)
                hC=vComps(j);
                if strcmp(hC.ClassName,'sysobj_comp')&&hC.isLowerable
                    lowersysobj.validatePirSysObjComp(hC,simulinkFlow);
                end
            end
        end

        function[sysObjClassName,hdlImpl]=getSysobjHDLImpl(hC)
            hdlImpl=[];
            sysObjImpl=hC.getSysObjImpl;
            sysObjClassName=class(sysObjImpl);

            if isa(sysObjImpl,lowersysobj.getBlackBoxName())
                sysObjImplStr=lowersysobj.getBlackBoxName();
            elseif isa(sysObjImpl,lowersysobj.getPIRHDLFunctionObjectName())
                implName=sysObjImpl.getPIRImplmentation();
                hdlImpl=eval(implName);
                return;
            else
                sysObjImplStr=sysObjClassName;
            end

            [sysObjMap,~]=lowersysobj.getSysObjImplMap();
            if isKey(sysObjMap,sysObjImplStr)
                hdlImpl=eval(sysObjMap(sysObjImplStr));
            end
        end

        function validatePirSysObjComp(hC,simulinkFlow)
            suppress_report=true;



            launchReport=false;
            levels={'Note','Error','Warning','Message'};
            hasErrors=false;
            [sysObjClassName,hdlImpl]=lowersysobj.getSysobjHDLImpl(hC);
            if~isempty(hdlImpl)
                if isempty(hC.Name)
                    hC.Name=sysObjClassName;
                end
                v=hdlImpl.validate(hC);
                for ii=1:numel(v)
                    check=v(ii).Message;
                    status=v(ii).Status;
                    if~isempty(check)&&status>=1&&status<=3
                        level=levels{status+1};
                        fileName=hC.getFileName();
                        lineNum=hC.getLineNumber();
                        colNum=hC.getColumnNumber();
                        if status==1||status==2
                            launchReport=true;
                            if status==1
                                hasErrors=true;
                            end
                        end
                        if~simulinkFlow
                            emlhdlcoder.EmlChecker.CheckRepository.addCgirCheck(check,v(ii).MessageID,level,fileName,lineNum,colNum);
                        elseif hasErrors
                            error(message('hdlcoder:matlabhdlcoder:systemobjectvalidationmsg',...
                            check));
                        end
                    end
                end
            else
                error(message('hdlcoder:matlabhdlcoder:unsupportedsystemobject',...
                sysObjClassName,lowersysobj.getCompName(hC)));
            end

            p=pir;hTop=p.getTopNetwork;
            topFcnName=hTop.Name;
            cgDirName=p.getParamValue('codegendir');
            dbgLevel=p.getParamValue('debug');
            if launchReport&&~simulinkFlow
                [~,hdlCfg]=hdlismatlabmode();
                assert(~isempty(hdlCfg),message('Coder:hdl:ConfigObjectNotFound'))
                errorCheckReport=hdlCfg.ErrorCheckReport;
                runMATLABHDLCoderChecker(topFcnName,cgDirName,launchReport,dbgLevel,errorCheckReport,suppress_report);
            end
            if hasErrors
                error(message('hdlcoder:matlabhdlcoder:systemobjectvalidation'));
            end
        end

        function setLatency(hN)
            vComps=hN.Components;
            isEnabledSubSystem=hN.isSLEnabledSubsys;
            for j=1:length(vComps)
                hC=vComps(j);
                if strcmp(hC.ClassName,'sysobj_comp')
                    latency=lowersysobj.setCompProperties(hC);
                    if latency>0&&isEnabledSubSystem
                        if strcmpi('hdl.internal.PIRHDLFunctionObject',hC.Name)
                            objImpl=hC.getSysObjImpl;
                            if hdlismatlabmode()

                                error(message('hdlcoder:matlabhdlcoder:cordic_need_zero_latency',objImpl.FunctionName));
                            else

                                error(message('hdlcoder:matlabhdlcoder:cordic_fcnblk_need_zero_latency',objImpl.FunctionName));
                            end
                        else
                            error(message('hdlcoder:matlabhdlcoder:systemobjectlatencyenabled',hC.Name));
                        end
                    end
                end
            end
        end

        function latency=setCompProperties(hC)
            [sysObjClassName,hdlImpl]=lowersysobj.getSysobjHDLImpl(hC);



            latency=0;
            if~isempty(hdlImpl)
                if isempty(hC.Name)
                    hC.Name=sysObjClassName;
                end
                latencyInfo=hdlImpl.getTotalCompLatency(hC);
                hC.setOutputDelay(latencyInfo.outputDelay);
                hC.setInputDelay(latencyInfo.inputDelay);
                hC.setSamplingChange(latencyInfo.samplingChange);
                latency=latencyInfo.outputDelay;
                hC.setHasDesignDelay(hdlImpl.hasDesignDelay);
                state=hdlImpl.getStateInfo;
                hC.setHasState(state.HasState);
                hC.setHasFeedback(state.HasFeedback);
            end

        end

        function copyConstrainedRetimingResults(hC,hNewC)
            hNewC.setConstrainedOutputPipeline(hC.getConstrainedOutputPipeline);
            hNewC.setConstrainedOutputPipelineStatus(hC.getConstrainedOutputPipelineStatus);
            hNewC.setConstrainedOutputPipelineDeficit(hC.getConstrainedOutputPipelineDeficit);
        end

        function postLowering(hN,hC,hNewC)
            if(hNewC~=hC)
                hNewC.copyComment(hC);
                hNewC.SimulinkHandle=hC.SimulinkHandle;
                hNewC.setGMHandle(hC.getGMHandle);
                lowersysobj.copyConstrainedRetimingResults(hC,hNewC);
                hN.removeComponent(hC);
            end
        end


        function name=getCompName(hC)
            if~isempty(hC.Name)
                name=[hC.Owner.Name,'/',hC.Name];
            else
                name=[hC.Owner.Name,'/',hC.RefNum];
            end
        end

        function[sysObjMapContainer,allowedObjMapContainer]=createSysObjMap
            sysObjMapFiles=which('-all','hdlsysobjs.m');
            sysObjMapContainer=containers.Map;
            allowedObjMapContainer=containers.Map;
            for ii=1:numel(sysObjMapFiles)
                fid=fopen(sysObjMapFiles{ii},'r');
                if fid~=-1

                    file=char(fread(fid)');
                    fclose(fid);

                    idx=min(strfind(file,'='));
                    structname=deblank(file(9:idx-1));
                    structname=strtrim(structname);


                    idx=strfind(file,char(10));
                    if~isempty(idx)
                        file(1:idx(1))=[];
                    end
                    try
                        eval(file);
                        newSysObjMap=eval(structname);
                    catch me %#ok<NASGU>

                    end
                    for mapKey=keys(newSysObjMap)
                        value=newSysObjMap(mapKey{1});


                        if strcmp(value,'ALLOW_INSIDE_PIR')...
                            ||strcmp(value,'ALWAYS_ALLOW')
                            if~isKey(allowedObjMapContainer,mapKey{1})
                                allowedObjMapContainer(mapKey{1})=value;
                            end
                        else


                            if~isKey(sysObjMapContainer,mapKey{1})
                                sysObjMapContainer(mapKey{1})=value;
                            end
                        end
                    end
                end
            end
        end

        function checkFiles(filesToCheck)

            for f=filesToCheck

                [directory,file,~]=fileparts(f);
                className=file;
                while contains(directory,'+')||contains(directory,'@')
                    [directory,file]=fileparts(directory);
                    if file(1)=='+'||file(1)=='@'
                        className=[file(2:end),'.',className];
                    else
                        className=[file,'.',className];
                    end
                end


                [~,pirSupportMap]=lowersysobj.getSysObjImplMap();
                if~(lowersysobj.isAllowedAuthoredObject(className)...
                    &&strcmp(pirSupportMap(className),'ALWAYS_ALLOW'))


                    error(className);
                end
            end
        end

    end

end


