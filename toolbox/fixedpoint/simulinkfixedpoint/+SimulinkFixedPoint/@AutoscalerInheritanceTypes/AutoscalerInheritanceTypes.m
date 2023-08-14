classdef AutoscalerInheritanceTypes<int16






    enumeration
        UNKNOWNINHERITANCE(-1)
        NOTINHERITED(0)
        ALLPORTSSAMEDATATYPE(1)
        AUTO(2)
        FROMDEFINITIONINCHART(3)
        FROMSIMULINKSIGNALOBJECT(4)
        INHERITFROMBREAKPOINTDATA(5)
        INHERITFROMCONSTANTVALUE(6)
        INHERITFROMGAIN(7)
        INHERITFROMTABLEDATA(8)
        INHERITVIABACKPROPAGATION(9)
        INHERITVIAINTERNALRULE(10)
        INHERITFROMINPUT(11)
        INHERITFROMOUTPUT(12)
        LOGICALSEECONFIGURATIONPARAMETERSOPTIMIZATION(13)
        SAMEASACCUMULATOR(14)
        SAMEASCORRESPONDINGINPUT(15)
        SAMEASFIRSTINPUT(16)
        SAMEASSECONDINPUT(17)
        SAMEASINPUT(18)
        SAMEASPRODUCTOUTPUT(19)
        SAMEASOUTPUT(20)
        SAMEASSIMULINK(21)
        SAMEASTABLE(22)
        SAMEASTABLEPORT(23)
        SAMEWORDLENGTHASINPUT(24)
        SAMEASINPUTSQUAREDPRODUCT(25)
        SAMEASPRODUCT(26)
        SAMEASPRODUCT1(27)
        SAMEASPRODUCT2(28)
        SAMEASPRODUCT3(29)
        SAMEASPRODUCT4(30)
        SAMEASSECTIONINPUT(31)
        INHERITVIAPROPAGATIONRULE(32)
    end

    methods(Static,Hidden)


        inheritanceType=getInheritanceType(dTContainerInfo);



        encodedString=encoder(dataTypeString);


        acceptableTypes=getAcceptableTypes();
    end

end

