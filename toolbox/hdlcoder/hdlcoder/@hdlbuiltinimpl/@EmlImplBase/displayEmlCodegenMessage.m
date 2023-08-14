function displayEmlCodegenMessage(this,hC)



    slbh=hC.SimulinkHandle;
    blkName=strrep(getfullname(slbh),newline,' ');
    fprintf('Elaborating MATLAB authoring implementation ''%s'' for ''%s''\n',class(this),blkName);
end
