classdef ATG<soc.intelcomp.IntelComponentBase
    properties
        comp_name=''
timePeriods
    end

    methods
        function obj=ATG(varargin)

            obj.Configuration={...
            'dev_addr','0x00000000',...
            'dev_range','0',...
            'num','0',...
            'rw_dir','w',...
            'bsize','256',...
            'baddr','0',...
            'mm_dw','32',...
            'period','1e-6',...
            'mem_type','memPL',...
            'mem_addr','0x00000000',...
            'blkName','',...
            };
            if nargin>0
                obj.Configuration=varargin;
            end

            obj.timePeriods=eval(obj.Configuration.period);

            burst_len=ceil(str2double(obj.Configuration.bsize)/(str2double(obj.Configuration.mm_dw)/8));
            bsize_max=256*(str2double(obj.Configuration.mm_dw)/8);
            if burst_len>256||burst_len<1
                error(message('soc:msgs:trafficGenBurstLengthError',num2str(burst_len),obj.Configuration.bsize,num2str(bsize_max)));
            end

            obj.comp_name=['axi_traffic_gen_',obj.Configuration.num];

            obj.addAXI4Master([obj.comp_name,'.axi4_master'],obj.Configuration.mem_type,obj.Configuration.mem_type);


            obj.addAXI4Slave([obj.comp_name,'.axi4lite_slave'],'reg',obj.Configuration.mem_type,obj.Configuration.dev_addr);


            obj.addClk([obj.comp_name,'.IPCORE_CLK'],obj.type2ClkName(obj.Configuration.mem_type));
            obj.addClk([obj.comp_name,'.axi_clock'],obj.type2ClkName(obj.Configuration.mem_type));
            obj.addRst([obj.comp_name,'.IPCORE_RESET'],obj.type2RstnName(obj.Configuration.mem_type));
            obj.addRst([obj.comp_name,'.axi_reset'],obj.type2RstnName(obj.Configuration.mem_type));
            obj.Instance=[...
            ['add_instance ',obj.comp_name,' MW_traffic_generator 1.0 \n'],...
            ['set_instance_parameter_value ',obj.comp_name,' {AXI4_Master_Data_Width}',' {',obj.Configuration.mm_dw,'}\n'],...
            ];
        end

        function result=validateProperties(obj)
            result=hdlvalidatestruct;
            if obj.timePeriods(2)~=obj.timePeriods(3)
                result=hdlvalidatestruct(1,message('soc:msgs:checkFpgaDummyMasterPeriodNotSame',obj.Configuration.blkName));
            end
        end
    end
end
