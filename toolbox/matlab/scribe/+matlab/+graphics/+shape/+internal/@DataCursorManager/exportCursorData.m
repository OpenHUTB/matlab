function exportCursorData(hObj)










    prompt={getString(message('MATLAB:uistring:datacursor:EnterVariableName'))};
    name=getString(message('MATLAB:uistring:datacursor:TitleExportCursorDataToWorkspace'));
    numlines=1;


    answer={hObj.DefaultExportVarName};

    exportVarAcquired=false;
    cancelExport=false;
    while~exportVarAcquired&&~cancelExport

        answer=inputdlg(prompt,name,numlines,answer);

        if isempty(answer)

            cancelExport=true;
        else

            if~isvarname(answer{1})
                h=errordlg(getString(message('MATLAB:uistring:datacursor:DialogInvalidVariableName',answer{1})),...
                getString(message('MATLAB:uistring:datacursor:DialogCursorDataExportError')),'modal');
                waitfor(h);

            elseif localExistsInBase(answer{1})


                warnMessage=getString(...
                message('MATLAB:uistring:datacursor:WarningVariableExists',...
                answer{1},answer{1}));
                exportVarAcquired=localUIPrefDiag(hObj.Figure,warnMessage,...
                getString(message('MATLAB:uistring:datacursor:TitleExportCursorDataToWorkspace')),...
                'DataCursorVariable');

            else

                exportVarAcquired=true;
            end
        end
    end

    if~cancelExport&&exportVarAcquired&&ischar(answer{1})
        datainfo=getCursorInfo(hObj);
        try

            assignin('base',answer{1},datainfo);


            hObj.DefaultExportVarName=answer{1};

        catch ex

            id=ex.identifier;
            if strcmpi(id,'MATLAB:assigninInvalidVariable')
                h=errordlg(getString(message('MATLAB:uistring:datacursor:DialogInvalidVariableName',answer{1})),...
                getString(message('MATLAB:uistring:datacursor:DialogCursorDataExportError')),'modal');
            else
                h=errordlg(getString(message('MATLAB:uistring:datacursor:DialogErrorWhileSavingData')),...
                getString(message('MATLAB:uistring:datacursor:DialogCursorDataExportError')),'modal');
            end
        end
    end
end


function ret=localExistsInBase(str)

    exists=evalin('base',['exist(''',str,''',''var'')']);
    ret=(exists~=0);
end


function userAns=localUIPrefDiag(hFig,theMessage,title,key)




    [lastWarnMsg,lastWarnId]=lastwarn;
    oldstate=warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

    jFrame=matlab.ui.internal.JavaMigrationTools.suppressedJavaFrame(hFig);


    warning(oldstate);
    lastwarn(lastWarnMsg,lastWarnId);

    canvases=jFrame.getAxisComponent;
    yesAnswer=com.mathworks.mwswing.MJOptionPane.YES_OPTION;
    res=edtMethod('showOptionalConfirmDialog','com.mathworks.widgets.Dialogs',canvases,...
    theMessage,title,...
    com.mathworks.mwswing.MJOptionPane.CANCEL_OPTION,...
    com.mathworks.mwswing.MJOptionPane.WARNING_MESSAGE,...
    key,yesAnswer,true);

    userAns=(res==yesAnswer);
end
