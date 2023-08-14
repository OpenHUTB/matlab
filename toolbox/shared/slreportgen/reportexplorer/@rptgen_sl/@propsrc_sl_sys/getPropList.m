function list=getPropList(h,filterName)




    switch filterName
    case 'all'
        list=LocAllProps(h);
    case 'paper'
        list=LocFilterList(LocAllProps(h),'Paper');
    case 'fcn'
        list=LocFilterList(LocAllProps(h),'Fcn',logical(1));
    case 'mask'
        list=LocFilterList(LocAllProps(h),'Mask');
    case 'main'
        list={'Name'
'Tag'
'Type'
'Parent'
'Handle'
'Blocks'
'Signals'
'Depth'
        'SnapshotSmall'};
    otherwise
        list={};
    end



    function filtered=LocFilterList(unfiltered,spec,compareEnd)




        listBlock=strvcat(unfiltered{:});
        if nargin>2&compareEnd
            listBlock=strjust(listBlock(:,end:-1:1),'left');
            spec=spec(:,end:-1:1);
        end

        okIndices=strmatch(spec,listBlock);
        filtered=unfiltered(okIndices);


        function propNames=LocAllProps(h)


            persistent PROPSRC_ALL_SYSTEM_PROPERTIES

            if isempty(PROPSRC_ALL_SYSTEM_PROPERTIES)
                PROPSRC_ALL_SYSTEM_PROPERTIES=sort([h.getAllGettableProperties;{
'SnapshotSmall'
'SnapshotLarge'
                }]);
            end

            propNames=PROPSRC_ALL_SYSTEM_PROPERTIES;
