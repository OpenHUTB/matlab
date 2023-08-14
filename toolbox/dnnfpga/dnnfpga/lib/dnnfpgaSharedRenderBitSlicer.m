function dnnfpgaSharedRenderBitSlicer(gcb,elementNum,bitwidth,outType,kernelDataType)
    if(isempty(elementNum))
        return;
    end
    bsName='BS';
    bsPath=[gcb,'/',bsName];
    pos=get_param(bsPath,'Position');
    if(~strcmp(kernelDataType,'single'))
        outType='int32';
    end
    try
        lh=get_param(bsPath,'LineHandles');
        delete_block(bsPath);
        delete_line(lh.Inport);
        delete_line(lh.Outport);
        redrawBitSlicer([gcb,'/',bsName],pos,elementNum,bitwidth,outType);
        add_line(gcb,'In/1',[bsName,'/1'],'autorouting','on');
        add_line(gcb,'BS/1','Out/1','autorouting','on');
    catch me
    end
end

function curGcb=redrawBitSlicer(curGcbOrig,pos,elementNum,bitwidth,outType)
    [~,root]=fileparts(curGcbOrig);


    h=add_block('built-in/SubSystem',curGcbOrig,'MakeNameUnique','on','Position',pos,'TreatAsAtomicUnit','off');
    subBlockName=get_param(h,'name');
    curGcb=[root,'/',subBlockName];
    forEachPortPos=[150,-55,204,-24];
    inPortPos=[20,38,50,52];
    muxPos=[260,17,265,17+40*elementNum];
    firstBSPos=[180,35,230,55];
    casterPos=[325,110,390,130];
    outPortPos=[420,113,450,127];
    bsSpacer=50;


    add_block('built-in/InPort',[curGcbOrig,'/In'],'Position',inPortPos);
    add_block('built-in/Mux',[curGcbOrig,'/Mux'],'Position',muxPos,'Inputs',num2str(elementNum));
    add_block('built-in/OutPort',[curGcbOrig,'/Out'],'Position',outPortPos);
    if(strcmpi(outType,'single')||strcmpi(outType,'double'))
        add_block('built-in/FloatTypecast',[curGcbOrig,'/FTC'],'Position',casterPos);
        add_line(curGcbOrig,'Mux/1','FTC/1','autorouting','on');
        add_line(curGcbOrig,'FTC/1','Out/1','autorouting','on');
    else
        add_block('built-in/DataTypeConversion',[curGcbOrig,'/DTC'],'Position',casterPos,'OutDataTypeStr',outType);
        add_line(curGcbOrig,'Mux/1','DTC/1','autorouting','on');
        add_line(curGcbOrig,'DTC/1','Out/1','autorouting','on');
    end
    add_block('built-in/ForEach',[curGcbOrig,'/For Each'],'Position',forEachPortPos,'InputPartition',{'on'});

    for i=0:elementNum-1
        ridx=i*bitwidth;
        lidx=(i+1)*bitwidth-1;
        offset=[0,i*bsSpacer,0,i*bsSpacer];
        bsName=sprintf('bs%d',i);
        add_block('hdlsllib/Logic and Bit Operations/Bit Slice',[curGcbOrig,'/',bsName],...
        'MakeNameUnique','on','Position',firstBSPos+offset,...
        'lidx',num2str(lidx),'ridx',num2str(ridx));
        add_line(curGcbOrig,'In/1',[bsName,'/1'],'autorouting','on');
        add_line(curGcbOrig,[bsName,'/1'],['Mux/',num2str(i+1)],'autorouting','on');
    end

end
