function highlightReqChanges(objH,isSf,reqs,rmi_highlighting_on)
    filterSettings=rmi.settings_mgr('get','filterSettings');
    if filterSettings.enabled
        reqs=rmi.filterTags(reqs,filterSettings.tagsRequire,filterSettings.tagsExclude);
    end

    if isSf

        if isempty(reqs)||~any([reqs.linked])

            if rmi_highlighting_on

                if sf('get',objH,'.isa')~=1
                    sf_update_style(objH,'off');
                end

            end

            unhighlight_parent_block=true;
            chartId=obj_chart(objH);
            chartBlock=sf('Private','chart2block',chartId);
            if rmi.objHasReqs(chartBlock,filterSettings)
                unhighlight_parent_block=false;
            elseif rmi.objHasReqs(chartId,filterSettings)
                unhighlight_parent_block=false;
            else
                sfFilter=rmisf.sfisa('isaFilter');
                sfr=sfroot;
                chartObj=sfr.idToHandle(chartId);
                sfObjects=find(chartObj,sfFilter);
                for i=2:length(sfObjects)
                    Chart=sfObjects(i).Chart;
                    if strncmp(class(Chart),'Stateflow.',length('Stateflow.'))...
                        &&Chart.Id==chartId...
                        &&rmi.objHasReqs(sfObjects(i).Id,filterSettings)
                        unhighlight_parent_block=false;
                        break;
                    end
                end
            end
            if unhighlight_parent_block
                set_param(chartBlock,'HiliteAncestors','off');
            end

        else

            if rmi_highlighting_on
                target_chart=sf_update_style(objH,'req');
                chartBlock=sf('Private','chart2block',target_chart);
                if~rmi.objHasReqs(chartBlock,filterSettings)
                    set_param(chartBlock,'HiliteAncestors','reqInside');
                end

            end
        end

    else

        if isempty(reqs)||~any([reqs.linked])

            if rmi_highlighting_on
                set_param(objH,'HiliteAncestors','off');
            end

        else

            if rmi_highlighting_on

                if rmisl.is_signal_builder_block(objH)||strcmp(get_param(objH,'Type'),'annotation')
                    set_param(objH,'HiliteAncestors','reqInside');
                else
                    set_param(objH,'HiliteAncestors','reqHere');
                end
            end

        end

        if rmi_highlighting_on
            slInSf=SlInSf(objH);
            if~isempty(slInSf)

                try
                    slInSfObject=get_param(slInSf,'Object');
                    sfBox=Stateflow.SLUtils.getStateflowUddH(slInSfObject);
                    slInSfSubsysColor=slInSfObject.hiliteAncestors;
                    switch slInSfSubsysColor
                    case{'reqHere','reqInside'}
                        sf_update_style(sfBox.Id,'req');
                    case{'none','fade'}
                        sf_update_style(sfBox.Id,'off');
                    end
                catch ex %#ok<NASGU>
                end
            end
        end

    end
end


function slInSf=SlInSf(myPath)
    slInSf='';
    if~ischar(myPath)
        parentPath=get_param(myPath,'Parent');
    else
        tmpPath=strrep(myPath,'//','^^');
        separators=strfind(tmpPath,'/');
        if length(separators)>1
            parentPath=myPath(1:separators(end)-1);
        else
            return;
        end
    end
    if slprivate('is_stateflow_based_block',parentPath)
        slInSf=myPath;
    else
        slInSf=SlInSf(parentPath);
    end
end

