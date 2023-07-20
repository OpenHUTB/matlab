function[retVal,error,consoleOutput,fauxConfigSet]=ctFireCallback(callbackContext,fauxConfigSet)


    assert(isa(callbackContext,'com.mathworks.toolbox.coder.target.JavaCallbackContext'));
    import com.mathworks.toolbox.coder.target.CallbackType;
    error=[];
    retVal=[];
    consoleOutput=[];

    ci=coder.ctgui.CallbackInterface(callbackContext,fauxConfigSet);
    fauxConfigSet=ci.getConfigSet();%#ok<NASGU>

    tag=char(callbackContext.getParameterTag());
    desc='Coder Target';
    callbackType=callbackContext.getCallbackType();
    callbackFunc=char(callbackContext.getCallbackFunction());

    try
        if callbackType.equals(CallbackType.CHANGE)
            codeStr=sprintf('%s(ci, ci, ''%s'', ''%s'')',callbackFunc,tag,desc);
            if nargout(callbackFunc)~=0
                [consoleOutput,retVal]=evalc(codeStr);
            else
                consoleOutput=evalc(codeStr);
            end
        else
            [retVal,consoleOutput]=evalForInitialValue(ci,callbackFunc);

            if callbackType.equals(CallbackType.INITIAL_VALUE)




                overlayValueAsTransient(callbackContext.getParameter(),retVal,ci);
            end
        end

        fauxConfigSet=ci.getConfigSet();
    catch me
        fauxConfigSet=[];
        error=me.message;
        if(callbackContext.isDebugging())
            disp(me.getReport('extended'));
        else
            coder.internal.gui.asyncDebugPrint(me);
        end
    end
end


function overlayValueAsTransient(parameter,value,ci)
    assert(isa(parameter,'com.mathworks.toolbox.coder.target.CtParameter'));

    if isempty(value)||parameter.getStorageKey().isEmpty()
        return;
    end

    ci.setTransientMode(true);
    cleanup=onCleanup(@()ci.setTransientMode(false));

    pathTokens=strsplit(char(parameter.getStorageKey()),'.');
    data=ci.CoderTargetData;

    for i=1:numel(pathTokens)-1

        data=data.(pathTokens{i});
    end

    data.(pathTokens{end})=value;
end


function[val,output]=evalForInitialValue(ci,callbackFunc)

    hObj=ci;%#ok<NASGU>
    hDlg=ci;%#ok<NASGU>

    resolvedPath=which(callbackFunc);
    codeStr=callbackFunc;
    if~isempty(resolvedPath)&&nargin(resolvedPath)>0
        argCount=abs(nargin(resolvedPath));
        if argCount==1
            codeStr=sprintf('%s(hObj)',callbackFunc);
        elseif argCount~=0
            codeStr=sprintf('%s(hObj, hDlg)',callbackFunc);
        end
    end
    [output,val]=evalc(codeStr);
end
