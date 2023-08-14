function produce_navigation_table(this,nodeEntry,uncovIdArray,options)








    printIt(this,'<table>\n');

    firstSystem=false;
    if isfield(nodeEntry,'sysNum')
        firstSystem=1==nodeEntry.sysNum;
    end


    if~firstSystem&&nodeEntry.sysCvId>0

        allSysIds=[this.cvstruct.system.cvId];
        sysId=nodeEntry.sysCvId;
        while~any(sysId==allSysIds)
            sysId=cv('get',sysId,'.treeNode.parent');
            if~sysId
                sysId=nodeEntry.sysCvId;
                break;
            end
        end
        printIt(this,'  <tr><td width="150"><b>%s </b></td>\n',getString(message('Slvnv:simcoverage:cvhtml:Parent')));
        printIt(this,'      <td>%s</td></tr>\n',obj_full_path_link(sysId));
    end

    if isfield(nodeEntry,'subsystemCvId')&&~isempty(nodeEntry.subsystemCvId)
        printIt(this,'  <tr align="top"><td width="150"><b>%s </b></td>\n',getString(message('Slvnv:simcoverage:cvhtml:ChildSystems')));
        printIt(this,'      <td>');
        childStr=[];
        for childId=nodeEntry.subsystemCvId(:)'
            childStr=[childStr,obj_named_link(childId),', &#160;'];
        end
        printIt(this,'%s</td></tr>\n',childStr(1:(end-8)));
    end

    if(nodeEntry.flags.leafUncov==1)&&(1<numel(uncovIdArray))
        printIt(this,'  <tr><td><b>%s </b></td>\n',getString(message('Slvnv:simcoverage:cvhtml:UncoveredLinks')));
        printIt(this,'      <td>%s</td></tr>\n',generate_uncov_links(nodeEntry.cvId,uncovIdArray,options));
    end

    printIt(this,'</table>\n');





    function out=obj_named_link(id)
        if(id==0)
            out=getString(message('Slvnv:simcoverage:cvhtml:NA'));
        else
            name=cvi.TopModelCov.getNameFromCvId(id);
            if length(id)>1
                out=cvi.ReportUtils.obj_link(id,[cvi.ReportUtils.cr_to_space(name),' (#',num2str(id(2)),')']);
            else
                out=cvi.ReportUtils.obj_link(id,cvi.ReportUtils.cr_to_space(name));
            end
        end






        function out=obj_full_path_link(id)
            if(id==0)
                out=getString(message('Slvnv:simcoverage:cvhtml:NA'));
            else
                origin=cv('get',id,'.origin');
                switch origin
                case 0
                    label=cvi.TopModelCov.getNameFromCvId(id);
                case 1
                    slH=cv('get',id,'.handle');
                    if~isequal(slH,0)&&ishandle(slH)
                        label=[cvi.ReportUtils.cr_to_space(get_param(slH,'Parent')),'/',cvi.ReportUtils.cr_to_space(cvi.TopModelCov.getNameFromCvId(id))];
                    else
                        out=getString(message('Slvnv:simcoverage:cvhtml:NA'));
                        return;
                    end
                case 2
                    sfId=cv('get',id,'.handle');
                    label=sf('FullNameOf',sfId,'.');
                case 3
                    label=cvi.TopModelCov.getNameFromCvId(id);
                end
                out=cvi.ReportUtils.obj_link(id,label);
            end





            function str=generate_uncov_links(id,uncovArray,options)

                index=find(id==uncovArray);


                str='';

                if(index>1)
                    prevId=uncovArray(index-1);
                    str=[str,'&#160;',image_with_text('left_arrow.gif',getString(message('Slvnv:simcoverage:cvhtml:PreviousUncoveredObject')),prevId,options)];
                end

                if(index<length(uncovArray))
                    nextId=uncovArray(index+1);
                    str=[str,'&#160;',image_with_text('right_arrow.gif',getString(message('Slvnv:simcoverage:cvhtml:NextUncoveredObject')),nextId,options)];
                end

                str=[str,'<br/>',10];







                function out=image_with_text(file,text,linkId,options)



                    if isempty(text)
                        textIn='';
                    else
                        textIn=sprintf(' alt="%s"',text);
                    end
                    if isempty(linkId)
                        out=sprintf('<img src="%s"%s></img> ',file,textIn);
                    else
                        out=sprintf('<a href="#refobj%d"><img src="%s/%s"%s border="0"></img></a>',...
                        linkId,options.imageSubDirectory,file,textIn);
                    end
