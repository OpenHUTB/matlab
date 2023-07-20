function propName=getCheckableProperty(h)




    propName='';


    if isempty(h.hParent)&&h.containsModelReference()
        propName='logAsSpecifiedInMdl';
    end

end
