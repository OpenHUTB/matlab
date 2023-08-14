function schema





    pk=findpackage('siglayout');
    c=schema.class(pk,'constraints');




    p=schema.prop(c,'MinimumWidth','double');
    set(p,'FactoryValue',20);


    p=schema.prop(c,'MinimumHeight','double');
    set(p,'FactoryValue',20);


    p=schema.prop(c,'PreferredWidth','mxArray');
    set(p,'GetFunction',@get_preferredwidth);

    p=schema.prop(c,'PreferredHeight','mxArray');
    set(p,'GetFunction',@get_preferredheight);

    p=schema.prop(c,'MaximumWidth','double');
    set(p,'FactoryValue',inf);

    p=schema.prop(c,'MaximumHeight','double');
    set(p,'FactoryValue',inf);


    schema.prop(c,'IPadX','double');
    schema.prop(c,'IPadY','double');


    schema.prop(c,'LeftInset','double');
    schema.prop(c,'RightInset','double');
    schema.prop(c,'TopInset','double');
    schema.prop(c,'BottomInset','double');

    if isempty(findtype('ConstraintFillTypes'))
        schema.EnumType('ConstraintFillTypes',...
        {'None',...
        'Horizontal',...
        'Vertical',...
        'Both'});
    end

    if isempty(findtype('ConstraintAnchorTypes'))
        schema.EnumType('ConstraintAnchorTypes',...
        {'Center',...
        'Northwest',...
        'North',...
        'Northeast',...
        'East',...
        'Southeast',...
        'South',...
        'Southwest',...
        'West'});
    end

    schema.prop(c,'Fill','ConstraintFillTypes');
    schema.prop(c,'Anchor','ConstraintAnchorTypes');


    function mw=get_minimumwidth(this,mw)

        if isempty(mw)
            ext=get(this.Component,'Extent');
            mw=ext(3);
            switch get(this.Component,'Style')
            case{'popup','radio'}
                mw=mw+20;
            case{'pushbutton','togglebutton'}
                mw=mw+20;
            case 'text'
                mw=mw+2;
            end
        end


        function mh=get_minimumheight(this,mh)

            if isempty(mh)
                hComp=get(this,'Component');
                ext=get(hComp,'Extent');
                mh=ext(4);
                switch get(hComp,'Style')
                case 'edit'
                    if isempty(get(hComp,'String'))
                        origUnits=get(hComp,'FontUnits');
                        set(hComp,'FontUnits','pixels');
                        mh=9+ceil(get(hComp,'FontSize'));
                        set(hComp,'FontUnits',origUnits);
                    end
                case{'pushbutton','togglebutton'}
                    if~isempty(get(this.Component,'String'))
                        mh=mh+2;
                    end
                end
            end


            function pw=get_preferredwidth(this,pw)

                mw=get(this,'MinimumWidth');



                if isempty(pw)
                    pw=mw;
                elseif pw<mw
                    pw=mw;
                end


                function ph=get_preferredheight(this,ph)

                    mh=get(this,'MinimumHeight');



                    if isempty(ph)
                        ph=mh;
                    elseif ph<mh
                        ph=mh;
                    end


