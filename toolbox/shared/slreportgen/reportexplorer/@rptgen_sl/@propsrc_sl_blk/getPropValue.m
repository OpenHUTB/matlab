function[pValue,propName]=getPropValue(this,objList,propName)







    switch propName
    case this.getCommonPropValue('PropList')



        [pValue,propName]=getCommonPropValue(this,objList,propName);
    case 'dialogparameters'
        pValue=feval(['Loc',propName],this,objList);
    case 'InputSignalNames'
        pValue=SignalName(this,objList,'Inport');
    case 'OutputSignalNames'
        pValue=SignalName(this,objList,'Outport');
    case{'DefinedInBlk','ActualSrc'}
        pValue=locTrace(this,objList,'src',false);
        propName=getString(message('RptgenSL:rsl_propsrc_sl_blk:definedInLabel'));
    case 'DefinedInSys'
        pValue=locTrace(this,objList,'src',true);
        propName=getString(message('RptgenSL:rsl_propsrc_sl_blk:definedInLabel'));
    case{'UsedByBlk','ActualDst'}
        pValue=locTrace(this,objList,'dst',false);
        propName=getString(message('RptgenSL:rsl_propsrc_sl_blk:usedByLabel'));
    case 'GotoBlkName'
        pValue=locGetAssociatedBlockFields(this,objList,'Name','GotoBlock');
    case 'FromBlk'
        pValue=locGetAssociatedBlockFields(this,objList,'Name','FromBlocks');
    case 'GotoBlkLocation'
        pValue=locGetAssociatedBlockFields(this,objList,'Path','GotoBlock',true);
    case 'FromBlkLocation'
        pValue=locGetAssociatedBlockFields(this,objList,'Path','FromBlocks',true);
    case 'UsedBySys'
        pValue=locTrace(this,objList,'dst',true);
        propName=getString(message('RptgenSL:rsl_propsrc_sl_blk:usedByLabel'));
    case{
'UseBusObject'
'BusOutputAsStruct'
'LimitOutput'
'ShowSaturationPort'
'ShowStatePort'
'IgnoreLimit'
'StateMustResolveToSignalObject'
'CacheBpFlag'
'VectorInputFlag'
        }
        pValue=locEmptyDefault(objList,propName,'off');
    case 'VectorParams1D'
        pValue=locEmptyDefault(objList,propName,'on');
    case{
'SampleTime'
'Samptime'
'PortDimensions'
        }
        pValue=locEmptyDefault(objList,propName,'-1');
    case{
'OutDataTypeStr'
'SignalType'
'SamplingMode'
'AbsoluteTolerance'
        }
        pValue=locEmptyDefault(objList,propName,'Inherit: auto');
    case{
'ElementSrc'
'RowSrc'
'ColumnSrc'
        }
        pValue=locEmptyDefault(objList,propName,'Internal');
    case{
'DiagnosticForDimensions'
'ErrorRangeMode'
        }
        pValue=locEmptyDefault(objList,propName,'None');
    case{
'NumBitsMult'
'BiasMult'
'SlopeMult'
        }
        pValue=locEmptyDefault(objList,propName,'1');
    case{
'NumBitsAdd'
'BiasAdd'
'SlopeAdd'
'InitialCondition'
        }
        pValue=locEmptyDefault(objList,propName,'0');
    case 'IfRefDouble'
        pValue=locEmptyDefault(objList,propName,'double');
    case 'IfRefSingle'
        pValue=locEmptyDefault(objList,propName,'single');
    case 'UpperSaturationLimit'
        pValue=locEmptyDefault(objList,propName,'inf');
    case 'LowerSaturationLimit'
        pValue=locEmptyDefault(objList,propName,'-inf');
    case 'RTWStateStorageClass'
        pValue=locEmptyDefault(objList,propName,'Auto');
    case 'Chart'

        pValue=locChart(objList);
    case 'Script'

        pValue=locScript(objList);
    case{'UpdateMethod (TT)','SampleTime (TT)'}
        pValue=locTruthTableParams(objList,propName);
    case{'ModelName','ModelNames'}
        pValue=locMakeModelLink(objList);
    case 'RmiLinkedName'
        if RptgenRMI.option('linksToObjects')
            pValue=locRmiLinkedName(objList);
        else
            [pValue,~]=getCommonPropValue(this,objList,'Name');
        end
        propName=getString(message('Slvnv:RptgenRMI:getType:ObjColumnName'));
    otherwise
        pValue=locMakeVariableDisplay(this,objList,propName);
    end


    function values=locMakeVariableDisplay(propsrcObj,objList,propName)

        values=rptgen.safeGet(objList,propName,'get_param');

        d=get(rptgen.appdata_rg,'CurrentDocument');

        for i=1:length(values)

            if(isa(values{i},'char'))
                [propVariable,resultExists]=slResolve(values{i},objList{i},'variable');

                if(resultExists&&isa(propVariable,'handle'))

                    values{i}=propsrcObj.makeLinkScalar(...
                    propVariable,...
                    'var',...
                    'link',...
                    d,...
                    values{i});

                end
            end
        end


        function allList=Locdialogparameters(z,obj)%#ok - There are no explicit




            allList=rptgen.safeGet(obj,'dialogparameters','get_param');

            for i=1:length(allList)
                if isstruct(allList{i})
                    allList{i}=rptgen.makeSingleLineText(...
                    fieldnames(allList{i}),...
                    newline);
                end
            end


            function value=SignalName(z,objList,portType)

                portStruct=rptgen.safeGet(objList,'PortHandles','get_param');
                d=get(rptgen.appdata_rg,'CurrentDocument');
                value={};
                for i=length(portStruct):-1:1
                    sigList=portStruct{i}.(portType);
                    sigList=sigList(:);
                    if strcmp(portType,'Inport')
                        for j=1:length(sigList)
                            sigList(j)=locTraceSignalSources(sigList(j));
                        end
                    end

                    value{i}=z.makeLink(sigList,'sig','link',d);
                end


                function linkInfo=getLinked(uddObj,getMethod)%#ok - There are no explicit




                    linkInfo=[];

                    try
                        eval(['linkInfo = uddObj.get',getMethod,';']);


                    catch ex %#ok
                        linkInfo=ones(0,3);
                    end

                    if(exist('linkInfo','var')&&...
                        ~isempty(linkInfo))
                        linkInfo=rptgen.safeGet(linkInfo(:,1),'Parent','get_param');
                    else
                        linkInfo={};
                    end


                    function outSigs=locTraceSignalSources(inSigs)


                        for i=length(inSigs):-1:1

                            outSigs(i)=-1;

                            [lineHandle,failures]=rptgen.safeGet(inSigs(i),'Line','get_param');

                            if isempty(failures)&&~isempty(lineHandle)
                                lineHandle=lineHandle{1};
                                if ishandle(lineHandle)
                                    [oSig,failures]=rptgen.safeGet(lineHandle,'srcporthandle','get_param');
                                    if isempty(failures)&&~isempty(oSig)
                                        oSig=oSig{1};
                                        if ishandle(oSig)
                                            outSigs(i)=oSig;
                                        end
                                    end
                                end
                            end

                        end


                        function out=locTrace(psSL,blkList,traceDirection,isSystem)

                            if nargin<4
                                isSystem=false;
                            end

                            d=get(rptgen.appdata_rg,'CurrentDocument');

                            for i=length(blkList):-1:1
                                try
                                    thisTrace=rptgen_sl.traceBlock(traceDirection,blkList{i});
                                catch ex %#ok - reutrn getString(message('RptgenSL:rsl_propsrc_sl_blk:notApplicableLabel')) in the case of failure to trace block
                                    thisTrace={{getString(message('RptgenSL:rsl_propsrc_sl_blk:notApplicableLabel'))}};
                                end



                                portCount=length(thisTrace);
                                for portIdx=1:portCount
                                    nTrace=length(thisTrace{portIdx});
                                    if nTrace>1
                                        traceEl=createDocumentFragment(d);
                                    else
                                        traceEl=[];
                                    end

                                    for traceIdx=1:nTrace
                                        thisObj=thisTrace{portIdx}{traceIdx};
                                        if isempty(thisObj)
                                            parentModel=bdroot(blkList{i});
                                            objEl=makeLinkScalar(psSL,...
                                            parentModel,...
                                            'mdl',...
                                            'link',...
                                            d,...
                                            [get_param(parentModel,'Name'),' (model)']);



                                        elseif strcmp(thisObj,getString(message('RptgenSL:rsl_propsrc_sl_blk:notApplicableLabel')))||strcmp(thisObj,getString(message('RptgenSL:rsl_propsrc_sl_blk:unconnectedLabel')))
                                            objEl=createTextNode(d,thisObj);
                                        elseif isSystem
                                            objEl=makeLinkScalar(psSL,...
                                            get_param(thisObj,'Parent'),...
                                            'sys',...
                                            'link',...
                                            d);



                                        else
                                            objEl=makeLinkScalar(psSL,...
                                            thisObj,...
                                            '',...
                                            'link',...
                                            d);
                                        end

                                        if nTrace>1
                                            traceEl.appendChild(objEl);
                                            if traceIdx<nTrace
                                                traceEl.appendChild(createTextNode(d,', '));
                                            end
                                        else
                                            traceEl=objEl;
                                        end
                                    end
                                    thisTrace{portIdx}=traceEl;
                                end

                                if portCount==0
                                    out{i,1}='';
                                elseif portCount==1
                                    out{i,1}=thisTrace{1};
                                else

                                    if rptgen.use_java
                                        m=com.mathworks.toolbox.rptgencore.docbook.ListMaker(thisTrace);
                                    else
                                        m=mlreportgen.re.internal.db.ListMaker(thisTrace);
                                    end


                                    setListType(m,m.LIST_TYPE_ORDERED);



                                    setSpacingType(m,'compact');
                                    if rptgen.use_java
                                        out{i,1}=m.createList(java(d));
                                    else
                                        out{i,1}=createList(m,d.Document);
                                    end
                                end
                            end


                            function pValue=locChart(objList)

                                if ischar(objList)
                                    objList={objList};
                                end
                                nObj=length(objList);

                                psSF=rptgen_sf.propsrc_sf;

                                d=get(rptgen.appdata_rg,'CurrentDocument');

                                for i=nObj:-1:1
                                    sfChart=rptgen_sf.block2chart(objList{i});
                                    pValue{i,1}=makeLinkScalar(psSF,...
                                    sfChart,'Chart','link',d);
                                end


                                function pValue=locScript(objList)

                                    if ischar(objList)
                                        objList={objList};
                                    end

                                    d=get(rptgen.appdata_rg,'CurrentDocument');
                                    nObj=length(objList);
                                    for i=nObj:-1:1
                                        emlFcn=rptgen_sf.block2chart(objList{i});
                                        if rptgen.use_java
                                            script=com.mathworks.widgets.CodeAsXML.xmlize(java(d),emlFcn.Script);
                                        else
                                            script=rptgen.internal.docbook.CodeAsXML.xmlize(java(d),emlFcn.Script);
                                        end
                                        pValue{i,1}=createElement(d,'programlisting',script);
                                        setAttribute(pValue{i,1},'xml:space','preserve');
                                    end


                                    function pValue=locTruthTableParams(objList,propName)

                                        if ischar(objList)
                                            objList={objList};
                                        end
                                        nObj=length(objList);

                                        for i=nObj:-1:1
                                            ttObj=rptgen_sf.block2chart(objList{i});

                                            switch propName
                                            case 'UpdateMethod (TT)'
                                                pValue{i,1}=ttObj.ChartUpdate;
                                            case 'SampleTime (TT)'
                                                sampleTime=ttObj.SampleTime;
                                                if isempty(sampleTime)
                                                    sampleTime='-1';
                                                end
                                                pValue{i,1}=sampleTime;
                                            end

                                        end





                                        function pValue=locEmptyDefault(objList,propName,defaultValue)

                                            pValue=rptgen.safeGet(objList,propName,'get_param');

                                            defaultIdx=find(strcmp(pValue,defaultValue));
                                            if~isempty(defaultIdx)
                                                [pValue{defaultIdx}]=deal('');
                                            end




                                            function pValue=locGetAssociatedBlockFields(this,objList,fieldName,assocBlkType,isSysLink)

                                                if(nargin<5)
                                                    isSysLink=false;
                                                end

                                                doc=get(rptgen.appdata_rg,'CurrentDocument');

                                                numObjs=length(objList);


                                                pValue=cell(1,numObjs);

                                                for i=1:numObjs

                                                    docFrag=createDocumentFragment(doc);


                                                    curBlockData=get_param(objList{i},assocBlkType);

                                                    if(~isempty(curBlockData)&&~isempty(curBlockData(1).handle))
                                                        numHandles=length(curBlockData);

                                                        delimiter='';


                                                        for j=1:numHandles



                                                            docFrag.appendChild(createTextNode(doc,delimiter));
                                                            delimiter=', ';


                                                            curAssocBlock=get_param(curBlockData(j).handle,'object');
                                                            curAssocBlockName=curBlockData(j).name;


                                                            if(isSysLink)
                                                                assocObjContent=makeLinkScalar(this,...
                                                                curAssocBlock.(fieldName),...
                                                                'sys',...
                                                                'link',...
                                                                doc,...
                                                                curAssocBlock.(fieldName));


                                                            else
                                                                assocObjContent=makeLinkScalar(this,...
                                                                curAssocBlockName,...
                                                                '',...
                                                                'link',...
                                                                doc,...
                                                                curAssocBlock.(fieldName));
                                                            end

                                                            docFrag.appendChild(assocObjContent);

                                                            pValue{i}{j}=docFrag;
                                                        end

                                                    else

                                                        docFrag.appendChild(createTextNode(doc,getString(message('RptgenSL:rsl_propsrc_sl_blk:unconnectedLabel'))));
                                                        pValue{i}{1}=docFrag;

                                                    end

                                                end

                                                function pValue=locMakeModelLink(objList)

                                                    d=get(rptgen.appdata_rg,'CurrentDocument');
                                                    psSL=rptgen_sl.propsrc_sl;
                                                    nObjs=length(objList);
                                                    pValue=cell(1,nObjs);
                                                    for i=1:nObjs
                                                        obj=objList{i};
                                                        pValue{i}=makeLink(psSL,...
                                                        rptgen.safeGet(obj,'ModelName','get_param'),...
                                                        'model',...
                                                        'link',...
                                                        d);
                                                    end



                                                    function values=locRmiLinkedName(objList)

                                                        d=get(rptgen.appdata_rg,'CurrentDocument');

                                                        if ischar(objList)
                                                            objList={objList};
                                                        end

                                                        for i=length(objList):-1:1
                                                            try
                                                                values{i}=RptgenRMI.linkToMatlab(objList{i},d);
                                                            catch outerEx
                                                                try
                                                                    values{i}=get_param(objList{i},'Name');
                                                                catch innerEx
                                                                    values{i}='UNDEF';
                                                                    rptgen.displayMessage(sprintf('%s\n%s',outerEx.message,innerEx.message),6);
                                                                end
                                                            end
                                                        end
