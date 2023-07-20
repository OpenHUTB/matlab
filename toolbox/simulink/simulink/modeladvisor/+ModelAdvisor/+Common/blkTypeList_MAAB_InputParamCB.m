function blkTypeList_MAAB_InputParamCB(taskobj,tag,handle)%#ok<INUSD>
    if isa(taskobj,'ModelAdvisor.Task')
        inputParameters=taskobj.Check.InputParameters;
    elseif isa(taskobj,'ModelAdvisor.ConfigUI')
        inputParameters=taskobj.InputParameters;
    else
        return
    end



    ip2=getInputParameterByName(inputParameters,DAStudio.message('ModelAdvisor:engine:BlkListInterpretionMode'));
    ip3=getInputParameterByName(inputParameters,DAStudio.message('ModelAdvisor:engine:BlkTypeList'));

    if isempty(ip3)
        ip3=getInputParameterByName(inputParameters,DAStudio.message('ModelAdvisor:engine:BlkTypeListWithParameter'));
    end

    if strcmp(taskobj.MAC,'mathworks.maab.na_0008')
        ip2=getInputParameterByName(inputParameters,DAStudio.message('ModelAdvisor:styleguide:na_0008_input_param1'));
        ip3=getInputParameterByName(inputParameters,DAStudio.message('ModelAdvisor:styleguide:na_0008_input_param2'));
    end

    if strcmp(taskobj.MAC,'mathworks.jmaab.jc_0008')
        ip2=getInputParameterByName(inputParameters,DAStudio.message('ModelAdvisor:jmaab:jc_0008_input_param1'));
        ip3=getInputParameterByName(inputParameters,DAStudio.message('ModelAdvisor:jmaab:jc_0008_input_param2'));
    end

    if strcmp(tag,'InputParameters_1')

        switch inputParameters{1}.Value
        case{'MAB','JMAAB 5.0'}
            if strcmp(taskobj.MAC,'mathworks.maab.na_0008')
                if~isempty(ip2)
                    ip2.Enable=false;
                    ip2.Value=ModelAdvisor.Common.getDefaultBlockList_na_0008_output;
                end
                if~isempty(ip3)
                    ip3.Enable=false;
                    ip3.Value=ModelAdvisor.Common.getDefaultBlockList_na_0008_input;
                end
            elseif strcmp(taskobj.MAC,'mathworks.maab.db_0140')
                if~isempty(ip3)
                    ip3.Enable=false;
                    ip3.Value=getDefaultBlockList(taskobj);
                end
            elseif strcmp(taskobj.MAC,'mathworks.jmaab.jc_0008')
                if~isempty(ip2)
                    ip2.Enable=false;
                    ip2.Value=ModelAdvisor.Common.getDefaultBlockList_na_0008_output;
                end
                if~isempty(ip3)
                    ip3.Enable=false;
                    ip3.Value=ModelAdvisor.Common.getDefaultBlockList_na_0008_input;
                end
            else
                if~isempty(ip2)
                    ip2.Enable=false;
                    ip2.Value=getDefaultBlkListInterpretionMode(taskobj);
                end
                if~isempty(ip3)
                    ip3.Value=getDefaultBlockList(taskobj);
                    ip3.Enable=false;
                end
            end

        case 'Custom'

            if~isempty(ip2)
                ip2.Enable=true;
            end

            if~isempty(ip3)
                ip3.Enable=true;
            end
        end

    elseif strcmp(tag,'InputParameters_2')
        if strcmp(ip2.Value,getDefaultBlkListInterpretionMode(taskobj))
            if~isempty(ip3)
                ip3.Value=getDefaultBlockList(taskobj);
            end

        else
            if~isempty(ip3)
                ip3.Value={};
            end
        end
    end
end

function blkList=getDefaultBlockList(taskobj)
    blkList={};
    switch taskobj.MAC
    case 'mathworks.maab.jm_0001'
        blkList=ModelAdvisor.Common.getDefaultBlockList_jm_0001;
    case 'mathworks.maab.hd_0001'
        blkList=ModelAdvisor.Common.getDefaultBlockList_hd_0001;
    case 'mathworks.maab.db_0143'
        blkList=ModelAdvisor.Common.getDefaultBlockList_db_0143;
    case 'mathworks.maab.db_0140'
        blkList=ModelAdvisor.Common.getDefaultBlockList_db_0140;
    case 'mathworks.maab.na_0027'
        blkList=Advisor.Utils.Simulink.block.getSimulinkBlockSupportTable(false);
    end
end

function value=getDefaultBlkListInterpretionMode(taskobj)
    value='';
    switch taskobj.MAC
    case 'mathworks.maab.jm_0001'
        value=ModelAdvisor.Common.getDefaultBlkListInterpretionMode_jm_0001;
    case 'mathworks.maab.hd_0001'
        value=ModelAdvisor.Common.getDefaultBlkListInterpretionMode_hd_0001;
    case 'mathworks.maab.db_0143'
        value=ModelAdvisor.Common.getDefaultBlkListInterpretionMode_db_0143;
    otherwise
        value=DAStudio.message('ModelAdvisor:engine:Allowed');
    end
end

function inputParameter=getInputParameterByName(InputParameters,Name)
    inputParameter=[];
    for i=1:length(InputParameters)
        if strcmp(InputParameters{i}.Name,Name)
            inputParameter=InputParameters{i};
            return
        end
    end
end
