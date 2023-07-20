
function cleanName=cleanBlockName(name)



    cleanName=[];
    skip=false;
    for k=1:length(name)
        if skip
            skip=false;
            continue;
        end
        if name(k)~='/'
            cleanName=[cleanName,name(k)];
        elseif name(k+1)=='/'


            skip=true;
        else
            cleanName=[cleanName,'/'];
        end
    end
