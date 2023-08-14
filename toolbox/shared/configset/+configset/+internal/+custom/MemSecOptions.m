function[msList,packageFound]=MemSecOptions(package,packageEnabled,type)




    if(nargin==2)
        type='All';
    end

    msList={'Default'};

    try
        if packageEnabled
            msList=processcsc('GetMemorySectionNames',package,type);
            msList=transpose(msList);
        end
        packageFound=true;
    catch
        packageFound=false;
    end

