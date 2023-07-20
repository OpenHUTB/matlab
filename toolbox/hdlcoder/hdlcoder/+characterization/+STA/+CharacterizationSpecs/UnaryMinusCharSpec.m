function spec=UnaryMinusCharSpec(compName)





    spec=struct();








    switch compName

    case 'unaryminus_comp'

        spec.dataType='fixdt';

        port=characterization.PortDesc();
        port.port={1};
        port.range={4,64,4};
        port.widthTemplate='fixdt(1, %d, 0)';
        ports=port;

        spec.params={};
        spec.ports=ports;
        spec.widthSpec={1};

    case 'nfp_uminus_comp'

        spec.dataType='nfpdt';
        params=[];

        inport1=characterization.PortDesc();
        inport1.port={1};
        inport1.range={32,64};
        inport1.widthTemplate='';

        ports=inport1;

        spec.params=params;
        spec.ports=ports;
        spec.widthSpec={1};

    end
end
