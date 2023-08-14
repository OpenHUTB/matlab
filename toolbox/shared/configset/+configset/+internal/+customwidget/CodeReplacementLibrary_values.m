function out=CodeReplacementLibrary_values(cs,~,direction,widgetVals)






    if direction==0
        valueString=cs.get_param('CodeReplacementLibrary');


        if~isempty(valueString)&&~strcmpi(valueString,'none')&&slfeature('ConfigsetDDUX')==1
            dH=cs.getDialogHandle;
            if(isa(dH,'DAStudio.Dialog'))
                htmlView=dH.getDialogSource;
                data=struct;
                data.paramName='CodeReplacementLibrary';
                data.paramValue=valueString;
                data.widgetType='ddg';
                htmlView.publish('sendToDDUX',data);
            end
        end

        tr=RTW.TargetRegistry.get;
        valueArray=coder.internal.getCrlLibraries(valueString);
        len=length(valueArray);
        firstLibName=valueArray{1};
        try

            if~strcmp(firstLibName,'None')
                firstLibName=coder.internal.getTfl(tr,firstLibName).Name;
            end
        catch

        end

        if len>1
            newValueString=[firstLibName,'...'];
        else
            newValueString=firstLibName;
        end
        out={newValueString,newValueString,'',''};
    elseif direction==1
        out=widgetVals{1};
    end

