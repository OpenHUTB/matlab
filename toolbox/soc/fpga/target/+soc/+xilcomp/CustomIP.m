classdef CustomIP<soc.xilcomp.XilinxComponentBase
    properties
CustomIPOutClk
CustomIPCoreName
CustomDtsi
CustomIPParams
    end

    methods
        function obj=CustomIP(blk,memMap,varargin)









            if nargin>0
                obj.Configuration=varargin;
            end

            [customIPInClk,customIPRst,customIPOutClk]=soc.blkcb.customIPCb('getClockResetInfo',blk);

            if~isempty(customIPInClk)

                for i=1:numel(customIPInClk)

                    if strcmpi(customIPInClk(i).Source,'Register configuration')
                        clkType='SystemClk';
                    elseif strcmpi(customIPInClk(i).Source,'IP core')
                        clkType='IPCoreClk';
                    elseif strcmpi(customIPInClk(i).Source,'PL memory controller')
                        clkType='MemPLClk';
                    elseif strcmpi(customIPInClk(i).Source,'PS memory controller')
                        clkType='MemPSClk';
                    else
                        error('(internal) Unknown input clock type %s',customIPInClk(i).Source);
                    end
                    obj.addClk(customIPInClk(i).Name,clkType);
                end
            end

            if~isempty(customIPRst)

                for i=1:numel(customIPRst)

                    if strcmpi(customIPRst(i).Source,'Register configuration')
                        rstType='SystemRstn';
                    elseif strcmpi(customIPRst(i).Source,'IP core')
                        rstType='IPCoreRstn';
                    elseif strcmpi(customIPRst(i).Source,'PL memory controller')
                        rstType='MemPLRstn';
                    elseif strcmpi(customIPRst(i).Source,'PS memory controller')
                        rstType='MemPSRstn';
                    else
                        error('(internal) Unknown input reset type %s',customIPRst(i).Source);
                    end
                    obj.addRst(customIPRst(i).Name,rstType);
                end
            end


            if~isempty(customIPOutClk)

                obj.CustomIPOutClk=customIPOutClk.Name;

            end

            obj.CustomIPParams=soc.blkcb.cbutils('GetDialogParams',blk);




            axi4SlaveInfo=soc.blkcb.customIPCb('getAXI4SlaveInfo',blk);
            for i=1:numel(axi4SlaveInfo)
                [dev_addr,dev_range]=soc.memmap.getComponentAddress(memMap,axi4SlaveInfo(i).MemMapName);
                obj.addAXI4Slave(axi4SlaveInfo(i).Name,'reg','sys',dev_addr,[dev_range{:}]);
            end


















            obj.Instance=[strrep(fileread(obj.CustomIPParams.designFilePath),'\','\\'),newline];

            if~isempty(obj.CustomIPParams.constrFilePath)

                obj.Constraint=[strrep(fileread(obj.CustomIPParams.constrFilePath),'\','\\'),newline];

            else

                obj.Constraint='';

            end

        end

    end

end





