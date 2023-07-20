function schema





    pk=findpackage('dspopts');
    c=schema.class(pk,'spectrum',findclass(pk,'abstractspectrumwfreqpoints'));

    schema.prop(c,'SpectrumType','SignalSpectrumTypeList');


    p=schema.prop(c,'ConfLevel','mxArray');
    set(p,'AccessFlag.PublicSet','on',...
    'SetFunction',@set_ConfLevel,...
    'GetFunction',@get_ConfLevel);


    schema.prop(c,'ConfInterval','twocol_nonneg_matrix');


    function ConfLevel=set_ConfLevel(this,ConfLevel)


        if(~isempty(ConfLevel)&&(~isnumeric(ConfLevel)||~isscalar(ConfLevel)...
            ||ConfLevel==0||abs(ConfLevel)>=1))
            error(message('signal:dspopts:spectrum:schema:invalidConfidenceLevel'));
        end


        function ConfLevel=get_ConfLevel(this,ConfLevel)


            if isempty(ConfLevel)
                ConfLevel='Not Specified';
            end


