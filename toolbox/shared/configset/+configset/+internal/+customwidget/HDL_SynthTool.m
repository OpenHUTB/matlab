function out=HDL_SynthTool(cs,~,direction,widgetVals)









    if isa(cs,'Simulink.ConfigSet')
        hObj=cs.getComponent('HDL Coder');
    else
        hObj=cs;
    end



    edasSubcomp=hObj.getsubcomponent('hdlcoderui.hdledas');



    if direction==0
        out={edasSubcomp.SynToolOption};
    elseif direction==1
        out=widgetVals{1};
        edasSubcomp.SynToolOption=out;
    end
end


