function open(blockId,blockHandle,appId,varargin)


    try
        gui=Simulink.playback.GUI.pbGUI(blockId,blockHandle,appId,varargin{:});

        Simulink.HMI.initializeSubscriber(...
        '/sdi/AddDataTableApplication',...
        'pb_add_data_table_message_handler',false);
        gui.Config.AppId=appId;
        gui.openGUI(gui,gui.Config);
        gui.bringToFront();
    catch me
        msg=message('record_playback:errors:AddDataUILoadFailure',me.message);
        error(msg);
    end
end
