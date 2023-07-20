function valSrcPortsHdls=getValidSrcPortHandles(cbinfo)
    cbObj=cbinfo.uiObject;
    if isa(cbObj,'Simulink.BlockDiagram')||...
        isa(cbObj,'Simulink.SubSystem')
        line=find_system(cbObj.handle,'LookUnderMasks','all',...
        'SearchDepth',1,'FindAll','on',...
        'Type','line','Selected','on');
    else
        valSrcPortsHdls=[];
        return;
    end

    valSrcPortsHdls=zeros(length(line));

    for idx=1:length(line)
        onePort=get_param(line(idx),'SrcPortHandle');
        if isequal(-1,onePort)||...
            isequal(get_param(onePort,'PortType'),'connection')
            continue;
        else
            valSrcPortsHdls(idx)=onePort;
        end
    end

    valSrcPortsHdls=valSrcPortsHdls(valSrcPortsHdls~=0);
end