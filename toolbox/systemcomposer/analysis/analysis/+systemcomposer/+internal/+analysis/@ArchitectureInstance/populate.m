function populate(this)
    specification=this.specification;

    root=this.addInstanceForSpecification(specification);
    root.setName(this.getName);
    this.root=root;

    this.root.populateDescendants();
end

