function subcomponent=getSubComponent(this,name)













    ;

    subcomponent=[];




    if strcmp(this.Name,name)

        subcomponent=this;
        return;

    end;







    for idx=1:length(this.Components)
        aComponent=this.Components(idx);
        if~isempty(aComponent)

            if any(strcmp(methods(aComponent),'getSubComponent'))


                subcomponent=[subcomponent,aComponent.getSubComponent(name)];

            else


                if strcmp(aComponent.Name,name)

                    subcomponent=[subcomponent,aComponent];

                end

            end

        end

    end





