



function annotationInstantiation(this,annoblocks,configManager,hThisNetwork)%#ok<INUSL>

    if isempty(annoblocks)
        return;
    end



    origAnnoBlocks=annoblocks;

    try
        connexions=get_connected_annotations(hThisNetwork);
        if~isempty(connexions)&&(connexions.nHandles>0)

            unconnectedblks=setdiff(annoblocks,[connexions.srcHandle]);
            unattached=matchDestConnectionsWithComponents(hThisNetwork,connexions);

            annoblocks=union(unconnectedblks,unattached);
        end

    catch mEx
        disp(mEx.getReport())
        mEx %#ok<NOPRT>

        annoblocks=origAnnoBlocks;
    end

    for k=1:length(annoblocks)
        slbh=annoblocks(k);



        name=get_param(slbh,'Name');
        if~isempty(name)
            hC=hThisNetwork.addComponent('block_comp',0,0,'');
            hC.Name=name;
            hC.SimulinkHandle=slbh;
            impl=hdldefaults.Annotation;
            hC.setImplementation(impl);
        end
    end
end

function unattached=matchDestConnectionsWithComponents(hThisNetwork,connexions)
    unattached=[];
    for idx=1:connexions.nHandles
        dstHandle=connexions.dstHandle(idx);
        srcHandle=connexions.srcHandle(idx);

        dstComp=hThisNetwork.findComponent('sl_handle',dstHandle);
        if isempty(dstComp)
            unattached(end+1)=srcHandle;%#ok<AGROW>
            continue;
        end
        annoObj=get_param(srcHandle,'Object');
        dstComp.addComment(annoObj.PlainText);
    end
end

function connexions=get_connected_annotations(hThisNetwork)
    src_col=1;dst_col=2;
    connInfo=zeros(0,2);
    try

        connInfo=builtin('_sl_get_graph_connectors',hThisNetwork.SimulinkHandle);
    catch mEx
        if~strcmpi(mEx.identifier,'Simulink:Commands:InvSimulinkObjSpecifier')
            rethrow(mEx)
        end
    end
    connexions=struct('srcHandle',connInfo(:,src_col),'dstHandle',connInfo(:,dst_col),'nHandles',size(connInfo,1));
end


