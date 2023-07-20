function setMaskDlgParams(this,slBlockName,pv)






    if~isempty(pv)



        pv=pv';



        pv=pv(:)';



        if strcmp(get_param(slBlockName,'BlockType'),'SubSystem')
            containsRefSubsystem=contains(pv,'ReferencedSubsystem');
            if(any(containsRefSubsystem))
                refSubsystemIndex=find(containsRefSubsystem);
                pv{refSubsystemIndex+1}='';
            end
        end


        c=[{'set_param',slBlockName},pv];


        feval(c{:});
    end
end
