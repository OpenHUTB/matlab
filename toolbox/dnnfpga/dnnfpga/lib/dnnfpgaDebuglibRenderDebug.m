function dnnfpgaDebuglibRenderDebug(gcb,cc)



    if(isempty(cc))
        return;
    end
    MultistageName='Debugs_alloted';
    MultistagePath=[gcb,'/',MultistageName];


    try
        lh=get_param(MultistagePath,'LineHandles');
        delete_block(MultistagePath);
        delete_line(lh.Inport);
        delete_line(lh.Outport);
    catch ME
        disp(ME.message);
    end


    switchSysPos=[130,45,170,105];
    try
        if isfield(cc,'isCNN4Debug')&&cc.isCNN4Debug






            dnnfpga.debug.redrawDebugSwitch(MultistagePath,switchSysPos,cc);



        end
        add_line(gcb,'In1/1',[MultistageName,'/1'],'autorouting','on');
        add_line(gcb,'In2/1',[MultistageName,'/2'],'autorouting','on');
        add_line(gcb,[MultistageName,'/1'],'Out/1','autorouting','on');
    catch ME
        disp(ME.message);
    end
end





























































