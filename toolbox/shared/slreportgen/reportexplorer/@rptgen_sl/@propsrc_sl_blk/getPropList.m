function list=getPropList(h,filterName)




    switch filterName
    case 'all'
        list=LocAllProps(h);
    case 'fcn'
        list=LocFilterList(LocAllProps(h),'Fcn',logical(1));
    case 'mask'
        list=LocFilterList(LocAllProps(h),'Mask');
    case 'display'
        list={
'Position'
'Orientation'
'ForegroundColor'
'BackgroundColor'
'DropShadow'
'NamePlacement'
'ShowName'
'FontName'
'FontSize'
'FontWeight'
'FontAngle'
        };
    case 'main'
        list={
'Name'
'BlockType'
'Tag'
'Description'
'Parent'
'InputSignalNames'
'OutputSignalNames'
'dialogparameters'
'Depth'
'DefinedInBlk'
'UsedByBlk'
        };
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


            persistent PROPSRC_ALL_BLOCK_PROPERTIES

            if isempty(PROPSRC_ALL_BLOCK_PROPERTIES)
                PROPSRC_ALL_BLOCK_PROPERTIES=sort([h.getAllGettableProperties;{
'Depth'
'DefinedInSys'
'UsedBySys'
                }]);
            end

            propNames=PROPSRC_ALL_BLOCK_PROPERTIES;

