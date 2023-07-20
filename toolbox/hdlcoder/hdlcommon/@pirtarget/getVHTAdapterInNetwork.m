function nComp=getVHTAdapterInNetwork(hNTop,InputPortSignals,OutputPortSignals,networkName)




    if nargin<4
        networkName=sprintf('%s_VHT_Adapter_In',hNTop.Name);
    end

    InportNames={'data_in','tvalid','sof','eol','image_length','image_height','hporch','vporch'};
    in_types=arrayfun(@(x)InputPortSignals(x).Type,1:length(InputPortSignals),'uniformoutput',false);
    in_rates=arrayfun(@(x)InputPortSignals(x).SimulinkRate,1:length(InputPortSignals));

    OutPortNames={'data_out','hstart','hend','vstart','vend','valid','ready_out'};

    out_types(1)=InputPortSignals(1).Type;
    out_types(2)=InputPortSignals(2).Type;
    out_types(3)=InputPortSignals(2).Type;
    out_types(4)=InputPortSignals(2).Type;
    out_types(5)=InputPortSignals(2).Type;
    out_types(6)=InputPortSignals(2).Type;
    out_types(7)=InputPortSignals(2).Type;

    hN=pirelab.createNewNetwork(...
    'Network',hNTop,...
    'Name',networkName,...
    'InportNames',InportNames,...
    'InportTypes',[in_types{:}],...
    'InportRates',in_rates,...
    'OutportNames',OutPortNames,...
    'OutportTypes',out_types(:)...
    );


    inSigs=hN.PirInputSignals;
    outSigs=hN.PirOutputSignals;
    slRate=inSigs(1).SimulinkRate;
    boolean_type=inSigs(2).Type;
    data_type=inSigs(1).Type;


    data_reg=hN.addSignal2('Type',data_type,'Name','data_reg','SimulinkRate',slRate);
    data_buf=hN.addSignal2('Type',data_type,'Name','data_buf','SimulinkRate',slRate);
    data_buf_delay=hN.addSignal2('Type',data_type,'Name','data_buf_delay','SimulinkRate',slRate);
    data_buf_delay1=hN.addSignal2('Type',data_type,'Name','data_buf_delay1','SimulinkRate',slRate);
    data_out_output=hN.addSignal2('Type',data_type,'Name','data_out_output','SimulinkRate',slRate);
    data_reg_temp=hN.addSignal2('Type',data_type,'Name','data_reg_temp','SimulinkRate',slRate);
    valid_reg=hN.addSignal2('Type',boolean_type,'Name','valid_reg','SimulinkRate',slRate);
    eol_tvalid=hN.addSignal2('Type',boolean_type,'Name','eol_tvalid','SimulinkRate',slRate);
    eol_buf=hN.addSignal2('Type',boolean_type,'Name','eol_buf','SimulinkRate',slRate);
    line_counter_length=13;
    line_counter_type=hN.getType('FixedPoint','Signed',0,'WordLength',line_counter_length,'FractionLength',0);
    line_counter=hN.addSignal2('Type',line_counter_type,'Name','line_counter','SimulinkRate',slRate);
    pixel_counter_length=13;
    pixel_counter_type=hN.getType('FixedPoint','Signed',0,'WordLength',pixel_counter_length,'FractionLength',0);
    pixel_counter=hN.addSignal2('Type',pixel_counter_type,'Name','pixel_counter','SimulinkRate',slRate);

    porch_type=hN.getType('FixedPoint','Signed',0,'WordLength',13,'FractionLength',0);
    numofpixels=hN.addSignal2('Type',porch_type,'Name','numofpixels','SimulinkRate',slRate);
    numoflines=hN.addSignal2('Type',porch_type,'Name','numoflines','SimulinkRate',slRate);
    hlength=hN.addSignal2('Type',porch_type,'Name','hlength','SimulinkRate',slRate);
    hlength_buf=hN.addSignal2('Type',porch_type,'Name','hlength_buf','SimulinkRate',slRate);

    vlength=hN.addSignal2('Type',porch_type,'Name','vlength','SimulinkRate',slRate);
    vlength_buf=hN.addSignal2('Type',porch_type,'Name','vlength_buf','SimulinkRate',slRate);

    tvalid=hN.addSignal2('Type',boolean_type,'Name','tvalid','SimulinkRate',slRate);
    sof=hN.addSignal2('Type',boolean_type,'Name','sof','SimulinkRate',slRate);
    eol=hN.addSignal2('Type',boolean_type,'Name','eol','SimulinkRate',slRate);

    cond0=hN.addSignal2('Type',boolean_type,'Name','cond0','SimulinkRate',slRate);
    cond1=hN.addSignal2('Type',boolean_type,'Name','cond1','SimulinkRate',slRate);
    cond2=hN.addSignal2('Type',boolean_type,'Name','cond2','SimulinkRate',slRate);
    cond3=hN.addSignal2('Type',boolean_type,'Name','cond3','SimulinkRate',slRate);
    cond4=hN.addSignal2('Type',boolean_type,'Name','cond4','SimulinkRate',slRate);
    cond5=hN.addSignal2('Type',boolean_type,'Name','cond5','SimulinkRate',slRate);
    cond6=hN.addSignal2('Type',boolean_type,'Name','cond6','SimulinkRate',slRate);
    cond7=hN.addSignal2('Type',boolean_type,'Name','cond7','SimulinkRate',slRate);
    cond8=hN.addSignal2('Type',boolean_type,'Name','cond8','SimulinkRate',slRate);
    cond9=hN.addSignal2('Type',boolean_type,'Name','cond9','SimulinkRate',slRate);
    cond10=hN.addSignal2('Type',boolean_type,'Name','cond10','SimulinkRate',slRate);
    cond11=hN.addSignal2('Type',boolean_type,'Name','cond11','SimulinkRate',slRate);
    cond12=hN.addSignal2('Type',boolean_type,'Name','cond12','SimulinkRate',slRate);
    cond13=hN.addSignal2('Type',boolean_type,'Name','cond13','SimulinkRate',slRate);
    cond14=hN.addSignal2('Type',boolean_type,'Name','cond14','SimulinkRate',slRate);
    cond15=hN.addSignal2('Type',boolean_type,'Name','cond15','SimulinkRate',slRate);
    cond16=hN.addSignal2('Type',boolean_type,'Name','cond16','SimulinkRate',slRate);
    cond17=hN.addSignal2('Type',boolean_type,'Name','cond17','SimulinkRate',slRate);
    cond18=hN.addSignal2('Type',boolean_type,'Name','cond18','SimulinkRate',slRate);
    cond19=hN.addSignal2('Type',boolean_type,'Name','cond19','SimulinkRate',slRate);
    cond20=hN.addSignal2('Type',boolean_type,'Name','cond20','SimulinkRate',slRate);
    cond21=hN.addSignal2('Type',boolean_type,'Name','cond21','SimulinkRate',slRate);
    cond22=hN.addSignal2('Type',boolean_type,'Name','cond22','SimulinkRate',slRate);
    cond23=hN.addSignal2('Type',boolean_type,'Name','cond23','SimulinkRate',slRate);

    cond25=hN.addSignal2('Type',boolean_type,'Name','cond25','SimulinkRate',slRate);
    cond26=hN.addSignal2('Type',boolean_type,'Name','cond26','SimulinkRate',slRate);
    cond27=hN.addSignal2('Type',boolean_type,'Name','cond27','SimulinkRate',slRate);
    cond28=hN.addSignal2('Type',boolean_type,'Name','cond28','SimulinkRate',slRate);
    cond29=hN.addSignal2('Type',boolean_type,'Name','cond29','SimulinkRate',slRate);
    cond30=hN.addSignal2('Type',boolean_type,'Name','cond30','SimulinkRate',slRate);
    cond31=hN.addSignal2('Type',boolean_type,'Name','cond31','SimulinkRate',slRate);
    cond32=hN.addSignal2('Type',boolean_type,'Name','cond32','SimulinkRate',slRate);
    cond33=hN.addSignal2('Type',boolean_type,'Name','cond33','SimulinkRate',slRate);
    cond34=hN.addSignal2('Type',boolean_type,'Name','cond34','SimulinkRate',slRate);
    cond35=hN.addSignal2('Type',boolean_type,'Name','cond35','SimulinkRate',slRate);
    cond36=hN.addSignal2('Type',boolean_type,'Name','cond36','SimulinkRate',slRate);
    cond37=hN.addSignal2('Type',boolean_type,'Name','cond37','SimulinkRate',slRate);
    cond38=hN.addSignal2('Type',boolean_type,'Name','cond38','SimulinkRate',slRate);
    cond39=hN.addSignal2('Type',boolean_type,'Name','cond39','SimulinkRate',slRate);
    cond40=hN.addSignal2('Type',boolean_type,'Name','cond40','SimulinkRate',slRate);
    cond41=hN.addSignal2('Type',boolean_type,'Name','cond41','SimulinkRate',slRate);
    cond42=hN.addSignal2('Type',boolean_type,'Name','cond42','SimulinkRate',slRate);
    cond43=hN.addSignal2('Type',boolean_type,'Name','cond43','SimulinkRate',slRate);
    cond44=hN.addSignal2('Type',boolean_type,'Name','cond44','SimulinkRate',slRate);
    cond45=hN.addSignal2('Type',boolean_type,'Name','cond45','SimulinkRate',slRate);
    cond46=hN.addSignal2('Type',boolean_type,'Name','cond46','SimulinkRate',slRate);
    cond47=hN.addSignal2('Type',boolean_type,'Name','cond47','SimulinkRate',slRate);
    cond48=hN.addSignal2('Type',boolean_type,'Name','cond48','SimulinkRate',slRate);
    cond49=hN.addSignal2('Type',boolean_type,'Name','cond49','SimulinkRate',slRate);
    cond50=hN.addSignal2('Type',boolean_type,'Name','cond50','SimulinkRate',slRate);
    cond51=hN.addSignal2('Type',boolean_type,'Name','cond51','SimulinkRate',slRate);
    cond52=hN.addSignal2('Type',boolean_type,'Name','cond52','SimulinkRate',slRate);
    cond53=hN.addSignal2('Type',boolean_type,'Name','cond53','SimulinkRate',slRate);
    cond54=hN.addSignal2('Type',boolean_type,'Name','cond54','SimulinkRate',slRate);
    cond55=hN.addSignal2('Type',boolean_type,'Name','cond55','SimulinkRate',slRate);
    cond56=hN.addSignal2('Type',boolean_type,'Name','cond56','SimulinkRate',slRate);

    cond57=hN.addSignal2('Type',boolean_type,'Name','cond57','SimulinkRate',slRate);
    cond58=hN.addSignal2('Type',boolean_type,'Name','cond58','SimulinkRate',slRate);
    cond59=hN.addSignal2('Type',boolean_type,'Name','cond59','SimulinkRate',slRate);

    first_pixel_en=hN.addSignal2('Type',boolean_type,'Name','first_pixel_en','SimulinkRate',slRate);
    first_pixel_en_delay=hN.addSignal2('Type',boolean_type,'Name','first_pixel_en_delay','SimulinkRate',slRate);
    tvalid_not=hN.addSignal2('Type',boolean_type,'Name','tvalid_not','SimulinkRate',slRate);
    freeze=hN.addSignal2('Type',boolean_type,'Name','freeze','SimulinkRate',slRate);
    freeze_delay=hN.addSignal2('Type',boolean_type,'Name','freeze_delay','SimulinkRate',slRate);
    hstart_reg=hN.addSignal2('Type',boolean_type,'Name','hstart_reg','SimulinkRate',slRate);
    hstart_output=hN.addSignal2('Type',boolean_type,'Name','hstart_output','SimulinkRate',slRate);
    nonblank=hN.addSignal2('Type',boolean_type,'Name','nonblank','SimulinkRate',slRate);
    valid_output=hN.addSignal2('Type',boolean_type,'Name','valid_output','SimulinkRate',slRate);

    ready_out_cond1=hN.addSignal2('Type',boolean_type,'Name','read_out_cond1','SimulinkRate',slRate);
    ready_out_cond2=hN.addSignal2('Type',boolean_type,'Name','read_out_cond2','SimulinkRate',slRate);
    ready_out_cond3=hN.addSignal2('Type',boolean_type,'Name','read_out_cond3','SimulinkRate',slRate);
    ready_out_cond4=hN.addSignal2('Type',boolean_type,'Name','read_out_cond4','SimulinkRate',slRate);
    ready_out_cond5=hN.addSignal2('Type',boolean_type,'Name','read_out_cond5','SimulinkRate',slRate);
    ready_out_cond6=hN.addSignal2('Type',boolean_type,'Name','read_out_cond6','SimulinkRate',slRate);
    ready_out_cond8=hN.addSignal2('Type',boolean_type,'Name','read_out_cond8','SimulinkRate',slRate);
    ready_out_output=hN.addSignal2('Type',boolean_type,'Name','read_out_output','SimulinkRate',slRate);
    vend_reg=hN.addSignal2('Type',boolean_type,'Name','vend_reg','SimulinkRate',slRate);
    condition0=hN.addSignal2('Type',boolean_type,'Name','condition0','SimulinkRate',slRate);
    condition1=hN.addSignal2('Type',boolean_type,'Name','condition1','SimulinkRate',slRate);

    pixel_load_value0=hN.addSignal2('Type',pixel_counter_type,'Name','pixel_load_value0','SimulinkRate',slRate);
    pixel_load_value1=hN.addSignal2('Type',pixel_counter_type,'Name','pixel_load_value1','SimulinkRate',slRate);
    pixel_load_value2=hN.addSignal2('Type',pixel_counter_type,'Name','pixel_load_value2','SimulinkRate',slRate);

    hend_output=hN.addSignal2('Type',boolean_type,'Name','hend_output','SimulinkRate',slRate);
    hend_output_temp=hN.addSignal2('Type',boolean_type,'Name','hend_output_temp','SimulinkRate',slRate);
    vstart_output_temp=hN.addSignal2('Type',boolean_type,'Name','vstart_output_temp','SimulinkRate',slRate);


    pixel_constant0=hN.addSignal2('Type',pixel_counter_type,'Name','pixel_constant0','SimulinkRate',slRate);
    pixel_constant1=hN.addSignal2('Type',pixel_counter_type,'Name','pixel_constant1','SimulinkRate',slRate);
    pixel_counter_1=hN.addSignal2('Type',pixel_counter_type,'Name','pixel_counter_1','SimulinkRate',slRate);
    hlength_2=hN.addSignal2('Type',pixel_counter_type,'Name','hlength_2','SimulinkRate',slRate);


    line_load_value0=hN.addSignal2('Type',line_counter_type,'Name','line_load_value0','SimulinkRate',slRate);
    line_load_value1=hN.addSignal2('Type',line_counter_type,'Name','line_load_value1','SimulinkRate',slRate);

    line_constant0=hN.addSignal2('Type',line_counter_type,'Name','line_constant0','SimulinkRate',slRate);
    line_constant1=hN.addSignal2('Type',line_counter_type,'Name','line_constant1','SimulinkRate',slRate);

    data_constant0=hN.addSignal2('Type',data_type,'Name','data_constant0','SimulinkRate',slRate);

    constant_value0_1bit=hN.addSignal2('Type',boolean_type,'Name','constant0','SimulinkRate',slRate);
    constant_value1_1bit=hN.addSignal2('Type',boolean_type,'Name','constant1','SimulinkRate',slRate);
    constant_value2_13bit=hN.addSignal2('Type',porch_type,'Name','constant2','SimulinkRate',slRate);

    vstart_output=hN.addSignal2('Type',boolean_type,'Name','vstart_output','SimulinkRate',slRate);
    vend_output=hN.addSignal2('Type',boolean_type,'Name','vend_output','SimulinkRate',slRate);







    pirelab.getIntDelayComp(hN,inSigs(5),numofpixels,1,'numofpixels',false,0,0,[],0,0);
    pirelab.getIntDelayComp(hN,inSigs(6),numoflines,1,'numoflines',false,0,0,[],0,0);

    pirelab.getAddComp(hN,[inSigs(5),inSigs(7)],hlength_buf,'Floor','Wrap','Hlength_buf',[],'++');
    pirelab.getAddComp(hN,[inSigs(6),inSigs(8)],vlength_buf,'Floor','Wrap','Vlength_buf',[],'++');
    pirelab.getIntDelayComp(hN,hlength_buf,hlength,1,'hlength',false,0,0,[],0,0);
    pirelab.getIntDelayComp(hN,vlength_buf,vlength,1,'vlength',false,0,0,[],0,0);


    pirelab.getConstComp(hN,constant_value0_1bit,false,'Constant_value0_1bit');
    pirelab.getConstComp(hN,constant_value1_1bit,true,'Constant_value1_1bit');
    pirelab.getConstComp(hN,constant_value2_13bit,double(2),'constant_value2_13bit');


    pirelab.getWireComp(hN,inSigs(2),tvalid,'tvalid');
    pirelab.getWireComp(hN,inSigs(3),sof,'sof');
    pirelab.getWireComp(hN,inSigs(4),eol,'eol');

    pirelab.getIntDelayComp(hN,inSigs(1),data_reg,1,'input_data_delay',false,0,0,[],0,0);
    pirelab.getMultiPortSwitchComp(hN,[tvalid,data_buf_delay,inSigs(1)],data_buf,1,'Zero-based contiguous','Floor','Wrap','Switch5',[]);
    pirelab.getIntDelayComp(hN,data_buf,data_buf_delay,1,'data_buf_delay',false,0,0,[],0,0);

    pirelab.getIntDelayComp(hN,tvalid,valid_reg,1,'valid_reg_delay',false,0,0,[],0,0);

    pirelab.getLogicComp(hN,[eol,tvalid],eol_tvalid,'and','and27');
    pirelab.getIntDelayComp(hN,eol_tvalid,eol_buf,1,'eol_buf_delay',false,0,0,[],0,0);



    pirelab.getRelOpComp(hN,[line_counter,numoflines],cond0,'<',0,'equal12_');
    pirelab.getLogicComp(hN,[eol,tvalid,cond0],cond1,'and','and15');
    pirelab.getMultiPortSwitchComp(hN,[cond1,cond2,constant_value0_1bit],first_pixel_en,1,'Zero-based contiguous','Floor','Wrap','Switch14',[]);

    pirelab.getIntDelayComp(hN,first_pixel_en,first_pixel_en_delay,1,'Delay8',false,0,0,[],0,0);
    pirelab.getMultiPortSwitchComp(hN,[tvalid,first_pixel_en_delay,constant_value1_1bit],cond2,1,'Zero-based contiguous','Floor','Wrap','Switch19',[]);



    pirelab.getRelOpComp(hN,[line_counter,numoflines],cond4,'<',0,'equal1');

    pirelab.getLogicComp(hN,tvalid,tvalid_not,'not','tvalid_not');
    pirelab.getLogicComp(hN,[eol_buf,tvalid_not,cond4],cond3,'and','and1');

    pirelab.getMultiPortSwitchComp(hN,[cond3,cond5,constant_value1_1bit],freeze,1,'Zero-based contiguous','Floor','Wrap','Switch1',[]);

    pirelab.getIntDelayComp(hN,freeze,freeze_delay,1,'Delay9',false,0,0,[],0,0);
    pirelab.getMultiPortSwitchComp(hN,[tvalid,freeze_delay,constant_value0_1bit],cond5,1,'Zero-based contiguous','Floor','Wrap','Switch20',[]);



    pirelab.getLogicComp(hN,[sof,tvalid],hstart_reg,'and','and2');



    pirelab.getRelOpComp(hN,[line_counter,numoflines],cond8,'<=',0,'equal4_');
    pirelab.getCompareToValueComp(hN,pixel_counter,cond7,'==',double(1),'equal3',0);
    pirelab.getLogicComp(hN,[cond7,cond8,tvalid],cond9,'and','and3');

    pirelab.getCompareToValueComp(hN,line_counter,cond6,'==',double(1),'equal2',0);

    pirelab.getIntDelayComp(hN,hstart_reg,cond10,1,'Delay10',false,0,0,[],0,0);
    pirelab.getMultiPortSwitchComp(hN,[cond6,cond9,cond10],hstart_output,1,'Zero-based contiguous','Floor','Wrap','Switch2',[]);



    pirelab.getCompareToValueComp(hN,pixel_counter,cond11,'>',double(0),'equa5',0);
    pirelab.getRelOpComp(hN,[pixel_counter,numofpixels],cond12,'<=',0,'equa7');
    pirelab.getCompareToValueComp(hN,line_counter,cond13,'>',double(0),'equa6',0);
    pirelab.getRelOpComp(hN,[line_counter,numoflines],cond14,'<=',0,'equa8');

    pirelab.getLogicComp(hN,[cond11,cond12,cond13,cond14],nonblank,'and','and4');



    pirelab.getRelOpComp(hN,[vlength,numoflines],cond15,'~=',0,'equal14');

    pirelab.getRelOpComp(hN,[hlength,numofpixels],cond16,'~=',0,'equal13');

    pirelab.getLogicComp(hN,[cond15,cond16],cond19,'or','and9');
    pirelab.getRelOpComp(hN,[line_counter,vlength],cond18,'==',0,'equa11');
    pirelab.getRelOpComp(hN,[pixel_counter,hlength],cond17,'==',0,'equa10');

    pirelab.getLogicComp(hN,[cond17,cond18,cond19],cond20,'and','and6');

    pirelab.getLogicComp(hN,[valid_reg,nonblank],cond23,'and','and8');

    pirelab.getMultiPortSwitchComp(hN,[cond21,cond23,constant_value0_1bit],cond57,1,'Zero-based contiguous','Floor','Wrap','Switch21',[]);

    pirelab.getMultiPortSwitchComp(hN,[cond20,cond57,valid_reg],cond25,1,'Zero-based contiguous','Floor','Wrap','Switch4',[]);

    pirelab.getCompareToValueComp(hN,pixel_counter,cond21,'==',double(1),'equal9',0);

    pirelab.getCompareToValueComp(hN,line_counter,cond58,'~=',double(1),'equal27',0);

    pirelab.getLogicComp(hN,[cond21,tvalid,cond58],cond22,'and','and5');
    pirelab.getMultiPortSwitchComp(hN,[cond22,cond25,constant_value1_1bit],cond59,1,'Zero-based contiguous','Floor','Wrap','Switch3',[]);

    pirelab.getMultiPortSwitchComp(hN,[vstart_output,cond59,constant_value1_1bit],valid_output,1,'Zero-based contiguous','Floor','Wrap','Switch22',[]);


    pirelab.getCompareToValueComp(hN,line_counter,cond26,'>',double(1),'equa15',0);
    pirelab.getLogicComp(hN,[hstart_output,cond26],cond27,'and','and10');
    pirelab.getIntDelayComp(hN,data_buf,data_buf_delay1,1,'Delay11',false,0,0,[],0,0);

    pirelab.getConstComp(hN,data_constant0,0,'Constant20');
    pirelab.getMultiPortSwitchComp(hN,[valid_output,data_constant0,data_reg],data_reg_temp,1,'Zero-based contiguous','Floor','Wrap','Switch7',[]);

    pirelab.getMultiPortSwitchComp(hN,[cond27,data_reg_temp,data_buf_delay1],data_out_output,1,'Zero-based contiguous','Floor','Wrap','Switch6',[]);



    pirelab.getLogicComp(hN,[sof,tvalid],ready_out_cond1,'and','and12');

    pirelab.getCompareToValueComp(hN,pixel_counter,ready_out_cond2,'==',double(0),'equa16',0);

    pirelab.getRelOpComp(hN,[line_counter,numoflines],cond29,'<',0,'equa18');
    pirelab.getRelOpComp(hN,[pixel_counter,hlength],cond28,'==',0,'equa17');
    pirelab.getLogicComp(hN,[cond28,cond29],ready_out_cond3,'and','and13');

    pirelab.getRelOpComp(hN,[line_counter,numoflines],cond31,'<=',0,'equa20');
    pirelab.getSubComp(hN,[numofpixels,constant_value1_1bit],pixel_counter_1,'Floor','Wrap','pixel_counter_sub_1');
    pirelab.getRelOpComp(hN,[pixel_counter,pixel_counter_1],cond30,'<',0,'equa19');
    pirelab.getLogicComp(hN,[cond30,cond31],ready_out_cond4,'and','and14');

    pirelab.getRelOpComp(hN,[line_counter,numoflines],cond33,'<',0,'equa22');
    pirelab.getRelOpComp(hN,[pixel_counter,pixel_counter_1],cond32,'==',0,'equa21');
    pirelab.getLogicComp(hN,[cond32,cond33],ready_out_cond5,'and','and16');

    pirelab.getRelOpComp(hN,[line_counter,vlength],cond34,'==',0,'equa23');
    pirelab.getRelOpComp(hN,[pixel_counter,hlength],cond35,'<=',0,'equa24');
    pirelab.getSubComp(hN,[hlength,constant_value2_13bit],hlength_2,'Floor','Wrap','hlength_sub_2');
    pirelab.getRelOpComp(hN,[pixel_counter,hlength_2],cond36,'>',0,'equal25');
    pirelab.getLogicComp(hN,[cond34,cond35,cond36],ready_out_cond6,'and','and17');









    pirelab.getLogicComp(hN,[cond32,cond37,tvalid_not],ready_out_cond8,'and','and7');

    pirelab.getLogicComp(hN,[ready_out_cond1,ready_out_cond2,ready_out_cond3,ready_out_cond4,ready_out_cond5,ready_out_cond6,freeze,ready_out_cond8],ready_out_output,'or','ready_out_output');



    pirelab.getRelOpComp(hN,[line_counter,numoflines],cond37,'==',0,'equa26');
    pirelab.getLogicComp(hN,[eol,tvalid,cond37],vend_reg,'and','and18');



    pirelab.getRelOpComp(hN,[pixel_counter,hlength],cond39,'==',0,'equa29');
    pirelab.getRelOpComp(hN,[line_counter,vlength],cond38,'==',0,'equa28');
    pirelab.getLogicComp(hN,[cond38,cond39],condition0,'and','and23');



    pirelab.getRelOpComp(hN,[pixel_counter,hlength],cond40,'==',0,'equa31');
    pirelab.getLogicComp(hN,[cond40,first_pixel_en],condition1,'and','and24');





    pirelab.getMultiPortSwitchComp(hN,[condition1,constant_value0_1bit,constant_value1_1bit],cond42,1,'Zero-based contiguous','Floor','Wrap','Switch13',[]);

    pirelab.getMultiPortSwitchComp(hN,[condition0,cond42,constant_value1_1bit],cond43,1,'Zero-based contiguous','Floor','Wrap','Switch11',[]);

    pirelab.getLogicComp(hN,[sof,tvalid],cond41,'and','and19');

    pirelab.getMultiPortSwitchComp(hN,[cond41,cond43,constant_value1_1bit],cond44,1,'Zero-based contiguous','Floor','Wrap','Switch9',[]);



    pirelab.getConstComp(hN,pixel_constant0,0,'Constant33');
    pirelab.getConstComp(hN,pixel_constant1,1,'Constant34');

    pirelab.getMultiPortSwitchComp(hN,[condition1,pixel_constant0,pixel_constant1],pixel_load_value0,1,'Zero-based contiguous','Floor','Wrap','Switch15',[]);

    pirelab.getMultiPortSwitchComp(hN,[condition0,pixel_load_value0,pixel_constant0],pixel_load_value1,1,'Zero-based contiguous','Floor','Wrap','Switch12',[]);

    pirelab.getMultiPortSwitchComp(hN,[cond41,pixel_load_value1,pixel_constant1],pixel_load_value2,1,'Zero-based contiguous','Floor','Wrap','Switch10',[]);



    pirelab.getCompareToValueComp(hN,pixel_counter,cond45,'>',double(0),'equa27',0);
    pirelab.getRelOpComp(hN,[line_counter,numoflines],cond46,'<=',0,'less');
    pirelab.getRelOpComp(hN,[pixel_counter,numofpixels],cond47,'<',0,'less1');
    pirelab.getLogicComp(hN,[cond45,cond46,cond47,tvalid],cond48,'and','and21');

    pirelab.getRelOpComp(hN,[pixel_counter,hlength],cond49,'<',0,'less2');
    pirelab.getRelOpComp(hN,[pixel_counter,numofpixels],cond50,'>=',0,'larger');
    pirelab.getLogicComp(hN,[cond49,cond50],cond51,'and','and22');

    pirelab.getRelOpComp(hN,[line_counter,numoflines],cond52,'>',0,'larger1');

    pirelab.getLogicComp(hN,[cond48,cond51,cond52],cond53,'or','or_gate');


    pirelab.getCounterComp(hN,[cond44,pixel_load_value2,cond53],pixel_counter,'Count limited',0,1,double(4096),0,1,1,0,'obj_pixel_counter');



    pirelab.getLogicComp(hN,[eol,tvalid],hend_output_temp,'and','and25');
    pirelab.getIntDelayComp(hN,hend_output_temp,hend_output,1,'hend_output_delay',false,0,0,[],0,0);



    pirelab.getLogicComp(hN,[sof,tvalid],vstart_output_temp,'and','and26');
    pirelab.getIntDelayComp(hN,vstart_output_temp,vstart_output,1,'vstart_output_delay',false,0,0,[],0,0);



    pirelab.getIntDelayComp(hN,vend_reg,vend_output,1,'vend_output_delay',false,0,0,[],0,0);



    pirelab.getLogicComp(hN,[sof,tvalid],cond54,'and','and20');


    pirelab.getMultiPortSwitchComp(hN,[condition0,constant_value0_1bit,constant_value1_1bit],cond55,1,'Zero-based contiguous','Floor','Wrap','Switch17',[]);

    pirelab.getMultiPortSwitchComp(hN,[cond54,cond55,constant_value1_1bit],cond56,1,'Zero-based contiguous','Floor','Wrap','Switch8',[]);



    pirelab.getConstComp(hN,line_constant0,0,'Constant57');
    pirelab.getConstComp(hN,line_constant1,1,'Constant54');
    pirelab.getMultiPortSwitchComp(hN,[condition0,line_constant0,line_constant0],line_load_value0,1,'Zero-based contiguous','Floor','Wrap','Switch18',[]);

    pirelab.getMultiPortSwitchComp(hN,[cond54,line_load_value0,line_constant1],line_load_value1,1,'Zero-based contiguous','Floor','Wrap','Switch16',[]);


    pirelab.getCounterComp(hN,[cond56,line_load_value1,condition1],line_counter,'Count limited',0,1,double(2160),0,1,1,0,'obj_pixel_count',0);


    pirelab.getIntDelayComp(hN,data_out_output,outSigs(1),1,'data_out',false,0,0,[],0,0);
    pirelab.getIntDelayComp(hN,hstart_output,outSigs(2),1,'hstart',false,0,0,[],0,0);
    pirelab.getIntDelayComp(hN,hend_output,outSigs(3),1,'hend',false,0,0,[],0,0);
    pirelab.getIntDelayComp(hN,vstart_output,outSigs(4),1,'vstart',false,0,0,[],0,0);
    pirelab.getIntDelayComp(hN,vend_output,outSigs(5),1,'vend',false,0,0,[],0,0);
    pirelab.getIntDelayComp(hN,valid_output,outSigs(6),1,'valid',false,0,0,[],0,0);

    pirelab.getWireComp(hN,ready_out_output,outSigs(7),'ready_out');

    nComp=pirelab.instantiateNetwork(hNTop,hN,InputPortSignals,OutputPortSignals,hN.Name);

end




