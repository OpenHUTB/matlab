function varargout=validate(this,hDlg)




    b=true;
    exception=MException.empty;
    [b,exception]=validateDisplayProps(this,hDlg,b,exception);
    if nargout
        varargout={b,exception};
    elseif~b
        rethrow(exception);
    end
end
