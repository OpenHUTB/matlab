function htmlgatewayAdvisor(actionString,varargin)






    actionString=strtok(actionString,'?');


    decodedModelName='';
    tmpactionString=actionString;
    while(~isempty(tmpactionString))
        [tokenElement,tmpactionString]=strtok(tmpactionString,'&');
        [elementName,elementValue]=analyzeToken(tokenElement);
        switch elementName
        case 'modelName'
            decodedModelName=elementValue;
            break;
        end

        tmpactionString=tmpactionString(2:end);
    end

    if isempty(decodedModelName)
        errordlg(getString(message('ModelAdvisor:engine:DecodeMdlNameFailed')));
        return
    else
        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(decodedModelName);
    end

    if isempty(mdladvObj.System)
        errordlg(getString(message('ModelAdvisor:engine:MdlAdvDotMUsage')));
        return
    end



    if nargin>1
        StartInTaskPage=varargin{1};
    else
        StartInTaskPage=false;
    end
    if StartInTaskPage
        mdladvObj.deselectTaskAll;
    else
        mdladvObj.deselectCheckAll;
    end
    mdladvObj.StartInTaskPage=StartInTaskPage;


    ButtonClicked='checkModel';

    while(~isempty(actionString))
        [tokenElement,actionString]=strtok(actionString,'&');
        [elementName,elementValue]=analyzeToken(tokenElement);

        switch elementName
        case 'checkModel'
            ButtonClicked='checkModel';
        case 'modelName'

        otherwise
            [category,serialNum]=analyzeName(elementName);
            if strcmp(category,'CheckRecord')
                if strcmpi(elementValue,'on')
                    mdladvObj.updateCheck(str2double(serialNum),true);
                else
                    mdladvObj.updateCheck(str2double(serialNum),false);
                end
            end
            if strcmp(category,'CheckTask')
                if strcmpi(elementValue,'on')
                    mdladvObj.updateTask(str2double(serialNum),true);
                else
                    mdladvObj.updateTask(str2double(serialNum),false);
                end
            end
        end

        actionString=actionString(2:end);
    end

    switch ButtonClicked
    case 'checkModel'


        if StartInTaskPage
            mdladvObj.runTask;
        else
            mdladvObj.runCheck;
        end
    otherwise
        DAStudio.error('Simulink:tools:MAInvalidBtnClick');
        return
    end


    mdladvObj.displayReport('norefresh');




    function[name,value]=analyzeToken(token)
        [name,value]=strtok(token,'=');
        value=value(2:end);
        value=strrep(value,'+',' ');
        value=HTMLjsencode(value,'decode');




        function[category,serialNum]=analyzeName(name)
            [category,serialNum]=strtok(name,'_');
            serialNum=serialNum(2:end);

