function dnnfpgaSharedRenderEnabledTappedDelay(gcb,tapLength)



    if(isempty(tapLength))
        return;
    end
    if(tapLength<=0)
        return;
    end
    etdName='ETD';
    etdPath=[gcb,'/',etdName];
    pos=get_param(etdPath,'Position');
    try
        lh=get_param(etdPath,'LineHandles');
        delete_block(etdPath);
        delete_line(lh.Inport);
        delete_line(lh.Outport);
        redrawETD(etdPath,pos,tapLength);
        add_line(gcb,'In/1',[etdName,'/1'],'autorouting','on');
        add_line(gcb,'En/1',[etdName,'/2'],'autorouting','on');
        add_line(gcb,[etdName,'/1'],'Out/1','autorouting','on');
    catch me
    end
end

function redrawETD(curGcb,pos,tapLength)


    add_block('built-in/SubSystem',curGcb,'Name','ETD','Position',pos,'TreatAsAtomicUnit','off');

    inPortPos=[25,118,55,132];
    enPortPos=[100,73,130,87];
    outPortPos=[360,123,390,137];

    termPos=[170,70,190,90];
    muxPos=[300,0,305,235];
    delayPos=[160,95,200,155];


    add_block('built-in/InPort',[curGcb,'/In'],'Position',inPortPos);
    add_block('built-in/InPort',[curGcb,'/En'],'Position',enPortPos);
    add_block('built-in/OutPort',[curGcb,'/Out'],'Position',outPortPos);

    if(tapLength==1)
        add_block('built-in/Terminator',[curGcb,'/Term'],'Position',termPos);
        add_line(curGcb,'In/1','Out/1','autorouting','on');
        add_line(curGcb,'En/1','Term/1','autorouting','on');
    else
        add_block('built-in/Mux',[curGcb,'/Mux'],'Position',muxPos,'Inputs','2');
        if(tapLength>1)
            add_block('dnnfpgaSharedGenericlib/EnabledTD',[curGcb,'/EnabledTD'],'Position',delayPos,'tapLength',num2str(tapLength));
            add_line(curGcb,'En/1','EnabledTD/enable','autorouting','on');
            add_line(curGcb,'In/1','EnabledTD/1','autorouting','on');
            add_line(curGcb,'EnabledTD/1','Mux/1','autorouting','on');
        end
        add_line(curGcb,'In/1','Mux/2','autorouting','on');
        add_line(curGcb,'Mux/1','Out/1','autorouting','on');
    end
end
