

function scb(block)

    splitBlock=strsplit(block,'/');
    CurrentSystem=splitBlock(1);
    CurrentBlock=get_param(block,'name');


    root=sfroot;


    root.set('CurrentSystem',CurrentSystem{1});


    set_param(gcb,'Selected','off');


    root.getCurrentSystem.set('CurrentBlock',CurrentBlock);


    set_param(gcb,'Selected','on');
end