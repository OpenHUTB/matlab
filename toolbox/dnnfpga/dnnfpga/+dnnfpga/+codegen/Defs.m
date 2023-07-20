function tds=Defs(customLayerList)





    import dnnfpga.typedefs.*

    if nargin<1
        customLayerList=[];
    end



    tds=TypeDefs();

    TypeAlias('TableAddr','fixdt(0,10,0)');














    Enum('DLCmd',...
    {'DFLT','FC','CONV','ADD','CONCAT','INPUT','OUTPUT',...
    'STE','REG','NOOP','DONE'},...
    [],...
    'Description','DL Commands',...
    'DefaultValue','DFLT',...
    'StorageType','uint8');

    Enum('IStackCmd',...
    {'DFLT','CLR','INIT','WR','LST'},...
    [],...
    'Description','IStack Commands',...
    'DefaultValue','DFLT',...
    'StorageType','uint8');

    Enum('TableOpCmd',...
    {'DFLT','DOREAD','DOWRITE','INIT','INITSTATE','CANREAD','CANWRITE','ALWAYSTRUE','CLR','LST'},[0;1;2;3;4;5;6;7;8;9],...
    'Description','TableUpdate Commands',...
    'DefaultValue','DFLT',...
    'StorageType','uint8');














    Enum('AddrMode',...
    {'Direct','IncrementInput','IncrementOutput','IncrementOutputPrev','Indirect'},[0;1;2;3;4],...
    'Description','Addressing Mode',...
    'DefaultValue','Direct',...
    'StorageType','uint8');










    bus=Bus('DLInstr');

    elem=BusElement('cmd','DLCmd');
    bus.add(elem);

    elem=BusElement('src0','fixdt(0,10,0)');
    bus.add(elem);

    elem=BusElement('src1','fixdt(0,10,0)');
    bus.add(elem);

    elem=BusElement('dst0','fixdt(0,10,0)');
    bus.add(elem);

    elem=BusElement('src0Mode','AddrMode');
    bus.add(elem);

    elem=BusElement('src1Mode','AddrMode');
    bus.add(elem);

    elem=BusElement('dst0Mode','AddrMode');
    bus.add(elem);

    elem=BusElement('epoch','uint8');
    bus.add(elem);





    bus=Bus('IStack');

    elem=BusElement('cmd','IStackCmd');
    bus.add(elem);

    elem=BusElement('instr','DLInstr');
    bus.add(elem);






    bus=Bus('Payload');



    elem=BusElement('words','uint32',[1,7]);
    bus.add(elem);





    bus=Bus('IStackWData');

    elem=BusElement('payload','Payload');
    bus.add(elem);

    elem=BusElement('cmd','IStackCmd');
    bus.add(elem);

    elem=BusElement('instr','DLInstr');
    bus.add(elem);





    bus=Bus('ConcatPayload');

    elem=BusElement('oneBit','boolean');
    bus.add(elem);





    bus=Bus('NoOpPayload');

    elem=BusElement('oneBit','boolean');
    bus.add(elem);






    bus=Bus('ConvPayload');

    elem=BusElement('ipCount','uint16');
    bus.add(elem);

    elem=BusElement('opCount','uint16');
    bus.add(elem);

    elem=BusElement('srcAddr','uint32');
    bus.add(elem);

    elem=BusElement('dstAddr','uint32');
    bus.add(elem);





    bus=Bus('AddPayload');


    elem=BusElement('src0Addr','uint32');
    bus.add(elem);


    elem=BusElement('src1Addr','uint32');
    bus.add(elem);

    elem=BusElement('dstAddr','uint32');
    bus.add(elem);

    elem=BusElement('exponent','int8');
    bus.add(elem);

    elem=BusElement('exponentIn1','int8');
    bus.add(elem);

    elem=BusElement('exponentIn2','int8');
    bus.add(elem);

    elem=BusElement('reluValue','uint32');
    bus.add(elem);

    elem=BusElement('reluScaleExp','fixdt(1,8,0)');
    bus.add(elem);








    adderBCC=dnnfpga.bcc.getBCCDefaultAdd(customLayerList);
    lcParams=cell2mat(adderBCC.lcParams);
    bus=Bus('adderInstruBus');
    for lcParam=lcParams
        elem=BusElement(lcParam.name,lcParam.dataType,lcParam.vectorType);
        bus.add(elem);
    end





    bus=Bus('InputPayload');

    elem=BusElement('addr','uint32');
    bus.add(elem);

    elem=BusElement('sizeInBytes','uint32');
    bus.add(elem);

    elem=BusElement('id','uint8');
    bus.add(elem);

    elem=BusElement('frameNumber','uint32');
    bus.add(elem);

    elem=BusElement('isFirst','boolean');
    bus.add(elem);





    bus=Bus('OutputPayload');

    elem=BusElement('addr','uint32');
    bus.add(elem);

    elem=BusElement('sizeInBytes','uint32');
    bus.add(elem);

    elem=BusElement('id','uint8');
    bus.add(elem);

    elem=BusElement('isLast','boolean');
    bus.add(elem);





    bus=Bus('RegPayload');

    elem=BusElement('addr','uint32');
    bus.add(elem);

    elem=BusElement('value','uint32');
    bus.add(elem);






    bus=Bus('RegionDescriptor');

    elem=BusElement('isValid','boolean');
    bus.add(elem);

    elem=BusElement('addr','uint32');
    bus.add(elem);

    elem=BusElement('length','uint32');
    bus.add(elem);

    elem=BusElement('id','uint8');
    bus.add(elem);

    elem=BusElement('epoch','uint8');
    bus.add(elem);





    bus=Bus('FCPayload');

    elem=BusElement('instrCount','uint16');
    bus.add(elem);

    elem=BusElement('srcAddr','uint32');
    bus.add(elem);

    elem=BusElement('dstAddr','uint32');
    bus.add(elem);





    bus=Bus('TableEntry');

    elem=BusElement('num','fixdt(0,10,0)');
    bus.add(elem);

    elem=BusElement('staticReads','uint8');
    bus.add(elem);

    elem=BusElement('currentReads','uint8');
    bus.add(elem);

    elem=BusElement('epoch','uint8');
    bus.add(elem);

    elem=BusElement('isConstant','boolean');
    bus.add(elem);

    elem=BusElement('isState','boolean');
    bus.add(elem);





    bus=Bus('TableRsp');

    elem=BusElement('stackNum','uint8');
    bus.add(elem);

    elem=BusElement('value','boolean');
    bus.add(elem);

    elem=BusElement('isError','boolean');
    bus.add(elem);





    bus=Bus('TableOp');

    elem=BusElement('stackNum','uint8');
    bus.add(elem);

    elem=BusElement('num','fixdt(0,10,0)');
    bus.add(elem);

    elem=BusElement('cmd','TableOpCmd');
    bus.add(elem);

    elem=BusElement('staticReads','uint8');
    bus.add(elem);

    elem=BusElement('epoch','uint8');
    bus.add(elem);

    elem=BusElement('isConstant','boolean');
    bus.add(elem);





    bus=Bus('MemReq');

    elem=BusElement('isWrite','boolean');
    bus.add(elem);

    elem=BusElement('addr','uint32');
    bus.add(elem);





    bus=Bus('WordReq');

    elem=BusElement('isWrite','boolean');
    bus.add(elem);

    elem=BusElement('data','uint32');
    bus.add(elem);

    elem=BusElement('addr','uint32');
    bus.add(elem);





    bus=Bus('WordRsp');

    elem=BusElement('isWrite','boolean');
    bus.add(elem);

    elem=BusElement('data','uint32');
    bus.add(elem);





    bus=Bus('AxiRdReq');

    elem=BusElement('addr','uint32');
    bus.add(elem);

    elem=BusElement('length','uint32');
    bus.add(elem);





    bus=Bus('AxiRdSend');

    elem=BusElement('rd_avalid','boolean');
    bus.add(elem);

    elem=BusElement('rd_len','uint32');
    bus.add(elem);

    elem=BusElement('rd_addr','uint32');
    bus.add(elem);

    elem=BusElement('rd_dready','boolean');
    bus.add(elem);

    elem=BusElement('rd_arid','uint8');
    bus.add(elem);





    bus=Bus('AxiRdRecv');

    elem=BusElement('data','uint32');
    bus.add(elem);

    elem=BusElement('rd_dvalid','boolean');
    bus.add(elem);

    elem=BusElement('rd_aready','boolean');
    bus.add(elem);

    elem=BusElement('rd_rid','uint8');
    bus.add(elem);





    bus=Bus('AxiWrSend');

    elem=BusElement('wr_valid','boolean');
    bus.add(elem);

    elem=BusElement('wr_len','uint32');
    bus.add(elem);

    elem=BusElement('wr_addr','uint32');
    bus.add(elem);





    bus=Bus('AxiWrRecv');

    elem=BusElement('wr_ready','boolean');
    bus.add(elem);

    elem=BusElement('wr_complete','boolean');
    bus.add(elem);





    bus=Bus('AxiReq');

    elem=BusElement('addr','uint32');
    bus.add(elem);

    elem=BusElement('length','uint32');
    bus.add(elem);

end




