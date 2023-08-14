function out=cauer_model(in)










    out=in;


    blockName=strrep(gcb,newline,' ');
    refPortOption=in.getValue('refPort');
    if~isempty(refPortOption)&&(int32(eval(refPortOption))==int32(simscape.enum.onoff.on))
        pm_warning('physmod:ee:library:CauerRportRemoved',blockName);
    end

end