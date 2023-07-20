function ret=isCLATaskManagerBlock(tskMgrBlkPath)



    taskMgr=strsplit(tskMgrBlkPath,'Task Blocks');
    ret=contains(get_param(taskMgr{1},'ReferenceBlock'),'c2000');
end