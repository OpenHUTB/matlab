function yes=isInternalError(err)





    yes=(isfield(err,'identifier')||isprop(err,'identifier'))&&...
    ~isempty(err.identifier)&&~isempty(regexp(err.identifier,...
    '^CoderInternal(\:.+)?$','once'));
end