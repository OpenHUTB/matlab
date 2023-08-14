function replaceBlock(oldBlock,newBlock,varargin)






    name=strrep(get_param(oldBlock,'Name'),'/','//');
    parent=get_param(oldBlock,'Parent');
    newPath=[parent,'/',name];


    decorations=getDecorationParams(oldBlock);








    origMask=Simulink.Mask.get(oldBlock);
    blockType=get_param(oldBlock,'BlockType');
    if ismember(blockType,{'SubSystem','S-Function'})||isempty(origMask)
        mask=[];
    else


        [~,tmpBlock]=fileparts(tempname);
        tmpBlock=[parent,'/',tmpBlock];
        add_block('built-in/SubSystem',tmpBlock);
        mask=Simulink.Mask.create(tmpBlock);
        mask.copy(origMask);
    end


    portParams=getPortParams(oldBlock);



    delete_block(oldBlock);
    add_block(newBlock,newPath,varargin{:},decorations{:});


    if~isempty(mask)

        warn=warning('off','Simulink:Masking:Invalid_MaskType');
        cleanup=onCleanup(@()warning(warn));
        newMask=Simulink.Mask.create(newPath);
        newMask.copy(mask);
        delete_block(tmpBlock);
    end


    setPortParams(oldBlock,portParams);

end


function decorations=getDecorationParams(block)





    decorations=getParams(block,{...
    'Position',...
    'Orientation',...
    'ForegroundColor',...
    'BackgroundColor',...
    'DropShadow',...
    'NamePlacement',...
    'FontName',...
    'FontSize',...
    'FontWeight',...
    'FontAngle',...
    'ShowName',...
'AttributesFormatString'...
    });

end


function params=getPortParams(block)


    ph=get_param(block,'PortHandles');
    numPorts=length(ph.Outport);

    params=cell(numPorts,1);

    for i=1:numPorts
        params{i}=getParams(ph.Outport(i),{...
        'DataLogging',...
        'DataLoggingNameMode',...
        'DataLoggingName',...
        'DataLoggingDecimateData',...
        'DataLoggingDecimation',...
        'DataLoggingLimitDataPoints',...
        'DataLoggingMaxPoints',...
        });
    end

end


function setPortParams(block,params)


    ph=get_param(block,'PortHandles');
    numPorts=min(length(ph.Outport),length(params));

    for i=1:numPorts
        set_param(ph.Outport(i),params{i}{:});
    end

end


function params=getParams(handle,names)


    numParams=length(names);
    params=cell(numParams,2);
    params(:,1)=names;

    for i=1:numParams
        params{i,2}=get_param(handle,names{i});
    end

    params=reshape(params',1,length(params(:)));

end


