function v=validateBlock(this,hC)


    v=hdlvalidatestruct;

    bfp=hC.SimulinkHandle;



    insigs=hC.SLInputSignals;








    outport=hC.SLOutputPorts;





    outsig=outport(1).Signal;
    outsig_size=hdlsignalsizes(outsig);
    if(outsig_size(3)&&outsig_size(1)==0&&outsig_size(2)==0),
        v(end+1)=hdlvalidatestruct(1,...
        message('dsp:hdl:NCO:validateBlock:doubleoutput'));
    end


...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...


    hasdith=strcmp(get_param(bfp,'HasDither'),'on');
    accincsrc=get_param(bfp,'AccIncSrc');
    if strcmpi(accincsrc,'Specify via dialog')
        accinc=this.hdlslResolve('AccInc',bfp);
    else
        accinc=[];
    end
    accWL=this.hdlslResolve('AccumWL',bfp);
    acc_quantWL=this.hdlslResolve('TableDepth',bfp);
    quant=strcmp(get_param(bfp,'HasPhaseQuantizer'),'on');







    if hasdith==1,
        if(strcmpi(accincsrc,'Input Port')&&hdlissignaltype(insigs(1),'vector'))||...
            (~strcmpi(accincsrc,'Input Port')&&~isscalar(accinc)),
            v(end+1)=hdlvalidatestruct(1,...
            message('dsp:hdl:NCO:validateBlock:vectorinputdither'));
        end
    end


    if(quant&&acc_quantWL<4),
        v(end+1)=hdlvalidatestruct(1,...
        message('dsp:hdl:NCO:validateBlock:lutissue'));
    elseif(accWL<4),
        v(end+1)=hdlvalidatestruct(1,...
        message('dsp:hdl:NCO:validateBlock:lutissue'));
    end


    v(end+1)=hdlvalidatestruct(2,...
    message('dsp:hdl:NCO:validateBlock:deprecateHDLSupport'));


