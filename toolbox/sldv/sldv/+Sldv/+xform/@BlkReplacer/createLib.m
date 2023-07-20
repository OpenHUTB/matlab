function createLib(modelH,libName,libfullPath)




    hLib=Sldv.new_system(libName,'Library');

    save_system(hLib,libfullPath);
    set_param(hLib,'Dirty','on');
    tmploc=get_param(modelH,'location');
    set_param(hLib,'location',[tmploc(1),(tmploc(2)+tmploc(4))/2,...
    tmploc(3),tmploc(4)+(tmploc(4)-tmploc(2))/2]);
end