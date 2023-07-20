classdef UpgradeUtils





    properties(Constant=true)
        FILE_LOG_BLOCK_WIDTH=70
        FILE_LOG_BLOCK_HEIGHT=36
        TERM_BLOCK_WIDTH=20
        TERM_BLOCK_HEIGHT=20
        SCOPE_BLOCK=['slrtlib/Displays and',newline,'Logging/Scope ']
    end

    methods(Static=true)

        function signalLoggingMode(modelName,mode)



            if strcmp(mode,'buffered')
                modeVal=1;
            elseif strcmp(mode,'immediate')
                modeVal=0;
            else
                DAStudio.error('coder_xcp:host:InvalidLoggingMode','buffered','immediate');
            end

            sigs=get_param(modelName,'InstrumentedSignals');
            if~isempty(sigs)
                for nSig=1:sigs.Count
                    sig=sigs.get(nSig);
                    sig.TargetBufferedStreaming_=modeVal;
                    sigs.set(nSig,sig);
                end
            end
            set_param(modelName,'InstrumentedSignals',sigs);

        end

        function bsigs=getBufferedSignals(modelName)


            sigs=get_param(modelName,'InstrumentedSignals');
            bsigs=[];
            if~isempty(sigs)
                for nSig=1:sigs.Count
                    sig=sigs.get(nSig);
                    if sig.TargetBufferedStreaming_==1
                        srcBlk=sig.getAlignedBlockPath;
                        if isFileLogBock(srcBlk)

                            continue;
                        end
                        bsigs=[bsigs,sig];%#ok<AGROW>
                    end
                end
            end
        end

        function convertBufferedSignals(modelName)


            sigs=get_param(modelName,'InstrumentedSignals');
            sigsToRemove=[];
            if~isempty(sigs)
                for nSig=1:sigs.Count
                    sig=sigs.get(nSig);
                    if sig.TargetBufferedStreaming_==1

                        sigsToRemove=[sigsToRemove,nSig];%#ok<AGROW>
                        srcBlk=sig.getAlignedBlockPath;
                        if isempty(srcBlk)||getSimulinkBlockHandle(srcBlk)==-1


                            continue;
                        end
                        if isFileLogBock(srcBlk)


                            continue;
                        end

                        pos=genFileLogBlockPosition(srcBlk,sig.OutputPortIndex);
                        h=connectFileLogBlock(srcBlk,sig.OutputPortIndex,pos);


                        if strcmp(get_param(srcBlk,'Commented'),'on')
                            set_param(h,'Commented','on')
                        end
                    end
                end
            end
            for nSig=sort(sigsToRemove,'descend')
                sigs.remove(nSig);
            end
            set_param(modelName,'InstrumentedSignals',sigs);
        end

        function scopes=findScopes(modelName)
            import slrealtime.internal.logging.UpgradeUtils

            scopes=find_system(modelName,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks','on',...
            'LookUnderMasks','on',...
            'Commented','off',...
            'MaskType','Obsolete Simulink Real-Time Block',...
            'ObsoleteBlock',UpgradeUtils.SCOPE_BLOCK);
        end

        function convertScopes(modelName)
            import slrealtime.internal.logging.UpgradeUtils



            scopes=slrealtime.internal.logging.UpgradeUtils.findScopes(modelName);

            for i=1:length(scopes)
                scopeBlk=scopes{i};
                scopeType=slrealtime.internal.logging.UpgradeUtils.getScopeType(scopeBlk);
                pos=get_param(scopeBlk,'Position');
                parent=get_param(scopeBlk,'Parent');
                if strcmp(scopeType,'Target')||strcmp(scopeType,'Host')

                    sph=get_param(scopeBlk,'PortHandles');
                    lineh=get_param(sph.Inport,'Line');
                    delete_block(scopeBlk);
                    if lineh>0


                        h=add_block('simulink/Sinks/Terminator',[parent,'/Terminator'],...
                        'Position',pos,'MakeNameUnique','on');
                        pc=get_param(h,'PortConnectivity');
                        if pc.SrcBlock>0

                            sph=get_param(pc.SrcBlock,'PortHandles');

                            set_param(sph.Outport(pc.SrcPort+1),'DataLogging','on');
                        end

                        pos(3)=pos(1)+UpgradeUtils.TERM_BLOCK_WIDTH;
                        pos(4)=pos(2)+UpgradeUtils.TERM_BLOCK_HEIGHT;
                        set_param(h,'Position',pos);
                    end
                elseif strcmp(scopeType,'File')

                    delete_block(scopeBlk);
                    h=add_block('slrealtimeloglib/File Log',[parent,'/File Log'],...
                    'Position',pos,'MakeNameUnique','on');


                    pos(3)=pos(1)+UpgradeUtils.FILE_LOG_BLOCK_WIDTH;
                    pos(4)=pos(2)+UpgradeUtils.FILE_LOG_BLOCK_HEIGHT;
                    set_param(h,'Position',pos);
                else
                    error('TODO');
                end

            end
        end

        function type=getScopeType(scopeBlk)
            params=get_param(scopeBlk,'ObsoleteParameters');
            params=extractAfter(params,'scopetype:  ');
            type=extractBefore(params,newline);
        end

    end
end


function pos=genFileLogBlockPosition(srcBlk,srcPortIdx)
    import slrealtime.internal.logging.UpgradeUtils
    srcBlkPos=get_param(srcBlk,'Position');
    pos(1)=srcBlkPos(3)+25+srcPortIdx*5;
    pos(2)=srcBlkPos(2)+srcPortIdx*30;
    pos(3)=pos(1)+UpgradeUtils.FILE_LOG_BLOCK_WIDTH;
    pos(4)=pos(2)+UpgradeUtils.FILE_LOG_BLOCK_HEIGHT;
end

function b=isFileLogBock(blkPath)
    b=false;
    parent=get_param(blkPath,'Parent');
    if strcmp(get_param(parent,'Type'),'block')&&...
        strcmp(get_param(parent,'MaskType'),'slrealtimeloggingblock')
        b=true;
    end
end

function h=connectFileLogBlock(srcBlk,srcPortIdx,insertPos)
    parent=get_param(srcBlk,'Parent');
    h=add_block('slrealtimeloglib/File Log',[parent,'/File Log'],...
    'Position',insertPos,'MakeNameUnique','on');
    sph=get_param(srcBlk,'PortHandles');
    dph=get_param(h,'PortHandles');
    add_line(parent,sph.Outport(srcPortIdx),dph.Inport(1));
end
