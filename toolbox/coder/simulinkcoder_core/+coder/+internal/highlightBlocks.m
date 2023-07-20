function highlightBlocks(sids,varargin)




    if isempty(sids)
        return;
    elseif~iscell(sids)
        sids={sids};
    end


    model=strtok(sids{1},':');
    if~isempty(model)
        rtw.report.load_model_before_code2model(model,varargin{:});
    else
        return;
    end


    if slfeature('TraceVarSource')
        Simulink.URL.hilite('');
    else
        Simulink.ID.hilite('');
    end

    sids=unique(sids);
    try
        [sids,urls]=filterNonHilitableURLs(sids);
        Simulink.ID.hilite(sids,'find',true);
        Simulink.URL.hilite(urls);
    catch me
        myStage=Simulink.output.Stage(model,'ModelName',model,'UIMode',true);%#ok<NASGU>
        Simulink.output.error(me);
    end

    if numel(sids)>1
        lcs=rtw.report.getLowestCommonAncestor(sids);
        if~isempty(lcs)&&~allInSameSfBlock(sids)
            try
                editor=SLM3I.SLDomain.getLastActiveEditor();
                if~isempty(editor)
                    blockPath=simulinkcoder.internal.util.blockPathFromEditorAndHandle(editor,lcs);
                    blockPath.open('force','on');
                end
            catch
                open_system(lcs,'force');
            end
        end
    end


    function out=allInSameSfBlock(urls)
        out=false;
        if isempty(urls)
            return
        end
        if slfeature('TraceVarSource')
            sids=cellfun(@(x)strtok(x,'#'),urls,'UniformOutput',false);
        else
            sids=urls;
        end
        [h,~,blockH,~,~]=Simulink.ID.getHandle(sids);
        if~iscell(h)
            h={h};
            blockH={blockH};
        end
        isAllSfObj=all(cellfun(@(x)isa(x,'Stateflow.Object'),h));
        if isAllSfObj
            blockH=cell2mat(blockH);
            out=all(blockH==blockH(1));
        end

        function isValid=isValidSID(sidUrl)
            isValid=true;
            try
                sidUrl.eval;
            catch
                isValid=false;
            end

            function[sids,hilitableURLs]=filterNonHilitableURLs(urls)
                hilitableURLs={};
                sids={};
                for k=1:length(urls)
                    url=urls{k};
                    h=Simulink.URL.parseURL(url);
                    kind=class(h);
                    if kind=="Simulink.URL.PortURL"
                        hilitableURLs{end+1}=url;
                        sids{end+1,1}=h.getParent;

                    elseif kind=="Simulink.URL.SID"
                        if isValidSID(h)
                            sids{end+1,1}=url;
                        end
                    else
                        sids{end+1,1}=h.getParent;
                    end
                    sids=unique(sids);
                    hilitableURLs=unique(hilitableURLs);
                end
                sids=unique(sids);
                hilitableURLs=unique(hilitableURLs);




