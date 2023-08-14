classdef(Abstract)IntelComponentBase<handle
    properties
AXI4Slave
AXI4Master
Clk
Rst
Instance
InstancePost
Configuration
Constraint
        Interrupt=struct('name',{},'irq_num',{},'triggerType',{});
BlkName
    end
    methods
        function addClk(obj,inputName,inputDriver)
            validateName(inputName);
            validateClkDriver(inputDriver);
            obj.Clk=[obj.Clk...
            ,struct('name',inputName,'driver',inputDriver)];
        end

        function addRst(obj,inputName,inputDriver)
            validateName(inputName);
            validateRstDriver(inputDriver);
            obj.Rst=[obj.Rst...
            ,struct('name',inputName,'driver',inputDriver)];
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
        function addAXI4Slave(obj,inputName,inputUsage,inputClkRstn,inputOffset)
            validateName(inputName);
            validateUsage(inputUsage);
            validateClkRstn(inputClkRstn);
            validateOffset(inputOffset);
            obj.AXI4Slave=[obj.AXI4Slave...
            ,struct('name',inputName,'usage',inputUsage,'clkRstn',inputClkRstn,'offset',inputOffset)];
        end
        function addAXI4Master(obj,inputName,inputUsage,inputClkRstn)
            validateName(inputName);
            validateUsage(inputUsage);
            validateClkRstn(inputClkRstn);
            obj.AXI4Master=[obj.AXI4Master...
            ,struct('name',inputName,'usage',inputUsage,'clkRstn',inputClkRstn)];
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

function validateName(inputName)
    if~iscellstr(inputName)&&~ischar(inputName)
        error(message('soc:msgs:configInvalidInputName'));
    end
end

function validateClkDriver(inputDriver)
    if~strcmpi(inputDriver,{'IPCoreClk','SystemClk','MemPSClk','MemPLClk','InputClk'})
        error(message('soc:msgs:configInvalidClkDriver'));
    end
end

function validateRstDriver(inputDriver)
    if~strcmpi(inputDriver,{'IPCoreRstn','SystemRstn','MemPSRstn','MemPLRstn','InputRst'})
        error(message('soc:msgs:configInvalidRstDriver'));
    end
end

function validateUsage(inputUsage)
    if~strcmpi(inputUsage,{'reg','all','memPS','memPL'})
        error(message('soc:msgs:configInvalidUsage'));
    end
end

function validateClkRstn(inputClkRstn)
    if~strcmpi(inputClkRstn,{'ipcore','sys','memPS','memPL'})
        error(message('soc:msgs:configInvalidClkRstnType'));
    end
end

function validateOffset(inputOffset)
    if~strncmpi(inputOffset,'0x',2)
        error(message('soc:msgs:configInvalidOffset'));
    end
end
