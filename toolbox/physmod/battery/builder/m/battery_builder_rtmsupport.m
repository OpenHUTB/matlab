function battery_builder_rtmsupport(event,handle)





    switch lower(event)
    case 'copyfcn'
        if strcmp(get_param(handle,"BlockType"),'SubSystem')
            set_param(gcb,'LinkStatus','breakWithoutHierarchy');
            drawnow;
        end
    case 'precopyfcn'
        checkSimscapeBatteryLicense();
    case 'predeletefcn'
        [~,~]=license('checkout','simscape_battery');
    case 'loadfcn'
        [~,~]=license('checkout','simscape_battery');
    otherwise
    end
    function checkSimscapeBatteryLicense()
        if~pmsl_checklicense('simscape_battery')
            error(message('physmod:battery:license:MissingLicense'));
        end
    end
end
