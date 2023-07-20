


function closeUI()
    releaseManagerHTMLInstance=multivercosim.internal.releasemanagerHTML.getInstance();
    if(~isempty(releaseManagerHTMLInstance))
        releaseManagerHTMLInstance.close();
    end
end