function flag=checkNFPSupportedBlocks(this)




    flag=true;
    model=this.m_sys;
    dut=this.m_DUT;


    targetConfig=hdlget_param(model,'FloatingPointTargetConfig');
    if~isempty(targetConfig)
        if strcmpi('NativeFloatingPoint',targetConfig.Library)
            blocks_in_DUT=hdlcoder.ModelChecker.find_system_MAWrapper(dut,'RegExp','On','Type','Block');

            block_types=cellfun(@(x)strrep(hdlgetblocklibpath(x),newline,' '),...
            blocks_in_DUT,'UniformOutput',false);

            supported_blocks=hdlcoder.NFPModelChecker.getSupportedBlocks;

            unsupported_blocks={};
            for block_num=1:length(blocks_in_DUT)
                if~any(strcmpi(supported_blocks,block_types{block_num}))
                    if isSingleType(blocks_in_DUT{block_num})
                        unsupported_blocks{end+1}=blocks_in_DUT{block_num};%#ok<AGROW>
                        this.addCheck('warning',DAStudio.message('HDLShared:hdlmodelchecker:desc_NFP_unsupported_blocks'),blocks_in_DUT{block_num},0);
                    end
                end
            end
            flag=isempty(unsupported_blocks);
        end
    end
end


function isSingle=isSingleType(block)
    isSingle=false;
    portHandles=get_param(block,'PortHandles');
    inoutph=[portHandles.Inport,portHandles.Outport];
    datatypes=get_param(inoutph,'CompiledPortDataType');
    if any(strcmpi(datatypes,'single'))
        isSingle=true;
    end
end


