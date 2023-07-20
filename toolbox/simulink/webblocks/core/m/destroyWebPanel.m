function destroyWebPanel(panelHandleHex)
    panelPath=getfullname(str2double(panelHandleHex));
    panelSubsystemPath=regexprep(panelPath,'/panelInfo$','');
    delete_block(panelSubsystemPath);
end
