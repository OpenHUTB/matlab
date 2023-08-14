function out=HDL_LintScriptValues(cs,name,direction,widgetVals)









    if isa(cs,'Simulink.ConfigSet')
        hObj=cs.getComponent('HDL Coder');
    else
        hObj=cs;
    end


    cli=hObj.getCLI;

    edasSubcomp=hObj.getsubcomponent('hdlcoderui.hdledas');
    lintTool=cli.HDLLintTool;



    switch lintTool
    case 'None'
        fName=name;
    case 'AscentLint'
        fName=[name,'_A'];
    case 'HDLDesigner'
        fName=[name,'_H'];
    case 'Leda'
        fName=[name,'_L'];
    case 'LEDA'
        fName=[name,'_L'];
    case 'SpyGlass'
        fName=[name,'_S'];
    case 'Custom'
        fName=[name,'_C'];
    end

    if direction==0
        val=edasSubcomp.(fName);
        out={val};

    elseif direction==1
        out=widgetVals{1};
        edasSubcomp.(fName)=out;
    end
end


