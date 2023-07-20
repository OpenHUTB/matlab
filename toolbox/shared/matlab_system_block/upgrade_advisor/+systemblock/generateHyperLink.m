function link=generateHyperLink(blockPath,linkText)
    blockPath=strrep(blockPath,'"','%22');
    link=['<a href = "',blockPath,'">',linkText,'</a>'];
end