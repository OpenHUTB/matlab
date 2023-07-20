function[paramNames,csVals]=getConstantParams(modelName,scmFileName)





    isOk=~isempty(modelName);
    paramNames={};
    csVals={};
    if isOk


        hashTblFileFolder=fileparts(scmFileName);

        hashTblFile=fullfile(hashTblFileFolder,'filemap.mat');

        if exist(hashTblFile,'file')
            load(hashTblFile,'fileMap');
            objKeys=fileMap.keys;
            for idx=1:length(objKeys)
                thisObj=fileMap(objKeys{idx});
                if(strcmp(thisObj.kind,'constpdef'))



                    paramNames{end+1}=thisObj.checkSumName;%#ok
                    cs=fileMap(objKeys{idx}).checksum;
                    csVals{end+1}=[uint32(cs(1)),uint32(cs(2))...
                    ,uint32(cs(3)),uint32(cs(4))];%#ok
                end
            end
        end
    end

end


