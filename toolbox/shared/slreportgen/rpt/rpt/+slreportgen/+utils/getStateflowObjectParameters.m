function propList=getStateflowObjectParameters(h,filterName)




    if strcmpi(filterName,'name')
        propList={
'Name'
'FullPath+Name'
'SFPath+Name'
        };
    else


        switch lower(filterName)
        case 'machine'
            propList={
'Description'
'Document'
'Created'
'Creator'
'Modified'
'Version'
'Charts'
'Data'
'Events'
            };
        case 'chart'
            propList={
'Description'
'Document'
'States'
'Junctions'
'Transitions'
'Data'
'Events'
            };
        case 'state'
            propList={
'Description'
'Document'
'Label'
'Data'
'Events'
            };
        case{'box','function'}
            propList={
'LabelString'
'IsGrouped'
'IsSubchart'
'Document'
'Description'
'Data'
'Events'
            };
        case 'transition'
            propList={
'Source'
'Destination'
'Description'
'ExecutionOrder'
'Document'
'Label'
            };
        case 'junction'
            propList={
'Description'
'Document'
'sourcedTransitions'
            };
        case 'data'
            propList={
'Description'
'Document'
'Scope'
'DataType'
'Range'
'InitValue'
            };
        case 'event'
            propList={
'Description'
'Document'
'Scope'
'Trigger'
            };
        case 'target'
            propList={
'Description'
'Document'
'CustomCode'
'UserSources'
'UserIncludeDirs'
'UserLibraries'
            };
        case{'note','annotation'}
            propList={
'Text'
'Description'
'Document'
            };
        case 'truthtable'
            propList={
'LabelString'
'Document'
'Description'
'BadIntersection'
'UnderSpecDiagnostic'
'OverspecDiagnostic'
            };

        case 'slfunction'
            propList={
'LabelString'
'Description'
'SimulinkSubSystem'
            };
        case 'emfunction'
            propList={
'LabelString'
'Document'
'Script'
'Data'
            };
        case 'port'
            propList={
'LabelString'
'Description'
'Document'
'PortType'
            };
        otherwise
            propList={
'Parent'
'Description'
'Document'
            };
        end
    end