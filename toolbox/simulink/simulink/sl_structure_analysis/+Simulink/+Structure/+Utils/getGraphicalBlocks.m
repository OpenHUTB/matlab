




function hBlist=getGraphicalBlocks(obj)



    import Simulink.Structure.Utils.*

    if~strcmp(obj.Type,'block_diagram')
        if isNormalModeModelRef(obj)
            mdlName=obj.ModelName;
            mo=get_param(mdlName,'Object');
            obj=mo;
        end
    end


    hBlist=find_system(obj.handle,'SearchDepth',1,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on','FindAll','off','type','block');
    n=length(hBlist);

    if n<1
        hBlist=[];
    else
        if hBlist(1)==obj.handle
            hBlist=hBlist(2:end);
        end
    end



    n=length(hBlist);
    IndexToRemove=[];

    for i=1:n
        ho=get_param(hBlist(i),'Object');
        if ho.isPostCompileVirtual

            Ports=get_param(hBlist(i),'Ports');
            nIp=Ports(1);
            nOp=Ports(2);

            if(nIp==1)&&(nOp==1)




                portConnectivity=get_param(hBlist(i),'PortConnectivity');
                srcB=portConnectivity(1).SrcBlock;

                remove=true;



                if srcB~=-1&&strcmp(get_param(srcB,'BlockType'),'Inport')
                    dstB=portConnectivity(2).DstBlock;

                    for j=1:length(dstB)
                        dstType=get_param(dstB(j),'BlockType');
                        if strcmp(dstType,'Outport')
                            remove=false;
                            break;
                        end
                    end
                end

                if remove
                    IndexToRemove=[IndexToRemove;i];
                end

            end
        end
    end

    hBlist(IndexToRemove)=[];

end