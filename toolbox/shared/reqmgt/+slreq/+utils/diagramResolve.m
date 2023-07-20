function[outer,inner]=diagramResolve(obj)









    outer=diagram.resolver.resolve(obj);
    inner=[];

    if(strcmp(outer.resolutionDomain,'simulink'))
        if(~outer.isDiagram)


            if is_subsystem(obj)
                if is_stateflow_block(obj)


                    chartId=sfprivate('block2chart',obj);
                    inner=diagram.resolver.resolve(chartId);
                else

                    inner=diagram.resolver.resolve(obj,'diagram');

                    outerObj=slreq.utils.getRMISLTarget(obj,true);
                    if outerObj~=obj

                        outer=diagram.resolver.resolve(outerObj);
                    end
                end
            end
        end
    else

        if isa(obj,'double')
            rt=sfroot;
            obj=rt.idToHandle(obj);
        end

        if is_subcharted_state(obj)
            inner=diagram.resolver.resolve(obj,'diagram');
        elseif is_supertransition(obj)


            allSubTranObj=slreq.utils.getTransitionViewerList(obj.Id);
            inner=diagram.Object.empty;
            for index=1:length(allSubTranObj)
                subTranId=allSubTranObj(index).subtranID;
                inner(end+1)=diagram.resolver.resolve(subTranId);
            end
        end
    end
end



function out=is_stateflow_block(obj)
    out=slprivate('is_stateflow_based_block',obj);
end

function out=is_subsystem(obj)
    try
        out=isa(obj,'double')&&strcmp(get_param(obj,'BlockType'),'SubSystem');
    catch MX
        out=false;
    end
end

function out=is_subcharted_state(obj)
    out=false;
    try
        out=obj.IsSubchart;
    catch Mx
    end
end

function out=is_supertransition(obj)
    out=false;
    try
        out=~isa(obj,'double')&&sf('get',obj.Id,'trans.type')==1;
    catch ex %#ok<NASGU>
    end
end

