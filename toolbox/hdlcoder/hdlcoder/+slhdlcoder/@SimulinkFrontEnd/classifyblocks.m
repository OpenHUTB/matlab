function blockInfo=classifyblocks(this,blocklist,doChecks)





    if nargin<3
        doChecks=true;
    end


    blockInfo=struct('Inports',[],'Outports',[],'EnablePort',[],...
    'ActionPort',[],'StateControl',[],'StateEnablePort',[],...
    'ResetPort',[],'TriggerPort',[],'SyntheticBlocks',[],'OtherBlocks',[]);

    for k=1:length(blocklist)
        bhan=blocklist(k);

        if doChecks


            this.checkBlock(bhan);
        end

        typ=get_param(bhan,'BlockType');
        switch typ
        case 'Inport'
            blockInfo.Inports=[blockInfo.Inports,bhan];
        case 'Outport'
            blockInfo.Outports=[blockInfo.Outports,bhan];
        case 'EnablePort'
            blockInfo.EnablePort=bhan;
        case 'ActionPort'
            blockInfo.ActionPort=bhan;
        case 'StateControl'
            blockInfo.StateControl=bhan;
        case 'StateEnablePort'
            blockInfo.StateEnablePort=bhan;
        case 'ResetPort'
            blockInfo.ResetPort=bhan;
        case 'TriggerPort'
            blockInfo.TriggerPort=bhan;
        otherwise
            blockInfo.OtherBlocks=[blockInfo.OtherBlocks,bhan];

            if doChecks&&slhdlcoder.SimulinkFrontEnd.isSyntheticBlock(bhan)
                blk=get_param(bhan,'Object');
                if~strcmp(blk.getSyntReason,'SL_SYNT_BLK_REASON_BUSEXPANSION')

                    blockInfo.SyntheticBlocks=[blockInfo.SyntheticBlocks,bhan];
                end
            end
        end
    end

    debug=this.HDLCoder.getParameter('debug')>=2;
    if debug
        for ii=1:length(blocklist)
            blkname=getfullname(blocklist(ii));
            blkname=strrep(blkname,newline,' ');
            blklibpath=hdlgetblocklibpath(blocklist(ii));
            blklibpath=strrep(blklibpath,newline,' ');
            fprintf('%s -> %s\n',blkname,blklibpath);
        end
    end
