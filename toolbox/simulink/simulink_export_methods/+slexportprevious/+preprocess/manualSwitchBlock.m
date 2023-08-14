function manualSwitchBlock(obj)









    if isR2012aOrEarlier(obj.ver)

        manswitchBlks=obj.findBlocksOfType('ManualSwitch');

        if isempty(manswitchBlks)
            return;
        end


        lib_mdl=getTempLib(obj);


        maskManualSwitchBlk=[lib_mdl,'/',obj.generateTempName];


        add_block('built-in/S-Function',maskManualSwitchBlk);

        set_param(maskManualSwitchBlk,...
        'GraphicalNumInputPorts','2',...
        'GraphicalNumOutputPorts','1',...
        'MaskVariables','sw=@1;action=@2;varsize=@3');

        save_system(lib_mdl);

        for i=1:length(manswitchBlks)
            blk=manswitchBlks{i};

            orient=get_param(blk,'Orientation');
            pos=get_param(blk,'Position');


            portH=get_param(blk,'PortHandles');
            datalog=get_param(portH.Outport,'DataLogging');


            CurrentSetting=get_param(blk,'sw');
            Action=get_param(blk,'action');
            VarSize=get_param(blk,'varsize');

            obj.replaceBlock(blk,maskManualSwitchBlk);

            set_param(blk,...
            'sw',CurrentSetting,...
            'action',Action,...
            'varsize',VarSize);


            newPortH=get_param(blk,'PortHandles');
            set_param(newPortH.Outport,'DataLogging',datalog);
        end



        ManualSwitchOldRef='simulink/Signal\nRouting/Manual Switch';
        obj.appendRule(['1',slexportprevious.rulefactory.replaceInSourceBlock('SourceBlock',...
        maskManualSwitchBlk,ManualSwitchOldRef)]);

    end


