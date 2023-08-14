function[dstStr,hadErrors]=replaceTokensFromTokenArray(srcStr,tokenArray,hObj)







    if nargin==2
        hObj=[];
    end

    if iscell(srcStr)
        dstStr=cell(1,numel(srcStr));
        for i=1:numel(srcStr)
            [dstStr{i},hadErrors]=i_replace(srcStr{i},tokenArray,hObj);
        end
    else
        [dstStr,hadErrors]=i_replace(srcStr,tokenArray,hObj);
    end
end


function[srcStr,hadErrors]=i_replace(srcStr,tokenArray,hObj)
    hadErrors=false;
    for j=1:length(tokenArray)
        tokenName=tokenArray{j}.Name;
        tokenValue=tokenArray{j}.Value;
        if~isempty(tokenValue)
            tokenStr=['$(',tokenName,')'];
            if isempty(strfind(srcStr,tokenStr))
                continue
            end

            str=which(tokenValue);
            [~,~,e]=fileparts(str);
            if~isempty(e)&&(isequal(e,'.m')||isequal(e,'.p'))
                try
                    tokenValue=eval(tokenValue);
                catch
                    tokenValue='';
                    hadErrors=true;
                end
            end

            srcStr=strrep(srcStr,tokenStr,tokenValue);
        end
    end
end
