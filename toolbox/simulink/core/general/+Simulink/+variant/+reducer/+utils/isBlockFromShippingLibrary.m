function isShippingBlock=isBlockFromShippingLibrary(block)




    isShippingBlock=false;

    libinfo=Simulink.variant.reducer.utils.getLibInfo(block);


    if~isempty(libinfo)






        [~,isLibSlxUnderML]=arrayfun(@(x)Simulink.loadsave.resolveFile(x.Library,'slx'),libinfo,'UniformOutput',false);
        [~,isLibMdlUnderML]=arrayfun(@(x)Simulink.loadsave.resolveFile(x.Library,'mdl'),libinfo,'UniformOutput',false);
        isUnderMlrootslx=any(Simulink.variant.utils.i_cell2mat(isLibSlxUnderML));
        isUnderMlrootmdl=any(Simulink.variant.utils.i_cell2mat(isLibMdlUnderML));
        isShippingBlock=isUnderMlrootslx||isUnderMlrootmdl;
    end
end


