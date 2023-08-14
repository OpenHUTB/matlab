function html=removeCEFFormatting(htmlStr)



    html=strrep(htmlStr,'&nbsp;',char(32));
end