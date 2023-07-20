


function reloadTable(obj,codeLanguage,file)


    obj.saveCurrentData();


    obj.setCurrentFile(file);

    obj.setCodeLanguage(codeLanguage);


    if isKey(obj.fData,file)
        data=obj.fData(file);
        obj.setCurrentData(data);

        msgData=values(data);


        obj.sendData('reloadData',msgData);

        obj.updateCodeViewAnnotation(codeLanguage,data);
    else


        obj.reloadData();
    end

end
