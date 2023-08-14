function comp=component(this,varargin)







    arg=this.componentArg(varargin);

    comp=arg.Component;

    this.ChildNode{end+1}=comp;


    this.addChildren(comp);


    if isa(comp,'eda.internal.component.BlackBox')
        if isfield(arg,'UniqueName')
            comp.UniqueName=arg.UniqueName;
            arg=rmfield(arg,'UniqueName');
        end
        if isfield(arg,'InstName')
            comp.InstName=arg.InstName;
            arg=rmfield(arg,'InstName');
        else
            comp.InstName=arg.Name;
            arg=rmfield(arg,'Name');
        end

    else
        if isfield(arg,'UniqueName')
            comp.UniqueName=arg.UniqueName;
            arg=rmfield(arg,'UniqueName');
        end
        if isfield(arg,'InstName')
            comp.InstName=arg.InstName;
            arg=rmfield(arg,'InstName');
        else
            comp.InstName=arg.Name;
            arg=rmfield(arg,'Name');
        end
    end

    arg=rmfield(arg,'Component');

    this.setSignalSrcDst(arg);

end


