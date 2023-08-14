function emlrtWarnFromDestructor(rtmessage)




    msgstruct=coder.internal.buildMsgStruct(rtmessage);

    oldBtMode=warning('backtrace').state;
    warning('off','backtrace');

    stackFrame=msgstruct.stack(1);
    msg=message('Coder:builtins:ErrorThrownFromDestructorWithLangTargetCpp',...
    stackFrame.name,stackFrame.line,msgstruct.message);
    warning(msg);

    warning(oldBtMode,'backtrace');
