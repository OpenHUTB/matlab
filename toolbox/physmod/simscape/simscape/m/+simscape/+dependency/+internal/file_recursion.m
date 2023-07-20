function[files,missing]=file_recursion(filePth,depType,doTWM)






























    [files,missing]=l_impl(filePth,depType,doTWM,{},{});
    analyzed={filePth};
    todo=setdiff(files,analyzed);

    while~isempty(todo)
        [files,missing]=l_impl(todo{1},depType,doTWM,files,missing);
        analyzed(end+1)=todo(1);%#ok
        todo=setdiff(files,analyzed);
    end
end

function[files,missing]=l_impl(pth,depType,doTWM,files,missing)
    [~,~,ext]=fileparts(pth);
    if~any(strcmp(ext,{'.ssc','.sscp'}))
        return;
    end

    [f,m]=simscape.dependency.file(pth,depType,false,doTWM);
    files=union(files,f);
    missing=union(missing,m);
end
