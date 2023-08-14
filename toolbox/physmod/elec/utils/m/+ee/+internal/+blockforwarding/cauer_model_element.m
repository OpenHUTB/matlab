function out=cauer_model_element(in)










    out=in;


    blockName=strrep(gcb,newline,' ');
    pm_warning('physmod:ee:library:CauerRportRemoved',blockName);


end