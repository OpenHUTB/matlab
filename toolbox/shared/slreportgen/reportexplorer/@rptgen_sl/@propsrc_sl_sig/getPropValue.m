function[pValue,propName]=getPropValue(this,objList,propName,dataObjects)




    if(iscell(objList)&&all(cellfun(@ishandle,objList)))


        objList=cell2mat(objList);
    end

    switch propName
    case 'Depth'
        [pValue,propName]=getCommonPropValue(this,objList,propName);

    case 'ParentBlock'
        [pValue,propName]=getCommonPropValue(this,objList,'Parent');

    case 'ParentSystem'
        pBlocks=rptgen.safeGet(objList,'Parent','get_param');
        [pValue,propName]=getCommonPropValue(this,pBlocks,'Parent');

    case{'Tag','Position','Rotation'}
        pValue=rptgen.safeGet(objList,propName,'get_param');

    case{'Name','GraphicalName'}
        pValue=locGraphicalName(objList);
        propName=getString(message('RptgenSL:rsl_propsrc_sl_sig:graphicalNameLabel'));

    case{'FontName','FontAngle','FontWeight','FontSize'}
        pValue=locLineProperty(objList,propName);

    case 'DocumentLink'
        if(nargin<4)
            dataObjects=locGetSignalObjects(objList);
        end
        pValue=locDocumentLink(objList,dataObjects);

    case 'RTWStorageClass'
        if(nargin<4)
            dataObjects=locGetSignalObjects(objList);
        end
        pValue=locRTWStorageClass(objList,dataObjects);

    case 'RTWStorageTypeQualifier'
        if(nargin<4)
            dataObjects=locGetSignalObjects(objList);
        end
        pValue=locRTWStorageTypeQualifier(objList,dataObjects);

    case 'DefinedInBlk'
        pValue=locTrace(this,objList,'src',false);
        propName=getString(message('RptgenSL:rsl_propsrc_sl_sig:definedInLabel'));

    case 'DefinedInSys'
        pValue=locTrace(this,objList,'src',true);
        propName=getString(message('RptgenSL:rsl_propsrc_sl_sig:definedInLabel'));

    case 'UsedByBlk'
        pValue=locTrace(this,objList,'dst',false);
        propName=getString(message('RptgenSL:rsl_propsrc_sl_sig:usedByLabel'));

    case 'UsedBySys'
        pValue=locTrace(this,objList,'dst',true);
        propName=getString(message('RptgenSL:rsl_propsrc_sl_sig:usedByLabel'));

    case{'Description'}
        if(nargin<4)
            dataObjects=locGetSignalObjects(objList);
        end
        pValue=locGetDescription(objList,propName,dataObjects);

    case 'DataType'
        pValue=rptgen.safeGet(objList,'CompiledPortDataType','get_param');

    case{'Min','Max','Complexity','Dimensions','Unit'}

        pValue=locUseUtilsGetSignalProperty(objList,propName);

    otherwise
        if(nargin<4)
            dataObjects=locGetSignalObjects(objList);
        end

        pValue=locGetSignalParam(objList,propName,dataObjects);
    end


    function sigObj=locGetSignalObjects(objList)




        prevWarnState=warning('query','all');
        warning('off','all');

        nObjects=length(objList);
        sigObj=cell(nObjects,1);
        for i=1:nObjects
            oName=get_param(objList(i),'Name');
            if~isempty(oName)
                [sigObj{i},isExist]=slResolve(oName,...
                get_param(objList(i),...
                'Parent'));%#ok isExist necessary to prevent error
            end
        end


        warning(prevWarnState);


        function out=locGetSignalParam(objList,propName,dataObjects)

            [out,badIndices]=getObjectParam(dataObjects,propName);

            if~isempty(badIndices)
                out(badIndices)=rptgen.safeGet(objList(badIndices),propName,'get_param');
            end


            function out=locGetDescription(objList,propName,dataObjects)

                [out,badIndices]=getObjectParam(dataObjects,propName);

                if~isempty(badIndices)
                    out(badIndices)=rptgen.safeGet(objList(badIndices),propName,'get_param');
                end

                d=get(rptgen.appdata_rg,'CurrentDocument');
                for i=1:length(out)
                    if rptgen.use_java
                        out{i}=com.mathworks.toolbox.rptgencore.docbook.StringImporter.importHonorLineBreaksNull(java(d),out{i});
                    else
                        out{i}=mlreportgen.re.internal.db.StringImporter.importHonorLineBreaksNull(d.Document,out{i});
                    end


                end


                function[out,badIndices]=getObjectParam(dataObjects,propName)


                    [prevWarnMsg,prevWarnID]=lastwarn;

                    nDataObjects=length(dataObjects);
                    out=cell(nDataObjects,1);
                    badIndices=zeros(nDataObjects,1);
                    nBadIndices=0;

                    for i=1:nDataObjects
                        if isa(dataObjects{i},'Simulink.Signal')
                            try
                                out{i}=subsref(dataObjects{i},locMakeSubsref(propName));
                            catch ME %#ok
                                nBadIndices=nBadIndices+1;
                                badIndices(nBadIndices)=i;
                            end
                        else
                            nBadIndices=nBadIndices+1;
                            badIndices(nBadIndices)=i;
                        end
                    end


                    badIndices(nBadIndices+1:end)=[];


                    lastwarn(prevWarnMsg,prevWarnID);


                    function sref=locMakeSubsref(propName)


                        sTerms=textscan(propName,'%s','delimiter','.');
                        sTerms=sTerms{1};

                        sref=cell(1,length(sTerms)*2);

                        [sref{1:2:end-1}]=deal('.');
                        [sref{2:2:end}]=deal(sTerms{:});

                        sref=substruct(sref{:});


                        function linkList=locDocumentLink(objList,dataObjects)

                            linkList=locGetSignalParam(objList,'DocumentLink',dataObjects);
                            notEmptyList=find(~cellfun('isempty',linkList));
                            if~isempty(notEmptyList)
                                d=get(rptgen.appdata_rg,'CurrentDocument');

                                for i=1:length(notEmptyList)
                                    url=linkList{notEmptyList(i)};
                                    slashLoc=strfind(url,'/');
                                    if isempty(slashLoc)
                                        name=slashLoc;
                                    else
                                        name=url(slashLoc(end)+1:end);
                                    end
                                    linkList{notEmptyList(i)}=makeLink(d,url,name,'ulink');
                                end
                            end


                            function out=locRTWStorageClass(objList,dataObjects)




                                out=getObjectParam(dataObjects,'CoderInfo.StorageClass');
                                outNotOkIndex=find(cellfun('isempty',out));

                                if~isempty(outNotOkIndex)
                                    hVal=rptgen.safeGet(objList(outNotOkIndex),'RTWStorageClass','get_param');

                                    testPointIndex=find(strcmp(...
                                    rptgen.safeGet(objList(outNotOkIndex),'TestPoint','get_param'),...
                                    'on'));

                                    if~isempty(testPointIndex)
                                        [hVal{testPointIndex}]=deal('SimulinkGlobal');
                                    end

                                    out(outNotOkIndex)=hVal;
                                end


                                function out=locRTWStorageTypeQualifier(objList,dataObjects)

                                    [out,badIndices]=getObjectParam(dataObjects,'CoderInfo.TypeQualifier');
                                    if~isempty(badIndices)
                                        out(badIndices)=rptgen.safeGet(objList(badIndices),'RTWStorageTypeQualifier');
                                    end


                                    function out=locLineProperty(objList,propName)

                                        out=rptgen.safeGet(objList,'Line','get_param');
                                        for i=length(out):-1:1
                                            out(i)=rptgen.safeGet(out{i},propName,'get_param');
                                        end


                                        function nameList=locGraphicalName(objList)


                                            nameList=rptgen.safeGet(objList,'Name','get_param');
                                            psIdx=find(strcmp(...
                                            rptgen.safeGet(objList,'ShowPropagatedSignals','get_param'),...
                                            'on'));
                                            if~isempty(psIdx)
                                                objList=objList(psIdx);
                                                psNames=rptgen.safeGet(objList,'PropagatedSignals','get_param');
                                                nameList(psIdx)=strcat(nameList(psIdx),' <',psNames,'>');
                                            end



                                            function value=locTrace(psSL,sigList,traceDirection,isSystem)

                                                if nargin<4
                                                    isSystem=false;
                                                end

                                                d=get(rptgen.appdata_rg,'CurrentDocument');

                                                propName=['NonVirtual',traceDirection,'Ports'];

                                                nSigs=length(sigList);
                                                value=cell(nSigs,1);
                                                for i=nSigs:-1:1
                                                    try
                                                        thisLine=get_param(sigList(i),'Line');
                                                        thisTracePrt=get_param(thisLine,propName);
                                                        thisTraceBlk=rptgen.safeGet(thisTracePrt,'Parent','get_param');
                                                    catch ME %#ok
                                                        thisTraceBlk={'N/A'};
                                                    end

                                                    if isSystem
                                                        thisTraceBlk=rptgen.safeGet(thisTraceBlk,'Parent','get_param');
                                                        thisTraceBlk=unique(thisTraceBlk);
                                                        oType='System';
                                                    else
                                                        oType='Block';
                                                    end

                                                    value{i}=makeLink(psSL,...
                                                    thisTraceBlk,...
                                                    oType,...
                                                    'link',...
                                                    d);
                                                end



                                                function value=locUseUtilsGetSignalProperty(objList,propName)
                                                    nObjects=numel(objList);
                                                    value=cell(nObjects,1);
                                                    for i=1:nObjects
                                                        value{i}=slreportgen.utils.internal.getSignalProperty(objList(i),propName);
                                                    end

