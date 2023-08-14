function h=getexplorer


    daRoot=DAStudio.Root;
    h=daRoot.find('-isa','TflDesigner.explorer');



    if~ishandle(h)
        h=[];
    end

