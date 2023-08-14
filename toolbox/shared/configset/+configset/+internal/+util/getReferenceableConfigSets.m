function[out,refList,csList,refExtra,csExtra]=getReferenceableConfigSets(ref)













    out={};
    csList={};
    refList={};
    csExtra={};
    refExtra={};

    if~isa(ref,'Simulink.ConfigSetRef')

        return
    end



    csList=configset.internal.util.getConfigSetList(ref.DDName);
    out=csList;


    source=ref.getConfigSetSource;
    attachedToModel=isa(ref.up,'Simulink.BlockDiagram')||...
    (isa(source,'Simulink.ConfigSetRef')&&isa(source.up,'Simulink.BlockDiagram'));
    if attachedToModel
        refList=configset.internal.util.getConfigSetList(...
        ref.DDName,'Simulink.ConfigSetRef');
        out=[refList,out];
    end



    if~isempty(ref.DDName)
        try
            dd=Simulink.data.dictionary.open(ref.DDName);
        catch

            return
        end
        c=onCleanup(@()close(dd));

        EnableAccessToBaseWorkspace=false;
        model=ref.getModel;
        if~isempty(model)
            EnableAccessToBaseWorkspace=strcmp(get_param(model,'EnableAccessToBaseWorkspace'),'on');
        end

        if dd.HasAccessToBaseWorkspace||EnableAccessToBaseWorkspace


            csExtra=configset.internal.util.getConfigSetList('');
            csExtra=setdiff(csExtra,out,'stable');
            list=csExtra;

            if attachedToModel
                refExtra=configset.internal.util.getConfigSetList('','Simulink.ConfigSetRef');
                refExtra=setdiff(refExtra,out,'stable');
                list=[refExtra,list];
            end
            out=[out,setdiff(list,out,'stable')];
        end
    end
