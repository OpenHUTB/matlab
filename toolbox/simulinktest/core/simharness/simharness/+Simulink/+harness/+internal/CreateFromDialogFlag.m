function value=CreateFromDialogFlag(update)
    persistent flag
    value=isequal(flag,true);
    if exist('update','var')
        flag=update;
    end
end