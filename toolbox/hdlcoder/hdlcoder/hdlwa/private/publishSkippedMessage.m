function[ResultDescription,ResultDetails]=publishSkippedMessage(mdladvObj,message)



    if nargin<2
        if mdladvObj.ActiveCheckID>0
            message=mdladvObj.CheckCellArray{mdladvObj.ActiveCheckID}.Title;
        else
            message='';
        end
    end


    ResultDescription={};
    ResultDetails={};


    Skipped=ModelAdvisor.Text('Skipped',{'Warn'});


    text=ModelAdvisor.Text([Skipped.emitHTML,message]);

    ResultDescription{end+1}=text.emitHTML;
    ResultDetails{end+1}='';
    mdladvObj.setCheckResultStatus(true);
end
