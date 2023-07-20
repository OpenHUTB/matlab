function[elemT1,elemT2]=Ifl_getDistributedStructElements


    eT=embedded.numerictype;
    eT.Signedness='Unsigned';
    eT.WordLength=32;
    eT.FractionLength=0;
    elemT1=embedded.structelement;
    elemT1.Type=eT;
    elemT1.Identifier='Index';


    eT=embedded.numerictype;
    eT.DataTypeMode='single';
    elemT2=embedded.structelement;
    elemT2.Type=eT;
    elemT2.Identifier='Ratio';

end
