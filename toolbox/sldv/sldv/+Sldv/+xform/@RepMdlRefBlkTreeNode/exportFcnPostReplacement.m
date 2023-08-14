function exportFcnPostReplacement(obj)








    if~isExportFcnMdl(obj)||isempty(obj.ReplacementInfo)
        return;
    end

    subsysH=obj.ReplacementInfo.AfterReplacementH;
    inportsToFix=obj.ExportFcnInformation.MultiDimFcnCallSrcSplit;
    sysInportH=find_system(subsysH,...
    'SearchDepth',1,...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'BlockType','Inport');

    for i=1:length(sysInportH)
        inportH=sysInportH(i);
        idx=str2double(get_param(inportH,'port'));
        if ismember(idx,inportsToFix)
            insertFcnCallPassThroughSys(inportH,subsysH);
        end
    end
end

function insertFcnCallPassThroughSys(inportH,subsysH)
    pos=get_param(inportH,'position');
    dstPath=[getfullname(subsysH),'/__SLDVFcnCallPass'];
    sysPos=[pos(1)+100,pos(2)+20,pos(1)+160,pos(2)+40];

    blkReplacer=Sldv.xform.BlkReplacer.getInstance();


    fcnSysH=blkReplacer.addBlock('built-in/SubSystem',dstPath,...
    'MakeNameUnique','on');
    set_param(fcnSysH,'position',sysPos);
    set_param(fcnSysH,'TreatAsAtomicUnit','on');
    set_param(fcnSysH,'Tag','__SLDVFcnCallPass');
    set_param(fcnSysH,'DisableCoverage','on');

    fcnSysPath=getfullname(fcnSysH);
    trigH=blkReplacer.addBlock('built-in/TriggerPort',[fcnSysPath,'/Fcn']);
    set_param(trigH,'TriggerType','function-call');


    fcnGenH=blkReplacer.addBlock('simulink/Ports & Subsystems/Function-Call Generator',...
    [fcnSysPath,'/FcnGen']);
    set_param(fcnGenH,'sample_time','-1');
    fcnPos=get_param(fcnGenH,'position');
    outH=blkReplacer.addBlock('built-in/Outport',[fcnSysPath,'/Out1']);
    set_param(outH,'position',[fcnPos(1)+100,fcnPos(2),fcnPos(1)+200,fcnPos(2)+20]);

    blkReplacer.addLine(fcnSysPath,[get_param(fcnGenH,'name'),'/1'],[get_param(outH,'name'),'/1']);
    inPH=get_param(inportH,'PortHandles');
    srcP=inPH.Outport(1);
    inLine=get_param(srcP,'line');
    dstP=get_param(inLine,'DstPortHandle');
    blkReplacer.deleteLine(inLine);

    fcnSysPorts=get_param(fcnSysH,'PortHandles');
    newDstP=fcnSysPorts.Trigger;
    newSrcP=fcnSysPorts.Outport;

    blkReplacer.addLine(subsysH,srcP,newDstP);
    blkReplacer.addLine(subsysH,newSrcP,dstP);


    Simulink.BlockDiagram.createSubsystem(fcnSysH);
    parentH=get_param(get_param(fcnSysH,'Parent'),'Handle');
    set_param(parentH,'Position',[pos(1)+100,pos(2),pos(3)+75,pos(4)]);
end
