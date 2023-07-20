function row=getDependencyRow(this,dependency,isDownstream,docType)





    if isDownstream
        node=dependency.DownstreamNode;
    else
        node=dependency.UpstreamNode;
    end
    index=find(node==this.FileNodes);
    fileName=this.getFileName(index,docType);
    upComp=getUpstreamComponent(dependency,docType);
    downComp=getDownstreamComponent(dependency,docType);
    row={fileName,upComp,downComp,dependency.Type.Leaf.Name};
end
