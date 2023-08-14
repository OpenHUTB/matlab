function[pValue,propName]=getPropValue(psSF,objList,propName,varargin)








    if isempty(objList)
        pValue={};
    else
        switch lower(propName)
        case 'name'




            if isempty(varargin)&&isa(objList,'Stateflow.Annotation')

                [pValue,propName]=getAnnotationPropValue(psSF,objList,'text');
            else


                for i=length(objList):-1:1
                    try
                        pValue{i}=psSF.getObjectName(objList(i));
                    catch %#ok<CTCH>
                        pValue{i}='N/A';
                    end
                end
            end
        case 'fullpath+name'
            d=get(rptgen.appdata_rg,'CurrentDocument');
            for i=length(objList):-1:1
                try
                    pValue{i}=psSF.getSLSFPath(objList(i),d);
                catch %#ok<CTCH>
                    pValue{i}='N/A';
                end
            end
            propName='Name';
        case 'sfpath+name'
            d=get(rptgen.appdata_rg,'CurrentDocument');
            for i=length(objList):-1:1
                try
                    pValue{i}=psSF.getSFPath(objList(i),d);
                catch %#ok<CTCH>
                    pValue{i}='N/A';
                end
            end
            propName='Name';
        case{'machine','chart','subviewer','source','destination'}

            pValue=safe_get_linked(psSF,propName,objList);
        case{
'defaulttransitions'
'innertransitions'
'outertransitions'
'sourcedtransitions'
            }

            pValue=safe_method_linked(psSF,propName,objList);
            propName=rptgen.prettifyName(propName);
        case{'events','transitions','states','junctions'}
            objType=rptgen.capitalizeFirst(propName(1:end-1));
            pValue=safe_method_linked(psSF,'find',objList,'-depth',1,'-isa',['Stateflow.',objType]);
        case 'charts'
            pValue=safe_method_linked(psSF,'find',objList,'-isa','Stateflow.Chart');



        case 'data'
            objType=rptgen.capitalizeFirst(propName);
            pValue=safe_method_linked(psSF,'find',objList,'-depth',1,'-isa',['Stateflow.',objType]);


        case 'parent'
            pValue=safe_method_linked(psSF,'up',objList);
        case{
'data type'
'datatype'
            }
            pValue=rptgen.safeGet(objList,'dataType');
            propName='Data Type';
        case 'document'
            pValue=rptgen.safeGet(objList,propName);
            for i=1:length(pValue)
                if~isempty(pValue{i})
                    delimLoc=min(union(find(pValue{i}=='('),find(pValue{i}==' ')));
                    if~isempty(delimLoc)
                        firstToken=pValue{i}(1:delimLoc(1)-1);%#ok<NASGU>
                    end
                end
            end


        case 'label'
            pValue=rptgen.safeGet(objList,'LabelString');
        case 'sf id'
            pValue=rptgen.safeGet(objList,'id');
        case{'creation date','created'}
            pValue=rptgen.safeGet(objList,'created');
            propName='Creation Date';
        case{'created by','creator'}
            pValue=rptgen.safeGet(objList,'creator');
            propName='Created By';
        case 'user include directories'
            pValue=rptgen.safeGet(objList,'UserIncludeDirs');






        case{'init value','initvalue'}
            pValue=getCommonPropValue(psSF,objList,'props.initialValue');
        case 'units'
            pValue=getCommonPropValue(psSF,objList,'props.type.units');
        case 'range'
            for i=1:length(objList)
                minVal=objList(i).props.range.minimum;
                maxVal=objList(i).props.range.maximum;

                if isempty(minVal)
                    if isempty(maxVal)
                        pValue{i,1}='';%#ok<AGROW>
                    else
                        pValue{i,1}=['[-inf ',maxVal,']'];%#ok<AGROW>
                    end
                else
                    if isempty(maxVal)
                        pValue{i,1}=['[',minVal,' inf]'];%#ok<AGROW>
                    else
                        pValue{i,1}=['[',minVal,' ',maxVal,']'];%#ok<AGROW>
                    end
                end
            end
        case{
'scope'
'type'
'trigger'
            }
            pValue=get_strip_underscore(objList,propName);
        case 'script'
            pValue=rptgen.safeGet(objList,propName);
            d=get(rptgen.appdata_rg,'CurrentDocument');
            for i=1:length(pValue)

                if rptgen.use_java
                    pValue{i}=com.mathworks.widgets.CodeAsXML.xmlize(java(d),pValue{i});
                else
                    pValue{i}=rptgen.internal.docbook.CodeAsXML.xmlize(d.Document,pValue{i});
                end
                pValue{i}=createElement(d,'programlisting',pValue{i});
                setAttribute(pValue{i},'xml:space','preserve');
            end
        case 'requirementinfo'
            propName=getString(message('RptgenSL:rsf_propsrc_sf:requirementsLabel'));
            d=get(rptgen.appdata_rg,'CurrentDocument');

            for i=length(objList):-1:1
                try



                    pValue{i}=RptgenRMI.getRequirementNode(objList(i),d);
                catch outerEx
                    warning(message('RptgenSL:rsf_propsrc_sf:rmiCallFailed',...
                    'getRequirementNode()',objList(i),outerEx.message));
                    try
                        pValue{i}=rmi('get',objList(i));
                    catch innerEx
                        pValue{i}=innerEx.message;
                    end
                end
            end
        case 'rmilinkedname'
            d=get(rptgen.appdata_rg,'CurrentDocument');
            pValue=rptgen.safeGet(objList(:,1),'name');
            include_links_to_objects=RptgenRMI.option('linksToObjects');
            for i=1:length(objList(:,1))
                try
                    if include_links_to_objects
                        pValue{i}=RptgenRMI.linkToMatlab(objList(i,1),d);
                    else
                        pValue{i}=psSF.getObjectName(objList(i,1));
                    end
                catch Ex
                    pValue{i}='UNDEF';
                    rptgen.displayMessage(...
                    getString(...
                    message('RptgenSL:rsf_propsrc_sf:failedToCreateFieldMsg',...
                    propName,Ex.message),6));
                end
            end
            propName=getString(message('Slvnv:RptgenRMI:getType:ObjColumnName'));

        case 'substates'

            pValue=safe_method_linked(psSF,@locGetSubStates,objList);


        case 'simulinksubsystem'
            pValue=safe_method_linked(psSF,'getDialogProxy',objList);

        case 'text'
            if isa(objList,'Stateflow.Annotation')
                [pValue,propName]=getAnnotationPropValue(psSF,objList,propName);
            else
                [pValue,propName]=getCommonPropValue(psSF,objList,propName);
            end

        otherwise
            [pValue,propName]=getCommonPropValue(psSF,objList,strrep(propName,' ',''));
        end
    end


    function out=safe_method_linked(psSF,methodName,objList,varargin)


        d=get(rptgen.appdata_rg,'CurrentDocument');

        for i=length(objList):-1:1
            try
                out{i}=feval(methodName,objList(i),varargin{:});
                ok=true;
            catch %#ok<CTCH>
                out{i}='N/A';
                ok=false;
            end

            if ok
                if isa(out{i},'Simulink.Object')

                    out{i}=makeLink(rptgen_sl.propsrc_sl,out{i},'','link',d);

                else
                    out{i}=makeLink(psSF,out{i},'','link',d);
                end
            end
        end


        function out=safe_get_linked(psSF,propName,objList)

            out=rptgen.safeGet(objList,propName);
            d=get(rptgen.appdata_rg,'CurrentDocument');
            for i=1:length(out)
                if ishandle(out{i})
                    out{i}=makeLink(psSF,out{i},'','link',d);
                end
            end



            function out=get_strip_underscore(objList,propName)




                out=rptgen.safeGet(objList,propName);
                for i=1:length(out)
                    uscoreLoc=strfind(out{i},'_');
                    if~isempty(uscoreLoc)
                        out{i}=strrep(out{i}(1:uscoreLoc(end)-1),'_',' ');
                    end
                end


                function substates=locGetSubStates(obj)

                    try
                        children=obj.getHierarchicalChildren;
                        substates=find(children,'-isa','Stateflow.State');
                    catch %#ok<CTCH>
                        substates=[];
                    end

                    if isempty(substates)
                        substates='';
                    end

