function html=makeHtmlSafe(html)




    switch class(html)
    case 'char'
        html=strrep(html,'&','&amp;');
        html=strrep(html,'>','&gt;');
        html=strrep(html,'<','&lt;');
        html=strrep(html,'"','&quot;');
        html=strrep(html,'''','&apos;');
    case 'cell'

        charIdx=cellfun(@ischar,html);

        html(charIdx)=strrep(html(charIdx),'&','&amp;');
        html(charIdx)=strrep(html(charIdx),'>','&gt;');
        html(charIdx)=strrep(html(charIdx),'<','&lt;');
        html(charIdx)=strrep(html(charIdx),'"','&quot;');
        html(charIdx)=strrep(html(charIdx),'''','&apos;');
    end
end

