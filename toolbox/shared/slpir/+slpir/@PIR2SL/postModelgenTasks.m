function postModelgenTasks(this,hPir,mpd)




    hiliters=initHiliteMap(this);

    if~havePostModelgenTasks(hiliters)
        return;
    end

    hiliters=setupFiles(this,hiliters,mpd.firstModel);



    nets=hPir.Networks;
    for i=1:length(nets)
        hN=nets(i);
        srcParentPath=hN.FullPath;
        hiliteNetwork(this,hiliters,srcParentPath,hN,mpd);
    end

    if mpd.genModel


        if this.genmodelgetparameter('StaticLatencyPathAnalysis')
            hiliteLatencyPathComp(this,hPir,mpd,hiliters('feedback').clearHighlightingFileid);
        end

        generateCPEHtmlReport(this,hiliters,mpd);
    end
    cleanupTasks(this,hiliters,mpd);

end




function hiliters=initHiliteMap(this)

    hiliters=containers.Map;


    hiliters('feedback')=struct(...
    'param','HighlightFeedbackLoops',...
    'active',this.genmodelgetparameter('HighlightFeedbackLoops'),...
    'fileparam','HighlightFeedbackLoopsFile',...
    'fid',0,...
    'msgid','',...
    'portfcn',[],...
    'compfcn',@hiliteFeedbackComp);

    hiliters('critpath')=struct(...
    'param','CriticalPathEstimation',...
    'active',this.genmodelgetparameter('CriticalPathEstimation'),...
    'fileparam','CriticalPathEstimationFile',...
    'fid',0,...
    'msgid','hdlcoder:hdldisp:GeneratingCPEHiliteScript',...
    'portfcn',[],...
    'compfcn',@hiliteCriticalPathComp,...
    'generatedmodelonly',true);

    hiliters('ncc')=struct(...
    'param','CriticalPathEstimation',...
    'active',this.genmodelgetparameter('CriticalPathEstimation')...
    |this.genmodelgetparameter('UseSynthesisEstimatesForDistributedPipelining'),...
    'fileparam','BlocksWithNoCharacterizationFile',...
    'fid',0,...
    'msgid','hdlcoder:hdldisp:GeneratingBlocksWithNoCharacterizationHighlightScript',...
    'portfcn',[],...
    'compfcn',@hiliteCompsWithNoCharacterization);

    hiliters('retimingcp')=struct(...
    'param','RetimingCP',...
    'active',this.genmodelgetparameter('RetimingCP'),...
    'fileparam','RetimingCPFile',...
    'fid',0,...
    'msgid','hdlcoder:hdldisp:GeneratingRetimingCPHiliteScript',...
    'portfcn',[],...
    'compfcn',@hiliteRetimingCP);

    hiliters('crp')=struct(...
    'param','HighlightClockRatePipeliningDiagnostic',...
    'active',this.genmodelgetparameter('HighlightClockRatePipeliningDiagnostic'),...
    'fileparam','HighlightClockRatePipeliningFile',...
    'fid',0,...
    'msgid','hdlcoder:hdldisp:GeneratingCRPHiliteScript',...
    'portfcn',@hiliteCRPPort,...
    'compfcn',@hiliteCRPComp);

    hiliters('dpb')=struct(...
    'param','DistributedPipeliningBarriers',...
    'active',this.genmodelgetparameter('DistributedPipeliningBarriers'),...
    'fileparam','DistributedPipeliningBarriersFile',...
    'fid',0,...
    'msgid','hdlcoder:hdldisp:GeneratingDistributedPipeliningBarriersHiliteScript',...
    'portfcn',[],...
    'compfcn',@hiliteDistributedPipeliningBarriers);


    if this.genmodelgetparameter('LUTMapToRAM')&&~isempty(this.genmodelgetparameter('SynthesisTool'))
        toolName=this.genmodelgetparameter('SynthesisTool');

        if(strncmpi(toolName,'xilinx',6)||strncmpi(toolName,'Altera',6)||...
            strncmpi(toolName,'Intel',5))
            hiliters('lutram')=struct(...
            'param','HighlightLUTPipeliningDiagnostic',...
            'active',this.genmodelgetparameter('HighlightLUTPipeliningDiagnostic'),...
            'fileparam','HighlightLUTPipeliningDiagnosticFile',...
            'fid',0,...
            'msgid','hdlcoder:hdldisp:GeneratingLUTPipeliningDiagnosticHiliteScript',...
            'portfcn',[],...
            'compfcn',@hiliteLUTPipelines);
        end
    end

    hiliters('sharinggroups')=struct(...
    'param','',...
    'active',0,...
    'fileparam','',...
    'fid',0,...
    'msgid','',...
    'portfcn',[],...
    'compfcn',@hiliteSharingGroups,...
    'netfcn',@setupSharingNetwork);

    hiliters('streaminggroups')=struct(...
    'param','',...
    'active',0,...
    'fileparam','',...
    'fid',0,...
    'msgid','',...
    'portfcn',[],...
    'compfcn',@hiliteStreamingGroups,...
    'netfcn',@setupStreamingNetwork);
end

function val=havePostModelgenTasks(hiliters)
    values=hiliters.values;

    val=false;
    for i=1:length(values)
        paraminfo=values{i};

        if paraminfo.active
            val=true;
            return;
        end

    end

end

function generateAnnotateHelperFunction()
    hDrv=hdlcurrentdriver;
    annotateFile=fullfile(hDrv.hdlGetBaseCodegendir(),'annotate_port.m');
    if exist(annotateFile,'file')
        return;
    end

    fid=fopen(annotateFile,'w');
    if fid>-1
        fprintf(fid,'function pass = annotate_port(blockName, isInport, portId, annoteString)\n\n');
        fprintf(fid,'pass = true ;\n');
        fprintf(fid,'try\n');
        fprintf(fid,'ph=get_param(blockName, ''PortHandles\'');\n');
        fprintf(fid,'if ( isInport )\n');
        fprintf(fid,'portHandle = get_param(ph.Inport(portId),''Object'');\n');
        fprintf(fid,'else\n');
        fprintf(fid,'portHandle = get_param(ph.Outport(portId),''Object'');\n');
        fprintf(fid,'end\n');
        fprintf(fid,'Simulink.AnnotationGateway.Annotate( portHandle, annoteString);\n');
        fprintf(fid,'catch\n');
        fprintf(fid,'pass = false;\n');
        fprintf(fid,'end\n');
        fprintf(fid,'end\n');
        fclose(fid);
    end
end

function hiliters=setupFiles(this,hiliters,firstModel)
    keys=hiliters.keys;

    outMdlFile=this.OutModelFile;
    inMdlFile=this.InModelFile;

    clearHighlightingFid=setupClearHighlightingFile(this,inMdlFile,outMdlFile,firstModel);

    for i=1:length(keys)
        sid=keys{i};
        paraminfo=hiliters(sid);

        bothModels=true;
        if(isfield(paraminfo,'generatedmodelonly')&&...
            paraminfo.generatedmodelonly==true)
            bothModels=false;
        end

        if paraminfo.active
            fname=getFileName(this,paraminfo.fileparam,true);
            fid=openFile(fname,inMdlFile,outMdlFile,firstModel,bothModels);
            paraminfo.fid=fid;
        end

        paraminfo.clearHighlightingFileid=clearHighlightingFid;
        hiliters(sid)=paraminfo;
    end
end

function fid=setupClearHighlightingFile(this,inMdlFile,outMdlFile,firstModel)
    fname=getClearHighlightingFileName(this);

    hDrv=hdlcurrentdriver;
    hDrv.hdlMakeCodegendir;

    clear(fname);

    mode='a+';

    if(firstModel)
        mode='w+';
    end

    fid=fopen(fname,mode);

    fprintf(fid,'SLStudio.Utils.RemoveHighlighting(get_param(''%s'', ''handle''));\n',inMdlFile);
    if~isempty(outMdlFile)
        fprintf(fid,'SLStudio.Utils.RemoveHighlighting(get_param(''%s'', ''handle''));\n',outMdlFile);
    end
end

function fname=getClearHighlightingFileName(this)
    fname=getFileName(this,'ClearHighlightingFile',true);
end

function cleanupTasks(this,hiliters,mpd)
    values=hiliters.values;
    clearHighlightingFid=0;
    showClearHiliteMsg=false;

    for i=1:length(values)
        paraminfo=values{i};

        if paraminfo.fid>0
            fclose(paraminfo.fid);
        end

        if(isfield(paraminfo,'clearHighlightingFileid')&&clearHighlightingFid==0)
            clearHighlightingFid=paraminfo.clearHighlightingFileid;
        end

        msg=showMessage(this,paraminfo,mpd);

        if~isempty(msg)&&~showClearHiliteMsg
            showClearHiliteMsg=true;
        end
    end

    outputClearHighlightingFile(this,clearHighlightingFid,mpd,showClearHiliteMsg);

end

function outputClearHighlightingFile(this,fid,mpd,showClearHiliteMsg)
    if(fid>0)
        fclose(fid);
    end

    filename=getClearHighlightingFileName(this);

    if(isempty(mpd.highlightMessages))
        if exist(filename,'file')
            try
                delete(filename);
            catch
            end
        end
    end
    if(showClearHiliteMsg)
        msgObj=message('hdlcoder:hdldisp:ClearHighlightingScript');
        if(this.HyperlinksInLog)
            linkstr=sprintf('<a href="matlab:run(''%s'')">%s</a>',filename,filename);
            msg=[msgObj.getString(),' ',linkstr];
        else
            msg=[msgObj.getString(),' ',filename];
        end
        this.genmodeldisp(msg);
    end

end

function fid=openFile(filename,inMdlFile,outMdlFile,firstModel,bothModels)

    if isempty(outMdlFile)&&~bothModels


        fid=-1;
        return
    end

    hDrv=hdlcurrentdriver;
    hDrv.hdlMakeCodegendir;

    clear(filename);
    mode='a+';

    if(firstModel)
        mode='w+';
    end

    fid=fopen(filename,mode);
    if fid>0
        if bothModels
            fprintf(fid,'open_system(''%s'');\n',inMdlFile);
        end
        if~isempty(outMdlFile)
            fprintf(fid,'open_system(''%s'');\n',outMdlFile);
        end
    end
end

function fullname=getFileName(this,fileparam,addExtension,baseCodegenDir)
    if nargin<4
        baseCodegenDir=true;
    end

    if nargin<3
        addExtension=false;
    end

    filename=this.genmodelgetparameter(fileparam);
    hDrv=hdlcurrentdriver;

    if(baseCodegenDir)
        fullname=fullfile(hDrv.hdlGetBaseCodegendir(),filename);
    else
        fullname=fullfile(hDrv.hdlGetCodegendir(),filename);
    end

    if addExtension
        fullname=sprintf('%s.m',fullname);
    end
end



function hiliteNetwork(this,hiliters,srcParentPath,hN,mpd)

    tgtParentPath=getTargetModelPath(this,srcParentPath);

    hIns=hN.PirInputPorts;
    hOuts=hN.PirOutputPorts;

    hiliters=runNetworkFcn(this,hiliters,hN,mpd,true);

    this.genmodeldisp(sprintf('Highlighting input ports...'),3);
    hilitePorts(hiliters,hIns,srcParentPath,tgtParentPath,false);

    this.genmodeldisp(sprintf('Highlighting output ports...'),3);
    hilitePorts(hiliters,hOuts,srcParentPath,tgtParentPath,true);

    this.genmodeldisp(sprintf('Highlighting components...'),3);
    hiliteComps(hiliters,srcParentPath,tgtParentPath,hN,mpd);

    runNetworkFcn(this,hiliters,hN,mpd,false);
end


function hiliteComps(hiliters,srcParentPath,tgtParentPath,hN,mpd)

    vComps=hN.Components;
    numComps=length(vComps);

    for i=1:numComps
        hC=vComps(i);
        hiliteCompInModels(hiliters,srcParentPath,tgtParentPath,hC,mpd);
        mpd.firstComp=false;
    end

end


function hiliters=runNetworkFcn(this,hiliters,hN,mpd,isbegin)
    keys=hiliters.keys();
    for i=1:length(keys)
        sid=keys{i};
        paraminfo=hiliters(sid);
        if(isfield(paraminfo,'netfcn'))
            netfcn=paraminfo.netfcn;
            if~isempty(netfcn)
                paraminfo=netfcn(this,paraminfo,hN,mpd,sid,isbegin);
                if~isempty(paraminfo)
                    hiliters(sid)=paraminfo;
                end
            end
        end
    end
end


function fid=openHighlightFile(this,hN,str)
    hDrv=hdlcurrentdriver;
    baseCodeGenDir=hDrv.hdlGetBaseCodegendir();
    filename=[str,hN.getCtxName,hN.RefNum(2:end),'.m'];
    filename=strrep(filename,' ','_');
    fullname=fullfile(baseCodeGenDir,filename);
    fid=fopen(fullname,'w+');
    if~isempty(this.OutModelFile)
        fprintf(fid,'open_system(''%s'');\n',this.OutModelFile);
    end
    fprintf(fid,'open_system(''%s'');\n',this.InModelFile);
    fprintf(fid,'%s;\n',this.genmodelgetparameter('ClearHighlightingFile'));
end


function hiliteCompInModels(hiliters,srcParentPath,tgtParentPath,hC,mpd)

    keys=hiliters.keys();
    for i=1:length(keys)
        highlighted=false;
        paraminfo=hiliters(keys{i});
        fcn=paraminfo.compfcn;
        if~isempty(fcn)&&paraminfo.active
            highlighted=fcn(paraminfo,srcParentPath,tgtParentPath,hC,mpd);
        end
        if(highlighted&&(~isfield(paraminfo,'hasUsefulInfo')||~paraminfo.hasUsefulInfo))
            paraminfo.hasUsefulInfo=true;
            hiliters(keys{i})=paraminfo;
        end
    end

end


function hilitePorts(hiliters,ports,srcParentPath,tgtParentPath,useInput)
    for i=1:length(ports)
        hP=ports(i);
        hilitePortInModels(hiliters,srcParentPath,tgtParentPath,hP,useInput);
    end
end


function hilitePortInModels(hiliters,srcParentPath,tgtParentPath,hP,useInput)

    values=hiliters.values;

    for i=1:length(values)
        paraminfo=values{i};
        fcn=paraminfo.portfcn;
        if~isempty(fcn)&&paraminfo.active
            fcn(paraminfo,srcParentPath,tgtParentPath,hP,useInput);
        end
    end

end


function highlighted=hiliteFeedbackComp(paraminfo,srcParentPath,tgtParentPath,hC,~)

    highlighted=false;
    id=hC.getFeedbackColorId;

    if id<0
        return;
    end

    fid=paraminfo.fid;
    if fid<=0
        return;
    end

    hiliteId=getHiliteScheme(fid,id);

    hGMBlock=hC.getGMHandle;
    hiliteComp(hC,fid,tgtParentPath,hiliteId,hGMBlock,paraminfo.clearHighlightingFileid);

    hOrigBlock=hC.OrigModelHandle;
    hiliteComp(hC,fid,srcParentPath,hiliteId,hOrigBlock,paraminfo.clearHighlightingFileid);
    highlighted=true;
end


function highlighted=hiliteCRPComp(paraminfo,srcParentPath,tgtParentPath,hC,~)
    highlighted=false;
    id=hC.getCRPId;

    if id<0
        return;
    end

    fid=paraminfo.fid;
    if fid<=0
        return;
    end

    desc=hC.getCRPDescription;
    useInput=true;
    if~isempty(desc)&&hC.NumberOfPirInputPorts<=0
        if hC.NumberOfPirOutputPorts>0
            useInput=false;
        else
            desc=[];
        end
    end

    hiliteId=getHiliteScheme(fid,id);

    hGMBlock=hC.getGMHandle;
    hiliteComp(hC,fid,tgtParentPath,hiliteId,hGMBlock,paraminfo.clearHighlightingFileid,message(desc).getString,useInput);

    hOrigBlock=hC.OrigModelHandle;
    hiliteComp(hC,fid,srcParentPath,hiliteId,hOrigBlock,paraminfo.clearHighlightingFileid,message(desc).getString,useInput);
    highlighted=true;
end


function hiliteCRPPort(paraminfo,srcParentPath,tgtParentPath,hP,useInput)

    id=hP.getCRPId;

    if id<0
        return;
    end

    fid=paraminfo.fid;
    if fid<=0
        return;
    end

    desc=hP.getCRPDescription;

    hiliteId=getHiliteScheme(fid,id);

    hGMBlock=hP.getGMHandle;
    hiliteComp(hP,fid,tgtParentPath,hiliteId,hGMBlock,paraminfo.clearHighlightingFileid,message(desc).getString,useInput);

    hiliteComp(hP,fid,srcParentPath,hiliteId,[],paraminfo.clearHighlightingFileid,message(desc).getString,useInput);

end



function cpeDelaysMap=collectReportInfo(cpeDelaysMap,blockName,isInport,portNum,delay,phC,index)
    try
        uniqueId=phC.getCriticalPathId(index);
    catch
        return;
    end
    pathDetails=struct('blockPath',blockName,...
    'port',portNum,...
    'inport',isInport,...
    'propagationDelay',delay);

    cpeDelaysMap(uniqueId)=pathDetails;
end


function generateCPEHtmlReport(this,hiliters,mpd)

    if(~hdlgetparameter('CriticalPathEstimation')||...
        ~mpd.lastModel)
        return;
    end


    offendingBlocksFileName={};
    if(hiliters.isKey('ncc'))
        paraminfo=hiliters('ncc');
        if isfield(paraminfo,'hasUsefulInfo')&&...
            paraminfo.hasUsefulInfo
            offendingBlocksFileName=getFileName(this,'BlocksWithNoCharacterizationFile');
        end
    end

    cpeDelaysMap=mpd.cpeTable;
    hDriver=hdlcurrentdriver;
    topModelName=hDriver.getStartNodeName;
    cpeReportFile=fullfile(hDriver.hdlGetBaseCodegendir(),'criticalpathestimationsummary.html');
    cpehighlightscript=getFileName(this,'CriticalPathEstimationFile');
    qoroptimizations.printCPESummary(topModelName,cpeDelaysMap,cpeReportFile,cpehighlightscript,offendingBlocksFileName);


end


function highlighted=hiliteCriticalPathComp(paraminfo,~,tgtParentPath,phC,mpd)
    highlighted=false;
    hC=phC;
    hGMBlock=hC.getGMHandle;

    fid=paraminfo.fid;
    if fid<=0
        return;
    end

    if~isempty(hC)&&hC.getOnCriticalPath
        blockName=getBlockNameFromHandle(hC,tgtParentPath,hGMBlock);

        if isempty(blockName)
            return
        end

        if(hC.getCriticalPathBegin||hC.getCriticalPathEnd)
            hiliteId=getHiliteSchemeWithColor(fid,'blue',1);
        else
            hiliteId=getHiliteSchemeWithColor(fid,'lightblue',2);
        end

        hiliteComp(hC,fid,tgtParentPath,hiliteId,hGMBlock,paraminfo.clearHighlightingFileid);

        numOfDelays=hC.getNumberOfCriticalPathDelays();

        for index=0:numOfDelays-1
            portNum=hC.getCriticalPathPort(index);
            delay=num2str(hC.getCriticalPathDelay(index));
            isInport=hC.getCriticalPathPortType(index);
            if portNum==-1
                portNum=0;
            end
            annotatePort(fid,blockName,isInport,portNum+1,['cp : ',delay,' ns'],paraminfo.clearHighlightingFileid);
            collectReportInfo(mpd.cpeTable,blockName,isInport,portNum,delay,hC,index);
        end
        highlighted=true;
    end
end







function generateGMMapMatFile(this,hPir)


    load_system(this.OutModelFile);


    ntwks=hPir.Networks;


    fname=[getFileName(this,'SLPAGMMapMATFile',false,false),'_',this.OutModelFile,'.mat'];




    needToLoadFromMAT=true;


    res=cell(size(ntwks));


    for ntwkIdx=1:length(ntwks)


        localNtwk=ntwks(ntwkIdx);


        gmHandles=struct('comp',{cell(size(localNtwk.Components))},'inport',{cell(size(localNtwk.PirInputPorts))},'outport',{cell(size(localNtwk.PirOutputPorts))});


        for compIdx=1:length(localNtwk.Components)
            currComp=localNtwk.Components(compIdx);


            if(currComp.getGMHandle~=-1)



                needToLoadFromMAT=false;


                gmHandles.comp{compIdx}=[get_param(currComp.getGMHandle,'Parent'),'/',get_param(currComp.getGMHandle,'Name')];
            end
        end


        for inportIdx=1:length(localNtwk.PirInputPorts)
            currInport=localNtwk.PirInputPorts(inportIdx);


            if(currInport.getGMHandle~=-1)



                needToLoadFromMAT=false;


                gmHandles.inport{inportIdx}=[get_param(currInport.getGMHandle,'Parent'),'/',get_param(currInport.getGMHandle,'Name')];
            end
        end


        for outportIdx=1:length(localNtwk.PirOutputPorts)
            currOutport=localNtwk.PirOutputPorts(outportIdx);


            if(currOutport.getGMHandle~=-1)



                needToLoadFromMAT=false;


                gmHandles.outport{outportIdx}=[get_param(currOutport.getGMHandle,'Parent'),'/',get_param(currOutport.getGMHandle,'Name')];
            end
        end


        res{ntwkIdx}=gmHandles;
    end


    if needToLoadFromMAT&&exist(fname,'file')

        load(fname,'res');



        if(length(res)~=length(ntwks))
            return
        end


        for ntwkIdx=1:length(ntwks)



            if(length(res{ntwkIdx}.comp)~=length(hPir.Networks(ntwkIdx).Components))||...
                (length(res{ntwkIdx}.inport)~=length(hPir.Networks(ntwkIdx).PirInputPorts))||...
                (length(res{ntwkIdx}.outport)~=length(hPir.Networks(ntwkIdx).PirOutputPorts))
                return
            end


            for compIdx=1:length(hPir.Networks(ntwkIdx).Components)



                if~isempty(res{ntwkIdx}.comp{compIdx})
                    hPir.Networks(ntwkIdx).Components(compIdx).setGMHandle(get_param(res{ntwkIdx}.comp{compIdx},'Handle'));
                end
            end


            for inportIdx=1:length(hPir.Networks(ntwkIdx).PirInputPorts)



                if~isempty(res{ntwkIdx}.inport{inportIdx})
                    hPir.Networks(ntwkIdx).PirInputPorts(inportIdx).setGMHandle(get_param(res{ntwkIdx}.inport{inportIdx},'Handle'));
                end
            end


            for outportIdx=1:length(hPir.Networks(ntwkIdx).PirOutputPorts)



                if~isempty(res{ntwkIdx}.outport{outportIdx})
                    hPir.Networks(ntwkIdx).PirOutputPorts(outportIdx).setGMHandle(get_param(res{ntwkIdx}.outport{outportIdx},'Handle'));
                end
            end
        end
    else
        save(fname,'res');
    end
end


function hiliteLatencyPathComp(this,hPir,mpd,clearHighlightingFileid)

    mpd.highlightMessages('latAnalysis')=1;

    generateGMMapMatFile(this,hPir);


    hDriver=hdlcurrentdriver;

    topLevelModel=strcmp(hDriver.hdlGetCodegendir(),hDriver.hdlGetBaseCodegendir());


    if~topLevelModel
        return
    end


    res=hPir.doStaticLatencyAnalysis();


    clearfilename=getClearHighlightingFileName(this);
    [~,clearfilename,clearfileext]=fileparts(clearfilename);


    tempRes=res{1};

    newRes=struct([]);

    if~isempty(tempRes)
        newRes(1).fname=getFileName(this,'SLPAFile',false,false);
        fid=openFile([newRes(1).fname,'.m'],[],this.OutModelFile,true,false);


        if topLevelModel
            fprintf(fid,'run(''%s'');\n',[clearfilename,clearfileext]);
        end

        hiliteId=getHiliteSchemeWithColor(fid,'green',1);

        comps=tempRes(1).Path;





        latency=round(tempRes(1).LongestLatency);

        tRes=writeCompDetailsToFile(fid,comps,hiliteId,1,clearHighlightingFileid,latency);

        newRes(1).firstComp=tRes.firstComp;
        newRes(1).lastComp=tRes.lastComp;
        newRes(1).Latency=tRes.Latency;

        fclose(fid);
    end

    res{1}=newRes;



    tempRes=res{2};

    if~isempty(tempRes)

        backEdgeFileName=getFileName(this,'SLPABackEdgeFile',true,false);
        [~,tempRes(1).backEdgeFileName,~]=fileparts(backEdgeFileName);


        generateBackEdgeHighlightFunction(tempRes(1).backEdgeFileName,backEdgeFileName);
    end

    for idx=1:length(tempRes)

        tempRes(idx).fname=[getFileName(this,'SLPALoopsFile',false,false),num2str(idx)];

        fid=openFile([tempRes(idx).fname,'.m'],[],this.OutModelFile,true,false);


        if topLevelModel
            fprintf(fid,'run(''%s'');\n',[clearfilename,clearfileext]);
        end

        hiliteId=getHiliteSchemeWithColor(fid,'yellow',idx);

        comps=tempRes(idx).Components;

        writeCompDetailsToFile(fid,comps,hiliteId,0);

        for bidx=1:length(tempRes(idx).BackEdges)
            tempRes(idx).BackEdges{bidx}{1}=getCompPathFromStack(tempRes(idx).BackEdges{bidx}{1});
            tempRes(idx).BackEdges{bidx}{2}=getCompPathFromStack(tempRes(idx).BackEdges{bidx}{2});
        end

        fclose(fid);
    end

    res{2}=tempRes;


    tempRes=res{3};

    for idx=1:length(tempRes)
        tempRes{idx}=getCompPathFromStack(tempRes{idx});
    end

    res{3}=tempRes;

    res{end+1}=getClearHighlightingFileName(this);



    topModelName=hDriver.getStartNodeName;
    staticLatReportFile=fullfile(hDriver.hdlGetCodegendir(),'staticlatencypathanalysissummary.html');

    qoroptimizations.printStaticLatencyPathSummary(topModelName,staticLatReportFile,res,this.OutModelFile,topLevelModel,hDriver.hdlGetCodegendir());



    if topLevelModel
        if this.HyperlinksInLog
            linkstr=sprintf('<a href="matlab:uiopen(''%s'',1)">%s</a>',staticLatReportFile,staticLatReportFile);
            hdldisp(message('hdlcoder:hdldisp:GeneratingStaticLatencyPathHiliteScript',linkstr));
        else
            hdldisp(message('hdlcoder:hdldisp:GeneratingStaticLatencyPathHiliteScript',staticLatReportFile));
        end
    end
end

function generateBackEdgeHighlightFunction(backEdgeFunctionName,backEdgeFileName)

    if exist(backEdgeFileName,'file')
        return;
    end

    fid=fopen(backEdgeFileName,'w');
    if fid>1
        fprintf(fid,'function %s(src, dest)\n\n',backEdgeFunctionName);
        fprintf(fid,'if isempty(src) || isempty(dest)\n');
        fprintf(fid,'\treturn;\n');
        fprintf(fid,'end\n');
        fprintf(fid,'try\n');
        fprintf(fid,'destParent = split(dest,''/'');\n');
        fprintf(fid,'destParent = join(destParent(1:end-1), ''/'');\n');
        fprintf(fid,'destParent = destParent{1};\n');
        fprintf(fid,'outSigs = get_param(src,''LineHandles'');\n');
        fprintf(fid,'outSigs = outSigs.Outport;\n');
        fprintf(fid,'if isempty(outSigs)\n');
        fprintf(fid,'\tsrcParent = split(src,''/'');\n');
        fprintf(fid,'\tsrcParent = join(srcParent(1:end-1), ''/'');\n');
        fprintf(fid,'\tsrcParent = srcParent{1};\n');
        fprintf(fid,'\toutSigs = get_param(srcParent,''LineHandles'');\n');
        fprintf(fid,'\toutSigs = outSigs.Outport;\n');
        fprintf(fid,'\toutPorts = get_param(outSigs,''SrcPortHandle'');\n');
        fprintf(fid,'\tif iscell(outPorts)\n');
        fprintf(fid,'\t\toutPorts = num2str(cellfun(@(a) get_param(a,''PortNumber''), outPorts)'');\n');
        fprintf(fid,'\t\toutPorts = split(outPorts);\n');
        fprintf(fid,'\telse\n');
        fprintf(fid,'\t\toutPorts = num2str(get_param(outPorts,''PortNumber''));\n');
        fprintf(fid,'\tend\n');
        fprintf(fid,'\toutPortIdx = strcmp(get_param(src,''Port''),outPorts);\n');
        fprintf(fid,'\toutSigs = outSigs(outPortIdx);\n');
        fprintf(fid,'end\n');
        fprintf(fid,'for outSigIdx = 1:length(outSigs)\n');
        fprintf(fid,'\tdestBlkH = get_param(outSigs(outSigIdx),''DstBlockHandle'');\n');
        fprintf(fid,'\tfor destBlkIdx = 1:length(destBlkH)\n');
        fprintf(fid,'\t\tif strcmp(dest, strrep([get_param(destBlkH(destBlkIdx),''Parent'') ''/'' get_param(destBlkH(destBlkIdx),''Name'')], newline, '' ''))...\n');
        fprintf(fid,'\t\t|| strcmp(destParent, strrep([get_param(destBlkH(destBlkIdx),''Parent'') ''/'' get_param(destBlkH(destBlkIdx),''Name'')], newline, '' ''))\n');
        fprintf(fid,'\t\t\thilite_system(outSigs(outSigIdx));\n');
        fprintf(fid,'\t\t\treturn;\n');
        fprintf(fid,'\t\tend\n');
        fprintf(fid,'\tend\n');
        fprintf(fid,'end\n');
        fprintf(fid,'catch\n');
        fprintf(fid,'end\n');
        fprintf(fid,'end\n');
    end

    fclose(fid);
end

function[compPath,modelRef,modelrefStack]=getCompPathFromStack(compStack)

    modelRef=false;
    modelrefStack=cell(0);
    blockPath='';


    compStack=compStack(compStack~=-1);

    if isempty(compStack)
        skipComp=true;
    else
        skipComp=false;

        for stackIdx=length(compStack):-1:1

            if compStack(stackIdx)==-1
                skipComp=true;
                break;
            end

            if isempty(blockPath)
                blockPath=[get_param(compStack(stackIdx),'Parent'),'/',get_param(compStack(stackIdx),'Name')];
            else
                blockPath=[blockPath,'/',get_param(compStack(stackIdx),'Name')];%#ok<AGROW> 
            end

            if strcmp(get_param(blockPath,'BlockType'),'ModelReference')

                modelrefStack{end+1}=strrep(blockPath,newline,' ');%#ok<AGROW> 
                modelRef=true;
                blockPath='';
            end
        end
    end


    if skipComp
        compPath='';
    else
        compPath=blockPath;
    end

    compPath=strrep(compPath,newline,' ');
end

function res=writeCompDetailsToFile(fid,compsIn,hiliteId,annotateWeightFlag,clearHighlightingFileid,latency)

    comps=cell(length(compsIn),1);
    modelRef=cell(length(compsIn),1);
    modelrefStack=cell(length(compsIn),1);


    if~isempty(compsIn)


        for compIdx=1:length(compsIn)
            [comps{compIdx},modelRef{compIdx},tempStack]=getCompPathFromStack(compsIn{compIdx});




            if compIdx>1&&modelRef{compIdx-1}&&modelRef{compIdx}

                tempStackPrev=modelrefStack{compIdx-1};
                toRemove=0;


                for modelRefStackIdx=1:min(length(tempStackPrev),length(tempStack))
                    if strcmp(tempStackPrev{modelRefStackIdx},tempStack{modelRefStackIdx})
                        toRemove=toRemove+1;
                    else
                        break;
                    end
                end

                tempStack(1:toRemove)=[];
            end

            modelrefStack{compIdx}=tempStack;
        end

        res.firstComp=comps{1};
        res.lastComp=comps{end};

        if annotateWeightFlag
            res.Latency=latency(end);
        end

        [comps,~,compPosition]=unique(comps);

        for compIdx=1:length(comps)

            compName=comps{compIdx};

            if strcmp(compName,'')
                continue;
            end

            fprintf(fid,'hilite_system(''%s'', ''%s'');\n',compName,hiliteId);

            if annotateWeightFlag

                latIndex=(compPosition==compIdx);

                if strcmp(get_param(compName,'BlockType'),'ModelReference')
                    latIndexShifted=[latIndex(2:end);0];
                    latIndexShifted=latIndexShifted&latIndex;

                    latIndex=xor(latIndex,latIndexShifted);
                end

                compWeight=latency(latIndex);

                compWeightStr=num2str(abs(compWeight),'%d,');
                compWeightStr(end)=[];

                portIdx=1;

                if strcmpi(get_param(compName,'BlockType'),'Outport')
                    portIdx=str2double(get_param(compName,'Port'));
                    compName=get_param(compName,'Parent');
                    compName=strrep(compName,newline,' ');

                    fprintf(fid,'hilite_system(''%s'', ''%s'');\n',compName,hiliteId);
                end

                annotatePort(fid,compName,false,portIdx,compWeightStr,clearHighlightingFileid);
            end
        end


        modelrefStack(isempty(modelrefStack))=[];

        for modelRefStackIdx=1:length(modelrefStack)

            tempStack=modelrefStack{modelRefStackIdx};

            for stackIdx=1:length(tempStack)

                if strcmp(tempStack{stackIdx},'')
                    continue;
                end

                fprintf(fid,'hilite_system(''%s'', ''%s'');\n',tempStack{stackIdx},hiliteId);
            end
        end
    end
end


function highlighted=hiliteRetimingCP(paraminfo,srcParentPath,tgtParentPath,hC,~)

    highlighted=false;
    idPre=hC.getRetimingCPIdxPre;
    accumLatencyPre=hC.getRetimingCPAccumLatencyPre;
    isStartPre=hC.getRetimingCPIsStartPre;
    isEndPre=hC.getRetimingCPIsEndPre;
    idPost=hC.getRetimingCPIdxPost;
    accumLatencyPost=hC.getRetimingCPAccumLatencyPost;
    isStartPost=hC.getRetimingCPIsStartPost;
    isEndPost=hC.getRetimingCPIsEndPost;

    if idPre<=0&&idPost<=0
        return;
    end

    fid=paraminfo.fid;
    if fid<=0
        return;
    end
    highlighted=true;

    if idPost>0
        hiliteId=getHiliteScheme(fid,idPost);
        hGMBlock=hC.getGMHandle;
        hiliteComp(hC,fid,tgtParentPath,hiliteId,hGMBlock,paraminfo.clearHighlightingFileid,sprintf('Idx:%d, AccumL:%.1f isStart: %d isEnd: %d',idPost,accumLatencyPost,isStartPost,isEndPost));
    end

    if idPre>0
        hiliteId=getHiliteScheme(fid,idPre);
        hOrigBlock=hC.OrigModelHandle;
        hiliteComp(hC,fid,srcParentPath,hiliteId,hOrigBlock,paraminfo.clearHighlightingFileid,sprintf('Idx:%d AccumL:%.1f isStart: %d isEnd: %d',idPre,accumLatencyPre,isStartPre,isEndPre));
    end
end


function highlighted=hiliteDistributedPipeliningBarriers(paraminfo,srcParentPath,tgtParentPath,hC,~)
    highlighted=false;
    hilite=hC.getRetimingBarriers;

    if hilite==false
        return;
    end

    id=0;
    fid=paraminfo.fid;
    if fid<=0
        return;
    end

    desc=hC.getRetimingBarriersRationale;
    hiliteId=getHiliteScheme(fid,id);

    hGMBlock=hC.getGMHandle;
    hiliteComp(hC,fid,tgtParentPath,hiliteId,hGMBlock,paraminfo.clearHighlightingFileid,message(desc).getString);

    hOrigBlock=hC.OrigModelHandle;
    hiliteComp(hC,fid,srcParentPath,hiliteId,hOrigBlock,paraminfo.clearHighlightingFileid,message(desc).getString);
    highlighted=true;
end

function highlighted=hiliteLUTPipelines(paraminfo,srcParentPath,tgtParentPath,hC,~)
    highlighted=false;
    origHandle=hC.OrigModelHandle;

    if(origHandle<=0||hC.isBlackBox)
        return;
    end


    if~ismethod(hC,'getBlockName')||~contains(hC.getBlockName,'Lookup')...
        ||~ismethod(hC,'getMapToRAM')
        return;
    end


    if(hC.getAdaptivePipelinesInserted()<=0)
        hilite=false;


        if strcmpi(class(hC),'hdlcoder.lookuptable_comp')&&hC.getInterpVal()>0
            return;
        end


        outsignal=hC.PirOutputSignals;
        if(numel(outsignal)==1)
            receivers=outsignal.getReceivers;
            for ii=1:length(receivers)
                if~(ismethod(receivers(ii).Owner,'isDelay')&&...
                    ismethod(receivers(ii).Owner,'isBlackBox'))

                    hilite=false;
                    break;
                elseif(receivers(ii).Owner.isBlackBox)
                    continue;
                elseif(receivers(ii).Owner.isDelay)
                    hilite=receivers(ii).Owner.getResetNone;
                else

                    hilite=false;
                    break;
                end
            end
        end
    else
        hilite=true;
    end

    if hilite==false
        return;
    end

    id=0;
    fid=paraminfo.fid;
    if fid<=0
        return;
    end

    desc='hdlcoder:optimization:lutpipeline';
    hiliteId=getHiliteScheme(fid,id);

    hGMBlock=hC.getGMHandle;
    hiliteComp(hC,fid,tgtParentPath,hiliteId,hGMBlock,paraminfo.clearHighlightingFileid,message(desc).getString);

    hOrigBlock=hC.OrigModelHandle;
    hiliteComp(hC,fid,srcParentPath,hiliteId,hOrigBlock,paraminfo.clearHighlightingFileid,message(desc).getString);
    highlighted=true;
end


function highlighted=hiliteCompsWithNoCharacterization(paraminfo,srcParentPath,tgtParentPath,hC,~)

    hilite=hC.getNotACharacterizedBlock();
    highlighted=hilite;

    if hilite==false
        return;
    else

        p=pir;
        p.setContainsCriticalPathOffendingBlocks(true);
    end

    id=1;
    fid=paraminfo.fid;
    if fid<=0
        return;
    end

    desc=hC.getCPEDescription;


    useInput=true;


    if~isempty(desc)&&hC.NumberOfPirInputPorts<=0


        if hC.NumberOfPirOutputPorts>0
            useInput=false;
        else


            desc=[];
        end
    end


    hiliteMessage=[];
    if~isempty(desc)
        hiliteMessage=message(desc).getString;
    end

    hiliteId=getHiliteScheme(fid,id);

    hGMBlock=hC.getGMHandle;
    hiliteComp(hC,fid,tgtParentPath,hiliteId,hGMBlock,paraminfo.clearHighlightingFileid,hiliteMessage,useInput);

    hOrigBlock=hC.OrigModelHandle;
    hiliteComp(hC,fid,srcParentPath,hiliteId,hOrigBlock,paraminfo.clearHighlightingFileid,hiliteMessage,useInput);

end


function highlighted=hiliteSharingGroups(paraminfo,srcParentPath,tgtParentPath,hC,mpd)
    highlighted=false;

    if paraminfo.fid<=0
        return;
    end

    id=hC.getSharingGroupId;
    desc=hC.getSharingDiagnosticMessage;
    if(~isempty(desc))
        hiliteId=getHiliteScheme(paraminfo.fid,0);
        hGMBlock=hC.getGMHandle;
        hiliteComp(hC,paraminfo.fid,tgtParentPath,hiliteId,hGMBlock,paraminfo.clearHighlightingFileid,desc);
        hOrigBlock=hC.OrigModelHandle;
        hiliteComp(hC,paraminfo.fid,srcParentPath,hiliteId,hOrigBlock,paraminfo.clearHighlightingFileid,desc);
    end

    if id<0
        return;
    end

    if(hC.isNetworkInstance&&~hC.ReferenceNetwork.isShared)
        hN=hC.ReferenceNetwork;
        vComps=hN.Components;
        numComps=length(vComps);
        for i=1:numComps
            hComp=vComps(i);
            hiliteSharingGroups(paraminfo,srcParentPath,tgtParentPath,hComp,mpd);
        end
    else
        hiliteId=getHiliteSchemeStreamingSharing(paraminfo.fid,id);
        desc=['Sharing Group ',num2str(id+1)];
        hGMBlock=hC.getGMHandle;
        hiliteComp(hC,paraminfo.fid,tgtParentPath,hiliteId,hGMBlock,paraminfo.clearHighlightingFileid,desc);

        group1=hC.getStreamingOrigCompsHandles;
        group2=hC.getSharingOrigCompsHandles;
        hiliteOrigCompsByGroup({group1,group2},hC,paraminfo,srcParentPath,hiliteId,desc);
    end

    highlighted=true;
end


function highlighted=hiliteStreamingGroups(paraminfo,srcParentPath,tgtParentPath,hC,mpd)
    highlighted=false;

    if paraminfo.fid<=0
        return;
    end

    id=hC.getStreamingGroupId;
    desc=hC.getStreamingDiagnosticMessage;

    if(~isempty(desc))
        hiliteId=getHiliteScheme(paraminfo.fid,0);
        hGMBlock=hC.getGMHandle;
        hiliteComp(hC,paraminfo.fid,tgtParentPath,hiliteId,hGMBlock,paraminfo.clearHighlightingFileid,desc);
        hOrigBlock=hC.OrigModelHandle;
        hiliteComp(hC,paraminfo.fid,srcParentPath,hiliteId,hOrigBlock,paraminfo.clearHighlightingFileid,desc);
    end

    if id<0
        return;
    end

    if(hC.isNetworkInstance)
        hN=hC.ReferenceNetwork;
        vComps=hN.Components;
        numComps=length(vComps);
        for i=1:numComps
            hComp=vComps(i);
            hiliteStreamingGroups(paraminfo,srcParentPath,tgtParentPath,hComp,mpd);
        end
    end

    hiliteId=getHiliteSchemeStreamingSharing(paraminfo.fid,id);

    desc=['Streaming Group ',num2str(id+1)];
    hGMBlock=hC.getGMHandle;
    hiliteComp(hC,paraminfo.fid,tgtParentPath,hiliteId,hGMBlock,paraminfo.clearHighlightingFileid,desc);

    group1=hC.getStreamingOrigCompsHandles;
    group2=hC.getSharingOrigCompsHandles;
    hiliteOrigCompsByGroup({group1,group2},hC,paraminfo,srcParentPath,hiliteId,desc);

    highlighted=true;
end


function hiliteOrigCompsByGroup(groups,hC,paraminfo,srcParentPath,hiliteId,desc)

    hHilite=[];
    for i=1:length(groups)
        hOrigBlocks=str2double(strsplit(groups{i},'|'));
        for j=1:length(hOrigBlocks)
            if hOrigBlocks(j)>0
                hHilite=[hHilite,hOrigBlocks(j)];%#ok<AGROW> 
            end
        end
    end

    hHilite=unique(hHilite,'stable');
    for i=1:length(hHilite)
        hiliteComp(hC,paraminfo.fid,srcParentPath,hiliteId,hHilite(i),paraminfo.clearHighlightingFileid,desc);
    end
end


function paraminfo=setupSharingNetwork(this,paraminfo,hN,mpd,sid,isbegin)
    if(hN.getSharingFactor<=0)
        paraminfo=[];
        return;
    end

    if(isbegin)
        paraminfo.active=true;
        paraminfo.fid=openHighlightFile(this,hN,'highlightSharing');
        mpd.highlightMessages(sid)=1;
    else
        if(paraminfo.fid>0)
            highlightCulprit(this,paraminfo,hN.getSharingCulprit,hN.sharingStatusMsg,paraminfo.fid);
            fclose(paraminfo.fid);
            paraminfo.fid=0;
        end
    end
end


function paraminfo=setupStreamingNetwork(this,paraminfo,hN,mpd,sid,isbegin)
    if(hN.getStreamingFactor<=0)
        paraminfo=[];
        return;
    end

    if(isbegin)
        paraminfo.active=true;
        paraminfo.fid=openHighlightFile(this,hN,'highlightStreaming');
        mpd.highlightMessages(sid)=1;
    else
        if(paraminfo.fid>0)
            highlightCulprit(this,paraminfo,hN.getStreamingCulprit,hN.streamingStatusMsg,paraminfo.fid);
            fclose(paraminfo.fid);
            paraminfo.fid=0;
        end
    end
end


function slBlockName=getBlockNameFromHandle(hC,path,hBlk)

    slBlockName={};

    if isempty(hBlk)||hBlk<=0
        if isempty(hC.Name)
            blkname='t';
        else
            blkname=hC.Name;
        end
        slBlockName1=hdlfixblockname(['',path,'/',blkname,'']);

        try
            hBlk=get_param(slBlockName1,'Handle');
        catch
            hBlk=[];
        end
    end

    if~isempty(hBlk)&&hBlk>0
        slBlockName=getfullname(hBlk);



        slBlockName=regexprep(slBlockName,'\r\n|\n|\r',' ');
    end

end


function hiliteComp(hC,fid,path,id,hBlk,clearHighlightingFid,desc,useInput)

    if nargin<=6
        desc=[];
    end
    if nargin<=7
        useInput=false;
    end

    slBlockName=getBlockNameFromHandle(hC,path,hBlk);

    if~isempty(slBlockName)

        try
            hBlk=get_param(slBlockName,'Handle');
        catch
            hBlk=[];
        end

        if~isempty(hBlk)
            fprintf(fid,'hilite_system(''%s'', ''%s'');\n',slBlockName,id);
        end

        if~isempty(desc)
            annotatePort(fid,slBlockName,useInput,1,desc,clearHighlightingFid);
        end
    end
end

function annotatePort(fid,slBlockName,useInput,port,descString,clearHighlightingFid)

    generateAnnotateHelperFunction();
    descString=strrep(descString,'''','''''');
    fprintf(fid,'annotate_port(''%s'', %d, %d, ''%s'');\n',slBlockName,useInput,port,descString);
    if(clearHighlightingFid>0)
        fprintf(clearHighlightingFid,'annotate_port(''%s'', %d, %d, ''%s'');\n',slBlockName,useInput,port,'');
    end

end

function hiliteId=getHiliteSchemeWithColor(fid,color,userid)
    if(userid>5)
        userid=mod(userid,5)+1;
    end
    hiliteId=['user',num2str(userid)];
    fprintf(fid,'cs.HiliteType = ''%s'';\n',hiliteId);
    fprintf(fid,'cs.ForegroundColor = ''black'';\n');
    fprintf(fid,'cs.BackgroundColor = ''%s'';\n',color);
    fprintf(fid,'set_param(0, ''HiliteAncestorsData'', cs);\n');
end


function hiliteId=getHiliteScheme(fid,id)
    persistent colors




    if isempty(colors)
        colors={'cyan','gray','yellow','darkGreen','magenta'};
    end

    id=id+1;

    if id>length(colors)
        id=length(colors);
    end

    color=colors{id};

    hiliteId=getHiliteSchemeWithColor(fid,color,id);

end

function hiliteId=getHiliteSchemeStreamingSharing(fid,id)
    persistent colorsStreamShare




    if isempty(colorsStreamShare)

        colorsStreamShare={'yellow','red','blue','lightblue','magenta','green','gray'};
    end

    if id>=length(colorsStreamShare)
        id=mod(id,length(colorsStreamShare));
    end

    id=id+1;

    color=colorsStreamShare{id};
    hiliteId=getHiliteSchemeWithColor(fid,color,id);
end

function msg=showMessage(this,paraminfo,mpd)
    msgsMap=mpd.highlightMessages;
    lastModel=mpd.lastModel;
    msg=[];
    if paraminfo.active&&...
        isfield(paraminfo,'hasUsefulInfo')&&...
        paraminfo.hasUsefulInfo&&...
        ~isempty(paraminfo.fileparam)&&...
        ~msgsMap.isKey(paraminfo.fileparam)
        msgsMap(paraminfo.fileparam)=1;
        if(~isempty(paraminfo.msgid))
            filename=getFileName(this,paraminfo.fileparam);
            msgObj=message(paraminfo.msgid);
            if this.HyperlinksInLog
                linkstr=sprintf('<a href="matlab:run(''%s'')">%s.m</a>',filename,filename);
                msg=[msgObj.getString(),' ',linkstr];
            else
                msg=[msgObj.getString(),' ',filename,'.m'];
            end
            this.genmodeldisp(msg);


            hDrv=hdlcurrentdriver();
            hDrv.addCheck(hDrv.ModelName,'Message',msgObj,'script',filename);
        end
    end

    if~isempty(paraminfo.fileparam)&&lastModel&&~msgsMap.isKey(paraminfo.fileparam)
        filename=getFileName(this,paraminfo.fileparam,true);
        if exist(filename,'file')
            try
                delete(filename);
            catch
            end
        end
    end

end

function highlightCulprit(this,paraminfo,culprit,desc,fid)


    if isempty(culprit)
        return;
    end
    r=strsplit(culprit,'/');
    if length(r)<2
        return;
    end

    gm_culprit_path=[this.OutModelFile,'/',strjoin(r(2:end),'/')];
    handle=getSimulinkBlockHandle(gm_culprit_path);
    if(handle>0)
        hiliteId=getHiliteScheme(fid,0);
        blkpath=regexprep(gm_culprit_path,'\r\n|\n|\r',' ');
        fprintf(fid,'hilite_system(''%s'', ''%s'');\n',blkpath,hiliteId);
        if~isempty(desc)
            annotatePort(fid,blkpath,false,1,desc,paraminfo.clearHighlightingFileid);
        end
    end


    handle=getSimulinkBlockHandle(culprit);
    if handle>0
        hiliteId=getHiliteScheme(fid,0);
        blkpath=regexprep(culprit,'\r\n|\n|\r',' ');
        fprintf(fid,'hilite_system(''%s'', ''%s'');\n',blkpath,hiliteId);
        if~isempty(desc)
            annotatePort(fid,blkpath,false,1,desc,paraminfo.clearHighlightingFileid);
        end
    end
end








