function status=preReplacementCheck(obj,blockInfo)




    status=true;

    if obj.UseOriginalBlockAsReplacement
        return;
    end

    blockH=blockInfo.BlockH;

    portH=get_param(obj.ReplacementPath,'PortHandles');

    replacementInfo.NumOfInports=length(portH.Inport);
    replacementInfo.NumOfOutports=length(portH.Outport);

    fields=fieldnames(replacementInfo);
    for i=1:length(fields)
        if replacementInfo.(fields{i})~=blockInfo.(fields{i})
            portName=strrep(fields{i},'NumOf','');
            errStr=getString(message('Sldv:xform:RepRule:MatchError',portName,getfullname(blockH),obj.ReplacementPath));
            blockInfo.ReplacementInfo.PreReplacementMsgs{end+1}=errStr;
            status=false;
            break;
        end
    end
end