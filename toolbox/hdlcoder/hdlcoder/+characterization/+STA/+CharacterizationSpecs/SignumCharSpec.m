function spec=SignumCharSpec(compName)





    spec=struct();









    switch compName
    case 'signum_comp'

        spec.dataType='nfpdt';

        port=characterization.PortDesc();
        port.port={1};
        port.range={4,64,4};
        port.widthTemplate='fixdt(1, %d, 0)';
        ports=port;

        spec.params={};
        spec.ports=ports;
        spec.widthSpec={1};

    case 'nfp_signum_comp'

        spec.dataType='nfpdt';

        params=[];

        inport1=characterization.PortDesc();
        inport1.port={1};
        inport1.range={32,64,32};
        inport1.widthTemplate='single';

        ports=inport1;

        spec.params=params;
        spec.ports=ports;
        spec.widthSpec={1};

    end
end
