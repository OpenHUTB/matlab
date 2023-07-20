function editTimeAttribs=GetEditTimeAttributesHelper(sigHier,sigName)
    editTimeAttribs={};
    if(~isempty(sigHier))
        for j=1:numel(sigHier)
            attribs=sigHier(j);

            if(~isempty(attribs))
                for i=1:length(attribs)
                    if(isempty(sigName))
                        editTimeAttribs=...
                        [editTimeAttribs,...
                        slde.ddg.GetEditTimeAttributesHelper(...
                        attribs(i).Children,...
                        attribs(i).SignalName)];
                    else
                        editTimeAttribs=...
                        [editTimeAttribs,...
                        slde.ddg.GetEditTimeAttributesHelper(...
                        attribs(i).Children,...
                        strcat(sigName,'.',...
                        attribs(i).SignalName))];
                    end
                end
            else
                if(isempty(sigName))



                    editTimeAttribs(end+1)={...
                    sigHier(j).SignalName};
                else
                    editTimeAttribs(end+1)={strcat(sigName,...
                    '.',sigHier(j).SignalName)};
                end
            end
        end
    elseif(isempty(sigName))

        editTimeAttribs(end+1)={'entity'};
    else
        editTimeAttribs(end+1)={sigName};
    end

    editTimeAttribs=unique(editTimeAttribs);

end