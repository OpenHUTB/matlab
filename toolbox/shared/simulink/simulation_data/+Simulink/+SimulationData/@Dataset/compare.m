






































function[equal,mismatches]=compare(this,other,varargin)
    [varargin{:}]=convertStringsToChars(varargin{:});

    equal=false;
    mismatches={};


    parser=inputParser;
    parser.addRequired('this');
    parser.addRequired('other');
    parser.addParameter('PropertiesToIgnore',{},...
    @(x)iscell(x)&&all(cellfun(@(xx)(ischar(xx)||isstring(xx)),x)));
    parser.addParameter('IgnoreOrder',false,...
    @(x)validateattributes(x,{'numeric','logical'},{'scalar'}));
    parser.parse(this,other,varargin{:});
    params.propsToIgnore=cellfun(@(x)convertStringsToChars(x),parser.Results.PropertiesToIgnore,'UniformOutput',false);
    params.ignoreOrder=parser.Results.IgnoreOrder;


    params.propsToIgnore=[params.propsToIgnore,'IsTimeFirst_'];


    params.propsToIgnore=[params.propsToIgnore,...
    'Increment_','Time_','Start_'];



    params.propsToIgnore=[params.propsToIgnore,'Simulink.SimulationData.Signal.Version'];


    params.propsToIgnore=[params.propsToIgnore,...
    'Simulink.SimulationData.DatasetRef.Location',...
    'Simulink.SimulationData.DatasetRef.Identifier'];


    params.propsToIgnore=strcat(params.propsToIgnore,{'$'});


    params.propToIgnoreMap=containers.Map('KeyType','char','ValueType','logical');




    objectName='<input expression>';



    wState=warning('off','SimulationData:Objects:InvalidAccessToDatasetElement');


    mismatches=locCompareData(...
    this,other,objectName,params,mismatches);


    if isempty(mismatches)
        equal=true;
    end

    warning(wState);

end

function[mismatches,params]=...
    locCompareData(actual,expected,propName,params,mismatches)



    classActual=class(actual);
    datasetTypes={'Simulink.SimulationData.Dataset',...
    'Simulink.SimulationData.DatasetRef'};
    if~isequal(classActual,class(expected))


        if~(ismember(classActual,datasetTypes)&&ismember(class(expected),datasetTypes))
            mismatches=locAppendMismatches(mismatches,propName);
            return;
        end
    end


    if~isequal(size(actual),size(expected))
        mismatches=locAppendMismatches(mismatches,propName);
        return;
    end


    if isempty(actual)&&isempty(expected)
        return;
    end

    numElement=numel(expected);


    if isequal(classActual,'struct')


        namesActual=fieldnames(actual);
        namesExpected=fieldnames(expected);
        if~isequal(namesActual,namesExpected)
            mismatches=locAppendMismatches(mismatches,propName);
            return;
        end


        for idxArray=1:numElement
            for idx=1:length(namesExpected)
                nameExpected=namesExpected{idx};
                newPropName=...
                sprintf('%s.%s',...
                locGenerateIndexedPropName(propName,idxArray,numElement),nameExpected);
                subPropActual=actual(idxArray).(nameExpected);
                subPropExpected=expected(idxArray).(nameExpected);

                [mismatches,params]=...
                locCompareData(subPropActual,subPropExpected,...
                newPropName,params,mismatches);
            end
        end


    elseif isequal(classActual,'cell')

        for idxArray=1:numElement
            newPropName=...
            sprintf('%s{%d}',propName,idxArray);
            subPropActual=actual{idxArray};
            subPropExpected=expected{idxArray};

            [mismatches,params]=...
            locCompareData(subPropActual,subPropExpected,...
            newPropName,params,mismatches);
        end


    elseif any(...
        ismember(...
        {
'timeseries'
'tsdata.timemetadata'
'tsdata.datametadata'
        },...
classActual...
        )...
        )...
        ||isa(actual,'Simulink.SimulationData.BlockData')...
        ||isa(actual,'Simulink.SimulationData.Dataset')...
        ||isa(actual,'Simulink.SimulationData.DatasetRef')

        for idxArray=1:numElement
            newPropName=locGenerateIndexedPropName(propName,idxArray,numElement);
            subPropActual=actual(idxArray);
            subPropExpected=expected(idxArray);
            [mismatches,params]=...
            locCompareObjects(subPropActual,subPropExpected,...
            newPropName,params,mismatches);
        end


    elseif isequal(classActual,'timetable')

        newPropName=sprintf('%s.Properties',propName);
        subPropActual=actual.Properties;
        subPropExpected=expected.Properties;
        [mismatches,params]=...
        locCompareData(subPropActual,subPropExpected,...
        newPropName,params,mismatches);

        if isequal(actual.Properties.VariableNames,expected.Properties.VariableNames)
            timeTableDataName=expected.Properties.VariableNames{:};
            newPropName=sprintf('%s.%s',propName,timeTableDataName);
            subPropActual=actual.(timeTableDataName);
            subPropExpected=expected.(timeTableDataName);
            [mismatches,params]=...
            locCompareData(subPropActual,subPropExpected,...
            newPropName,params,mismatches);
        end


    elseif isequal(classActual,'matlab.io.datastore.SimulationDatastore')
        for idxArray=1:numElement
            newPropName=locGenerateIndexedPropName(propName,idxArray,numElement);
            newPropName=sprintf('%s.readall',newPropName);
            subPropActual=actual(idxArray);
            subPropExpected=expected(idxArray);

            if~isequal(subPropActual,subPropExpected)

                subPropFullActual=subPropActual.readall;
                subPropFullExpected=subPropExpected.readall;
                [mismatches,params]=...
                locCompareData(subPropFullActual,subPropFullExpected,...
                newPropName,params,mismatches);
            end
        end


    else
        if~locIsEqual(actual,expected)
            mismatches=locAppendMismatches(mismatches,propName);
            return;
        end
    end
end


function[mismatches,params]=locCompareObjects(...
    actual,expected,propName,params,mismatches)





    mExpected=metaclass(expected);
    propCellExpected=[mExpected.Properties{:}];
    propCellNamesExpected={propCellExpected.Name};




    for idxExpected=1:length(propCellExpected)

        propNameExpected=propCellNamesExpected{idxExpected};
        propVarName=[propName,'.',propNameExpected];
        propClassName=[mExpected.Name,'.',propNameExpected];


        [isPropertyIgnored,params]=...
        locIsPropertyIgnored(params,propClassName);
        if isPropertyIgnored
            continue;
        end


        if(isequal(propCellExpected(idxExpected).GetAccess,'public'))
            propActual=actual.(propNameExpected);
            propExpected=expected.(propNameExpected);

            [mismatches,params]=locCompareData(propActual,propExpected,...
            propVarName,...
            params,mismatches);



        elseif(...
            strcmp(propNameExpected,'Storage_')&&...
            isa(expected,'Simulink.SimulationData.Dataset')...
            )...
            ||...
            (...
            strcmp(propNameExpected,'Dataset_')&&...
            isa(expected,'Simulink.SimulationData.DatasetRef')...
            )

            numElemActual=actual.getLength;
            numElemExpected=expected.getLength;


            if~isequal(numElemActual,numElemExpected)
                mismatches=locAppendMismatches(mismatches,...
                [propName,'.getLength']);
                continue;
            end


            for idxElemExpected=1:numElemExpected

                elemExpected=expected.getElement(idxElemExpected);
                elemExpectedName=...
                sprintf('%s.get(%d)',propName,idxElemExpected);

                if(params.ignoreOrder)




                    elemName=propName;

                    elemActual=actual;
                    elemExpectedClassName=class(elemExpected);



                    [isPropertyIgnored,params]=...
                    locIsPropertyIgnored(params,...
                    [elemExpectedClassName,'.Name']);
                    if~isPropertyIgnored
                        elemActual=elemActual.get(elemExpected.Name);
                        elemName=...
                        [elemName,'.get(',elemExpectedName,'.Name, ''Property'', ''Name'')'];%#ok<AGROW>
                    end



                    if...
                        (...
                        isa(elemActual,'Simulink.SimulationData.Dataset')||...
                        isa(elemActual,'Simulink.SimulationData.DatasetRef')...
                        )
                        [isPropertyIgnored,params]=...
                        locIsPropertyIgnored(params,...
                        [elemExpectedClassName,'.BlockPath']);
                        if~isPropertyIgnored
                            elemActual=elemActual.get(...
                            elemExpected.BlockPath,...
                            'Property','BlockPath');
                            elemName=...
                            [elemName,'.get(',elemExpectedName,'.BlockPath, ''Property'', ''BlockPath'')'];%#ok<AGROW>
                        end
                    end




                    if...
                        (...
                        isa(elemActual,'Simulink.SimulationData.Dataset')||...
                        isa(elemActual,'Simulink.SimulationData.DatasetRef')...
                        )...
                        &&isprop(elemActual.get(1),'PortIndex')

                        [isPropertyIgnored,params]=...
                        locIsPropertyIgnored(params,...
                        [elemExpectedClassName,'.PortIndex']);
                        if~isPropertyIgnored
                            elemActual=elemActual.get(...
                            elemExpected.PortIndex,'Property','PortIndex');
                            elemName=...
                            [elemName,'.get(',elemExpectedName,'.PortIndex,''Property'',''PortIndex'')'];%#ok<AGROW>
                        end
                    end






                else
                    elemName=elemExpectedName;
                    elemActual=actual.getElement(idxElemExpected);
                end

                [mismatches,params]=locCompareData(elemActual,elemExpected,...
                elemName,params,mismatches);
            end
        end

    end
end

function equal=locIsEqual(varargin)

    equal=isequaln(varargin{1},varargin{2});
end

function mismatches=locAppendMismatches(mismatches,mismatch)

    mismatches=union(mismatches,mismatch);
end

function[isIgnored,params]=locIsPropertyIgnored(params,prop)

    propMap=params.propToIgnoreMap;
    if isKey(propMap,prop)
        isIgnoredCell=values(propMap,{prop});
        isIgnored=isIgnoredCell{1};
    else
        isIgnored=false;
        propsToIgnore=params.propsToIgnore;
        for idx=1:length(propsToIgnore)
            if~isempty(regexp(prop,propsToIgnore{idx},'once'))
                isIgnored=true;
                break;
            end
        end
        params.propToIgnoreMap(prop)=isIgnored;
    end
end

function propName=locGenerateIndexedPropName(propName,idx,numElement)



    if numElement>1
        if~isempty(propName)&&isequal(propName(end),')')
            propName=sprintf('%s; ans(%d)',propName,idx);
        else
            propName=sprintf('%s(%d)',propName,idx);
        end
    end
end

