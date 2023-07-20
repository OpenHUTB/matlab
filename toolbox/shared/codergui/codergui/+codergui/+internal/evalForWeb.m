

function[varargout]=evalForWeb(strToEval)

    matlabResults=cell(nargout,1);
    [matlabResults{:}]=eval(strToEval);

    varargout=cell(nargout,1);
    for i=1:nargout
        varargout{i}=codergui.internal.flattenForJson(matlabResults{i});
    end

end