function versionNumber=getToolVersionNumber(toolVersion)





    parts=sscanf(toolVersion,'%d.%d')';
    if isempty(parts)
        warning(message('hdlcommon:workflow:InvalidVersionID',toolVersion));

        parts=[100,99];
    end

    if length(parts)<2
        parts(2)=0;
    end
    versionNumber=parts*[1;0.01];
end