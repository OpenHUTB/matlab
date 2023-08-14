function out=obj_diag_named_link(id,addtxt,commandType,isLinked)







    if nargin<2
        addtxt=[];
    end

    if nargin<3
        commandType=0;
    end

    if nargin<4
        isLinked=true;
    end

    if~isempty(addtxt)
        str=addtxt;
        maxLength=80;
    else
        name=cvi.TopModelCov.getNameFromCvId(id);
        str=cvi.ReportUtils.cr_to_space(name);
        maxLength=40;
    end

    if length(str)>maxLength
        str=[str(1:maxLength),'...'];
    end

    if(id==0)
        out=getString(message('Slvnv:simcoverage:cvhtml:NA'));
    else
        out=obj_diag_link(commandType,id,str,isLinked);
    end





    function out=obj_diag_link(commandType,id,str,isLinked)

        str=cvi.ReportUtils.str_to_html(str);
        switch commandType

        case 0
            cvId=id(1);
            modelcovId=cv('get',cvId,'slsf.modelcov');
            if cv('get',modelcovId,'.isScript')
                scriptName=SlCov.CoverageAPI.getModelcovName(modelcovId);
                if numel(id)==1
                    id(2)=1;
                    id(3)=1;
                end
                if isLinked
                    out=sprintf('<a href="matlab: cvdisplay(''%s'', %d, %d, %d);">%s</a>',scriptName,id(2),id(3),1,str);
                else
                    out=str;
                end
            else
                ssid=cvi.TopModelCov.getSID(cvId);
                if length(id)>1
                    if isLinked
                        out=sprintf('<a href="matlab: cvdisplay(''%s'', %d, %d);">%s</a>',ssid,id(2),id(3),str);
                    else
                        out=str;
                    end
                else
                    if cv('get',cvId,'.origin')==1
                        if cv('get',cvId,'.handle')==0
                            ssid=SlCov.CoverageAPI.getModelcovName(modelcovId);
                        else
                            pssid=Simulink.ID.getSimulinkParent(ssid);

                            if strcmpi(get_param(pssid,'Type'),'block')&&...
                                strcmpi(get_param(pssid,'MaskHideContents'),'on')
                                ssid=pssid;
                            end

                        end
                    end
                    if isLinked
                        out=sprintf('<a href="matlab: cvdisplay(''%s'');">%s</a>',ssid,str);
                    else
                        out=str;
                    end
                end
            end

        case 1
            out=str;
        otherwise
            out=sprintf('%s',str);
        end
