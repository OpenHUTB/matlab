function attachToConfigSet(this,configSet)




    ;

    if isempty(this.getParent)





        mdl=configSet.getModel;
        mdlDirtyFlag=cache_dirty(mdl);










        csComponents=configSet.Components;
        csNames=get(csComponents,'Name');


        thisComponents=this.Components;
        thisNames=get(thisComponents,'Name');
        if~iscell(thisNames)
            thisNames={thisNames};
        end


        changed=false;

        for thisIdx=1:length(thisNames)


            thisComponentName=thisNames{thisIdx};
            csIdx=find(strcmp(csNames,thisComponentName));

            if~isempty(csIdx)


                thisComponents(thisIdx)=csComponents(csIdx);
                configSet.detachComponent(thisComponentName);

                changed=true;



            end

        end


        if changed





            cacheComponentsAttached=this.ComponentsAttached;

            this.detachAllSubComponents;
            for idx=1:length(thisComponents)
                this.attachComponent(thisComponents(idx));
            end

            this.ComponentsAttached=cacheComponentsAttached;

        end








        configSet.attachComponent(this);


        cache_dirty(mdl,mdlDirtyFlag);

    end


