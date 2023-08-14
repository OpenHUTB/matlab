classdef(Abstract)XilinxComponentBase<handle
    properties
AXI4Slave
AXI4Master
Clk
Rst
Instance
        InstancePost=''
Configuration
Constraint
        Interrupt=struct('name',{},'irq_num',{},'triggerType',{});
BlkName
    end

    methods
        function addClk(obj,inputName,inputDriver)
            l_validateName(inputName);
            l_validateClkDriver(inputDriver);
            obj.Clk=[obj.Clk...
            ,struct('name',inputName,'driver',inputDriver)];
        end

        function addRst(obj,inputName,inputDriver)
            l_validateName(inputName);
            l_validateRstDriver(inputDriver);
            obj.Rst=[obj.Rst...
            ,struct('name',inputName,'driver',inputDriver)];
        end

        function addAXI4Slave(obj,inputName,inputUsage,inputClkRstn,inputOffset,inputRange)
            l_validateName(inputName);
            l_validateUsage(inputUsage);
            l_validateClkRstn(inputClkRstn);
            l_validateOffset(inputOffset);
            obj.AXI4Slave=[obj.AXI4Slave...
            ,struct('name',inputName,'usage',inputUsage,'clk_rstn',inputClkRstn,'offset',inputOffset,'range',inputRange)];
        end

        function addAXI4Master(obj,inputName,inputUsage,inputClkRstn)
            l_validateName(inputName);
            l_validateUsage(inputUsage);
            l_validateClkRstn(inputClkRstn);
            obj.AXI4Master=[obj.AXI4Master...
            ,struct('name',inputName,'usage',inputUsage,'clk_rstn',inputClkRstn)];
        end

        function set.Configuration(obj,vargin)
            if~iscellstr(vargin)||mod(numel(vargin),2)
                error(message('soc:msgs:configMustCellArray'));
            end
            for i=1:2:numel(vargin)
                obj.Configuration.(vargin{i})=vargin{i+1};
            end
        end
        function addInterrupt(obj,inputName)
            obj.Interrupt=[obj.Interrupt...
            ,struct('name',inputName,'irq_num',0,'triggerType','Rising edge')];
        end
        function clk_name=type2ClkName(obj,type)
            switch lower(type)
            case 'sys'
                clk_name='SystemClk';
            case 'memps'
                clk_name='MemPSClk';
            case 'mempl'
                clk_name='MemPLClk';
            case 'ipcore'
                clk_name='IPCoreClk';
            end
        end
        function rstn_name=type2RstnName(obj,type)
            switch lower(type)
            case 'sys'
                rstn_name='SystemRstn';
            case 'memps'
                rstn_name='MemPSRstn';
            case 'mempl'
                rstn_name='MemPLRstn';
            case 'ipcore'
                rstn_name='IPCoreRstn';
            end
        end

    end

end

function l_validateName(inputName)
    if~iscellstr(inputName)&&~ischar(inputName)
        error(message('soc:msgs:configInvalidInputName'));
    end
end

function l_validateClkDriver(inputDriver)
    if~strcmpi(inputDriver,{'IPCoreClk','SystemClk','MemPSClk','MemPLClk','InputClk'})
        error(message('soc:msgs:configInvalidClkDriver'));
    end
end

function l_validateRstDriver(inputDriver)
    if~strcmpi(inputDriver,{'IPCoreRstn','SystemRstn','MemPSRstn','MemPLRstn','InputRst'})
        error(message('soc:msgs:configInvalidRstDriver'));
    end
end

function l_validateUsage(inputUsage)
    if~strcmpi(inputUsage,{'reg','all','memPS','memPL'})
        error(message('soc:msgs:configInvalidUsage'));
    end
end

function l_validateClkRstn(inputClkRstn)
    if~strcmpi(inputClkRstn,{'ipcore','sys','memPS','memPL'})
        error(message('soc:msgs:configInvalidClkRstnType'));
    end
end

function l_validateOffset(inputOffset)
    if~strncmpi(inputOffset,'0x',2)
        error(message('soc:msgs:configInvalidOffset'));
    end
end




