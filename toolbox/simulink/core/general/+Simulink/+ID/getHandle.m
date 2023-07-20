function[out,varargout]=getHandle(sid)

















    narginchk(1,1);

    if nargout<=1

        try
            if iscell(sid)
                out=cellfun(@locSid2HandleNoCheck,sid,'UniformOutput',false);
            elseif isstring(sid)&&~isscalar(sid)
                out=arrayfun(@locSid2HandleNoCheck,sid,'UniformOutput',false);
            else
                out=locSid2HandleNoCheck(sid);
            end
            return
        catch
        end
    end

    sid=convertStringsToChars(sid);
    if~iscell(sid)
        [out,aux,hSidSpace,msg,msgargs]=locSid2Handle(sid);
    else

        out=cell(size(sid));
        aux=cell(size(sid));
        hSidSpace=cell(size(sid));
        msg=cell(size(sid));
        msgargs=cell(size(sid));
        for k=1:length(sid)
            [out{k},aux{k},hSidSpace{k},msg{k},msgargs{k}]=locSid2Handle(sid{k});
        end
    end


    if nargout>1
        varargout{1}=aux;
    end


    if nargout>2
        varargout{2}=hSidSpace;
    end


    if nargout>3
        varargout{3}=msg;
        if nargout>4
            varargout{4}=msgargs;
        end
    else
        if iscell(msg)&&~isempty(msg)
            idx=find(~strcmp(msg,''));
            if~isempty(idx)
                msg=msg{idx(1)};
                msgargs=msgargs{idx(1)};
            else
                msg='';
                msgargs={};
            end
        end
        if~isempty(msg)
            throw(MException(message(msg,msgargs{:})));
        end
    end





    function out=locSid2HandleNoCheck(sid)

        out=[];
        if(ischar(sid)||isStringScalar(sid))&&~any(strfind(sid,'/'))
            [out,remainder]=Simulink.SIDSpace.getHandle(sid);
            if~isempty(remainder)
                chartId=sfprivate('block2chart',out);
                activeInstance=sfprivate('getActiveInstance',chartId);

                if~isequal(activeInstance,out)
                    sfprivate('setActiveInstance',chartId,...
                    out);
                end

                out=sfprivate('ssIdToHandle',[':',remainder],out);
            end
        end
        if isempty(out)
            throw(MException('Simulink:utility:SIDSyntaxError','',''));
        end


        function[out,aux,hSidSpace,msg,msgargs]=locSid2Handle(sid)

            out=[];
            aux='';
            hSidSpace=[];
            msg='';
            msgargs={};


            idx=Simulink.ID.checkSyntax(sid);
            if~isempty(idx)
                msg='Simulink:utility:SIDSyntaxError';
                if idx>0
                    msgargs={sid,sid(idx:end)};
                else
                    msgargs={'',''};
                end
                return
            end



            if contains(sid,',#')
                sid=sid(1:strfind(sid,',#')-1);
            end
            delim=':';
            [mdl,next]=strtok(sid,delim);

            hSidSpace=[];
            try
                hSidSpace=get_param(mdl,'handle');
            catch
            end
            if isempty(hSidSpace)
                msg='Simulink:utility:modelNotLoaded';
                msgargs={mdl};
                return
            end

            if isempty(next)

                out=hSidSpace;
                return
            end


            while~isempty(next)
                current=next;
                hidden=false;
                if strncmp(current,'::',2)
                    hidden=true;
                end
                if hidden&&~locIsHiddenSIDSpace(hSidSpace)
                    msg='Simulink:utility:SIDSyntaxError';
                    msgargs={sid,current};
                    return
                end
                if~hidden&&locIsStateflow(hSidSpace)

                    chartId=sfprivate('block2chart',hSidSpace);
                    activeInstance=sfprivate('getActiveInstance',chartId);
                    if~isequal(activeInstance,hSidSpace)
                        sfprivate('setActiveInstance',chartId,...
                        hSidSpace);
                    end
                    [out,aux]=sfprivate('ssIdToHandle',current,hSidSpace);
                    if isempty(out)
                        msg='Simulink:utility:invalidSID';
                        msgargs={sid,current};
                    end
                    return
                end
                if~hidden&&locIsConfigSS(hSidSpace)

                    hiddenLink=[getfullname(hSidSpace),'/'...
                    ,strrep(get_param(hSidSpace,'BlockChoice'),'/','//')];
                    hSidSpace=get_param(hiddenLink,'Handle');
                end

                [sidNumber,next]=strtok(current,delim);

                if~isempty(sidNumber)
                    sidNumber=str2double(sidNumber);
                    if sidNumber==0


                        out=[];
                        return
                    end
                end


                out=locFindSystem(hSidSpace,sidNumber);


                watermark=str2double(get_param(hSidSpace,'SIDHighWatermark'));
                if isempty(out)
                    if sidNumber>watermark||sidNumber==0
                        msg='Simulink:utility:invalidSID';
                        msgargs={sid,sid(1:end-length(next))};
                    elseif locIsOutsideLink(hSidSpace,sidNumber)

                        msg='Simulink:utility:invalidSID';
                        msgargs={sid,sid(1:end-length(next))};
                    else
                        msg='Simulink:utility:objectDestroyed';
                        msgargs={};
                    end
                    return;
                end
                assert(length(out)==1);


                if~isempty(next)
                    if locBlockHasSIDSpace(out)
                        hSidSpace=out;
                    else
                        msg='Simulink:utility:invalidSIDSpace';
                        msgargs={sid};
                        return
                    end
                end
            end

            function out=locIsHiddenSIDSpace(hSidSpace)

                out=locIsConfigSS(hSidSpace)||locIsStateflow(hSidSpace);


                function out=locFindSystem(h,sid)

                    out=[];
                    hSIDSpace=get_param(h,'SIDSpace');
                    if isa(hSIDSpace,'Simulink.SIDSpace')
                        out=hSIDSpace.find(sid);
                    end


                    function out=locBlockHasSIDSpace(blk)


                        out=strcmp(get_param(blk,'Type'),'block')&&...
                        strcmp(get_param(blk,'BlockType'),'SubSystem')&&...
                        ~isempty(get_param(blk,'SIDHighWatermark'));


                        function out=locIsStateflow(block)

                            out=strcmp(get_param(block,'type'),'block')&&...
                            slprivate('is_stateflow_based_block',block);


                            function out=locIsConfigSS(block)




                                if strcmp(get_param(block,'type'),'block')
                                    template=get_param(block,'TemplateBlock');
                                    out=template~=""&&template~="self"&&template~="master";
                                else
                                    out=false;
                                end


                                function out=locIsOutsideLink(sidSpace,sidNumber)
                                    out=false;
                                    if~strcmp(get_param(sidSpace,'type'),'block')
                                        return
                                    end
                                    if~strcmp(get_param(sidSpace,'LinkStatus'),'resolved')
                                        return
                                    end

                                    libblk=get_param(sidSpace,'ReferenceBlock');
                                    hSIDSpace=get_param(libblk,'SIDSpace');
                                    if isempty(hSIDSpace)
                                        hSIDSpace=get_param(libblk,'SIDSpaceParent');
                                    end
                                    if~isempty(hSIDSpace.find(sidNumber))
                                        out=true;
                                    end



