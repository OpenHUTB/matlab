function sfObj=getSFObj(blkH,elemType,varargin)



    sfObj=struct('Name','','ID','0','SSID','0','ChartBlk',blkH,...
    'BusType','','SFDataType','Unknown','StateActType','Unknown','Valid',false);
    chartId=sfprivate('block2chart',blkH);
    if chartId==0
        return;
    end
    chart=idToHandle(sfroot,chartId);
    if~isa(chart,'Stateflow.Chart')&&~isa(chart,'Stateflow.ReactiveTestingTableChart')...
        &&~isa(chart,'Stateflow.StateTransitionTableChart')&&~isa(chart,'Stateflow.TruthTableChart')
        return;
    end
    chartSID=Simulink.ID.getSID(blkH);
    switch elemType
    case 'SFState'
        ssid=varargin{1};
        actType=varargin{2};
        sfObj.SSID=ssid;
        sfObj.StateActType=actType;
        if isempty(ssid)
            if strcmp(actType,'Self')
                return;
            end
            sfObj.Name=chart.Name;
            sfObj.ID=num2str(chartId);
            sfObj.Valid=strcmp(chart.Decomposition,'EXCLUSIVE_OR');
        else
            try
                sfHdl=Simulink.ID.getHandle([chartSID,':',ssid]);
            catch
                return;
            end
            if~isa(sfHdl,'Stateflow.Object')
                return;
            end
            sfObj.Name=sfHdl.Name;
            sfObj.ID=num2str(sfHdl.Id);
            if isa(sfHdl,'Stateflow.State')
                sfObj.Valid=strcmp(actType,'Self')||strcmp(sfHdl.Decomposition,'EXCLUSIVE_OR');
            elseif isa(sfHdl,'Stateflow.SimulinkBasedState')||isa(sfHdl,'Stateflow.AtomicSubchart')
                sfObj.Valid=strcmp(actType,'Self');
            else
                return;
            end
        end
    case 'SFData'
        ssid=varargin{1};
        sfObj.SSID=ssid;
        try
            sfHdl=Simulink.ID.getHandle([chartSID,':',ssid]);
        catch
            return;
        end
        if~isa(sfHdl,'Stateflow.Data')
            return;
        end

        if strcmp(sfHdl.Scope,'Local')
            sfObj.SFDataType='Local';
        elseif strcmp(sfHdl.Scope,'Parameter')
            sfObj.SFDataType='Parameter';
        else
            return;
        end

        sfObj.Name=sfHdl.Name;
        sfObj.ID=num2str(sfHdl.Id);
        if strcmp(sfHdl.Props.Type.Method,'Bus Object')
            sfObj.BusType=sfHdl.Props.Type.BusObject;
        end
        sfObj.Valid=true;
    otherwise
        return;
    end

end

