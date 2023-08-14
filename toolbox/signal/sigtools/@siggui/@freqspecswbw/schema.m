function schema





    pk=findpackage('siggui');
    c=schema.class(pk,'freqspecswbw',pk.findclass('freqframe'));
    set(c,'Description','Frequency Specifications');

    p=schema.prop(c,'Values','string vector');
    set(p,'SetFunction',@setvalues,'GetFunction',@getvalues);

    p=schema.prop(c,'Labels','string vector');
    set(p,'SetFunction',@setlabels,'GetFunction',@getlabels);

    p=schema.prop(c,'nonBWLabel','ustring');
    set(p,'FactoryValue','Rolloff','SetFunction',@setnonbwlbl,'GetFunction',@getnonbwlbl);

    if isempty(findtype('sigguiBWvnonBW'))
        schema.EnumType('sigguiBWvnonBW',{'bandwidth','nonbw','none'});
    end

    p=schema.prop(c,'TransitionMode','sigguiBWvnonBW');
    set(p,'SetFunction',@settmode,'GetFunction',@gettmode);

    p=schema.prop(c,'Bandwidth','ustring');
    set(p,'SetFunction',@setbandwidth,'GetFunction',@getbandwidth);

    p=schema.prop(c,'nonBW','ustring');
    set(p,'SetFunction',@setnonbw,'GetFunction',@getnonbw);


    function out=setlabels(this,out)

        set(getcomponent(this,'-class','siggui.labelsandvalues'),'Labels',out);
        out={''};


        function out=getlabels(this,out)

            out=get(getcomponent(this,'-class','siggui.labelsandvalues'),'Labels');
            if isempty(out),out={''};end


            function out=setvalues(this,out)

                set(getcomponent(this,'-class','siggui.labelsandvalues'),'Values',out);
                out={''};


                function out=getvalues(this,out)

                    out=get(getcomponent(this,'-class','siggui.labelsandvalues'),'Values');
                    if isempty(out),out={''};end



                    function out=settmode(this,out)

                        hs=getcomponent(this,'-class','siggui.selectorwvalues');
                        if strcmpi(out,'none')
                            disableselection(hs,'bandwidth','nonbw');
                        else
                            enableselection(hs,'bandwidth','nonbw');
                            set(hs,'Selection',lower(out));
                        end


                        function out=gettmode(this,out)

                            hs=getcomponent(this,'-class','siggui.selectorwvalues');
                            if~isempty(hs)
                                if isempty(getenabledselections(hs))
                                    out='none';
                                else
                                    out=get(hs,'Selection');
                                    if isempty(out),out='none';end
                                end
                            end


                            function out=setnonbwlbl(this,out)

                                setstring(getcomponent(this,'-class','siggui.selectorwvalues'),'nonbw',out);
                                out='';


                                function out=getnonbwlbl(this,out)

                                    hs=getcomponent(this,'-class','siggui.selectorwvalues');
                                    if~isempty(hs),out=getstring(hs,'nonbw');end


                                    function out=setbandwidth(this,out)

                                        hs=getcomponent(this,'-class','siggui.selectorwvalues');

                                        vals=get(hs,'Values');
                                        vals{1}=out;
                                        set(hs,'Values',vals);

                                        out='';


                                        function out=getbandwidth(this,out)

                                            hs=getcomponent(this,'-class','siggui.selectorwvalues');
                                            if~isempty(hs)
                                                out=get(hs,'Values');
                                                out=out{1};
                                            end


                                            function out=setnonbw(this,out)

                                                hs=getcomponent(this,'-class','siggui.selectorwvalues');

                                                vals=get(hs,'Values');
                                                vals{2}=out;
                                                set(hs,'Values',vals);

                                                out='';


                                                function out=getnonbw(this,out)

                                                    hs=getcomponent(this,'-class','siggui.selectorwvalues');
                                                    if~isempty(hs)
                                                        out=get(hs,'Values');
                                                        out=out{2};
                                                    end


