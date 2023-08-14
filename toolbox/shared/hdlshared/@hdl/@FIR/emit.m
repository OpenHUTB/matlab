function hdlcode=emit(this)





    body=[];

    pipeline=hdl.tapdelay(...
    'clock',hdlgetcurrentclock,...
    'clockenable',hdlgetcurrentclockenable,...
    'reset',hdlgetcurrentreset,...
    'inputs',this.datain,...
    'outputs',this.data_pipe,...
    'processName',this.pipeline_processname,...
    'resetvalues',0,...
    'nDelays',this.length-1,...
    'delayOrder','Oldest',...
    'includeCurrent','on'...
    );
    hdlcode=pipeline.emit;


    [prod_vtype,prod_sltype]=hdlgettypesfromsizes(this.product_type(1),this.product_type(2),this.product_type(3));
    firmult=hdl.spblkmultiply(...
    'in1',this.data_pipe,...
    'in2',this.taps,...
    'outname','filter_products',...
    'product_sltype',prod_sltype,...
    'accumulator_sltype',hdlsignalsltype(this.filterout),...
    'rounding',this.product_mode{1},...
    'saturation',this.product_mode{2}...
    );
    hdlcode=hdlcodeconcat([hdlcode,firmult.emit()]);
    this.tap_products=get(firmult,'out');















    [inWL,inFL,inSIGN]=hdlwordsize(hdlsignalsltype(this.tap_products));
    [outWL,outFL,outSIGN]=hdlwordsize(hdlsignalsltype(this.filterout));


    impl=this.adder_implementation;
    if strcmpi(impl,'try_tree'),

        bitgrowth=ceil(log2(this.length));
        if(inSIGN==outSIGN)&&(inFL==outFL)&&(outWL>=(inWL+bitgrowth))&&~hdlsignaliscomplex(this.tap_products),
            impl='tree';
        else
            impl='linear';
        end
    end

    body=[body,hdlformatcomment([impl,' sum of filter products']),'\n'];

    body=[body,hdlsumofelements(this.tap_products,this.filterout,...
    this.adder_mode{1},this.adder_mode{2},impl)];

    hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,body];
