function entry=pm_libdef




    entry=PmSli.LibraryEntry('batt_sl_lib','simscape_battery','batt_lib');
    entry(end).Descriptor=sprintf('BMS');
    entry(end).DocumentationFcn=PmSli.LibraryEntry.defaultDocumentationFcn('simscape-battery/index.html','simscape-battery/ref');
    entry(end).EditingModeFcn='battery_sli_editingmodecallback';

    entry=iAddEntry(entry,'BatteryBalancing');
    entry=iAddEntry(entry,'BatteryCurrentManagement');
    entry=iAddEntry(entry,'BatteryEstimators');
    entry=iAddEntry(entry,'BatteryProtection');
    entry=iAddEntry(entry,'BatteryThermalManagement');

end

function entry=iAddEntry(entry,libraryName)
    entry(end+1)=PmSli.LibraryEntry(libraryName,'simscape_battery','');
    entry(end).DocumentationFcn=PmSli.LibraryEntry.defaultDocumentationFcn('simscape-battery/index.html','simscape-battery/ref');
    entry(end).EditingModeFcn='battery_sli_editingmodecallback';
end