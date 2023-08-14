




function ssid=getSID(cvid)

    try
        ssid=[];
        if cv('ishandle',cvid)
            handle=cv('get',cvid,'.handle');
            if cv('get',cvid,'.origin')==3

                ssid=cv('GetSlsfName',cvid);
                ssid=[ssid,'.m'];
                return;
            end
            if cv('get',cvid,'.origin')==4
                ssid=cv('GetSlsfName',cvid);
                return;
            end
            if cv('get',cvid,'.origin')==2
                ccvid=getCvChartId(cvid);
                instancePath=cv('get',ccvid,'.origPath');
                instaceSSID=Simulink.ID.getSID(instancePath);
                chartHandle=cv('get',ccvid,'.handle');
                if~sf('Private','is_eml_chart',chartHandle)&&...
                    ~sf('Private','is_truth_table_chart',chartHandle)&&...
                    cv('get',cvid,'.refClass')~=sf('get','default','chart.isa')
                    ssid=sf('get',handle,'.ssIdNumber');
                    ssidTxt='%s:%d';
                    ssid=sprintf(ssidTxt,instaceSSID,ssid);
                else
                    ssid=instaceSSID;
                end
            end
        end
        if isempty(ssid)&&handle~=0
            ssid=Simulink.ID.getSID(handle);
        end
    catch MEx
        rethrow(MEx);
    end

    function cvid=getCvChartId(cvid)
        while cv('get',cvid,'.refClass')~=sf('get','default','chart.isa')
            cvid=cv('get',cvid,'.treeNode.parent');
        end


