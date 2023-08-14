function out=getEvaledParameterInfo(hObj)



    out=[];

    info=codertarget.utils.getParameterDialogInfo(hObj);
    if isempty(info)
        return;
    end

    hint=codertarget.utils.getTargetHardwareDetailWidgets(hObj);
    if isempty(hint)||isempty(hint.Items)
        return;
    end

    out=loc_evaluate(hObj,info);


    function info=loc_evaluate(hObj,info)%#ok<INUSL>
        fs=fields(info);
        for i=1:length(fs)
            f=fs{i};
            v=info.(f);
            if isempty(v)
                continue;
            end
            params=v.Parameters;
            for j=1:length(params)
                ps=params{j};
                for k=1:length(ps)
                    p=ps{k};
                    if ischar(p.Value)&&strcmp(p.ValueType,'callback')
                        try
                            p.Value=eval(p.Value);
                        catch
                            p.Value='';
                        end
                    end
                    if ischar(p.Visible)
                        try
                            p.Visible=eval(p.Visible);
                        catch
                            p.Visible=false;
                        end
                    end
                    if ischar(p.Enabled)
                        try
                            p.Enabled=eval(p.Enabled);
                        catch
                            p.Enabled=false;
                        end
                    end
                    if~isempty(p.Entries)
                        try
                            p.Entries=feval(p.Entries{1});
                        catch
                        end
                    end
                    ps{k}=p;
                end
                params{j}=ps;
            end
            v.Parameters=params;
            info.(f)=v;
        end

