function blockInstantiation(this,topslbh,blockInfo,configManager,hThisNetwork)




    otherblocks=[blockInfo.OtherBlocks,blockInfo.EnablePort,...
    blockInfo.ActionPort,blockInfo.ResetPort,blockInfo.StateControl,...
    blockInfo.StateEnablePort,blockInfo.TriggerPort];
    handleReusable=this.HandleReusableSubsystem;
    generateGenerics=this.HDLCoder.getParameter('MaskParameterAsGeneric');

    for k=1:length(otherblocks)
        slbh=otherblocks(k);
        typ=get_param(slbh,'BlockType');

        switch typ
        case 'SubSystem'
            blockPath=getfullname(slbh);

            impl=configManager.getImplementationForBlock(blockPath);

            if~isempty(blockPath)
                busexpansion=slhdlcoder.SimulinkFrontEnd.isBusExpansionSubsystem(slbh);
                bbox=false;
                if busexpansion
                    this.validateBusExpansionSubsystem(blockPath,slbh);
                    donotrecurse=false;
                else
                    [donotrecurse,bbox]=this.isAFrontEndStopSubsystem(impl,blockPath);
                end
                if donotrecurse
                    hC=this.pirAddComponent(slbh,hThisNetwork);
                    this.setImplAndParams(hC,slbh,configManager);
                    if(bbox)
                        setBboxPortParams(this,hC,slbh,configManager);
                    end
                else

                    if isReuseable(this,handleReusable,blockPath,slbh)



                        if generateGenerics
                            [maskParamInfo,unsupportedParam]=...
                            this.collectMaskParamInfo(slbh,configManager);
                        else
                            maskParamInfo=[];
                            unsupportedParam=false;
                        end

                        [foundPirNtwkForSS,checksumStr,hChildNetwork]=...
                        this.isHandledReusableSS(blockPath);






                        if~unsupportedParam


                            this.ReusedSSBlks(blockPath)=checksumStr;
                        end

                        if foundPirNtwkForSS&&~unsupportedParam


                            hNtwkInstComp=this.pirAddNtwkInstanceComp(slbh,...
                            hThisNetwork,hChildNetwork);
                        else


                            [hChildNetwork,hNtwkInstComp]=recurseIntoSubsystem(this,...
                            blockPath,slbh,configManager,hThisNetwork,impl);



                            if~isempty(hChildNetwork)&&isForEachSubsystem(hChildNetwork)...
                                &&~unsupportedParam
                                [maskParamInfo,unsupportedParam]=...
                                this.collectMaskParamInfo(slbh,configManager);
                            end

                            validateIPBlockRecurseSS(this,impl,blockPath,hChildNetwork,hNtwkInstComp);



                            if~isempty(checksumStr)
                                this.CheckSumNtwkMap(checksumStr)=hChildNetwork;
                            end
                        end


                        if generateGenerics||(~isempty(hChildNetwork)&&isForEachSubsystem(hChildNetwork))
                            if~unsupportedParam
                                this.annotateMaskParamInfo(maskParamInfo,hChildNetwork,...
                                hNtwkInstComp,foundPirNtwkForSS);
                            end
                        end
                    else
                        if generateGenerics
                            [maskParamInfo,unsupportedParam]=...
                            this.collectMaskParamInfo(slbh,configManager);
                        else
                            maskParamInfo=[];
                            unsupportedParam=false;
                        end

                        [hChildNetwork,hNtwkInstComp]=...
                        recurseIntoSubsystem(this,blockPath,slbh,...
                        configManager,hThisNetwork,impl);



                        if~isempty(hChildNetwork)&&isForEachSubsystem(hChildNetwork)...
                            &&~unsupportedParam
                            [maskParamInfo,unsupportedParam]=...
                            this.collectMaskParamInfo(slbh,configManager);
                        end

                        if~isempty(impl)&&impl.recurseIntoSubSystem
                            v=impl.validateBlock(hNtwkInstComp);
                            updateSubsystemChecks(this,v,slbh);
                            validateIPBlockRecurseSS(this,impl,blockPath,hChildNetwork,hNtwkInstComp);
                        end

                        if isBlockASubsystemBasedLibrary(blockPath,impl)

                            storeNetworkForFlatteningPhase(this,hChildNetwork);
                        end
                        if~isempty(impl)
                            setPipelineInfo(this,hChildNetwork,impl);
                        end

                        if generateGenerics||(~isempty(hChildNetwork)&&isForEachSubsystem(hChildNetwork))
                            if~unsupportedParam

                                this.annotateMaskParamInfo(maskParamInfo,hChildNetwork,...
                                hNtwkInstComp,false);
                            end
                        end
                    end
                end
            end

        case 'ModelReference'
            blockPath=getfullname(slbh);
            impl=configManager.getImplementationForBlock(blockPath);
            if isa(impl,'hdldefaults.ModelReference')
                instantiateModelReference(this,blockPath,slbh,hThisNetwork,...
                configManager,impl);
            else

                hC=this.pirAddComponent(slbh,hThisNetwork);
                this.setImplAndParams(hC,slbh,configManager);
            end
        case 'StateControl'



        case 'PMIOPort'

        otherwise
            hC=this.pirAddComponent(slbh,hThisNetwork);
            this.setImplAndParams(hC,slbh,configManager);
            checkAssertionComp(this,hC);
        end
    end


    toptype=get_param(topslbh,'Type');
    if strcmp(toptype,'block_diagram')||strcmp(toptype,'block')
        this.collectTopMaskParamInfo(blockInfo,configManager,hThisNetwork);
    end
end



function r=isReuseable(this,handleReusable,blockPath,slbh)
    if strcmp(hdlgetparameter('subsystemreuse'),'Atomic and Virtual')&&handleReusable


        r=isKey(this.CheckSumInfo,blockPath);
    elseif strcmp(hdlgetparameter('subsystemreuse'),'Atomic only')
        r=handleReusable&&this.isReusableSS(slbh);
    else
        r=false;
    end
end


function b=isBlockASubsystemBasedLibrary(blockPath,impl)



    bRecurse=((~strcmp(hdlgetblocklibpath(blockPath),'built-in/SubSystem'))&&...
    (~isempty(impl)&&impl.recurseIntoSubSystem()));
    bBusAssign=(~isempty(impl)&&isa(impl,'hdldefaults.BusAssignment'));
    b=bRecurse||bBusAssign;
end


function updateSubsystemChecks(this,v,slbh)
    for kk=1:length(v)
        if v(kk).Status
            SubsystemLibraryBlockChecks=struct();
            SubsystemLibraryBlockChecks.path=getfullname(slbh);
            SubsystemLibraryBlockChecks.type='block';
            SubsystemLibraryBlockChecks.message=v(kk).Message;
            if v(kk).Status==1
                SubsystemLibraryBlockChecks.level='Error';
            elseif v(kk).Status==2
                SubsystemLibraryBlockChecks.level='Warning';
            else
                SubsystemLibraryBlockChecks.level='Message';
            end
            SubsystemLibraryBlockChecks.MessageID=v(kk).MessageID;
            hdlDrv=this.HDLCoder;
            hdlDrv.updateChecksCatalog(this.hPir.ModelName,SubsystemLibraryBlockChecks);
        end
    end
end



function storeNetworkForFlatteningPhase(this,hNetwork)
    if isempty(this.MaskedSubsystemLibraryBlocks)
        this.MaskedSubsystemLibraryBlocks=hNetwork;
    else
        this.MaskedSubsystemLibraryBlocks(end+1)=hNetwork;
    end
end




function[hChildNetwork,hNtwkInstComp]=recurseIntoSubsystem(this,blockPath,...
    slbh,configManager,hParentNetwork,impl)
    hChildNetwork=[];
    hNtwkInstComp=[];

    if allowedBlocksForRecurse(slbh)
        [isInternalLib,isUnregistered]=this.getInternalLibraryBlockInfo(slbh,impl);
        if isInternalLib
            this.InBlockSSPIRConstruction=this.InBlockSSPIRConstruction+1;

            if isUnregistered&&this.InBlockSSPIRConstruction==1

                if(strcmp(hdlfeature('DetectValidHDLRegistrations'),'on'))
                    msgObj=message('hdlcoder:engine:InvalidBlockRegistration',blockPath,hdlgetblocklibpath(slbh));
                    this.updateChecks(blockPath,'block',msgObj,'Warning');
                end

            end

        end

        hChildNetwork=this.constructPIR(blockPath,configManager);

        if isInternalLib
            this.InBlockSSPIRConstruction=this.InBlockSSPIRConstruction-1;
        end

    else
        msgobj=message('hdlcoder:engine:missingImplementation',...
        strrep(blockPath,newline,' '));
        this.updateChecks(blockPath,'block',msgobj,'Error');
    end

    if~isempty(hChildNetwork)
        hNtwkInstComp=this.pirAddNtwkInstanceComp(slbh,hParentNetwork,hChildNetwork);
    end
end


function instantiateModelReference(this,blockPath,slbh,hThisNetwork,...
    configManager,impl)

    treatAsBlackBox=strcmp(get_param(slbh,'ProtectedModel'),'on');
    if~treatAsBlackBox&&strcmp(hdlgetparameter('compilestrategy'),'CompileChanged')
        refMdlName=get_param(blockPath,'ModelName');
        check=arrayfun(@(x)strcmp(x.modelName,refMdlName),...
        this.HDLCoder.AllModels);
        treatAsBlackBox=isempty(find(check,1));
    end

    if treatAsBlackBox

        modelName=get_param(slbh,'Name');



        modelFile=get_param(slbh,'ModelFile');
        [~,refName,~]=fileparts(modelFile);
        dirPath=[this.HDLCoder.hdlGetBaseCodegendir,filesep,refName];
        matFile=[dirPath,filesep,'hdlcodegenstatus.mat'];
        clear('CodeGenStatus');
        clear('ModelGenStatus');
        load(matFile,'ModelGenStatus');
        load(matFile,'CodeGenStatus');
        load(matFile,'Latency');
        inPorts={ModelGenStatus.TopNetworkPortInfo.inputPorts.Name};
        outPorts={ModelGenStatus.TopNetworkPortInfo.outputPorts.Name};
        clockPortName={CodeGenStatus.clockReportDatt.clockData.name};
        clockEnablePorts={CodeGenStatus.clockReportDatt.clockEnableData};
        clockPortStatus='on';


        if all(strcmp(clockPortName,''))&&...
            (numel(clockEnablePorts)==0||...
            (numel(clockEnablePorts)>0&&isempty(clockEnablePorts{1})))
            clockPortStatus='off';
        end

        clear('CodeGenStatus');
        CLIstr=ModelGenStatus.CLI;
        vhdllibname=getVHDLLibraryName(CLIstr);
        pirelab.instantiateProtectedModel('Network',hThisNetwork,...
        'EntityName',refName,...
        'Name',modelName,...
        'InportNames',inPorts,...
        'OutportNames',outPorts,...
        'AddClockPort',clockPortStatus,...
        'AddClockEnablePort',clockPortStatus,...
        'AddResetPort',clockPortStatus,...
        'Latency',Latency,...
        'ClockEnablePorts',clockEnablePorts,...
        'VHDLLibraryName',vhdllibname,...
        'SLHandle',slbh);


        return;
    end

    if this.HDLCoder.getParameter('hierarchicalDistPipelining')
        msg=message('hdlcoder:validate:ModelRefHierDistPipeline');
        this.updateChecks(blockPath,'block',msg,'Warning');
        this.HDLCoder.setParameter('hierarchicalDistPipelining',0);
    end


    refMdlName=get_param(blockPath,'ModelName');
    refPir=pir(refMdlName);

    if strcmp(hdlgetparameter('compilestrategy'),'CompileChanged')
        refMdlPrefix='';
    else
        refMdlPrefix=getReferenceModelPrefix(this,impl,refMdlName,blockPath);
    end

    refPir.setReferenceModelPrefix(refMdlPrefix);



    simMode=get_param(slbh,'SimulationMode');
    if strncmp(simMode,'softw',5)||strncmp(simMode,'proce',5)
        simMode='Normal';
    end
    rcName=this.validateAndGetName(get_param(slbh,'Name'));
    hNewC=pirelab.instantiateModel(hThisNetwork,refPir,[],...
    [],rcName,simMode);
    hNewC.SimulinkHandle=slbh;

    refNtwk=hNewC.ReferenceNetwork;
    desc=get_param(slbh,'Description');

    if~isempty(refNtwk)
        refNtwk.addComment(desc);
    end

    this.setNetworkRefCompParams(refNtwk,configManager,blockPath,false);


    this.readModelRefMaskParams(slbh,blockPath,refNtwk,hNewC);
end


function name=getVHDLLibraryName(CLIstr)






    name='';
    newstr=splitlines(CLIstr);
    for ii=1:numel(newstr)
        str=newstr(ii);
        str1=str{1};
        if regexp(str1,'VHDLLibraryName.*')
            [~,second]=strtok(str1,':');
            last=strtok(second,':');
            name=regexprep(last,'''','');
            name=regexprep(name,' ','');
        end
    end
end


function setBboxPortParams(this,hC,slbh,configManager)
    bboxiph=find_system(slbh,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','Inport');
    bboxoph=find_system(slbh,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','Outport');

    for ii=1:length(bboxiph)
        bbph=bboxiph(ii);
        impl=this.pirGetImplementation(bbph,configManager);
        isbidi=impl.getImplParams('BidirectionalPort');
        b=~isempty(isbidi)&&strcmpi(isbidi,'on');
        portnum=str2double(get_param(bbph,'Port'))-1;
        hC.setInPortBidirectional(portnum,b);
    end

    for ii=1:length(bboxoph)
        bbph=bboxoph(ii);
        impl=this.pirGetImplementation(bbph,configManager);
        isbidi=impl.getImplParams('BidirectionalPort');
        b=~isempty(isbidi)&&strcmpi(isbidi,'on');
        portnum=str2double(get_param(bbph,'Port'))-1;
        hC.setOutPortBidirectional(portnum,b);
    end
end


function checkAssertionComp(this,hC)
    if strcmp(hC.getImplementationName,'hdldefaults.Assertion')
        this.AssertionCompPresent=true;
    end
end

function allowed=allowedBlocksForRecurse(slbh)
    allowed=true;
    refBlk=get_param(slbh,'ReferenceBlock');



    if contains(refBlk,['Slider',newline,'Gain'])
        allowed=false;
    end
end


function validateIPBlockRecurseSS(this,impl,blockPath,hChildNetwork,hNtwkInstComp)


    if slhdlcoder.SimulinkFrontEnd.isIPBlockRecurseSS(impl)
        impl.validateNetworkPostConstruction(hChildNetwork,...
        hNtwkInstComp,this.HDLCoder);


        impl.updateInfRatesOnConstantComps(hNtwkInstComp.ReferenceNetwork);


        impl.propagateSuppressValidationForNetworks(hChildNetwork,blockPath);
    end
end





