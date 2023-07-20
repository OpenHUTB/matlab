function editUpdateFcn(hObj)









    fileName=localGetFileNameFromUpdateFcn(hObj);

    textToHighlight='%********* Define the content of the data tip here *********%';



    if~isempty(fileName)
        editorDocument=matlab.desktop.editor.openDocument(fileName);


        if isempty(editorDocument)
            editorDocument=matlab.desktop.editor.newDocument(localGetUpdateText(textToHighlight));
        end
    else
        editorDocument=matlab.desktop.editor.newDocument(localGetUpdateText(textToHighlight));
    end

    editorDocument.smartIndentContents();

    indexOfText=strfind(editorDocument.Text,textToHighlight);
    if~isempty(indexOfText)
        editorDocument.goToLine(matlab.desktop.editor.indexToPositionInLine(editorDocument,indexOfText));
    end





    timeObj=timer('StartDelay',2,...
    'Name','Datatips_EditUpdateFcnTimer',...
    'ObjectVisibility','off',...
    'ExecutionMode','fixedRate',...
    'Period',0.5);
    timeFcnCallback=@(~,~)checkForDocumentFileName(hObj,timeObj,editorDocument);


    timeObj.TimerFcn=matlab.graphics.controls.internal.timercb(timeFcnCallback);
    start(timeObj);




    function checkForDocumentFileName(hObj,timerObj,editorDocument)


        if~isvalid(timerObj)
            return;
        end
        if~isvalid(hObj)||~editorDocument.Opened
            stop(timerObj);
            delete(timerObj);
            return;
        end


        editorFileName=editorDocument.Filename;
        fileName=localGetFileNameFromUpdateFcn(hObj);
        if~strcmp(fileName,editorFileName)
            [pathstr,~]=fileparts(editorFileName);
            if~isempty(pathstr)
                localSetUpdateFcn(hObj,editorFileName);
            end
        end



        if editorDocument.Modified
            timerObj.UserData=true;
        elseif timerObj.UserData
            timerObj.UserData=false;
            localSetUpdateFcn(hObj,editorFileName);
        end

        function localSetUpdateFcn(hObj,fileName)


            if~isempty(fileName)
                currFun=hObj.UpdateFcn;
                if iscell(currFun)
                    currFun=currFun{1};
                end
                if ischar(currFun)
                    funName=strtok(hObj.UpdateFcn,' ');
                    clear(funName);
                elseif~isempty(currFun)
                    clear(func2str(currFun));
                end
                [pathstr,name]=fileparts(fileName);
                if~contains(which(name),pathstr)
                    currDir=pwd;
                    cd(pathstr);
                    hFun=str2func(name);
                    cd(currDir);
                else
                    hFun=str2func(name);
                end




                if~isempty(currFun)
                    funInfo=functions(currFun);
                    if~iscell(hObj.UpdateFcn)||~isequal(funInfo.file,fileName)
                        hObj.UpdateFcn=hFun;
                    end
                else
                    hObj.UpdateFcn=hFun;
                end
            end

            function fileName=localGetFileNameFromUpdateFcn(hObj)
                currFunc=hObj.UpdateFcn;
                fileName=[];
                if~isempty(currFunc)
                    if iscell(currFunc)
                        currFunc=currFunc{1};
                    end
                    if isa(currFunc,'function_handle')
                        funcInfo=functions(currFunc);
                        fileName=funcInfo.file;
                    else
                        fileName=which(currFunc);
                    end
                end


                function[str,cursorPosition]=localGetUpdateText(textToHighlight)

                    str=['function output_txt = myfunction(obj,event_obj)',newline,...
                    '% Display data cursor position in a data tip',newline,...
                    '% obj          Currently not used',newline,...
                    '% event_obj    Handle to event object',newline,...
                    '% output_txt   Data tip text, returned as a character vector or a cell array of character vectors',newline,...
                    newline,...
                    'pos = event_obj.Position;',newline,...
                    newline,...
                    newline,...
                    textToHighlight,newline,...
                    newline,...
                    '% Display the x and y values:',newline,...
                    'output_txt = {[''X'',formatValue(pos(1),event_obj)],...',newline,...
                    '              [''Y'',formatValue(pos(2),event_obj)]};',newline,...
                    '%***********************************************************%',newline,...
                    newline,...
                    newline,...
                    '% If there is a z value, display it:',newline,...
                    'if length(pos) > 2',newline,...
                    '    output_txt{end+1} = [''Z'',formatValue(pos(3),event_obj)];',newline,...
                    'end',newline,...
                    newline,...
                    '%***********************************************************%',newline,...
                    newline,...
                    'function formattedValue = formatValue(value,event_obj)',newline,...
                    '% If you do not want TeX formatting in the data tip, uncomment the line below.',newline,...
                    '% event_obj.Interpreter = ''none'';',newline,...
                    'if strcmpi(event_obj.Interpreter,''tex'')',newline,...
                    '    valueFormat = '' \color[rgb]{0 0.6 1}\bf'';',newline,...
                    '    removeValueFormat = ''\color[rgb]{.25 .25 .25}\rm'';',newline,...
                    'else',newline,...
                    '    valueFormat = '': '';',newline,...
                    '    removeValueFormat = '''';',newline,...
                    'end',newline,...
                    'formattedValue = [valueFormat num2str(value,4) removeValueFormat];',newline];

                    cursorPosition=length(extractBefore(str,"',"));