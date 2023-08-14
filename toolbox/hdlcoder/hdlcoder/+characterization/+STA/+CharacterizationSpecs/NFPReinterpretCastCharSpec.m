function spec=getCharacterizationSpec(compName)




    spec=struct();









    spec.dataType='nfpdt';

    switch compName
    case 'nfp_cast_comp'
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
