function schemas=LBHDLCoderItems(~)
    schemas={@RemoveHDLMode};
end

function schema=RemoveHDLMode(~)
    schema=DAStudio.ActionSchema;

    schema.accelerator='Ctrl+Shift+H';

    if privhdllibstate('status')
        schema.icon='Simulink:Undo';
        schema.label=DAStudio.message('hdlsllib:hdlsllib:hdllib_exit_filter');
        schema.tooltip=DAStudio.message('hdlsllib:hdlsllib:hdllib_exit_filter');
    else
        schema.icon='Simulink:Redo';
        schema.label=DAStudio.message('hdlsllib:hdlsllib:hdllib_enter_filter');
        schema.tooltip=DAStudio.message('hdlsllib:hdlsllib:hdllib_enter_filter');
    end

    schema.callback=@ToggleHDLModeCB;
end

function ToggleHDLModeCB(~)
    enable_flag=~privhdllibstate('status');

    if enable_flag
        title=DAStudio.message('hdlsllib:hdlsllib:hdllib_entering_filter');
    else
        title=DAStudio.message('hdlsllib:hdlsllib:hdllib_exiting_filter');
    end


    hWaitbar=waitbar(0,title);
    function updateWaitbar(val)
        waitbar(val,hWaitbar);
    end

    arrayfun(@updateWaitbar,linspace(0,0.25,1000));
    pause(1);


    lb=slLibraryBrowser;
    arrayfun(@updateWaitbar,linspace(0.25,0.5,1000));
    lb.close();
    arrayfun(@updateWaitbar,linspace(0.5,0.75,1000));


    if enable_flag
        hdllib('on');
    else
        hdllib('off');
    end


    arrayfun(@updateWaitbar,linspace(0.75,1,1000))
    delete(hWaitbar);
end
