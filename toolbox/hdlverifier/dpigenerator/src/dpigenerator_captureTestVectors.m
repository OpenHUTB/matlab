function dpigenerator_captureTestVectors(tbdir,tbobj)


    dpigenerator_disp('Running Simulink simulation to capture inputs and expected outputs')
    tbobj.genVectors;
    tbobj.saveToMatFile('DPI input vectors',tbdir);
