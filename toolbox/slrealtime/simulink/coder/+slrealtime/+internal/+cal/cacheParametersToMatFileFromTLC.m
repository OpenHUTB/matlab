function ret=cacheParametersToMatFileFromTLC(fileName,parametersFromTLC,coderTypesFileNames)








    matObj=matfile(fileName,'Writable',true);
    coderTypesFileNames=cellstr(coderTypesFileNames);
    coderTypesFileNames=coderTypesFileNames(:)';
    matObj.CoderTypesFileNames=coderTypesFileNames;
    if parametersFromTLC.NumParameters==0
        matObj.Parameters=[];
    elseif parametersFromTLC.NumParameters==1
        matObj.Parameters=parametersFromTLC.PageSwitchingParameter;
    else
        matObj.Parameters=[parametersFromTLC.PageSwitchingParameter{:}];
    end
    ret=true;
end