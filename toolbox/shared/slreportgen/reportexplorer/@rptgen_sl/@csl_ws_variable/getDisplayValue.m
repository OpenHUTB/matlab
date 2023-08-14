function[dValue,dName]=getDisplayValue(this,dName)






    dValue=this.PropSrc.getPropValue(this.Variables(dName),'Value');
    dValue=dValue{1};


