function str=convertToStrForMLAPPCode(blockpath)






    if~iscell(blockpath)


        str=['''',blockpath,''''];
    else


        numEls=length(blockpath);
        str='{';
        for i=1:numEls
            str=[str,'''',blockpath{i},''''];%#ok
            if i~=numEls
                str=[str,','];%#ok
            end
        end
        str=[str,'}'];
    end
end

