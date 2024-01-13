function[srcCS,origCS]=getMdlConfigSet(modelH)

    modelObj=get_param(modelH,'Object');
    origCS=modelObj.getActiveConfigSet();
    srcCS=origCS;
    while srcCS.isa('Simulink.ConfigSetRef')
        if~strcmpi(srcCS.SourceResolved,'on')
            srcCS=[];
            return
        end
        srcCS=configset.util.getSource(srcCS);
    end
