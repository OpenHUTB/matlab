function propagateCodeGenProp(this)







    if~strcmpi(this.Partition.Type,'MIXED')&&~isempty(this.getParent)
        if isempty(this.Partition.Lang)
            parentLang=this.findLang;
            if isempty(parentLang)
                error(message('EDALink:Node:propagateCodeGenProp:LangNotSpecifiedInAnyLevel'));
            else
                this.Partition.Lang=parentLang;
                comps=this.ChildNode;
                for i=1:length(comps)
                    comp=comps{i};
                    propagateCodeGenProp(comp);
                end
            end
        else

            if~isempty(this.getParent)
                parentLang=this.findLang;
                if~strcmpi(this.Partition.Lang,parentLang);

                    if isa(this,'eda.internal.component.BlackBox')&&~isempty(this.findprop('wrapperFileNeeded'))
                        this.Partition.Lang=parentLang;
                    elseif isa(this,'eda.internal.component.WhiteBox')&&this.flatten
                        error(message('EDALink:Node:propagateCodeGenProp:LangNotCombined'));
                    end
                end
            end
        end
    elseif strcmpi(this.Partition.Type,'MIXED')&&~isempty(this.getParent)

    elseif strcmpi(this.Partition.Type,'MIXED')&&isempty(this.getParent)

    else
        if isempty(this.Partition.Lang)
            error(message('EDALink:Node:propagateCodeGenProp:LangNotSpecifiedAtTop'));
        else
            comps=this.ChildNode;
            for i=1:length(comps)
                comp=comps{i};
                propagateCodeGenProp(comp);
            end
        end
    end

