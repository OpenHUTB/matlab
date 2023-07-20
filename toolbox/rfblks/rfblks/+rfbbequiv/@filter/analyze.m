function h=analyze(h,block)







    transf=localfreqresp(h,block);


    [resp,delay]=response(h,transf);
    set(h,'ImpulseResp',resp,'Delay',delay);