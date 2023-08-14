



function dialect=getDialect(compiler,compilerVersion)

    if strcmp(compiler,'msvc')

        if compilerVersion>=1920

            dialect='visual16.x';
        elseif compilerVersion>=1910

            dialect='visual15.x';
        elseif compilerVersion>=1900
            dialect='visual14.0';
        elseif compilerVersion>=1800
            dialect='visual12.0';
        elseif compilerVersion>=1700
            dialect='visual11.0';
        else
            dialect='visual10.0';
        end
    elseif strcmp(compiler,'gcc')
        if compilerVersion>=80000
            dialect='gnu8.x';
        elseif compilerVersion>=70000
            dialect='gnu7.x';
        elseif compilerVersion>=60000
            dialect='gnu6.x';
        elseif compilerVersion>=50000
            dialect='gnu5.x';
        elseif compilerVersion>=40900
            dialect='gnu4.9';
        elseif compilerVersion>=40800
            dialect='gnu4.8';
        elseif compilerVersion>=40700
            dialect='gnu4.7';
        else
            dialect='gnu4.6';
        end
    elseif strcmp(compiler,'clang')
        if compilerVersion>=110000
            dialect='clang11.x';
        elseif compilerVersion>=100000
            dialect='clang10.x';
        elseif compilerVersion>=90000
            dialect='clang9.x';
        elseif compilerVersion>=80000
            dialect='clang8.x';
        elseif compilerVersion>=70000
            dialect='clang7.x';
        elseif compilerVersion>=60000
            dialect='clang6.x';
        else
            dialect='clang5.x';
        end
    elseif strcmp(compiler,'lcc')
        dialect='generic';
    else
        dialect='generic';
    end


