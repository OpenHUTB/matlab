function spec=AbsCharSpec(compName)





    spec=struct();








    switch compName
    case 'abs_comp'

        spec.dataType='fixdt';
        port=characterization.PortDesc();
        port.port={1};
        port.range={4,64,4};
        port.widthTemplate='fixdt(1, %d, 0)';
        ports=port;

        spec.params={};
        spec.ports=ports;
        spec.widthSpec={1};

    case 'nfp_abs_comp'

        spec.dataType='nfpdt';
        port=characterization.PortDesc();
        port.port={1};
        port.range={32,64};
        port.widthTemplate='';

        spec.params={};
        spec.ports=port;
        spec.widthSpec={1};
    end
end
