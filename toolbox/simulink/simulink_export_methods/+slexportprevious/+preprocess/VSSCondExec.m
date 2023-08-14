function VSSCondExec(obj)







    vssBlks=find_system(obj.modelName,...
    'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.allVariants,...
    'IncludeCommented','on',...
    'BlockType','SubSystem',...
    'Variant','on');

    if isReleaseOrEarlier(obj.ver,'R2022a')

        for ii=1:numel(vssBlks)
            ctrlPortBlks={};

            ctrlPortBlks=find_system(vssBlks{ii},...
            'LookUnderMasks','all',...
            'searchdepth',1,...
            'MatchFilter',@Simulink.match.allVariants,...
            'IncludeCommented','on',...
            'regexp','on',...
            'BlockType','(Enable|Trigger|Reset)Port');
            for jj=1:length(ctrlPortBlks)
                dstH=ctrlportHandleOf(ctrlPortBlks{jj});

                srcLine=get_param(dstH,'Line');

                if srcLine~=-1

                    srcH=get_param(srcLine,'SrcPortHandle');

                    delete_line(srcLine);
                end

                delete_block(ctrlPortBlks{jj})

                inportBlk=add_block('built-in/Inport',ctrlPortBlks{jj});



                portNum=str2double(get_param(inportBlk,'Port'));

                vssBlockH=get_param(vssBlks{ii},'Handle');
                vssPortHandles=get_param(vssBlockH,'PortHandles');
                inputPortH=vssPortHandles.Inport(portNum);


                if srcLine~=-1
                    add_line(get_param(vssBlockH,'Parent'),srcH,inputPortH,'autorouting','smart');
                end
            end
        end
    end

end

function pH=ctrlportHandleOf(ctrlPortBlk)
    vssBlockH=get_param(get_param(ctrlPortBlk,'Parent'),'Handle');
    vssPortHandles=get_param(vssBlockH,'PortHandles');
    if strcmp(get_param(ctrlPortBlk,'BlockType'),'EnablePort')
        pH=vssPortHandles.Enable;
    elseif strcmp(get_param(ctrlPortBlk,'BlockType'),'TriggerPort')
        pH=vssPortHandles.Trigger;
    elseif strcmp(get_param(ctrlPortBlk,'BlockType'),'ResetPort')
        pH=vssPortHandles.Reset;
    end
end


