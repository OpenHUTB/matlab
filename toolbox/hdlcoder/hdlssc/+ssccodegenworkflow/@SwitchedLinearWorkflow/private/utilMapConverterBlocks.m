function[inputMap,outputMap]=utilMapConverterBlocks(dynamicSystem,spsBlks,pssBlks)





    inputMap=cell(numel(spsBlks),2);
    for ii=1:numel(spsBlks)


        inputMap{ii,1}=spsBlks{ii};
        inputMap{ii,2}={ii,dynamicSystem.Input(ii).Name,dynamicSystem.Input(ii).Dimension};
    end




    outputMap=cell(numel(pssBlks),2);
    for ii=1:numel(pssBlks)


        outputMap{ii,1}=pssBlks{ii};
        outputMap{ii,2}={ii,dynamicSystem.Output(ii).Name,dynamicSystem.Output(ii).Dimension};
    end

end


