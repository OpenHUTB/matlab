function[pValue,propName,isScript]=getStateflowObjectValue(objList,propName)




    isScript=false;
    propName=char(propName);

    if isempty(objList)
        pValue={};
    else
        switch lower(char(propName))
        case{'machine','chart','subviewer','source','destination'}

            pValue=safe_get_linked(propName,objList);
        case{
'defaulttransitions'
'innertransitions'
'outertransitions'
'sourcedtransitions'
            }
            pValue=safe_method_linked(propName,objList);

        case{'events','transitions','states','junctions'}
            objType=mlreportgen.utils.capitalizeFirstChar(propName(1:end-1));
            pValue=safe_method_linked('find',objList,'-depth',1,'-isa',['Stateflow.',objType]);
        case 'charts'
            pValue=safe_method_linked('find',objList,'-isa','Stateflow.Chart');



        case 'data'
            objType=mlreportgen.utils.capitalizeFirstChar(propName);
            pValue=safe_method_linked('find',objList,'-depth',1,'-isa',['Stateflow.',objType]);


        case 'parent'
            pValue=safe_method_linked('up',objList);
        case{
'data type'
'datatype'
            }
            pValue=mlreportgen.utils.safeGet(objList,'dataType');
            propName='Data Type';
        case 'document'
            pValue=mlreportgen.utils.safeGet(objList,propName);
            for i=1:length(pValue)
                if~isempty(pValue{i})
                    delimLoc=min(union(find(pValue{i}=='('),find(pValue{i}==' ')));
                    if~isempty(delimLoc)
                        firstToken=pValue{i}(1:delimLoc(1)-1);%#ok<NASGU>
                    end
                end
            end
        case 'label'
            pValue=mlreportgen.utils.safeGet(objList,'LabelString');
        case 'sf id'
            pValue=mlreportgen.utils.safeGet(objList,'id');
        case{'creation date','created'}
            pValue=mlreportgen.utils.safeGet(objList,'created');
            propName='Creation Date';
        case{'created by','creator'}
            pValue=mlreportgen.utils.safeGet(objList,'creator');
            propName='Created By';
        case{'init value','initvalue'}
            propName='props.initialValue';
            dotLoc=findstr(propName,'.');
            if isempty(dotLoc)
                pValue=mlreportgen.utils.safeGet(objList(:,1),propName);
            else
                firstProp=propName(1:dotLoc(1)-1);
                pValue=mlreportgen.utils.safeGet(objList(:,1),firstProp);
                for i=1:length(pValue)
                    eval(['pValue{i} = pValue{i}',propName(dotLoc(1):end),';'],...
                    'pValue{i}=''N/A'';');
                end
            end
        case 'units'

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
            pValue=mlreportgen.utils.safeGet(objList,propName);
            isScript=true;
        case 'simulinksubsystem'
            pValue=safe_method_linked('getDialogProxy',objList);

        case 'text'
            if isa(objList,'Stateflow.Annotation')
                [pValue]=objList.Text;
            else
                pValue=getCommonPropValue(objList,propName);
            end

        otherwise
            pValue=getCommonPropValue(objList,propName);
        end
    end


    function result=safe_method_linked(methodName,objList,varargin)

        for i=length(objList):-1:1
            try
                out{i}=feval(methodName,objList(i),varargin{:});

            catch %#ok<CTCH>
                out{i}='N/A';

            end

        end

        result=out;


        function out=safe_get_linked(propName,objList)

            out=mlreportgen.utils.safeGet(objList,propName);



            function out=get_strip_underscore(objList,propName)




                out=mlreportgen.utils.safeGet(objList,propName);
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


                    function pValue=getCommonPropValue(objList,propName)
                        dotLoc=strfind(propName,'.');
                        if isempty(dotLoc)
                            pValue=mlreportgen.utils.safeGet(objList(:,1),propName);
                        else
                            firstProp=propName(1:dotLoc(1)-1);
                            pValue=mlreportgen.utils.safeGet(objList(:,1),firstProp);
                            for i=1:length(pValue)
                                eval(['pValue{i} = pValue{i}',propName(dotLoc(1):end),';'],...
                                'pValue{i}=''N/A'';');
                            end
                        end
