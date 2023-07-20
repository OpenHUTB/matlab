function isVisible=isSlCovVisible(cs)




    try
        isVisible=cs.getComponent('Simulink Coverage').isVisible;
    catch
        isVisible=false;
    end
