function spsDrivesOutputSelectorCbak(driveBlock,varargin)








    driveType=get_param(driveBlock,'driveType');
    busSelectorBlock=[driveBlock,'/Output bus selection','_',lower(driveType)];
    desiredOutputMode=get_param(driveBlock,'outputBusMode');
    drivePortHandles=get_param(driveBlock,'PortHandles');
    currentNumberOfOutputPorts=length(drivePortHandles.Outport);
    busLabels=get_param(driveBlock,'busLabels');



    suffix='';
...
...
...
...
...
...
...
    if strcmp(busLabels,'on')
        suffix='_with_labels';



    end


    switch desiredOutputMode
    case 'Single output bus'
        variant=['Single_output_bus',suffix];
        switch currentNumberOfOutputPorts


        case{1,2}

            if~isequal(get_param(busSelectorBlock,'LabelModeActiveChoice'),variant)
                set_param(busSelectorBlock,'LabelModeActiveChoice',variant);
            end
            return;


        case{3,4}


            if~isequal(get_param(busSelectorBlock,'LabelModeActiveChoice'),variant)
                set_param(busSelectorBlock,'LabelModeActiveChoice',variant);
            end

            replace_block(driveBlock,'FollowLinks','on','LookUnderMasks','on','SearchDepth',1,'Name','Ctrl','Parent',driveBlock,'Port','3','simulink/Sinks/Terminator','noprompt');
            replace_block(driveBlock,'FollowLinks','on','LookUnderMasks','on','SearchDepth',1,'Name','Conv.','Parent',driveBlock,'Port','2','simulink/Sinks/Terminator','noprompt');
        end

    case 'Multiple output buses'
        variant=['Multiple_output_buses',suffix];
        switch currentNumberOfOutputPorts


        case{3,4}
            if~isequal(get_param(busSelectorBlock,'LabelModeActiveChoice'),variant)
                set_param(busSelectorBlock,'LabelModeActiveChoice',variant);
            end
            return;


        case{1,2}


            if~isequal(get_param(busSelectorBlock,'LabelModeActiveChoice'),variant)
                set_param(busSelectorBlock,'LabelModeActiveChoice',variant);
            end

            replace_block(driveBlock,'FollowLinks','on','Name','Ctrl','Parent',driveBlock,'BlockType','Terminator','simulink/Sinks/Out1','noprompt');
            replace_block(driveBlock,'FollowLinks','on','Name','Conv.','Parent',driveBlock,'BlockType','Terminator','simulink/Sinks/Out1','noprompt');

            set_param([driveBlock,'/Conv.'],'Port','2','ForegroundColor','blue');
            set_param([driveBlock,'/Ctrl'],'Port','3','ForegroundColor','blue');
        end
    end