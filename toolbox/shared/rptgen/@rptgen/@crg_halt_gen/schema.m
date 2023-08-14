function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'crg_halt_gen',pkgRG.findclass('rptcomponent'));


    rptgen.makeProp(h,'isPrompt','bool',false,...
    getString(message('rptgen:r_crg_halt_gen:confirmPromptMessage')));


    rptgen.makeProp(h,'PromptString','ustring',...
    getString(message('rptgen:r_crg_halt_gen:stopGenerationDefault')),...
    getString(message('rptgen:r_crg_halt_gen:confirmQuestionLabel')));


    rptgen.makeProp(h,'HaltString','ustring',...
    getString(message('rptgen:r_crg_halt_gen:haltGenerationLabel')),...
    getString(message('rptgen:r_crg_halt_gen:haltButtonNameLabel')));


    rptgen.makeProp(h,'ContString','ustring',...
    getString(message('rptgen:r_crg_halt_gen:continueGenerationLabel')),...
    getString(message('rptgen:r_crg_halt_gen:continueButtonNameLabel')));


    rptgen.makeStaticMethods(h,{
    },{
    });