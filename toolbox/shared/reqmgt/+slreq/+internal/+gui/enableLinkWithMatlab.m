function r=enableLinkWithMatlab()
    r=struct('name',getString(message('Slvnv:slreq:LinkWithMatlab')),...
    'tag','','callback','','accel','','enabled',true,'visible',true);

    [targetFile,range,selectedText]=rmiml.getSelection();
    if isempty(targetFile)||isempty(selectedText)
        r.enabled=false;
    elseif startsWith(targetFile,'Untitled')
        r.enabled=false;
    elseif rmiml.isBuiltinNoRmi(targetFile)
        r.enabled=false;
    elseif rmiml.canLink(targetFile,false)
        r.enabled=true;
    else
        r.enabled=false;
    end
end

