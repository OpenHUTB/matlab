function disConnectComponent(this,property,value,Node)








    if nargin<3
        root=this;
    elseif strcmpi(Node,'rootNode')
        root=this.findTreeRoot;
    else

    end

    recursiveSearch(root,property,value);

end


function recursiveSearch(this,property,value)

    children=this.getChildren;
    tmp='';
    for i=1:length(children)
        if strcmpi(property,'Class')
            if isa(children(i),class(value))
                child=children(i);
                child.disconnect;
                for ii=1:length(this.ChildNode)
                    if this.ChildNode{ii}~=child
                        tmp{end+1}=this.ChildNode{ii};%#ok<AGROW>
                    end
                end
                this.ChildNode=tmp;
            else
                recursiveSearch(children(i),property,value);
            end
        elseif strcmpi(children(i).(property),value)
                child=children(i);
                child.disconnect;
                for ii=1:length(this.ChildNode)
                    if this.ChildNode{ii}~=child
                        tmp{end+1}=this.ChildNode{ii};%#ok<AGROW>
                    end
                end
                this.ChildNode=tmp;
            else
                recursiveSearch(children(i),property,value);
            end
        end
    end
end
