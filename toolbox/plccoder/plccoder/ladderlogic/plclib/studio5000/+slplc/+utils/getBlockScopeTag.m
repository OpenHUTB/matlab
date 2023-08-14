function scopeTag=getBlockScopeTag(block)

    sid=Simulink.ID.getSID(block);
    strings=strsplit(sid,':');
    levelNum=numel(strfind(sid,':'));
    scopeTag=['s',num2str(levelNum),'_',strings{end}];

end