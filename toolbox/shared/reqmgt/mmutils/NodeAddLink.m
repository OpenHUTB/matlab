function link=NodeAddLink(this,otherEnd)



    link=rmidd.Link(this.modelM3I);



    if(isa(this,'rmidd.Root'))
        link.root=this;
    else
        link.root=this.root;
    end


    link.root.changed=true;


    link.dependeeNode=otherEnd;
    link.dependentNode=this;

end

