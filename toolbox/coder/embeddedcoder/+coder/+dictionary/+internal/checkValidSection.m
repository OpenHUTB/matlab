function checkValidSection(obj,name)




    if~obj.isvalid||coder.dictionary.internal.isCoderDictionaryRemoved(obj)
        DAStudio.error('SimulinkCoderApp:data:InvalidSection',name);
    end
end
