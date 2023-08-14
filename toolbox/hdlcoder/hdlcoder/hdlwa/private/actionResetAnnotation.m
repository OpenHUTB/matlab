function result=actionResetAnnotation(taskobj)

    try
        hdlannotatepath('reset');
    catch me

        Failed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGFailed'),{'Fail'});
        text=ModelAdvisor.Text([Failed.emitHTML,me.message]);
        result=text.emitHTML;

        return;
    end

    Passed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGPassed'),{'Pass'});
    result=Passed.emitHTML;
