function hilite(sid,scheme,studioReuse)




    persistent last_sid;

    narginchk(1,3);

    if nargin<2
        scheme='find';
    end
    if nargin<3






        studioReuse=false;
    end

    sid=convertStringsToChars(sid);
    if~iscell(sid)
        sid={sid};
    end
    [h,aux,sidSpace,msg,msgargs]=Simulink.ID.getHandle(sid);


    if~isempty(last_sid)
        [h_last,aux_last,sidSpace_last,msg_last]=...
        Simulink.ID.getHandle(last_sid);
        if~iscell(h_last)
            h_last={h_last};
        end
        for k=1:length(last_sid)
            if isempty(msg_last{k})
                if isa(h_last{k},'Stateflow.Object')
                    locHiliteSfObj(h_last{k},aux_last{k},sidSpace_last{k},...
                    'none',studioReuse);
                    set_param(sidSpace_last{k},'HiliteAncestors','none');
                else
                    set_param(h_last{k},'HiliteAncestors','none');
                    sfUddH=locGetStateflowObject(h_last{k});
                    if~isempty(sfUddH)
                        locHiliteSfObj(sfUddH,aux_last{k},sidSpace_last{k},'none',studioReuse);
                    end
                end
            end
        end
    end

    last_sid=[];
    if length(sid)==1&&isempty(sid{1})
        return
    end

    for k=1:length(msg)
        if~isempty(msg{k})
            DAStudio.error(msg{k},msgargs{k}{:});
        end
    end

    sfObjIdx=[];
    emlFcnIdx=[];
    if~iscell(h)
        h={h};
    end
    for k=1:length(h)
        if isa(h{k},'Stateflow.Object')
            isMultiHighlightable=isa(h{k},'Stateflow.State')...
            ||isa(h{k},'Stateflow.Transition')...
            ||isa(h{k},'Stateflow.Junction');


            if isMultiHighlightable
                sfObjIdx(end+1)=k;%#ok<AGROW>
            else
                objectId=h{k}.Id;
                isEmlFcn=(sfprivate('is_eml_based_chart',objectId)||...
                sfprivate('is_eml_based_fcn',objectId))...
                &&~isempty(aux{k})&&...
                ~sfprivate('is_eml_truth_table_fcn',objectId);
                if isEmlFcn
                    emlFcnIdx(end+1)=k;%#ok<AGROW>
                else
                    set_param(sidSpace{k},'HiliteAncestors',scheme);
                    locHiliteSfObj(h{k},aux{k},sidSpace{k},scheme,studioReuse);
                end
            end
        else
            loc_hilite_system(h{k},scheme,studioReuse);
            sfUddH=locGetStateflowObject(h{k});
            if~isempty(sfUddH)
                if isa(sfUddH,'Stateflow.SLFunction')

                    if~strcmp(scheme,'none')
                        open_system(h{k});
                    end
                else
                    locHiliteSfObj(sfUddH,aux{k},sidSpace{k},scheme,studioReuse);
                end
            end
        end
    end

    if~isempty(emlFcnIdx)
        blockH=cell2mat(sidSpace(emlFcnIdx));
        sfprivate('sfHighlightEml',blockH,h(emlFcnIdx),sid(emlFcnIdx));
    end

    if~isempty(sfObjIdx)>0
        blockH=cell2mat(sidSpace(sfObjIdx));
        objH=h(sfObjIdx);
        auxInfo=aux(sfObjIdx);
        if numel(objH)==1
            set_param(blockH(1),'HiliteAncestors',scheme);
            locHiliteSfObj(objH{1},auxInfo{1},blockH(1),scheme,studioReuse);
        else

            [blockH,idx]=sort(blockH);
            objH=objH(idx);

            start=1;
            for i=2:numel(blockH)
                if blockH(i)~=blockH(i-1)
                    set_param(blockH(start),'HiliteAncestors',scheme);
                    sfprivate('sfHighlightObjects',blockH(start),objH(start:i-1));
                    start=i;
                end
            end
            set_param(blockH(start),'HiliteAncestors',scheme);
            sfprivate('sfHighlightObjects',blockH(start),objH(start:end));
        end
    end
    last_sid=sid;

    function locHiliteSfObj(h,aux,sidSpace,scheme,studioReuse)


        if(isa(h,'Stateflow.Data'))
            parent=h.up;
            if(isa(parent,'Stateflow.SLFunction'))
                h=find_system(parent.getDialogProxy.Handle,...
                'SearchDepth',1,'Name',h.Name);
                loc_hilite_system(h,scheme,studioReuse);

                return
            end
            if~strcmp(scheme,'none')
                modelName=find_system('type','block_diagram','name',strtok(h.getFullName,'/'));
                isModelNotOpen=isempty(modelName)||strcmp(get_param(modelName,'Open'),'off');
                if isModelNotOpen
                    open_system(modelName);
                end
            end
        end
        if~strcmp(scheme,'none')
            sfprivate('sfOpenObjectByHandle',h,aux,sidSpace);
        else
            sfprivate('traceabilityManager','unHighlightObject',h);
        end




        function out=locGetStateflowObject(h)
            out=Stateflow.SLUtils.getStateflowUddH(get_param(h,'Object'));


            function loc_hilite_system(h,scheme,studioReuse)
                isBlockDiagram=strcmp(get_param(h,'Type'),'block_diagram');
                if studioReuse
                    try
                        editor=SLM3I.SLDomain.getLastActiveEditor();
                        if~isempty(editor)
                            blockPath=simulinkcoder.internal.util.blockPathFromEditorAndHandle(editor,h);
                            if isBlockDiagram
                                blockPath.open;
                            else
                                hilite_system(blockPath,scheme);
                            end
                            return
                        end
                    catch
                    end
                end
                if isBlockDiagram
                    open_system(h);
                else
                    hilite_system(h,scheme);
                end



