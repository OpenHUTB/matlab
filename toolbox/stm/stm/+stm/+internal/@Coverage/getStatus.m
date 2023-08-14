

function status=getStatus(name)
    import stm.internal.Coverage;

    if Coverage.isNotUnique(name)


        status=Coverage.MODEL;
    else
        if contains(name,'/')

            name=extractBefore(name,'/');
        end
        status=exist(name,'file');
    end
end
