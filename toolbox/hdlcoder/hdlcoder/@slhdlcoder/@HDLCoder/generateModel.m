function generateModel(this,hPir,mpd)






    infile=hPir.ModelName;
    verbose=this.getParameter('verbose');
    openoutfile=any(strcmp(this.getParameter('codegenerationoutput'),...
    {'DisplayGeneratedModelOnly',...
    'GenerateHDLCodeAndDisplayGeneratedModel'}));

    outfile=this.getParameter('generatedmodelname');
    outfileprefix=this.getParameter('generatedmodelnameprefix');
    autoroute=this.getParameter('autoroute');
    autoplace=this.getParameter('autoplace');
    hiliteparents=this.getParameter('hiliteancestors');
    color=this.getParameter('hilitecolor');
    showCGPIR=this.getParameter('showcodegenpir');
    hyperlinksInLog=~this.getParameter('BuildToProtectModel');
    usearrangesystem=this.getParameter('UseArrangeSystem');
    samplesPerCycle=this.getParameter('SamplesPerCycle');

    hb=slhdlcoder.SimulinkBackEnd(hPir,...
    'InModelFile',infile,...
    'OutModelFile',outfile,...
    'DUTMdlRefHandle',this.DUTMdlRefHandle,...
    'ShowModel',mapyesno(openoutfile),...
    'OutModelFilePrefix',outfileprefix,...
    'ShowCodeGenPIR',mapyesno(showCGPIR),...
    'AutoRoute',mapyesno(autoroute),...
    'AutoPlace',mapyesno(autoplace),...
    'UseArrangeSystem',mapyesno(usearrangesystem),...
    'HiliteAncestors',mapyesno(hiliteparents),...
    'HiliteColor',color,...
    'HyperlinksInLog',hyperlinksInLog,...
    'Verbose',verbose,...
    'nonTopDut',this.nonTopDut,...
    'SamplesPerCycle',samplesPerCycle);


    this.BackEnd=hb;
    gmReady=false;
    regen=this.getIncrementalCodeGenDriver.modelGenerationPredicate(this,hPir);
    incrForTop=incrementalcodegen.IncrementalCodeGenDriver.topModelPredicate(hPir.modelName);


    if~regen&&incrForTop&&~this.getParameter('Backannotation')

        gmModel=this.BackEnd.getOutModelFile(true);
        try
            hdldisp(sprintf('Loading Target model %s',gmModel),3);
            load_system(fullfile(this.hdlGetCodegendir,gmModel));
            this.BackEnd.resolveOutModelFile(false);
            if this.DUTMdlRefHandle>0&&~this.isDutModelRef



                if numel(this.AllModels)==this.mdlIdx


                    simMode=get_param(get_param(this.DUTMdlRefHandle,'ActiveVariantBlock'),'SimulationMode');
                    this.BackEnd.createAndSetGMSubmodelVariant(gmModel,simMode);
                    set_param(this.DUTMdlRefHandle,'LabelModeActiveChoice',...
                    this.gmVariantName);
                end
            end
            gmReady=true;
        catch %#ok<CTCH>
        end
    end



    if~gmReady
        this.BackEnd.generateModel;
        saveGeneratedModel(this,hPir);
        this.cleanupModelRef;
    end

    this.BackEnd.postModelgenTasks(hPir,mpd);

    isSameAsOutModelFile=true;
    if this.DUTMdlRefHandle>0
        mdlBlk=get_param(this.DUTMdlRefHandle,'ActiveVariantBlock');
        isSameAsOutModelFile=strcmp(get_param(mdlBlk,'ModelName'),this.BackEnd.OutModelFile);
        mdlObj=get_param(mdlBlk,'Object');
        mdlObj.refreshModelBlock;
        vss=getfullname(this.DUTMdlRefHandle);
        modelName=get_param(mdlBlk,'ModelName');
        updateVssPortNames(vss,modelName);
        addExtraPortsToVSS(vss,modelName);
    end

    if(this.nonTopDut&&strcmp(hdlfeature('NonTopNoModelReference'),'on'))
        prefix=this.getParameter('GeneratedModelNamePrefix');
        topGMName=getGeneratedModelName(prefix,this.OrigModelName,false);
        this.setParameter('generatedmodelname',topGMName);
        this.updateCLI('generatedmodelname',topGMName);
    end

    if this.DUTMdlRefHandle>0&&isSameAsOutModelFile


        prefix=this.getParameter('GeneratedModelNamePrefix');
        topGMName=getGeneratedModelName(prefix,this.OrigModelName,false);
        if this.isDutModelRef
            gmDUT=getDutName(this.OrigStartNodeName,this.OrigModelName,topGMName);


            mdlBlk=get_param(gmDUT,'ActiveVariantBlock');
            set_param(mdlBlk,'ModelName',this.PirInstance.GeneratedModelName);
        end
        gmDUT=getDutName(this.OrigStartNodeName,this.OrigModelName,topGMName);
        drawTunableConstBlocks(this,gmDUT,this.PirInstance.getTopNetwork);

        if(this.getParameter('EnableTestpoints'))
            gmTop=gmDUT;



            index=strfind(this.OrigStartNodeName,this.OrigModelName);
            first=index(1);
            if first==1
                gmTop=[this.OrigStartNodeName(1:first-1),topGMName,this.OrigStartNodeName(first+length(this.OrigModelName):end)];
            end
            connectTestpoints(this,gmTop,this.PirInstance.getTopNetwork);
        end




        mdlIdxSave=this.mdlIdx;
        this.mdlIdx=numel(this.AllModels);
        codegenDir=this.hdlGetCodegendir;
        this.mdlIdx=mdlIdxSave;





        variants=get_param(gmDUT,'Variants');
        for i=1:length(variants)
            mdlObj=get_param(variants(i).BlockName,'Object');

            mdlObj.refreshModelBlock;
        end

        save_system(topGMName,...
        fullfile(codegenDir,[topGMName,'.slx']),...
        'OverwriteIfChangedOnDisk',true,'SaveModelWorkspace',false);
    end
end

function drawTunableConstBlocks(this,gmDUT,hNet)


    if~tunablePortsPresent(hNet)
        return;
    end





    set_param(get_param(gmDUT,'ActiveVariantBlock'),'ModelName',this.PirInstance.GeneratedModelName);


    posOfDut=get_param(gmDUT,'Position');
    move_down=[0,50];
    blkSize=[30,30];
    posOfBlk=[posOfDut(1)-60,posOfDut(2)-30];

    outFileName=fileparts(gmDUT);
    for ii=1:numel(hNet.PirInputPorts)
        if~strcmp(hNet.PirInputPorts(ii).getTunableName(),'')
            tunName=hNet.PirInputPorts(ii).getTunableName();
            outFileBlkName=[outFileName,'/','tunable_const'];
            new_block=add_block('built-in/Constant',outFileBlkName,...
            'MakeNameUnique','on','Value',char(tunName));
            DTstruct=getslsignaltype(hNet.PirInputPorts(ii).Signal.Type);
            set_param(new_block,'OutDataTypeStr',DTstruct.viadialog);

            posOfBlk=posOfBlk+move_down;
            position=[posOfBlk,posOfBlk+blkSize];
            set_param(new_block,'Position',position);
            srcPort=[char(get_param(new_block,'Name')),'/','1'];
            dstPort=[char(get_param(gmDUT,'Name')),'/',num2str(ii)];
            add_line(outFileName,srcPort,dstPort,'autorouting','on');
        end
    end
end

function retval=tunablePortsPresent(hNet)

    retval=false;
    for ii=1:numel(hNet.PirInputPorts)
        if~strcmp(hNet.PirInputPorts(ii).getTunableName(),'')
            retval=true;
            break;
        end
    end
end




function result=mapyesno(booleaninput)
    mapstr={'no','yes'};
    result=mapstr{(double(booleaninput)+1)};
end




function saveGeneratedModel(this,pirInstance)
    genMdlName=pirInstance.GeneratedModelName;
    fullGenMdlName=fullfile(this.hdlGetCodegendir,[genMdlName,'.slx']);
    this.hdlMakeCodegendir;
    if numel(this.AllModels)>1


        if strcmp(this.AllModels(end).modelName,pirInstance.ModelName)
            if isAbsolutePath(this.hdlGetCodegendir)
                here=this.hdlGetCodegendir;
            else
                here=fullfile(pwd,this.hdlGetCodegendir);
            end
            preLoadFcn=get_param(genMdlName,'PreLoadFcn');
            newPreLoadFcn=sprintf('%s\naddpath(''%s'');\n',preLoadFcn,here);
            set_param(genMdlName,'PreLoadFcn',newPreLoadFcn);
            closeFcn=get_param(genMdlName,'CloseFcn');
            newCloseFcn=sprintf('%s\naddpath(''%s'');\nrmpath(''%s'');\n',...
            closeFcn,here,here);
            set_param(genMdlName,'CloseFcn',newCloseFcn);
        end
    end



    for ii=1:numel(this.ProtectedModels)
        protectedModel=this.ProtectedModels(ii);
        if isAbsolutePath(this.hdlGetBaseCodegendir)
            here=this.hdlGetBaseCodegendir;
        else
            here=fullfile(pwd,this.hdlGetBaseCodegendir);
        end
        protectedModelPath=fullfile(here,protectedModel.modelName);
        preLoadFcn=get_param(genMdlName,'PreLoadFcn');
        newPreLoadFcn=sprintf('%s\naddpath(''%s'');\n',preLoadFcn,protectedModelPath);
        set_param(genMdlName,'PreLoadFcn',newPreLoadFcn);


        initFcn=get_param(genMdlName,'InitFcn');
        newInitFcn=sprintf('%s\naddpath(''%s'');\n',initFcn,protectedModelPath);
        set_param(genMdlName,'InitFcn',newInitFcn);

        closeFcn=get_param(genMdlName,'CloseFcn');
        newCloseFcn=sprintf('%s\naddpath(''%s'');\nrmpath(''%s'');\n',...
        closeFcn,protectedModelPath,protectedModelPath);
        set_param(genMdlName,'CloseFcn',newCloseFcn);

    end




    if~strcmp(get_param(genMdlName,'FixedStep'),'auto')&&...
        (pirInstance.getDutBaseRateScalingFactor>1)&&...
        ~this.getParameter('BuildToProtectModel')
        set_param(genMdlName,'FixedStep',num2str(pirInstance.ModelBaseRate,15));
    end
    save_system(genMdlName,fullGenMdlName,'OverwriteIfChangedOnDisk',true,...
    'SaveModelWorkspace',false);


    if this.DUTMdlRefHandle>0&&...
        this.mdlIdx==numel(this.AllModels)
        set_param(this.DUTMdlRefHandle,'LabelModeActiveChoice',this.gmVariantName);
    end
end



function isAbsPath=isAbsolutePath(aPath)
    if strcmp(filesep,aPath(1))
        isAbsPath=true;
    elseif ispc&&numel(aPath)>1&&isletter(aPath(1))&&strcmp(aPath(2),':')

        isAbsPath=true;
    else
        isAbsPath=false;
    end
end











function connectTestpoints(~,gmDUT,gmTop)

    if~testpointsPresent(gmTop)
        return;
    end

    posOfDut=get_param(gmDUT,'Position');


    tpScopeMap=containers.Map('KeyType','double','ValueType','double');

    totalTPPorts=0;
    for ii=1:numel(gmTop.PirOutputPorts)
        if(gmTop.PirOutputPorts(ii).isTestpoint())
            totalTPPorts=totalTPPorts+1;
        end
    end

    outFileName=fileparts(gmDUT);

    for ii=1:numel(gmTop.PirOutputPorts)
        if(gmTop.PirOutputPorts(ii).isTestpoint())

            portYDiff=(posOfDut(4)-posOfDut(2))/numel(gmTop.PirOutputPorts);
            portYLoc=(ii-1)*portYDiff+portYDiff/2;
            outPortLocation=[posOfDut(3),posOfDut(2)+portYLoc,posOfDut(3),posOfDut(2)+portYLoc];


            portType=getDutOutportType(gmTop,ii);
            if portType.isRecordType&&...
                get_param(gmTop.getOutputPortSignal(ii-1).SimulinkHandle,'CompiledBusType')=="VIRTUAL_BUS"
                posTerminator=outPortLocation+[60,0,90,30];
                terminatorH=addBlockUnique('simulink/Sinks/Terminator',[outFileName,'/tpTerminator']);
                new_terminator=getfullname(terminatorH);
                set_param(new_terminator,'Position',posTerminator);
                blkPort=[char(get_param(gmDUT,'Name')),'/',char(num2str(ii))];
                terminatorInput=[char(get_param(new_terminator,'Name')),'/1'];
                add_line(outFileName,blkPort,terminatorInput,'autorouting','on');
            else

                simRate=gmTop.PirOutputPorts(ii).Signal.SimulinkRate;


                [new_scope,portID,tpScopeMap]=getScopeFor(tpScopeMap,outFileName,simRate,outPortLocation);


                src_scope=[char(get_param(new_scope,'Name')),'/',char(num2str(portID))];
                blkPort=[char(get_param(gmDUT,'Name')),'/',char(num2str(ii))];
                add_line(outFileName,blkPort,src_scope,'autorouting','on');
            end
        end
    end

end


function[new_scope,portID,tpScopeMap]=getScopeFor(tpScopeMap,gmTop,simRate,refPortLoc)
    if isKey(tpScopeMap,simRate)
        new_scope=tpScopeMap(simRate);
        s=get_param(new_scope,'ScopeConfiguration');
        totalPortsScoped=str2double(s.NumInputPorts);
    else
        tpScopeName=[gmTop,'/TestpointScope'];
        new_scope=addBlockUnique('simulink/Sinks/Scope',tpScopeName);
        tpScopeMap(simRate)=new_scope;
        position=refPortLoc+[200,0,230,30];
        scope_name=getfullname(new_scope);
        set_param(scope_name,'Position',position);
        totalPortsScoped=0;
    end
    s=get_param(new_scope,'ScopeConfiguration');
    s.NumInputPorts=num2str(totalPortsScoped+1);
    portID=totalPortsScoped+1;
end


function blkH=addBlockUnique(blkType,tgtBlkPath)
    blkH=add_block(blkType,tgtBlkPath,'MakeNameUnique','on');
end


function outType=getDutOutportType(hn,idx)
    outType=[];
    hs=hn.getOutputPortSignal(idx-1);
    if~isempty(hs)
        outType=hs.Type;
    end
end


function retval=testpointsPresent(top)
    retval=false;
    for ii=1:numel(top.PirOutputPorts)
        if top.PirOutputPorts(ii).isTestpoint()
            retval=true;
            break;
        end
    end
end






function updateVssPortNames(vss,choiceModel)
    vssInputPortH=find_system(vss,'SearchDepth',1,'BlockType','Inport');
    inPorts=find_system(choiceModel,'SearchDepth',1,'BlockType','Inport');
    updateVssPortsWithBepPortNames(inPorts,vssInputPortH,'InBus');
    vssOutputPortH=find_system(vss,'SearchDepth',1,'BlockType','Outport');
    outPorts=find_system(choiceModel,'SearchDepth',1,'BlockType','Outport');
    updateVssPortsWithBepPortNames(outPorts,vssOutputPortH,'OutBus');
end

function updateVssPortsWithBepPortNames(refModelPorts,vssPortHandls,suffixName)
    vssPortNames=get_param(vssPortHandls,'Name');
    for idx=1:numel(refModelPorts)
        if strcmpi(get_param(refModelPorts{idx},'isbuselementport'),'on')
            portName=get_param(refModelPorts{idx},'PortName');
            suffixLen=length(suffixName);
            if strcmpi(portName(end-(suffixLen-1):end),suffixName)
                busPortName=portName(1:(end-suffixLen));
                for idx2=1:numel(vssPortNames)
                    if strcmp(vssPortNames{idx2},busPortName)

                        set_param(vssPortHandls{idx2},'Name',portName);

                        vssPortNames{idx2}='';
                    end
                end
            end
        end
    end


end











function addExtraPortsToVSS(vss,choiceModel)



    vssIports=get_param(find_system(vss,'SearchDepth',1,'BlockType','Inport'),'Name');

    vssOports=get_param(find_system(vss,'SearchDepth',1,'BlockType','Outport'),'Name');

    inPorts=find_system(choiceModel,'SearchDepth',1,'BlockType','Inport');
    chIports=cell(numel(inPorts),1);
    for idx=1:numel(inPorts)
        if strcmpi(get_param(inPorts{idx},'isbuselementport'),'on')
            chIports{idx}=get_param(inPorts{idx},'PortName');
        else
            chIports{idx}=get_param(inPorts{idx},'Name');
        end
    end
    chIports=unique(chIports);


    outPorts=find_system(choiceModel,'SearchDepth',1,'BlockType','Outport');
    chOports=cell(numel(outPorts),1);
    for idx=1:numel(outPorts)
        if strcmpi(get_param(outPorts{idx},'isbuselementport'),'on')
            chOports{idx}=get_param(outPorts{idx},'PortName');
        else
            chOports{idx}=get_param(outPorts{idx},'Name');
        end
    end
    chOports=unique(chOports);



    vssIports=strrep(vssIports,newline,' ');
    vssOports=strrep(vssOports,newline,' ');
    chIports=strrep(chIports,newline,' ');
    chOports=strrep(chOports,newline,' ');


    vssIports=strtrim(vssIports);
    vssOports=strtrim(vssOports);
    chIports=strtrim(chIports);
    chOports=strtrim(chOports);


    iPorts=setdiff(chIports,vssIports,'stable');

    for i=1:numel(iPorts)
        add_block([choiceModel,'/',iPorts{i}],[vss,'/',iPorts{i}]);
    end

    oPorts=setdiff(chOports,vssOports,'stable');

    for i=1:numel(oPorts)
        add_block([choiceModel,'/',oPorts{i}],[vss,'/',oPorts{i}]);
    end
end





function genDutPath=getDutName(dutPath,origName,newName)


    try
        splitPath=strsplit(dutPath,'/');
        splitPath{1}=newName;
        genDutPath=strjoin(splitPath,'/');
    catch

        genDutPath=strrep(dutPath,origName,newName);
    end
end



