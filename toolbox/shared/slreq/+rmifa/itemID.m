function out=itemID(host,in,mode)



    if isempty(strtok(in))
        if mode
            out='';
        else

            [~,out]=fileparts(host);
        end
        return;
    end

    if isempty(host)
        out=in;
        return;
    end

    [~,mdlName]=fileparts(host);

    if in(1)=='@'
        in=in(2:end);
    end




    if mode==rmifa.isFaultIdString(in)

        out=in;
        return;
    elseif rmifa.isFaultIdString(in)


        faultInfoObj=rmifa.getFaultInfoObj(mdlName,in);
        out=rmifa.getDisplayString(faultInfoObj);
    else


        bridge=getString(message('Slvnv:reqmgt:LinkSet:updateContents:LocationInDoc','',''));
        leng=length(bridge);
        inds=strfind(in,bridge);

        for i=1:numel(inds)
            faultName=in(1:inds(i)-1);
            displayName=in(inds(i)+leng:end);
            if startsWith(displayName,mdlName)
                break;
            end
        end

        fault=Simulink.fault.get(displayName,faultName);
        out=[rmifa.itemIDPref,fault.Uuid];
    end
end
