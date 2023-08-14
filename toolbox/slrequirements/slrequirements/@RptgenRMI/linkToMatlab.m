function link=linkToMatlab(obj,dXML)








    isRichText=false;
    if ischar(obj)
        if strcmp(obj,'current chart')
            sfData=rptgen_sf.appdata_sf;
            chart=get(sfData.CurrentObject,'ID');
            obj=sf('Private','chart2block',chart);
        else

            [obj,isRichText]=rmisl.richTextToHandle(obj);
        end
    end

    grpInfo='';
    if iscell(obj)

        doc=obj{1};
        location=obj{2};
        if location(1)=='@'
            location=location(2:end);
        end
        if strcmp(location,':')
            location='';
        elseif any(location=='.')
            [location,grpInfo]=strtok(location,'.');
        end
        try
            obj=Simulink.ID.getHandle([doc,location]);
        catch %#ok<CTCH> % it may happen that 'doc' is not loaded
            try
                load_system(doc);
                obj=Simulink.ID.getHandle([doc,location]);
            catch Mex
                link=sprintf('faled to create link: %s',Mex.message);
                return;
            end
        end
        if~isempty(grpInfo)


            signalbuilder(obj,'ActiveGroup',str2double(grpInfo(2:end)));
        end
    end


    try



        if isa(obj,'Stateflow.Object')
            isSf=true;
            slsfobj=obj;
            obj=obj.Id;
        elseif isa(obj,'double')
            isSf=~isRichText&&(ceil(obj)==obj);
            slsfobj=get_param(obj,'Object');
        else
            isSf=false;
            slsfobj=get_param(obj,'Object');
            if isa(slsfobj,'Simulink.Annotation')
                obj=slsfobj.Handle;
            end
        end
        [modelStr,sid]=rmidata.getRmiKeys(obj,isSf);
        if strncmp(modelStr,'$ModelName$',length('$ModelName$'))



            [~,~,harnessInfo]=Simulink.harness.internal.sidmap.isObjectOwnedByCUT(slsfobj);
            modelStr=strrep(modelStr,'$ModelName$',harnessInfo.model);
        end
        if~isempty(grpInfo)


            navcmd=['rmiobjnavigate(''',modelStr,''',''',sid,''',',grpInfo(2:end),');'];
        else
            navcmd=['rmiobjnavigate(''',modelStr,''',''',sid,''');'];
        end


        if rmi.settings_mgr('get','reportSettings','navUseMatlab')
            url=rmiut.cmdToUrl(navcmd);
        else
            url=sprintf('matlab:%s',navcmd);
        end

        if nargin==2

            if isRichText
                objname=getString(message('Slvnv:rmi:resolveobj:RichTextAnnotation',Simulink.ID.getSID(obj)));
            else
                objname=rmi.objname(obj);
            end
            if~isempty(grpInfo)
                objname=sprintf('%s, signal group %s',objname,grpInfo(2:end));
            elseif isempty(objname)
                objname=getString(message('Slvnv:report:UnlabeledObject',num2str(obj.SSIdNumber)));
            end
            link=dXML.makeLink(url,objname,'ulink');
        else

            link=url;
        end

    catch Mex
        link=sprintf('faled to create link: %s',Mex.message);
    end


