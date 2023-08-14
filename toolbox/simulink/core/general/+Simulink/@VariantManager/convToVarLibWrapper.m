function vssHandle=convToVarLibWrapper(blockH)





    narginchk(1,1);
    vssHandle=-1;
    if(strcmp(get_param(blockH,'BlockType'),'ModelReference')&&strcmp(get_param(blockH,'Variant'),'on'))
        isLibrary=strcmpi(get_param(bdroot(blockH),'BlockDiagramType'),'library');
        modelHdl=bdroot(blockH);
        fullName=getfullname(blockH);
        if isLibrary&&strcmp(get_param(modelHdl,'Lock'),'on')
            set_param(modelHdl,'Lock','off');
            finishup=onCleanup(@()set_param(modelHdl,'Lock','on'));
        end
        vssHandle=Simulink.VariantManager.convertToVariant(blockH);
        msg=DAStudio.message('Simulink:Variants:ConvertMRVToVariantSuccess',fullName);

        disp(msg);
    end
end


