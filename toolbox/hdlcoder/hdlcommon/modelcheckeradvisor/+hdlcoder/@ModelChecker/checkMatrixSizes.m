function flag=checkMatrixSizes(this)



    flag=true;

    dut=this.m_DUT;
    blocks=hdlcoder.ModelChecker.find_system_MAWrapper(dut,'RegExp','On','Type','Block');
    for ii=1:numel(blocks)

        blockType=get_param(blocks{ii},'BlockType');
        pHandles=get_param(blocks{ii},'PortHandles');
        phan=[pHandles.Inport,pHandles.Outport];
        for jj=1:numel(phan)

            cDims=get_param(phan(jj),'CompiledPortDimensions');
            if isempty(cDims)
                continue;
            end
            if any(strcmp(blockType,{'Product','Sum'}))&&cDims(1)==2&&cDims(2)*cDims(3)>=10
                this.addCheck('warning',...
                DAStudio.message('HDLShared:hdlmodelchecker:MatrixSizesChecks_largeMatrix'),...
                blocks{ii},0);
                flag=false;
                break;
            end
            if cDims(1)>2
                this.addCheck('warning',...
                DAStudio.message('HDLShared:hdlmodelchecker:MatrixSizesChecks_tooManyDims'),...
                blocks{ii},0);
                flag=false;
                break;
            end
        end
    end
end
