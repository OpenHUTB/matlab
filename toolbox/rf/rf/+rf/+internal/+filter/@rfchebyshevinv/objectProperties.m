function op=objectProperties(obj,op)




    responseStr=regexprep(lower(obj.ResponseType),...
    '(ow|igh|and|ass|top)','');
    if obj.UseFilterOrder

        op{end+1,1}='FilterOrder';
        op{end,2}=sprintf('%.15g',obj.FilterOrder);

        [y,e]=engunits(obj.StopbandAttenuation);
        val=sprintf('%.15g',y);
        if e~=1
            val=sprintf('%se%d',val,round(log10(1/e)));
        end
        op{end+1,1}='StopbandAttenuation';
        op{end,2}=val;

        if strcmpi(responseStr,'bs')
            [y,e]=engunits(obj.StopbandFrequency);
            val=sprintf('[%.15g %.15g]',y);
            if e~=1
                val=sprintf('%s*1e%d',val,round(log10(1/e)));
            end
            op{end+1,1}='StopbandFrequency';
            op{end,2}=val;
        else

            [y,e]=engunits(obj.PassbandFrequency);
            if strcmpi(responseStr,'bp')
                val=sprintf('[%.15g %.15g]',y);
                if e~=1
                    val=sprintf('%s*1e%d',val,round(log10(1/e)));
                end
            else
                val=sprintf('%.15g',y);
                if e~=1
                    val=sprintf('%se%d',val,round(log10(1/e)));
                end
            end
            op{end+1,1}='PassbandFrequency';
            op{end,2}=val;

            [y,e]=engunits(obj.PassbandAttenuation);
            val=sprintf('%.15g',y);
            if e~=1
                val=sprintf('%se%d',val,round(log10(1/e)));
            end
            op{end+1,1}='PassbandAttenuation';
            op{end,2}=val;

















        end

    else

        [y,e]=engunits(obj.PassbandFrequency);
        if strcmpi(responseStr(1),'b')
            val=sprintf('[%.15g %.15g]',y);
            if e~=1
                val=sprintf('%s*1e%d',val,round(log10(1/e)));
            end
        else
            val=sprintf('%.15g',y);
            if e~=1
                val=sprintf('%se%d',val,round(log10(1/e)));
            end
        end
        op{end+1,1}='PassbandFrequency';
        op{end,2}=val;

        [y,e]=engunits(obj.PassbandAttenuation);
        val=sprintf('%.15g',y);
        if e~=1
            val=sprintf('%se%d',val,round(log10(1/e)));
        end
        op{end+1,1}='PassbandAttenuation';
        op{end,2}=val;

        [y,e]=engunits(obj.StopbandFrequency);
        if strcmpi(responseStr(1),'b')
            val=sprintf('[%.15g %.15g]',y);
            if e~=1
                val=sprintf('%s*1e%d',val,round(log10(1/e)));
            end
        else
            val=sprintf('%.15g',y);
            if e~=1
                val=sprintf('%se%d',val,round(log10(1/e)));
            end
        end
        op{end+1,1}='StopbandFrequency';
        op{end,2}=val;

        [y,e]=engunits(obj.StopbandAttenuation);
        val=sprintf('%.15g',y);
        if e~=1
            val=sprintf('%se%d',val,round(log10(1/e)));
        end
        op{end+1,1}='StopbandAttenuation';
        op{end,2}=val;
    end
end
