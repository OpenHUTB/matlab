function Name=findSignalName(this,propName,mode)





    if strcmpi(mode,'componentInst')
        if isa(this.(propName).signal,'eda.internal.component.Signal')
            Name=this.(propName).signal.UniqueName;
        elseif isa(this.(propName).signal,'eda.internal.component.Port')
            parent=this.getParent;
            if parent.flatten&&parentIsNotTopModule(parent)
                propName=this.(propName).signal.UniqueName;

                Name=findSignalName(parent,propName,'componentInst');
            else
                Name=this.(propName).signal.UniqueName;
            end
        end

    else
        if this.flatten
            parent=this.getParent;
            if parent.flatten&&parentIsNotTopModule(parent)
                propName=this.(propName).signal.UniqueName;

                Name=findSignalName(parent,propName,'componentDecl');
            else
                Name=this.(propName).signal.UniqueName;
            end
        else
            Name=this.(propName).UniqueName;
        end
    end

end


function status=parentIsNotTopModule(parent)
    if isempty(parent.getParent)
        status=false;
    else
        status=true;
    end
end

