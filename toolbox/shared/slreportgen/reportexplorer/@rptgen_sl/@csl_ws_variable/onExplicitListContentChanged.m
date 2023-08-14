function onExplicitListContentChanged(this,value)


    parsedValue=locParseString(value);

    this.filteredPropHash(this.currFilterClass)=parsedValue;

    this.filteredProps=parsedValue;

    function cells=locParseString(stringToParse)

        cells={};

        try

            stringToParse=strrep(stringToParse,' ','');


            stringToParse=strrep(stringToParse,',',''',''');

            if(~isempty(stringToParse))

                eval(['cells={''',stringToParse,'''};']);
            end
        catch ex %#ok<NASGU>

        end