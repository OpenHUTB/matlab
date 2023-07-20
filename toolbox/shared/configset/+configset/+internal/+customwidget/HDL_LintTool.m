function out=HDL_LintTool(cs,~,direction,widgetVals)









    if isa(cs,'Simulink.ConfigSet')
        hObj=cs.getComponent('HDL Coder');
    else
        hObj=cs;
    end



    edasSubcomp=hObj.getsubcomponent('hdlcoderui.hdledas');



    if direction==0
        out={edasSubcomp.LintToolOption};
    elseif direction==1
        out=widgetVals{1};
        edasSubcomp.LintToolOption=out;
    end
end


