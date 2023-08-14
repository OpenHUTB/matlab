function init(this)




    this.syncContentToSelectedBlock(true);

    name=['CoverageDetailsWindow_',this.hStudio.getStudioTag,'_',this.covMode];


    oldComp=this.hStudio.getComponent('GLUE2:DDG Component',name);
    if~isempty(oldComp)
        this.hStudio.destroyComponent(oldComp);
    end


    comp=GLUE2.DDGComponent(this.hStudio,name,this);
    this.hStudio.registerComponent(comp);
    comp.PersistState=false;
    comp.ExplicitShow=false;

    if this.hStudio.isStudioVisible()
        title=getString(message('Slvnv:simcoverage:cvmodelview:CoverageDetailsWindow'));
        if this.hasMultipleTypes
            title=[title,' (',this.covMode,')'];
        end
        this.hStudio.moveComponentToDock(comp,title,'Right','Tabbed');
    end
    this.hDDGComponent=comp;
end