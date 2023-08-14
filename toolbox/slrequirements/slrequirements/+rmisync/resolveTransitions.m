function objH=resolveTransitions(transIdx,paths,parentPaths,parentId)%#ok<*INUSL>





    trans=sf('TransitionsOf',parentId);


    trans=rmisf.filterTransForSync(trans,parentId,true);


    transPaths=rmisf.transPaths(trans);


    [jnk,siblingIdx,isResolve]=rmiut.setmap(paths(transIdx),transPaths);%#ok
    objH=-1*ones(length(transIdx),1);
    objH(isResolve)=trans(siblingIdx);

end