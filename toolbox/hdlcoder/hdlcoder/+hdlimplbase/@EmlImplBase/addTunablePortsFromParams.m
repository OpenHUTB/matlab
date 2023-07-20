function addTunablePortsFromParams(slbh)





    if slprivate('is_stateflow_based_block',slbh)


        linkStatus=get_param(slbh,'linkstatus');
        if(~strcmpi(linkStatus,'none')&&~strcmpi(linkStatus,'inactive'))

            set_param(slbh,'linkstatus','none');
        end

        chartID=sfprivate('block2chart',slbh);
        r=sfroot;
        chartUddH=r.idToHandle(chartID);
        if isempty(chartUddH)
            return;
        end


        chartInputs=chartUddH.find('-isa','Stateflow.Data','Scope','Input');
        lastInput=numel(chartInputs);

        chartParams=chartUddH.find('-isa','Stateflow.Data','Scope','Parameter');
        for ii=1:numel(chartParams)
            paramName=chartParams(ii).Name;
            TunableParamStr=hdlimplbase.EmlImplBase.getTunableParameter(slbh,paramName);
            if~isempty(TunableParamStr)
                chartParams(ii).Scope='input';
                chartParams(ii).Port=lastInput+1;
                lastInput=lastInput+1;
            end
        end
    end



