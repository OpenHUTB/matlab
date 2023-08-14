function ret=plc_check_ladder_subsystem(blkH)



    ret=false;
    if isequal(get_param(blkH,'Type'),'block_diagram')
        plccore.common.plcThrowError('plccoder:plccore:CGUnsupportedForModel',getfullname(blkH));
        return;
    else


        blkType=slplc.utils.getParam(blkH,'PLCBlockType');
        if isempty(blkType)
            return;
        end
        ret=true;
    end
end
