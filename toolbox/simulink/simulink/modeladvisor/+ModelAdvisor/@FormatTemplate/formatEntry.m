


function[entry]=formatEntry(this,input)

    if(~ischar(input)&&~isscalar(input))||iscell(input)
        entry=loc_parseArray(this,input);
    elseif isa(input,'Advisor.Element')
        entry=loc_parseAdvisorElement(this,input);
    elseif ischar(input)
        entry=loc_parseString(this,input);
    elseif~isnumeric(input)&&ishandle(input)
        entry=loc_parseObject(this,input);






    elseif isnumeric(input)&&ishandle(input)&&isempty(ancestor(input,'root'))
        handType=get_param(input,'Type');
        registerResultData(input);
        switch handType
        case 'line'
            parentName=cleanName(get_param(input,'Parent'));
            sigName=cleanName(get_param(input,'Name'));

            if~isempty(sigName)
                entry=ModelAdvisor.Text([parentName,'/',sigName]);
            else
                entry=ModelAdvisor.Text(parentName);
            end
            myStr=sprintf('%18.16f',input);
            entry.setHyperlink(['matlab: modeladvisorprivate hiliteLine ',num2str(myStr)]);
        case 'port'

            parentName=getfullname(input);
            parentName=cleanName(parentName);
            lineHand=get_param(input,'Line');
            entry=ModelAdvisor.Text(parentName);
            myStr=sprintf('%18.16f',lineHand);
            if lineHand>0
                entry.setHyperlink(['matlab: modeladvisorprivate hiliteLine ',num2str(myStr)]);
            else
                entry.Content=[entry.Content,num2str(get_param(input,'PortNumber'))];
            end
        otherwise
            fullpathname=getfullname(input);
            if it_contains_i18n_chars(fullpathname)
                [entry]=ModelAdvisor.FormatTemplate.fullPathToHTML(this,fullpathname,Simulink.ID.getSID(fullpathname));
            else
                [entry]=ModelAdvisor.FormatTemplate.fullPathToHTML(this,fullpathname);
            end
        end
    elseif isnumeric(input)
        entry=num2str(input);
    else
        entry=input;
    end
end

function yesorno=it_contains_i18n_chars(str)
    yesorno=false;
    for i=1:length(str)
        if double(str(i))>255
            yesorno=true;
            break;
        end
    end
end

function registerResultData(input,varargin)
    if nargin>1
        inputIsSID=varargin{1};
    else
        inputIsSID=false;
    end
    x=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    if isa(x,'Simulink.ModelAdvisor')
        checkObj=x.ActiveCheck;
        if isa(checkObj,'ModelAdvisor.Check')&&checkObj.SupportHighlighting
            if inputIsSID

                temp=input;
            else
                temp=Simulink.ID.getSID(input);
            end

            if~isempty(temp)&&~strcmp(temp,bdroot(x.SystemName))
                checkObj.ProjectResultData{end+1}=temp;
            end
        end
    end
end

function[name]=cleanName(name)

    cr=sprintf('%c',13);
    cr2=sprintf('%c',10);
    name=regexprep(name,'>','&#62;');
    name=regexprep(name,'<','&#60;');
    name=regexprep(name,cr,'_');
    name=regexprep(name,cr2,'_');
end

function formattedArray=loc_parseArray(ft,array)

    if iscell(array)
        formattedArray=cell(size(array));
        for rowIndex=1:size(array,1)
            for colIndex=1:size(array,2)
                formattedArray{rowIndex,colIndex}=...
                ft.formatEntry(array{rowIndex,colIndex});
            end
        end

    elseif isa(array,'Advisor.Element')
        formattedArray=Advisor.Element;
        for rowIndex=1:size(array,1)
            for colIndex=1:size(array,2)
                formattedArray(rowIndex,colIndex)=...
                ft.formatEntry(array(rowIndex,colIndex));
            end
        end

    else
        formattedArray=array;
    end

end








function formattedTextObj=loc_parseString(ft,stringInput)



    if isempty(Simulink.ID.checkSyntax(stringInput))&&Simulink.ID.isValid(stringInput)



        [object,remainder]=Simulink.ID.getHandle(stringInput);

        if~isempty(object)
            registerResultData(stringInput,true);
        end

        if strncmp(class(object),'Stateflow',9)


            fullPathToObject=object.getFullName();






            if Advisor.BaseRegisterCGIRInspectorResults.isValidMATLABFcnStartEndPostFix(remainder)&&...
                (isa(object,'Stateflow.EMChart')||isa(object,'Stateflow.EMFunction'))
                fullPathToObject=[fullPathToObject,':',remainder];
            end

        else
            fullPathToObject=Simulink.ID.getFullName(stringInput);
        end

        formattedTextObj=ModelAdvisor.FormatTemplate.fullPathToHTML(ft,fullPathToObject,stringInput);


    elseif isValidSlObject(slroot,stringInput)
        registerResultData(stringInput);

        formattedTextObj=ModelAdvisor.FormatTemplate.fullPathToHTML(ft,stringInput);


    elseif~isempty(regexp(stringInput,'\.m$','once'))||...
        ~isempty(regexp(stringInput,'\.m:[0-9]+\-[0-9]+$','once'))||...
        ~isempty(regexp(stringInput,'\.m:[0-9]+$','once'))

        idx=strfind(stringInput,'.m');
        if exist(stringInput(1:idx(end)+1),'file')

            slCB=ModelAdvisor.getSimulinkCallback('hilite_file',stringInput);
            formattedTextObj=ModelAdvisor.Text(stringInput);
            formattedTextObj.setHyperlink(slCB);
        else
            formattedTextObj=ModelAdvisor.Text(stringInput);
        end


    else



        SIDtokens=regexp(stringInput,'href="matlab:\s*Simulink.ID.hilite\(\''(\S+)\''\)','tokens');
        for i=1:length(SIDtokens)
            registerResultData(SIDtokens{i}{1},true);
        end

        formattedTextObj=ModelAdvisor.Text(stringInput);
    end

end

function formattedTextObj=loc_parseObject(ft,object)

    if strncmp(class(object),'Simulink',8)||isa(object,'Stateflow.Chart')
        sid=Simulink.ID.getSID(object);

        fullPathToObject=Simulink.ID.getFullName(sid);

        formattedTextObj=ModelAdvisor.FormatTemplate.fullPathToHTML(ft,fullPathToObject,sid);
        registerResultData(sid,true);

    elseif strncmp(class(object),'Stateflow',9)

        sid=Simulink.ID.getSID(object);
        if Simulink.ID.isValid(sid)
            formattedTextObj=ModelAdvisor.FormatTemplate.fullPathToHTML(ft,object.getFullName(),sid);
            registerResultData(sid,true);
        else
            machineSID=Simulink.ID.getSID(object.Machine);
            fakeSID=[machineSID,':',object.Name];
            formattedTextObj=ModelAdvisor.FormatTemplate.fullPathToHTML(ft,fakeSID);
            slCB=...
            ['matlab: modeladvisorprivate hiliteSystem MACHINELEVEL_SID:',...
            fakeSID];
            formattedTextObj.setHyperlink(slCB);
        end

    else

        formattedTextObj=ModelAdvisor.Text(class(object));
    end
end

function advisorElement=loc_parseAdvisorElement(this,advisorElement)
    if isa(advisorElement,'Advisor.Text')
        if~isempty(advisorElement.Hyperlink)

            SIDtokens=regexp(advisorElement.emitHTML,'href="matlab:\s*Simulink.ID.hilite\(\''(\S+)\''\)','tokens');
            for i=1:length(SIDtokens)
                registerResultData(SIDtokens{i}{1},true);
            end
        else


            outputAdvisorElement=formatEntry(this,advisorElement.Content);
            advisorElement.Content=outputAdvisorElement.Content;
            advisorElement.setHyperlink(outputAdvisorElement.Hyperlink);
        end
    elseif isa(advisorElement,'Advisor.List')||isa(advisorElement,'Advisor.Paragraph')
        for n=1:length(advisorElement.Items)
            advisorElement.Items(1,n)=formatEntry(this,advisorElement.Items(1,n));
        end
    elseif isa(advisorElement,'Advisor.Table')
        for n=1:advisorElement.NumRow
            for ni=1:advisorElement.NumColumn
                advisorElement.Entries{n,ni}=formatEntry(this,advisorElement.Entries{n,ni});
            end
        end
    else


    end

end
