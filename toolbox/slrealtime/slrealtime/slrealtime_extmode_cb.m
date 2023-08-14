function slrealtime_extmode_cb(model,obj,data)




    if strcmp(model,obj.ModelName)
        ext_open_intrf(model,'ProcessUpBlock',data,[],[],[],[]);
    end
end
