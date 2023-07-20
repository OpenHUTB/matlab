function link=getHyperlinkToBlockParameter(block,paramName)

    link=Advisor.Text(paramName);

    if contains(block,':')

        model=Simulink.ID.getModel(block);

        block=Simulink.ID.getFullName(block);
    else
        model=bdroot(block);
    end
    link.setHyperlink(['matlab:%20load_system(''',model,''');Simulink.internal.OpenBlockParamsDialog(''',block,''',''',paramName,''');']);

end