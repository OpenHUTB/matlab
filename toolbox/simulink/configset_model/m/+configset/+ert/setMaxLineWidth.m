function newValue=setMaxLineWidth(~,value)



    minvalue=50;
    maxvalue=1000;

    if(value<minvalue||value>maxvalue)
        DAStudio.error('Simulink:ConfigSet:MinMaxCodeLineWidth',minvalue,maxvalue);
    end
    newValue=value;


