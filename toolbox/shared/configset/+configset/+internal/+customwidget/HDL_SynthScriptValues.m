function out=HDL_SynthScriptValues(cs,name,direction,widgetVals)









    if isa(cs,'Simulink.ConfigSet')
        hObj=cs.getComponent('HDL Coder');
    else
        hObj=cs;
    end



    edasSubcomp=hObj.getsubcomponent('hdlcoderui.hdledas');



    switch name
    case 'HDLSynthFilePostfix'
        cliName='SynScriptPostFix';
    case 'HDLSynthInit'
        cliName='SynScriptInit';
    case 'HDLSynthCmd'
        cliName='SynScriptCmd';
    case 'HDLSynthTerm'
        cliName='SynScriptTerm';
    end


    cli=hObj.getCLI;

    synthTool=cli.HDLSynthTool;



    switch synthTool
    case 'None'
        fName=cliName;
    case 'Vivado'
        fName=[cliName,'_V'];
    case 'ISE'
        fName=[cliName,'_I'];
    case 'Libero'
        fName=[cliName,'_L'];
    case 'Precision'
        fName=[cliName,'_P'];
    case 'Quartus'
        fName=[cliName,'_Q'];
    case 'Synplify'
        fName=[cliName,'_S'];
    case 'Custom'
        fName=[cliName,'_C'];
    end

    if direction==0
        val=edasSubcomp.(fName);
        out={val};

    elseif direction==1
        out=widgetVals{1};
        edasSubcomp.(fName)=out;
    end
end


