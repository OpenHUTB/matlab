function execute(obj)
    obj.addHeadItem('<script language="JavaScript" type="text/javascript" src="rtwshrink.js"></script>');


    [tflList,tflName]=obj.getLibraryContents;
    p=ModelAdvisor.Paragraph;
    contents=ModelAdvisor.Text(DAStudio.message('CoderFoundation:report:CodeReplacementLibraryList',tflName));
    p.addItem(contents);
    if~isempty(tflList)
        p.addItem(tflList);
    end
    obj.addItem(p);


    instructionSetString=obj.getInstructionSetString;
    if~isempty(instructionSetString)&&~isempty(instructionSetString.Items)
        p=ModelAdvisor.Paragraph;
        contents=ModelAdvisor.Text(message(...
        'CoderFoundation:report:InstructionSetExtensionsList').getString);
        p.addItem(contents);
        p.addItem(instructionSetString);
        obj.addItem(p);
    end

    cmd=['matlab: rtwprivate invokeViewerForReport ''',obj.ModelName,''' ''',obj.LibName,''''];
    alink=Simulink.report.ReportInfo.getMatlabCallHyperlink(cmd);
    p=ModelAdvisor.Paragraph;
    contents=ModelAdvisor.Text(DAStudio.message('CoderFoundation:report:CodeReplacementLibraryViewer',alink{1},alink{2}));
    p.addItem(contents);
    obj.addItem(p);
    obj.addCodeReplacementSection;
end
