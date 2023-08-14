function serdes(obj)






    if isReleaseOrEarlier(obj.ver,'R2018b')




        blocks=Simulink.findBlocks(obj.modelName,'ReferenceBlock','serdesUtilities/Configuration');
        if~isempty(blocks)
            obj.reportWarning('serdes:simulink:NotSupportedBefore19a');
        end
    end