

function out=getRTWTableShrinkButton(id,option)

    if isempty(id)

        id=convertStringsToChars(matlab.lang.internal.uuid);
    end
    if option.UseSymbol
        if option.ShowByDefault
            text='[+]';
        else
            text='[-]';
        end
        text_style='style="cursor:pointer;font-family:monospace;font-weight:normal;"';
        isSymbol='true';
    else
        if option.ShowByDefault
            text='[<u>show</u>]';
        else
            text='[<u>hide</u>]';
        end
        text_style='style="cursor:pointer;font-weight:normal;"';
        isSymbol='false';
    end
    if~isfield(option,'tooltip')
        tooltip='Click to shrink or expand table';
    else
        tooltip=option.tooltip;
    end
    jsCall=['rtwTableShrink(window.document, this, ''',id,''', ',isSymbol,')'];
    out=['<span title="',tooltip,'" ',text_style,' id="',id,'_control"',' onclick ="if (rtwTableShrink) ',jsCall,'"><span class="shrink-button">',text,'</span></span>'];
end
