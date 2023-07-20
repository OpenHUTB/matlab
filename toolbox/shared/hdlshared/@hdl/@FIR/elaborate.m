function elaborate(this)





    hN=this.hN;
    slrate=this.slrate;



    delayOrder=true;
    includeCurrent=true;
    pirelab.getTapDelayComp(hN,this.datain,this.data_pipe,this.length-1,...
    this.pipeline_processname,0,delayOrder,includeCurrent);
















    hTProd=hN.getType('FixedPoint','Signed',this.product_type(3),...
    'WordLength',this.product_type(1),'FractionLength',-1*this.product_type(2));
    firmult=hdl.spblkmultiply(...
    'in1',this.data_pipe,...
    'in2',this.taps,...
    'outname','filter_products',...
    'product_sltype',hTProd,...
    'accumulator_sltype',this.filterout.Type,...
    'rounding',this.product_mode{1},...
    'saturation',this.product_mode{2},...
    'hN',hN,...
    'slrate',this.slrate...
    );

    firmult.elaborate;
    this.tap_products=get(firmult,'out');















    [inWL,inFL,inSIGN]=hdlwordsize(hdlsignalsltype(this.tap_products));
    [outWL,outFL,outSIGN]=hdlwordsize(hdlsignalsltype(this.filterout));


    impl=this.adder_implementation;
    if strcmpi(impl,'try_tree')

        bitgrowth=ceil(log2(this.length));
        if(inSIGN==outSIGN)&&(inFL==outFL)&&(outWL>=(inWL+bitgrowth))...

            impl='tree';
        else
            impl='linear';
        end
    end

    if~hdlsignaliscomplex(this.tap_products)




        if strcmpi(impl,'tree')
            addComp=pirelab.getTreeArch(hN,this.tap_products,this.filterout,'sum',...
            this.adder_mode{1},this.adder_mode{2},'fir_add_tree');


        else
            addComp=pirelab.getAddComp(hN,this.tap_products,this.filterout,...
            this.adder_mode{1},this.adder_mode{2},'fir_add',this.filterout.Type,'+');
        end
    else
        vecSize=this.tap_products.Type.Dimensions;
        hTtap=this.tap_products.Type.BaseType.BaseType;
        hTVec=pirelab.createPirArrayType(hTtap,vecSize);
        tap_products_re=hN.addSignal2('Type',hTVec,'Name',[this.tap_products.Name,'_re'],...
        'SimulinkRate',slrate);
        tap_products_im=hN.addSignal2('Type',hTVec,'Name',[this.tap_products.Name,'_im'],...
        'SimulinkRate',slrate);
        pirelab.getComplex2RealImag(hN,this.tap_products,[tap_products_re,tap_products_im]);

        hTout=this.filterout.Type.BaseType;
        filterout_re=hN.addSignal2('Type',hTout,'Name',[this.filterout.Name,'_re'],...
        'SimulinkRate',slrate);
        filterout_im=hN.addSignal2('Type',hTout,'Name',[this.filterout.Name,'_im'],...
        'SimulinkRate',slrate);
        if strcmpi(impl,'tree')
            addComp=pirelab.getAddTreeComp(hN,tap_products_re,filterout_re,...
            this.adder_mode{1},this.adder_mode{2});
            pirelab.getAddTreeComp(hN,tap_products_im,filterout_im,...
            this.adder_mode{1},this.adder_mode{2});
        else
            addComp=pirelab.getAddComp(hN,tap_products_re,filterout_re,...
            this.adder_mode{1},this.adder_mode{2},'fir_add_re',filterout_re.Type,'+');
            pirelab.getAddComp(hN,tap_products_im,filterout_im,...
            this.adder_mode{1},this.adder_mode{2},'fir_add_im',filterout_im.Type,'+');
        end

        pirelab.getRealImag2Complex(hN,[filterout_re,filterout_im],this.filterout);
    end
    addComp.addComment([impl,' sum of filter products']);


