function schema





    pk=findpackage('siglayout');
    c=schema.class(pk,'gridbaglayout',pk.findclass('gridlayout'));

    p=schema.prop(c,'HorizontalWeights','double_vector');
    set(p,'GetFunction',@get_horizontalweights,'SetFunction',@set_weights);

    p=schema.prop(c,'VerticalWeights','double_vector');
    set(p,'GetFunction',@get_verticalweights,'SetFunction',@set_weights);


    function hw=get_horizontalweights(this,hw)

        nw=size(this.Grid,2);


        hw=[hw,zeros(1,nw-length(hw))];
        hw=hw(1:nw);

        hw=hw(:)';


        function vw=get_verticalweights(this,vw)

            nh=size(this.Grid,1);


            vw=[vw,zeros(1,nh-length(vw))];
            vw=vw(1:nh);

            vw=vw(:);


            function w=set_weights(this,w)

                if any(w<0)
                    error(message('signal:siglayout:gridbaglayout:schema:MustBePositive'));
                end


