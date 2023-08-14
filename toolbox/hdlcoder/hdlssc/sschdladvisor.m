function sschdladvisor(sys)







    if nargin~=1
        error(message('hdlcoder:hdlssc:ssccodegenadvisor:IncorrectInputArguments'));
    else
        if ishandle(sys)
            sys=bdroot(getfullname(sys));
        end
        if isstring(sys)
            sys=convertStringsToChars(sys);
        end

        topModel=strtok(sys,'/');

        if~isvarname(topModel)
            error(message('Simulink:utility:InvalidBlockDiagramName'));
        end
        if~bdIsLoaded(topModel)
            load_system(topModel);
        end

        hyperlinkToModel=ssccodegenutils.createHyperlink(['(',topModel,')'],topModel);
        dispStr=['### Running Simscape HDL Workflow Advisor for ',hyperlinkToModel];
        disp(dispStr);


        sschdlWorkflowObj=ssccodegenworkflow.SwitchedLinearWorkflow(topModel);

        sschdlAdvisorObj=Simulink.ModelAdvisor.getModelAdvisor(topModel,'new','com.mathworks.hdlssc.ssccodegenadvisor.sscCodeGenAdvisorProcedure');

        sschdlWorkflowObjCheck=sschdlAdvisorObj.getCheckObj('com.mathworks.hdlssc.ssccodegenadvisor.workflowObjectCheck');
        sschdlWorkflowObjCheck.ResultData=sschdlWorkflowObj;


        sschdlWorkflowObjCheck.InputParameters{end+1}=struct;


        sschdlAdvisorTaskObj=sschdlAdvisorObj.getTaskObj('com.mathworks.hdlssc.ssccodegenadvisor.sscCodeGenAdvisorProcedure');
        sschdlAdvisorTaskObjChildren=sschdlAdvisorTaskObj.getAllChildren;
        for ii=1:numel(sschdlAdvisorTaskObjChildren)
            sschdlAdvisorTaskObjChildren{ii}.reset;
        end


        customObj=ModelAdvisor.Customization;

        customObj.MenuHelp.Text=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor:ssccgaRootHelp');
        customObj.MenuHelp.Callback='helpview([docroot,''/hdlcoder/csh/ssccga.map''],''ssccga_help_button'');';
        customObj.MenuAbout.Text=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor:ssccgaAbout');
        customObj.MenuAbout.Callback='privhdladvisor(''aboutslhdlcoder'');';

        customObj.MenuSettings.Visible=false;
        sschdlAdvisorObj.CustomObject=customObj;


        sschdlAdvisorObj.displayExplorer;

        advisorName=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_procedures:sscCodeGenAdvisorProcedureDisplayName');
        modelAdvisorName=DAStudio.message('Simulink:ModelAdvisor:ModelAdvisorDummyMessage');
        sschdlAdvisorObj.MAExplorer.title=regexprep(sschdlAdvisorObj.MAExplorer.title,['^',modelAdvisorName],advisorName);




        sschdlAdvisorObj.MEMenus.loadSnapShot.visible='off';

        sschdlAdvisorObj.MEMenus.saveSnapshot.visible='off';

        sschdlAdvisorObj.MEMenus.quicksaveSnapshot.visible='off';

        sschdlAdvisorObj.MEMenus.Find.visible='off';

        sschdlAdvisorObj.MEMenus.s_treatasmdlref.visible='off';

        sschdlAdvisorObj.MEMenus.M_popupOption.visible='off';




        sschdlAdvisorObj.Toolbar.findPrompt.setVisible(false);
        sschdlAdvisorObj.Toolbar.filterCriteriaComboBoxWidget.setVisible(false);

        sschdlAdvisorObj.Toolbar.E_select1.visible='off';
        sschdlAdvisorObj.Toolbar.E_select2.visible='off';
    end
end
