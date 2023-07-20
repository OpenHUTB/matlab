function invariantTBParams=logInvariantTBParams(this)












    if this.CodeGenSuccessful
        invariantTBParams.target_language=this.getParameter('target_language');
        invariantTBParams.use_single_library=this.getParameter('use_single_library');
        invariantTBParams.vhdl_library_name=this.getParameter('vhdl_library_name');
        invariantTBParams.simulationtool=this.getParameter('simulationtool');
    else
        invariantTBParams=[];
    end
end

