function schema





    pk=findpackage('fdtbxgui');
    c=schema.class(pk,'wordfracnrange',pk.findclass('wordnfrac'));

    p=schema.prop(c,'SpecifyWhich','string vector');
    set(p,'SetFunction',@setspecifywhich,'GetFunction',@getspecifywhich);

    p=schema.prop(c,'Ranges','string vector');
    set(p,'GetFunction',@getranges,'SetFunction',@setranges);

    p=schema.prop(c,'EnableFracLengths','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'UMS_Listeners','handle.listener vector');
    set(p,'AccessFlags.PublicSet','Off','AccessFlags.PublicGet','Off');


    function sw=setspecifywhich(this,sw)

        h=getcomponent(this,'-class','siggui.selectorwvalues');

        if isempty(h),return;end

        for indx=1:length(sw)
            set(h(indx),'Selection',sw{indx});
        end

        sw={};


        function sw=getspecifywhich(this,sw)

            h=getcomponent(this,'-class','siggui.selectorwvalues');

            if isempty(h),return;end

            for indx=1:this.Maximum
                sw{indx}=get(h(indx),'Selection');
            end


            function r=getranges(this,r)

                h=getcomponent(this,'-class','siggui.selectorwvalues');

                if isempty(h),return;end

                for indx=1:this.Maximum
                    r{indx}=get(h(indx),'Values');
                    r{indx}=r{indx}{2};
                end


                function r=setranges(this,r)

                    h=getcomponent(this,'-class','siggui.selectorwvalues');

                    if isempty(h),return;end

                    for indx=1:min(this.Maximum,length(this.FracLabels))
                        vals=get(h(indx),'Values');
                        vals{2}=r{indx};
                        set(h(indx),'Values',vals);
                    end

                    r={};


