function node=uitreenode_deprecated(value,string,icon,isLeaf)





    warn=warning('query','MATLAB:uitreenode:DeprecatedFunction');
    if isequal(warn.state,'on')
        warning(message('MATLAB:uitreenode:DeprecatedFunction'));
    end

    import com.mathworks.hg.peer.UITreeNode;
    node=handle(UITreeNode(value,string,icon,isLeaf));
    schema.prop(node,'UserData','MATLAB array');
