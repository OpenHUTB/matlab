function ret=isValidAdaptorName(reg,name)





    uninitializedAdaptorName=linkfoundation.pjtgenerator.getUninitializedAdaptorName();
    len=length(uninitializedAdaptorName);
    if strncmp(name,uninitializedAdaptorName,len)

        ret=0;
    else

        ret=any(strcmp(name,reg.getAdaptorNames));
    end

end
