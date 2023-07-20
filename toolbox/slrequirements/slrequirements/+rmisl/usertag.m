function[total_objects,total_links,varargout3,varargout4]=usertag(modelH,method,tag,varargin)















    if~strcmp(method,'list')
        if builtin('_license_checkout','Simulink_Requirements','quiet')
            error(message('Slvnv:vnv_panel_mgr:ReqLicenseRequired'));
        end
    end


    objects=rmi('getobjwithreqs',modelH);
    total_objects=length(objects);
    total_links=0;
    modified_objects=0;
    affected_links=0;
    tag_strings={};
    tag_counts=[];
    if total_objects>0

        for obj=objects'
            reqs=rmi('get',obj);
            modified=false;
            to_be_cleared=[];

            for i=1:length(reqs)
                total_links=total_links+1;

                keywords=reqs(i).keywords;
                tags=string2cell(keywords);

                switch(method)
                case 'add'
                    if~any(strcmpi(tags,tag))&&(isempty(varargin)||~isempty(regexpi(reqs(i).doc,varargin{1})))
                        new_tags=[tags;tag];
                        reqs(i).keywords=cell2string(sort(new_tags));
                        affected_links=affected_links+1;
                        modified=true;
                    end
                case 'delete'
                    matched=strcmpi(tags,tag);
                    if any(matched)&&(isempty(varargin)||~isempty(regexpi(reqs(i).doc,varargin{1})))
                        tags(matched)=[];
                        reqs(i).keywords=cell2string(sort(tags));
                        affected_links=affected_links+1;
                        modified=true;
                    end
                case 'replace'
                    matched=strcmpi(tags,tag);
                    if any(matched)&&(length(varargin)==1||~isempty(regexpi(reqs(i).doc,varargin{2})))
                        if any(strcmpi(tags,varargin{1}))
                            tags(matched)=[];
                        else
                            tags{matched}=varargin{1};
                        end
                        reqs(i).keywords=cell2string(sort(tags));
                        affected_links=affected_links+1;
                        modified=true;
                    end
                case 'clear'
                    if any(strcmpi(tags,tag))&&(isempty(varargin)||~isempty(regexpi(reqs(i).doc,varargin{1})))
                        to_be_cleared(end+1)=i;%#ok
                        affected_links=affected_links+1;
                        modified=true;
                    end
                case 'list'
                    for j=1:length(tags)
                        tag=tags{j};
                        match=strcmp(tag_strings,tag);
                        if any(match)
                            tag_counts(match)=tag_counts(match)+1;%#ok<AGROW>
                        else
                            tag_strings{end+1}=tag;%#ok<AGROW>
                            tag_counts(end+1)=1;%#ok<AGROW>
                        end
                    end
                otherwise
                    error(message('Slvnv:reqmgt:rmi_tag:UnsupportedMethod',method));
                end

            end

            if modified

                if isempty(to_be_cleared)



                    if rmisl.is_signal_builder_block(obj)
                        rmi('set',obj,reqs,1,length(reqs));
                    else
                        rmi('set',obj,reqs);
                    end
                else


                    if rmisl.is_signal_builder_block(obj)
                        pruneSigBuilderReqs(obj,reqs,to_be_cleared);
                    else
                        reqs(to_be_cleared)=[];
                        rmi('set',obj,reqs);
                    end
                end

                modified_objects=modified_objects+1;
            end

        end
    end

    if strcmp(method,'list')
        varargout3=tag_strings;
        varargout4=tag_counts;
    else
        varargout3=modified_objects;
        varargout4=affected_links;
    end
end


function pruneSigBuilderReqs(obj,reqs_all,clear_in_all)




    fromWsH=find_system(obj,'FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all',...
    'BlockType','FromWorkspace');
    blkInfo=get_param(fromWsH,'VnvData');


    if isfield(blkInfo,'groupCnt')&&~isempty(blkInfo.groupCnt)&&...
        isfield(blkInfo,'groupReqCnt')&&~isempty(blkInfo.groupReqCnt)


        if sum(blkInfo.groupReqCnt)~=length(reqs_all)
            warning(message('Slvnv:reqmgt:rmi_tag:InconsistentInfo',get_param(obj,'Name')));
        elseif length(blkInfo.groupReqCnt)~=blkInfo.groupCnt
            warning(message('Slvnv:reqmgt:rmi_tag:InconsistentInfo',get_param(obj,'Name')));
        else


            groupReqCnt=blkInfo.groupReqCnt;
            for group=1:blkInfo.groupCnt
                offset=sum(groupReqCnt(1:group-1));
                range=offset+1:offset+groupReqCnt(group);
                clear_in_group=intersect(clear_in_all,range);
                if~isempty(clear_in_group)
                    blkInfo.groupReqCnt(group)=blkInfo.groupReqCnt(group)-length(clear_in_group);
                end
            end


            reqs_all(clear_in_all)=[];
            rmi('set',obj,reqs_all,1,sum(groupReqCnt));


            set_param(fromWsH,'VnvData',blkInfo);


            jPanel=sigb_get_jpanel(obj);
            if~isempty(jPanel)
                currentGroup=blkInfo.activeGroup;
                if blkInfo.groupReqCnt(currentGroup)==0
                    jPanel.setAllReqStrs({});
                else
                    offset=sum(blkInfo.groupReqCnt(1:currentGroup-1));
                    updatedLabels=rmi('descriptions',obj,offset+1,blkInfo.groupReqCnt(currentGroup));
                    jPanel.setAllReqStrs(updatedLabels);
                end
            end
        end
    else
        warning(message('Slvnv:reqmgt:rmi_tag:InvalidInfo',get_param(obj,'Name')));
    end
end


function jPanel=sigb_get_jpanel(blockH)
    jPanel=[];
    dialogH=get_param(blockH,'UserData');
    if~isempty(dialogH)&&ishandle(dialogH)
        UD=get(dialogH,'UserData');
        if UD.current.isVerificationVisible
            jPanel=UD.verify.jVerifyPanel;
        end
    end
end


function cell_array=string2cell(string)
    trimmed=strtrim(string);
    cell_array=sort(strread(trimmed,'%s','delimiter',','));%#ok<DSTRRD>
end

function result=cell2string(cell_array)
    string='';
    for i=1:length(cell_array)
        string=[string,', ',cell_array{i}];%#ok
    end
    result=string(2:end);
end

