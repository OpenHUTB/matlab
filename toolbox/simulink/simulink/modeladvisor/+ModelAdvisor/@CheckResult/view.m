function view(this)












    if(isempty(this.html))
        web(['text://<b>',DAStudio.message('ModelAdvisor:engine:CmdAPINoHTML'),'</b>']);
    else
        web(['text://','<title>',DAStudio.message('ModelAdvisor:engine:CmdAPIMACheckResult'),'- ',this.system,'</title>','<body><b>',this.checkName,'</b> [CheckID:',this.checkID,']',this.html,'</body>'])
    end
end