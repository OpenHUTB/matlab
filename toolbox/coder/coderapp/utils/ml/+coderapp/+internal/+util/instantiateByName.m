function instances=instantiateByName(classNames,baseClass,varargin)



    if nargin<2
        baseClass='';
    end
    classNames=cellstr(classNames);
    instances=cell(numel(classNames),1);
    for i=1:numel(classNames)
        if isempty(meta.class.fromName(classNames{i}))
            error('No class "%s" found on path',classNames{i});
        elseif~isempty(baseClass)&&~ismember(baseClass,superclasses(classNames{i}))
            error('Class "%s" does not extend %s',classNames{i},baseClass);
        end
        instances{i}=feval(classNames{i},varargin{:});
    end
    instances=[instances{:}];
end

