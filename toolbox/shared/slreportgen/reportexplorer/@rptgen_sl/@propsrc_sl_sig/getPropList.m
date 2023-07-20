function list=getPropList(h,filterName)





    switch filterName
    case 'all'
        list=[LocAllProps(h)
        getPropList(h,'object')
        ];
    case 'main'
        list={
'Name'
'GraphicalName'
'Tag'
'Description'
'ParentBlock'
'ParentSystem'
'Depth'
'DefinedInBlk'
'UsedByBlk'
        };
    case 'display'
        list={
'Position'
'Rotation'
'FontName'
'FontSize'
'FontWeight'
'FontAngle'
        };
    case 'object'
        hObj=Simulink.Parameter;
        hProps=Simulink.data.getPropList(hObj,...
        'GetAccess','public',...
        'Hidden',false);
        list={hProps.Name}';
    case 'other'
        list={'DocumentLink'
'RTWStorageClass'
        'RTWStorageTypeQualifier'};
    end


    function propNames=LocAllProps(h)


        persistent PROPSRC_ALL_SIGNAL_PROPERTIES

        if isempty(PROPSRC_ALL_SIGNAL_PROPERTIES)
            PROPSRC_ALL_SIGNAL_PROPERTIES=sort([h.getAllGettableProperties;{
'Depth'
'GraphicalName'
'ParentBlock'
'ParentSystem'
'DefinedInSys'
'UsedBySys'
            }]);
        end

        propNames=PROPSRC_ALL_SIGNAL_PROPERTIES;

