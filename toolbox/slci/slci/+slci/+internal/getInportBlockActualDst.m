

function[actDst]=getInportBlockActualDst(blkH,port,srcH,srcPort)










    actDst=zeros(0,5);
    srcActDst=slci.internal.getActualDst(srcH,srcPort);
    sysPortActDst=getSubsystemPortDst(blkH,port);
    for j=1:numel(srcActDst)
        dst=srcActDst(j,:);
        if ismember(dst(1),sysPortActDst(:,1))
            actDst=[actDst;dst];%#ok
        end
    end
end


function actDst=getSubsystemPortDst(blkH,port)
    actDst=zeros(0,5);
    blkType=get_param(blkH,'BlockType');
    if strcmp(blkType,'SubSystem')
        blkHandle=get_param(blkH,'Handle');
        inportBlocks=find_system(blkHandle,'SearchDepth',1,...
        'BlockType','Inport');
        if port<numel(inportBlocks)
            for i=1:numel(inportBlocks)
                prt=get_param(inportBlocks(i),'Port');
                if str2double(prt)==port+1
                    block=inportBlocks(i);
                    actDst=slci.internal.getActualDst(block,0);
                    break;
                end
            end
        end
    end
end
