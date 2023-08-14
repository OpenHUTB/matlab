function componentSet(obj,arg)








    if~isempty(arg)
        fields=fieldnames(arg);
        for i=1:length(fields)
            prop=obj.findprop(fields{i});
            if~isempty(prop)
                if~isempty(arg.(fields{i}))
                    if isa(obj.(prop.Name),'eda.internal.component.Inport')||isa(obj.(prop.Name),'eda.internal.component.Outport')

                        obj.(prop.Name).signal=arg.(fields{i});

                    else
                        if isa(arg.(fields{i}),'struct')
                            obj.(fields{i})=arg.(fields{i}).Name;
                        else
                            obj.(fields{i})=arg.(fields{i});
                        end
                    end
                end
            end
        end
    end
