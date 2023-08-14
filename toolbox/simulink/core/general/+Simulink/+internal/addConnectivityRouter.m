function addConnectivityRouter(n,hierStrings,destination)















    if(sum(size(hierStrings)==[1,n])<2)
        error('hierStrings cell array must be of size [1 n]');
    end



    colIds='';
    for i=1:1:n
        for j=1:1:n+1
            if(j==n+1)
                colIds=strcat(colIds,string(num2str(j-1)));
                colIds=strcat(colIds,string(';'));
            else

            end
        end
    end

    for j=1:1:n-1
        colIds=strcat(colIds,string(num2str(j-1)));
        colIds=strcat(colIds,string(','));
    end
    colIds=strcat(colIds,string(num2str(n-1)));



    values='';
    for i=1:1:n
        for j=1:1:n+1
            if(j==n+1)
                values=strcat(values,string('0'));
                values=strcat(values,string(';'));
            else

            end
        end
    end

    for j=1:1:n-1
        values=strcat(values,string('0'));
        values=strcat(values,string(','));
    end
    values=strcat(values,string('0'));



    dirs='';
    for i=1:1:n
        for j=1:1:n+1
            if(j==n+1)
                dirs=strcat(dirs,string('-1'));
                dirs=strcat(dirs,string(';'));
            else

            end
        end
    end

    for j=1:1:n-1
        dirs=strcat(dirs,string('1'));
        dirs=strcat(dirs,string(','));
    end
    dirs=strcat(dirs,string('1'));



    HierStr='';
    for i=1:1:n
        for j=1:1:n+1
            if(j==n+1)
                HierStr=strcat(HierStr,hierStrings(i));
                HierStr=strcat(HierStr,string(';'));
            else

            end
        end
    end

    for j=1:1:n-1
        HierStr=strcat(HierStr,hierStrings(j));
        HierStr=strcat(HierStr,string(','));
    end
    HierStr=strcat(HierStr,hierStrings(n));



    h=add_block('built-in/ConnectivityRouter',destination);
    set_param(gcb,'NumberOfLeftConnectionPorts',num2str(n),'NumberOfRightConnectionPorts',num2str(1),'hierStrings',HierStr,'hierDirs',dirs,'connColId',colIds,'connValue',values)
    myString=fileread('connectivityRouterMaskInitialization.m');
    set_param(gcbh,'MaskInitialization',myString);

end
