function tokens=splitAbsolutePath(absShortNamePath)




    if nargin<1
        DAStudio.error('RTW:autosar:badSplitAbsPathArgument');
    end

    if(isempty(absShortNamePath)==true)||...
        ((ischar(absShortNamePath)||isStringScalar(absShortNamePath))==false)||...
        (size(absShortNamePath,1)>1)||...
        (~ismatrix(absShortNamePath))
        DAStudio.error('RTW:autosar:badSplitAbsPathShortName',...
        absShortNamePath);
    end

    if(absShortNamePath(1)~='/')
        DAStudio.error('RTW:autosar:badAbsolutePath',absShortNamePath);

    end


    tokens=regexp(absShortNamePath,'\/([^\/]*)','tokens');
    if isempty(tokens)
        return
    else
        old=tokens;
        tokens=cell(size(old));
        for ii=1:numel(old)
            tokens{ii}=old{ii}{1};
        end
    end
