function[outputBlk,outputBlkPosition]=addSLBlockModel(this,hC,originalBlkPath,targetBlkPath)






    in=hC.SLInputPorts;
    start_position=[185,75];
    move_right=[100,0];
    move_down=[0,100];

    origBlkPortDataType=get_param(originalBlkPath,'CompiledPortDataTypes');
    OutDataTypeMode=origBlkPortDataType.Outport;
    blkpath=[targetBlkPath,'/',hC.Name];
    blkSize=blockSize(originalBlkPath);
    add_block(originalBlkPath,blkpath);
    blkPosition=[start_position,start_position+blkSize];
    start_position=start_position+move_right;
    set_param(blkpath,'Position',blkPosition);


    for i=1:length(in)
        add_line(targetBlkPath,['In',num2str(i),'/1'],[hC.Name,'/',num2str(i)],'autorouting','on');
    end

    genSignalConversionPath=[targetBlkPath,'/',hC.Name,'_SignalConversion'];
    add_block('built-in/SignalConversion',genSignalConversionPath);
    blkPosition=[start_position,start_position+blockSize(genSignalConversionPath)];
    set_param(genSignalConversionPath,'Position',blkPosition);
    set_param(genSignalConversionPath,'ConversionOutput','Contiguous copy');
    set_param(genSignalConversionPath,'OverrideOpt','on')
    add_line(targetBlkPath,[hC.Name,'/1'],[hC.Name,'_SignalConversion','/1'],'autorouting','on');
    outputBlk=[hC.Name,'_SignalConversion'];
    outputBlkPosition=start_position+blockSize(genSignalConversionPath);


    function blkSize=blockSize(Block)
        Position=get_param(Block,'Position');
        blkSize=[Position(3)-Position(1),Position(4)-Position(2)];





