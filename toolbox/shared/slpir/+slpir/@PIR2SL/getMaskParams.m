function maskParams=getMaskParams(~,slBlock)



    op=get_param(slBlock,'objectparameters');

    if isempty(op)
        maskParams=[];
        return;
    end

    f=fieldnames(op);
    i=strncmp(f,'Mask',4);
    mp=f(i);



    j=[];
    s='String';
    for i=1:length(mp)
        if findstr(s,mp{i})
            j=[j,i];
        end
    end
    mp(j)=[];


    i=strmatch('MaskNames',mp);mp(i)=[];
    i=strmatch('MaskWSVariables',mp);mp(i)=[];
    i=strmatch('MaskObject',mp);mp(i)=[];
    i=strmatch('TemplateBlock',mp);mp(i)=[];


    i=strmatch('MaskVariableAliases',mp);mp(i)=[];


    p='MaskCallbacks';
    i=strmatch(p,mp);
    mp(i)=[];
    mp(end+1)={p};

    p='MaskInitialization';
    i=strmatch(p,mp);
    mp(i)=[];
    mp(end+1)={p};


    for i=1:length(mp)
        v{i,1}=get_param(slBlock,mp{i});
    end





    i=strmatch('MaskValues',mp);
    if~isempty(i)
        maskObj=Simulink.Mask.get(slBlock);
        newvalues=v{i,1};
        for j=1:numel(maskObj.Parameters)

            p=maskObj.Parameters(j);

            if~strcmpi(p.Type,'promote')
                continue;
            end
            if numel(v{i,1})<j
                continue;
            end

            [~,status]=str2num(newvalues{j});%#ok<ST2NM>
            if status~=0
                continue;
            end

            if~strncmpi(newvalues{j},'''',1)
                try
                    if isempty(slResolve(newvalues{j},slBlock))
                        newvalues{j}=['''',newvalues{j},''''];
                    end
                catch

                    newvalues{j}=['''',newvalues{j},''''];
                end
            end

        end
        v{i,1}=newvalues;
    end


    pv=[mp,v];
    maskParams=pv;
end