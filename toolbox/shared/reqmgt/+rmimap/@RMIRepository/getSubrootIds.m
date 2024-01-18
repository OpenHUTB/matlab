function subrootIds=getSubrootIds(this,mdlName,varargin)

    if isempty(varargin)
        rootType='linktype_rmi_matlab';
    else
        rootType=varargin{1};
    end

    subrootIds={};
    srcRoot=rmimap.RMIRepository.getRoot(this.graph,mdlName);
    if isempty(srcRoot)
        return;
    end
    for i=2:srcRoot.nodeData.size
        ndData=srcRoot.nodeData.at(i);
        if strcmp(ndData.getValue('source'),rootType)
            id=ndData.getValue('id');
            subRootName=[mdlName,id];
            if this.rootHasLinks(subRootName)
                subrootIds{end+1}=id;%#ok<AGROW>
            end
        end
    end
end


