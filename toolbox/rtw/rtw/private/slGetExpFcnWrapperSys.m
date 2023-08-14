function[sysHdl,sfcnHdl]=slGetExpFcnWrapperSys(origBlk,mask_ss_hdl,gen_sfcn_hdl)




    origBlkName=get_param(origBlk,'Name');
    modelH=find_system('type','block_diagram','Name',[origBlkName,'_expfcn']);
    if(length(modelH)==1)
        modelH=modelH{1};
    end
    wrapperSys=find_system(modelH,'SearchDepth',1,'BlockType','SubSystem','Name',origBlkName);
    if(length(wrapperSys)==1);
        wrapperSys=wrapperSys{1};
    end

    virtualSys=find_system(wrapperSys,'SearchDepth',1,...
    'MaskType',[origBlkName,'_ExpCodeSys']);
    if~isempty(virtualSys)


        virtualSysPos=get_param(virtualSys,'Position');
        delete_block(virtualSys);
        new_ss_path=[get_param(bdroot(mask_ss_hdl),'Name'),'/',get_param(mask_ss_hdl,'Name')];
        dstPath=[wrapperSys,'/__ExportCode__'];
        add_block(new_ss_path,...
        dstPath,...
        'Position',virtualSysPos{1},...
        'ForegroundColor','black',...
        'ShowName','on','FontSize',10);

        LocalCheckConnection(wrapperSys,gcb);
        close_system(wrapperSys);



        inportBlks=find_system(dstPath,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SearchDepth',2,'BlockType','Inport');
        for i=1:length(inportBlks)
            set_param(inportBlks{i},'PortDimensions','-1');
            set_param(inportBlks{i},'VarSizeSig','Inherit');
            set_param(inportBlks{i},'OutDataTypeStr','Inherit: auto');
            set_param(inportBlks{i},'SignalType','auto');
        end

        modelName=get_param(modelH,'Name');
        blksInRoot=find_system(bdroot(modelH),'SearchDepth',1,'type','block');
        for i=1:length(blksInRoot)
            blk=blksInRoot{i};
            if~strcmp(blk,wrapperSys)
                portH=get_param(blk,'PortHandles');
                if~isempty(portH.Outport)
                    for j=1:length(portH.Outport)
                        lineH=get_param(portH.Outport(j),'Line');
                        if lineH>0
                            delete(lineH);
                        end
                    end
                end
                if~isempty(portH.Inport)
                    for j=1:length(portH.Inport)
                        lineH=get_param(portH.Inport(j),'Line');
                        if lineH>0
                            delete(lineH);
                        end
                    end
                end
                delete_block(blk);
            end
        end
        sysHdl=wrapperSys;


        new_sfcn=find_system(dstPath,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Name',get_param(gen_sfcn_hdl,'Name'));
        if(length(new_sfcn)==1)
            sfcnHdl=new_sfcn{1};
        end

        close_system(bdroot(mask_ss_hdl),0);
        open_system(bdroot(sysHdl));
    else
        sysHdl=mask_ss_hdl;
        sfcnHdl=gen_sfcn_hdl;
    end
end

function LocalCheckConnection(parentSys,blkHdl)
    needReconnect=false;
    portHdls=get_param(blkHdl,'PortHandles');

    for i=1:length(portHdls.Inport)
        inportHdl=portHdls.Inport(i);
        lineH=get_param(inportHdl,'Line');
        if lineH==-1
            needReconnect=true;
            continue
        end
    end
    if needReconnect

        for i=1:length(portHdls.Inport)
            inportHdl=portHdls.Inport(i);
            lineH=get_param(inportHdl,'Line');
            if lineH~=-1
                delete(lineH);
            end
        end

        inportBlks=find_system(parentSys,'SearchDepth',1,'BlockType','Inport');
        for i=1:length(inportBlks)
            locPortHdls=get_param(inportBlks{i},'PortHandles');
            srcPortH=locPortHdls.Outport;
            dstPortH=portHdls.Inport(i);
            lineH=get_param(srcPortH,'Line');
            while lineH~=-1
                tmpBlkH=get_param(lineH,'DstBlockHandle');
                if tmpBlkH==-1
                    delete(lineH);
                    break;
                end
                locPortHdls=get_param(tmpBlkH,'PortHandles');
                srcPortH=locPortHdls.Outport(1);
                lineH=get_param(srcPortH,'Line');
            end
            add_line(parentSys,srcPortH,dstPortH);
        end
    end


    needReconnect=false;
    for i=1:length(portHdls.Outport)
        outportHdl=portHdls.Outport(i);
        lineH=get_param(outportHdl,'Line');
        if lineH==-1
            needReconnect=true;
            continue;
        end
    end
    if needReconnect

        for i=1:length(portHdls.Outport)
            outportHdl=portHdls.Outport(i);
            lineH=get_param(outportHdl,'Line');
            if lineH~=-1
                delete(lineH);
            end
        end

        outportBlks=find_system(parentSys,'SearchDepth',1,'BlockType','Outport');
        for i=1:length(outportBlks)
            locPortHdls=get_param(outportBlks{i},'PortHandles');
            dstPortH=locPortHdls.Inport;
            if get_param(dstPortH,'Line')~=-1;
                delete(get_param(dstPortH,'Line'));
            end
            srcPortH=portHdls.Outport(i);
            add_line(parentSys,srcPortH,dstPortH);
        end
    end
end
