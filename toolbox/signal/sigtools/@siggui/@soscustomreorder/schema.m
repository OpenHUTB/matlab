function schema





    pk=findpackage('siggui');
    c=schema.class(pk,'soscustomreorder',pk.findclass('sigcontainer'));

    if isempty(findtype('sosreorderspecify'))
        schema.EnumType('sosreorderspecify',{'Use Numerator Order','Specify'});
    end

    schema.prop(c,'NumeratorOrder','ustring');
    p=schema.prop(c,'DenominatorOrder','ustring');
    set(p,'GetFunction',@getdenord,'SetFunction',@setdenord);
    p=schema.prop(c,'ScaleValuesOrder','ustring');
    set(p,'GetFunction',@getsvord,'SetFunction',@setsvord);

    p=schema.prop(c,'DenomOrdSource','sosreorderspecify');
    set(p,'GetFunction',@getdenomordsource,'SetFunction',@setdenomordsource);
    p=schema.prop(c,'ScaleVOrdSource','sosreorderspecify');
    set(p,'GetFunction',@getscalevordsource,'SetFunction',@setscalevordsource);

    p=schema.prop(c,'Listeners','handle.listener vector');
    set(p,'AccessFlags.PublicGet','Off','AccessFlags.PublicSet','Off');


    function do=getdenord(this,do)

        hden=getcomponent(this,'tag','denominator');
        if isempty(hden),return;end
        do=get(hden,'Values');
        do=do{2};


        function do=setdenord(this,do)

            hden=getcomponent(this,'tag','denominator');
            if isempty(hden),return;end
            vals={'',do};
            set(hden,'Values',vals);


            function sv=getsvord(this,sv)

                hsv=getcomponent(this,'tag','scalevalues');
                if isempty(hsv),return;end
                sv=get(hsv,'Values');
                sv=sv{2};


                function do=setsvord(this,do)

                    hsv=getcomponent(this,'tag','scalevalues');
                    if isempty(hsv),return;end
                    vals={'',do};
                    set(hsv,'Values',vals);


                    function source=getdenomordsource(this,source)

                        hden=getcomponent(this,'tag','denominator');

                        source=tag2string(get(hden,'Selection'));


                        function source=setdenomordsource(this,source)

                            hden=getcomponent(this,'tag','denominator');

                            set(hden,'Selection',string2tag(source));


                            function source=getscalevordsource(this,source)

                                hsv=getcomponent(this,'tag','scalevalues');

                                source=tag2string(get(hsv,'Selection'));


                                function source=setscalevordsource(this,source)

                                    hsv=getcomponent(this,'tag','scalevalues');

                                    set(hsv,'Selection',string2tag(source));


                                    function tag=string2tag(str)

                                        if strcmpi(str,'Specify')
                                            tag='specify';
                                        else
                                            tag='use';
                                        end


                                        function str=tag2string(tag)

                                            if strcmpi(tag,'use')
                                                str='Use Numerator Order';
                                            else
                                                str='Specify';
                                            end


