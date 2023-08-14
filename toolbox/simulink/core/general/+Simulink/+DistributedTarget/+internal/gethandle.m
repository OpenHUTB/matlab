function handle=gethandle(arglist,archH)








    sizeArg=length(arglist);

    try
        if(sizeArg==0)
            handle=archH;
        else
            currentHandle=archH;
            for i=1:sizeArg
                if ismethod(currentHandle,'findChildren')
                    currentHandle=currentHandle.findChildren(arglist{i});
                else
                    DAStudio.error('Simulink:mds:InvalidObjectIdentifier',...
                    strjoin(arglist,'/'));
                end
            end
            handle=currentHandle;
        end
    catch err

        throwAsCaller(err);
    end

end


