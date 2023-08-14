function number_of_problems=checkDoc(docname)



































    if builtin('_license_checkout','Simulink_Requirements','quiet')
        error(message('Slvnv:reqmgt:licenseCheckoutFailed'));
    end

    number_of_problems=-1;

    if nargin==0
        [doctype,docname]=promptDoc();
        if isempty(doctype)
            disp 'Action canceled';
            return;
        end

    else
        doctype=resolveType(docname);
        if isempty(doctype)
            error(message('Slvnv:reqmgt:checkDoc:DocType',docname));
        end
    end

    switch doctype
    case 'word'
        checker=rmiref.DocCheckWord(docname);
        number_of_problems=checker.docCheckRun();
    case 'excel'
        checker=rmiref.DocCheckExcel(docname);
        number_of_problems=checker.docCheckRun();
    case 'doors'
        checker=rmiref.DocCheckDoors(docname);
        number_of_problems=checker.docCheckRun();
    otherwise
        fprintf(1,'\nSorry, %s is not supported.\n',doctype);
    end
end

function[type,name]=promptDoc()



    name='';
    while isempty(name)
        reply=input([...
        getString(message('Slvnv:rmiref:Check:writeReport:PleaseChooseType')),newline...
        ,getString(message('Slvnv:rmiref:Check:writeReport:s_x1')),newline...
        ,getString(message('Slvnv:rmiref:Check:writeReport:s_x2')),newline...
        ,getString(message('Slvnv:rmiref:Check:writeReport:s_x3')),newline...
        ,'[1,2,3]? ']);
        if isempty(reply)
            type='';
            return;
        end
        switch reply
        case 1
            type='word';
            reply=input(getString(message('Slvnv:rmiref:Check:writeReport:s_MicrosoftWordDocumentCheck')),'s');
            if isempty(reply)||strcmp(reply,'current')
                name=rmiref.DocCheckWord.getCurrentDoc();
                if~confirmName(name,'word')
                    name='';
                end
            else
                name=rmiref.DocCheckWord.locateDocument(reply);
            end

        case 2
            type='excel';
            reply=input(getString(message('Slvnv:rmiref:Check:writeReport:s_MicrosoftExcelDocumentCheck')),'s');
            if isempty(reply)||strcmp(reply,'current')
                name=rmiref.DocCheckExcel.getCurrentDoc();
                if~confirmName(name,'excel')
                    name='';
                end
            else
                name=rmiref.DocCheckExcel.locateDocument(reply);
            end

        case 3
            if rmidoors.isAppRunning()
                type='doors';
                reply=input(getString(message('Slvnv:rmiref:Check:writeReport:s_DOORSModuleCheckcurrent')),'s');
                if isempty(reply)||strcmp(reply,'current')
                    name=rmiref.DocCheckDoors.getCurrentDoc();
                    if~confirmName(name,'doors')
                        name='';
                    end
                else
                    name=rmiref.DocCheckDoors.locateDocument(reply);
                end
            else
                disp(getString(message('Slvnv:rmiref:Check:writeReport:s_DOORSNotRunningCantCheck')));
                type='';
                return;
            end
        otherwise
            disp(getString(message('Slvnv:rmiref:Check:writeReport:s_InvalidChoicePleaseTryAgain')));
        end
    end
end


function confirmed=confirmName(name,doctype)
    switch doctype
    case{'word','excel'}
        confirm=input(['Checking ''',regexprep(name,'\','/'),''' (Y/n) ? '],'s');
    case 'doors'
        confirm=input(['Checking module ''',rmidoors.getModuleAttribute(name,'FullName'),''' (Y/n) ? '],'s');
    end
    if isempty(confirm)||strcmpi(confirm(1),'y')
        confirmed=true;
    else
        confirmed=false;
    end
end

function type=resolveType(docName)



    [~,~,ext]=fileparts(docName);

    if isempty(ext)
        type='doors';
    elseif any(strcmpi(ext,{'.doc','.docx','.docm','.rtf'}))
        type='word';
    elseif any(strcmpi(ext,{'.xls','.xlsx','.xlsm'}))
        type='excel';
    else
        type=[docName,' format'];
    end
end

