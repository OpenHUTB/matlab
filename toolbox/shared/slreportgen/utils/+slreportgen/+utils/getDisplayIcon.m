function displayIcon=getDisplayIcon(obj)














    displayIcon=string.empty();

    if~isempty(obj)

        obj=slreportgen.utils.getSlSfObject(obj);
        if isa(obj,'Simulink.SubSystem')
            if(strcmp(obj.SfBlockType,'NONE')||isMasked(obj))
                displayIcon=getDisplayIcon(obj);
            else


                sfObjs=find(obj,'-isa','Stateflow.Object');
                nSfObjs=numel(sfObjs);
                for i=1:nSfObjs
                    sfObj=sfObjs(i);
                    if contains(class(sfObj),'Chart')
                        displayIcon=getDisplayIcon(sfObj);
                        break;
                    end
                end
            end

        elseif(isa(obj,'Stateflow.Chart')&&isMasked(obj))

            displayIcon='toolbox/shared/dastudio/resources/Chart.png';

        else
            displayIcon=getDisplayIcon(obj);
        end

        if~isempty(displayIcon)



            displayIcon=matlabroot+"/"+displayIcon;
            if ispc()
                displayIcon=replace(displayIcon,"/","\");
            end
        end
    end
end
