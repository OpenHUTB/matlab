function setOutputVisibility(pouBlock,outputNames,settings,baseIndex)



    if~iscell(outputNames)
        outputNames={outputNames};
    end

    if~iscell(settings)
        settings={settings};
    end

    portIndex=baseIndex;
    for nameCount=1:numel(outputNames)
        if strcmpi(settings(nameCount),'on')
            replaceOutport(pouBlock,outputNames{nameCount},'Terminator','Outport');
            set_param([pouBlock,'/',outputNames{nameCount}],'Port',num2str(portIndex));
            portIndex=portIndex+1;
        else
            replaceOutport(pouBlock,outputNames{nameCount},'Outport','Terminator');
        end
    end
end

function replaceOutport(pouBlock,outputName,block1,block2)
    replace_block(pouBlock,...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'Name',outputName,...
    'BlockType',block1,...
    block2,'noprompt');
end