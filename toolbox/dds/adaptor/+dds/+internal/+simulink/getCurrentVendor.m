function vendorKey=getCurrentVendor(modelName)






    stf=get_param(modelName,'SystemTargetFile');
    if strcmp(stf,'slrealtime.tlc')

        vendorKey='eprosima_2_x';
    else
        [~,~,vendorKey,~]=dds.internal.simulink.Util.getCurrentMapSetting(modelName);
    end
end