function[pValue,propName]=getCommonPropValue(h,objList,propName)%#ok<INUSL>










    pValue={
'Blocks'
'Lines'
'Signals'
'PaperSize'
'PaperPosition'
'Parent'
'Depth'
'Name'
'RequirementInfo'
'MaskWSVariables'
'Description'
'MaskDescription'
    };

    if nargin==2

        return;
    end

    if any(strcmp(pValue,propName))
        [pValue,propName]=feval(['Loc',propName],...
        rptgen_sl.propsrc_sl,...
        objList);
    else
        pValue=rptgen.safeGet(objList,propName,'get_param');
    end




    function[parentList,propName]=LocParent(psSL,obj)
        propName='Parent';

        parentList=rptgen.safeGet(obj,'Parent','get_param');

        d=get(rptgen.appdata_rg,'CurrentDocument');
        for i=1:length(parentList)
            if isempty(parentList{i})

                parentList{i}='<root>';
            elseif strcmp(parentList{i},'N/A')

            else

                parentList{i}=makeLink(psSL,...
                parentList{i},...
                '',...
                'link',...
                d);
            end
        end


        function[value,propName]=LocDepth(z,obj)%#ok<INUSL>
            propName='Depth';



            if iscell(obj)
                subsrefType='{}';
            elseif ischar(obj)
                obj={obj};
                subsrefType='{}';
            else
                subsrefType='()';
            end

            value={};
            for i=length(obj):-1:1
                depth=-1;
                parent=subsref(obj,substruct(subsrefType,{i}));
                while~isempty(parent)
                    try
                        parent=get_param(parent,'Parent');
                        depth=depth+1;
                    catch ex %#ok<NASGU>
                        parent=[];
                    end
                end
                value{i,1}=depth;
            end


            function[value,propName]=LocBlocks(psSL,obj)
                propName='Blocks';

                value=rptgen.safeGet(obj,'Blocks','get_param');

                d=get(rptgen.appdata_rg,'CurrentDocument');
                for i=1:length(value)
                    if~isempty(value{i})
                        fullNames=strcat(obj{i},'/',strrep(value{i},'/','//'));
                        value{i}=makeLink(psSL,...
                        fullNames,...
                        '',...
                        'link',...
                        d);
                    else
                        value{i}='';
                    end
                end


                function[value,propName]=LocLines(z,obj)%#ok<INUSL>
                    propName='Lines';

                    value=rptgen.safeGet(obj,'Lines','get_param');
                    for i=1:length(value)
                        if~isstruct(value{i})
                            value{i}='N/A';
                        else
                            value{i}=sprintf('%i lines',locLineCount(value{i},0));
                        end
                    end


                    function[numLines,propName]=locLineCount(lineStruct,numLines)
                        propName='Line Count';

                        for i=1:length(lineStruct)
                            numLines=locLineCount(lineStruct(i).Branch,numLines+1);
                        end


                        function[value,propName]=LocName(psSL,obj)
                            propName='Name';

                            if iscell(obj)
                                for i=length(obj):-1:1
                                    value{i}=psSL.getObjectName(obj{i});
                                end
                            elseif ischar(obj)
                                value{1}={psSL.getObjectName(obj)};
                            else
                                for i=length(obj):-1:1
                                    value{i}=psSL.getObjectName(obj(i));
                                end
                            end


                            function[value,propName]=LocSignals(psSL,obj)
                                propName='Signals';

                                if ischar(obj)
                                    obj={obj};
                                end

                                value={};
                                d=get(rptgen.appdata_rg,'CurrentDocument');
                                for i=length(obj):-1:1
                                    if iscell(obj)
                                        currObj=obj{i};
                                    else
                                        currObj=obj(i);
                                    end

                                    sigList=find_system(currObj,...
                                    'findall','on',...
                                    'SearchDepth',1,...
                                    'type','port',...
                                    'porttype','outport');

                                    value{i}=makeLink(psSL,...
                                    sigList,...
                                    'sig',...
                                    'link',...
                                    d);
                                end


                                function[value,propName]=LocPaperPosition(z,objHandles)%#ok<INUSL>
                                    propName='Paper Position';

                                    value=rptgen.safeGet(objHandles,'PaperPosition','get_param');

                                    for i=1:length(value)
                                        if isnumeric(value{i})
                                            value{i}=sprintf('(%0.2f, %0.2f) %0.2f x %0.2f',...
                                            value{i}(1),value{i}(2),value{i}(3),value{i}(4));
                                        end
                                    end


                                    function[value,propName]=LocPaperSize(z,objHandles)%#ok<INUSL>
                                        propName='Paper Size';

                                        value=rptgen.safeGet(objHandles,'PaperSize','get_param');

                                        for i=1:length(value)
                                            if isnumeric(value{i})
                                                value{i}=sprintf('%0.2f x %0.2f',value{i}(1),value{i}(2));
                                            end
                                        end


                                        function[value,propName]=LocRequirementInfo(psSL,objList)%#ok<INUSL>

                                            propName=getString(message('Slvnv:RptgenRMI:ReqTable:execute:ReqData'));

                                            if ischar(objList)
                                                objList={objList};
                                            end

                                            [rmiInstalled,rmiLicensed]=rmi.isInstalled();
                                            if rmiInstalled&&rmiLicensed

                                                d=get(rptgen.appdata_rg,'CurrentDocument');

                                                for i=length(objList):-1:1
                                                    try



                                                        value{i}=RptgenRMI.getRequirementNode(objList{i},d);
                                                    catch outerEx
                                                        warning('RptgenRMI:getRequirementNode','%s',outerEx.message);
                                                        try

                                                            value{i}=rmi('get',objList{i});
                                                        catch innerEx
                                                            value{i}=getString(message('RptgenSL:rsl_propsrc_sl:vAndVUnavailable'));
                                                            rptgen.displayMessage(sprintf('%s : %s',value{i},innerEx.message),6);
                                                        end
                                                    end
                                                end

                                            else
                                                for i=length(objList):-1:1
                                                    value{i}=getString(message('RptgenSL:rsl_propsrc_sl:vAndVUnavailable'));
                                                end

                                            end



                                            function[value,propName]=LocMaskWSVariables(psSL,objList)%#ok<INUSL>

                                                propName='Mask Workspace Variables';

                                                d=get(rptgen.appdata_rg,'CurrentDocument');

                                                value=rptgen.safeGet(objList,'MaskWSVariables','get_param');

                                                for i=1:length(value)
                                                    thisValueStruct=value{i};
                                                    if isstruct(thisValueStruct)&&~isempty(thisValueStruct)
                                                        thisValueEl=d.createElement('simplelist');
                                                        thisValueEl.setAttribute('type','horiz');
                                                        thisValueEl.setAttribute('columns','2');
                                                        for j=1:length(thisValueStruct)
                                                            thisValueEl.appendChild(d.createElement('member',...
                                                            d.createTextNode(thisValueStruct(j).Name,128)));
                                                            thisValueEl.appendChild(d.createElement('member',...
                                                            d.createTextNode(thisValueStruct(j).Value,128)));
                                                        end
                                                        value{i}=thisValueEl;
                                                    end
                                                end


                                                function[value,propName]=LocDescription(psSL,objList)%#ok<INUSL>

                                                    propName='Description';

                                                    value=rptgen.safeGet(objList,'Description','get_param');


                                                    d=get(rptgen.appdata_rg,'CurrentDocument');
                                                    for i=1:length(value)
                                                        if rptgen.use_java
                                                            value{i}=com.mathworks.toolbox.rptgencore.docbook.StringImporter.importHonorLineBreaksNull(java(d),value{i});
                                                        else
                                                            value{i}=mlreportgen.re.internal.db.StringImporter.importHonorLineBreaksNull(d.Document,value{i});
                                                        end


                                                    end


                                                    function[value,propName]=LocMaskDescription(psSL,objList)%#ok<INUSL>

                                                        propName='Mask Description';

                                                        value=rptgen.safeGet(objList,'MaskDescription','get_param');


                                                        d=get(rptgen.appdata_rg,'CurrentDocument');
                                                        for i=1:length(value)
                                                            if rptgen.use_java
                                                                value{i}=com.mathworks.toolbox.rptgencore.docbook.StringImporter.importHonorLineBreaksNull(java(d),value{i});
                                                            else
                                                                value{i}=mlreportgen.re.internal.db.StringImporter.importHonorLineBreaksNull(d.Document,value{i});
                                                            end


                                                        end

