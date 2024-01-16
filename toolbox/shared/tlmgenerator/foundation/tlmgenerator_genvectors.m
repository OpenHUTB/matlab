function tlmgenerator_genvectors(subsysPath,subsysName,tbDir)

    savedDir=pwd;

    try
        tbobj=tlmg.TLMTestbench(subsysPath,subsysName);
        numVectors=tbobj.genVectors();%#ok<NASGU>
        cd(tbDir);
        tbobj.saveToMatFile('original Simulink signal log');
        tbobj.saveToMatFile('TLM input vectors');

    catch ME
        cd(savedDir);
        rethrow(ME);
    end

    cd(savedDir);

end
