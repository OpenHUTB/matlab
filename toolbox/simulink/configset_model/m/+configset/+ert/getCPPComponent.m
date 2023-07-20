function h=getCPPComponent(hSrc)




    h=[];

    try
        h=hSrc.getComponent('CPPClassGenComp');
    catch
        h=[];
    end

