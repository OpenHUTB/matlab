function schema





    pk=findpackage('siggui');

    c=schema.class(pk,'firwinoptionsframe',pk.findclass('sigcontainer'));


    p=schema.prop(c,'Scale','on/off');
    set(p,'Description','Scale Passband','FactoryValue','on');


    if isempty(findtype('SignalSpectrumWindowList'))
        [winclasses,winnames]=findallwinclasses;
        schema.EnumType('SignalSpectrumWindowList',winnames(1:end-1));
    end

    p=schema.prop(c,'Window','SignalSpectrumWindowList');
    set(p,'SetFunction',@set_window,'GetFunction',@get_window);

    p=schema.prop(c,'Parameter','ustring');
    set(p,'SetFunction',@set_parameter,'GetFunction',@get_parameter,...
    'Description','Sidelobe Level','AccessFlags.Init','off');

    p=schema.prop(c,'Parameter2','ustring');
    set(p,'SetFunction',@set_parameter2,'GetFunction',@get_parameter2,...
    'AccessFlags.Init','off');

    p=schema.prop(c,'privWindow','mxArray');
    set(p,'Visible','off');

    schema.prop(c,'isMinOrder','bool');

    p=schema.prop(c,'ParameterCache','mxArray');
    set(p,'Visible','off');


    schema.event(c,'OrderRequested');


    function parameter=set_parameter(this,parameter)


        paramName=getParamNames(this);
        paramName=paramName{1};


        if~isempty(paramName)
            this.ParameterCache.(paramName)=parameter;
        end


        function parameter=get_parameter(this,parameter)


            paramName=getParamNames(this);
            paramName=paramName{1};


            if~isempty(paramName)
                parameter=getParameterFromCache(this,paramName);
            end


            function parameter=set_parameter2(this,parameter)


                paramName=getParamNames(this);
                paramName=paramName{2};


                if~isempty(paramName)
                    this.ParameterCache.(paramName)=parameter;
                end


                function parameter=get_parameter2(this,parameter)


                    paramName=getParamNames(this);
                    paramName=paramName{2};

                    if~isempty(paramName)


                        parameter=getParameterFromCache(this,paramName);
                    end


                    function parameter=getParameterFromCache(this,paramName)

                        if isfield(this.ParameterCache,paramName)
                            parameter=this.ParameterCache.(paramName);
                        elseif isprop(this.privWindow,paramName)
                            parameter=mat2str(this.privWindow.(paramName));
                        else
                            parameter='';
                        end


